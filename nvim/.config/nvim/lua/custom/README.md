# lua/custom/ — our delta only (never edit vendored kickstart sections)

Add a plugin (vim.pack pattern, 3 lines):

```lua
-- lua/custom/plugins/extra.lua
vim.pack.add { 'https://github.com/user/repo' }
require('repo').setup {}
```

Then inside nvim: `:lua vim.pack.update()` (`:write` applies),
then `git add nvim/.config/nvim/nvim-pack-lock.json` and commit.

Update the base: `git fetch upstream master`, review diff, re-apply
this directory. Verify with `nvim --headless '+checkhealth' +q`.
