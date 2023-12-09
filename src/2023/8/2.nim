import std/[strformat, strutils, sequtils, sugar, tables, sets, options, math, algorithm]
import fusion/matching
import elvis
import utils



type
  Node* = ref object
    left*, right*: string
  NodeDef = tuple
    self: string
    paths: Node

proc solve*(input: string): int
proc parseNetworkNode*(input: string): NodeDef
proc solveSingleGhost(turns: seq[char], network: Table[string, Node], start: Node): int



#[ tests:
  solve(readFile("test3.txt")) == 6
  solve(readFile("input.txt")) == 9177460370549
]#
proc solve(input: string): int =
  [@t, @n] := input.split("\n\n")
  let
    turns = toSeq(t)
    nodes = n
      .split("\n")
      .map(parseNetworkNode)
    network = toTable(nodes)

  nodes
    .filterIt(it.self[2] == 'A')
    .mapIt(it.paths)
    .mapIt(solveSingleGhost(turns, network, it))
    .lcm

proc solveSingleGhost(turns: seq[char], network: Table[string, Node], start: Node): int =
  var
    currentNode = start
    steps = 0

  while true:
    for t in turns:
      let nextNode = t == 'L' ? currentNode.left ! currentNode.right
      currentNode = network[nextNode]

      steps += 1
      if nextNode[2] == 'Z':
        return steps

  0

#[ tests:
  parseNetworkNode("KCP = (DMG, QRV)").self == "KCP"
  parseNetworkNode("KCP = (DMG, QRV)").paths.left == "DMG"
  parseNetworkNode("KCP = (DMG, QRV)").paths.right == "QRV"
]#
proc parseNetworkNode(input: string): NodeDef =
  [@self, @rest] := input.split(" = (")
  [@left, @right] := rest.split(", ")
  (self, Node(left: left, right: right[0..2]))
