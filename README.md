# wezterm-config

My terminal, in a repo. WezTerm with ten hot-swappable neon themes, a Starship
prompt, a bash setup with aliases and navigation shortcuts, and a shared git
config — all installed by one script.

```bash
git clone https://github.com/alexcolls/wezterm-config.git
cd wezterm-config
./install.sh
```

That installs WezTerm, FiraCode Nerd Font and Starship, links the configs into
place, and appends a single sourcing block to your `~/.bashrc`. Nothing is
overwritten silently: everything it replaces lands in
`~/.dotfiles-backup/<timestamp>/`, and `~/.bashrc` gets a timestamped `.bak`.

```bash
./install.sh --dry-run     # show every step, change nothing
./install.sh -y            # no questions
./install.sh --skip-wezterm --skip-fonts   # configs only
./install.sh --copy        # copy the files instead of symlinking them
./uninstall.sh             # unlink and unhook (leaves the packages installed)
```

Works on Debian/Ubuntu (apt), Fedora (dnf), Arch (pacman), openSUSE (zypper)
and macOS (Homebrew), with a Flatpak fallback.

---

## Keybindings

### WezTerm

| Keys | Does |
| --- | --- |
| `Alt` + `1`…`0` | Switch theme instantly (ten of them, see below) |
| `Alt` + `Enter` | Toggle fullscreen |
| `Alt` + `R` | Rename the current tab |
| `Shift` + `Alt` + `←↑↓→` | Split the pane in that direction |
| `Alt` + `←↑↓→` | Move focus between panes |
| `Ctrl` + `Tab` | Next tab |
| `Ctrl` + `Shift` + `Tab` | Previous tab |
| `Ctrl` + `PgUp` / `PgDn` | Previous / next tab |
| `Ctrl` + `Shift` + `1`…`8` | Jump to tab 1–8 |
| `Ctrl` + `Shift` + `9` | Jump to the last tab |
| `Ctrl` + `T` / `Ctrl` + `Shift` + `T` | New tab *(WezTerm default)* |
| `Ctrl` + `N` / `Ctrl` + `Shift` + `N` | New window *(WezTerm default)* |
| `Ctrl` + `Shift` + `W` | Close the tab, with a confirmation *(WezTerm default)* |
| `Ctrl` + `Alt` + `T` | Open WezTerm from anywhere *(set up by the installer)* |

### From the shell

Handy when your hands are already on the keyboard:

| Command | Does |
| --- | --- |
| `nt` | New tab, in the directory you're standing in |
| `nw` | New window, same directory |
| `vs` / `hs` | Split the current pane down / right |

These work because the shell reports its working directory to WezTerm (OSC 7),
which is also why new tabs and splits open where you already are.

---

## Themes

`Alt` + a number swaps the palette live — no restart, no config reload.

| | Theme | | | Theme |
| --- | --- | --- | --- | --- |
| `Alt+1` | Cyberpunk Base — deep navy, ice blue, hot-pink cursor | | `Alt+6` | Corpo Gold |
| `Alt+2` | Mainframe Matrix — green on black | | `Alt+7` | Netrunner |
| `Alt+3` | Miami Synthwave | | `Alt+8` | Toxic Waste |
| `Alt+4` | Old School CRT — amber phosphor | | `Alt+9` | Ghost Ops |
| `Alt+5` | Blood Ice | | `Alt+0` | Neon Pastel |

Cyberpunk Base is the one that loads at startup. The rest of the look:
FiraCode Nerd Font Thin at 11pt with 1.3 line height, no window decorations,
80% opacity, 20px padding, blinking block cursor, minimal tab bar that hides
itself when only one tab is open.

To change the default theme, edit the `config.colors = themes[1]` line in
`config/wezterm/wezterm.lua`. To add one, append another `make_theme { … }`
entry — the `Alt`+number bindings are generated from the list.

---

## Shell

### Getting around

`..` `...` `....` `.....` climb directories, `-` jumps back to where you were,
`mkcd <dir>` creates and enters, `up 3` climbs three levels, `md` is
`mkdir -p`. `autocd` is on, so typing a directory name on its own enters it.

### Everyday aliases

| | | | |
| --- | --- | --- | --- |
| `x`, `q` | exit | `cl`, `c` | clear |
| `ll` | `ls -alFh` | `lt` | newest first |
| `la` | all but `.`/`..` | `lsd` | directories only |
| `py` | `python3` | `venv` | create + activate `.venv` |
| `serve` | HTTP server in the cwd | `act` | activate `.venv` |
| `d` / `dc` | docker / compose | `dps` | readable `docker ps` |
| `n` / `nr` / `ni` | npm / run / install | `p` / `pr` | pnpm / run |
| `g` | git | `gs` | `git status -sb` |
| `gaa` | `git add -A` | `gcm` | `git commit -m` |
| `gl` / `gll` | pretty log / all branches | `gd` / `gds` | diff / staged |
| `reload` | re-source `~/.bashrc` | `path` | print `$PATH`, one per line |

`cp`, `mv` and `rm` prompt before destroying things. Also included:
`extract <archive>` (any format), `ff <name>` (find files), `gcl <url>`
(clone and cd in).

### History

50k entries, deduplicated, timestamped, and shared between panes the moment a
command finishes — so a command you just ran in one split is up-arrow-able in
the next.

---

## Git

`config/git/gitconfig` is *included* from your `~/.gitconfig` rather than
replacing it, so your identity and credentials stay yours and anything you set
locally still wins. It turns on `push.autoSetupRemote`, `pull.rebase`,
`fetch.prune`, `rerere`, histogram diffs and `zdiff3` conflict markers, plus
aliases: `git s`, `git lg`, `git sync`, `git undo`, `git wip`, `git cleanup`,
`git aliases` (lists them all).

A global gitignore for OS/editor/tooling noise goes to `~/.gitignore_global`.

---

## Layout

```
config/
  wezterm/wezterm.lua        the terminal: themes, font, window, keybindings
  starship/starship.toml     the prompt: directory + branch + ❯
  shell/
    bashrc.sh                entry point — ~/.bashrc sources this
    exports.sh               $EDITOR, history, guarded $PATH entries
    aliases.sh               everything in the table above
    functions.sh             mkcd, up, extract, nt/nw/vs/hs
    local.sh.example         machine-specific settings (copy → local.sh)
  git/
    gitconfig                aliases + settings, included from ~/.gitconfig
    gitignore_global
scripts/                     one script per install step
install.sh / uninstall.sh
```

The configs are **symlinked** into place, so editing anything under `config/`
takes effect on the next reload — no reinstall, and `git status` in this repo
shows exactly what you've changed.

## Machine-specific settings

CUDA paths, Vault addresses, tokens, per-box toolchains — anything that
shouldn't be on GitHub goes in `config/shell/local.sh`, which is gitignored and
sourced last. `install.sh` creates it for you from `local.sh.example`.

## Requirements

bash 4+, `git`, `curl`, `unzip`, and `sudo` for the package-manager steps.
Everything else the installer takes care of.
