import std/[strformat, strutils, sequtils, sugar, tables, sets, options, math, algorithm]
import fusion/matching
import utils
import matrix



proc solve*(input: string): int
proc simulateSupportBeamLoadAfterLongTime*(reflectorDish: Matrix): int
proc computeSupportBeamLoad*(reflectorDish: Matrix): int
proc spinCycle*(reflectorDish: Matrix): Matrix
proc predictSupportBeamLoad*(measurements: seq[int], spinCountPrediction: int): int
proc findLastSequenceLength*(measurements: seq[int]): int
proc findLastSequence(measurements: seq[int]): tuple[len:int, start:int]

tests:
  solve(readFile("test.txt")) == 64
  solve(readFile("input.txt")) == 98894



proc solve(input: string): int =
  input
    .splitLines
    .mapIt(it.toSeq)
    .matrix
    .simulateSupportBeamLoadAfterLongTime

proc simulateSupportBeamLoadAfterLongTime(reflectorDish: Matrix): int =
  let measurementCount = 1_000
  var
    measurements = newSeq[int](measurementCount)
    tilted = reflectorDish

  for i in 0 ..< measurementCount:
    tilted = spinCycle(tilted)
    measurements[i] = computeSupportBeamLoad(tilted)

  predictSupportBeamLoad(measurements, 1_000_000_000)

#[ tests:
  spinCycle("""O....X....
O.OOX....X
.....XX...
OO.XO....O
.O.....OX.
O.X..O.X.X
..O..XO..O
.......O..
X....XXX..
XOO..X....""".splitLines.mapIt(it.toSeq).matrix) == """.....X....
....X...OX
...OOXX...
.OOX......
.....OOOX.
.OX...OX.X
....OX....
......OOOO
X...OXXX..
X..OOX....""".splitLines.mapIt(it.toSeq).matrix
]#
proc spinCycle*(reflectorDish: Matrix): Matrix =
  var tilted = reflectorDish

  # north
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

  # west
  for y in 0 ..< tilted.rows:
    for x in 0 ..< tilted.cols:
      if tilted[y,x] == 'O':
        var x2 = x - 1
        while x2 >= 0 and tilted[y,x2] == '.':
          x2 -= 1

        # we always move 1 step too far; so move back
        x2 += 1
        if x != x2:
          tilted[y, x] = '.'
          tilted[y,x2] = 'O'

  # south
  for y in countdown(tilted.lastRow, 0):
    for x in countdown(tilted.lastCol, 0):
      if tilted[y,x] == 'O':
        var y2 = y + 1
        while y2 < tilted.rows and tilted[y2,x] == '.':
          y2 += 1

        # we always move 1 step too far; so move back
        y2 -= 1
        if y != y2:
          tilted[y, x] = '.'
          tilted[y2,x] = 'O'

  # east
  for y in countdown(tilted.lastRow, 0):
    for x in countdown(tilted.lastCol, 0):
      if tilted[y,x] == 'O':
        var x2 = x + 1
        while x2 < tilted.cols and tilted[y,x2] == '.':
          x2 += 1

        # we always move 1 step too far; so move back
        x2 -= 1
        if x != x2:
          tilted[y, x] = '.'
          tilted[y,x2] = 'O'

  tilted

#[ tests:
  computeSupportBeamLoad("""OOOO.X.O..
OO..X....X
OO..OXX..O
O..X.OO...
........X.
..X....X.X
..O..X.O.O
..O.......
X....XXX..
X....X....""".splitLines.mapIt(it.toSeq).matrix) == 136
]#
proc computeSupportBeamLoad(reflectorDish: Matrix): int =
  var totalBeamLoad = 0

  for y in 0 ..< reflectorDish.rows:
    for x in 0 ..< reflectorDish.cols:
      if reflectorDish[y,x] == 'O':
        totalBeamLoad += reflectorDish.rows - y

  totalBeamLoad

proc predictSupportBeamLoad(measurements: seq[int], spinCountPrediction: int): int =
  let
    (len, start) = findLastSequence(measurements)
    spinIndex = start + (((spinCountPrediction - start) - 1) mod len)
    estimatedValue = measurements[spinIndex]

  estimatedValue

proc findLastSequence(measurements: seq[int]): tuple[len:int, start:int] =
  let len = measurements
    .reversed()
    .findLastSequenceLength()

  for i in 0 .. measurements.len:
    let
      a = measurements[i + 0   ..< i + len]
      b = measurements[i + len ..< i + len * 2]

    doAssert a.len == len
    doAssert a.len == b.len

    if a == b:
      return (len, i)

  return (1, 0)

#[ tests:
  findLastSequenceLength(@[14,42,0,3,1,14,42,0,3,1,14,42,0,3,1]) == 5
  findLastSequenceLength(@[1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8,9,0,45,4,78,2]) == 10
  findLastSequenceLength(@[1,2,3,4,5,6,7,8,9]) == 1
]#
proc findLastSequenceLength(measurements: seq[int]): int =
  # we can probably have some unlucky sub-sequences, so assume we are looking for a repetition factor of at least 5 or greater
  for x in 5 ..< measurements.len div 2:
    if measurements[0 ..< x] == measurements[x ..< 2*x]:
      return x

  return 1
