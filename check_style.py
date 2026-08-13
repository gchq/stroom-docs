#!/usr/bin/env python3
"""Check markdown content against the stroom-docs style guide.

The rules implemented here are the mechanically verifiable subset of
content/en/community/documentation/style-guide/.

Run via ./check_style.sh, which executes this in a container.
"""

import argparse
import fnmatch
import glob
import os
import re
import sys
from collections import defaultdict

# Files that are generated rather than hand written, so fixing them by hand
# would be undone on the next regeneration.
EXCLUDED_GLOBS = [
    "content/en/releases/*/change-log.md",
]

# Shortcodes whose inner content is verbatim code, not markdown.
CODE_SHORTCODES = (
    "command-line",
    "sql-shell",
    "code-block",
    "textfile",
    "stroom-tree",
    "stroom-tab",
)

# Words left in lower case in a title, unless first or last.
SMALL_WORDS = {
    "a", "an", "the", "and", "but", "or", "nor", "for", "yet", "so",
    "at", "by", "in", "of", "on", "to", "up", "as", "if", "per", "via",
}

# Abbreviations ending in '.' that do not terminate a sentence.
ABBREVIATIONS = {
    "e.g", "i.e", "eg", "ie", "etc", "vs", "cf", "approx", "incl", "excl",
    "min", "max", "no", "al", "dr", "mr", "mrs", "ms", "st", "jr", "sr",
    "inc", "ltd", "co", "corp", "fig", "ref",
}

RULES = {
    "sentence-per-line": "Each sentence must start on a new line",
    "heading-blank-before": "Heading needs two blank lines above (one under its parent)",
    "heading-no-blank-after": "Heading needs one blank line below",
    "title-case": "Heading should use title case",
    "fence-blank-before": "Fenced code block needs a blank line above",
    "fence-blank-after": "Fenced code block needs a blank line below",
    "ordered-list-not-1": "Numbered list items should all use '1.'",
    "setext-heading": "Use '#' headings, not '===' / '---' underlines",
    "h1-in-body": "Headings should be level 2 or lower",
    "hash-no-space": "'#' must be followed by a single space",
}

DISABLE_RE = re.compile(r"<!--\s*style-check:\s*disable\s*-->")
ENABLE_RE = re.compile(r"<!--\s*style-check:\s*enable\s*-->")


def is_excluded(path):
    norm = path.replace(os.sep, "/")
    return any(fnmatch.fnmatch(norm, g) for g in EXCLUDED_GLOBS)


def scan(path):
    """Return the lines plus masks marking code, tables, comments and opt-outs."""
    lines = open(path, encoding="utf-8").read().split("\n")
    n = len(lines)

    # Front matter, which may be preceded by blank lines.
    start = 0
    first = 0
    while first < n and lines[first].strip() == "":
        first += 1
    if first < n and lines[first].strip() == "---":
        for k in range(first + 1, n):
            if lines[k].strip() == "---":
                start = k + 1
                break

    in_code = [False] * n
    in_table = [False] * n
    skip = [False] * n

    fences = []
    shortcode = None
    in_comment = False
    disabled = False

    for i in range(start, n):
        line = lines[i]

        if DISABLE_RE.search(line):
            disabled = True
        if disabled:
            skip[i] = True
        if ENABLE_RE.search(line):
            disabled = False

        if shortcode is None:
            match = re.match(
                r"^\s*\{\{[<%]\s*(" + "|".join(CODE_SHORTCODES) + r")\b", line)
            if match and not re.search(r"\{\{[<%]\s*/", line):
                shortcode = match.group(1)
                in_code[i] = True
                continue
        else:
            in_code[i] = True
            if re.match(r"^\s*\{\{[<%]\s*/\s*" + shortcode + r"\s*[%>]\}\}", line):
                shortcode = None
            continue

        fence = re.match(r"^\s*(`{3,})", line)
        if fence:
            width = len(fence.group(1))
            if fences and width >= fences[-1]:
                fences.pop()
            elif not fences:
                fences.append(width)
            in_code[i] = True
            continue
        if fences:
            in_code[i] = True
            continue

        if "<!--" in line:
            in_comment = True
        if in_comment:
            skip[i] = True
        if "-->" in line:
            in_comment = False

        if re.match(r"^\s*\|", line):
            in_table[i] = True

    # A delimiter row marks the whole table block, including the style the
    # style guide permits where rows have no leading '|'.
    for i in range(start, n):
        if in_code[i] or "|" not in lines[i]:
            continue
        if not re.match(r"^[\s:|-]*-{2,}[\s:|-]*$", lines[i]):
            continue
        for step in (-1, 1):
            j = i + step
            while start <= j < n and lines[j].strip() and not in_code[j]:
                in_table[j] = True
                j += step
        in_table[i] = True

    return lines, start, in_code, in_table, skip


