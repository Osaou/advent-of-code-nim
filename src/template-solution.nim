# imports
import std/[strformat, strutils, sequtils, sugar, tables, sets, math]
import fusion/matching
import utils

{.experimental: "caseStmtMacros".}



# tests
const
  expectedTestResult* = 0
  expectedRunResult* = 0



# main
proc logic*(input: string): int64 =
