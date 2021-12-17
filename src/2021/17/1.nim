# imports
import std/[strformat, strutils, sequtils, sugar, tables, sets, math]
import fusion/matching
import utils
import data
{.experimental: "caseStmtMacros".}



# tests
const
  expectedTestResult* = 45
  expectedRunResult* = 2775



# main
proc logic*(input: string): int64 =
  [@targetX, @targetY] := parseTargetArea(input)
  var maxY = 0

  for testVX in 1 .. targetX.hi:
    for testVY in targetY.lo .. targetY.lo.abs():
      var
        localMaxY = 0
        p = Point(x:0, y:0, vx:testVX, vy:testVY)

      # step until either out of bounds or in target area
      while p.x <= targetX.hi and
            p.y >= targetY.lo and
            not p.inTargetArea(targetX, targetY):
        p.step()

        if p.y > localMaxY:
          localMaxY = p.y

      # check if we ended up in target area and have a new arc height record
      if p.inTargetArea(targetX, targetY) and localMaxY > maxY:
        maxY = localMaxY

  maxY