def core(word):
    return re.sub(r"^[^A-Za-z]+|[^A-Za-z]+$", "", word)


def title_case_offenders(text):
    text = re.sub(r"<--.*$", "", text)          # trailing annotations in examples
    text = re.sub(r"\{#[^}]*\}", "", text)      # explicit anchor attributes
    text = re.sub(r"`[^`]*`", "", text)         # code / identifiers
    words = [w for w in text.split() if core(w)]
    offenders = []
    for index, word in enumerate(words):
        stem = core(word)
        if stem.isupper() and len(stem) > 1:
            continue                             # acronym, e.g. IDP, TODO
        if any(c.isupper() for c in stem[1:]):
            continue                             # MySQL, Stroom-Docs
        if word.startswith(".") or "/" in word:
            continue                             # .png, paths
        if re.match(r"^v?\d+(\.\d+)*$", stem or word) or re.match(r"^v\d", word):
            continue                             # v7.1, 6.0
        if any(c in word for c in "()_."):
            continue                             # dictionary(), a_b, x.y
        is_edge = index in (0, len(words) - 1)
        if is_edge and stem[0].islower():
            offenders.append(word)
        elif not is_edge and stem.lower() not in SMALL_WORDS and stem[0].islower():
            offenders.append(word)
        elif not is_edge and stem.lower() in SMALL_WORDS and stem[0].isupper():
            offenders.append(word)
    return offenders


SENTENCE_RE = re.compile(
    r"([A-Za-z0-9\)\]\"'`]+)([.!?])([\"')\]]?)\s+(?=[A-Z\"'`(])")


def extra_sentences(line):
    text = re.sub(r"`[^`]*`", " X ", line)                 # code spans
    text = re.sub(r"\{\{[<%].*?[%>]\}\}", " X ", text)     # shortcodes
    text = re.sub(r"\[[^\]]*\]\([^)]*\)", " X ", text)     # markdown links
    text = re.sub(r"https?://\S+", " X ", text)            # bare urls
    hits = []
    for match in SENTENCE_RE.finditer(text):
        word = match.group(1)
        if word.lower() in ABBREVIATIONS:
            continue
        if re.fullmatch(r"[A-Za-z]", word):                # initial, e.g. 'A.'
            continue
        if re.fullmatch(r"\d+", word) and match.group(2) == ".":
            continue                                       # list marker
        hits.append(match.group(0).strip())
    return hits


def check(path):
    lines, start, in_code, in_table, skip = scan(path)
    found = []

    def report(rule, line_no, detail):
        found.append((rule, line_no, detail))

    headings = []
    for i in range(start, len(lines)):
        if in_code[i] or skip[i]:
            continue
        line = lines[i]

        if re.match(r"^#{1,6}[^#\s]", line):
            report("hash-no-space", i + 1, line.strip())
            continue

        heading = re.match(r"^(#{1,6}) (.+?)\s*$", line)
        if heading:
            level, text = len(heading.group(1)), heading.group(2)
            if level == 1:
                report("h1-in-body", i + 1, line.strip())
            headings.append((i, level, text))
            offenders = title_case_offenders(text)
            if offenders:
                report("title-case", i + 1,
                       f"{line.strip()}  -> {', '.join(offenders)}")
            if i + 1 < len(lines) and lines[i + 1].strip() != "":
                report("heading-no-blank-after", i + 1, line.strip())
            continue

        if (re.match(r"^(={3,}|-{3,})\s*$", line) and i > start
                and lines[i - 1].strip() and not in_table[i - 1]
                and not re.match(r"^[\s|:-]+$", lines[i - 1])):
            report("setext-heading", i + 1, lines[i - 1].strip())

        ordered = re.match(r"^(\s*)(\d+)\.\s+\S", line)
        if ordered and ordered.group(2) != "1":
            report("ordered-list-not-1", i + 1, line.strip()[:70])

        if not in_table[i] and not line.lstrip().startswith(">"):
            for hit in extra_sentences(line):
                report("sentence-per-line", i + 1, hit[:70])

    for index, (i, level, text) in enumerate(headings):
        blanks = 0
        j = i - 1
        while j >= start and lines[j].strip() == "":
            blanks += 1
            j -= 1
        if j < start:
            continue                                    # first heading in body
        previous = headings[index - 1] if index else None
        under_parent = previous is not None and j == previous[0] and previous[1] < level
        wanted = 1 if under_parent else 2
        if blanks != wanted:
            report("heading-blank-before", i + 1,
                   f"{text}  (has {blanks}, wants {wanted})")

    open_fence = False
    for i in range(start, len(lines)):
        if skip[i] or not re.match(r"^\s*`{3,}", lines[i]):
            continue
        if not open_fence:
            open_fence = True
            if (i > start and lines[i - 1].strip() != ""
                    and not re.match(r"^\s*\{\{", lines[i - 1])):
                report("fence-blank-before", i + 1, lines[i].strip()[:40])
        else:
            open_fence = False
            if (i + 1 < len(lines) and lines[i + 1].strip() != ""
                    and not re.match(r"^\s*\{\{", lines[i + 1])):
                report("fence-blank-after", i + 1, lines[i].strip()[:40])

    return found


