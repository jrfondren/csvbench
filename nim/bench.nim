import std/[parsecsv, tables, strutils, unicode]

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

template openrussian(v: untyped, filename: string, body: untyped): untyped =
  var v: CsvParser
  v.open(filename, separator='\t')
  v.readHeaderRow()
  while p.readRow():
    body
  v.close()
proc rowInt(p: var CsvParser, col: string): int = p.rowEntry(col).parseInt

proc loadSentences(filename: string) =
  openrussian(p, filename):
    let id = p.rowInt("id")
    doAssert id notin Sentences
    Sentences[id] = (
      p.rowEntry("ru").quoteToEmphasis,
      p.rowInt("tatoeba_key"),
      parseEnum[WordLevel](p.rowEntry("level"), WordLevel.None))

loadSentences("sentences.csv")
echo Sentences.len
