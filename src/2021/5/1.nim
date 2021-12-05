# imports
import std/strformat
import std/strutils
import std/sequtils
import std/sugar
import utils



# tests
const
  expectedTestResult* = 5
  expectedRunResult* = 5167



const FIELD_SIZE = 1000

type
  Point = tuple
    x: int
    y: int
  Line = object
    x1, y1: int
    x2, y2: int

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
  for y in y1 .. y2:
    for x in x1 .. x2:
      yield (x:x, y:y)

func parseLine(input: string): Line



# logic
proc logic*(input: string): int =
  let lines = input
    .splitLines
    .map(parseLine)
    .filterIt(it.x1 == it.x2 or it.y1 == it.y2)

  var field = newSeqWith(FIELD_SIZE, newSeq[int](FIELD_SIZE))

  for line in lines:
    #echo "processing line: ", line
    #for y in line.y1 .. line.y2:
    #  for x in line.x1 .. line.x2:
    #    echo fmt"  marking coordinate: {x},{y}"
    #    field[y][x] += 1
    for x, y in line:
      #echo fmt"  marking coordinate: {x},{y}"
      field[y][x] += 1

  var intersections = 0
  for y in 0 ..< FIELD_SIZE:
    #echo field[y]
    for x in 0 ..< FIELD_SIZE:
      if field[y][x] > 1:
        intersections += 1

  intersections



func parseLine(input: string): Line =
  let
    points: seq[string] = input.split(" -> ")
    p1 = points[0].split(',')
    p2 = points[1].split(',')
  Line(
    x1: p1[0] |> parseInt,
    y1: p1[1] |> parseInt,
    x2: p2[0] |> parseInt,
    y2: p2[1] |> parseInt
  )
