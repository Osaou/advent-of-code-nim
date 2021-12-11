# imports
import std/strformat
import std/strutils
import std/sequtils
import std/sugar
import utils
import fusion/matching
import math

{.experimental: "caseStmtMacros".}



# tests
const
  expectedTestResult* = 15
  expectedRunResult* = 522



func charToInt(c: char): int =
  c.int - 48

# logic
func logic*(input: string): int =
  let
    values = input
      .splitLines()
      .mapIt(toSeq it)
      .mapIt(it.map(charToInt))
    xlen = values[0].len
    ylen = values.len
    xmax = xlen - 1
    ymax = ylen - 1

    heightmap = collect(newSeq):
      for row in values:
        for height in row:
          height

    heightValue = proc(x,y: int): int =
      heightmap[y*xlen + x]

    heightValueFromSeq = proc(pos: seq[int]): int =
      heightValue(pos[0], pos[1])

    neighborCoords = proc(x,y: int): seq[seq[int]] =
      case @[x, y]:
        of [0, 0]:        @[@[0, 1], @[1, 0]]                             # top-left
        of [0, ymax]:     @[@[0, y-1], @[x+1, 0]]                         # bottom-left
        of [xmax, 0]:     @[@[x-1, 0], @[0, y+1]]                         # top-right
        of [0, _]:        @[@[0, y-1], @[0, y+1], @[x+1, y]]              # left edge
        of [_, 0]:        @[@[x-1, 0], @[x+1, 0], @[x, y+1]]              # top edge
        of [xmax, ymax]:  @[@[x, y-1], @[x-1, y]]                         # bottom-right
        of [xmax, _]:     @[@[xmax, y-1], @[xmax, y+1], @[x-1, y]]        # right edge
        of [_, ymax]:     @[@[x-1, ymax], @[x+1, ymax], @[x, y-1]]        # bottom edge
        else:             @[@[x-1, y], @[x+1, y], @[x, y-1], @[x, y+1]]   # anywhere else

  let lowPoints = collect(newSeq):
    for y in 0 .. ymax:
      for x in 0 .. xmax:
        let
          height = heightValue(x, y)
          neighbors = neighborCoords(x, y)
        if neighbors.map(heightValueFromSeq).all(neighbor => neighbor > height):
          # return risk level
          height + 1

  lowPoints.sum()
