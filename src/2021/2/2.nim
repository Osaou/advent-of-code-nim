import std/[strformat, strutils, sequtils, sugar, json]
import tools
import utils



proc solve*(input: string): int =
  let trajectory = input
    .splitLines
    .filterIt(it.strip() != "")
    .map(str => str.split(" "))
    .map(arr => (dir: arr[0], speed: parseInt(arr[1])))
  var
    aim = 0
    depth = 0
    position = 0

  for move in trajectory:
    case move.dir
      of "up":
        aim -= move.speed
      of "down":
        aim += move.speed
      of "forward":
        position += move.speed
        depth += aim * move.speed

    #echo fmt"Position: {position}, Depth: {depth}, Aim: {aim}"

  position * depth



tests:
  solve(readFile("test.txt")) == 900
  solve(readFile("input.txt")) == 1_954_293_920
