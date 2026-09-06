-- lua/custom/mizuki.lua — Mizuki colorscheme (Akiyama Mizuki palette).
-- Dark Niigo-night base, Mizuki Pink accents. No plugins required.
-- Applied by lua/custom/init.lua. Palette is exposed as M.palette so
-- future custom config (e.g. lualine) can reuse it.
local M = {}

M.palette = {
  night   = '#1E1B26', -- Niigo Night: background
  surface = '#2A2433', -- Surface: statusline, popups, cursorline
  overlay = '#3A3344', -- Overlay: borders, separators
  visual  = '#4A2E3D', -- Visual selection (ribbon-tinted)
  lace    = '#F4E3EB', -- Pale Lace: foreground
  pink    = '#DDAACC', -- Mizuki Pink: official image color, primary accent
  hair    = '#F4A9C6', -- Hair Pink: bright accent (strings, keywords, search)
  ribbon  = '#8E3B5C', -- Deep Ribbon: selections, warnings
  gray    = '#A2A6BD', -- Uniform Gray: comments, inactive
  dim     = '#6B7089', -- Dim Gray: line numbers, whitespace
  green   = '#A8CFA0', -- ok / added
  red     = '#E56B7F', -- error / deleted
  gold    = '#E3C07F', -- warn / numbers
  ice     = '#9AB5D6', -- info / types
}

function M.setup()
  vim.o.background = 'dark'
  vim.cmd('hi clear')
  if vim.fn.exists('syntax_on') == 1 then
    vim.cmd('syntax reset')
  end
  vim.g.colors_name = 'mizuki'

  local c = M.palette
  local set = vim.api.nvim_set_hl
  local h = {
    -- base
    Normal = { fg = c.lace, bg = c.night },
    NormalFloat = { fg = c.lace, bg = c.surface },
    FloatBorder = { fg = c.overlay, bg = c.surface },
    CursorLine = { bg = c.surface },
    CursorColumn = { bg = c.surface },
    ColorColumn = { bg = c.surface },
    LineNr = { fg = c.dim },
    CursorLineNr = { fg = c.hair, bold = true },
    SignColumn = { fg = c.gray, bg = c.night },
    Folded = { fg = c.gray, bg = c.surface },
    FoldColumn = { fg = c.dim, bg = c.night },
    NonText = { fg = c.dim },
    Whitespace = { fg = c.dim },
    SpecialKey = { fg = c.dim },
    MatchParen = { bg = c.overlay, bold = true },
    Visual = { bg = c.visual },
    Search = { fg = c.night, bg = c.hair, bold = true },
    IncSearch = { fg = c.night, bg = c.pink, bold = true },
    CurSearch = { link = 'IncSearch' },
    Pmenu = { fg = c.lace, bg = c.surface },
    PmenuSel = { fg = c.lace, bg = c.ribbon, bold = true },
    PmenuSbar = { bg = c.overlay },
    PmenuThumb = { bg = c.gray },
    WildMenu = { link = 'PmenuSel' },
    StatusLine = { fg = c.lace, bg = c.surface },
    StatusLineNC = { fg = c.gray, bg = c.night },
    WinSeparator = { fg = c.overlay },
    TabLine = { fg = c.gray, bg = c.night },
    TabLineFill = { bg = c.night },
    TabLineSel = { fg = c.hair, bg = c.surface, bold = true },
    WinBar = { fg = c.pink, bg = c.night },
    WinBarNC = { fg = c.gray, bg = c.night },

    -- syntax
    Comment = { fg = c.gray, italic = true },
    Constant = { fg = c.gold },
    String = { fg = c.hair },
    Character = { link = 'String' },
    Number = { fg = c.gold },
    Boolean = { fg = c.gold },
    Float = { link = 'Number' },
    Identifier = { fg = c.lace },
    Function = { fg = c.pink },
    Statement = { fg = c.hair },
    Keyword = { fg = c.hair },
    Conditional = { link = 'Statement' },
    Repeat = { link = 'Statement' },
    Label = { link = 'Statement' },
    Operator = { fg = c.lace },
    Exception = { fg = c.red },
    PreProc = { fg = c.pink },
    Include = { link = 'PreProc' },
    Define = { link = 'PreProc' },
    Macro = { link = 'PreProc' },
    Type = { fg = c.ice },
    StorageClass = { link = 'Type' },
    Structure = { link = 'Type' },
    Typedef = { link = 'Type' },
    Special = { fg = c.gold },
    SpecialChar = { link = 'Special' },
    Delimiter = { fg = c.gray },
    Underlined = { underline = true },
    Bold = { bold = true },
    Italic = { italic = true },
    Todo = { fg = c.lace, bg = c.ribbon, bold = true },
    Error = { fg = c.red, bold = true },

    -- treesitter (links keep it robust; explicit where it matters)
    ['@variable'] = { fg = c.lace },
    ['@variable.builtin'] = { fg = c.hair },
    ['@function'] = { link = 'Function' },
    ['@function.builtin'] = { fg = c.pink, bold = true },
    ['@keyword'] = { link = 'Keyword' },
    ['@string'] = { link = 'String' },
    ['@number'] = { link = 'Number' },
    ['@boolean'] = { link = 'Boolean' },
    ['@type'] = { link = 'Type' },
    ['@comment'] = { link = 'Comment' },
    ['@operator'] = { link = 'Operator' },
    ['@punctuation.delimiter'] = { link = 'Delimiter' },
    ['@punctuation.bracket'] = { fg = c.gray },
    ['@tag'] = { fg = c.pink },
    ['@tag.attribute'] = { fg = c.hair },
    ['@property'] = { fg = c.lace },

    -- diagnostics
    DiagnosticError = { fg = c.red },
    DiagnosticWarn = { fg = c.gold },
    DiagnosticInfo = { fg = c.ice },
    DiagnosticHint = { fg = c.gray },
    DiagnosticOk = { fg = c.green },
    DiagnosticUnderlineError = { undercurl = true, sp = c.red },
    DiagnosticUnderlineWarn = { undercurl = true, sp = c.gold },
    DiagnosticUnderlineInfo = { undercurl = true, sp = c.ice },
    DiagnosticUnderlineHint = { undercurl = true, sp = c.gray },
    DiagnosticSignError = { link = 'DiagnosticError' },
    DiagnosticSignWarn = { link = 'DiagnosticWarn' },
    DiagnosticSignInfo = { link = 'DiagnosticInfo' },
    DiagnosticSignHint = { link = 'DiagnosticHint' },
    DiagnosticSignOk = { link = 'DiagnosticOk' },

    -- diff / git (kickstart ships gitsigns)
    DiffAdd = { bg = '#2A3A2E' },
    DiffDelete = { bg = '#3A2A30' },
    DiffChange = { bg = '#2E2A3A' },
    DiffText = { bg = c.visual },
    GitSignsAdd = { fg = c.green },
    GitSignsChange = { fg = c.gold },
    GitSignsDelete = { fg = c.red },

    -- messages / misc
    ModeMsg = { fg = c.pink, bold = true },
    MoreMsg = { fg = c.hair },
    Question = { fg = c.hair },
    WarningMsg = { fg = c.gold },
    ErrorMsg = { fg = c.red, bold = true },
    Directory = { fg = c.pink },
    Title = { fg = c.hair, bold = true },
    SpellBad = { undercurl = true, sp = c.red },
    SpellCap = { undercurl = true, sp = c.gold },
  }
  for group, opts in pairs(h) do
    set(0, group, opts)
  end
end

return M
