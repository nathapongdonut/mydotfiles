# Research: Kickstart.nvim current base and update flow

Ticket: [#4](https://github.com/nathapongdonut/mydotfiles/issues/4) (part of wayfinding map #1).
Date: 2026-09-06. All claims traced to primary sources (linked per section).
Upstream pinned at [`f7b845d`](https://github.com/nvim-lua/kickstart.nvim/commit/f7b845d8b6df409b0392ca117d092d5dffd2b538) ("Align keymaps with gitsigns.nvim's defaults", 2026-09-06).

> Heads-up: the ticket asks about "lazy.nvim wiring", but upstream no longer uses lazy.nvim.
> Kickstart migrated to the built-in `vim.pack` manager (Neovim 0.12+). Details in §2.

## 1. Single-file shape (current master)

- One heavily-commented `init.lua` (~1100 lines) in 10 labeled sections: (1) options/leaders, (2) keymaps + autocmds, (3) plugin-manager intro + build hooks, (4) UI/core UX, (5) Telescope, (6) LSP, (7) formatting, (8) autocomplete/snippets, (9) treesitter, (10) optional examples/next steps.
- Source: [`init.lua` @ master](https://raw.githubusercontent.com/nvim-lua/kickstart.nvim/master/init.lua) (fetched 2026-09-06).
- Small helper `local function gh(repo) return 'https://github.com/' .. repo end` so specs read `gh 'user/repo'`; versions via `version = vim.version.range '2.*'` (LuaSnip) / `'1.*'` (blink.cmp), treesitter pinned to `version = 'main'`.
- The "single file" is deliberate teaching design, not a technical limit; the FAQ points at [kickstart-modular.nvim](https://github.com/dam9000/kickstart-modular.nvim) for a split equivalent and links discussions [#218](https://github.com/nvim-lua/kickstart.nvim/issues/218) / [#473](https://github.com/nvim-lua/kickstart.nvim/pull/473).
- Source: [README — FAQ](https://github.com/nvim-lua/kickstart.nvim#faq).
- Beyond `init.lua` the repo is thin: `lua/kickstart/plugins/{debug,indent_line,lint,autopairs,neo-tree}.lua` (opt-in via commented `require` lines), `lua/custom/plugins/` loader pattern, `lua/kickstart/health.lua`, `doc/`, `.stylua.toml`, `nvim-pack-lock.json` (git-ignored upstream). Top-level file list confirmed via repo front page: [nvim-lua/kickstart.nvim](https://github.com/nvim-lua/kickstart.nvim).

## 2. Plugin management: `vim.pack`, not lazy.nvim

- Post-install is now: open `nvim`, `vim.pack` installs everything; inspect with `:lua vim.pack.update(nil, { offline = true })`, update with `:lua vim.pack.update()` (`:write` applies, `:quit` cancels). There is no lazy.nvim bootstrap and no `:Lazy` command.
- Source: [README — Post Installation](https://github.com/nvim-lua/kickstart.nvim#post-installation), [Section 3 of init.lua](https://raw.githubusercontent.com/nvim-lua/kickstart.nvim/master/init.lua).
- Pattern per plugin is `vim.pack.add { gh '…' }` followed by `require('…').setup { … }` — i.e. no `opts` auto-passing like lazy.nvim; configuration is explicit Lua after the add call.
- Build steps (telescope-fzf-native via `make`, LuaSnip `make install_jsregexp`, `TSUpdate`) run from a `PackChanged` autocmd; fzf-native is only added when `vim.fn.executable 'make' == 1`, else skipped.
- Source: Sections 3/5/8/9 of `init.lua`; Windows/CMake variant documented in [README — Install Recipes](https://github.com/nvim-lua/kickstart.nvim#install-recipes).
- Background: `vim.pack` shipped in Neovim 0.12 (experimental, Git-based, no third-party bootstrap), conceptually derived from `mini.deps`; the canonical guide is [A Guide to vim.pack](https://echasnovski.com/blog/2026-03-13-a-guide-to-vim-pack) (linked from init.lua itself). Migration cost from lazy.nvim is real — no built-in lazy-loading (`cmd`/`event`/`ft`/`keys` specs don't translate; defer via `vim.schedule`/autocmds) — see [Averpil: From lazy.nvim to vim.pack](https://fredrikaverpil.github.io/blog/2026/04/15/from-lazy.nvim-to-vim.pack/). Kickstart 0.12 tracking lived in [#1971](https://github.com/nvim-lua/kickstart.nvim/issues/1971) (lazy.nvim replacement discussed under [#1630](https://github.com/nvim-lua/kickstart.nvim/issues/1630)).
- Current plugin inventory in the base (all wired as above): guess-indent, gitsigns (+ recommended `<leader>h` keymaps), which-key, tokyonight-night, todo-comments, mini.nvim (`ai` with `aa`/`ii` next-object remaps to avoid clashing with native `v_an`/`v_in`, `surround`, `statusline`, `icons` when a Nerd Font is present), Telescope (+ plenary, ui-select, fzf-native), fidget, nvim-lspconfig + mason.nvim + mason-lspconfig + mason-tool-installer, conform.nvim (format-on-save opt-in per filetype, `<leader>f`), LuaSnip, blink.cmp (rust matcher off, lua impl), nvim-treesitter `main` branch with auto-install-on-FileType.
- Source: Sections 4–9 of `init.lua`.

## 3. First-run dependencies

- Neovim: latest `stable` or `nightly` only (`nvim --version` check).
- Required externals: `git`, `make`, `unzip`, C compiler (`gcc`); [`ripgrep`](https://github.com/BurntSushi/ripgrep#installation) + [`fd-find`](https://github.com/sharkdp/fd#installation) (Telescope live_grep/find_files); [tree-sitter CLI](https://github.com/tree-sitter/tree-sitter/blob/master/crates/cli/README.md#installation); a clipboard tool (xclip/xsel/win32yank per platform).
- Optional: [Nerd Font](https://www.nerdfonts.com/) (then set `vim.g.have_nerd_font = true` in init.lua); Ubuntu emoji font `fonts-noto-color-emoji` if emoji wanted.
- Per-language: `npm` for TypeScript, `go` for Golang, etc.; formatters/linters/LSP servers beyond the Lua defaults (`stylua`, `lua_ls`) come via `:Mason` / `mason-tool-installer` `ensure_installed`.
- Source: [README — Install External Dependencies](https://github.com/nvim-lua/kickstart.nvim#install-external-dependencies).
- Distro recipes (copy-paste): Ubuntu (`ppa:neovim-ppa/unstable` + `apt install make gcc ripgrep fd-find tree-sitter-cli unzip git xclip neovim`), Debian (apt + tarball from `neovim/neovim/releases/latest`), Fedora (`dnf install -y gcc make git ripgrep fd-find tree-sitter-cli unzip neovim`), Arch (`pacman -S --needed gcc make git ripgrep fd tree-sitter-cli unzip neovim`), Alpine (+ `musl-dev`, caution: lua-language-server may fail on musl — `:Mason`/`:MasonLog`, swap `lua_ls`→`emmylua_ls`); Windows via choco (`neovim git ripgrep wget fd unzip gzip mingw make tree-sitter`) or WSL2 Ubuntu recipe. Alternative version managers: bob, Homebrew, Flatpak, mise/asdf.
- Source: [README — Install Recipes / Alternative installation](https://github.com/nvim-lua/kickstart.nvim#install-recipes).
- Trial without clobbering an existing config: `NVIM_APPNAME=nvim-kickstart` + `~/.config/nvim-kickstart` + alias; uninstall = delete config + `~/.local/share/nvim*` data dir.
- Source: [README — FAQ](https://github.com/nvim-lua/kickstart.nvim#faq).

## 4. Recommended upstream-tracking workflow (small local diff)

- Upstream's own guidance: either GitHub "Use this template" (clean break, you manually cherry-pick upstream changes later) or **fork** (easy sync path: keep your config on a separate branch, fast-forward `master` from upstream). Tradeoffs debated in [#1740](https://github.com/nvim-lua/kickstart.nvim/issues/1740).
- Source: [README — Recommended Step](https://github.com/nvim-lua/kickstart.nvim#recommended-step).
- Recommendation for our `nvim/` Stow package (easiest maintenance):
  1. Vendor a snapshot: `nvim/.config/nvim/init.lua` + `nvim/.config/nvim/lua/{kickstart,custom}/` copied from pinned upstream commit; stamp the SHA + date in a header comment and in this file (§1 above).
  2. Keep local diff small by rule: never edit vendored sections in place — put all personal config in `lua/custom/` (or a clearly-marked `LOCAL OVERRIDES` tail section) and leave the five optional `require 'kickstart.plugins.…'` lines as the only toggles inside the base.
  3. Track `nvim-pack-lock.json` in version control (upstream git-ignores it only to ease its own maintenance; downstream users are told to un-ignore it — see `:help vim.pack-lockfile`).
  4. Update flow: `git fetch upstream master`, review `git log/diff upstream/master` (upstream moves fast — 453 commits), then either fast-forward a pristine `vendor` branch and re-apply our small patchset, or cherry-pick the upstream hunks we want. Verify with `nvim --headless '+checkhealth' +q` and `:lua vim.pack.update(nil, { offline = true })`.
  5. Plugin updates are separate from base updates: `:lua vim.pack.update()` inside nvim (`:write` applies), then commit the changed lockfile.
- Why not a git submodule/subtree of kickstart directly: kickstart is a *template to own*, not a dependency — upstream says "it's your config now". Vendoring a pinned snapshot with a recorded SHA gives reproducible Stow installs without coupling our repo history to 46k-fork upstream churn.

## 5. Answer to the ticket question

- Base pattern for `nvim/`: single vendored `init.lua` (vim.pack-based, §§1–2) + `lua/kickstart/plugins/*` opt-ins + `lua/custom/` for our delta, pinned at `f7b845d` (2026-09-06), lockfile tracked.
- First-run story for `install.sh`: Neovim stable + `git make unzip gcc ripgrep fd-find tree-sitter-cli <clipboard-tool>` per distro (§3 recipe lines) before Stow-linking `nvim/`; Nerd Font optional via `vim.g.have_nerd_font`.
- Update story: fork-style vendor branch + small `lua/custom/` diff + lockfile commits (§4); trial sidelines via `NVIM_APPNAME`.
