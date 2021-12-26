import std/[strformat, strutils, sequtils, sugar, tables, sets, heapqueue, options, math]
import fusion/matching
import utils
import memo



type
  Spot = char

  BurrowState = seq[seq[Spot]]

  PartialSolution = object
    state: BurrowState
    predictedCost: int
    totalCost: int

  MoveAttempt = object
    fromX, fromY: int
    toX, toY: int
    moveCost: int



const
  HOME_ROW = 2
  HOME_ROW_LAST = HOME_ROW + 3
  HOME_ROWS = HOME_ROW .. HOME_ROW_LAST
  HOME_A_COL = 3
  HOME_B_COL = 5
  HOME_C_COL = 7
  HOME_D_COL = 9
  HOME_COLS = [HOME_A_COL, HOME_B_COL, HOME_C_COL, HOME_D_COL]
  AMPHIPOD_HOMES = ['A', 'B', 'C', 'D']
  HALLWAY_ROW = 1
  HALLWAY_COL_MIN = 1
  HALLWAY_COL_MAX = 11
  HALLWAY = HALLWAY_COL_MIN .. HALLWAY_COL_MAX
  EMPTY = '.'



func isWinState(burrow: BurrowState): bool =
  for row in HOME_ROWS:
    for i, col in HOME_COLS:
      if burrow[row][col] != AMPHIPOD_HOMES[i]:
        return false

  return true

func canMoveTo(pos: Spot): bool =
  pos == EMPTY

func isOccupied(pos: Spot): bool =
  pos == 'A' or
  pos == 'B' or
  pos == 'C' or
  pos == 'D'

func homeRoomCol(pos: Spot): int =
  case pos:
    of 'A': HOME_A_COL
    of 'B': HOME_B_COL
    of 'C': HOME_C_COL
    of 'D': HOME_D_COL
    else: 0

func canRestAt(row, col: int): bool =
  row == HALLWAY_ROW and (
    col != HOME_A_COL and
    col != HOME_B_COL and
    col != HOME_C_COL and
    col != HOME_D_COL
  )

func moveCost(pod: Spot, steps: int): int =
  case pod:
    of 'A': steps * 1
    of 'B': steps * 10
    of 'C': steps * 100
    of 'D': steps * 1000
    else: 0

func availableRoomRow(pod: Spot, burrow: BurrowState, col: int): Option[int] =
  for row in countdown(HOME_ROW_LAST, HOME_ROW):
    let spot = burrow[row][col]
    if spot == EMPTY:
      return some(row)
    elif spot != pod:
      return none[int]()

  return none[int]()

func blockingOtherAmphipod(pod: Spot, burrow: BurrowState, col,row: int): bool =
  for r in row..HOME_ROW_LAST:
    if burrow[r][col] != pod:
      return true

  return false



proc generateNextPossibleMoves(burrow: BurrowState): seq[MoveAttempt] =
  # if the hallway is not empty, we can look into moving an amphipod to its final room, if possible
  for col in HALLWAY:
    let spot = burrow[HALLWAY_ROW][col]
    if spot.isOccupied():
      let
        amphipod = spot
        targetCol = amphipod.homeRoomCol()
        availableHome = amphipod.availableRoomRow(burrow, targetCol)
      case availableHome:
        of Some(@targetRow):
          # check if the route is clear
          block moveTowardsHome:
            let dir = if targetCol < col: -1 else: 1
            var currentCol = col
            while currentCol != targetCol:
              currentCol += dir
              let target = burrow[HALLWAY_ROW][currentCol]
              if not target.canMoveTo():
                break moveTowardsHome

            let steps = abs(targetRow - HALLWAY_ROW) + abs(targetCol - col)
            result.add(MoveAttempt(
              fromX: col,
              fromY: HALLWAY_ROW,
              toX: targetCol,
              toY: targetRow,
              moveCost: amphipod.moveCost(steps)
            ))

  for row in HOME_ROWS:
    for col in HOME_COLS:
      let spot = burrow[row][col]
      if spot.isOccupied():
        block movePodFromHome:
          let
            amphipod = spot
            amphipodHome = amphipod.homeRoomCol()

          # already home?
          if col == amphipodHome and not amphipod.blockingOtherAmphipod(burrow, col, row):
            break movePodFromHome

          var
            targetCol = col
            targetRow = row
            stepsUp = 0

          # move into hallway
          while targetRow > HALLWAY_ROW:
            stepsUp += 1
            targetRow -= 1
            let target = burrow[targetRow][targetCol]
            if not target.canMoveTo():
              break movePodFromHome

          # move pod to the left
          targetCol = col
          block movePodLeftInHallway:
            while targetCol > HALLWAY_COL_MIN:
              targetCol -= 1
              let target = burrow[targetRow][targetCol]
              if not target.canMoveTo():
                break movePodLeftInHallway

              if canRestAt(targetRow, targetCol):
                let steps = stepsUp + abs(targetCol - col)
                result.add(MoveAttempt(
                  fromX: col,
                  fromY: row,
                  toX: targetCol,
                  toY: targetRow,
                  moveCost: amphipod.moveCost(steps)
                ))

              # move pod home?
              elif targetCol == amphipodHome:
                block movePodHome:
                  case amphipod.availableRoomRow(burrow, targetCol):
                    of Some(@targetRow):
                      let steps = stepsUp + abs(targetCol - col) + abs(targetRow - HALLWAY_ROW)
                      result.add(MoveAttempt(
                        fromX: col,
                        fromY: row,
                        toX: targetCol,
                        toY: targetRow,
                        moveCost: amphipod.moveCost(steps)
                      ))

          # move pod to the right
          targetCol = col
          block movePodRightInHallway:
            while targetCol < HALLWAY_COL_MAX:
              targetCol += 1
              let target = burrow[targetRow][targetCol]
              if not target.canMoveTo():
                break movePodRightInHallway

              if canRestAt(targetRow, targetCol):
                let steps = stepsUp + abs(targetCol - col)
                result.add(MoveAttempt(
                  fromX: col,
                  fromY: row,
                  toX: targetCol,
                  toY: targetRow,
                  moveCost: amphipod.moveCost(steps)
                ))

              # move pod home?
              elif targetCol == amphipodHome:
                block movePodHome:
                  case amphipod.availableRoomRow(burrow, targetCol):
                    of Some(@targetRow):
                      let steps = stepsUp + abs(targetCol - col) + abs(targetRow - HALLWAY_ROW)
                      result.add(MoveAttempt(
                        fromX: col,
                        fromY: row,
                        toX: targetCol,
                        toY: targetRow,
                        moveCost: amphipod.moveCost(steps)
                      ))



