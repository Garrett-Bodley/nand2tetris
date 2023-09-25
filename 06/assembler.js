#! /usr/bin/env node
const PATH = "pong/PongL.asm";

const fs = require("node:fs");
const path = require("node:path");
const readline = require("node:readline");

class SymbolTable {
  static varMemoryStart = 1024;

  constructor() {
    this.dict = {
      SP: 0,
      LCL: 1,
      ARG: 2,
      THIS: 3,
      THAT: 4,
      R0: 0,
      R1: 1,
      R2: 2,
      R3: 3,
      R4: 4,
      R5: 5,
      R6: 6,
      R7: 7,
      R8: 8,
      R9: 9,
      R10: 10,
      R11: 11,
      R12: 12,
      R13: 13,
      R14: 14,
      R15: 15,
      SCREEN: 16384,
      KBD: 24576,
    };
    this.labelCount = 0;
    this.varCount = 0;
  }

  addEntry(string, address) {
    this.dict[string] = address;
  }

  contains(string) {
    return this.dict[string] !== undefined;
  }

  getAddress(string) {
    if (this.contains(string)) return this.dict[string];
    throw Error("Provided string was not found in the SymbolTable");
  }
}

class CodeTable {
  static ALUDict = {
    0: "0101010",
    1: "0111111",
    "-1": "0111010",
    D: "0001100",
    A: "0110000",
    "!D": "0001101",
    "!A": "0110001",
    "-D": "0001111",
    "-A": "0110011",
    "D+1": "0011111",
    "1+D": "0011111",
    "A+1": "0110111",
    "1+A": "0110111",
    "D-1": "0001110",
    "A-1": "0110010",
    "D+A": "0000010",
    "A+D": "0000010",
    "D-A": "0010011",
    "A-D": "0000111",
    "D&A": "0000000",
    "A&D": "0000000",
    "D|A": "0010101",
    "A|D": "0010101",

    M: "1110000",
    "!M": "1110001",
    "-M": "1110011",
    "M+1": "1110111",
    "M-1": "1110010",
    "D+M": "1000010",
    "M+D": "1000010",
    "D-M": "1010011",
    "M-D": "1000111",
    "D&M": "1000000",
    "M&D": "1000000",
    "D|M": "1010101",
    "M|D": "1010101",
  };

  static destDict = {
    M: "001",
    D: "010",
    MD: "011",
    A: "100",
    AM: "101",
    AD: "110",
    AMD: "111",
  };

  static jumpDict = {
    JGT: "001",
    JEQ: "010",
    JGE: "011",
    JLT: "100",
    JNE: "101",
    JLE: "110",
    JMP: "111",
  };

  static dict = {
    ALUDict: CodeTable.ALUDict,
    destDict: CodeTable.destDict,
    jumpDict: CodeTable.jumpDict,
  };

  dest(string = "") {
    if (string.length == 0) return "000";
    return CodeTable.dict.destDict[string];
  }

  comp(string) {
    return CodeTable.dict.ALUDict[string];
  }

  jump(string = "") {
    if (string.length == 0) return "000";
    return CodeTable.dict.jumpDict[string];
  }
}

class Parser {
  constructor(relativePath) {
    const {
      symbolProcessingRLInterface,
      finalAssemblyRLInterface,
      writeStream,
    } = this.#setupIO(relativePath);
    this.symbolProcessingRLInterface = symbolProcessingRLInterface;
    this.finalAssemblyRLInterface = finalAssemblyRLInterface;
    this.writeStream = writeStream;
    this.symbolTable = new SymbolTable();
    this.codeTable = new CodeTable();
  }

