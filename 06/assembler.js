#! /usr/bin/env node
const PATH = "pong/Pong.asm";

const fs = require("node:fs");
const path = require("node:path");
const readline = require("node:readline");

// ARCHITECTURE OF PROBLEM
// - Reading an assembly file and translating it to machine code
// - I must read the file twice. Parsing the labels used for jumps requires a preprocessing step before final translation
// - I am using the readlines module to read through the file line by line
// - ** I am creating a readlines Interface object by feeding readline.creatInterface a readStream object **
// - At first, I initialized both Interface objects at the same time, one for each pass over the file.
//   - I then assigned a callback to the second Interface instance after awaiting the "close" event of the first Interface's stream
//   - This did not work
//   - If I didn't await the "close" event of the first Interface, then both processing steps would happen at the same time, which is not the desired functionality

// PROBLEM
// 1. Something is getting messed up with the second readline Interface instance
// 2. I was handing the interface a callback for its onLine event handler, but that callback was never getting called
// 3. If I check the stream associated with the InterfaceObject, it says there is content left to read
// 4. Nonetheless, the callback function for the "line" event is not getting called during the second pass

// CURRENT SOLUTION
// - Instantiate BOTH the stream and second interface upon the first stream closing
//   - This is done inside the interfaces onClose event handler

// QUESTIONS
// 1. Why can't I initialize the second stream in the class constructor?
// 2. Using the broken solution, when I check the readableStream associated with the second Interface object it says that there is content to read
//   a. If there is content remaining, why is the callback not being called?
// 3. What is happening between intialization and the second pass that is invalidating the second Interface object?

// SIDEQUEST
// - Before wrapping the callback declaration in a promise I also tried using an async interator 
//    Ex: for await (const line of readlineInterface)){ doThings(line) }
// - Is there a way to wrap that in a Promise as well?
// - Why the heck do I have to do so much work just to get synchronous, blocking, imperative code??

// SIDEQUEST TWO: ELECTRIC BOOGALOO
// - At some point I was getting segfaults while trying to step through the program using the debugger?
// - How the heck am I causing a segfault when I'm just trying to read a file?
// - What is going on lol


