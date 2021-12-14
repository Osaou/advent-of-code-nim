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
  Polymer = ref PolymerObj
  PolymerObj = object
    element: string
    next: Polymer

  RuleReplacements = tuple
    first, second: string



func parsePolymer(str: string): Polymer =
  result = Polymer(element:str[0] & str[1], next:nil)
  var current = result
  for index in 1 ..< str.len - 1:
    let element = str[index] & str[index+1]
    current.next = Polymer(element:element, next:nil)
    current = current.next

func parseRules(rules: string): Table[string, Option[RuleReplacements]] =
  result = initTable[string, Option[RuleReplacements]]()
  for rule in rules.splitLines():
    [@pattern, @injection] := rule.split(" -> ")
    let
      first = pattern[0] & injection
      second = injection & pattern[1]
    result[pattern] = some((first:first, second:second))



proc growPolymer(polymer: var Polymer, rules: Table[string, Option[RuleReplacements]]): Polymer =
  result = polymer
  var
    previous: Polymer = nil
    current = polymer

  while current != nil:
    let
      next = current.next
      insertion = rules.getOrDefault(current.element, none[RuleReplacements]())
    case insertion:
      of Some(@replacements):
        let
          second = Polymer(element:replacements.second, next:next)
          first = Polymer(element:replacements.first, next:second)
        current = second

        if previous != nil:
          previous.next = first
        else:
          result = first

    previous = current
    current = next



# main
proc logic*(input: string): int =
  [@polymerTemplate, @insertionRules] := input.split("\n\n")

  var polymer = parsePolymer(polymerTemplate)
  let rules = parseRules(insertionRules)

  #stdout.write "Polymer before:"
  #var p = polymer
  #while p != nil:
  #  stdout.write " "
  #  stdout.write p.element
  #  p = p.next
  #echo ""

  for step in 1..23:
    echo "running step ", step
    polymer = polymer.growPolymer(rules)
  echo "done "

  #stdout.write "Polymer after:"
  #p = polymer
  #while p != nil:
  #  stdout.write " "
  #  stdout.write p.element
  #  p = p.next
  #echo ""

  var elements = initCountTable[char]()
  var current = polymer
  while true:
    elements.inc(current.element[0])
    let next = current.next

    if next == nil:
      elements.inc(current.element[1])
      break
    else:
      current = next

  elements.largest().val - elements.smallest().val
