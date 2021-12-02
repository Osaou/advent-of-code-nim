# imports
import std/strformat
import std/strutils
import std/sequtils
import std/sugar
import elvis



# tests
const
  expectedTestResult* = 5
  expectedRunResult* = 1734



# 199  A
# 200  A B
# 208  A B C
# 210    B C D
# 200  E   C D
# 207  E F   D
# 240  E F G
# 269    F G H
# 260      G H
# 263        H

proc assignMatrixValue(matrix: var seq[seq[int]], i: int, value: int) =
  if i-2 >= 0:
    matrix[i-2][i] = value
  if i-1 >= 0:
    matrix[i-1][i] = value
  matrix[i][i] = value

# logic
proc logic*(input: string): int =
  var measurements: seq[int] = input
    .split("\n")
    .filterIt(it.strip() != "")
    .map(parseInt)

  let count = measurements.len

  var matrix = newSeqWith(count, newSeq[int](count))
  for i, value in measurements:
    assignMatrixValue(matrix, i, value)
  #echo matrix

  var windows: seq[int]
  for i in 0 ..< count - 2:
    let window =
      matrix[i][i+0] +
      matrix[i][i+1] +
      matrix[i][i+2]
    windows.add(window)
  #echo windows

  return windows
    .foldl(b > a.prev ? (b, a.increases + 1) ! (b, a.increases), (prev: high(int), increases: 0))
    .increases
