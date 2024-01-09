import std/[strformat, strutils, sequtils, sugar, tables, hashes, sets, options, math, algorithm, heapqueue]
import fusion/matching
import utils
import matrix



type
  Position = tuple
    x,y: int
  Direction = enum
    Unknown
    Up
    Right
    Down
    Left
  ProgressState = tuple
    pos: Position
    dir: Direction
    straight: int
  Node = ref object
    state: ProgressState
    cost: int
    prev: Node

proc `<`(a, b: Node): bool =
  a.cost < b.cost

proc solve*(input: string): int
proc dijkstra(grid: Matrix[int]): int
proc nextPossibleMoves(grid: Matrix[int], node: Node): seq[Node] {.inline.}
proc opposite(dir: Direction): Direction {.inline.}
proc position(dir: Direction): Position {.inline.}
proc renderPath(grid: Matrix[int], path: seq[Position])

tests:
  solve(readFile("test.txt")) == 94
  solve(readFile("test5.txt")) == 71
  solve(readFile("input.txt")) == 1382



proc solve(input: string): int =
  let grid = input
    .splitLines()
    .mapIt(it.toSeq.map(charToInt))
    .matrix

  dijkstra(grid)

proc dijkstra(grid: Matrix[int]): int =
  let
    start = (0,0).Position
    startNode = Node(state:(pos:start, dir:Unknown, straight:0).ProgressState, cost:0, prev:nil)
    goal = (grid.lastCol, grid.lastRow).Position

  var
    queue = [startNode].toHeapQueue
    visited = initHashSet[ProgressState]()

  while queue.len > 0:
    let node = queue.pop()

    if node.state.pos == goal:
      var
        path = newSeq[Position]()
        n = node
      while n.state.pos != start:
        path.add(n.state.pos)
        n = n.prev

      renderPath(grid, path.reversed)
      return node.cost

    for move in grid.nextPossibleMoves(node):
      if visited.containsOrIncl(move.state):
        continue

      queue.push(move)

proc nextPossibleMoves(grid: Matrix[int], node: Node): seq[Node] =
  let (cx, cy) = node.state.pos
  var moves = newSeq[Node]()

  for steps in 4..10:
    for dir in [Right, Down, Left, Up]:
      if node.state.dir == dir or
         node.state.dir == dir.opposite:
        continue

      let
        (dx, dy) = dir.position
        nx = cx + dx * steps
        ny = cy + dy * steps

      if nx < 0 or
         ny < 0 or
         nx > grid.lastCol or
         ny > grid.lastRow:
        continue

      let
        xmin = min(cx + dx, nx)
        xmax = max(cx + dx, nx)
        ymin = min(cy + dy, ny)
        ymax = max(cy + dy, ny)

      var cost = node.cost
      for y in ymin..ymax:
        for x in xmin..xmax:
          cost += grid[y, x]

      let
        state = (pos:(nx, ny).Position, dir:dir, straight:steps).ProgressState
        next = Node(state:state, cost:cost, prev:node)

      moves.add(next)

  moves

proc opposite(dir: Direction): Direction =
  case dir:
  of Up: Down
  of Right: Left
  of Down: Up
  of Left: Right
  of Unknown: Unknown

proc position(dir: Direction): Position =
  case dir:
  of Up: (0,-1)
  of Right: (1,0)
  of Down: (0,1)
  of Left: (-1,0)
  of Unknown: (0,0)

proc renderPath(grid: Matrix[int], path: seq[Position]) =
  var
    steps = matrix[char](grid.rows, grid.cols)
    abcs  = matrix[char](grid.rows, grid.cols, ' ')
  for y in 0 ..< grid.rows:
    for x in 0 ..< grid.cols:
      steps[y, x] = grid[y, x].intToChar

  var previous = (0,0).Position
  for i, step in path:
    steps[step.y, step.x] = ' '
    abcs[step.y, step.x] = ('A'.int + i).char
    previous = step

  echo "grid:"
  for y in 0 ..< grid.rows:
    for x in 0 ..< grid.cols:
      write(stdout, grid[y,x])
    echo ""
  echo ""

  echo "steps:"
  for y in 0 ..< steps.rows:
    for x in 0 ..< steps.cols:
      write(stdout, steps[y,x])
    echo ""
  echo ""

  echo "path:"
  for y in 0 ..< abcs.rows:
    for x in 0 ..< abcs.cols:
      write(stdout, abcs[y,x])
    echo ""
  echo ""
