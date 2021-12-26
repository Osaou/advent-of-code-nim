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
  HOME_ROW_2 = HOME_ROW + 1
  HOME_ROWS = HOME_ROW .. HOME_ROW_2
  HOME_A_COL = 3
  HOME_B_COL = 5
  HOME_C_COL = 7
  HOME_D_COL = 9
  HOME_COLS = [HOME_A_COL, HOME_B_COL, HOME_C_COL, HOME_D_COL]
  HALLWAY_ROW = 1
  HALLWAY_COL_MIN = 1
  HALLWAY_COL_MAX = 11
  HALLWAY = HALLWAY_COL_MIN .. HALLWAY_COL_MAX
  EMPTY = '.'



func isWinState(burrow: BurrowState): bool =
  burrow[HOME_ROW][HOME_A_COL] == 'A' and burrow[HOME_ROW_2][HOME_A_COL] == 'A' and
  burrow[HOME_ROW][HOME_B_COL] == 'B' and burrow[HOME_ROW_2][HOME_B_COL] == 'B' and
  burrow[HOME_ROW][HOME_C_COL] == 'C' and burrow[HOME_ROW_2][HOME_C_COL] == 'C' and
  burrow[HOME_ROW][HOME_D_COL] == 'D' and burrow[HOME_ROW_2][HOME_D_COL] == 'D'

func availableRoomRow(burrow: BurrowState, col: int): Option[int] =
  for row in countdown(HOME_ROW_2, HOME_ROW):
    if burrow[row][col] == EMPTY:
      return some(row)

  return none[int]()

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



proc generateNextPossibleMoves(burrow: BurrowState): seq[MoveAttempt] =
  # if the hallway is not empty, we can look into moving an amphipod to its final room, if possible
  for col in HALLWAY:
    let spot = burrow[HALLWAY_ROW][col]
    if spot.isOccupied():
      let
        amphipod = spot
        targetCol = amphipod.homeRoomCol()
        availableHome = burrow.availableRoomRow(targetCol)
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
          if col == amphipodHome and
            (row == HOME_ROW_2 or
            burrow[HOME_ROW_2][col] == amphipod):
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
                  case burrow.availableRoomRow(targetCol):
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
                  case burrow.availableRoomRow(targetCol):
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
  # cost to move from hallway to in front of home room
  for col in HALLWAY:
    let spot = burrow[HALLWAY_ROW][col]
    if spot.isOccupied():
      let
        amphipod = spot
        targetCol = amphipod.homeRoomCol()
        steps = abs(targetCol - col)

      result += amphipod.moveCost(steps)

  # cost to move from room to hallway in front of home room
  for row in HOME_ROWS:
    for col in HOME_COLS:
      let spot = burrow[row][col]
      if spot.isOccupied():
        block movePodFromHome:
          let
            amphipod = spot
            amphipodHome = amphipod.homeRoomCol()

          # already home?
          if col == amphipodHome and
            (row == HOME_ROW_2 or
            burrow[HOME_ROW_2][col] == amphipod):
            break movePodFromHome

          let
            targetCol = amphipod.homeRoomCol()
            steps = abs(HALLWAY_ROW - row) + abs(targetCol - col)

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
  solve(readFile("test.txt")) == 12521
  solve(readFile("input.txt")) == 10321
