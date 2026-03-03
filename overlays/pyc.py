#!/usr/bin/env python3

import collections
import functools
import itertools
import os
import re
import sys
import traceback
from argparse import ArgumentParser
from math import *
from pathlib import Path

def digit(n):
    if n in range(0, 10):
        return chr(ord("0") + n)
    if n in range(10, 37):
        return chr(ord("A") + n - 10)
    raise ValueError("Number not in base", n, base)


class int_base(int):
    base = 10
    def __repr__(self, /):
        if self.base == 1:
            return "1" * n
        if n == 0:
            return "0"
        ret = ""
        while n > 0:
            ret = digit(n % self.base) + ret
            n = n // self.base
        return ret


parser = ArgumentParser("Python calculator")
parser.add_argument("--base", help="output base to print numbers [1, 36]", type=int)
args = parser.parse_args()
if args.base:
    assert args.base in range(1, 37)
    int = int_base
    int_base.base = args.base

try:
    while line := input():
        try:
            print(repr(eval(line)))
        except:
            traceback.print_exc()
except (KeyboardInterrupt, EOFError):
    pass
