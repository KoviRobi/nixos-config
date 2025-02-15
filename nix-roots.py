#!/usr/bin/env python3
import itertools
import json
import os
import re
import sys
import typing as t
from pathlib import Path
from subprocess import PIPE, run

NIX_STORE_PATH = re.compile(r"/nix/store/(?P<hash>[^-]*)-(?P<name>[^/]*)")
DIRENV_RE = re.compile(r"/\.direnv/.*")

Du = dict[str, int]
Deps = dict[str, list[str]]
Rdeps = dict[str, list[str]]
Roots = dict[str, list[str]]

du: Du = {}
deps: Deps = {}
rdeps: Rdeps = {}

cursor_save = "\x1b[s"
cursor_restore = "\x1b[u"


def in_nix_store(path: Path) -> bool:
    return ("/", "nix", "store") == path.parts[:3]


def nix_store_root(p: Path | str) -> Path:
    p = Path(p)
    assert in_nix_store(p)
    return Path(*p.parts[:4])


def get_key(nix_path: Path | str) -> str:
    "Computes the keys for the du/dep/rdep dics"
    return nix_store_root(nix_path).name


def nix_name_parts(name: str) -> tuple[str, str]:
    match = NIX_STORE_PATH.match(name)
    assert match
    return t.cast(tuple[str, str], match.groups())


def recurse_du(key: str, path: Path) -> None:
    if path.is_symlink():
        res = path.resolve()
        if in_nix_store(res):
            dep = get_key(res)
            if dep != key and in_nix_store(res):
                rdeps[dep] = rdeps.get(dep, [])
                rdeps[dep].append(key)
                deps[key] = rdeps.get(key, [])
                deps[key].append(dep)
                compute_du(res)


def compute_du(root: Path) -> None:
    key = get_key(root)
    if key in du:  # Already visited
        return
    du[key] = root.lstat().st_size
    recurse_du(key, root)
    for dirpath, dirnames, filenames in root.walk(follow_symlinks=False):
        for child_name in itertools.chain(dirnames, filenames):
            child = dirpath / child_name
            du[key] += child.lstat().st_size
            recurse_du(key, child)


def compute_all_du(roots: Roots, progress=sys.stderr) -> tuple[Du, Du]:
    closures = {}
    for fromPath, toPaths in roots.items():
        closure = 0
        print(fromPath, cursor_save, file=progress, end="", flush=True)
        n = 0
        m = len(toPaths)
        for path in toPaths:
            print(f"{cursor_restore}[{n}/{m}]", file=progress, end="", flush=True)
            compute_du(nix_store_root(path))
            key = get_key(path)
            closure += du[key]
            for dep in deps.get(key, []):
                closure += du[dep]
            n += 1
        closures[fromPath] = closure
        print(f"{cursor_restore}[{n}/{m}] closure {hsize(closure)}", file=progress)
    # Unique size can only be computed after closures have been
    uniques = {}
    for fromPath, toPaths in roots.items():
        unique = 0
        for path in toPaths:
            key = get_key(path)
            unique += du[key]
            for dep in deps.get(key, []):
                if dep in rdeps and len(rdeps[dep]) == [key]:
                    unique += du[dep]
        uniques[fromPath] = unique
    return (closures, uniques)


def get_roots() -> Roots:
    roots_proc = run(["nix-store", "--gc", "--print-roots"], stdout=PIPE, check=True)
    lines = roots_proc.stdout.decode().splitlines()

    roots: Roots = {}
    for line in lines:
        [fromPath, toPath] = line.split(" -> ")

        fromPath = fromPath.strip()
        toPath = toPath.strip()

        fromPath = DIRENV_RE.sub("/.direnv/", fromPath)

        roots[fromPath] = roots.get(fromPath, [])
        roots[fromPath].append(toPath)
    return roots


def print_info(roots: Roots, closures: Du, uniques: Du):
    alignTo = max(len(key) for key in roots.keys())

    for fromPath, toPaths in roots.items():
        pad = alignTo - len(fromPath)
        chunkSize = max(20, os.get_terminal_size().columns - alignTo - 3)
        shortTo = " ".join(
            f"{hash[:7]}...-{name}"
            for path in toPaths
            for hash, name in [nix_name_parts(path)]
        )
        print(fromPath, end="")
        while shortTo != "":
            print(" " * pad, "->", shortTo[:chunkSize])
            pad = alignTo
            shortTo = shortTo[chunkSize:]

    print(f"{'Path':{alignTo}}{'Closure size':20}Unique size")
    for fromPath, toPaths in roots.items():
        print(
            f"{fromPath:{alignTo}}{hsize(closures[fromPath]):20}{hsize(uniques[fromPath])}",
        )


def hsize(size: float | int) -> str:
    "Returns human size as in `du -h`"
    if size < 1024:
        return f"{size:.3f}B"
    size = size / 1024
    if size < 1024:
        return f"{size:.3f}KiB"
    size = size / 1024
    if size < 1024:
        return f"{size:.3f}MiB"
    size = size / 1024
    if size < 1024:
        return f"{size:.3f}GiB"
    size = size / 1024
    return f"{size:.3f}TiB"


def main():
    log = sys.stderr
    print("Getting roots", file=log)
    roots = get_roots()

    with open("roots.json", "w") as fp:
        json.dump(roots, fp)

    print("Computing root sizes", file=log)
    closures, uniques = compute_all_du(roots, progress=log)

    with open("closures.json", "w") as fp:
        json.dump(closures, fp)
    with open("uniques.json", "w") as fp:
        json.dump(uniques, fp)

    print("=" * os.get_terminal_size().columns)
    print_info(roots, closures, uniques)
    print("=" * os.get_terminal_size().columns)


if __name__ == "__main__":
    main()
