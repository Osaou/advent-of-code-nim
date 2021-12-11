# imports
import std/[strformat, strutils, sequtils, sugar, math]



# tests
const
  expectedTestResult* = 26_397
  expectedRunResult* = 411_471



func parseNavigationLine(input: string): int64 =
  var line = input
  while line.len > 0:
    if line[0] in "([{<":
      let replaced = line
        .replace("()", "")
        .replace("[]", "")
        .replace("{}", "")
        .replace("<>", "")

      if replaced.len != line.len:
        line = replaced
      else:
        break
    else:
      break

  let closer = line.find({')', ']', '}', '>'})
  if closer >= 0:
    # corrupted line
    case line[closer]:
      of ')': 3
      of ']': 57
      of '}': 1197
      of '>': 25137
      else: 0
  elif line.len > 0:
    # incomplete line
    0
  else:
    # balanced
    0

# logic
proc logic*(input: string): int64 =
  input
    .splitLines()
    .map(parseNavigationLine)
    .sum()
