import std/[strformat, strutils, sequtils, parseutils, sugar, tables, sets, math, options]
import fusion/matching
import utils



type

  ElementKind = enum
    Literal
    Pair

  Leg = enum
    Irrelevant
    Left
    Right

  SnailfishNumber = ref SnailfishNumberObj
  SnailfishNumberObj = object
    parent: Option[SnailfishNumber]
    leg: Leg
    case kind: ElementKind:
      of Literal:
        value: int
      of Pair:
        left: SnailfishNumber
        right: SnailfishNumber



# construct

proc parseSnailfishNumber(snailfishNotation: string, parent: Option[SnailfishNumber], leg: Leg): tuple[parsed:int, nr:SnailfishNumber] =
  if snailfishNotation[0] == '[':
    var pair = SnailfishNumber(kind:Pair, parent:parent, leg:leg)
    let
      (parsedLeft, left) = parseSnailfishNumber(snailfishNotation[1 ..< snailfishNotation.len], some(pair), Left)
      (parsedRight, right) = parseSnailfishNumber(snailfishNotation[1+parsedLeft+1 ..< snailfishNotation.len], some(pair), Right)

    pair.left = left
    pair.right = right

    (       # [ + LLLLLLLLLL + , + RRRRRRRRRRR + ]
      parsed: 1 + parsedLeft + 1 + parsedRight + 1,
      nr: pair
    )

  else:
    var literal: int
    let intLength = parseSaturatedNatural(snailfishNotation, literal)

    (
      parsed: intLength,
      nr: SnailfishNumber(kind:Literal, parent:parent, leg:leg,
        value: literal
      )
    )

proc newSnailfishNumber(snailfishNotation: string): SnailfishNumber =
  parseSnailfishNumber(snailfishNotation, none[SnailfishNumber](), Irrelevant).nr

proc copy(source: SnailfishNumber, parent: Option[SnailfishNumber]): SnailfishNumber =
  case source.kind:
    of Pair:
      var duplicate = SnailfishNumber(kind:Pair, parent:parent, leg:source.leg)
      let
        left = copy(source.left, some(duplicate))
        right = copy(source.right, some(duplicate))

      duplicate.left = left
      duplicate.right = right

      return duplicate

    of Literal:
      return SnailfishNumber(kind:Literal, parent:parent, leg:source.leg,
        value: source.value
      )

proc copy(source: SnailfishNumber): SnailfishNumber =
  copy(source, none[SnailfishNumber]())



# equals and toString

proc `==`(a, b: SnailfishNumber): bool =
  if a.kind != b.kind:
    return false

  case a.kind:
    of Pair:
      a.left == b.left and
      a.right == b.right

    of Literal:
      a.value == b.value

proc `$`(nr: SnailfishNumber): string =
  case nr.kind:
    of Pair:
      let
        left = $nr.left
        right = $nr.right
      fmt"[{left},{right}]"

    of Literal:
      $nr.value



# explode

proc findLeftLiteralUpwards(nr: SnailfishNumber): Option[SnailfishNumber] =
  case nr.parent:
    of Some(@parent):
      assert parent.kind == Pair
      let leftNode = parent.left
      case leftNode.kind:
        of Literal:
          return some(leftNode)
        of Pair:
          return findLeftLiteralUpwards(parent)

    of None():
      return none[SnailfishNumber]()

proc findLeftLiteralDownwards(nr: SnailfishNumber): Option[SnailfishNumber] =
  case nr.kind:
    of Literal:
      return some(nr)
    of Pair:
      return findLeftLiteralDownwards(nr.left)

proc findRightLiteralUpwards(nr: SnailfishNumber, cameFrom: Leg): Option[SnailfishNumber] =
  case nr.parent:
    of Some(@parent):
      assert parent.kind == Pair
      let rightNode = parent.right
      case rightNode.kind:
        of Literal:
          return some(rightNode)
        of Pair:
          return findRightLiteralUpwards(parent, nr.leg)

    of None():
      case nr.kind:
        of Literal:
          raise newException(ValueError, "makes no sense with a root literal!")
        of Pair:
          if cameFrom == Left:
            return findLeftLiteralDownwards(nr.right)
          else:
            return none[SnailfishNumber]()

