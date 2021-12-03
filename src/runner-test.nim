import std/os
import std/strformat
import elvis
import logic

let
  dataSet = paramStr(1)
  expectedResult = dataSet == "test" ? expectedTestResult ! expectedRunResult
  dataPath = paramStr(2)
  input = readFile(dataPath)
  testResult = logic(input)

echo "Test result: ", testResult

assert testResult == expectedResult
