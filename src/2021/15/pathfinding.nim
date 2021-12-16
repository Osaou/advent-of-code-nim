import astar



type
  Grid* = seq[seq[int]]
  Point* = tuple[x, y: int]
  Distance* = float



template yieldIfExists(grid: Grid, point: Point) =
  let exists =
    point.y >= 0 and point.y < grid.len and
    point.x >= 0 and point.x < grid[point.y].len
  if exists:
    yield point

# iterator of connected neighbor nodes from any given node
iterator neighbors*(grid: Grid, point: Point): Point =
  yieldIfExists grid, (x: point.x - 1, y: point.y)
  yieldIfExists grid, (x: point.x + 1, y: point.y)
  yieldIfExists grid, (x: point.x, y: point.y - 1)
  yieldIfExists grid, (x: point.x, y: point.y + 1)

# the cost of moving from node a to node b
proc cost*(grid: Grid, a, b: Point): Distance =
  grid[a.y][a.x].Distance

# A* algorithm requires a "priority" heuristic value for visiting a given node
# use provided "as the crow flies" algorithm
proc heuristic*(grid: Grid, node, goal: Point): Distance =
  asTheCrowFlies(node, goal)
