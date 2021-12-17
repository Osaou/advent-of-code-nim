import std/[strformat, strutils, sequtils, sugar, tables, sets, math, options]
import fusion/matching
import utils



type
  Polymer = object
    elements: CountTable[char]
    sequences: CountTable[string]

  RuleReplacements = tuple
    first, second: string
    injection: char



func parsePolymer(input: string): Polymer =
  result = Polymer(
    elements: initCountTable[char](),
    sequences: initCountTable[string]()
  )

  for element in input:
    result.elements.inc(element)

  for index in 0 ..< input.len - 1:
    let sequence = input[index] & input[index+1]
    result.sequences.inc(sequence)

func parseRules(rules: string): Table[string, Option[RuleReplacements]] =
  result = initTable[string, Option[RuleReplacements]]()

  for rule in rules.splitLines():
    [@pattern, @injection] := rule.split(" -> ")
    let
      first = pattern[0] & injection
      second = injection & pattern[1]

    result[pattern] = some((first:first, second:second, injection:injection[0]))



func growPolymer(polymer: Polymer, rules: Table[string, Option[RuleReplacements]]): Polymer =
  result = Polymer(
    elements: polymer.elements.dup(),
    sequences: initCountTable[string]()
  )

  for sequence, count in polymer.sequences:
    let rule = rules.getOrDefault(sequence, none[RuleReplacements]())
    case rule:
      of Some((@first, @second, @injection)):
        result.sequences.inc(first, count)
        result.sequences.inc(second, count)
        result.elements.inc(injection, count)



func solve*(input: string): int64 =
  [@polymerTemplate, @insertionRules] := input.split("\n\n")

  var polymer = parsePolymer(polymerTemplate)
  let rules = parseRules(insertionRules)

  for step in 1..40:
    polymer = polymer.growPolymer(rules)

  polymer.elements.largest().val - polymer.elements.smallest().val



tests:
  solve(readFile("test.txt")) == 2_188_189_693_529
  solve(readFile("input.txt")) == 2_437_698_971_143
