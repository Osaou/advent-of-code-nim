import std/[strformat, strutils, sequtils, sugar, tables, sets, math]
import fusion/matching
import utils
import data



func solve*(input: string): int64 =
  [@targetX, @targetY] := parseTargetArea(input)
  var successCount = 0

  for testVX in 1 .. targetX.hi:
    for testVY in targetY.lo .. targetY.lo.abs():
      var p = Point(x:0, y:0, vx:testVX, vy:testVY)

      # step until either out of bounds or in target area
      while p.x <= targetX.hi and
            p.y >= targetY.lo and
            not p.inTargetArea(targetX, targetY):
        p.step()

      # check if we ended up in target area
      if p.inTargetArea(targetX, targetY):
        successCount += 1

  successCount



tests:
  solve(readFile("test.txt")) == 112
  solve(readFile("input.txt")) == 1566
