

<!-- generated from docs/src/readme.qmd — edit the .qmd, then run docs/src/render-docs.sh -->

# RSM-MSBA computing environment

The computing environment for the Rady MSBA program — Python, Quarto,
PostgreSQL, and the course packages — **the same on your laptop and on
the Rady server**. No Docker to install.

There are two ways to use it. Most students use the **server** (nothing
to install). Pick one:

## A. On your own laptop

Install once, then everything lives in `~/rsm-msba`.

1.  Install **VS Code**: <https://code.visualstudio.com>
2.  Follow the one-page guide for your platform — it installs Nix + VS
    Code, then has you run `rsm-setup`:
    - **macOS (Apple Silicon):**
      [docs/student-macos.md](docs/student-macos.md)
    - **Windows 11:** [docs/student-wsl2.md](docs/student-wsl2.md)
3.  Open the `~/rsm-msba` folder in VS Code. For notebooks, pick the
    **Python (nix-uv)** kernel.

## B. On the Rady server (nothing to install)

You use the server through VS Code on your laptop.

1.  Install **VS Code** and its **Remote - SSH** extension.

2.  Be on the campus network or the **UCSD VPN**, then connect to
    `<your-campus-username>@rsm-compute-01.ucsd.edu` and enter your
    campus password.

3.  In a terminal, run:

    ``` bash
    rsm-setup
    ```

4.  Open the `~/rsm-msba` folder. For notebooks, pick the **Python
    (nix-uv)** kernel.

Full walkthrough: **[docs/connect-server.md](docs/connect-server.md)**

## Updating

Run `rsm-setup` any time — it pulls the latest environment and rebuilds.
It’s safe to re-run and never touches your coursework.

------------------------------------------------------------------------

*Instructors / developers:* the flake interfaces, the full command list,
the directory layout, and the server configuration are in
**[README-tech.md](README-tech.md)** and the [`docs/`](docs/) guides.
