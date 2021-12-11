# imports
import std/[strformat, strutils, sequtils, sugar, algorithm, math]
import parsing



# tests
const
  expectedTestResult* = 288_957'i64
  expectedRunResult* = 3_122_628_974'i64



# logic
proc logic*(input: string): int64 =
  let incompleteErrorScores = input
    .splitLines()
    .map(parseNavigationLine)
    .filterIt(not it.isCorrupted)
    .filterIt(it.isIncomplete)
    .mapIt(it.errorScore)
    .sorted()

  incompleteErrorScores[ floorDiv(incompleteErrorScores.len, 2) ]
