# imports
import std/[strformat, strutils, sequtils, sugar, tables, sets, math]
import fusion/matching
import utils
import bits

{.experimental: "caseStmtMacros".}



# tests
const
  expectedTestResult* = 31
  expectedRunResult* = 913



func sumOfPacketVersions(packet: Packet): int =
  case packet.kind:
    of PacketKind.Literal:
      packet.header.version
    of PacketKind.Operator:
      packet.header.version + packet.subPackets.map(sumOfPacketVersions).sum()

# main
proc logic*(input: string): int64 =
  parseBitsPacket(input).sumOfPacketVersions()



# more tests
when isMainModule:
  assert logic("8A004A801A8002F478") == 16
  assert logic("620080001611562C8802118E34") == 12
  assert logic("C0015000016115A2E0802F182340") == 23
  assert logic("A0016C880162017C3686B18A3D4780") == 31
