import std/[strformat, strutils, sequtils, sugar, tables, sets, options, math, algorithm, heapqueue]
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
    priority: int
    prev: Node

# [
proc `hash`(x: ProgressState): int =
  x.pos.y +
    x.pos.x * 1_000 +
    x.dir.y * 1_000_000 +
    x.dir.x * 1_000_010 +
    x.straight * 1_000_020
#]#

proc `<`(a, b: Node): bool =
  #a.cost < b.cost

  a.priority < b.priority
  #a.priority < b.priority and a.cost < b.cost
  #(a.priority div 3) < (b.priority div 3) and a.cost < b.cost

  #[
  let prio = a.priority - b.priority
  #let prio = (a.priority div 3) - (b.priority div 3)
  #let prio = (a.priority div 2) - (b.priority div 2)
  #let prio = (a.priority - b.priority) + 2
  if prio < 0: true
  elif prio > 0: false
  else: a.cost < b.cost
  #]#

  #(a.cost + a.priority) < (b.cost + b.priority)

proc solve*(input: string): int
#proc dijkstra(grid: Matrix[int]): int
proc dijkstra(grid: Matrix[int]): seq[Position]
proc countStraightSteps(currentNode: Node, step: Position): int {.inline.}
proc depthIndex*(dx,dy: int, straight: int): int
proc manhattanDistance(a,b: Position): int {.inline.}

proc renderPath(grid: Matrix[int], path: seq[Position])
proc renderStepFrom(a,b: Position): char

#tests:
#  solve(readFile("test.txt")) == 102
#  solve(readFile("input.txt")) == 0



proc solve(input: string): int =
  let grid = input
    .splitLines()
    .mapIt(it.toSeq.map(charToInt))
    .matrix

  echo "finding the shortest path..."
  let path = dijkstra(grid)

  # [
  echo "shortest path:"
  renderPath(grid, path)
  #]#

  let x = path.foldl(a + grid[b.y, b.x], 0)
  #echo x
  x

