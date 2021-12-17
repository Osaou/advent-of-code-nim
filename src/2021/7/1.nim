import std/[strformat, strutils, sequtils, sugar]
import math
import utils



func solve*(input: string): int =
  let crabPositions = input
    .split(",")
    .map(parseInt)

  var candidates: seq[int]

  for shift in min(crabPositions) .. max(crabPositions):
    var shiftSum: seq[int]
    for crab in crabPositions:
      abs(crab - shift) |> shiftSum.add()

    shiftSum.sum() |> candidates.add()

  candidates.min()



tests:
  solve(readFile("test.txt")) == 37
  solve(readFile("input.txt")) == 344_735
