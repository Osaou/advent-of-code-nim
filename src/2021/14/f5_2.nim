# imports
import std/[strformat, strutils, sequtils, sugar, tables, sets, math, options]
import fusion/matching
import utils

{.experimental: "caseStmtMacros".}



# tests
const
  expectedTestResult* = 2188189693529
  expectedRunResult* = 0



type
  PolymerNode = ref PolymerNodeObj
  PolymerNodeObj = object
    element: char
    next: PolymerNode

  Polymer = object
    root: PolymerNode
    size: int64



func parsePolymer(str: string): Polymer =
  let root = PolymerNode(element:str[0], next:nil)
  var current = root
  for element in str[1 ..< str.len]:
    current.next = PolymerNode(element:element, next:nil)
    current = current.next

  Polymer(root:root, size:str.len)

func parseRules(rules: string): Table[string, Option[char]] =
  result = initTable[string, Option[char]]()
  for rule in rules.splitLines():
    [@pattern, @injection] := rule.split(" -> ")
    result[pattern] = some(injection[0])



proc growPolymer(polymer: var Polymer, rules: Table[string, Option[char]]) =
  var current = polymer.root
  while current.next != nil:
    let
      next = current.next
      sequence = current.element & next.element
      insertion = rules.getOrDefault(sequence, none[char]())
    case insertion:
      of Some(@element):
        let inserted = PolymerNode(element:element, next:next)
        current.next = inserted
        polymer.size += 1

    current = next



# main
proc logic*(input: string): int =
  [@polymerTemplate, @insertionRules] := input.split("\n\n")

  var polymer = parsePolymer(polymerTemplate)
  let rules = parseRules(insertionRules)

  for step in 1..20:
    echo "running step ", step
    polymer.growPolymer(rules)
  echo "done, length is now: ", polymer.size

  var elements = initCountTable[char]()
  var current = polymer.root
  while current != nil:
    elements.inc(current.element)
    current = current.next

  elements.largest().val - elements.smallest().val
