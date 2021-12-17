import std/[strformat, strutils, sequtils, sugar, tables, sets, math]
import fusion/matching
import utils
import data



iterator pairs(line: Line): Point =
  var
    x1 = line.x1
    y1 = line.y1
    x2 = line.x2
    y2 = line.y2

  if x1 > x2:
    x1 = line.x2
    x2 = line.x1
  if y1 > y2:
    y1 = line.y2
    y2 = line.y1

  # NOTE: this is buggy, and will yield rectangles, but since we are only working with horizontal and vertical lines, I never notice...
  for y in y1 .. y2:
    for x in x1 .. x2:
      yield (x:x, y:y)



proc solve*(input: string): int =
  let
    (lines, cols, rows) = parseData(input)
    filteredLines       = lines.filterIt(it.x1 == it.x2 or it.y1 == it.y2)
  var seabed            = newSeqWith(rows+1, newSeq[int](cols+1))

  for line in filteredLines:
    for x, y in line:
      seabed[y][x] += 1

  var intersections = 0
  for y in 0 .. rows:
    for x in 0 .. cols:
      if seabed[y][x] > 1:
        intersections += 1

  intersections



tests:
  solve(readFile("test.txt")) == 5
  solve(readFile("input.txt")) == 5167
