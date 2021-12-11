# imports
import std/strformat
import std/strutils
import std/sequtils
import std/sugar
import math



# tests
const
  expectedTestResult* = 26
  expectedRunResult* = 532



# logic
func logic*(input: string): int =
  input
    .splitLines()
    .mapIt(it.split(" | ")[1])
    .mapIt(it
      .split(" ")
      .filterIt(it.len == 2 or  #1
                it.len == 3 or  #7
                it.len == 4 or  #4
                it.len == 7)    #8
      .len()
    )
    .sum()
