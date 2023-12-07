import std/[strformat, strutils, sequtils, sugar, tables, sets, options, math, algorithm]
import fusion/matching
import utils



type
  HandType* = enum
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

proc parseHand*(input: string): Hand

#[ tests:
  parseType("AAAAA") == FiveOfAKind
  parseType("22222") == FiveOfAKind
  parseType("AA8AA") == FourOfAKind
  parseType("JJJJJ") == FiveOfAKind
  parseType("23332") == FullHouse
  parseType("TTT98") == ThreeOfAKind
  parseType("23432") == TwoPair
  parseType("A23A4") == OnePair
  parseType("23456") == HighCard
  parseType("KK677") == TwoPair
  parseType("KTJJT") == FourOfAKind
  parseType("T55J5") == FourOfAKind
  parseType("QQQJA") == FourOfAKind
]#
proc parseType*(cards: string): HandType

proc naiveHandType(table: CountTableRef[char]): HandType

#[ tests:
  handSorter(parseHand("33332 0"), parseHand("2AAAA 0")) < 0
  handSorter(parseHand("2AAAA 0"), parseHand("33332 0")) > 0
  handSorter(parseHand("77888 0"), parseHand("77788 0")) < 0
  handSorter(parseHand("KK677 0"), parseHand("KTJJT 0")) > 0
  handSorter(parseHand("T55J5 0"), parseHand("QQQJA 0")) > 0
  handSorter(parseHand("23455 0"), parseHand("J3455 0")) > 0
  handSorter(parseHand("23555 0"), parseHand("J3455 0")) < 0
  handSorter(parseHand("AAAAA 0"), parseHand("JJJJJ 0")) < 0
  handSorter(parseHand("JJJJJ 0"), parseHand("AAAAA 0")) > 0
]#
proc handSorter*(a,b: Hand): int

#[ tests:
  cardValue('J') == 1
  cardValue('2') == 2
  cardValue('T') == 10
  cardValue('Q') == 12
  cardValue('K') == 13
  cardValue('A') == 14
]#
proc cardValue*(card: char): int



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

  if table.len > 1:
    let jokerCount = table.getOrDefault('J', 0)
    if jokerCount > 0:
      table.del('J')
      let highCard = table.largest
      table[highCard.key] = highCard.val + jokerCount

  naiveHandType(table)

proc naiveHandType(table: CountTableRef[char]): HandType =
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
    @['J','2','3','4','5','6','7','8','9','T','Q','K','A'],
    @[ 1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 12, 13, 14 ]
  )
  .newTable

proc cardValue(card: char): int =
  valueMap[card]



tests:
  solve(readFile("test.txt")) == 5905
  solve(readFile("input.txt")) == 243101568