class SymbolTable {
  static variableStartAddress = 16;

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
    this.usedAddresses = this.#initUsedAddresses(this.dict);
    this.addedVariableCount = 0;
  }

  addLabel(string, address) {
    // I hardcoded this debugger bc the program was failing on this label prior to adding an await statement
    if(string == "memory.peek") debugger
    if (this.contains(string))
      throw Error(`Error: Provided label name has already been used\nAttempted Add String: ${string}`);
    this.dict[string] = parseInt(address);
    return this.getAddress(string);
  }

  addVariable(string) {
    // I hardcoded this debugger bc the program was failing on this label prior to adding an await statement
    if(string == "memory.peek") debugger
    if (this.contains(string))
      throw Error(`Error: Provided variable name has already been used\nAttempted Add String: ${string}`);
    this.dict[string] =
      SymbolTable.variableStartAddress + this.addedVariableCount;
    this.addedVariableCount++;

    return this.getAddress(string);
  }

  contains(string) {
    return this.dict[string] !== undefined;
  }

  getAddress(string) {
    if (this.contains(string)) return this.dict[string];
    throw Error("Provided string was not found in the SymbolTable");
  }

  #initUsedAddresses = (dict) => {
    let used = new Set();
    for (const key in dict) {
      used.add(dict[key]);
    }
    return used;
  };
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
    this.relativePath = relativePath
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

  async firstPass() {
    console.log("STARTING FIRST PASS");

    
    return new Promise((resolve, reject) => {
      let lineNum = 1;
      let machineCodeLineNum = 0;
      this.symbolProcessingRLInterface.on("line", (line) => {
        const trimmedLine = this.removeTrailingComments(line).trim();
        const [commandType, commandString] = this.caseLine(trimmedLine);
  
        switch (commandType) {
          case "COMMENT":
            console.log(
              `Line Num: ${lineNum}\nMachine Code Line Num: ${machineCodeLineNum}\nCommand Type: ${commandType}\n\nSkipping Code Comment on Line ${lineNum}\n\nLine Contents:\n${commandString}\n\n--------------------------------`
            );
            break;
          case "EMPTY":
            console.log(
              `Line Num: ${lineNum}\nCommand Type: ${commandType}\n\nSkipping Empty Line\n\n--------------------------------`
            );
            break;
          case "A_COMMAND":
            console.log(
              `LineNum: ${lineNum}\nMachine Code Line Num: ${machineCodeLineNum}\nCommand Type: ${commandType}\n\nLine Contents:\n${commandString}\nIGNORED ON FIRST PASS\n\n-------------------------------`
            );
            machineCodeLineNum++;
            break;
          case "C_COMMAND":
            console.log(
              `LineNum: ${lineNum}\nMachine Code Line Num: ${machineCodeLineNum}\nCommand Type: ${commandType}\n\nLine Contents:\n${commandString}\nIGNORED ON FIRST PASS\n\n-------------------------------`
            );
            machineCodeLineNum++;
            break;
          case "L_COMMAND":
            // This debugger never gets triggered. Why? Is it because it's inside a Promise?
            if(commandString == "memory.peek") debugger
            this.symbolTable.addLabel(
              this.removeParenthesis(commandString),
              machineCodeLineNum
            );
            console.log(
              `LineNum: ${lineNum}\nMachine Code Line Num: ${machineCodeLineNum}\nCommand Type: ${commandType}\n\nLine Contents:\n${commandString}\nADDED TO SYMBOL TABLE\nSymbolTable Key: ${this.removeParenthesis(commandString)}\nSymbolTable Value: ${this.symbolTable.getAddress(this.removeParenthesis(commandString))}\n-------------------------------`
            );
            break;
        }
        lineNum++
      });

      this.symbolProcessingRLInterface.on("close", _ => {
        // Why do I have to reinitialize the stream here?
        const inPath = this.#pathParse(this.relativePath)[0]
        this.finalAssemblyRLInterface = readline.createInterface({
          input: this.#createReadStream(inPath)
        });
        resolve()
      })
    })
  }

  async parse() {
    await this.firstPass()
    debugger
    console.log("STARTING SECOND PASS")

    // ▼▼ Turns out I can do this in the onClose event handler. Still don't know why I can't initialize the stream upon object construction ▼▼

    // Hacky Interface reinitialization. It's ugly but it works. I have no idea why tho
    // const [inPath, _] = this.#pathParse(this.relativePath);
    // const secondStream = this.#createReadStream(inPath)

    // const secondInterface = readline.createInterface({
    //   input: secondStream,
    // });

    let lineNum = 1;
    let machineCodeLineNum = 0;

    // Switched from secondInterface.on("line", doStuff(line))

    // The above line works. It seems that initializing both streams at the same time is causing issues. Awaiting the first stream causes the second stream to be invalid?
    // I have no idea what's going on lol

    // ▼▼ PROBLEM THAT EXISTS WHEN I DON'T REINITIALIZE THE STREAM IN THE .on("close", ...) FUNCTION ▼▼
    // What's really weird is if I check the readable stream associated with the finalAssemblyRLInterface it says that it has not closed

    // Ex:
    // this.finalAssemblyReadStream.readable
    // > true

    // Doesn't this imply that there is content that can be read in the stream? If so, why isn't the interface's onLine event handler not being called?
    
    this.finalAssemblyRLInterface.on("line", (line) => {
      const trimmedLine = this.removeTrailingComments(line).trim();
      const [commandType, commandString] = this.caseLine(trimmedLine);
      let machineCode;
      switch (commandType) {
        case "COMMENT":
          console.log(
            `Line Num: ${lineNum}\nCommand Type: ${commandType}\n\nSkipping Code Comment on Line ${lineNum}\n\nLine Contents:\n${commandString}\n\n--------------------------------`
          );
          break;
        case "EMPTY":
          console.log(
            `Line Num: ${lineNum}\nCommand Type: ${commandType}\n\nSkipping Empty Line\n\n--------------------------------`
          );
          break;
        case "A_COMMAND":
          // This debugger DOES triggered. Why?
          if(commandString == "@memory.peek") debugger
          machineCode = `0${this.translateACommand(commandString)}`;

          console.log(
            `LineNum: ${lineNum}\nCommand Type: ${commandType}\n\nLine Contents:\n${commandString}\nTranslated to 16 bit Binary:\n${machineCode}\n\n-------------------------------`
          );
          this.writeStream.write(`${machineCode}\n`);
          machineCodeLineNum++;
          break;
        case "C_COMMAND":
          // Example instruction code:
          // ixxaccccccdddjjj

          const CommandTokens = this.tokenizeCCommand(commandString);

          let compMachineCode = this.codeTable.comp(CommandTokens.comp);
          let destMachineCode = this.codeTable.dest(CommandTokens.dest);
          let jumpMachineCode = this.codeTable.jump(CommandTokens.jump);

          machineCode = `111${compMachineCode}${destMachineCode}${jumpMachineCode}`;
          console.log(
            `LineNum: ${lineNum}\nCommand Type: ${commandType}\n\nLine Contents:\n${commandString}\nTranslated to 16 bit Binary:\n${machineCode}\n\n-------------------------------`
          );
          this.writeStream.write(`${machineCode}\n`);
          machineCodeLineNum++;
          break;
        case "L_COMMAND":
          console.log(
            `LineNum: ${lineNum}\nCommand Type: ${commandType}\n\nLine Contents:\n${commandString}\nIGNORED ON SECOND PASS\nSymbolTable Key: ${this.removeParenthesis(commandString)}\nSymbolTable Value: ${this.symbolTable.getAddress(this.removeParenthesis(commandString))}\n-------------------------------`
          );
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

    if (line.match(/^\([A-Za-z_.$:][A-Za-z0-9_.$:]*\)$/))
      return ["L_COMMAND", this.removeAllWhiteSpace(line)];

    return ["C_COMMAND", this.removeAllWhiteSpace(line)];
  }

  removeParenthesis(string) {
    return string.replace(/[\(\)]/g, "");
  }

  translateACommand(commandString) {
    commandString = commandString.replace("@", "");
    let binaryVal;
    let address
    if (this.aCommandIsConstant(commandString)) {
      binaryVal = this.#twosCompliment(parseInt(commandString), 15);
    } else if (this.aCommandIsSymbol(commandString)) {
      if (this.symbolTable.contains(commandString)) {
        address = this.symbolTable.getAddress(commandString);
        binaryVal = this.#twosCompliment(address, 15)
      } else {
        address = this.symbolTable.addVariable(commandString);
        binaryVal = this.#twosCompliment(address, 15)
      }
    } else {
      throw Error(
        `Error: Invalid A_COMMAND provided\nProvided Command: ${commandString}\n\n-------------------------------`
      );
    }
    return binaryVal;
  }

  aCommandIsConstant(string) {
    // Checks the provided string consists of only digits
    return !!string.match(/^\d+$/);
  }

  aCommandIsSymbol(string) {
    // Checks if the provided string only contains acceptable characters
    //
    // A user-defined symbol can be any sequence of letters, digits, underscore (_),
    // dot (.), dollar sign ($), and colon (:) that does not begin with a digit

    return !!string.match(/^[A-Za-z_.$:][A-Za-z0-9_.$:]*$/);
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

    this.symbolProcessingReadStream = symbolProcessingReadStream
    this.finalAssemblyReadStream = finalAssemblyReadStream

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
