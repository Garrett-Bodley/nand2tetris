const fs = require("node:fs")
const readline = require("node:readline")
const path = require("node:path")

debugger

function vmTranslator(){
  if(process.argv.length === 2) throw Error("Please specify the filepath of the VM code you wish to translate.")
  if(process.argv.length > 3) throw Error(`Too many arguments provided (${process.argv.length - 2}). Please specify the filepath of the VM code you wish to translate.`)

  const [inPath, outPath] = parsePath(process.argv[2])
  debugger

  function parsePath(relPath){
    const pathObj = path.parse(path.join(__dirname, relPath))
    if(pathObj.ext !== ".vm") throw Error(`Invalid filetype provided! Provided file has a ${pathObj.ext} extension. Translator requires .vm filetype.`)
    debugger
    const inPath = path.join(pathObj.dir, pathObj.base)
    // this is not correct
    const outPath = path.join(pathObj.dir, pathObj.name, '.hack')
    return [inPath, outPath]
  }
}

vmTranslator()


class VMTranslator{
  constructor(inPath, outPath){
    this.inPath = inPath
    this.outPath = outPath
    this.RLInterface = this.#createRLInterface(inPath, outPath)
  }

  async processLines(){
    for await (const line of this.RLInterface){
      
    }
  }

  #createRLInterface(inPath, outPath){
    const readStream = fs.createReadStream(inPath)
    readStream.on("error", e => {throw Error(e.message)})
    const writeStream = fs.createWriteStream(outPath)
    writeStream.on("error", e => {throw Error(e.message)})

    return readline.createInterface({input: readStream, output: writeStream})
  }
}
