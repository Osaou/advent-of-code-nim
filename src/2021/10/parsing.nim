import std/[strformat, options]
import fusion/matching
import utils

{.experimental: "caseStmtMacros".}



type
  ChunkType* = enum
    parenthesis     = "()"
    squareBrackets  = "[]"
    curluBrackets   = "{}"
    angleBrackets   = "<>"

  Chunk* = ref ChunkObj

  ChunkObj = object
    kind: ChunkType
    children: seq[Chunk]
    parent: Option[Chunk]
    closedCorrectly: bool

  NavigationLine* = object
    children: seq[Chunk]
    isIncomplete*: bool
    isCorrupted*: bool
    errorScore*: int64



func newChunk(opener: char, parent: Chunk): Chunk =
  let p =
    if parent == nil:
      none(Chunk)
    else:
      some(parent)
  case opener:
    of '(': Chunk(parent:p, children:newSeq[Chunk](0), closedCorrectly:false, kind:parenthesis)
    of '[': Chunk(parent:p, children:newSeq[Chunk](0), closedCorrectly:false, kind:squareBrackets)
    of '{': Chunk(parent:p, children:newSeq[Chunk](0), closedCorrectly:false, kind:curluBrackets)
    of '<': Chunk(parent:p, children:newSeq[Chunk](0), closedCorrectly:false, kind:angleBrackets)
    else: raise newException(ValueError, fmt"Unknown chunk opener type: {opener}")

func expectedClosingCharacter(chunk: Chunk): char =
  case chunk.kind:
    of parenthesis: ')'
    of squareBrackets: ']'
    of curluBrackets: '}'
    of angleBrackets: '>'

func incompleteErrorScore(chunk: Chunk): int64 =
  case chunk.kind:
    of parenthesis: 1
    of squareBrackets: 2
    of curluBrackets: 3
    of angleBrackets: 4

func corruptionErrorScore(illegalCharacter: char): int64 =
  case illegalCharacter:
    of ')': 3
    of ']': 57
    of '}': 1197
    of '>': 25137
    else: 0

func parseNavigationLine*(input: string): NavigationLine =
  var
    navigationLine = NavigationLine(
      children: newSeq[Chunk](0),
      isIncomplete: false,
      isCorrupted: false,
      errorScore: 0
    )
    current: Chunk = nil

  # parse input
  for index, character in input:
    case character
      of '(', '[', '{', '<':
        let opened = newChunk(character, current)
        current = opened

      of ')', ']', '}', '>':
        if character == current.expectedClosingCharacter():
          current.closedCorrectly = true
        else:
          navigationLine.isCorrupted = true
          navigationLine.errorScore = corruptionErrorScore(character)
          break

        case current.parent:
          of Some(@parent):
            current = parent
          of None():
            current = nil

      else:
        raise newException(ValueError, fmt"Unknown chunk character: {character}")

  # compute error score for incomplete lines
  if not navigationLine.isCorrupted and current != nil:
    var errorScore: int64 = 0
    block computeErrorScore:
      while true:
        errorScore *= 5
        errorScore += incompleteErrorScore(current)
        case current.parent:
          of Some(@parent):
            current = parent
          of None():
            break computeErrorScore

    navigationLine.isIncomplete = true
    navigationLine.errorScore = errorScore

  navigationLine
