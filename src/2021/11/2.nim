# imports
import std/[strformat, strutils, sequtils, sugar, math]
import data



# tests
const
  expectedTestResult* = 195
  expectedRunResult* = 314



proc findSimultaneousFlashEvent(group: var OctopusGroup): int64 =
  var step = 0'i64
  while true:
    step += 1

    group.modelSingleStep()

    # did all octopi flash simultaneously?
    if group.octopi.sum() == 0:
      break

  step



# daily logic
proc logic*(input: string): int64 =
  var group = newOctopusGroup(input)
  group.findSimultaneousFlashEvent()
