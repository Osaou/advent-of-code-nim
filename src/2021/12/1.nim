import std/[strformat, strutils, sequtils, sugar, tables, sets, math]
import fusion/matching
import utils
import data



func countPathsTo(current, destination: CaveRoom, visitedRooms: HashSet[string]): int =
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

func countPaths(cavern: Cavern): int =
  let
    startRoom = cavern.rooms["start"]
    endRoom = cavern.rooms["end"]

  startRoom.countPathsTo(endRoom, initHashSet[string]())



func solve*(input: string): int =
  newCavern(input).countPaths()



tests:
  solve(readFile("test.txt")) == 10
  solve(readFile("test_slightly_larger_example.txt")) == 19
  solve(readFile("test_even_larger_example.txt")) == 226
  solve(readFile("input.txt")) == 3292
