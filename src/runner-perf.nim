import std/os
import std/times
import std/random
import std/strformat
import std/sequtils
import cputicks
import elvis
import solution



const
  WARMUP_RUNS_COUNT = 100
  WARMUP_MAX_TIMEOUT_SEC = 5
  PERF_TEST_RUNS_COUNT = 1000
  PERF_TEST_MAX_TIMEOUT_SEC = 10

type
  Reading = tuple
    start: float
    stop: float



echo "TEST: ", splitFile(paramStr(0))[1]

let input = readFile(paramStr(1))
var readings = newSeq[Reading](WARMUP_RUNS_COUNT)

var
  t0 = cpuTime()
  warmupRunCount = 0
randomize()
while warmupRunCount < WARMUP_RUNS_COUNT:
  let
    w0 = float(rand 100)
  discard solve(input)
  let
    w1 = float(rand 100)
    reading = (start: w0, stop: w1)
  readings &= reading

  warmupRunCount += 1
  if (cpuTime() - t0) > WARMUP_MAX_TIMEOUT_SEC:
    break

var perfRunCount = 0
t0 = cpuTime()
asm """mfence"""

while perfRunCount < PERF_TEST_RUNS_COUNT:
  discard solve(input)

  perfRunCount += 1
  if (cpuTime() - t0) > PERF_TEST_MAX_TIMEOUT_SEC:
    break

asm """mfence"""
let t1 = cpuTime()

let
  total = t1 - t0
  avg = total / float(perfRunCount)

const
  NANO_CUTOFF  = 0.001
  NANO_MUL     = 1_000_000
  MILLI_CUTOFF = 1.0
  MILLI_MUL    = 1_000

func readableTime(sec: float): string =
  if sec < NANO_CUTOFF:    fmt"{sec*NANO_MUL} ns"
  elif sec < MILLI_CUTOFF: fmt"{sec*MILLI_MUL} ms"
  else:                    fmt"{sec} sec"

echo fmt"Time  (mean):         {readableTime(avg)}         {perfRunCount} runs, {warmupRunCount} warmup"
#echo fmt"Range (min … max):    {readableTime(min)} … {readableTime(max)}"
