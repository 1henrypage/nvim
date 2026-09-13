local Colors = require("1henrypage.extras").colors

vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") == 1 then
  vim.cmd("syntax reset")
end

vim.o.background = "dark"
vim.g.colors_name = "ristretto"

local C = Colors
local groups = {
  -- Editor chrome
  Normal = { bg = C.background, fg = C.text },
  NormalNC = { bg = C.background, fg = C.dimmed1 },
  NormalFloat = { bg = C.dark1, fg = C.dimmed1 },
  FloatBorder = { bg = C.dark1, fg = C.dimmed4 },
  FloatTitle = { bg = C.dark1, fg = C.yellow, bold = true },
  Cursor = { bg = C.text, fg = C.background },
  lCursor = { link = "Cursor" },
  CursorIM = { link = "Cursor" },
  CursorLine = { bg = C.terminal },
  CursorColumn = { bg = C.terminal },
  ColorColumn = { bg = C.dark1 },
  LineNr = { fg = C.dimmed4 },
  LineNrAbove = { fg = C.dimmed4 },
  LineNrBelow = { fg = C.dimmed4 },
  CursorLineNr = { fg = C.yellow, bold = true },
  SignColumn = { bg = C.background, fg = C.dimmed3 },
  FoldColumn = { bg = C.background, fg = C.dimmed3 },
  Folded = { bg = C.terminal, fg = C.dimmed1 },
  EndOfBuffer = { bg = C.background, fg = C.background },
  VertSplit = { fg = C.dark1 },
  WinSeparator = { fg = C.dark1 },
  Visual = { bg = C.dimmed4, fg = C.text },
  VisualNOS = { link = "Visual" },
  Search = { bg = C.yellow, fg = C.dark2 },
  CurSearch = { bg = C.red, fg = C.dark2, bold = true },
  IncSearch = { bg = C.orange, fg = C.dark2, bold = true },
  Substitute = { bg = C.purple, fg = C.dark2 },
  MatchParen = { fg = C.cyan, bold = true, underline = true },
  NonText = { fg = C.dimmed4 },
  Whitespace = { fg = C.dimmed4 },
  SpecialKey = { fg = C.dimmed3 },
  Conceal = { fg = C.dimmed3 },
  Directory = { fg = C.cyan },
  Title = { fg = C.yellow, bold = true },
  ErrorMsg = { fg = C.red },
  WarningMsg = { fg = C.yellow },
  MoreMsg = { fg = C.green },
  Question = { fg = C.green },
  ModeMsg = { fg = C.dimmed1 },
  MsgArea = { bg = C.background, fg = C.dimmed1 },
  QuickFixLine = { bg = C.terminal, fg = C.yellow, bold = true },
  WildMenu = { bg = C.orange, fg = C.dark2 },

  -- Menus, bars and tabs
  Pmenu = { bg = C.terminal, fg = C.dimmed1 },
  PmenuSel = { bg = C.dimmed3, fg = C.text, bold = true },
  PmenuKind = { bg = C.terminal, fg = C.cyan },
  PmenuKindSel = { bg = C.dimmed3, fg = C.cyan },
  PmenuExtra = { bg = C.terminal, fg = C.dimmed2 },
  PmenuExtraSel = { bg = C.dimmed3, fg = C.text },
  PmenuSbar = { bg = C.dark1 },
  PmenuThumb = { bg = C.dimmed3 },
  StatusLine = { bg = C.dark1, fg = C.text },
  StatusLineNC = { bg = C.dark1, fg = C.dimmed3 },
  TabLine = { bg = C.dark2, fg = C.dimmed2 },
  TabLineFill = { bg = C.dark1 },
  TabLineSel = { bg = C.background, fg = C.text, bold = true },
  WinBar = { bg = C.background, fg = C.dimmed1 },
  WinBarNC = { bg = C.background, fg = C.dimmed3 },
  WinBarFile = { bg = C.background, fg = C.dimmed1, bold = true },

  -- Vim syntax. Comments are deliberately the only italic text.
  Comment = { fg = C.dimmed3, italic = true },
  SpecialComment = { fg = C.dimmed3, italic = true },
  Constant = { fg = C.purple },
  String = { fg = C.yellow },
  Character = { fg = C.purple },
  Number = { fg = C.purple },
  Boolean = { fg = C.purple },
  Float = { fg = C.purple },
  Identifier = { fg = C.text },
  Function = { fg = C.green },
  Statement = { fg = C.red },
  Conditional = { fg = C.red },
  Repeat = { fg = C.red },
  Label = { fg = C.red },
  Operator = { fg = C.red },
  Keyword = { fg = C.red },
  Exception = { fg = C.red },
  PreProc = { fg = C.orange },
  Include = { fg = C.red },
  Define = { fg = C.orange },
  Macro = { fg = C.orange },
  PreCondit = { fg = C.orange },
  Type = { fg = C.cyan },
  StorageClass = { fg = C.red },
  Structure = { fg = C.cyan },
  Typedef = { fg = C.cyan },
  Special = { fg = C.orange },
  SpecialChar = { fg = C.orange },
  Delimiter = { fg = C.dimmed1 },
  Underlined = { fg = C.cyan, underline = true },
  Bold = { bold = true },
  Italic = { fg = C.text },
  Error = { fg = C.red },
  Todo = { fg = C.purple, bold = true },

  -- Diffs and version control
  DiffAdd = { bg = C.dark1, fg = C.green },
  DiffChange = { bg = C.terminal, fg = C.yellow },
  DiffDelete = { bg = C.dark1, fg = C.red },
  DiffText = { bg = C.dimmed4, fg = C.text, bold = true },
  diffAdded = { fg = C.green },
  diffChanged = { fg = C.yellow },
  diffRemoved = { fg = C.red },
  GitSignsAdd = { fg = C.green, bold = true },
  GitSignsChange = { fg = C.orange, bold = true },
  GitSignsDelete = { fg = C.red, bold = true },
  GitSignsCurrentLineBlame = { fg = C.dimmed3 },
  BlameDate = { fg = C.dimmed2 },
  BlameUncommitted = { fg = C.orange },

  -- Diagnostics and LSP UI
  DiagnosticError = { fg = C.red },
  DiagnosticWarn = { fg = C.yellow },
  DiagnosticInfo = { fg = C.cyan },
  DiagnosticHint = { fg = C.purple },
  DiagnosticOk = { fg = C.green },
  DiagnosticUnderlineError = { sp = C.red, undercurl = true },
  DiagnosticUnderlineWarn = { sp = C.yellow, undercurl = true },
  DiagnosticUnderlineInfo = { sp = C.cyan, undercurl = true },
  DiagnosticUnderlineHint = { sp = C.purple, undercurl = true },
  DiagnosticVirtualTextError = { bg = C.dark1, fg = C.red },
  DiagnosticVirtualTextWarn = { bg = C.dark1, fg = C.yellow },
  DiagnosticVirtualTextInfo = { bg = C.dark1, fg = C.cyan },
  DiagnosticVirtualTextHint = { bg = C.dark1, fg = C.purple },
  LspReferenceText = { bg = C.dimmed4 },
  LspReferenceRead = { bg = C.dimmed4, underline = true },
  LspReferenceWrite = { bg = C.dimmed4, bold = true, underline = true },
  LspReferenceTarget = { bg = C.dimmed4, bold = true },
  LspInlayHint = { bg = C.dark1, fg = C.dimmed2 },
  LspCodeLens = { fg = C.dimmed2 },
  LspCodeLensSeparator = { fg = C.dimmed4 },
  LspSignatureActiveParameter = { fg = C.yellow, bold = true },
  LightBulbSign = { fg = C.yellow },

  -- Completion and pickers
  BlinkCmpMenu = { bg = C.terminal, fg = C.dimmed1 },
  BlinkCmpMenuBorder = { bg = C.terminal, fg = C.dimmed4 },
  BlinkCmpMenuSelection = { bg = C.dimmed3, fg = C.text, bold = true },
  BlinkCmpLabel = { fg = C.dimmed1 },
  BlinkCmpLabelMatch = { fg = C.cyan, bold = true },
  BlinkCmpLabelDeprecated = { fg = C.dimmed3, strikethrough = true },
  BlinkCmpLabelDescription = { fg = C.dimmed2 },
  BlinkCmpLabelDetail = { fg = C.dimmed2 },
  BlinkCmpSource = { fg = C.dimmed3 },
  BlinkCmpGhostText = { fg = C.dimmed3 },
  BlinkCmpDoc = { bg = C.dark1, fg = C.dimmed1 },
  BlinkCmpDocBorder = { bg = C.dark1, fg = C.dimmed4 },
  BlinkCmpDocCursorLine = { bg = C.terminal },
  BlinkCmpSignatureHelp = { bg = C.dark1, fg = C.dimmed1 },
  BlinkCmpSignatureHelpBorder = { bg = C.dark1, fg = C.dimmed4 },
  BlinkCmpSignatureHelpActiveParameter = { fg = C.yellow, bold = true },
  BlinkCmpScrollBarGutter = { bg = C.dark1 },
  BlinkCmpScrollBarThumb = { bg = C.dimmed3 },
  FzfLuaNormal = { bg = C.dark1, fg = C.dimmed1 },
  FzfLuaBorder = { bg = C.dark1, fg = C.orange },
  FzfLuaTitle = { bg = C.orange, fg = C.dark2, bold = true },
  FzfLuaPreviewNormal = { bg = C.dark1, fg = C.dimmed1 },
  FzfLuaPreviewBorder = { bg = C.dark1, fg = C.orange },
  FzfLuaPreviewTitle = { bg = C.green, fg = C.dark2, bold = true },
  FzfLuaCursorLine = { bg = C.terminal },
  FzfLuaSearch = { fg = C.yellow, bold = true },

  -- Indentation, breadcrumbs and outline
  IblIndent = { fg = C.dimmed5, nocombine = true },
  IblWhitespace = { fg = C.dimmed5, nocombine = true },
  IblScope = { fg = C.orange, nocombine = true },
  NavicText = { fg = C.dimmed1 },
  NavicSeparator = { fg = C.dimmed4 },
  AerialNormal = { bg = C.dark1, fg = C.dimmed1 },
  AerialNormalNC = { bg = C.dark1, fg = C.dimmed2 },
  AerialLine = { bg = C.terminal, fg = C.text, bold = true },
  AerialGuide = { fg = C.dimmed4 },
  AerialWinSeparator = { bg = C.dark1, fg = C.background },
  AerialStatusLine = { bg = C.dark1, fg = C.dimmed3 },
  AerialStatusLineNC = { bg = C.dark1, fg = C.dark1 },

  -- Sidebars and utility windows
  NeoTreeNormal = { bg = C.dark1, fg = C.dimmed2 },
  NeoTreeNormalNC = { bg = C.dark1, fg = C.dimmed2 },
  NeoTreeSignColumn = { bg = C.dark1, fg = C.dimmed2 },
  NeoTreeWinSeparator = { bg = C.dark1, fg = C.background },
  NeoTreeEndOfBuffer = { bg = C.dark1, fg = C.dark1 },
  NeoTreeStatusLine = { bg = C.dark1, fg = C.dark1 },
  NeoTreeStatusLineNC = { bg = C.dark1, fg = C.dark1 },
  NeoTreeCursorLine = { bg = C.terminal, fg = C.text, bold = true },
  NeoTreeRootName = { fg = C.yellow, bold = true },
  NeoTreeDirectoryIcon = { fg = C.cyan },
  NeoTreeDirectoryName = { fg = C.dimmed1 },
  NeoTreeIndentMarker = { fg = C.dimmed5 },
  NeoTreeExpander = { fg = C.dimmed3 },
  NeoTreeGitAdded = { fg = C.green },
  NeoTreeGitModified = { fg = C.orange },
  NeoTreeGitDeleted = { fg = C.red },
  NeoTreeGitUntracked = { fg = C.purple },
  NeoTreeGitConflict = { fg = C.red, bold = true },
  TroubleNormal = { bg = C.dark1, fg = C.dimmed1 },
  TroubleNormalNC = { bg = C.dark1, fg = C.dimmed2 },
  TroubleText = { fg = C.dimmed1 },
  TroubleCount = { bg = C.terminal, fg = C.purple },
  TroubleSource = { fg = C.dimmed3 },
  TroubleCode = { fg = C.dimmed3 },
  TroublePos = { fg = C.orange },
  TroubleDirectory = { fg = C.dimmed3 },
  TroubleFilename = { fg = C.cyan },
  TroublePreview = { bg = C.terminal },
  WhichKey = { fg = C.cyan },
  WhichKeyGroup = { fg = C.orange },
  WhichKeyDesc = { fg = C.dimmed1 },
  WhichKeySeparator = { fg = C.dimmed4 },
  WhichKeyNormal = { bg = C.dark1 },
  LazyNormal = { bg = C.dark1, fg = C.dimmed1 },
  MasonNormal = { bg = C.dark1, fg = C.dimmed1 },

  -- mini.nvim modules retained by this config
  MiniNotifyNormal = { bg = C.dark1, fg = C.text },
  MiniNotifyBorder = { bg = C.dark1, fg = C.orange },
  MiniNotifyTitle = { bg = C.dark1, fg = C.orange, bold = true },
  MiniCursorword = { sp = C.orange, underline = true },
  MiniCursorwordCurrent = { sp = C.orange, underline = true },
  MiniHipatternsFix = { fg = C.red, bold = true },
  MiniHipatternsFixme = { fg = C.red, bold = true },
  MiniHipatternsHack = { fg = C.orange, bold = true },
  MiniHipatternsTodo = { fg = C.purple, bold = true },
  MiniHipatternsNote = { fg = C.cyan, bold = true },

  -- Tests and debugging
  NeotestPassed = { fg = C.green },
  NeotestFailed = { fg = C.red },
  NeotestRunning = { fg = C.yellow },
  NeotestSkipped = { fg = C.dimmed3 },
  NeotestTest = { fg = C.text },
  NeotestNamespace = { fg = C.cyan },
  DapBreakpoint = { fg = C.red },
  DapBreakpointCondition = { fg = C.yellow },
  DapLogPoint = { fg = C.cyan },
  DapStopped = { bg = C.terminal, fg = C.yellow },

  -- Spelling
  SpellBad = { sp = C.red, undercurl = true },
  SpellCap = { sp = C.yellow, undercurl = true },
  SpellLocal = { sp = C.cyan, undercurl = true },
  SpellRare = { sp = C.purple, undercurl = true },
}

