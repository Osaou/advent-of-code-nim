import std/[strformat, strutils, sequtils, sugar, tables, sets, options, math, algorithm]
import fusion/matching
import utils



type
  HandType = enum
    HighCard
    OnePair
    TwoPair
    ThreeOfAKind
    FullHouse
    FourOfAKind
    FiveOfAKind
  Hand = tuple
    cards: string
    bid: int
    handType: HandType

proc parseHand(input: string): Hand
proc parseType(cards: string): HandType
proc handSorter(a,b: Hand): int
proc cardValue(card: char): int



proc solve*(input: string): int =
  let hands = input
    .split("\n")
    .map(parseHand)
    .sorted(handSorter, Descending)

  var winnings = 0
  for i, hand in hands:
    winnings += (i+1) * hand.bid

  winnings

proc parseHand(input: string): Hand =
  [@cards, @bid] := input.split(" ")
  (
    cards: cards,
    bid: parseInt(bid),
    handType: parseType(cards)
  )

proc parseType(cards: string): HandType =
  var table = newCountTable(cards.toSeq)

  case table.len
  of 1:
    FiveOfAKind
  of 2:
    if table.smallest().val == 1:
      FourOfAKind
    else:
      FullHouse
  of 3:
    if table.largest().val == 3:
      ThreeOfAKind
    else:
      TwoPair
  of 4:
    OnePair
  else:
    HighCard

proc handSorter(a,b: Hand): int =
  if a.handType != b.handType:
    return b.handType.ord - a.handType.ord

  for i in 0..<5:
    let
      ac = a.cards[i]
      bc = b.cards[i]
    if ac != bc:
      return bc.cardValue - ac.cardValue

  0

let valueMap = zip(
    @['2','3','4','5','6','7','8','9','T','J','Q','K','A'],
    @[ 2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14 ]
  )
  .toTable

proc cardValue(card: char): int =
  valueMap[card]



tests:
  parseType("AAAAA") == FiveOfAKind
  parseType("22222") == FiveOfAKind
  parseType("AA8AA") == FourOfAKind
  parseType("23332") == FullHouse
  parseType("TTT98") == ThreeOfAKind
  parseType("23432") == TwoPair
  parseType("A23A4") == OnePair
  parseType("23456") == HighCard
  parseType("KK677") == TwoPair
  parseType("KTJJT") == TwoPair
  parseType("T55J5") == ThreeOfAKind
  parseType("QQQJA") == ThreeOfAKind
  handSorter(parseHand("33332 0"), parseHand("2AAAA 0")) < 0
  handSorter(parseHand("2AAAA 0"), parseHand("33332 0")) > 0
  handSorter(parseHand("77888 0"), parseHand("77788 0")) < 0
  handSorter(parseHand("KK677 0"), parseHand("KTJJT 0")) < 0
  handSorter(parseHand("T55J5 0"), parseHand("QQQJA 0")) > 0
  cardValue('2') == 2
  cardValue('T') == 10
  cardValue('J') == 11
  cardValue('Q') == 12
  cardValue('K') == 13
  cardValue('A') == 14
  solve(readFile("test.txt")) == 6440
  solve(readFile("input.txt")) == 241344943
