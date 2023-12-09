import std/[strformat, strutils, sequtils, sugar, tables, sets, options, math, algorithm]
import fusion/matching
import utils



type
  Node* = ref object
    left*, right*: string
  NodeDef = tuple
    self: string
    paths: Node

proc solve*(input: string): int
proc parseNetworkNode*(input: string): NodeDef



#[ tests:
  solve(readFile("test.txt")) == 2
  solve(readFile("test2.txt")) == 6
  solve(readFile("input.txt")) == 19783
]#
proc solve(input: string): int =
  [@t, @n] := input.split("\n\n")
  let
    turns = toSeq(t)
    nodes = n
      .split("\n")
      .map(parseNetworkNode)
    network = toTable(nodes)
    goal = "ZZZ"

  var
    currentNode = network["AAA"]
    steps = 0

  while true:
    for t in turns:
      steps += 1

      let nextNode = if t == 'L': currentNode.left else: currentNode.right
      if nextNode == goal:
        return steps

      currentNode = network[nextNode]

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
