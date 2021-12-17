import std/os
import std/parseopt
import std/times
import std/strutils
import std/strformat
import std/sugar
import std/options
import elvis
import fusion/matching

{.experimental: "caseStmtMacros".}



let
  now = now()
  month = now.month
var
  year: int
  day: int
  part = 1
  inputFile = none(string)

# if it's advent of code right now use the current year and day
if month == Month.mDec and now.monthday <= 25:
  year = now.year
  day = now.monthday

var
  flagClean = false
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
        of "f", "inputfile": inputFile = some(opts.val)
        else: quit 1
    of cmdArgument:
      case opts.key
        of "clean": flagClean = true
        of "printconf": flagPrintConfig = true
        of "fetch": flagFetchInput = true
        of "send": flagSendAnswer = true
        of "initday": flagInitDay = true
        of "test": flagTest = true
        of "test:all": flagTestAll = true
        of "run": flagRun = true
        of "perf": flagPerfTest = true
        of "gui":
          flagGui = true
          flagGuiTestFile = false
        else: quit 1



proc printConfig() =
  echo "Working against year ", year, ", month ", month, ", day ", day, ", part ", part

let baseCompileOpts = "--warning:UnusedImport:off --verbosity:0 -d:nimNoLentIterators --experimental:caseStmtMacros"

proc compileWithRunner(runnerFile: string, opts: string, runCommand: (binaryPath: string) -> void) =
  let
    srcDir = fmt"./src"
    solutionDir = fmt"{srcDir}/{year}/{day}"
    buildDir = fmt"./build/{year}/{day}"
    tempDir = "./tmp"
  createDir(buildDir)
  createDir(tempDir)

  # start by copying all nim files from selected day's folder
  for variant in walkFiles(fmt"{solutionDir}/*.nim"):
    let (_, fileName, _) = splitFile(variant)
    copyFile(variant, fmt"{tempDir}/{fileName}.nim")

  # copy all input files to build dir
  for inputFile in walkFiles(fmt"{solutionDir}/*.txt"):
    let (_, fileName, _) = splitFile(inputFile)
    copyFile(inputFile, fmt"{buildDir}/{fileName}.txt")

  # now iterate over all solutions for selected part and compile + run
  for variant in walkFiles(fmt"{solutionDir}/{part}*.nim"):
    let
      (_, fileName, _) = splitFile(variant)
      buildFile = buildDir / fileName

    # prepare source files
    copyFile(fmt"{srcDir}/utils.nim", fmt"{tempDir}/utils.nim")
    copyFile(fmt"{srcDir}/tools-noop.nim", fmt"{tempDir}/tools.nim")
    copyFile(fmt"{srcDir}/cputicks.nim", fmt"{tempDir}/cputicks.nim")
    copyFile(fmt"{srcDir}/{runnerFile}", fmt"{tempDir}/runner.nim")
    copyFile(variant, fmt"{tempDir}/solution.nim")

    # compile
    if execShellCmd(fmt"nim compile {baseCompileOpts} {opts} --out:{buildFile} {tempDir}/runner.nim") != 0:
      quit 1

    # run
    runCommand(buildFile)

proc compileWithRunner(runnerFile: string, runCommand: (binaryPath: string) -> void) =
  compileWithRunner(runnerFile, "", runCommand)

proc compileForWeb(dataFile: string, runCommand: (binaryPath: string) -> void) =
  let
    solutionDir = fmt"./src/{year}/{day}"
    buildDir = fmt"./build/{year}/{day}"
    tempDir = "./tmp"
  createDir(buildDir)
  createDir(tempDir)

  # start by copying all nim files from selected day's folder
  for srcFile in walkFiles(fmt"{solutionDir}/*.nim"):
    let (_, fileName, _) = splitFile(srcFile)
    copyFile(srcFile, fmt"{tempDir}/{fileName}.nim")

  # copy all input files to build dir
  for inputFile in walkFiles(fmt"{solutionDir}/*.txt"):
    let (_, fileName, _) = splitFile(inputFile)
    copyFile(inputFile, fmt"{buildDir}/{fileName}.txt")

  # now iterate over all solutions for selected part and compile + run
  for variant in walkFiles(fmt"{solutionDir}/gui_{part}*.nim"):
    let
      (_, fileName, _) = splitFile(variant)
      buildFile = buildDir / fileName
      buildHtml = fmt"{buildFile}.html"

    # prepare source files
    copyFile("./src/utils.nim", fmt"{tempDir}/utils.nim")
    copyFile("./src/tools-web.nim", fmt"{tempDir}/tools.nim")
    copyFile("./src/template-web.nim", fmt"{tempDir}/runner.nim")
    copyFile(variant, fmt"{tempDir}/solution.nim")

    # prepare runner file with input data
    let
      dataInput = readFile(dataFile)
      runnerContent = readFile("./src/template-web.html")
        .replace("{RUN_SCRIPT}", fmt"{fileName}.js")
        .replace("{DATA_INPUT}", dataInput)
    writeFile(buildHtml, runnerContent)

    # compile, targetting javascript
    if execShellCmd(fmt"nim js {baseCompileOpts} --out:{buildFile}.js {tempDir}/runner.nim") != 0:
      quit 1

    # run
    runCommand(buildHtml)



if flagClean:
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
  copyFile("./src/template-solution.nim", fmt"./src/{year}/{day}/1.nim")
  copyFile("./src/template-solution.nim", fmt"./src/{year}/{day}/2.nim")
  writeFile(fmt"./src/{year}/{day}/test.txt", "")
  writeFile(fmt"./src/{year}/{day}/input.txt", "")

if flagTest:
  compileWithRunner("runner-test.nim", " --verbosity:1", proc (binary: string) =
    let (dir, bin, _) = splitFile(binary)
    discard execShellCmd(fmt"cd {dir} && ./{bin}")
  )

if flagTestAll:
  compileWithRunner("runner-test.nim", proc (binary: string) =
    discard execShellCmd(fmt"{binary} test ./src/{year}/{day}/test.txt")
    discard execShellCmd(fmt"{binary} input ./src/{year}/{day}/input.txt")
  )

if flagRun:
  compileWithRunner("runner-main.nim", "-d:danger", proc (binary: string) =
    for input in walkFiles(fmt"./src/{year}/{day}/input*.txt"):
      discard execShellCmd(fmt"{binary} {input}")
  )

if flagGui:
  let dataFile = flagGuiTestFile ? "test.txt" ! "input.txt"
  compileForWeb(fmt"./src/{year}/{day}/{dataFile}", proc (binary: string) =
    discard execShellCmd(fmt"wslview {binary}")
  )

  #compileWithRunner("runner-opengl.nim", proc (binary: string) =
  #  discard execShellCmd(fmt"{binary} ./src/{year}/{day}/{dataFile}")
  #)

if flagPerfTest:
  # TODO: perhaps rewrite performance testing so that loading input data from disk is not part of the test
  #compileWithRunner("runner-main.nim", "-d:danger", proc (binary: string) =
  #  discard execShellCmd(fmt"hyperfine --warmup 50 '{binary} ./src/{year}/{day}/input.txt'")
  #)
  compileWithRunner("runner-perf.nim", "-d:danger", proc (binary: string) =
    discard execShellCmd(fmt"{binary} ./src/{year}/{day}/input.txt")
  )
