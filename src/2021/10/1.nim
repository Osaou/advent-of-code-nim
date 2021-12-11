# imports
import std/[strformat, strutils, sequtils, sugar, math]
import parsing



# tests
const
  expectedTestResult* = 26_397
  expectedRunResult* = 411_471



# logic
proc logic*(input: string): int64 =
  input
    .splitLines()
    .map(parseNavigationLine)
    .filterIt(not it.isIncomplete)
    .filterIt(it.isCorrupted)
    .mapIt(it.errorScore)
    .sum()
