import std/[strformat, strutils, sequtils, sugar, tables, sets, math]
import fusion/matching
import utils
import pathfinding
from astar import path



func extend(grid: Grid, mul: int): Grid =
  let
    origHeight = grid.len
    origWidth = grid[0].len

  result = newSeqWith(origHeight * mul, newSeq[int](origWidth * mul))

  for y in 0 ..< origHeight:
    for x in 0 ..< origWidth:
      for ym in 0 ..< mul:
        for xm in 0 ..< mul:
          var risk = grid[y][x] + xm + ym
          while risk > 9:
            risk -= 9
          result[y + ym*origHeight][x + xm*origWidth] = risk



proc solve*(input: string): int64 =
  let
    caves: Grid = parseGrid[int](input).extend(5)
    start: Point = (x: 0, y: 0)
    goal: Point = (x: caves.len-1, y: caves[0].len-1)

  # since A* returns iterator of nodes to visit, we need to visit them all and sum their cost
  path[Grid, Point, Distance](caves, start, goal)
    .toSeq()
    .mapIt(caves[it.y][it.x])
    .sum() - caves[start.y][start.x]



tests:
  solve(readFile("test.txt")) == 315
  solve(readFile("input.txt")) == 3063
