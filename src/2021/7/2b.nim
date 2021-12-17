import std/[strformat, strutils, sequtils, sugar]
import math
import utils



func solve*(input: string): int =
  let crabPositions = input
    .split(",")
    .map(parseInt)

  toSeq(min(crabPositions) .. max(crabPositions))
    .map(shift => crabPositions
      .mapIt(it - shift)
      .mapIt(abs it)
      .mapIt(it * (it + 1) / 2 |> int)
      .sum()
    )
    .min()



tests:
  solve(readFile("test.txt")) == 168
  solve(readFile("input.txt")) == 96_798_233
