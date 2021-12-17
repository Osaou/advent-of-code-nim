import std/[strformat, strutils, sequtils, sugar, tables, sets, math]
import fusion/matching
import utils
import data



func solve*(input: string): int =
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



tests:
  solve(readFile("test.txt")) == 15
  solve(readFile("input.txt")) == 522
