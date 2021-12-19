import std/[strformat, strutils, sequtils, parseutils, sugar, tables, sets, math, algorithm]
import fusion/matching
import utils



type SnailfishNumber = string



proc extractPair(partial: string): tuple[left,right:int, parsed:int] =
  var
    values = newSeq[string](2)
    current = 0

  for index, c in partial:
    if c.isDigit():
      values[current] &= c
    elif c == ',':
      current = 1
    elif c == ']':
      return (
        left: values[0].parseInt(),
        right: values[1].parseInt(),
        parsed: index + 1
      )

  raise newException(ValueError, "invalid snailfish number")

proc explodeLeft(partial: string, exploded: int): string =
  let rev = partial.reversed()
  var start = -1
  for index, c in rev:
    # search for first number we can find
    if start < 0:
      if c.isDigit():
        start = index
    else:
      # when we find where that number ends, we can assemble a new string
      if not c.isDigit():
        let
          before = partial[0 ..< partial.len - index]
          value = rev[start ..< index].reversed().join().parseInt()
          after = partial[partial.len - start ..< partial.len]
        return fmt"{before}{value + exploded}{after}"

  partial

proc explodeRight(partial: string, exploded: int): string =
  var start = -1
  for index, c in partial:
    # search for first number we can find
    if start < 0:
      if c.isDigit():
        start = index
    else:
      # when we find where that number ends, we can assemble a new string
      if not c.isDigit():
        let
          before = partial[0 ..< start]
          value = partial[start ..< index].parseInt()
          after = partial[index ..< partial.len]
        return fmt"{before}{value + exploded}{after}"

  partial

proc explode(nr: SnailfishNumber): tuple[didExplode:bool, nr:SnailfishNumber] =
  var nested = 0
  for index, c in nr:
    if c == '[':
      nested += 1
    elif c == ']':
      nested -= 1

    if nested > 4:
      let
        (left, right, parsed) = extractPair(nr[index ..< nr.len])
        before = explodeLeft(nr[0 ..< index], left)
        after = explodeRight(nr[index+parsed ..< nr.len], right)

      return (didExplode:true, nr:SnailfishNumber(fmt"{before}0{after}"))

  (didExplode:false, nr:nr)



proc split(nr: SnailfishNumber): tuple[didSplit:bool, nr:SnailfishNumber] =
  var start = -1
  for index, c in nr:
    # search for first number we can find
    if start < 0:
      if c.isDigit():
        start = index
    else:
      # when we find where that number ends, we can check if needs to be split
      if not c.isDigit():
        if index - start <= 1:
          # does not need to be split, restart search
          start = -1
        else:
          let
            before = nr[0 ..< start]
            value = nr[start ..< index].parseInt()
            after = nr[index ..< nr.len]
            half = value / 2
            left = half.floor().int
            right = half.ceil().int

          return (didSplit:true, nr:SnailfishNumber(fmt"{before}[{left},{right}]{after}"))

  (didSplit:false, nr:nr)



proc reduce(nr: SnailfishNumber): SnailfishNumber =
  result = nr
  var iteration = 1
  var lastEvent = "after addition"

  while true:
    #echo iteration, ": ", result, " <- ", lastEvent
    iteration += 1

    #if iteration > 5:
    #  return

    let (didExplode, explodedNr) = result.explode()
    if didExplode:
      #stdout.write " <- explodes"
      lastEvent = "after explode"
      result = explodedNr
      continue

    let (didSplit, splitNr) = result.split()
    if didSplit:
      #stdout.write " <- splits"
      lastEvent = "after split"
      result = splitNr
      continue

    return

proc `+`(a, b: SnailfishNumber): SnailfishNumber =
  let sum: SnailfishNumber = fmt"[{a},{b}]"
  sum.reduce()

proc magnitude(nr: SnailfishNumber): tuple[parsed:int, value:int] =
  if nr[0] == '[':
    let
      (parsedLeft, left) = magnitude(nr[1 ..< nr.len])
      (parsedRight, right) = magnitude(nr[1+parsedLeft+1 ..< nr.len])

    #echo fmt"adding  3*left + 2*right  ==  3*{left} + 2*{right}  ==  ", 3*left + 2*right
    (       # [ + LLLLLLLLLL + , + RRRRRRRRRRR + ]
      parsed: 1 + parsedLeft + 1 + parsedRight + 1,
      value: 3*left + 2*right
    )

  else:
    var value: int
    let intLength = parseSaturatedNatural(nr, value)

    (
      parsed: intLength,
      value: value
    )