proc explode(nr: SnailfishNumber, hasExploded: bool, depth: int): tuple[didExplode:bool, nr:SnailfishNumber] =
  if hasExploded:
    return (didExplode:true, nr:nr)

  case nr.kind:
    of Pair:
      if depth >= 4 and nr.left.kind == Literal and nr.right.kind == Literal:
        #echo "will now explode: ", nr
        # increase literal to the left of us with our left value
        var leftLiteral = findLeftLiteralUpwards(nr)
        #if leftLiteral.isSome:
        #  #echo fmt"inc left: {leftLiteral.get().value} + {nr.left.value}"
        #  leftLiteral.get().value += nr.left.value
        case leftLiteral:
          of Some(@left):
            case left.kind:
              of Literal:
                echo fmt"adding {nr.left.value} to {left.value}"
                left.value += nr.left.value
              else:
                discard
          else:
            discard

        # increase literal to the right of us with our right value
        var rightLiteral = findRightLiteralUpwards(nr, Irrelevant)
        if rightLiteral.isSome:
          #echo fmt"inc right: {rightLiteral.get().value} + {nr.right.value}"
          rightLiteral.get().value += nr.right.value

        # replace ourselves with the literal 0
        let replaced = SnailfishNumber(kind:Literal, parent:nr.parent, leg:nr.leg,
          value: 0
        )

        (didExplode:true, nr:replaced)

      else:
        let
          (leftExplosion, left) = nr.left.explode(false, depth + 1)
          (rightExplosion, right) = nr.right.explode(leftExplosion, depth + 1)

        (
          didExplode: leftExplosion or rightExplosion,
          nr: SnailfishNumber(kind:Pair, parent:nr.parent, leg:nr.leg,
            left: left,
            right: right
          )
        )

    of Literal:
      (didExplode:false, nr:nr)

proc explode(nr: SnailfishNumber): SnailfishNumber =
  var dup = nr.copy()
  explode(dup, false, 0).nr



# split

proc split(nr: SnailfishNumber, hasSplit: bool): tuple[didSplit:bool, nr:SnailfishNumber] =
  if hasSplit:
    return (didSplit:true, nr:nr)

  case nr.kind:
    of Pair:
      let
        (leftSplit, left) = nr.left.split(false)
        (rightSplit, right) = nr.right.split(leftSplit)

      nr.left = left
      nr.right = right

      (didSplit:leftSplit or rightSplit, nr:nr)

    of Literal:
      if nr.value < 10:
        return (didSplit:false, nr:nr)

      var pair = SnailfishNumber(kind:Pair, parent:nr.parent, leg:nr.leg)
      let
        half = nr.value / 2
        left = SnailfishNumber(kind:Literal, value: half.floor().int, parent:some(pair), leg:Left)
        right = SnailfishNumber(kind:Literal, value: half.ceil().int, parent:some(pair), leg:Right)

      pair.left = left
      pair.right = right

      (didSplit:true, nr:pair)

proc split(nr: SnailfishNumber): SnailfishNumber =
  var dup = nr.copy()
  split(dup, false).nr



# reduce

proc reduce(nr: SnailfishNumber): SnailfishNumber =
  result = nr
  var iteration = 1
  var lastEvent = "after addition"

  while true:
    echo iteration, ": ", result, " <- ", lastEvent
    iteration += 1

    #if iteration > 5:
    #  return

    let (didExplode, explodedNr) = result.copy().explode(false, 0)
    if didExplode:
      #stdout.write " <- explodes"
      lastEvent = "after explode"
      result = explodedNr
      continue

    let (didSplit, splitNr) = result.copy().split(false)
    if didSplit:
      #stdout.write " <- splits"
      lastEvent = "after split"
      result = splitNr
      continue

    return



# add

proc `+`(a, b: SnailfishNumber): SnailfishNumber =
  let sum = SnailfishNumber(kind:Pair, parent:none[SnailfishNumber](), leg:Irrelevant,
    left: a,
    right: b
  )

  a.parent = some(sum)
  a.leg = Left

  b.parent = some(sum)
  b.leg = Right

  sum.reduce()



