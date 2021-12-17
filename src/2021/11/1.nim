import std/[strformat, strutils, sequtils, sugar]
import utils
import data



func modelEnergyOverTime(group: var OctopusGroup, steps: int): int64 =
  for step in 1..steps:
    group.modelSingleStep()

  group.flashCount



func solve*(input: string): int64 =
  var group = newOctopusGroup(input)
  group.modelEnergyOverTime(100)



tests:
  solve(readFile("test.txt")) == 1656
  solve(readFile("input.txt")) == 1591
