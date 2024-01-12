import std/[strformat, strutils, sequtils, sugar, tables, sets, options, math, algorithm]
import fusion/matching
import utils



type
  RuleType = enum
    Defaulted
    Checked
  Rule = ref object
    case kind: RuleType
    of Defaulted:
      default: string
    of Checked:
      param: string
      cmp: char
      value: int
      leadsTo: string
  Workflow = ref object
    name: string
    rules: seq[Rule]
  PartRating = tuple
    x,m,a,s: int
  Result = tuple
    accepted: bool
    part: PartRating

proc solve*(input: string): int
proc parseWorkflows(W: string): TableRef[string, Workflow]
proc parseRule(R: string): Rule
proc parseParts(P: string): seq[PartRating]
proc apply(workflows: TableRef[string, Workflow], part: PartRating): Result
proc compare(rule: Rule, part: PartRating): string
proc param(part: PartRating, param: string): int

tests:
  solve(readFile("test.txt")) == 19114
  solve(readFile("input.txt")) == 406849



proc solve(input: string): int =
  [@W, @P] := input.split("\n\n")
  let
    workflows = parseWorkflows(W)
    parts = parseParts(P)

  parts
    .mapIt(workflows.apply(it))
    .filterIt(it.accepted)
    .mapIt(it.part)
    .mapIt(it.x + it.m + it.a + it.s)
    .sum

proc parseWorkflows(W: string): TableRef[string, Workflow] =
  var workflows = newTable[string, Workflow]()

  for flow in W.splitLines:
    [@name, @R] := flow
      .replace("}", "")
      .split("{")

    let rules = R
      .split(",")
      .map(parseRule)

    workflows[name] = Workflow(name:name, rules:rules)

  workflows

proc parseRule(R: string): Rule =
  if R.contains(":"):
    [@check, @leadsTo] := R.split(":")
    let cmp = check[1]
    [@param, @value] := check
      .replace("<", "|")
      .replace(">", "|")
      .split("|")

    return Rule(kind:Checked, param:param, cmp:cmp, value:value.parseInt, leadsTo:leadsTo)

  return Rule(kind:Defaulted, default:R)

proc parseParts(P: string): seq[PartRating] =
  collect:
    for part in P.splitLines:
      [@x,@m,@a,@s] := part[1..^2]
        .split(",")
        .mapIt(it[2..^1])
        .map(parseInt)
      ( x, m, a, s).PartRating

proc apply(workflows: TableRef[string, Workflow], part: PartRating): Result =
  var workflow = workflows["in"]

  while workflow != nil:
    for rule in workflow.rules:
      let outcome = rule.compare(part)
      case outcome
      of "A":
        return (true, part).Result
      of "R":
        return (false, part).Result
      else:
        if outcome.len > 0:
          workflow = workflows[outcome]
          break

proc compare(rule: Rule, part: PartRating): string =
  case rule.kind
  of Defaulted:
    return rule.default
  of Checked:
    let param = part.param(rule.param)
    let check = if rule.cmp == '<': param < rule.value
                else: param > rule.value
    if check:
      return rule.leadsTo

    return ""

proc param(part: PartRating, param: string): int =
  case param
  of "x": part.x
  of "m": part.m
  of "a": part.a
  of "s": part.s
  else: 0
