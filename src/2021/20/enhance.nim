import std/[strformat, strutils, sequtils, sugar, tables, sets, options, math]
import fusion/matching



type
  EnhancementAlgorithm* = seq[int]
  Image* = seq[seq[int]]



func `$`*(img: Image): string =
  for y in 0 ..< img.len:
    for x in 0 ..< img[0].len:
      if img[y][x] == 1:
        result &= '#'
      else:
        result &= '.'
    result &= '\n'



func hue(c: char): int =
  if c == '#':
    1
  else:
    0

func parseEnhancementAlgorithm*(input: string): EnhancementAlgorithm =
  input
    .items()
    .toSeq()
    .map(hue)

func parseImage*(input: string): Image =
  var grid = newSeq[seq[int]]()

  for line in input.splitLines():
    var row = newSeq[int]()
    for c in line:
      row &= hue(c)

    grid &= row

  grid



proc enhance(algo: EnhancementAlgorithm, img: Image, step: int, prevInfValue: int): Image =
  var
    bordered = newSeqWith(img.len + 4, newSeq[int](img[0].len + 4))
    enhanced = newSeqWith(img.len + 2, newSeq[int](img[0].len + 2))

  for y in 0 ..< bordered.len:
    bordered[y][0] = prevInfValue
    bordered[y][1] = prevInfValue
    bordered[y][bordered[0].len-2] = prevInfValue
    bordered[y][bordered[0].len-1] = prevInfValue

  for x in 0 ..< bordered[0].len:
    bordered[0][x] = prevInfValue
    bordered[1][x] = prevInfValue
    bordered[bordered.len-2][x] = prevInfValue
    bordered[bordered.len-1][x] = prevInfValue

  for y in 0 ..< img.len:
    for x in 0 ..< img[0].len:
      let
        bx = x + 2
        by = y + 2
      bordered[by][bx] = img[y][x]

  let infinityValue = algo[ (step mod 2) * (algo.len - 1) ]

  for y in 0 ..< enhanced.len:
    for x in 0 ..< enhanced[0].len:
      let
        bx = x + 1
        by = y + 1
        source = @[
          bordered[by-1][bx-1], bordered[by-1][bx+0], bordered[by-1][bx+1],
          bordered[by+0][bx-1], bordered[by+0][bx+0], bordered[by+0][bx+1],
          bordered[by+1][bx-1], bordered[by+1][bx+0], bordered[by+1][bx+1],
        ]
        index = source.mapIt($it).join().parseBinInt()

      enhanced[y][x] = algo[index]

  let nextStep = step - 1
  if nextStep > 0:
    algo.enhance(enhanced, nextStep, infinityValue)
  else:
    enhanced

proc enhance*(algo: EnhancementAlgorithm, img: Image, enhancementLevels: int): Image =
  algo.enhance(img, enhancementLevels, 0)
