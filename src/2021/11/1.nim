# imports
import std/[strformat, strutils, sequtils, sugar]
import data



# tests
const
  expectedTestResult* = 1656
  expectedRunResult* = 1591



proc modelEnergyOverTime(group: var OctopusGroup, steps: int): int64 =
  for step in 1..steps:
    group.modelSingleStep()

  group.flashCount



# daily logic
proc logic*(input: string): int64 =
  var group = newOctopusGroup(input)
  group.modelEnergyOverTime(100)
