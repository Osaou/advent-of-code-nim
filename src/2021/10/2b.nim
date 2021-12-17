import std/[strformat, strutils, sequtils, sugar, algorithm, math]
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
    0
  elif line.len > 0:
    # incomplete line
    toSeq(line.reversed().items)
      .foldl(5 * a + (
        case b:
          of '(': 1
          of '[': 2
          of '{': 3
          of '<': 4
          else: 0
      ), 0)
  else:
    # balanced
    0



func solve*(input: string): int64 =
  let incompleteErrorScores = input
    .splitLines()
    .map(parseNavigationLine)
    .filterIt(it > 0)
    .sorted()

  incompleteErrorScores[ floorDiv(incompleteErrorScores.len, 2) ]



tests:
  solve(readFile("test.txt")) == 288_957'i64
  solve(readFile("input.txt")) == 3_122_628_974'i64
