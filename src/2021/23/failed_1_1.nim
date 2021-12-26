import std/[strformat, strutils, sequtils, sugar, tables, sets, options, math]
import fusion/matching
import utils
import memo



type
  Color = enum
    Amber
    Bronze
    Copper
    Desert

  Position = tuple
    row, col: int

  Amphipod = object
    color: Color
    pos: Position
    home: bool

  Location = enum
    Hallway
    Room

  Spot = object
    case kind: Location:
      of Hallway:
        canRest: bool
      of Room:
        belongsTo: Color

  #BurrowState = {.union.} object
  #  amphipods: array[8, Amphipod]
  #  p1,p2,p3,p4,p5,p6,p7,p8: Amphipod
  BurrowState = object
    amphipods: seq[Amphipod]

#  RoomIndex = enum
#    First = 2
#    Second = 4
#    Third = 6
#    Fourth = 8
#    NotARoom



let burrow =  @[
  @[ Spot(kind:Hallway, canRest:true), Spot(kind:Hallway, canRest:true) ],
  @[
    Spot(kind:Hallway, canRest:false),
    Spot(kind:Room, belongsTo:Amber),
    Spot(kind:Room, belongsTo:Amber),
  ],
  @[ Spot(kind:Hallway, canRest:true) ],
  @[
    Spot(kind:Hallway, canRest:false),
    Spot(kind:Room, belongsTo:Bronze),
    Spot(kind:Room, belongsTo:Bronze),
  ],
  @[ Spot(kind:Hallway, canRest:true) ],
  @[
    Spot(kind:Hallway, canRest:false),
    Spot(kind:Room, belongsTo:Copper),
    Spot(kind:Room, belongsTo:Copper),
  ],
  @[ Spot(kind:Hallway, canRest:true) ],
  @[
    Spot(kind:Hallway, canRest:false),
    Spot(kind:Room, belongsTo:Desert),
    Spot(kind:Room, belongsTo:Desert),
  ],
  @[ Spot(kind:Hallway, canRest:true), Spot(kind:Hallway, canRest:true) ],
]

# start with a very high score to beat
var recordScore = 10_000'i64 #high(int).int64



proc parseAmphipod(pods: openArray[string], row,col: int): Amphipod =
  let pos = (
    row: row - 1,
    col: col * 2 + 2
  )
  case pods[row][col]:
    of 'A': Amphipod(color:Amber,  pos:pos, home: col == 0)
    of 'B': Amphipod(color:Bronze, pos:pos, home: col == 1)
    of 'C': Amphipod(color:Copper, pos:pos, home: col == 2)
    of 'D': Amphipod(color:Desert, pos:pos, home: col == 3)
    else: raise newException(ValueError, "unknown diagram amphipod representation: '" & pods[row][col] & "'")

proc parseInput(input: string): BurrowState =
  let pods = input
    .replace("#", "")
    .replace(".", "")
    .replace(" ", "")
    .splitLines()
  echo pods

  BurrowState(amphipods: @[
    pods.parseAmphipod(2,0), pods.parseAmphipod(3,0),
    pods.parseAmphipod(2,1), pods.parseAmphipod(3,1),
    pods.parseAmphipod(2,2), pods.parseAmphipod(3,2),
    pods.parseAmphipod(2,3), pods.parseAmphipod(3,3),
  ])



func winState(state: BurrowState): bool =
  state.amphipods.allIt(it.home)

func moveCost(pod: Amphipod, steps: int): int64 =
  case pod.color:
    of Amber: steps
    of Bronze: steps * 10
    of Copper: steps * 100
    of Desert: steps * 1000

func isHomeRoom(pod: Amphipod, roomIndex: int): bool =
  case pod.color:
    of Amber: roomIndex == 2
    of Bronze: roomIndex == 4
    of Copper: roomIndex == 6
    of Desert: roomIndex == 8

#func isHomeRoom(pod: Amphipod, room: RoomIndex): bool =
#  case pod.color:
#    of Amber: room == First
#    of Bronze: room == Second
#    of Copper: room == Third
#    of Desert: room == Fourth

#func roomIndex(col: int): bool =
#  case col:
#    of Amber: room == First
#    of Bronze: room == Second
#    of Copper: room == Third
#    of Desert: room == Fourth

# step 1, try to find a color where their bottom room spot is filled correctly, but top is not
#func findAlmostFilledCandidate(): Option[Amphipod] =
#  for p1 in state.amphipods:
#    if p1.home:
#      for p2 in state.amphipods:
#        if not p2.home and p2.col == p1.col:
#          return some(p2)