local captures = {
  ["@variable"] = { fg = C.text },
  ["@variable.builtin"] = { fg = C.purple },
  ["@variable.parameter"] = { fg = C.dimmed1 },
  ["@variable.member"] = { fg = C.cyan },
  ["@constant"] = { fg = C.purple },
  ["@constant.builtin"] = { fg = C.purple, bold = true },
  ["@constant.macro"] = { fg = C.orange },
  ["@module"] = { fg = C.cyan },
  ["@module.builtin"] = { fg = C.cyan },
  ["@label"] = { fg = C.red },
  ["@string"] = { fg = C.yellow },
  ["@string.documentation"] = { fg = C.yellow },
  ["@string.regexp"] = { fg = C.orange },
  ["@string.escape"] = { fg = C.orange },
  ["@string.special"] = { fg = C.orange },
  ["@character"] = { fg = C.purple },
  ["@boolean"] = { fg = C.purple },
  ["@number"] = { fg = C.purple },
  ["@number.float"] = { fg = C.purple },
  ["@type"] = { fg = C.cyan },
  ["@type.builtin"] = { fg = C.cyan },
  ["@type.definition"] = { fg = C.cyan },
  ["@attribute"] = { fg = C.orange },
  ["@attribute.builtin"] = { fg = C.orange },
  ["@property"] = { fg = C.cyan },
  ["@function"] = { fg = C.green },
  ["@function.builtin"] = { fg = C.green },
  ["@function.call"] = { fg = C.green },
  ["@function.macro"] = { fg = C.orange },
  ["@function.method"] = { fg = C.green },
  ["@function.method.call"] = { fg = C.green },
  ["@constructor"] = { fg = C.cyan },
  ["@operator"] = { fg = C.red },
  ["@keyword"] = { fg = C.red },
  ["@keyword.coroutine"] = { fg = C.red },
  ["@keyword.function"] = { fg = C.red },
  ["@keyword.operator"] = { fg = C.red },
  ["@keyword.import"] = { fg = C.red },
  ["@keyword.type"] = { fg = C.red },
  ["@keyword.modifier"] = { fg = C.red },
  ["@keyword.repeat"] = { fg = C.red },
  ["@keyword.return"] = { fg = C.red },
  ["@keyword.debug"] = { fg = C.red },
  ["@keyword.exception"] = { fg = C.red },
  ["@keyword.conditional"] = { fg = C.red },
  ["@keyword.directive"] = { fg = C.orange },
  ["@punctuation.delimiter"] = { fg = C.dimmed1 },
  ["@punctuation.bracket"] = { fg = C.dimmed1 },
  ["@punctuation.special"] = { fg = C.orange },
  ["@comment"] = { link = "Comment" },
  ["@comment.documentation"] = { link = "Comment" },
  ["@comment.error"] = { fg = C.red, italic = true, bold = true },
  ["@comment.warning"] = { fg = C.yellow, italic = true, bold = true },
  ["@comment.todo"] = { fg = C.purple, italic = true, bold = true },
  ["@comment.note"] = { fg = C.cyan, italic = true, bold = true },
  ["@markup.strong"] = { fg = C.text, bold = true },
  ["@markup.italic"] = { fg = C.dimmed1 },
  ["@markup.strikethrough"] = { fg = C.dimmed2, strikethrough = true },
  ["@markup.underline"] = { fg = C.cyan, underline = true },
  ["@markup.heading"] = { fg = C.orange, bold = true },
  ["@markup.link"] = { fg = C.cyan },
  ["@markup.link.label"] = { fg = C.purple },
  ["@markup.link.url"] = { fg = C.cyan, underline = true },
  ["@markup.raw"] = { fg = C.yellow },
  ["@markup.list"] = { fg = C.red },
  ["@diff.plus"] = { fg = C.green },
  ["@diff.minus"] = { fg = C.red },
  ["@diff.delta"] = { fg = C.yellow },
  ["@tag"] = { fg = C.red },
  ["@tag.attribute"] = { fg = C.orange },
  ["@tag.delimiter"] = { fg = C.dimmed1 },
}

