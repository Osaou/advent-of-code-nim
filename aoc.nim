import std/os
import std/parseopt
import std/times
import std/strutils
import std/strformat



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
  flagPrintConfig = false
  flagFetchInput = false
  flagSendAnswer = false
  flagInitDay = false
  flagTest = false
  flagRun = false
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
        of "c", "printconf": flagPrintConfig = true
        of "f", "fetch": flagFetchInput = true
        of "s", "send": flagSendAnswer = true
        of "i", "initday": flagInitDay = true
        of "t", "test": flagTest = true
        of "r", "run": flagRun = true
        of "perf": flagPerfTest = true
        else: quit 1

proc printConfig() =
  echo "Working against year ", year, ", month ", month, ", day ", day, ", part ", part

proc compileWithRunner(runnerFile: string, opts: string = "") =
  # prepare source files
  createDir(fmt"./tmp")
  copyFile(fmt"./src/{runnerFile}", "./tmp/runner.nim")
  copyFile(fmt"./src/{year}/{day}/{part}.nim", "./tmp/logic.nim")

  # compile
  discard execShellCmd(fmt"nim compile --warning:UnusedImport:off --verbosity:0 {opts} --out:./build/{year}/{day}/{part} ./tmp/runner.nim")



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
  compileWithRunner("test-template.nim")
  discard execShellCmd(fmt"./build/{year}/{day}/{part} ./src/{year}/{day}")

if flagRun:
  compileWithRunner("runner-template.nim")
  discard execShellCmd(fmt"./build/{year}/{day}/{part} ./src/{year}/{day}/input.txt")

if flagPerfTest:
  compileWithRunner("runner-template.nim", "-d:danger")
  discard execShellCmd(fmt"hyperfine --warmup 3 './build/{year}/{day}/{part} ./src/{year}/{day}/input.txt'")
