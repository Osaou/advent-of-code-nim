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
    enhanced50x = algorithm.enhance(original, 50)

  #echo "original image: \n", original
  #echo "1x enhance: \n", enhanced1x
  #echo "50x enhance: \n", enhanced50x

  enhanced50x.foldl(a + b.sum(), 0)



tests:
  solve(readFile("test.txt")) == 3351
  solve(readFile("input.txt")) == 18395
