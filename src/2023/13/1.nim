import std/[strformat, strutils, sequtils, sugar, tables, sets, options, math, algorithm]
import fusion/matching
import utils
import matrix



proc solve*(input: string): int
proc findMirrorPoint*(pattern: string): int
proc findInflectionPoint*(drawing: Matrix, inflectionPoint: int): int

tests:
  solve(readFile("test.txt")) == 405
  solve(readFile("input.txt")) == 27202



proc solve(input: string): int =
  input
    .split("\n\n")
    .map(findMirrorPoint)
    .sum

#[ tests:
  findMirrorPoint("""o.oo..oo.
..o.oo.o.
oo......o
oo......o
..o.oo.o.
..oo..oo.
o.o.oo.o.""") == 5
  findMirrorPoint("""o...oo..o
o....o..o
..oo..ooo
ooooo.oo.
ooooo.oo.
..oo..ooo
o....o..o""") == 400
]#
proc findMirrorPoint*(pattern: string): int =
  let drawing = pattern
    .split("\n")
    .mapIt(it.toSeq)
    .matrix

  for y in 1..<drawing.rows:
    let mirrorValue = findInflectionPoint(drawing, y)
    if mirrorValue > 0:
      return mirrorValue * 100

  let transpose = drawing.transpose
  for x in 1..<transpose.rows:
    let mirrorValue = findInflectionPoint(transpose, x)
    if mirrorValue > 0:
      return mirrorValue

  0

proc findInflectionPoint(drawing: Matrix, inflectionPoint: int): int =
  ##[
    attempts to find an inflection point along the horisontal axis
    e.g:
      .....##
      ###..##
      -------
      ###..##
      .....##
      ......#
  ]##
  let
    width = drawing.cols
    previousOffset = (inflectionPoint - 1) * width
    currentOffset =  (inflectionPoint + 0) * width
    previousRow = drawing.data[previousOffset ..< previousOffset + width]
    currentRow =  drawing.data[currentOffset  ..< currentOffset  + width]

  if currentRow == previousRow:
    var
      alen = drawing.data[0 ..< currentOffset].len
      blen = drawing.data[currentOffset .. ^1].len
      mirrorLength = min(alen, blen)
    let
      flippedInflectionPoint = drawing.rows - inflectionPoint
      flippedOffset =  flippedInflectionPoint * width
      top =    drawing.flipV.data[flippedOffset ..< flippedOffset + mirrorLength]
      bottom = drawing.      data[currentOffset ..< currentOffset + mirrorLength]

    if top == bottom:
      return inflectionPoint

  0
