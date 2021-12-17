import std/[strformat, strutils, sequtils, sugar, tables, sets, math, options]
import fusion/matching
import utils



func parseRules(rules: string): Table[string, Option[string]] =
  result = initTable[string, Option[string]]()

  for rule in rules.splitLines():
    [@pattern, @injection] := rule.split(" -> ")
    result[pattern] = some(injection)



func growPolymer(polymer: string, rules: Table[string, Option[string]]): string =
  var inserts = newSeq[tuple[pos:int, element:string]]()

  for pos in 0 ..< polymer.len - 1:
    let
      sequence = polymer[pos .. pos+1]
      rule = rules.getOrDefault(sequence, none[string]())
    case rule:
      of Some(@element):
        inserts &= (pos:pos+1, element:element)

  result = polymer
  for index, (pos, element) in inserts:
    let finalPos = index + pos
    result = result[0 ..< finalPos] & element & result[finalPos .. result.len - 1]



func solve*(input: string): int64 =
  [@polymerTemplate, @insertionRules] := input.split("\n\n")

  var polymer = polymerTemplate
  let rules = parseRules(insertionRules)

  for step in 1..10:
    polymer = polymer.growPolymer(rules)

  var elements = initCountTable[char]()
  for element in polymer:
    elements.inc(element)

  elements.largest().val - elements.smallest().val



tests:
  solve(readFile("test.txt")) == 1588
  solve(readFile("input.txt")) == 2010
