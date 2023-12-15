import std/[strformat, strutils, sequtils, sugar, tables, sets, options, math, algorithm]
import fusion/matching
import utils



type Lens = tuple
  focalLength: int
  label: string

proc solve*(input: string): int
proc hash*(input: string): int
proc applyInitSequence*(initSequence: seq[string]): seq[seq[Lens]]

tests:
  solve(readFile("test.txt")) == 145
  solve(readFile("input.txt")) == 246762



proc solve(input: string): int =
  let
    initSequence = input.split(",")
    hashMap = applyInitSequence(initSequence)

  var focusingPower = 0
  for box, lenses in hashMap:
    for slot, lens in lenses:
      focusingPower += (1 + box) * (1 + slot) * lens.focalLength

  focusingPower

#[ tests:
  hash("rn=1") == 30
  hash("cm-") == 253
  hash("qp=3") == 97
]#
proc hash(input: string): int =
  input
    .mapIt(it.ord)
    .foldl(((a + b) * 17) mod 256, 0)

proc applyInitSequence(initSequence: seq[string]): seq[seq[Lens]] =
  var hashMap = newSeqWith(256, newSeq[Lens]())

  for lensConfig in initSequence:
    [@label, @focalLength] := lensConfig.split({'=','-'})
    let
      lens = (
        focalLength: if focalLength.len > 0: focalLength.parseInt
                     else: 0,
        label: label
      )
      box = hash(label)
    var
      lenses = hashMap[box]
      existingLens = -1

    for i, l in lenses:
      if l.label == label:
        existingLens = i
        break

    # add lens to box
    if lensConfig.find('=') >= 0:
      if existingLens >= 0:
        lenses[existingLens] = lens
      else:
        lenses.add(lens)
    # remove lens from box
    elif existingLens >= 0:
      lenses.delete(existingLens..existingLens)

    # update hash map with new box infoprmation
    hashMap[box] = lenses

  hashMap
