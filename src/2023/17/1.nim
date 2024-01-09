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
    priority: int
    #steps: int
    prev: Node
  PQNode = ref object
    data: Node
    priority: int
    prev, next: PQNode
  PQ = ref object
    head, tail: PQNode
    size: int
  # [
  MovementKind = enum
    Straight
    Turn
    Loop
  Movement = object
    case kind: MovementKind
    of Straight: len: int
    of Turn: straight: int
    of Loop: discard
  #]#

proc newPrioQueue(): PQ =
  PQ(head:nil, tail:nil, size:0)

proc push(queue: var PQ, data: Node, priority: int) =
  # first node?
  if queue.head == nil:
    let node = PQNode(data:data, priority:priority, prev:nil, next:nil)
    queue.head = node
    queue.tail = node
    queue.size = 1
    return

  var
    prev: PQNode = nil
    next = queue.head
  while next != nil:
    if priority < next.priority:
      break

    prev = next
    next = next.next

  # new tail?
  if next == nil:
    let node = PQNode(data:data, priority:priority, prev:queue.tail, next:nil)
    if queue.tail != nil:
      queue.tail.next = node
    queue.tail = node
  # new head?
  elif prev == nil:
    let node = PQNode(data:data, priority:priority, prev:nil, next:queue.head)
    queue.head.prev = node
    queue.head = node
  # in the middle somewhere?
  else:
    let node = PQNode(data:data, priority:priority, prev:prev, next:next)
    prev.next = node
    next.prev = node

  queue.size += 1

proc pop(queue: var PQ): Node =
  if queue.head == nil:
    return nil

  let data = queue.head.data
  queue.head = queue.head.next

  if queue.head == nil:
    queue.tail = nil

  queue.size -= 1
  return data

proc len(queue: PQ): int =
  queue.size

#[
proc hash(x: ProgressState): Hash =
  result =
    x.pos.x.hash !&
    x.pos.y.hash !&
    x.dir.x.hash !&
    x.dir.y.hash !&
    x.straight.hash
  result = !$result
#]#
#[
proc hash(x: ProgressState): Hash =
  x.pos.y +
    x.pos.x * 1_000 +
    x.dir.y * 1_000_000 +
    x.dir.x * 1_000_010 +
    x.straight * 1_000_020
#]#

proc `<`(a, b: Node): bool =
  a.cost < b.cost
  #a.priority < b.priority

  #[
  if a.cost != b.cost:
    return a.cost < b.cost
  if a.state.straight != b.state.straight:
    return a.state.straight < b.state.straight
  return a.priority < b.priority
  ]#

proc solve*(input: string): int
#proc dijkstra(grid: Matrix[int]): int
proc dijkstra(grid: Matrix[int]): seq[Position]
proc countStraightSteps(currentNode: Node, dir: Position): int {.inline.}
proc mapPreviousFourSteps(currentNode: Node, dir: Position): Movement {.inline.}
#proc manhattanDistance(a,b: Position): int {.inline.}

proc renderPath(grid: Matrix[int], path: seq[Position])
proc renderStepFrom(a,b: Position): char

tests:
  solve(readFile("test.txt")) == 102
  solve(readFile("test2.txt")) == 171
  solve(readFile("test3.txt")) == 7
  solve(readFile("test4.txt")) == 29
#  solve(readFile("input.txt")) == 0



proc solve(input: string): int =
  let grid = input
    .splitLines()
    .mapIt(it.toSeq.map(charToInt))
    .matrix

  let path = dijkstra(grid)

  # [
  renderPath(grid, path)
  #]#

  let x = path.foldl(a + grid[b.y, b.x], 0)
  #let x = path[^1].cost
  #echo x
  x

