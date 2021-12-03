import std/os
import std/parseopt
import std/times
import std/strutils
import std/strformat
import std/sugar
import elvis



let
  now = now()
  month = now.month
var
  year: int
  day: int
  part = 1

# if it's advent of code right now use the current year and day
if month == Month.mDec and now.monthday <= 25:
  year = now.year
  day = now.monthday

var
  flagClear = false
  flagPrintConfig = false
  flagFetchInput = false
  flagSendAnswer = false
  flagInitDay = false
  flagTest = false
  flagTestAll = false
  flagRun = false
  flagGui = false
  flagGuiTestFile = false
  flagPerfTest = false
  opts = initOptParser()
while true:
  opts.next()
  case opts.kind
    of cmdEnd: break
    of cmdShortOption, cmdLongOption:
      case opts.key
        of "y", "year": year = parseInt(opts.val)
        of "d", "day": day = parseInt(opts.val)
        of "p", "part":
          case opts.val
          of "1": part = 1
          of "2": part = 2
          else: quit 1
        else: quit 1
    of cmdArgument:
      case opts.key
        of "clear": flagClear = true
        of "c", "printconf": flagPrintConfig = true
        of "f", "fetch": flagFetchInput = true
        of "s", "send": flagSendAnswer = true
        of "i", "initday": flagInitDay = true
        of "t", "test": flagTest = true
        of "test:all": flagTestAll = true
        of "test:gui":
          flagGui = true
          flagGuiTestFile = true
        of "r", "run": flagRun = true
        of "run:gui":
          flagGui = true
          flagGuiTestFile = false
        of "gui": flagGui = true
        of "perf": flagPerfTest = true
        else: quit 1



proc printConfig() =
  echo "Working against year ", year, ", month ", month, ", day ", day, ", part ", part

let baseCompileOpts = "--warning:UnusedImport:off --verbosity:0"

proc compileWithRunner(runnerFile: string, opts: string, runCommand: (binaryPath: string) -> void) =
  for variant in walkFiles(fmt"./src/{year}/{day}/{part}*.nim"):
    let
      (_, fileName, _) = splitFile(variant)
      outFile = fmt"./build/{year}/{day}/{fileName}"

    # prepare source files
    createDir(fmt"./tmp")
    copyFile("./src/utils.nim", "./tmp/utils.nim")
    copyFile("./src/tools-noop.nim", "./tmp/tools.nim")
    copyFile(fmt"./src/{runnerFile}", "./tmp/runner.nim")
    copyFile(variant, "./tmp/logic.nim")

    # compile
    if execShellCmd(fmt"nim compile {baseCompileOpts} {opts} --out:{outFile} ./tmp/runner.nim") != 0:
      quit 1

    # run
    runCommand(outFile)

proc compileWithRunner(runnerFile: string, runCommand: (binaryPath: string) -> void) =
  compileWithRunner(runnerFile, "", runCommand)

proc compileForWeb(dataFile: string, runCommand: (binaryPath: string) -> void) =
  for variant in walkFiles(fmt"./src/{year}/{day}/{part}*.nim"):
    let
      (_, fileName, _) = splitFile(variant)
      outFile = fmt"./build/{year}/{day}/{fileName}"
      outHtml = fmt"{outFile}.html"

    # prepare source files
    createDir(fmt"./tmp")
    copyFile("./src/utils.nim", "./tmp/utils.nim")
    copyFile("./src/tools-web.nim", "./tmp/tools.nim")
    copyFile("./src/web-template.nim", "./tmp/runner.nim")
    copyFile(variant, "./tmp/logic.nim")

    # prepare runner file with input data
    let
      dataInput = readFile(dataFile)
      runnerContent = readFile("./src/web-template.html")
        .replace("{RUN_SCRIPT}", fmt"{fileName}.js")
        .replace("{DATA_INPUT}", dataInput)
    writeFile(outHtml, runnerContent)

    # compile, targetting javascript
    if execShellCmd(fmt"nim js {baseCompileOpts} --out:{outFile}.js ./tmp/runner.nim") != 0:
      quit 1

    # run
    runCommand(outHtml)



if flagClear:
  removeDir("./build")
  removeDir("./tmp")

if flagPrintConfig:
  printConfig()

if flagFetchInput:
  echo "Not implemented"

if flagSendAnswer:
  echo "Not implemented"

if flagInitDay:
  printConfig()
  createDir(fmt"./src/{year}/{day}")
  copyFile("./src/part-template.nim", fmt"./src/{year}/{day}/1.nim")
  copyFile("./src/part-template.nim", fmt"./src/{year}/{day}/2.nim")
  writeFile(fmt"./src/{year}/{day}/test.txt", "")

if flagTest:
  compileWithRunner("test-template.nim", " --verbosity:1", proc (binary: string) =
    discard execShellCmd(fmt"{binary} test ./src/{year}/{day}/test.txt")
  )

if flagTestAll:
  compileWithRunner("test-template.nim", proc (binary: string) =
    discard execShellCmd(fmt"{binary} test ./src/{year}/{day}/test.txt")
    discard execShellCmd(fmt"{binary} input ./src/{year}/{day}/input.txt")
  )

if flagRun:
  compileWithRunner("runner-template.nim", proc (binary: string) =
    discard execShellCmd(fmt"{binary} ./src/{year}/{day}/input.txt")
  )

if flagGui:
  let dataFile = flagGuiTestFile ? "test.txt" ! "input.txt"
  compileForWeb(fmt"./src/{year}/{day}/{dataFile}", proc (binary: string) =
    discard execShellCmd(fmt"wslview {binary}")
  )

  #compileWithRunner("gl-template.nim", proc (binary: string) =
  #  discard execShellCmd(fmt"{binary} ./src/{year}/{day}/test.txt")
  #)

if flagPerfTest:
  compileWithRunner("runner-template.nim", "-d:danger", proc (binary: string) =
    discard execShellCmd(fmt"hyperfine --warmup 50 '{binary} ./src/{year}/{day}/input.txt'")
  )
