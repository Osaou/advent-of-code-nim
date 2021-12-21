import std/os
import std/strformat
import std/times
import elvis
import utils
import solution

let
  input = readFile(paramStr(1))
  inputFile = (paramStr(1) |> splitFile())[1]
  isMainInputFile = inputFile == "input"
  t0 = cpuTime()

echo solve(input), not isMainInputFile ? fmt" ({inputFile}.txt)" ! ""

let
  t1 = cpuTime()
  total = t1 - t0
if total > 1.0:
  echo "Took ", total, " seconds to run."
