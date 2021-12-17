import std/[strformat, strutils, sequtils, sugar, algorithm, math]
import utils
import parsing



func solve*(input: string): int64 =
  let incompleteErrorScores = input
    .splitLines()
    .map(parseNavigationLine)
    .filterIt(not it.isCorrupted)
    .filterIt(it.isIncomplete)
    .mapIt(it.errorScore)
    .sorted()

  incompleteErrorScores[ floorDiv(incompleteErrorScores.len, 2) ]



tests:
  solve(readFile("test.txt")) == 288_957'i64
  solve(readFile("input.txt")) == 3_122_628_974'i64
