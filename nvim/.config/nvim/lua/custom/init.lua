-- lua/custom/init.lua — personal delta entry (auto-required from root init.lua).
-- Theme first so plugins pick up Mizuki colors on setup.
vim.opt.termguicolors = true
require('custom.mizuki').setup()