#proc dijkstra(grid: Matrix[int]): int =
proc dijkstra(grid: Matrix[int]): seq[Position] =
  let
    start = (0,0).Position
    #startNode = Node(state:(pos:start, dir:(0,0).Position, straight:0).ProgressState, cost:0, priority:0, steps:0, prev:nil)
    startNode = Node(state:(pos:start, dir:(0,0).Position, straight:0).ProgressState, cost:0, priority:0, prev:nil)
    #startNode = Node(state:ProgressState(pos:start, dir:(0,0).Position, straight:0), cost:0, priority:0, steps:0, prev:nil)
    goal = (grid.lastCol, grid.lastRow).Position

  #echo startNode.state
  #echo $startNode.state

  var
    cache = newTable[string, int]()
    queue = [startNode].toHeapQueue
    #queue = newPrioQueue()
    recordNode: Node = nil
    iterations = 0

  echo "goal: ", goal.x, ", ", goal.y
  #queue.push(startNode, 0)

  while queue.len > 0:
    let
      node = queue.pop()
      nodePos = node.state.pos
    #echo "checking (", x, ",", y, ")"

    #[
    var
      path = newSeq[Position]()
      n = node
    while n != nil:
      path.add(n.state.pos)
      n = n.prev
    echo "current path: ", path.reversed()
    #]#

    #[
    var
      path = newSeq[Position]()
      n = node
    while n != nil:
      path.add(n.state.pos)
      n = n.prev
    write(stdout, "cost: ")
    write(stdout, node.cost)
    write(stdout, ", path: ")
    for p in path.reversed():
      write(stdout, grid[p.y, p.x])
    #write(stdout, ", path: ")
    for p in path.reversed():
      write(stdout, " (")
      write(stdout, p.x)
      write(stdout, ",")
      write(stdout, p.y)
      write(stdout, ")")
    echo ""
    #]#

    if nodePos == goal:
    #if nodePos.x == goal.x and nodePos.y == goal.y:
      echo "found it!"
      # [
      recordNode = node
      break
      #]#

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
        #echo "  discarded movement ", dir, " because of BACKTRACKING"
        continue

      if nx < 0 or
         ny < 0 or
         nx > grid.lastCol or
         ny > grid.lastRow:
        #echo "  discarded movement ", dir, " because of OUTSIDE PERIMETER"
        continue

      # [
      let straight = countStraightSteps(node, dir)
      if straight > 3:
        #echo "  discarded movement ", dir, " because of EXCEEDED MAX STRAIGHT STEPS (", straight, ")"
        continue
      #]#
      #[
      let
        steps = mapPreviousFourSteps(node, dir)
        straight = case steps.kind
        of Straight:
          continue
        else:
          steps.straight
      #]#

      let
        totalCost = node.cost + grid[ny, nx]
        pos = (nx, ny).Position
        state = (pos:pos, dir:dir, straight:straight).ProgressState
        #state = ProgressState(pos:pos, dir:dir, straight:straight)
        recordCost = cache.getOrDefault($state, int.high)
      if totalCost > recordCost:
        continue

      #if recordCost != int.high:
      #  queue.del(next) !!!

      let
        #distance = manhattanDistance(pos, goal)
        #distance = manhattanDistance(start, pos)
        #steps = node.steps + 1
        priority = totalCost
        #next = Node(state:state, cost:totalCost, priority:priority, steps:steps, prev:node)
        next = Node(state:state, cost:totalCost, priority:priority, prev:node)
        #present = queue.find(next)

      #if present >= 0:
      #  continue

      queue.push(next)
      #queue.push(next, priority)
      cache[$state] = totalCost
      #echo "  pushed movement ", dir, " with priority ", priority

    # [
    iterations += 1
    if iterations mod 100_000 == 0:
      echo queue.len
      iterations = 0
    #]#

  echo "iterations: ", iterations

  if recordNode == nil:
    return @[]

  var
    path = newSeq[Position]()
    n = recordNode
  while n.state.pos != start:
    path.add(n.state.pos)
    n = n.prev
  return path.reversed()

# [
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
#]#

# [
proc mapPreviousFourSteps(currentNode: Node, dir: Position): Movement =
  var
    node = currentNode
    distance = 1
    nextDir = dir

  for i in 1..3:
    if node.prev == nil:
      break

    if node.state.dir == nextDir:
      distance += 1
    else:
      nextDir = (0,0).Position

    node = node.prev

  if distance > 3:
    return Movement(kind: Straight, len: distance)

  let
    (nx, ny) = node.state.pos
    (cx, cy) = currentNode.state.pos
    dx = abs(nx - (cx + dir.x))
    dy = abs(ny - (cy + dir.y))

  if dx == 0 and dy == 0:
    return Movement(kind: Loop)
  else:
    return Movement(kind: Turn, straight: distance)
#]#

#[
proc manhattanDistance(a,b: Position): int =
  abs(a.x - b.x) + abs(a.y - b.y)
]#

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
