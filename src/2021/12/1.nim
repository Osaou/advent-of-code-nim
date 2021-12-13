# imports
import std/[strformat, strutils, sequtils, sugar, tables, sets, math]
import fusion/matching
import data

{.experimental: "caseStmtMacros".}



# tests
const
  expectedTestResult* = 19
  expectedRunResult* = 3292



# daily logic

proc countPathsTo(current, destination: CaveRoom, visitedRooms: HashSet[string]): int =
  if visitedRooms.contains(current.name):
    return 0

  # are we there yet?
  if current == destination:
    return 1

  # small rooms can only be visited once
  var visitedRoomsPrim = visitedRooms.dup()
  if not current.isBigRoom:
    visitedRoomsPrim.incl(current.name)

  # visit all connected rooms and sum their individual path counts to destination
  let successfulPaths = collect(newSeq):
    for room in current.connectedRooms:
      room.countPathsTo(destination, visitedRoomsPrim)

  successfulPaths.sum()

proc countPaths(cavern: Cavern): int =
  let
    startRoom = cavern.rooms["start"]
    endRoom = cavern.rooms["end"]

  startRoom.countPathsTo(endRoom, initHashSet[string]())



# main
proc logic*(input: string): int =
  newCavern(input).countPaths()
