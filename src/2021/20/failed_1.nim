import std/[strformat, strutils, sequtils, sugar, tables, sets, options, math]
import fusion/matching
import utils



type
  EnhancementAlgorithm = seq[int]
  Image = seq[seq[int]]



func `$`(img: Image): string =
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

func parseEnhancementAlgorithm(input: string): EnhancementAlgorithm =
  input
    .items()
    .toSeq()
    .map(hue)

func parseImage(input: string): Image =
  var grid = newSeq[seq[int]]()

  for line in input.splitLines():
    var row = newSeq[int]()
    for c in line:
      row &= hue(c)

    grid &= row

  grid



func addBorder(img: Image): Image =
  let rowBorder = newSeq[int](img[0].len + 2)

  var grid = newSeq[seq[int]]()
  grid &= rowBorder

  for y in 0 ..< img.len:
    var row = newSeq[int]()
    row &= 0
    for x in 0 ..< img[0].len:
      row &= img[y][x]
    row &= 0

    grid &= row

  grid &= rowBorder
  grid

func addBorder(img: Image, size: int): Image =
  var withBorder = img
  for i in 1..size:
    withBorder = addBorder(withBorder)

  withBorder



proc enhance(img: Image, algo: EnhancementAlgorithm): Image =
  var enhanced = newSeqWith(img.len, newSeq[int](img[0].len))

  for y in 1 ..< img.len - 1:
    for x in 1 ..< img[0].len - 1:
      let
        source = @[
          img[y-1][x-1], img[y-1][x+0], img[y-1][x+1],
          img[y+0][x-1], img[y+0][x+0], img[y+0][x+1],
          img[y+1][x-1], img[y+1][x+0], img[y+1][x+1],
        ]
        index = source.mapIt($it).join().parseBinInt()

      enhanced[y][x] = algo[index]

  enhanced.addBorder()



proc solve*(input: string): int =
  [@enhancementAlgorithm, @image] := input.split("\n\n")
  let
    algorithm = enhancementAlgorithm.parseEnhancementAlgorithm()
    original = image.parseImage().addBorder(2)
    enhanced1x = original.enhance(algorithm)
    enhanced2x = enhanced1x.enhance(algorithm)

  echo "original image: \n", original
  echo "1x enhance: \n", enhanced1x
  echo "2x enhance: \n", enhanced2x

  enhanced2x.foldl(a + b.sum(), 0)



tests:
  readFile("test.txt").items().toSeq().toHashSet().len == 3
  readFile("input.txt").items().toSeq().toHashSet().len == 3

  solve(readFile("test.txt")) == 35
