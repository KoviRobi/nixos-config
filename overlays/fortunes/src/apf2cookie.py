from titlecase import titlecase
from argparse import ArgumentParser
from pathlib import Path
from dataclasses import dataclass
import re
import logging

LOGGER = logging.getLogger(__name__)

SECTIONS_RE = re.compile(
    r"""
    -{75}\n        # -------------------------...
    \*\*\*\ (.*)\n # *** Discworld Annotations
    -{75}          # -------------------------...
    """,
    re.VERBOSE,
)

BOOKS_RE = re.compile(r"^((?:[AI]\ )?[A-Z]{2,}.*)$", re.VERBOSE | re.MULTILINE)

ANNOTATION_RE = re.compile(
    r"""
    ^[-+]\ (?P<ann>               # Line starting with "- " or "+ "
    (\[pg?\.? \s* (?P<pg>[0-9/]+)\])? # Page number
    .*                            # Rest of the line
    (\n(^$|^\ \ .*$))*)           # Empty line or line starting with "  "
    """,
    re.VERBOSE | re.MULTILINE,
)

XREF_RE = re.compile(
    r"""
    See \s+ the \s+ annotations? \s+
    (?P<pages> for      \s+ pg?\.? \s* [0-9/]+
        ((\s+ and | , ) \s+ pg?\.? \s* [0-9/]+)*)
    (\s+ of \s+ (?P<book> _ [^_]+ _ ))?
    """,
    re.VERBOSE | re.IGNORECASE,
)
PAGE_RE = re.compile(r"pg?\.? \s* ([0-9/]+)", re.VERBOSE)


@dataclass
class CompiledAnnotation:
    book: str | None
    annotation: str


# Book title and page number, mapping to a list of references (may be multiple
# per page)
XrefDict = dict[str, dict[int, list[str]]]


def titlecase_roman(s: str) -> str:
    return re.sub(
        r"\b[ivxmcl]{2,8}\b",
        lambda m: m[0].upper(),
        titlecase(s),
        flags=re.IGNORECASE,
    )


def compile_annotations(
    section: str,
    book_title: str | None,
    annotations: str,
    compiled: list[CompiledAnnotation],
    xrefs: XrefDict,
):
    header = "  " + section
    if book_title:
        book_title = titlecase_roman(book_title)
        header += " -- " + book_title
    header += "\n\n"
    for match in ANNOTATION_RE.finditer(annotations):
        ann = match["ann"].strip()
        annotation = header + "  " + ann
        try:
            pg = int(match["pg"].strip())
            if book_title:
                if book_title not in xrefs:
                    xrefs[book_title] = {}
                if pg not in xrefs[book_title]:
                    xrefs[book_title][pg] = []
                xrefs[book_title][pg].append(ann)
        except (IndexError, AttributeError, ValueError):
            LOGGER.info("Error adding xref for book %s", book_title)
            LOGGER.info("| annotation:")
            for line in annotation.splitlines():
                LOGGER.info("| %s", line)
            LOGGER.info("| Exception:", exc_info=True)
        compiled.append(CompiledAnnotation(book_title, annotation))


def xref(comp_ann: CompiledAnnotation, xrefs: XrefDict):
    for ref in XREF_RE.finditer(comp_ann.annotation):
        pages = [
            int(page)
            for match in PAGE_RE.finditer(ref["pages"])
            for page in match[1].split("/")
        ]
        if ref["book"]:
            book = " ".join(ref["book"].strip("_").split())
            book = titlecase_roman(book)
            book = re.sub(r"\.$", "", book)
            for page in pages:
                if page in xrefs[book]:
                    print("\n  " + book, "\n".join(xrefs[book][page]))
        elif comp_ann.book is not None:
            for page in pages:
                if page in xrefs[comp_ann.book]:
                    print("\n  " + comp_ann.book, "\n".join(xrefs[comp_ann.book][page]))
        else:
            LOGGER.info("Bad xref %s", ref.groupdict())


def main(file: Path):
    apf = file.read_text()

    sections = SECTIONS_RE.split(apf)
    titles = sections[1::2]
    contents = sections[2::2]

    # Book title/page number to annotation xref
    xrefs: XrefDict = {}
    compiled: list[CompiledAnnotation] = []

    for title, section in zip(titles, contents):
        title = title.strip()
        if title in ["Discworld Annotations", "Other Annotations"]:
            books = BOOKS_RE.split(section)
            book_titles = books[1::2]
            book_annotations = books[2::2]
            for book_title, book_annotation in zip(book_titles, book_annotations):
                book_title = book_title.strip()
                compile_annotations(title, book_title, book_annotation, compiled, xrefs)
        else:
            compile_annotations(title, None, section, compiled, xrefs)

    annotations_db = {}
    for comp_ann in compiled:
        print(comp_ann.annotation)
        xref(comp_ann, xrefs)
        print("%")


def main_cli() -> None:
    parser = ArgumentParser(
        description="Process the Annotated Pratchett File to a fortune cookie"
    )
    parser.add_argument("file", type=Path, help="Path to the Annotated Pratchett File.")
    parser.add_argument("--verbose", "-v", action="store_true")
    args = parser.parse_args()
    if args.verbose:
        logging.basicConfig(level="INFO")
    else:
        logging.basicConfig()
    main(args.file)


if __name__ == "__main__":
    main_cli()
