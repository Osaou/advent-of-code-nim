import std/[strformat, strutils, sequtils, sugar, tables, sets, math]
import fusion/matching
import utils
import matrix



func solve*(input: string): int =
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

  # break 'em down (fold paper according to first instruction)
  let (dir, fold) = folds[0]
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

  # clamp values to 1 and simply sum them to get how many dots there are left
  paper
    .clamp(1)
    .data
    .sum()



tests:
  solve(readFile("test.txt")) == 17
  solve(readFile("input.txt")) == 704
