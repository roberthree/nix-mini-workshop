<!-- markdownlint-disable MD013 MD026 MD033 -->

<!--
title: Development Environments with Nix
description: A hands‑on mini‑workshop about using Nix, a package management and system configuration tool, to create reproducible developer environments.
author: Robert Three
theme: default
paginate: true
headingDivider: 3
-->

# Development Environments with Nix

<base target="_blank">

A hands‑on mini‑workshop about using [Nix](https://nixos.org/), a package management and system configuration tool, to create reproducible developer environments.

## Goals

- Confident in explaining what Nix is and how Nix flakes help in constructing reproducible developer environments
- Comfortable with the Nix language, able to find help in the documentation and experiment in the Nix REPL ([Read–eval–print loop](https://en.wikipedia.org/wiki/Read%E2%80%93eval%E2%80%93print_loop))
- Able to create packages, apps and developer shells with Nix flakes

## Agenda

| Time          | Topic                                                                |
| ------------- | -------------------------------------------------------------------- |
| 00:05 – 00:10 | **What is Nix?** ((language + CLI + package manager) in one tool)    |
| 00:10 – 00:30 | **Nix Language Basics** (hands-on using `nix repl`)                  |
| 00:30 – 00:45 | **Understanding Flakes** (inputs, outputs, packages, devShells, ...) |
| 00:45 – 01:30 | **Hands-on Challenges** (each participant works on a challenge)      |
| 01:30 – 01:50 | **Cross‑Verification** (everyone tests everyone else's flake)        |
| 01:50 – 02:00 | **Wrap-up** (recap, next steps and final thoughts)                   |

## What is [Nix](https://zero-to-nix.com/concepts/nix/)?

It is actually 3 things: A CLI, package manager, and programming language.
But think of it as one single tool.

- A [programming language](https://zero-to-nix.com/concepts/nix-language/) is needed to have a dynamic configuration;
  think of it as "JSON, but with functions"
- The [CLI](https://zero-to-nix.com/concepts/nix/#cli) executes the package manager based on the provided Nix files
- The [package manager](https://zero-to-nix.com/concepts/package-management/) supports multiple platforms and builds packages from scratch

This allows providing a unified developer environment that is reproducible.
There is no need for manually installing any packages.

<!--
**Resources**

- [[Zero to Nix] Nix](https://zero-to-nix.com/concepts/nix/)
- [[Zero to Nix] The Nix language](https://zero-to-nix.com/concepts/nix-language/)
- [[Zero to Nix] Package management](https://zero-to-nix.com/concepts/package-management/)
-->

## Nix language basics

Nix is a pure, functional, lazy, declarative, and reproducible programming language.

Think of it like "JSON, but with functions":

- Wherever you see a `:`, it indicates a function, i.e. `ARGUMENT : BODY`
- The Rest are primitive types that all exist in JSON

We will know play around with `nix repl`.

**Resources:**

- [[nix.dev/tutorials] Nix language basics](https://nix.dev/tutorials/nix-language.html)
- [[nix.dev/manual] Nix Language](https://nix.dev/manual/nix/latest/language/index.html)
- [[Zero to Nix] The Nix language](https://zero-to-nix.com/concepts/nix-language/)

## What are Nix flakes and how do they work?

Nix flakes (`flake.nix`) are a concept for referencing and sharing Nix code.
Flakes can be "chained" to iteratively build easily a large complex development environment.

**Resources:**

- [[NixOS Wiki] Flakes](https://wiki.nixos.org/wiki/Flakes)
- [[Zero to Nix] Nix flakes](https://zero-to-nix.com/concepts/flakes/)
- [[NixOS & Flakes Book] An unofficial book for beginners](https://nixos-and-flakes.thiscute.world/)
- [[xeiaso.net] Nix Flakes: an Introduction](https://xeiaso.net/blog/nix-flakes-1-2022-02-21/)

### Important ⚠️

- Even though flakes are currently an experimental feature and will be in the near future, they are strongly recommended compared to existing "official" concepts!
- Nix does not see files that are not registered via `git`, at least stage new files to be able to use Nix on them!
- Nix and company networks sometimes have a complicated relationship, you may need to retry certain commands if they seem to be stuck!
- To detect whether you are in a Nix development shell evaluate `$IN_NIX_SHELL` and `$name` or use tools like [Starship](https://starship.rs/)!

---

A simple `flake.nix` for a development shell for one specific system:

```nix
{
  inputs = {
    nixpkgs.url = "nixpkgs/25.05";
  };

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        name = "example-dev-shell";
        packages = [
          pkgs.nixfmt-rfc-style
        ];
      };
    };
}
```

---

A simple `flake.nix` for a development shell for all default systems:

```nix
{
  inputs = {
    nixpkgs.url = "nixpkgs/25.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {self, nixpkgs, flake-utils}:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          name = "example-dev-shell";
          packages = [
            pkgs.nixfmt-rfc-style
          ];
        };
      }
    );
}
```

### Flake references

- [Flake references](https://zero-to-nix.com/concepts/flakes/#references) are string representations of where a flake is located:
  - `path:path/to/flake`
  - `github:Account/repository/branch`
- [Flake registries](https://zero-to-nix.com/concepts/flakes/#registries) may simplify these strings to identifiers, e.g. `nixpkgs` is the symbolic identifier for `github:NixOS/nixpkgs`

### Flake inputs

- Each flake has [inputs](https://zero-to-nix.com/concepts/flakes/#inputs), which are dependencies that are need for the built:

```nix
inputs = {
  nixpkgs.url = "nixpkgs/25.05";
  flake-utils.url = "github:numtide/flake-utils";
  myFlake.url = "path:path/to/flake";
};
```

- These dependencies can come from GitHub, the filesystem, custom git repositories and so on, often just another flake
- The flake input schema is defined [here](https://nix.dev/manual/nix/latest/command-ref/new-cli/nix3-flake#flake-inputs)
- All inputs are pinned in `flake.lock`

### Flake outputs

Each flake has [outputs](https://nixos-and-flakes.thiscute.world/other-usage-of-flakes/outputs), which can be, amongst others, simple library functions, [packages](https://zero-to-nix.com/concepts/packages/) or entire [development environments](https://zero-to-nix.com/concepts/dev-env/).

Available packages from the NixOS ecosystem can be found via the [Nixpkgs Package Search](https://search.nixos.org/packages).

Study the [Nixpkgs Reference Manual](https://nixos.org/manual/nixpkgs/stable/) for utility functions:

- [Nixpkgs Library Functions](https://nixos.org/manual/nixpkgs/stable/#sec-functions-library), e.g., [`lib.strings.concatStrings`](https://nixos.org/manual/nixpkgs/stable/#function-library-lib.strings.concatStrings)
- [Trivial build helpers](https://nixos.org/manual/nixpkgs/stable/#chap-trivial-builders), e.g., [`writeTextFile`](https://nixos.org/manual/nixpkgs/stable/#trivial-builder-writeTextFile), [`writeShellApplication`](https://nixos.org/manual/nixpkgs/stable/#trivial-builder-writeShellApplication)
- [Python](https://nixos.org/manual/nixpkgs/stable/#buildpythonpackage-function), e.g., [`buildPythonPackage`](https://nixos.org/manual/nixpkgs/stable/#buildpythonpackage-function)

### Important CLI commands

- Enter dev shell: `nix develop ./path#name`
- Build a package: `nix build ./path#name`
  (Results are stored in `result`, ⚠️ overwrites previous results)
- Run an app: `nix run ./path#name`

### Flake examples

#### Packages

- `nix build ./examples/packages/#bastet` -> `result/bin/bastet`
- `nix build ./examples/packages/#t2048` -> `result/bin/2048-in-terminal`

#### Apps

- `nix run ./examples/apps/#csv2arrow -- examples/apps/test.csv examples/apps/test.arrow`
- Alternatively `nix build ./examples/apps/#csv2arrow` -> `result/bin/csv2arrow examples/apps/test.csv examples/apps/test.arrow`

#### DevShells

- `nix develop ./examples/devShells/#pythonWithFun`

## Challenges for each participant

<div style="width: 100%; overflow: hidden;">
    <div style="width: 600px; float: left;">
        <p>
            Python has one of the <a href="https://pradyunsg.me/blog/2023/01/21/thoughts-on-python-packaging/">most complex package management systems</a>.
        </p>
        <p>
            Even though this will highly improve with <a href="https://python-poetry.org/">Poetry</a>, it is still an ideal use-case for providing a unified developer environment using Nix.
        </p>
        <p>
            The challenge for each participant is to provide a development environment where all others could immediately start working on Python scripts involving complex libraries.
        </p>
    </div>
    <div style="margin-left: 650px;">
        <img src="https://imgs.xkcd.com/comics/python_environment.png" alt="XKCD">
        Source: <a href="https://xkcd.com/1987/">xkcd.com/1987</a>
    </div>
</div>

### Procedure

**In the first round,** everyone develops an initial Nix development shell, such that another participant can immediately write nicely formatted python code.

Add a `flake.nix` to `challenges/challenge_**/` that provides a development shell containing Python and the formatter [black](https://github.com/psf/black). The result should be pushed to the branch `challenge_**`.

**In the second round,** everyone tries to solve a simple challenge by extending the provided development environment and writing challenge-specific scripts.

In the end, everyone should be able to checkout each branch `challenge_**`, `cd` into the folder `challenges/challenge_**/`, and:

- `nix build`: produce your binary in `./result/bin/...`, or
- `nix run`: run your app

### Hands-on the flakes!

Add a `flake.nix` to `challenges/challenge_**/` providing a development shell containing Python and [black](https://github.com/psf/black). Push the result to the branch `challenge_**`.

```nix
{
  inputs = {
    nixpkgs.url = "nixpkgs/25.05";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = {self, nixpkgs, flake-utils} : flake-utils.lib.eachDefaultSystem (
    system : let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      devShells.default = pkgs.mkShell {
        name = "example-dev-shell";
        packages = [ pkgs.nixfmt-rfc-style ];
      };
    }
  );
}
```

### Challenge Type Easy: Make a given Python script executable

- Extend the existing `flake.nix` with required Python libraries
- Make the script executable via `nix run`

**Goal:** Being able to add packages to flakes

### Challenge Type Medium: Provide multiple development shells

- Extend the existing `flake.nix` with additional development shells
- Make in each development shell a different Python script executable
- Make each script available as a shell application
- Make all shell applications executable via `nix run`

**Goal:** Being able to structure a flake with different [derivations](https://zero-to-nix.com/concepts/derivations/)

### Challenge Type Hard: Add flake outputs `checks` and `formatter`

- Extend the existing `flake.nix` with outputs `checks` and `formatter`
- Execute the formatter black as a checker in `checks` and as a formatter in `formatter`
- `nix flake check` should detect unformatted Python scripts
- `nix fmt` should format these scripts

**Goal:** Being able to extend the functionality of flakes

### Challenge Type Expert: Creating a Python library and application

- Extend the existing `flake.nix` with Python libraries of your choice
- Write a script that provides something useful
- Provide a Python library and application of your script as a flake package
- Make the application executable via `nix run`

**Goal:** Being able to provide Python packages without [pypi.org](https://pypi.org/)

### Python script ideas

- Create plots with `numpy`, `pandas` and `matplotlib`
- Write a simple game with `pygame`
- Image processing with `opencv`
- Turn an image into ASCII Art with `ascii_magic`
- Train a classifier with `scikit-learn`
- Start a basic web server with `flask`
- Scrap the World Wide Web with `requests` and `beautifulsoup4`

## Checkout the flakes!

Each participant has a challenge which will be verified by everyone else.

**Reminder:**

- Enter dev shell: `nix develop ./path#name`
- Build a package: `nix build ./path#name`
  (Results are stored in `result`, ⚠️ overwrites previous results)
- Run an app: `nix run ./path#name`

## Cross‑Verification

Time to verify each one's solution.

Please push your branches!

## Wrap-up

- Confident in explaining what Nix is (language, CLI, package manager) and how flakes help in constructing reproducible developer environments
- Be comfortable with the Nix language, find help in the documentation, and being able to play around in `nix repl`
- Create packages, apps and developer shells with a `flake.nix`
  (`nix build` / `nix run` / `nix develop`)
