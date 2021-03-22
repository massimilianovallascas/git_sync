# Git sync

PoC script to mirror and keep in sync two git repositories.

Protected branches should not be updated on the Mirror to avoid conflicts.

## Setup

Before running the script modify the following variables:
- **ORIGIN:** Origin repository url
- **MIRROR:** Mirror repository url
- **PROTECTED_BRANCHES:** Branches to keep in sync

## Usage

`./git_sync setup`

`./git_sync sync` or `./git sync2`