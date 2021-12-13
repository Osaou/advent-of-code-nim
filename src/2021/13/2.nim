# imports
import std/[strformat, strutils, sequtils, sugar, tables, sets, math]
import fusion/matching
import utils
import matrix

{.experimental: "caseStmtMacros".}



# tests
const
  expectedTestResult* = 0
  expectedRunResult* = 0



# main
proc logic*(input: string): int =
  # start by splitting up the dots and folds info
  [@dotsInstructions, @foldsInstructions] := input
    .split("\n\n")

  let
    # parse dots to sequence of (x:int, y:int) tuples
    dots = dotsInstructions
      .splitLines()
      .mapIt(it.split(","))
      .mapIt((x: it[0].parseInt, y: it[1].parseInt))

    # find size of paper
    rows = dots
      .mapIt(it.y)
      .max() + 1
    columns = dots
      .mapIt(it.x)
      .max() + 1

    # parse folds to sequence of (dir:"x/y", fold:int) tuples
    folds = foldsInstructions
      .splitLines()
      .mapIt(it.replace("fold along ", ""))
      .mapIt(it.split("="))
      .mapIt((dir: it[0], fold: it[1].parseInt))

  # build 'em up (create matrix representation of dots on paper)
  var paper = matrix[int](rows, columns)
  for (x,y) in dots:
    paper[y, x] = 1

  # break 'em down (fold paper according to instructions)
  for (dir, fold) in folds:
    case dir
      of "x":
        let
          (left, right) = paper.splitH(fold)
          rightFlipped = right.flipH()
        paper = left.add(rightFlipped)

      of "y":
        let
          (top, bottom) = paper.splitV(fold)
          bottomFlipped = bottom.flipV()
        paper = top.add(bottomFlipped)

  echo "folded: ", paper

  #let
  #  letterCount = 8
  #  letterHeight = folded.N
  #  letterWidth = int(folded.M / letterCount)
  #echo "letterWidth: ", letterWidth

  #var letters: seq[Matrix[int]]
  #for letterIndex in 0 ..< letterCount:
  #  var letter = matrix[int](letterHeight, letterWidth)
  #  for i in 0 ..< letterHeight:
  #    for j in 0 ..< letterWidth:
  #      letter[i,j] = folded[i, j + letterIndex*letterWidth]
  #  letters.add(letter)
  #echo "letters: ", letters

  0
