import std/[strformat, strutils, sequtils, sugar, tables, sets, math]
import fusion/matching
import elvis
import utils
import bits



proc evaluateOperators(packet: Packet): int64 =
  case packet.kind:
    of PacketKind.Literal:
      packet.value

    of PacketKind.Operator:
      let operands = packet.subPackets.map(evaluateOperators)
      case packet.opKind:
        of OperatorKind.Sum:          operands.sum()
        of OperatorKind.Product:      operands.foldl(a * b, 1'i64)
        of OperatorKind.Minimum:      operands.foldl(min(a, b), int64.high)
        of OperatorKind.Maximum:      operands.foldl(max(a, b), int64.low)
        of OperatorKind.GreaterThan:  operands[0] > operands[1] ? 1 ! 0
        of OperatorKind.LessThan:     operands[0] < operands[1] ? 1 ! 0
        of OperatorKind.Equal:        operands[0] == operands[1] ? 1 ! 0



proc solve*(input: string): int64 =
  parseBitsPacket(input).evaluateOperators()



tests:
  solve("C200B40A82") == 3
  solve("04005AC33890") == 54
  solve("880086C3E88112") == 7
  solve("CE00C43D881120") == 9
  solve("D8005AC2A8F0") == 1
  solve("F600BC2D8F") == 0
  solve("9C005AC2F8F0") == 0
  solve("9C0141080250320F1802104A08") == 1
  solve(readFile("test.txt")) == 54
  solve(readFile("input.txt")) == 1_510_977_819_698
