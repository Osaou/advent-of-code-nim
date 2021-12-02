# imports
import std/strformat
import std/strutils
import std/sequtils
import std/sugar
import elvis



# tests
const
  expectedTestResult* = 7
  expectedRunResult* = 1713



# logic
proc logic*(input: string): int =
  input
    .split("\n")
    .filterIt(it.strip() != "")
    .map(parseInt)
    .foldl(b > a.prev ? (b, a.increases + 1) ! (b, a.increases), (prev: high(int), increases: 0))
    .increases
