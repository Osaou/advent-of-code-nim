import std/os
import std/strformat
import elvis
import utils
import solution

let
  input = readFile(paramStr(1))
  inputFile = (paramStr(1) |> splitFile())[1]
  isMainInputFile = inputFile == "input"

echo solve(input), not isMainInputFile ? fmt" ({inputFile}.txt)" ! ""
