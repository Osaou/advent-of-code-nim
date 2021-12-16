# imports
import std/[strformat, strutils, sequtils, sugar, tables, sets, math]
import fusion/matching
import utils
import pathfinding
from astar import path



# tests
const
  expectedTestResult* = 40
  expectedRunResult* = 824



# main
proc logic*(input: string): int64 =
  let
    caves: Grid = parseGrid[int](input)
    start: Point = (x: 0, y: 0)
    goal: Point = (x: caves.len-1, y: caves[0].len-1)

  # since A* returns iterator of nodes to visit, we need to visit them all and sum their cost
  path[Grid, Point, Distance](caves, start, goal)
    .toSeq()
    .mapIt(caves[it.y][it.x])
    .sum() - caves[start.y][start.x]
