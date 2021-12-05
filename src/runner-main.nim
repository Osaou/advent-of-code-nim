import std/os
import std/strformat
import elvis
import utils
import logic

let
  input = readFile(paramStr(1))
  inputFile = (paramStr(1) |> splitFile())[1]
  isMainInputFile = inputFile == "input"

echo logic(input), not isMainInputFile ? fmt" ({inputFile}.txt)" ! ""