proc solve*(input: string): int =
  input
    .splitLines()
    .mapIt(it.SnailfishNumber)
    .foldl(a + b)
    .magnitude()
    .value



tests:
  # extractPair
  "[9,8],1],2],3],4]".extractPair() == (left:9, right:8, parsed:5)
  "[13,20]]]]]".extractPair() == (left:13, right:20, parsed:7)
  # explode left
  "[9,8],1],2],3],4]".explodeLeft(3) == "[9,8],1],2],3],7]"
  "[9,8],1],2],3],4]".explodeLeft(13) == "[9,8],1],2],3],17]"
  "[13,20]]]]]".explodeLeft(1) == "[13,21]]]]]"
  "[13,20]]]]]".explodeLeft(100) == "[13,120]]]]]"
  # explode right
  "[1,8],1],2],3],4]".explodeRight(3) == "[4,8],1],2],3],4]"
  "[9,8],1],2],3],4]".explodeRight(10) == "[19,8],1],2],3],4]"
  "[[[[1,9],2],3],4]".explodeRight(3) == "[[[[4,9],2],3],4]"
  "[[[[1,9],2],3],4]".explodeRight(300) == "[[[[301,9],2],3],4]"
  # explode
  SnailfishNumber("[[[[[9,8],1],2],3],4]").explode().nr == SnailfishNumber("[[[[0,9],2],3],4]")
  SnailfishNumber("[7,[6,[5,[4,[3,2]]]]]").explode().nr == SnailfishNumber("[7,[6,[5,[7,0]]]]")
  SnailfishNumber("[[6,[5,[4,[3,2]]]],1]").explode().nr == SnailfishNumber("[[6,[5,[7,0]]],3]")
  SnailfishNumber("[[3,[2,[1,[7,3]]]],[6,[5,[4,[3,2]]]]]").explode().nr == SnailfishNumber("[[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]")
  SnailfishNumber("[[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]").explode().nr == SnailfishNumber("[[3,[2,[8,0]]],[9,[5,[7,0]]]]")
  # split
  SnailfishNumber("[10,0]").split().nr == SnailfishNumber("[[5,5],0]")
  SnailfishNumber("[11,0]").split().nr == SnailfishNumber("[[5,6],0]")
  SnailfishNumber("[0,12]").split().nr == SnailfishNumber("[0,[6,6]]")
  # add
  SnailfishNumber("[1,2]") + SnailfishNumber("[[3,4],5]") == SnailfishNumber("[[1,2],[[3,4],5]]")
  SnailfishNumber("[[[[4,3],4],4],[7,[[8,4],9]]]") + SnailfishNumber("[1,1]") == SnailfishNumber("[[[[0,7],4],[[7,8],[6,0]]],[8,1]]")
  @["[1,1]", "[2,2]", "[3,3]", "[4,4]"].mapIt(it.SnailfishNumber).foldl(a + b) == SnailfishNumber("[[[[1,1],[2,2]],[3,3]],[4,4]]")
  @["[1,1]", "[2,2]", "[3,3]", "[4,4]", "[5,5]"].mapIt(it.SnailfishNumber).foldl(a + b) == SnailfishNumber("[[[[3,0],[5,3]],[4,4]],[5,5]]")
  @["[1,1]", "[2,2]", "[3,3]", "[4,4]", "[5,5]", "[6,6]"].mapIt(it.SnailfishNumber).foldl(a + b) == SnailfishNumber("[[[[5,0],[7,4]],[5,5]],[6,6]]")
  SnailfishNumber("[[[[0,7],4],[15,[0,13]]],[1,1]]") == SnailfishNumber("[[[[0,7],4],[15,[0,13]]],[1,1]]")
  # example homework assignment
  readFile("test.txt").splitLines().mapIt(it.SnailfishNumber).foldl(a + b) == SnailfishNumber("[[[[6,6],[7,6]],[[7,7],[7,0]]],[[[7,7],[7,7]],[[7,8],[9,9]]]]")
  # final tests
  solve(readFile("test.txt")) == 4140
  solve(readFile("input.txt")) == 4289
