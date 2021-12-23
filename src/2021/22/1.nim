import std/[strformat, strutils, sequtils, sugar, tables, sets, options, math]
import fusion/matching
import utils
import reactor



proc solve*(input: string): int64 =
  let steps = parseInput(input)
    .filterIt([it.x1,it.x2, it.y1,it.y2, it.z1,it.z2].allIt(it.abs() <= 50))

  var activeCoreMass = newSeq[Cuboid]()
  for cuboid in steps:
    activeCoreMass = adjustCores(activeCoreMass, cuboid)

  activeCoreMass.count()



tests:
  parseInput("on x=10..12,y=20..22,z=30..32") == @[
    Cuboid(on: true,
      x1: 10, x2: 12,
      y1: 20, y2: 22,
      z1: 30, z2: 32,
    )
  ]

  solve(readFile("test.txt")) == 590_784
  solve(readFile("input.txt")) == 658_691
