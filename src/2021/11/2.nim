import std/[strformat, strutils, sequtils, sugar, math]
import utils
import data



proc findSimultaneousFlashEvent(group: var OctopusGroup): int64 =
  var step = 0'i64
  while true:
    step += 1

    group.modelSingleStep()

    # did all octopi flash simultaneously?
    if group.octopi.sum() == 0:
      break

  step



func solve*(input: string): int64 =
  var group = newOctopusGroup(input)
  group.findSimultaneousFlashEvent()



tests:
  solve(readFile("test.txt")) == 195
  solve(readFile("input.txt")) == 314
