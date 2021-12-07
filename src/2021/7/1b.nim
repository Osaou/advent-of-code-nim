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

  toSeq(min(crabPositions) .. max(crabPositions))
    .map(shift => crabPositions
      .dup()
      .foldl(a + abs(b - shift), 0)
    )
    .min()
