# imports
import std/[strformat, strutils, sequtils, sugar, tables, sets, math]
import fusion/matching
import utils
import data

{.experimental: "caseStmtMacros".}



# tests
const
  expectedTestResult* = 103
  expectedRunResult* = 89592



# daily logic

type PossiblePath = tuple
  count: int
  path: string

func countPathsTo(current, destination: CaveRoom, visitedRooms: CountTable[string], okToVisitTwice: CaveRoom): seq[PossiblePath] =
  let count = visitedRooms.getOrDefault(current.name)
  if current == okToVisitTwice:
    if count >= 2:
      return @[(count:0, path:"")]
  elif count >= 1:
    return @[(count:0, path:"")]

  # are we there yet?
  if current == destination:
    return @[(count:1, path:current.name)]

  # small rooms can only be visited once
  var visitedRoomsPrim = visitedRooms.dup()
  if not current.isBigRoom:
    visitedRoomsPrim.inc(current.name)

  # visit all connected rooms and sum their individual path counts to destination
  var successfulPaths: seq[PossiblePath]
  for room in current.connectedRooms:
    let possiblePath = room.countPathsTo(destination, visitedRoomsPrim, okToVisitTwice)
    for p in possiblePath:
      if p.count > 0:
        successfulPaths.add((
          count: p.count,
          path: fmt"{current.name}, {p.path}"
        ))

  successfulPaths

proc countPaths(cavern: Cavern): int =
  let
    startRoom = cavern.rooms["start"]
    endRoom = cavern.rooms["end"]
    smallRoomsToVisitTwice = toSeq(cavern.rooms.values)
      .filterIt(not it.isBigRoom)
      .filterIt(it != startRoom and it != endRoom)

  var
    totalPaths = initHashSet[string]()
    totalPathCount = 0

  for smallRoom in smallRoomsToVisitTwice:
    let possiblePaths = startRoom.countPathsTo(endRoom, initCountTable[string](), smallRoom)
    for p in possiblePaths:
      if not totalPaths.contains(p.path):
        totalPaths.incl(p.path)
        totalPathCount += p.count

  totalPathCount



# main
proc logic*(input: string): int =
  newCavern(input).countPaths()
