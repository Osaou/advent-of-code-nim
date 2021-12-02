# imports
import std/strformat
import std/strutils
import std/sequtils
import std/sugar



# tests
const
  expectedTestResult* = 150
  expectedRunResult* = 1670340



# logic
proc logic*(input: string): int =
  let trajectory = input
    .splitLines
    .filterIt(it.strip() != "")
    .map(str => str.split(" "))
    .map(arr => (dir: arr[0], speed: parseInt(arr[1])))
  var
    depth = 0
    position = 0

  #echo trajectory

  for move in trajectory:
    case move.dir
      of "up":
        depth -= move.speed
      of "down":
        depth += move.speed
      of "forward":
        position += move.speed

  #echo fmt"Position: {position}, Depth: {depth}"

  position * depth
