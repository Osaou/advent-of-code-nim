# imports
import std/[strformat, strutils, sequtils, sugar, tables, sets, math]
import fusion/matching
import elvis
import utils
import bits

{.experimental: "caseStmtMacros".}



# tests
const
  expectedTestResult* = 0
  expectedRunResult* = 1510977819698



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

# main
proc logic*(input: string): int64 =
  parseBitsPacket(input).evaluateOperators()
