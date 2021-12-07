# imports
import std/strformat
import std/strutils
import std/sequtils
import std/sugar
import math
import utils



# tests
const
  expectedTestResult* = 37
  expectedRunResult* = 344_735



# logic
func logic*(input: string): int =
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
