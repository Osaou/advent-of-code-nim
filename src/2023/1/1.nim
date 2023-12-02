import std/[strformat, strutils, sequtils, sugar, tables, sets, options, math, re]
import fusion/matching
import utils



proc parseNrs(line: string): int =
  let
    allNumbers = line
      .strip()
      .replace(re"\D")
      .mapIt(int(it) - int('0'))
    first = allNumbers[0]
    last = allNumbers[^1]
  first * 10 + last

proc solve*(input: string): int =
  input
    .split("\n")
    .filterIt(it.strip() != "")
    .map(parseNrs)
    .foldl(a + b, 0)


tests:
  parseNrs("pqr3s7tu8vwx") == 38
  solve(readFile("test.txt")) == 142
  solve(readFile("input.txt")) == 54644