proc moveAmphipods(state: BurrowState, totalCost: int64): bool {.memoized.} =
  # no chance to beat record?
  if totalCost >= recordScore:
    return false

  # new win state?
  if state.winState():
    if totalCost < recordScore:
      echo "new record: ", totalCost
      recordScore = totalCost
    return true

  var grid = newSeqWith[seq[char]](5, newSeqWith[char](13, '#'))
  for hallway in 1..11:
    grid[1][hallway] = '.'
  grid[2][3] = '.'
  grid[3][3] = '.'
  grid[2][5] = '.'
  grid[3][5] = '.'
  grid[2][7] = '.'
  grid[3][7] = '.'
  grid[2][9] = '.'
  grid[3][9] = '.'

  # find available spots
  let
    hallwayPods = state.amphipods.filterIt(it.pos.row == 0)
    emptyHallway = hallwayPods.len == 0
  var filledSpots = initHashSet[Position]()
  for pod in state.amphipods:
    filledSpots.incl(pod.pos)
    grid[pod.pos.row + 1][pod.pos.col + 1] = ($pod.color)[0]

  echo "Current state:\n"
  for row in grid:
    for c in row:
      stdout.write c
    echo ""

  # if the hallway is not empty, we can look into moving an amphipod to its final room, if possible
  if not emptyHallway:
    for index, hallwayPod in hallwayPods:
      var
        roomOccupants = 0
        roomCol = 0
        otherPods = state.amphipods
      otherPods.delete(index)

      for otherPod in otherPods:
        # is the last spot in our room occupied?
        if otherPod.pos.row > 1 and hallwayPod.isHomeRoom(otherPod.pos.col):
          roomOccupants += 1
          roomCol = otherPod.pos.col
          break

      # try to move to the first empty spot in our final room
      if roomOccupants < 2:
        let
          roomPos = 2 - roomOccupants
          steps = roomPos +                   # vertical steps
            abs(roomCol - hallwayPod.pos.col) # horisontal steps

        var pod = hallwayPod
        pod.pos.row = roomPos
        pod.pos.col = roomCol
        pod.home = true

        discard moveAmphipods(
          BurrowState(amphipods: otherPods & pod),
          totalCost + pod.moveCost(steps)
        )

  # try to move pods out from room into the hallway
  for index, p in state.amphipods:
    block podAttempt:
      var pod = p
      if not pod.home and pod.pos.row > 0:
        var stepsUp = 0
        # move out into hallway
        while pod.pos.row > 0:
          pod.pos.row -= 1
          stepsUp += 1
          # unable to move here?
          if filledSpots.contains(pod.pos):
            break podAttempt

        var
          startingCol = pod.pos.col
          otherPods = state.amphipods
        otherPods.delete(index)

        block moveLeft:
          # attempt to move to the left in hallway
          var stepsLeft = 0
          while true:
            if filledSpots.contains(pod.pos):
              break moveLeft

            stepsLeft += 1
            pod.pos.col = startingCol - stepsLeft

            discard moveAmphipods(
              BurrowState(amphipods: otherPods & pod),
              totalCost + pod.moveCost(stepsUp + stepsLeft)
            )

            if pod.pos.col <= 0:
              break moveLeft

            # final room?
            if pod.isHomeRoom(pod.pos.col):
              var roomOccupants = 0
              for otherPod in otherPods:
                # is the last spot in our room occupied?
                if otherPod.pos.row > 1 and pod.pos.col == otherPod.pos.col:
                  roomOccupants += 1
                  break

              # try to move to the first empty spot in our final room
              if roomOccupants < 2:
                let
                  roomPos = 2 - roomOccupants
                  steps = stepsUp + stepsLeft + roomPos

                var homePod = pod
                homePod.pos.row = roomPos
                homePod.home = true

                discard moveAmphipods(
                  BurrowState(amphipods: otherPods & homePod),
                  totalCost + homePod.moveCost(steps)
                )

        block moveRight:
          # attempt to move to the right in hallway
          var stepsRight = 0
          while true:
            if filledSpots.contains(pod.pos):
              break moveRight

            stepsRight += 1
            pod.pos.col = startingCol + stepsRight

            discard moveAmphipods(
              BurrowState(amphipods: otherPods & pod),
              totalCost + pod.moveCost(stepsUp + stepsRight)
            )

            if pod.pos.col >= 10:
              break moveRight

            # final room?
            if pod.isHomeRoom(pod.pos.col):
              var roomOccupants = 0
              for otherPod in otherPods:
                # is the last spot in our room occupied?
                if otherPod.pos.row > 1 and pod.pos.col == otherPod.pos.col:
                  roomOccupants += 1
                  break

              # try to move to the first empty spot in our final room
              if roomOccupants < 2:
                let
                  roomPos = 2 - roomOccupants
                  steps = stepsUp + stepsRight + roomPos

                var homePod = pod
                homePod.pos.row = roomPos
                homePod.home = true

                discard moveAmphipods(
                  BurrowState(amphipods: otherPods & homePod),
                  totalCost + homePod.moveCost(steps)
                )

  false

proc solve*(input: string): int64 =
  let burrow = parseInput(input)
  for pod in burrow.amphipods:
    echo "pod: ", pod.color, "(", pod.pos.row, ", ", pod.pos.col, "), home:", pod.home
  discard moveAmphipods(burrow, 0)

  recordScore



tests:
  parseAmphipod(["BCBD", "ADCA"], 0,0) == Amphipod(color:Bronze, pos:(row:0, col:0), home:false)
  parseAmphipod(["BCBD", "ADCA"], 1,3) == Amphipod(color:Amber,  pos:(row:1, col:3), home:false)
  parseAmphipod(["BCBD", "ADCA"], 1,0) == Amphipod(color:Amber,  pos:(row:1, col:0), home:true)
