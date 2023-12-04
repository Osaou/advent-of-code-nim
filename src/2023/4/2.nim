import std/[strformat, strutils, sequtils, sugar, tables, sets, options, math, algorithm]
import fusion/matching
import utils


type CardScore = tuple
  id: int
  matches: int

func readCardScore(card: string): CardScore
func scoreCard(cardScores: seq[CardScore], card: CardScore): int



func solve*(input: string): int =
  let cards = input.split("\n")
  var
    cardScores = cards.map(readCardScore)
    amount = 0

  for card in cardScores:
    amount += scoreCard(cardScores, card)

  amount

func scoreCard(cardScores: seq[CardScore], card: CardScore): int =
  var amount = 1
  let
    idx = card.id - 1
    startIdx = idx + 1
    endIdx = idx + min(card.matches, cardScores.len - 1)

  if card.id < cardScores.len:
    for i in startIdx..endIdx:
      let card = cardScores[i]
      amount += scoreCard(cardScores, card)

  amount

func readCardScore(card: string): CardScore =
  [@id, @scratches] := card
    .split(":")

  [@key, @nrs] := scratches
    .split("|")
    .mapIt(it
      .strip()
      .split(" ")
      .filterIt(it != "")
      .map(parseInt)
      .sorted()
    )

  let matches = nrs
    .filter((x) => key.anyIt(it == x))
    .len

  return (
    id: id.replace("Card", "").strip.parseInt,
    matches: matches
  )



tests:
  # scoring
  readCardScore("Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53") == (id:1, matches:4)
  readCardScore("Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11") == (id:6, matches:0)
  # solves
  solve(readFile("test.txt")) == 30
  solve(readFile("input.txt")) == 11787590
