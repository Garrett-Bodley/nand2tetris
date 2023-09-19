#! /usr/bin/env node
const PATH = "add/Add.asm";

const fs = require("node:fs");
const path = require("node:path");
const readline = require("node:readline");
const dict = {};

function Assemble(relativePath) {
  debugger;
  const rl = setupIO(relativePath);
  debugger;
  rl.on("line", (input) => {
    debugger;
    parseInstruction(input);
  });

  function setupIO(relativePath) {
    const [inPath, outPath] = pathParse(relativePath);

    const rs = fs.createReadStream(inPath, { encoding: "utf-8" });
    rs.on("error", (e) => console.log(`Error: ${e.message}`));

    const ws = fs.createWriteStream(outPath);
    ws.on("error", (e) => console.log(`Error: ${e.message}`));

    const rl = readline.createInterface({
      input: rs,
      output: ws,
    });

    return rl;
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

  const parseInstruction = (line) => {
    debugger;
    if (line.match(/(^\/\/)/)) {
      console.log(line);
      console.log("Skipping code comment");
      return;
    }
    if(line.length == 0){
      return console.log("Skipping empty line!")
    }
    if (line.match(/@/)) {
      aInstruction(line);
    } else {
      cInstruction(line);
    }
  };

  function aInstruction(line){
    console.log(`The following is an A instruction:\n${line}\n-------------------------------------`)
  }

  function cInstruction(line){
    console.log(`The following is a C instruction:\n${line}\n-------------------------------------`)
  }
}

try {
  debugger;
  // const inputPath = path.join(__dirname, PATH)
  // read(inputPath)
  Assemble("add/Add.asm");
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
