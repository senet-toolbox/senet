#!/usr/bin/env python3
"""Check that every Vapor symbol referenced in documents/*.md actually exists.

The docs drift silently: nothing compiles a markdown code block, so a renamed or
deleted API stays documented until a reader hits it. This walks every
`Vapor.X` / `Vapor.<namespace>.X` reference in the docs and resolves it against
the library source.

Usage:
    python3 scripts/check-docs-api.py [--vapor ../vapor] [--docs documents]

Exits non-zero if anything is unresolved, so it can gate a release.
"""

import argparse
import collections
import os
import re
import sys

# `pub const`, `pub fn`, `pub var`, and `pub export fn` are all part of the
# public surface.
PUB = re.compile(r"^\s*pub (?:export )?(?:const|fn|var)\s+(\w+)", re.M)


def public_symbols(path):
    try:
        with open(path) as handle:
            return set(PUB.findall(handle.read()))
    except FileNotFoundError:
        return None


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--vapor", default="../vapor", help="path to the vapor checkout")
    parser.add_argument("--docs", default="documents", help="directory of markdown docs")
    args = parser.parse_args()

    root = public_symbols(os.path.join(args.vapor, "src/comptime.zig"))
    if root is None:
        sys.exit(f"error: no vapor checkout at {args.vapor}")

    # Namespaces the docs reach into directly.
    namespaces = {}
    for prefix, rel in {
        "Vapor.lib": "src/lib/Vapor.zig",
        "Vapor.Types": "src/lib/types.zig",
        "Vapor.Kit": "src/lib/kit/Kit.zig",
        "Vapor.KeyStone": "src/lib/keystone/KeyStone.zig",
        "Vapor.Animation": "src/lib/Animation.zig",
        "Vapor.DateTime": "src/lib/DateTime.zig",
        "Vapor.Fetch": "src/lib/Fetch.zig",
    }.items():
        symbols = public_symbols(os.path.join(args.vapor, rel))
        if symbols is not None:
            namespaces[prefix] = symbols

    unresolved = collections.defaultdict(set)
    scanned = 0
    for name in sorted(os.listdir(args.docs)):
        if not name.endswith(".md"):
            continue
        scanned += 1
        with open(os.path.join(args.docs, name)) as handle:
            text = handle.read()

        # Namespaced references first, so `Vapor.Types.Color` is not also
        # reported as a bare `Vapor.Types`.
        for prefix, symbols in namespaces.items():
            for symbol in re.findall(re.escape(prefix) + r"\.(\w+)", text):
                if symbol not in symbols:
                    unresolved[f"{prefix}.{symbol}"].add(name)

        for symbol in re.findall(r"\bVapor\.(\w+)", text):
            if symbol not in root and symbol not in {
                p.split(".", 1)[1] for p in namespaces
            }:
                unresolved[f"Vapor.{symbol}"].add(name)

    print(f"scanned {scanned} docs against {args.vapor}")
    if not unresolved:
        print("all referenced Vapor symbols resolve")
        return 0

    print(f"\n{len(unresolved)} unresolved reference(s):\n")
    for symbol, files in sorted(unresolved.items()):
        print(f"  {symbol:38} {', '.join(sorted(files))}")
    return 1


if __name__ == "__main__":
    sys.exit(main())
