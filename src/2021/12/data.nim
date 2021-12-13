import std/[strformat, strutils, sequtils, sugar, tables, sets, math]
import fusion/matching

{.experimental: "caseStmtMacros".}



type
  CaveRoom* = ref CaveRoomObj
  CaveRoomObj = object
    name*: string
    connectedRooms*: seq[CaveRoom]
    isBigRoom*: bool

  Cavern* = object
    rooms*: Table[string, CaveRoom]

proc addRoom(cavern: var Cavern, name: string): CaveRoom =
  if cavern.rooms.hasKey(name):
    cavern.rooms[name]
  else:
    let room = CaveRoom(
      name: name,
      connectedRooms: newSeq[CaveRoom](),
      isBigRoom: name[0].isUpperAscii()
    )
    cavern.rooms[name] = room
    room

proc connectRooms(cavern: var Cavern, n1, n2: string) =
  let r1 = cavern.addRoom(n1)
  let r2 = cavern.addRoom(n2)
  r1.connectedRooms.add(r2)
  r2.connectedRooms.add(r1)

proc newCavern*(input: string): Cavern =
  var
    cavern = Cavern(rooms: initTable[string, CaveRoom]())
    #start = CaveRoom(paths:newSeq(), isBigRoom:false, name:"start")
    #end_ =  CaveRoom(paths:newSeq(), isBigRoom:false, name:"end")
  for path in input.splitLines():
    [@r1, @r2] := path.split("-")
    cavern.connectRooms(r1, r2)

  cavern
