-- Neovim v1 baseline — vendored kickstart snapshot (vim.pack, NOT lazy.nvim).
-- Pinned upstream: nvim-lua/kickstart.nvim @ f7b845d (2026-09-06).
-- Full vendor lands here on implementation; this skeleton proves the shape.
-- Rule: never edit vendored sections in place — personal config goes in
-- lua/custom/ (see lua/custom/README.md). Track nvim-pack-lock.json.
-- Details: docs/research/kickstart-base.md

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = false
vim.opt.number = true
vim.opt.mouse = 'a'

-- Local entry point for our delta (kept tiny in v1).
pcall(require, 'custom')
