import std/os
import std/strformat
import logic

let
  dataPath = paramStr(1)
  test = readFile(fmt"{dataPath}/test.txt")
  input = readFile(fmt"{dataPath}/input.txt")
  testResult = logic(test)
  inputResult = logic(input)

echo "Test result: ", testResult
echo "Final result: ", inputResult

assert testResult == expectedTestResult
assert inputResult == expectedRunResult
