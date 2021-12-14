# imports
import std/[strformat, strutils, sequtils, sugar, tables, sets, math, options]
import fusion/matching
import utils

{.experimental: "caseStmtMacros".}



# tests
const
  expectedTestResult* = 2188189693529
  expectedRunResult* = 0



type Rule = tuple
  pattern: string
  injection: string



func parseRules(rules: string): seq[Rule] =
  result = newSeq[Rule]()
  for rule in rules.splitLines():
    [@pattern, @injection] := rule.split(" -> ")
    #result[pattern] = injection
    result &= (
      pattern: pattern,
      injection: pattern[0] & injection & pattern[1]
    )



func growPolymer(rules: seq[Rule], polymer: string): string =
  polymer.multiReplace(rules)
  #var inserts = newSeq[tuple[pos:int, element:string]]()

  #for pos in 0 ..< polymer.len - 1:
  #  let
  #    sequence = polymer[pos .. pos+1]
  #    insertion = rules.getOrDefault(sequence, none[string]())
  #  case insertion:
  #    of Some(@element):
  #      inserts &= (pos:pos+1, element:element)

  #result = polymer
  #for index, (pos, element) in inserts:
  #  let finalPos = index + pos
  #  result = result[0 ..< finalPos] & element & result[finalPos .. result.len - 1]



# main
proc logic*(input: string): int64 =
  [@polymerTemplate, @insertionRules] := input.split("\n\n")

  var polymer = polymerTemplate
  let polymerizationEngine = parseRules(insertionRules)

  #echo "before ", polymer
  for step in 1..40:
    echo "running step ", step
    polymer = polymerizationEngine.growPolymer(polymer)
  echo "after ", polymer.len

  var elements = initCountTable[char]()
  for element in polymer:
    elements.inc(element)

  elements.largest().val - elements.smallest().val