proc predictRemainingCost(burrow: BurrowState): int =
  # cost to move from hallway to home room
  for col in HALLWAY:
    let spot = burrow[HALLWAY_ROW][col]
    if spot.isOccupied():
      let
        amphipod = spot
        targetCol = amphipod.homeRoomCol()
        steps = abs(targetCol - col) + 3 # estimate that 2 steps into room will be end position

      result += amphipod.moveCost(steps)

  # cost to move from room to home room
  for row in HOME_ROWS:
    for col in HOME_COLS:
      let spot = burrow[row][col]
      if spot.isOccupied():
        block movePodFromHome:
          let
            amphipod = spot
            amphipodHome = amphipod.homeRoomCol()

          # already home?
          if col == amphipodHome and not amphipod.blockingOtherAmphipod(burrow, col, row):
            break movePodFromHome

          let
            targetCol = amphipod.homeRoomCol()
            steps = abs(HALLWAY_ROW - row) + abs(targetCol - col) + 3 # estimate that 2 steps into room will be end position

          result += amphipod.moveCost(steps)

func `<`(a,b: PartialSolution): bool =
  a.predictedCost < b.predictedCost

proc findLeastCostlySolution(start: BurrowState): int =
  var
    partialSolutions = initHeapQueue[PartialSolution]()
    recordScores = initTable[BurrowState, int]()

  partialSolutions.push(PartialSolution(
    state: start,
    predictedCost: predictRemainingCost(start),
    totalCost: 0
  ))

  while partialSolutions.len > 0:
    let
      partialSolution = partialSolutions.pop()
      state = partialSolution.state
      totalCost = partialSolution.totalCost

    # no chance to beat record?
    if totalCost > recordScores.getOrDefault(state, high(int)):
      continue

    # new win state?
    if state.isWinState():
      # by definition of A-star algorithm, first complete solution we find is the best option
      return totalCost

    # generate all possible moves from this state and see where we can get with them
    for move in state.generateNextPossibleMoves():
      let
        newTotalCost = totalCost + move.moveCost
        amphipod = state[move.fromY][move.fromX]

      var newState = state.dup()
      newState[move.fromY][move.fromX] = '.'
      newState[move.toY][move.toX] = amphipod

      let previousRecordToThisState = recordScores.getOrDefault(newState, high(int))
      if newTotalCost < previousRecordToThisState:
        # new record to this state!
        recordScores[newState] = newTotalCost

        partialSolutions.push(PartialSolution(
          state: newState,
          predictedCost: newTotalCost + predictRemainingCost(newState),
          totalCost: newTotalCost
        ))

  # no possible solution found
  return 0



proc solve*(input: string): int =
  let burrow = parseGrid[Spot](input)
  findLeastCostlySolution(burrow)



tests:
  solve(readFile("test2.txt")) == 44169
  solve(readFile("input2.txt")) == 46451
