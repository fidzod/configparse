# learning-haskell

A from-scratch JSON parser in Haskell, built as a vehicle for learning the language.

## Environment

`flake.nix` provides a dev shell with `ghc` (9.10.3) and `cabal-install` via nixpkgs. Enter it with:

```
nix develop
```

## Who's doing what

The user is learning Haskell through this project and wants to write the project
code themselves — Claude should teach and guide, not author the parser
implementation. Short illustrative snippets in explanations are fine; writing
the actual `.hs` files is not. Tooling/config (flake.nix, this file, cabal
project files, etc.) is fair game for Claude to write directly.

Session style: move slowly, prioritize *why* and *how* over just getting things
working. Let the user run commands and read errors themselves rather than
narrating results for them.

## Learning goals

- Primary: build deep intuition for Functor, Applicative, and Monad — expected
  to emerge naturally from writing a parser-combinator library as part of this
  project.
- Secondary (not expected to come up in this project, planned as a follow-on):
  Foldable and Monoid.