  parse() {
    let lineNum = 1;
    this.finalAssemblyRLInterface.on("line", (line) => {
      const trimmedLine = this.removeTrailingComments(line).trim();
      const [commandType, commandString] = this.caseLine(trimmedLine);

      let trimmedCommandString;
      let machineCode;
      switch (commandType) {
        case "COMMENT":
          console.log(
            `Line Num: ${lineNum}\nCommand Type: ${commandType}\n\nSkipping Code Comment on Line ${lineNum}\n\nLine Contents:\n${commandString}\n\n--------------------------------`
          );
          break;
        case "EMPTY":
          console.log(
            `Line Num: ${lineNum}\nCommand Type:${commandType}\n\nSkipping Empty Line\n\n--------------------------------`
          );
          break;
        case "A_COMMAND":
          trimmedCommandString = this.removeAllWhiteSpace(commandString);
          machineCode = `0${this.translateACommand(trimmedCommandString)}`;

          console.log(
            `LineNum: ${lineNum}\nCommand Type: ${commandType}\n\nLine Contents:\n${trimmedCommandString}\nTranslated to 16 bit Binary:\n${machineCode}\n\n-------------------------------`
          );
          this.writeStream.write(`${machineCode}\n`);
          break;
        case "C_COMMAND":
          // Example instruction code:
          // ixxaccccccdddjjj

          trimmedCommandString = this.removeAllWhiteSpace(commandString);
          const CommandTokens = this.tokenizeCCommand(commandString);

          let compMachineCode = this.codeTable.comp(CommandTokens.comp);
          let destMachineCode = this.codeTable.dest(CommandTokens.dest);
          let jumpMachineCode = this.codeTable.jump(CommandTokens.jump);

          machineCode = `111${compMachineCode}${destMachineCode}${jumpMachineCode}`;
          console.log(
            `LineNum: ${lineNum}\nCommand Type: ${commandType}\n\nLine Contents:\n${trimmedCommandString}\nTranslated to 16 bit Binary:\n${machineCode}\n\n-------------------------------`
          );
          this.writeStream.write(`${machineCode}\n`);
          break;
      }

      lineNum++;
    });
  }

  removeTrailingComments(line) {
    // removes any trailing comment text before trimming all whitespace characters from both the start and end of the string
    return line.replace(/(?<=\S)\s*\/\/.*$/, "");
  }

  removeAllWhiteSpace(string) {
    return string.replace(/\s/g, "");
  }

  caseLine(line) {
    if (line.match(/(^\/\/)/)) return ["COMMENT", line];
    if (line.length == 0) return ["EMPTY", ""];
    if (line.includes("@"))
      return ["A_COMMAND", this.removeAllWhiteSpace(line)];
    return ["C_COMMAND", this.removeAllWhiteSpace(line)];
  }

  translateACommand(commandString) {
    commandString = commandString.replace("@", "");
    let binaryVal = this.#twosCompliment(parseInt(commandString), 15);
    return binaryVal;
  }

  tokenizeCCommand(commandString) {
    let [comp, dest, jump] = ["", "", ""];
    if (commandString.includes("=")) {
      [dest, comp] = commandString.split("=");
    } else if (commandString.includes(";")) {
      [comp, jump] = commandString.split(";");
    } else {
      throw Error(
        `Error: Invalid Command Provided\nCommand String:\n${commandString}\n\n--------------------------------`
      );
    }
    return { comp, dest, jump };
  }

  #setupIO(relativePath) {
    const [inPath, outPath] = this.#pathParse(relativePath);

    const symbolProcessingReadStream = this.#createReadStream(inPath);
    const finalAssemblyReadStream = this.#createReadStream(inPath);

    const writeStream = this.#createWriteStream(outPath);

    const symbolProcessingRLInterface = readline.createInterface({
      input: symbolProcessingReadStream,
    });

    const finalAssemblyRLInterface = readline.createInterface({
      input: finalAssemblyReadStream,
    });

    return {
      symbolProcessingRLInterface,
      finalAssemblyRLInterface,
      writeStream,
    };
  }

  #createReadStream(path) {
    const stream = fs.createReadStream(path, { encoding: "utf-8" });
    stream.on("error", (e) => {
      throw Error(`Error: ${e.message}`);
    });
    return stream;
  }

  #createWriteStream(path) {
    const stream = fs.createWriteStream(path);
    stream.on("error", (e) => {
      throw Error(`Error: ${e.message}`);
    });
    return stream;
  }

  #pathParse(relativePath) {
    const parseObj = path.parse(path.join(__dirname, relativePath));
    if (parseObj.ext !== ".asm") throw Error("Invalid file type!");
    const inPath = path.join(parseObj.dir, parseObj.base);
    const outPath = `${parseObj.dir}/${parseObj.name}.hack`;
    return [inPath, outPath];
  }

  #twosCompliment(value, bitCount) {
    // Borrowed from Brandon Sará's gist. Thank you Brandon!
    // https://gist.github.com/bsara/519df5f91833d01c20ec

    let binaryStr;
    if (value >= 0) {
      let twosComp = value.toString(2);
      binaryStr = this.#padAndChop(twosComp, "0", bitCount || twosComp.length);
    } else {
      binaryStr = (Math.pow(2, bitCount) + value).toString(2);
    }

    if (Number(binaryStr) < 0) return undefined;

    return binaryStr;
  }

  #padAndChop(str, padChar, length) {
    return (Array(length).fill(padChar).join("") + str).slice(length * -1);
  }
}

try {
  const parser = new Parser(PATH);
  parser.parse();
} catch (e) {
  console.log(e);
}
