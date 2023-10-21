import std/[tables, strutils, unicode]
import tsvreader

const combiningAccentAcute* = runeAt("\u0301", 0)
const singleQuote = runeAt("'", 0)

func quoteToEmphasis*(s: string): string =
  for c in s.runes:
    if c == singleQuote:
      result.add combiningAccentAcute
    else:
      result.add c

type
  # only 6% of words are in a level at all
  WordLevel* = enum
    None, A1, A2, B1, B2, C1, C2, Any

var
  Sentences* = initTable[int, tuple[ru: string, tatoeba_key: int, level: WordLevel]]()

proc loadSentences(filename: string) =
  let
    csv = openCsv(filename)
    id = csv.columns["id"]
    ru = csv.columns["ru"]
    tatoeba_key = csv.columns["tatoeba_key"]
    level = csv.columns["level"]
  for row in csv.row:
    let idn = row[id].parseInt
    doAssert idn notin Sentences
    Sentences[idn] = (
      row[ru].quoteToEmphasis,
      row[tatoeba_key].parseInt,
      parseEnum[WordLevel](row[level], WordLevel.None))

loadSentences("sentences.csv")
echo Sentences.len
