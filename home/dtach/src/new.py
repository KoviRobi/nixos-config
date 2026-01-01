#!/usr/bin/env python3

import os
from argparse import ArgumentParser
from pathlib import Path
from shutil import which
from subprocess import PIPE, run


def main():
    parser = ArgumentParser("Find and attach to first unattached socket")
    parser.add_argument("--i3-workspace", action="store_true", help="Use i3 window")
    parser.add_argument("--x11", action="store_true", help="Set X11 window property")
    parser.add_argument(
        "--shell",
        default=os.getenv("SHELL"),
        help="Shell to launch (defaults to $SHELL)",
    )
    parser.add_argument("--dtach", default=which("dtach"), help="dtach executable (full path)")
    parser.add_argument("--lsof", default=which("lsof"), help="lsof executable (full path)")
    parser.add_argument(
        "--socket-dir",
        default=f'{os.getenv("XDG_RUNTIME_DIR")}/dtach',
        help="socket directory (defaults to $XDG_RUNTIME_DIR/dtach)",
    )
    args = parser.parse_args()

    assert args.dtach, "`dtach` not found, specify using `--dtach <path>`"
    dtach = Path(args.dtach).expanduser()
    assert dtach.exists()

    assert args.lsof, "`lsof` not found, specify using `--lsof <path>`"
    lsof = Path(args.lsof).expanduser()
    assert lsof.exists()

    assert args.socket_dir, "socket directory not given, specify using `--socket-dir <path>`"
    socket_dir = Path(args.socket_dir)
    socket_dir.mkdir(exist_ok=True, parents=True)

    if args.i3_workspace:
        import i3ipc

        i3 = i3ipc.Connection()
        workspaces = i3.get_workspaces()
        focused = [ws for ws in workspaces if ws.focused][0]
        socket_dir = socket_dir / str(focused.num)

    os.environ["DTACH_SOCK_DIR"] = str(socket_dir)

    # Find and attach to a socket (create if necessary)
    n = 0
    maxsock = sum(1 for _ in socket_dir.iterdir())
    # For creating sockets, with leeway to account for concurrency
    maxsock += 10
    for n in range(maxsock):
        dtach_sock = str(socket_dir / str(n))
        os.environ["DTACH_SOCK"] = dtach_sock
        # No client
        if run([lsof, "-t", "+E", "--", dtach_sock], stdout=PIPE).stdout.count(b"\n") == 1:
            break
        # New socket
        if run([dtach, "-n", dtach_sock, args.shell]).returncode == 0:
            break
    else:
        raise RuntimeError(f"Giving up after {n} sockets tried")

    # Set window property
    if args.x11:
        import Xlib.display

        disp = Xlib.display.Display()
        win = disp.get_input_focus().focus
        PROP = disp.get_atom("DTACH")
        PROP_TYPE = disp.get_atom("STRING")
        win.change_property(PROP, PROP_TYPE, 8, dtach_sock.encode())
        disp.sync()

    # Re-execute, replacing current process
    os.execv(dtach, [dtach, "-A", dtach_sock, args.shell])


if __name__ == "__main__":
    main()