for name, value in pairs(captures) do
  groups[name] = value
end

local semantic_links = {
  boolean = "@boolean",
  builtinType = "@type.builtin",
  class = "@type",
  comment = "@comment",
  decorator = "@attribute",
  enum = "@type",
  enumMember = "@constant",
  event = "@constant",
  ["function"] = "@function",
  interface = "@type",
  keyword = "@keyword",
  macro = "@function.macro",
  method = "@function.method",
  namespace = "@module",
  number = "@number",
  operator = "@operator",
  parameter = "@variable.parameter",
  property = "@property",
  regexp = "@string.regexp",
  string = "@string",
  struct = "@type",
  type = "@type",
  typeParameter = "@type.definition",
  variable = "@variable",
}

for kind, link in pairs(semantic_links) do
  groups["@lsp.type." .. kind] = { link = link }
end
groups["@lsp.typemod.variable.readonly"] = { fg = C.purple }
groups["@lsp.typemod.property.readonly"] = { fg = C.purple }
groups["@lsp.typemod.function.defaultLibrary"] = { fg = C.green, bold = true }

local kind_colors = {
  Array = C.red,
  Boolean = C.purple,
  Class = C.cyan,
  Color = C.purple,
  Constant = C.purple,
  Constructor = C.green,
  Enum = C.orange,
  EnumMember = C.orange,
  Event = C.orange,
  Field = C.cyan,
  File = C.dimmed1,
  Folder = C.cyan,
  Function = C.green,
  Interface = C.cyan,
  Key = C.orange,
  Keyword = C.red,
  Method = C.green,
  Module = C.cyan,
  Namespace = C.cyan,
  Null = C.purple,
  Number = C.purple,
  Object = C.cyan,
  Operator = C.red,
  Package = C.purple,
  Property = C.cyan,
  Reference = C.purple,
  Snippet = C.green,
  String = C.yellow,
  Struct = C.cyan,
  Text = C.dimmed1,
  TypeParameter = C.orange,
  Unit = C.purple,
  Variable = C.text,
}

