import std/[strformat, strutils, sequtils, sugar]
import math
import utils



func solve*(input: string): int =
  let crabPositions = input
    .split(",")
    .map(parseInt)

  toSeq(min(crabPositions) .. max(crabPositions))
    .map(shift => crabPositions
      .dup()
      .foldl(a + abs(b - shift), 0)
    )
    .min()



tests:
  solve(readFile("test.txt")) == 37
  solve(readFile("input.txt")) == 344_735
