import std/[strformat, strutils, sequtils, sugar, tables, hashes, sets, options, math, algorithm, heapqueue]
import fusion/matching
import utils
import matrix



type
  Position = tuple
    x,y: int
  ProgressState = tuple
    pos: Position
    dir: Position
    straight: int
  Node = ref object
    state: ProgressState
    cost: int
    prev: Node

proc `<`(a, b: Node): bool =
  a.cost < b.cost

proc solve*(input: string): int
proc dijkstra(grid: Matrix[int]): seq[Position]
proc countStraightSteps(currentNode: Node, dir: Position): int {.inline.}

proc renderPath(grid: Matrix[int], path: seq[Position])
proc renderStepFrom(a,b: Position): char

tests:
  solve(readFile("test.txt")) == 102
  solve(readFile("test2.txt")) == 171
  solve(readFile("test3.txt")) == 7
  solve(readFile("test4.txt")) == 29
  solve(readFile("input.txt")) == 1256



proc solve(input: string): int =
  let grid = input
    .splitLines()
    .mapIt(it.toSeq.map(charToInt))
    .matrix

  let path = dijkstra(grid)
  renderPath(grid, path)

  path.foldl(a + grid[b.y, b.x], 0)

proc dijkstra(grid: Matrix[int]): seq[Position] =
  let
    start = (0,0).Position
    startNode = Node(state:(pos:start, dir:(0,0).Position, straight:0).ProgressState, cost:0, prev:nil)
    goal = (grid.lastCol, grid.lastRow).Position

  var
    queue = [startNode].toHeapQueue
    visited = initHashSet[ProgressState]()
    recordNode: Node = nil

  while queue.len > 0:
    let
      node = queue.pop()
      nodePos = node.state.pos

    if nodePos == goal:
      recordNode = node
      break

    let
      (cx, cy) = nodePos
      (px, py) = if node.prev == nil: (0,0)
                 else: node.prev.state.pos

    for nei, dir in [(1, 0), (0, 1), (-1, 0), (0, -1)]:
      let
        (dx, dy) = dir
        nx = cx + dx
        ny = cy + dy

      if nx == px and ny == py:
        continue

      if nx < 0 or
         ny < 0 or
         nx > grid.lastCol or
         ny > grid.lastRow:
        continue

      let straight = countStraightSteps(node, dir)
      if straight > 3:
        continue

      let
        state = (pos:(nx, ny).Position, dir:dir, straight:straight).ProgressState
        totalCost = node.cost + grid[ny, nx]
        next = Node(state:state, cost:totalCost, prev:node)

      if visited.containsOrIncl(state):
        continue

      queue.push(next)

  if recordNode == nil:
    return @[]

  var
    path = newSeq[Position]()
    n = recordNode
  while n.state.pos != start:
    path.add(n.state.pos)
    n = n.prev

  path.reversed()

proc countStraightSteps(currentNode: Node, dir: Position): int =
  var
    node = currentNode
    steps = 1

  for i in 1..3:
    if node.prev == nil:
      break
    if node.state.dir != dir:
      break

    node = node.prev
    steps += 1

  steps

proc renderPath(grid: Matrix[int], path: seq[Position]) =
  echo grid

  var blocks = matrix[char](grid.rows, grid.cols)
  for y in 0 ..< grid.rows:
    for x in 0 ..< grid.cols:
      blocks[y, x] = grid[y, x].intToChar

  var previous = (0,0).Position
  for step in path:
    blocks[step.y, step.x] = renderStepFrom(previous, step)
    previous = step

  echo blocks

proc renderStepFrom(a,b: Position): char =
  if b.x > a.x:
    return '>'
  elif b.x < a.x:
    return '<'
  elif b.y > a.y:
    return 'v'
  else:
    return '^'
