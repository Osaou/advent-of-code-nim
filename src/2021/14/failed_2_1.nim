import std/[strformat, strutils, sequtils, sugar, tables, sets, math, options]
import fusion/matching
import utils



func parseRules(rules: string): Table[string, Option[string]] =
  result = initTable[string, Option[string]]()
  for rule in rules.splitLines():
    [@pattern, @injection] := rule.split(" -> ")
    result[pattern] = some(injection)



func growPolymer(rules: Table[string, Option[string]], polymer: string): string =
  var inserts = newSeq[tuple[pos:int, element:string]]()

  for pos in 0 ..< polymer.len - 1:
    let
      sequence = polymer[pos .. pos+1]
      insertion = rules.getOrDefault(sequence, none[string]())
    case insertion:
      of Some(@element):
        inserts &= (pos:pos+1, element:element)

  result = polymer
  for index, (pos, element) in inserts:
    let finalPos = index + pos
    result = result[0 ..< finalPos] & element & result[finalPos .. result.len - 1]



proc solve*(input: string): int =
  [@polymerTemplate, @insertionRules] := input.split("\n\n")

  var polymer = polymerTemplate
  let polymerizationEngine = parseRules(insertionRules)

  for step in 1..40:
    polymer = polymerizationEngine.growPolymer(polymer)

  var elements = initCountTable[char]()
  for element in polymer:
    elements.inc(element)

  elements.largest().val - elements.smallest().val
