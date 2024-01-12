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
  RxInputTrigger = tuple
    name: string
    triggered: bool
    clicks: int

proc solve*(input: string): int
proc parse(input: string): TableRef[string, Module]
proc pressButton(modules: TableRef[string, Module], rxInputs: var seq[RxInputTrigger])
proc processSignal(signal: Signal, queue: var HeapQueue[Signal], modules: TableRef[string, Module])

tests:
  solve(readFile("input.txt")) == 238920142622879



proc solve(input: string): int =
  let modules = input.parse()
  var rxInputs = newSeq[RxInputTrigger]()

  # inspecting the input data, "rx" is a conjunction module, meaning ITS input modules all need to have a high signals sent,
  # ...then it's simply a matter of least common multiple to figure out how many total clicks it will take.
  for name1, m1 in modules.pairs:
    if m1.outputs.contains("rx"):
      for name2, m2 in modules.pairs:
        if m2.outputs.contains(name1):
          rxInputs.add((name2, false, 0).RxInputTrigger)

  while true:
    var allTriggered = true
    for i, input in rxInputs:
      if not input.triggered:
        allTriggered = false
        rxInputs[i].clicks += 1

    if allTriggered:
      break

    pressButton(modules, rxInputs)

  rxInputs
    .mapIt(it.clicks)
    .lcm

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

proc pressButton(modules: TableRef[string, Module], rxInputs: var seq[RxInputTrigger]) =
  let broadcaster = modules["broadcaster"]
  var queue = [(Low, broadcaster, "broadcaster").Signal].toHeapQueue

  while queue.len > 0:
    let signal = queue.pop()

    if signal.pulse == High:
      for i, input in rxInputs:
        if input.name == signal.source.name:
          rxInputs[i].triggered = true

    processSignal(signal, queue, modules)

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
