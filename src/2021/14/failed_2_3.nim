import std/[strformat, strutils, sequtils, sugar, tables, sets, math, options]
import fusion/matching
import utils



type
  Polymer = ref PolymerObj
  PolymerObj = object
    element: char
    next: Polymer



func parsePolymer(str: string): Polymer =
  result = Polymer(element:str[0], next:nil)
  var current = result
  for element in str[1 ..< str.len]:
    current.next = Polymer(element:element, next:nil)
    current = current.next

func parseRules(rules: string): Table[string, Option[char]] =
  result = initTable[string, Option[char]]()
  for rule in rules.splitLines():
    [@pattern, @injection] := rule.split(" -> ")
    result[pattern] = some(injection[0])



proc growPolymer(polymer: var Polymer, rules: Table[string, Option[char]]) =
  var current = polymer
  while current.next != nil:
    let
      next = current.next
      sequence = current.element & next.element
      insertion = rules.getOrDefault(sequence, none[char]())
    case insertion:
      of Some(@element):
        let inserted = Polymer(element:element, next:next)
        current.next = inserted

    current = next



proc solve*(input: string): int =
  [@polymerTemplate, @insertionRules] := input.split("\n\n")

  var polymer = parsePolymer(polymerTemplate)
  let rules = parseRules(insertionRules)

  for step in 1..40:
    echo "running step ", step
    polymer.growPolymer(rules)
  echo "done "

  var elements = initCountTable[char]()
  var current = polymer
  while current != nil:
    elements.inc(current.element)
    current = current.next

  elements.largest().val - elements.smallest().val