for kind, color in pairs(kind_colors) do
  groups["Aerial" .. kind] = { fg = color }
  groups["NavicIcons" .. kind] = { fg = color }
  groups["BlinkCmpKind" .. kind] = { fg = color }
  groups["TroubleIcon" .. kind] = { fg = color }
end

local rainbow = { C.red, C.yellow, C.cyan, C.orange, C.green, C.purple, C.cyan }
local rainbow_names = { "Red", "Yellow", "Blue", "Orange", "Green", "Violet", "Cyan" }
for index, name in ipairs(rainbow_names) do
  groups["RainbowDelimiter" .. name] = { fg = rainbow[index] }
end

for name, value in pairs(groups) do
  vim.api.nvim_set_hl(0, name, value)
end

vim.g.terminal_color_0 = C.terminal
vim.g.terminal_color_1 = C.red
vim.g.terminal_color_2 = C.green
vim.g.terminal_color_3 = C.yellow
vim.g.terminal_color_4 = C.orange
vim.g.terminal_color_5 = C.purple
vim.g.terminal_color_6 = C.cyan
vim.g.terminal_color_7 = C.text
vim.g.terminal_color_8 = C.dimmed3
vim.g.terminal_color_9 = C.red
vim.g.terminal_color_10 = C.green
vim.g.terminal_color_11 = C.yellow
vim.g.terminal_color_12 = C.orange
vim.g.terminal_color_13 = C.purple
vim.g.terminal_color_14 = C.cyan
vim.g.terminal_color_15 = C.text
