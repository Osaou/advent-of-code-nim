# imports
import std/strformat
import std/strutils
import std/sequtils
import std/sugar
import math
import utils



# tests
const
  expectedTestResult* = 168
  expectedRunResult* = 96_798_233



func sumFuel(constantCost: int): int =
  constantCost * (constantCost + 1) / 2 |> int

# logic
func logic*(input: string): int =
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
