import std/[strformat, strutils, sequtils, math]
import utils
import parsing



func solve*(input: string): int64 =
  input
    .splitLines()
    .map(parseNavigationLine)
    .filterIt(not it.isIncomplete)
    .filterIt(it.isCorrupted)
    .mapIt(it.errorScore)
    .sum()



tests:
  solve(readFile("test.txt")) == 26_397
  solve(readFile("input.txt")) == 411_471
