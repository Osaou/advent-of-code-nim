import std/[strformat, strutils, sequtils, sugar, tables, sets, options, math, algorithm, heapqueue]
import fusion/matching
import utils
import matrix



type
  Position = tuple
    x,y: int

  Record = tuple
    cost: int
    dir: int
    straight: int

  Node = ref object
    previous: Node
    pos: Position
    cost: int
    g: int # totalCost?
    h: int # estimatedRemainingCost?
    f: int # estimatedTotalCost?

proc `hash`(pos: Position): int =
  pos.x + pos.y * 1_000

proc `<`(a, b: Node): bool =
  a.f < b.f

#const BOUNDARY = 10

proc solve*(input: string): int
proc costOfShortestPath*(city: Matrix[int]): int
proc tweakedAStarSearch*(maze: Matrix[int], start,goal: Position): seq[Node]
#proc tweakedAStarSearch*(maze: Matrix[int], start,goal: Position): int
proc newNode*(pos: Position, cost: int): Node
proc countStraightSteps*(currentNode: Node, step: Position): int
proc manhattanDistance*(a,b: Position): int
proc manhattanDistanceCost(maze: Matrix[int], a,b: Position): int
proc renderPath(city: Matrix[int], path: seq[Node])
proc renderStepFrom(a,b: Node): char

tests:
  solve(readFile("test.txt")) == 102
#  solve(readFile("input.txt")) == 0



proc solve(input: string): int =
  input
    #.parseGrid[int]()
    .splitLines()
    .mapIt(it.toSeq.map(charToInt))
    .matrix
    .costOfShortestPath()

proc costOfShortestPath(city: Matrix[int]): int =
  let
    start = (0, 0).Position
    goal = (city.lastCol, city.lastRow).Position

  let path = tweakedAStarSearch(city, start, goal)

  #[
  echo "shortest path:"
  renderPath(city, path)
  #]#

  #let x = path.foldl(a + (if b.previous == nil: 0 else: b.cost), 0)
  #echo x
  path[^1].f

proc tweakedAStarSearch*(maze: Matrix[int], start,goal: Position): seq[Node] =
#proc tweakedAStarSearch*(maze: Matrix[int], start,goal: Position): int =
  let startNode = newNode(start, maze[start.y, start.x])
  var
    frontier = [startNode].toHeapQueue
    visited = newTable[Position, Record]()
    passes = 0
    record = int.high

  const STEP_UPDATE_COUNT = 10_000
  var stepsUntilUpdate = STEP_UPDATE_COUNT

  while frontier.len > 0:
    #[
    var
      currentNode = frontier[0]
      currentIndex = 0
    for i in 1 ..< frontier.len:
      let node = frontier[i]
      if node.f < currentNode.f:
        currentNode = node
        currentIndex = i

    frontier.delete(currentIndex)
    ]#
    let currentNode = frontier.pop()

    #[
    stepsUntilUpdate -= 1
    if stepsUntilUpdate < 0:
      stepsUntilUpdate = STEP_UPDATE_COUNT
      echo "best current pos: ", currentNode.pos.x, ",", currentNode.pos.y
      echo " cost to get here: ", currentNode.g
      echo " estimated remaining cost: ", currentNode.h
      echo " steps queued up: ", frontier.len
    #]#

    # are we done?
    if currentNode.pos == goal:
      #echo "found it!"
      # [
      var
        path = newSeq[Node]()
        node = currentNode

      while node != nil:
        path.add(node)
        node = node.previous

      echo "queued: ", frontier.len
      echo "visited: ", visited.len
      return path.reversed()
      #]#
      #[
      passes += 1
      if currentNode.g < record:
        record = currentNode.g

      if passes > 1_000:
        return record
      #]#

    for d in [(1, 0), (0, 1), (0, -1), (-1, 0)]:
      (@x, @y) := d
      let
        step = (
          x: currentNode.pos.x + x,
          y: currentNode.pos.y + y,
        )

      if step.x < 0 or
         step.y < 0 or
         step.x > maze.lastCol or
         step.y > maze.lastRow:
        continue

      let straight = countStraightSteps(currentNode, step)
      if straight > 3:
        continue

      let
        stepCost = maze[step.y, step.x]
        totalCost = currentNode.g + stepCost
        #path = (pos:step, dir:x+y*10, straight:straight).Steps
        #previousPathHere = visited.getOrDefault(path, int.high)
        dir = x + y*10
        previousPathHere = visited.getOrDefault(step, (cost:int.high, dir:dir, straight:4).Record)
      if previousPathHere.cost < totalCost and previousPathHere.dir == dir and previousPathHere.straight == straight:
        continue

      let
        g = totalCost
        h = manhattanDistance(step, goal)
        #h = manhattanDistanceCost(maze, step, goal)
        f = g + h
        stepNode = Node(
          previous: currentNode,
          pos: step,
          cost: stepCost,
          f:f, g:g, h:h,
        )

      #[
      # check if we already have a shorter path to this node
      var worthVisiting = true
      for n in 0 ..< frontier.len:
        let node = frontier[n]
        if node == stepNode and node.g > stepNode.g:
          worthVisiting = false
          break

      if worthVisiting:
        frontier.push(stepNode)
      #]#
      visited[step] = (cost:totalCost, dir:dir, straight:straight).Record
      frontier.push(stepNode)

  #return record

proc newNode(pos: Position, cost: int): Node =
  Node(
    previous: nil,
    pos: pos,
    cost: cost,
    g: 0,
    h: 0,
    f: 0,
  )

proc countStraightSteps(currentNode: Node, step: Position): int =
  var posThreeStepsAgo: Node = currentNode
  for i in 1..3:
    posThreeStepsAgo = posThreeStepsAgo.previous
    if posThreeStepsAgo == nil:
      return 0

  let
    dx = abs(posThreeStepsAgo.pos.x - step.x)
    dy = abs(posThreeStepsAgo.pos.y - step.y)

  max(dx, dy)

proc manhattanDistance(a,b: Position): int =
  abs(a.x - b.x) + abs(a.y - b.y)

proc manhattanDistanceCost(maze: Matrix[int], a,b: Position): int =
  var cost = 0

  for y in a.y .. b.y:
    for x in a.x .. b.x:
      cost += maze[y,x]

  cost

proc renderPath(city: Matrix[int], path: seq[Node]) =
  var blocks = matrix[char](city.rows, city.cols)
  for y in 0 ..< city.rows:
    for x in 0 ..< city.cols:
      blocks[y, x] = city[y, x].intToChar
  for step in path:
    if step.previous != nil:
      blocks[step.pos.y, step.pos.x] = renderStepFrom(step.previous, step)
  echo blocks

proc renderStepFrom(a,b: Node): char =
  let (ax, ay) = a.pos
  let (bx, by) = b.pos
  if bx > ax:
    return '>'
  elif bx < ax:
    return '<'
  elif by > ay:
    return 'v'
  else:
    return '^'