proc solve*(input: string): int =
  #echo "before:    ", newSnailfishNumber("[[[[0,7],4],[15,[0,13]]],[1,1]]")
  #echo "after:     ", newSnailfishNumber("[[[[0,7],4],[15,[0,13]]],[1,1]]").split()
  #echo "should be: ", newSnailfishNumber("[[[[0,7],4],[[7,8],[0,13]]],[1,1]]")
  #echo newSnailfishNumber("[[[[0,7],4],[15,[0,13]]],[1,1]]").split() == newSnailfishNumber("[[[[0,7],4],[[7,8],[0,13]]],[1,1]]")
  echo "got:      ", newSnailfishNumber("[[[[4,3],4],4],[7,[[8,4],9]]]") + newSnailfishNumber("[1,1]")
  echo "expected: ", newSnailfishNumber("[[[[0,7],4],[[7,8],[6,0]]],[8,1]]")
  0



tests:
  # constructor + stringify
  $newSnailfishNumber("[1,2]") == "[1,2]"
  $newSnailfishNumber("[[1,2],3]") == "[[1,2],3]"
  $newSnailfishNumber("[9,[8,7]]") == "[9,[8,7]]"
  $newSnailfishNumber("[[1,9],[8,5]]") == "[[1,9],[8,5]]"
  $newSnailfishNumber("[[[[1,2],[3,4]],[[5,6],[7,8]]],9]") == "[[[[1,2],[3,4]],[[5,6],[7,8]]],9]"
  $newSnailfishNumber("[[[9,[3,8]],[[0,9],6]],[[[3,7],[4,9]],3]]") == "[[[9,[3,8]],[[0,9],6]],[[[3,7],[4,9]],3]]"
  $newSnailfishNumber("[[[[1,3],[5,3]],[[1,3],[8,7]]],[[[4,9],[6,9]],[[8,2],[7,3]]]]") == "[[[[1,3],[5,3]],[[1,3],[8,7]]],[[[4,9],[6,9]],[[8,2],[7,3]]]]"

  # explode
  newSnailfishNumber("[[[[[9,8],1],2],3],4]").explode() == newSnailfishNumber("[[[[0,9],2],3],4]")
  newSnailfishNumber("[7,[6,[5,[4,[3,2]]]]]").explode() == newSnailfishNumber("[7,[6,[5,[7,0]]]]")
  newSnailfishNumber("[[6,[5,[4,[3,2]]]],1]").explode() == newSnailfishNumber("[[6,[5,[7,0]]],3]")
  newSnailfishNumber("[[3,[2,[1,[7,3]]]],[6,[5,[4,[3,2]]]]]").explode() == newSnailfishNumber("[[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]")
  newSnailfishNumber("[[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]").explode() == newSnailfishNumber("[[3,[2,[8,0]]],[9,[5,[7,0]]]]")

  # split
  newSnailfishNumber("10").split() == newSnailfishNumber("[5,5]")
  newSnailfishNumber("11").split() == newSnailfishNumber("[5,6]")
  newSnailfishNumber("12").split() == newSnailfishNumber("[6,6]")

  # add
  newSnailfishNumber("[1,2]") + newSnailfishNumber("[[3,4],5]") == newSnailfishNumber("[[1,2],[[3,4],5]]")
  newSnailfishNumber("[[[[4,3],4],4],[7,[[8,4],9]]]") + newSnailfishNumber("[1,1]") == newSnailfishNumber("[[[[0,7],4],[[7,8],[6,0]]],[8,1]]")
  @["[1,1]", "[2,2]", "[3,3]", "[4,4]"].map(newSnailfishNumber).foldl(a + b) == newSnailfishNumber("[[[[1,1],[2,2]],[3,3]],[4,4]]")
  @["[1,1]", "[2,2]", "[3,3]", "[4,4]", "[5,5]"].map(newSnailfishNumber).foldl(a + b) == newSnailfishNumber("[[[[3,0],[5,3]],[4,4]],[5,5]]")
  @["[1,1]", "[2,2]", "[3,3]", "[4,4]", "[5,5]", "[6,6]"].map(newSnailfishNumber).foldl(a + b) == newSnailfishNumber("[[[[5,0],[7,4]],[5,5]],[6,6]]")
  newSnailfishNumber("[[[[0,7],4],[15,[0,13]]],[1,1]]") == newSnailfishNumber("[[[[0,7],4],[15,[0,13]]],[1,1]]")
