<!-- markdownlint-disable MD013 -->

# Development Environments with Nix

This project offers developers who are unfamiliar with [Nix](https://nixos.org/) — a package management and system configuration tool — a practical, expert-guided mini-workshop to help them learn how to use it to create reproducible developer environments.

The Nix expert(s) will introduce the concepts using the [slides](https://roberthree.github.io/nix-mini-workshop/) created from [workshop.md](workshop.md).
In parallel, they will demonstrate how to apply these concepts in practice using the resources provided in the slides or in this repository, on a second screen in a terminal.
During the second half of the workshop, participants will solve simple challenges to gain hands-on experience with Nix.

## Prerequisites for participants

- Basic knowledge of [Python](https://www.python.org/)
- Familiarity with command-line tools
- An existing [Nix installation](https://nixos.org/download/) (check `nix --version`)
  - `~/.config/nix/nix.conf` or `/etc/nix/nix.conf` should contain the line `experimental-features = nix-command flakes`

## Learning Goals

By the end of the workshop, participants should be:

- Confident in explaining what Nix is and how Nix flakes help in constructing reproducible developer environments
- Comfortable with the Nix language, able to find help in the documentation and experiment in the Nix REPL ([Read–eval–print loop](https://en.wikipedia.org/wiki/Read%E2%80%93eval%E2%80%93print_loop))
- Able to create packages, apps and developer shells with Nix flakes

## Why use Nix for a software development project?

In many projects, dependencies come from multiple sources — your system package manager (e.g. Ubuntu’s `apt`), language-specific tools (e.g. Python’s `pip`), or direct GitHub checkouts.
Managing these manually can be slow, error-prone, and frustrating — especially when you need exact versions for reproducibility.

With Nix, you declare your entire development environment in a single file — typically `flake.nix`.
From there, you can spin up the exact environment with `nix develop`.

### Benefits

- **Zero manual setup** – All dependencies (system packages, language libraries, tools) are installed automatically
- **Reproducibility** – Eliminate “works on my machine” issues by pinning exact versions across all platforms
- **Shared environments** – Every developer gets the same setup, whether on Linux, macOS, or WSL
- **Effortless updates** – Change a version in `flake.nix` and everyone gets it instantly
- **Isolation** – Keep project dependencies separate from your global system, avoiding conflicts
