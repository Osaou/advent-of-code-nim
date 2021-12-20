import std/[strformat, strutils, sequtils, sugar, tables, sets, options, math]
import fusion/matching
import utils
import enhance



proc solve*(input: string): int =
  [@enhancementAlgorithm, @image] := input.split("\n\n")
  let
    algorithm = enhancementAlgorithm.parseEnhancementAlgorithm()
    original = image.parseImage()
    #enhanced1x = algorithm.enhance(original, 1)
    enhanced2x = algorithm.enhance(original, 2)

  #echo "original image: \n", original
  #echo "1x enhance: \n", enhanced1x
  #echo "2x enhance: \n", enhanced2x

  enhanced2x.foldl(a + b.sum(), 0)



tests:
  solve(readFile("test.txt")) == 35
  solve(readFile("input.txt")) == 5339