def load_baseline(path):
    counts = {}
    if not os.path.isfile(path):
        return None
    for line in open(path, encoding="utf-8"):
        line = line.rstrip("\n")
        if not line or line.startswith("#"):
            continue
        file_path, rule, count = line.split("\t")
        counts[(file_path, rule)] = int(count)
    return counts


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("paths", nargs="*", default=None,
                        help="files or globs to check (default: all content)")
    parser.add_argument("--detail", action="store_true",
                        help="list every finding, not just the summary")
    parser.add_argument("--rule", action="append", choices=sorted(RULES),
                        help="only report this rule (repeatable)")
    parser.add_argument("--strict", action="store_true",
                        help="exit non-zero if there are any findings")
    parser.add_argument("--ratchet", action="store_true",
                        help="exit non-zero only if findings exceed the baseline")
    parser.add_argument("--baseline", default="style-baseline.tsv",
                        help="baseline file used by --ratchet")
    parser.add_argument("--update-baseline", action="store_true",
                        help="rewrite the baseline from the current findings")
    args = parser.parse_args()

    if args.paths:
        paths = []
        for pattern in args.paths:
            paths.extend(glob.glob(pattern, recursive=True) if any(
                c in pattern for c in "*?[") else [pattern])
    else:
        paths = glob.glob("content/**/*.md", recursive=True)
    paths = sorted(p for p in paths if p.endswith(".md") and not is_excluded(p))

    per_file = defaultdict(lambda: defaultdict(list))
    totals = defaultdict(int)
    for path in paths:
        for rule, line_no, detail in check(path):
            if args.rule and rule not in args.rule:
                continue
            per_file[path][rule].append((line_no, detail))
            totals[rule] += 1

    if args.update_baseline:
        with open(args.baseline, "w", encoding="utf-8") as handle:
            handle.write("# Generated by check_style.sh --update-baseline\n")
            handle.write("# Counts of known style-guide findings, per file per rule.\n")
            handle.write("# --ratchet fails only when a count rises above these.\n")
            for path in sorted(per_file):
                for rule in sorted(per_file[path]):
                    handle.write(f"{path}\t{rule}\t{len(per_file[path][rule])}\n")
        print(f"Wrote baseline for {sum(totals.values())} finding(s) to {args.baseline}")
        return 0

    if args.detail:
        for path in sorted(per_file):
            print(f"\n{path}")
            rows = sorted((n, r, d) for r, v in per_file[path].items() for n, d in v)
            for line_no, rule, detail in rows:
                print(f"  {line_no:>5}  {rule:<22} {detail}")

    total = sum(totals.values())
    print()
    print(f"{'RULE':<24}{'COUNT':>8}{'FILES':>8}   DESCRIPTION")
    print("-" * 100)
    for rule in sorted(totals, key=lambda r: -totals[r]):
        files = sum(1 for p in per_file if rule in per_file[p])
        print(f"{rule:<24}{totals[rule]:>8}{files:>8}   {RULES[rule]}")
    print("-" * 100)
    print(f"{'TOTAL':<24}{total:>8}{len(per_file):>8}   "
          f"{len(paths)} pages checked, {len(paths) - len(per_file)} clean")

    if args.ratchet:
        baseline = load_baseline(args.baseline)
        if baseline is None:
            print(f"\nNo baseline at {args.baseline}; "
                  f"run --update-baseline first.", file=sys.stderr)
            return 2
        regressions = []
        for path in sorted(per_file):
            for rule, hits in sorted(per_file[path].items()):
                was = baseline.get((path, rule), 0)
                if len(hits) > was:
                    regressions.append((path, rule, was, len(hits), hits))
        if regressions:
            print("\nNew style-guide findings compared to the baseline:\n")
            for path, rule, was, now, hits in regressions:
                print(f"  {path}  [{rule}] {was} -> {now}")
                for line_no, detail in hits:
                    print(f"      line {line_no}: {detail}")
            return 1
        print("\nNo new findings compared to the baseline.")
        return 0

    if args.strict:
        return 1 if total else 0
    return 0


if __name__ == "__main__":
    sys.exit(main())
