import std/[strformat, strutils, sequtils, sugar, tables, sets, options, math, algorithm]
import fusion/matching
import utils
import matrix



type Star = tuple
  x,y: int

proc solve*(input: string): int
proc distanceBetweenStars*(a, b: Star, rowsValue, colsValue: seq[int]): int

tests:
  solve(readFile("test.txt")) == 374
  solve(readFile("input.txt")) == 9599070



proc solve(input: string): int =
  let galaxy = input
    .split("\n")
    .mapIt(it.toSeq)
    .matrix
  var
    stars = newSeq[Star]()
    rowsValue = newSeqWith(galaxy.rows, 2)
    colsValue = newSeqWith(galaxy.cols, 2)

  for y in 0..galaxy.lastRow:
    for x in 0..galaxy.lastCol:
      if galaxy[y, x] == '#':
        stars.add((x:x, y:y))
        colsValue[x] = 1
        rowsValue[y] = 1

  var sum = 0
  for i, a in stars:
    for b in stars[(i+1)..^1]:
      sum += distanceBetweenStars(a, b, rowsValue, colsValue)

  sum

proc distanceBetweenStars(a, b: Star, rowsValue, colsValue: seq[int]): int =
  var distance = 0

  let
    ly = if a.y > b.y: b.y else: a.y
    hy = if a.y > b.y: a.y else: b.y
  for y in ly..<hy:
    distance += rowsValue[y]

  let
    lx = if a.x > b.x: b.x else: a.x
    hx = if a.x > b.x: a.x else: b.x
  for x in lx..<hx:
    distance += colsValue[x]

  distance
