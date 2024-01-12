import std/[strformat, strutils, sequtils, sugar, tables, sets, options, math, algorithm]
import fusion/matching
import utils



type
  RuleType = enum
    Defaulted
    Checked
  PartType = enum
    X,M,A,S
  Operator = enum
    GreaterThan
    LessThan
  Rule = ref object
    case kind: RuleType
    of Defaulted:
      default: string
    of Checked:
      param: PartType
      operator: Operator
      value: int
      leadsTo: string
  Workflow = ref object
    name: string
    rules: seq[Rule]
  PartRange = tuple
    x,m,a,s: Slice[int]
  CheckedRangeType = enum
    Accepted
    Rejected
    Split
  CheckedRange = ref object
    case kind: CheckedRangeType
    of Accepted:
      discard
    of Rejected:
      discard
    of Split:
      accepted: PartRange
      rejected: PartRange



proc solve*(input: string): int
proc parseWorkflows(W: string): TableRef[string, Workflow]
proc parseRule(R: string): Rule
proc apply(workflows: TableRef[string, Workflow], ranges: PartRange, destination: string): int
proc compare(ranges: PartRange, rule: Rule): CheckedRange
proc combos(ranges: PartRange): int
proc with(ranges: PartRange, param: PartType, r: Slice[int]): PartRange

tests:
  solve(readFile("test.txt")) == 167409079868000
  solve(readFile("input.txt")) == 138625360533574



proc solve(input: string): int =
  [@W, @P] := input.split("\n\n")
  let
    workflows = parseWorkflows(W)
    ranges = (
      x: 1 .. 4000,
      m: 1 .. 4000,
      a: 1 .. 4000,
      s: 1 .. 4000,
    ).PartRange

  workflows.apply(ranges, "in")

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
    let
      cmp = check[1]
      operator = if cmp == '<': LessThan
                 else: GreaterThan
    [@P, @value] := check
      .replace("<", "|")
      .replace(">", "|")
      .split("|")
    let param = case P
      of "x": X
      of "m": M
      of "a": A
      else: S

    Rule(kind:Checked, param:param, operator:operator, value:value.parseInt, leadsTo:leadsTo)
  else:
    Rule(kind:Defaulted, default:R)

proc apply(workflows: TableRef[string, Workflow], ranges: PartRange, destination: string): int =
  case destination
  of "A":
    combos(ranges)
  of "R":
    0
  else:
    let workflow = workflows[destination]
    var
      currentRange = ranges
      sum = 0

    for rule in workflow.rules:
      case rule.kind
      of Defaulted:
        sum += workflows.apply(currentRange, rule.default)
      of Checked:
        let outcome = compare(currentRange, rule)
        case outcome.kind
        of Accepted:
          sum += workflows.apply(currentRange, rule.leadsTo)
        of Rejected:
          discard
        of Split:
          currentRange = outcome.rejected
          sum += workflows.apply(outcome.accepted, rule.leadsTo)

    sum

proc compare(ranges: PartRange, rule: Rule): CheckedRange =
  assert rule.kind == Checked

  let
    partRange = case rule.param
      of X: ranges.x
      of M: ranges.m
      of A: ranges.a
      of S: ranges.s
    rangeStart = partRange.a
    rangeEnd = partRange.b
    cmpValue = rule.value

  case rule.operator
  of GreaterThan:
    if rangeStart > cmpValue:
      CheckedRange(kind:Accepted)
    elif rangeEnd <= cmpValue:
      CheckedRange(kind:Rejected)
    else:
      CheckedRange(kind:Split,
        accepted: ranges.with(rule.param, cmpValue + 1 .. rangeEnd),
        rejected: ranges.with(rule.param, rangeStart .. cmpValue))
  of LessThan:
    if cmpValue <= rangeStart:
      CheckedRange(kind:Rejected)
    elif rangeEnd < cmpValue:
      CheckedRange(kind:Accepted)
    else:
      CheckedRange(kind:Split,
        accepted: ranges.with(rule.param, rangeStart .. cmpValue - 1),
        rejected: ranges.with(rule.param, cmpValue .. rangeEnd))

proc combos(ranges: PartRange): int =
  (ranges.x.b - ranges.x.a + 1) *
    (ranges.m.b - ranges.m.a + 1) *
    (ranges.a.b - ranges.a.a + 1) *
    (ranges.s.b - ranges.s.a + 1)

proc with(ranges: PartRange, param: PartType, r: Slice[int]): PartRange =
  var copy = (ranges.x, ranges.m, ranges.a, ranges.s).PartRange
  case param
  of X: copy.x = r
  of M: copy.m = r
  of A: copy.a = r
  of S: copy.s = r
  copy
