import std/[strformat, strutils, sequtils, sugar, algorithm]
import fusion/matching
import math
import utils
import data



type
  BasinMarker = object
    map: Heightmap
    markedCoords: seq[bool]
    basins: seq[int]

func newBasinMarker(map: Heightmap): BasinMarker =
  BasinMarker(
    map: map,
    markedCoords: newSeqWith(map.xlen * map.ylen, false)
  )

func isMarked(marked: BasinMarker, x,y: int): bool =
  marked.markedCoords[y * marked.map.xlen + x]

proc markBasin(marked: var BasinMarker, x,y: int): int =
  # check if we're out of bounds
  if marked.isMarked(x, y) or marked.map.heightValue(x, y) == 9:
    return 0

  # mark this position
  marked.markedCoords[y * marked.map.xlen + x] = true

  # iterate over all neighbors, and mark them too, if appropriate
  # return sum of marked neighbors, plus 1 for current coordinate
  marked.map
    .neighborCoords(x, y)
    .mapIt(marked.markBasin(it[0], it[1]))
    .sum() + 1

func addBasin(marked: var BasinMarker, size: int) =
  marked.basins &= size



func solve*(input: string): int =
  let
    map = newHeightmap(input)
  var
    marked = newBasinMarker(map)

  for y in 0 .. map.ymax:
    for x in 0 .. map.xmax:
      let basinSize = marked.markBasin(x, y)
      if basinSize > 0:
        marked.addBasin(basinSize)

  # multiply 3 largest basins
  [@first, @second, @third, all _] := marked.basins.sorted().reversed()
  first * second * third



tests:
  solve(readFile("test.txt")) == 1_134
  solve(readFile("input.txt")) == 916_688
