import std/[strformat, strutils, sequtils, sugar, tables, sets, options, math, algorithm, heapqueue]
import fusion/matching
import utils



type
  Pulse = enum
    Low
    High
  Signal = tuple
    pulse: Pulse
    source: Module
    target: string
  ModuleKind = enum
    Broadcaster
    FlipFlop
    Conjunction
  Module = ref object
    name: string
    outputs: seq[string]
    case kind: ModuleKind
    of Broadcaster:
      discard
    of FlipFlop:
      on: bool
    of Conjunction:
      inputs: TableRef[string, Pulse]

proc solve*(input: string): int
proc parse(input: string): TableRef[string, Module]
proc pressButton(modules: TableRef[string, Module]): tuple[lo, hi: int]
proc processSignal(signal: Signal, queue: var HeapQueue[Signal], modules: TableRef[string, Module])

tests:
  solve(readFile("test.txt")) == 32000000
  solve(readFile("test2.txt")) == 11687500
  solve(readFile("input.txt")) == 712543680



proc solve(input: string): int =
  let modules = input.parse()
  var
    lowCount = 0
    highCount = 0

  for i in 1..1000:
    let (lo, hi) = pressButton(modules)
    lowCount += lo
    highCount += hi

  lowCount * highCount

proc parse(input: string): TableRef[string, Module] =
  var modules = newTable[string, Module]()

  for m in input.splitLines:
    [@N, @O] := m.split(" -> ")
    let
      outputs = O.split(", ")
      (name, module) =
        if N == "broadcaster":
          (N, Module(name:N, outputs:outputs, kind:Broadcaster))
        else:
          let
            kind = N[0]
            name = N[1..^1]

          if kind == '%':
            (name, Module(name:name, outputs:outputs, kind:FlipFlop, on:false))
          else:
            (name, Module(name:name, outputs:outputs, kind:Conjunction, inputs:newTable[string, Pulse]()))

    modules[name] = module

  for sourceName, sourceModule in modules.mpairs:
    for targetName in sourceModule.outputs:
      let targetModule = modules.getOrDefault(targetName, nil)
      if targetModule != nil and targetModule.kind == Conjunction:
        targetModule.inputs[sourceName] = Low

  modules

proc pressButton(modules: TableRef[string, Module]): tuple[lo, hi: int] =
  let broadcaster = modules["broadcaster"]
  var
    queue = [(Low, broadcaster, "broadcaster").Signal].toHeapQueue
    lowCount = 0
    highCount = 0

  while queue.len > 0:
    let signal = queue.pop()

    case signal.pulse
    of Low: lowCount += 1
    of High: highCount += 1

    processSignal(signal, queue, modules)

  (lowCount, highCount)

proc processSignal(signal: Signal, queue: var HeapQueue[Signal], modules: TableRef[string, Module]) =
  var
    (pulse, sourceModule, targetName) = signal
    targetModule = modules.getOrDefault(targetName, nil)

  if targetModule == nil:
    return

  var relayed = none[Pulse]()

  case targetModule.kind
  of Broadcaster:
    relayed = some(pulse)

  of FlipFlop:
    if pulse == Low:
      if targetModule.on:
        targetModule.on = false
        relayed = some(Low)
      else:
        targetModule.on = true
        relayed = some(High)

  of Conjunction:
    targetModule.inputs[sourceModule.name] = pulse
    relayed = if pulse == High and
                 targetModule.inputs.values.toSeq.allIt(it == High): some(Low)
              else: some(High)

  if relayed.isSome:
    for target in targetModule.outputs:
      queue.push((relayed.get(), targetModule, target).Signal)
