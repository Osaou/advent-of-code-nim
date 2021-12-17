import std/[strformat, strutils, sequtils, sugar]
import math
import utils



func sumFuel(constantCost: int): int =
  constantCost * (constantCost + 1) / 2 |> int

func solve*(input: string): int =
  let crabPositions = input
    .split(",")
    .map(parseInt)

  var candidates: seq[int]

  for shift in min(crabPositions) .. max(crabPositions):
    var shiftSum: seq[int]
    for crab in crabPositions:
      abs(crab - shift) |> sumFuel() |> shiftSum.add()

    shiftSum.sum() |> candidates.add()

  candidates.min()



tests:
  solve(readFile("test.txt")) == 168
  solve(readFile("input.txt")) == 96_798_233
