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



# logic
func logic*(input: string): int =
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
