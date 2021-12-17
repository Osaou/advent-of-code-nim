import std/[strformat, strutils, sequtils, math]
import utils



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



func solve*(input: string): int64 =
  input
    .splitLines()
    .map(parseNavigationLine)
    .sum()



tests:
  solve(readFile("test.txt")) == 26_397
  solve(readFile("input.txt")) == 411_471
