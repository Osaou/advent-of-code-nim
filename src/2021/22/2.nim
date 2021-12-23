import std/[strformat, strutils, sequtils, sugar, tables, sets, options, math]
import fusion/matching
import utils
import reactor



proc solve*(input: string): int64 =
  let steps = parseInput(input)

  var activeCoreMass = newSeq[Cuboid]()
  for cuboid in steps:
    activeCoreMass = adjustCores(activeCoreMass, cuboid)

  activeCoreMass.count()



tests:
  solve(readFile("test2.txt")) == 2_758_514_936_282_235
  solve(readFile("input.txt")) == 1_228_699_515_783_640