#proc dijkstra(grid: Matrix[int]): int =
proc dijkstra(grid: Matrix[int]): seq[Position] =
  let
    start = Node(state:(pos:(0,0).Position, dir:(0,0).Position, straight:0).ProgressState, cost:0, priority:0, prev:nil)
    goal = (grid.lastRow, grid.lastCol).Position

  var
    #distances = matrix[seq[int]](grid.rows, grid.cols)
    #previous = matrix(grid.rows, grid.cols, (0,0).Position)
    #cache = newTable[ProgressState, Node]()
    cache = newTable[ProgressState, int]()
    #cache: seq[seq[seq[seq[Node]]]] = newSeqWith(grid.rows, newSeqWith(grid.cols, newSeqWith(4, newSeqWith[Node](4, nil))))
    queue = [start].toHeapQueue
    #paths = newSeq[Node]()

  #[
  const DEPTH = 4 * 4
  for y in 0 ..< distances.rows:
    for x in 0 ..< distances.cols:
      for z in 0 ..< DEPTH:
        if y == 0 and x == 0:
          distances[y,x] = newSeqWith(DEPTH, 0)
        else:
          distances[y,x] = newSeqWith(DEPTH, int.high)
  ]#

  #[
  for y in 0 ..< grid.rows:
    for x in 0 ..< grid.cols:
      if y != 0 and x != 0:
        let
          pos = (x,y).Position
          priority = manhattanDistance(pos, goal)
          node = (pos, grid[y,x], priority).Node
        queue.push(node)
  ]#

  var recordNode: Node = nil
  var iterations = 0

  while queue.len > 0:
    let
      node = queue.pop()
      nodePos = node.state.pos
    #echo "checking (", x, ",", y, ")"

    if nodePos == goal:
      #[
      paths.add(node)
      if paths.len >= 10:
        break
      ]#

      # [
      recordNode = node
      break
      #]#

      #[
      if recordNode == nil or node.cost < recordNode.cost:
        recordNode = node

      continue
      ]#

      #[
      echo "found it?"
      if distances[goal.y, goal.x].anyIt(it == 0):
        continue
      else:
        break
      ]#

      #[
      echo "found it!"
      #return distances[node.pos.y, node.pos.x]
      var path = newSeq[Position]()
      var n = node
      while n.pos != start.pos:
        path.add(n.pos)
        n = n.prev
      return path.reversed()
      ]#

    let
      (cx, cy) = nodePos
      (px, py) = if node.prev == nil: (0,0)
                 else: node.prev.state.pos

    for nei, neighbor in [(1, 0), (0, 1), (0, -1), (-1, 0)]:
      let
        (dx, dy) = neighbor
        nx = cx + dx
        ny = cy + dy

      if nx == px and ny == py:
        continue

      if nx < 0 or
         ny < 0 or
         nx > grid.lastCol or
         ny > grid.lastRow:
        continue

      let
        pos = (nx,ny).Position
        straight = countStraightSteps(node, pos)
      if straight > 3:
        continue

      let
        #depth = depthIndex(dx,dy, straight)
        #cost = grid[ny, nx]
        totalCost = node.cost + grid[ny, nx]
        state = (pos:pos, dir:neighbor.Position, straight:straight).ProgressState

      #[
      var recordCost = int.high
      let cached = cache.getOrDefault(state, nil)
      #let cached = cache[ny][nx][nei][straight]
      if cached != nil:
        recordCost = cached.cost
      ]#
      let recordCost = cache.getOrDefault(state, int.high)
      if totalCost > recordCost:
        continue

      let
        #priority = manhattanDistance(pos, goal) # HOW DO I GET THE PRIORITY RIGHT??? cost and distance should both matter, right?
        priority = totalCost
        next = Node(state:state, cost:totalCost, priority:priority, prev:node)
      queue.push(next)
      #cache[ny][nx][nei][straight] = cost
      cache[state] = totalCost

      #[
      for z in 0 ..< DEPTH:
        if totalCost < distances[ny, nx][z]:
          var depthCost = distances[ny, nx]
          depthCost[depth] = totalCost
          #previous[ny, nx] = node.pos

          let
            priority = manhattanDistance(pos, goal)
            next = Node(pos:pos, cost:cost, priority:priority, prev:node)
          queue.push(next)
      ]#

    #[
    iterations += 1
    if iterations mod 100_000 == 0:
      echo queue.len
      iterations = 0
    #]#

  if recordNode == nil:
    return @[]

  #return distances[node.pos.y, node.pos.x]

  #[
  recordNode = paths[0]
  for i in 1 ..< paths.len:
    let n = paths[i]
    if n.cost < recordNode.cost:
      recordNode = n
  ]#

  var path = newSeq[Position]()
  var n = recordNode
  while n.state.pos != start.state.pos:
    path.add(n.state.pos)
    n = n.prev
  return path.reversed()

proc countStraightSteps(currentNode: Node, step: Position): int =
  var node = currentNode
  for i in 1..3:
    if node.prev == nil:
      break
    node = node.prev

  let
    (nx, ny) = node.state.pos
    dx = abs(nx - step.x)
    dy = abs(ny - step.y)

  max(dx, dy)

#[ tests:#
  depthIndex(-1,0, 0) == 0
  depthIndex(-1,0, 1) == 1
  depthIndex(-1,0, 2) == 2
  depthIndex(-1,0, 3) == 3
  depthIndex( 1,0, 0) == 4
  depthIndex( 1,0, 1) == 5
  depthIndex( 1,0, 2) == 6
  depthIndex( 1,0, 3) == 7
  depthIndex(0,-1, 0) == 8
  depthIndex(0,-1, 1) == 9
  depthIndex(0,-1, 2) == 10
  depthIndex(0,-1, 3) == 11
  depthIndex(0, 1, 0) == 12
  depthIndex(0, 1, 1) == 13
  depthIndex(0, 1, 2) == 14
  depthIndex(0, 1, 3) == 15
]#
proc depthIndex(dx,dy: int, straight: int): int =
  if dy == 0:
    return straight + 1 + (if dx < 0: dx
                           else: 2 + dx)
  else:
    return straight + 9 + (if dy < 0: dy
                           else: 2 + dy)

proc manhattanDistance(a,b: Position): int =
  abs(a.x - b.x) + abs(a.y - b.y)

proc renderPath(grid: Matrix[int], path: seq[Position]) =
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
