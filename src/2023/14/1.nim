import std/[strformat, strutils, sequtils, sugar, tables, sets, options, math, algorithm]
import fusion/matching
import utils
import matrix



proc solve*(input: string): int
proc computeSupportBeamLoad*(reflectorDish: Matrix): int
proc tilt*(reflectorDish: Matrix): Matrix

tests:
  solve(readFile("test.txt")) == 136
  solve(readFile("input.txt")) == 112773



proc solve(input: string): int =
  input
    .splitLines
    .mapIt(it.toSeq)
    .matrix
    .computeSupportBeamLoad

proc computeSupportBeamLoad(reflectorDish: Matrix): int =
  let tilted = reflectorDish.tilt()
  var totalBeamLoad = 0

  for y in 0 ..< tilted.rows:
    for x in 0 ..< tilted.cols:
      if tilted[y,x] == 'O':
        totalBeamLoad += tilted.rows - y

  totalBeamLoad

#[ tests:
  tilt("""O....X....
O.OOX....X
.....XX...
OO.XO....O
.O.....OX.
O.X..O.X.X
..O..XO..O
.......O..
X....XXX..
XOO..X....""".splitLines.mapIt(it.toSeq).matrix) == """OOOO.X.O..
OO..X....X
OO..OXX..O
O..X.OO...
........X.
..X....X.X
..O..X.O.O
..O.......
X....XXX..
X....X....""".splitLines.mapIt(it.toSeq).matrix
]#
proc tilt(reflectorDish: Matrix): Matrix =
  var tilted = reflectorDish

  for y in 0 ..< tilted.rows:
    for x in 0 ..< tilted.cols:
      if tilted[y,x] == 'O':
        var y2 = y - 1
        while y2 >= 0 and tilted[y2,x] == '.':
          y2 -= 1

        # we always move 1 step too far; so move back
        y2 += 1
        if y != y2:
          tilted[y, x] = '.'
          tilted[y2,x] = 'O'

  tilted
