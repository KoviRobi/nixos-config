#!/usr/bin/env python3

from argparse import ArgumentParser

from Xlib import display


def main():
    parser = ArgumentParser(description="Get DTACH property of window")
    parser.add_argument("window_id", type=lambda i: int(i, 0))
    args = parser.parse_args()
    window_id: int = args.window_id

    # Set window property
    disp = display.Display()
    win = disp.create_resource_object("window", window_id)
    PROP = disp.get_atom("DTACH")
    PROP_TYPE = disp.get_atom("STRING")
    dtach_sock = win.get_full_text_property(PROP, PROP_TYPE, 8)
    assert dtach_sock, f"No DTACH property on window 0x{window_id:X}"
    print(dtach_sock)


if __name__ == "__main__":
    main()
