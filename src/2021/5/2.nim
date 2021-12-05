# imports
import std/strformat
import std/strutils
import std/sequtils
import std/sugar
import data



# tests
const
  expectedTestResult* = 12
  expectedRunResult* = 17604



iterator pairs(line: Line): Point =
  var
    x = line.x1
    y = line.y1
  let
    xmax = line.x2
    ymax = line.y2

    dx = if x < xmax:
           1
         elif x > xmax:
           -1
         else:
           0
    dy = if y < ymax:
           1
         elif y > ymax:
           -1
         else:
           0

  yield (x:x, y:y)
  while x != xmax or y != ymax:
    x += dx
    y += dy
    yield (x:x, y:y)



# logic
proc logic*(input: string): int =
  let (lines, cols, rows) = parseData(input)
  var seabed              = newSeqWith(rows+1, newSeq[int](cols+1))

  for line in lines:
    for x, y in line:
      seabed[y][x] += 1

  var intersections = 0
  for y in 0 .. rows:
    for x in 0 .. cols:
      if seabed[y][x] > 1:
        intersections += 1

  intersections
