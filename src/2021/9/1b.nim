# imports
import std/sequtils
import std/sugar
import math
import data



# tests
const
  expectedTestResult* = 15
  expectedRunResult* = 522



# logic
func logic*(input: string): int =
  let
    map = newHeightmap(input)
    lowPoints = collect(newSeq):
      for y in 0 .. map.ymax:
        for x in 0 .. map.xmax:
          let
            height = map.heightValue(x, y)
            neighbors = map.neighborCoords(x, y)
          if neighbors.mapIt(map.heightValueFromSeq(it)).all(neighbor => neighbor > height):
            # return risk level
            height + 1

  lowPoints.sum()
