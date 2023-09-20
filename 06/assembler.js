#! /usr/bin/env node
const PATH = "add/Add.asm";

const fs = require("node:fs");
const path = require("node:path");
const readline = require("node:readline");

const ALUDict = {
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

const destDict = {
  M: "001",
  D: "010",
  MD: "011",
  A: "100",
  AM: "101",
  AD: "110",
  AMD: "111",
};

const jumpDict = {
  JGT: "001",
  JEQ: "010",
  JGE: "011",
  JLT: "100",
  JNE: "101",
  JLE: "110",
  JMP: "111"
};

const dict = { ALUDict, destDict, jumpDict };

function Assemble(relativePath) {
  const {rl, ws} = setupIO(relativePath);
  let lineNum = 1;
  rl.on("line", (input) => {
    let newLine = parseInstruction(input, lineNum);
    debugger
    if(newLine.length !== 0){
      debugger
      ws.write(`${lineNum > 1 ? '\n' : '\r'}${newLine}`)
    }
    lineNum++;
  });

  function setupIO(relativePath) {
    const [inPath, outPath] = pathParse(relativePath);

    const rs = fs.createReadStream(inPath, { encoding: "utf-8" });
    rs.on("error", (e) => console.log(`Error: ${e.message}`));

    const ws = fs.createWriteStream(outPath);
    ws.on("error", (e) => console.log(`Error: ${e.message}`));

    const rl = readline.createInterface({
      input: rs,
    });

    return {rl, ws};
  }

  function pathParse(relativePath) {
    if (path.extname(relativePath) !== ".asm")
      throw Error("Invalid file type!");
    const inPath = path.join(__dirname, relativePath);
    const parseObj = path.parse(inPath);
    const outPath = `${parseObj.dir}/${path.basename(
      parseObj.base,
      parseObj.ext
    )}.hack`;
    return [inPath, outPath];
  }

  const parseInstruction = (line, lineNum) => {
    if (line.match(/(^\/\/)/)) {
      console.log(line);
      console.log("Skipping code comment");
      return '';
    }
    if (line.length == 0) {
      console.log("Skipping empty line!");
      return ''
    }
    if (line.match(/@/)) {
      return aInstruction(line, lineNum);
    } else {
      return cInstruction(line, lineNum);
    }
  };

  function aInstruction(line, lineNum) {
    const val = Number(line.replace(/@/, ""));
    const binaryInstruction = "0" + twosCompliment(val, 15);
    console.log(
      `A instruction:\n${line}\nTranslated to 16 bit Binary: \n${binaryInstruction}\n-------------------------------`
    );
    return binaryInstruction
  }

  function cInstruction(line, lineNum) {
    // Example instruction code:
    // ixxaccccccdddjjj
    // syntax: Destination = Computation
    //
    // if line.includes(';')
    //   Jump instructions
    //   ALU outputs D Register
    //   Hash Jump instructions
    // else if line.includes('=')
    //   Computation

    // Split on "="
    // Program destination component = Computation/ALU instructions
    debugger;
    let compBinary;
    let destBinary = "000";
    let jumpBinary = "000";
    if (line.match(/=/)) {
      const [destination, computation] = line.split("=");

      if (!dict.destDict[destination] || !dict.ALUDict[computation])
        throwInvalidInput(lineNum);

      destBinary = dict.destDict[destination];
      compBinary = dict.ALUDict[computation];
    } else if (line.match(/;/)) {
      debugger
      const [computation, jump] = line.split(";");

      if (!dict.ALUDict[computation] || !dict.jumpDict[jump])
        throwInvalidInput(lineNum);

      compBinary = dict.ALUDict[computation];
      jumpBinary = dict.jumpDict[jump];
    } else {
      throwInvalidInput(lineNum);
    }
    let binaryInstruction = `111${compBinary}${destBinary}${jumpBinary}`;
    console.log(
      `C instruction:\n${line}\nTranslated to 16 bit Binary: \n${binaryInstruction}\n-------------------------------`
    );
    return binaryInstruction
  }

  function throwInvalidInput(lineNum){
    throw Error(`Invalid instruction ${lineNum !== null ? `on line ${lineNum}` : ''}`);
  }

  function twosCompliment(value, bitCount) {
    // Borrowed from Brandon Sará's gist. Thank you Brandon!
    // https://gist.github.com/bsara/519df5f91833d01c20ec

    let binaryStr;
    if (value >= 0) {
      let twosComp = value.toString(2);
      binaryStr = padAndChop(twosComp, "0", bitCount || twosComp.length);
    } else {
      binaryStr = (Math.pow(2, bitCount) + value).toString(2);
    }

    if (Number(binaryStr) < 0) return undefined;

    return binaryStr;
  }

  function padAndChop(str, padChar, length) {
    return (Array(length).fill(padChar).join("") + str).slice(length * -1);
  }
}

try {
  debugger;
  // const inputPath = path.join(__dirname, PATH)
  // read(inputPath)
  Assemble(PATH);
} catch (e) {
  console.log(e);
}

function read(filePath) {
  const rs = fs.createReadStream(filePath);
  debugger;
  rs.on("error", (e) => console.log(`Error: ${e.message}`));
  rs.on("data", (chunk) => {
    debugger;
    console.log(chunk);
  });
}
