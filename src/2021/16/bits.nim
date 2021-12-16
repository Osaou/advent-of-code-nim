import std/[strformat, strutils, parseutils, sequtils, math]



type
  TypeId* {.pure.} = enum
    Sum = 0
    Product = 1
    Minimum = 2
    Maximum = 3
    Literal = 4
    GreaterThan = 5
    LessThan = 6
    Equal = 7

  PacketKind* {.pure.} = enum
    Literal
    Operator

  OperatorKind* {.pure.} = enum
    Sum
    Product
    Minimum
    Maximum
    GreaterThan
    LessThan
    Equal

  OperatorMode* = enum
    Zero
    One

  PacketHeader* = object
    version*: int
    typeId*: TypeId

  Packet* = ref PacketObj
  PacketObj = object
    header*: PacketHeader
    case kind*: PacketKind
      of PacketKind.Literal:
        value*: int64
      of PacketKind.Operator:
        mode*: OperatorMode
        opKind*: OperatorKind
        subPackets*: seq[Packet]



func hexToBin(hex: string): string =
  var nr: int
  discard parseHex(hex, nr)
  fmt"{nr:04b}"

func hexToBin(hex: char): string =
  hexToBin $(hex)

func binToInt(bin: string): int =
  var nr: int
  discard parseBin(bin, nr)
  nr

func binToInt64(bin: string): int64 =
  var nr: int64
  discard parseBin(bin, nr)
  nr



# forward declaration of parsing functions
proc parseBitsPacket*(packetHex: string): Packet
proc parsePacket(binary: var string): tuple[parsed:int, packet:Packet]
proc parseHeader(binary: var string): tuple[parsed:int, header:PacketHeader]
proc parseLiteral(binary: var string): tuple[parsed:int, value:int64]
proc parseOperator(binary: var string): tuple[parsed:int, mode:OperatorMode, subPackets:seq[Packet]]



proc parseBitsPacket(packetHex: string): Packet =
  echo "parsing bits packet: ", packetHex
  echo "binary: ", packetHex.items.toSeq().map(hexToBin).join(",")
  var binary = packetHex.items.toSeq().map(hexToBin).join()
  parsePacket(binary).packet



func packetKindToOperatorKind(header: PacketHeader): OperatorKind =
  case header.typeId:
    of TypeId.Sum:          OperatorKind.Sum
    of TypeId.Product:      OperatorKind.Product
    of TypeId.Minimum:      OperatorKind.Minimum
    of TypeId.Maximum:      OperatorKind.Maximum
    of TypeId.GreaterThan:  OperatorKind.GreaterThan
    of TypeId.LessThan:     OperatorKind.LessThan
    of TypeId.Equal:        OperatorKind.Equal
    else: raise newException(ValueError, "error in input data")

proc parsePacket(binary: var string): tuple[parsed:int, packet:Packet] =
  echo "PACKET, starting at: ", binary
  let (headerLength, header) = parseHeader(binary)

  case header.typeId:
    of TypeId.Literal:
      let (literalLength, value) = parseLiteral(binary)
      (
        parsed: headerLength + literalLength,
        packet: Packet(
          header: header,
          kind: PacketKind.Literal,
          value: value
        )
      )

    else:
      let (opLength, mode, subPackets) = parseOperator(binary)
      (
        parsed: headerLength + opLength,
        packet: Packet(
          header: header,
          kind: PacketKind.Operator,
          mode: mode,
          opKind: header.packetKindToOperatorKind(),
          subPackets: subPackets
        )
      )

proc parseHeader(binary: var string): tuple[parsed:int, header:PacketHeader] =
  echo " HEADER, starting at: ", binary
  let
    version = binary[0..<3].binToInt()
    typeId = binary[3..<6].binToInt()

  # advance past header
  binary = binary[6 ..< binary.len]

  echo fmt"  version: ", version
  echo fmt"  typeId: ", typeId.TypeId
  (
    parsed: 6,
    header: PacketHeader(
      version: version,
      typeId: typeId.TypeId
    )
  )

proc parseLiteral(binary: var string): tuple[parsed:int, value:int64] =
  echo " LITERAL, starting at: ", binary
  var
    literal = ""
    parsed = 0
    isLast = false

  while not isLast:
    isLast = binary[0] == '0'
    literal &= binary[1..4]
    parsed += 5

    # advance past value
    binary = binary[5 ..< binary.len]

  echo "  literal: ", literal
  echo "  value: ", literal.binToInt64()

  #let
  #  literalLength = literal.len * 5 + 6 # include length of literal's header (version and type id)
  #  rem = literalLength / 4
  #  padding = rem.ceil.int * 4 - literalLength
  #
  #echo "  padding: ", padding
  #
  ## advance past padding
  #if padding > 0:
  #  binary = binary[padding ..< binary.len]

  (
    parsed: parsed,
    value: literal.binToInt64()
  )

proc parseOperator(binary: var string): tuple[parsed:int, mode:OperatorMode, subPackets:seq[Packet]] =
  echo " OPERATOR, starting at: ", binary
  var
    parsed = 0
    subPackets: seq[Packet]
  let
    lengthTypeId = binary[0]
    mode = if lengthTypeId == '0': Zero else: One

  case mode:
    of Zero:
      echo "  operator mode 0"
      let subPacketDataLength = binary[1..15].binToInt()
      echo "  subPacketDataLength: ", subPacketDataLength

      # advance past operator header
      binary = binary[16 ..< binary.len]
      parsed += 16

      #let
      #  beforeSubPackets = binary
      #  rem = subPacketDataLength / 4
      #  padding = rem.ceil.int * 4 - subPacketDataLength
      #  totalSubLength = subPacketDataLength + padding
      #echo "  padding ", padding
      var subPacketDataParsed = 0

      while subPacketDataParsed < subPacketDataLength:
        let (subPacketLength, subPacket) = parsePacket(binary)
        subPacketDataParsed += subPacketLength
        echo "  parsed ", subPacketDataParsed, " out of ", subPacketDataLength, " total bits"
        subPackets &= subPacket

      parsed += subPacketDataParsed

      # advance past sub-packets
      #binary = beforeSubPackets[totalSubLength .. beforeSubPackets.len - 1]

      #if padding > 0:
      #  binary = binary[padding ..< binary.len]

    of One:
      echo "  operator mode 1"
      let subPacketCount = binary[1..11].binToInt()
      echo "  subPacketCount: ", subPacketCount

      # advance past operator header
      binary = binary[12 ..< binary.len]
      parsed += 12

      #let
      #  beforeSubPackets = binary
      #  rem = subPacketDataLength / 4
      #  padding = rem.ceil.int * 4 - subPacketDataLength
      #  totalSubLength = subPacketDataLength + padding

      for sp in 1..subPacketCount:
        let (subPacketLength, subPacket) = parsePacket(binary)
        parsed += subPacketLength
        subPackets &= subPacket

      # advance past sub-packets
      #binary = beforeSubPackets[totalSubLength .. beforeSubPackets.len - 1]

  (
    parsed: parsed,
    mode: mode,
    subPackets: subPackets
  )



# tests
when isMainModule:
  assert hexToBin("0") == "0000"
  assert hexToBin("9") == "1001"
  assert hexToBin("A") == "1010"
  assert hexToBin("F") == "1111"
