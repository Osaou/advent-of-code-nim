import std/[strformat, strutils, sequtils, sugar, tables, sets, options, math, algorithm]
import fusion/matching
import utils
import elvis
import matrix



proc solve*(input: string): int
proc findMirrorPoint*(pattern: string): int
proc findInflectionPoint*(drawing: Matrix, inflectionPoint: int): int
proc matchWithSmudge*(a, b: seq[char]): bool

tests:
  solve(readFile("test.txt")) == 400
  solve(readFile("input.txt")) == 41566



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
o.o.oo.o.""") == 300
  findMirrorPoint("""o...oo..o
o....o..o
..oo..ooo
ooooo.oo.
ooooo.oo.
..oo..ooo
o....o..o""") == 100
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

  if currentRow == previousRow or matchWithSmudge(currentRow, previousRow):
    var
      alen = drawing.data[0 ..< currentOffset].len
      blen = drawing.data[currentOffset .. ^1].len
      mirrorLength = min(alen, blen)
    let
      flippedInflectionPoint = drawing.rows - inflectionPoint
      flippedOffset =  flippedInflectionPoint * width
      top =    drawing.flipV.data[flippedOffset ..< flippedOffset + mirrorLength]
      bottom = drawing.      data[currentOffset ..< currentOffset + mirrorLength]

    if matchWithSmudge(top, bottom):
      return inflectionPoint

  0

#[ tests:
  matchWithSmudge("o..oo..ooo...oooo".toSeq, "o..oo..ooo...oooo".toSeq) == false
  matchWithSmudge("o..oo..ooo...oooo".toSeq, "...oo..ooo...oooo".toSeq) == true
  matchWithSmudge("o..oo..ooo...oooo".toSeq, "oo.oo..ooo...oooo".toSeq) == true
  matchWithSmudge("o..oo..ooo...oooo".toSeq, "o..oo..ooo....ooo".toSeq) == true
  matchWithSmudge("o..oo..ooo...oooo".toSeq, "o..oo..ooo...ooo.".toSeq) == true
  matchWithSmudge("o..oo..ooo...oooo".toSeq, "ooooo..ooo...oooo".toSeq) == false
  matchWithSmudge("o..oo..ooo...oooo".toSeq, "ooooo..ooo...ooo.".toSeq) == false
]#
proc matchWithSmudge*(a, b: seq[char]): bool =
  if a.len != b.len:
    return false

  let diff = collect:
    for i in 0..<a.len:
      let
        x = a[i]
        y = b[i]
      if x != y:
        i

  diff.len == 1
