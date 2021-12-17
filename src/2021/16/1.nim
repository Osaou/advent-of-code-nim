import std/[strformat, strutils, sequtils, sugar, tables, sets, math]
import fusion/matching
import utils
import bits



func sumOfPacketVersions(packet: Packet): int =
  case packet.kind:
    of PacketKind.Literal:
      packet.header.version
    of PacketKind.Operator:
      packet.header.version + packet.subPackets.map(sumOfPacketVersions).sum()



proc solve*(input: string): int64 =
  parseBitsPacket(input).sumOfPacketVersions()



tests:
  solve("D2FE28") == 6
  solve("8A004A801A8002F478") == 16
  solve("620080001611562C8802118E34") == 12
  solve("C0015000016115A2E0802F182340") == 23
  solve(readFile("test.txt")) == 31
  solve(readFile("input.txt")) == 913
