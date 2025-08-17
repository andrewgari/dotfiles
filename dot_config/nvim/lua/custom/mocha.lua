local mocha = {}

mocha.colors = {
  foreground = '#cdd6f4',
  background = '#1e1e2e',
  cursor = '#f38ba8',
  selection_fg = '#1e1e2e',
  selection_bg = '#f5e0dc',

  black = '#45475a',
  red = '#f38ba8',
  green = '#a6e3a1',
  yellow = '#f9e2af',
  blue = '#89b4fa',
  magenta = '#cba6f7',
  cyan = '#94e2d5',
  white = '#bac2de',
  bright_black = '#585b70',
  bright_red = '#f38ba8',
  bright_green = '#a6e3a1',
  bright_yellow = '#f9e2af',
  bright_blue = '#89b4fa',
  bright_magenta = '#cba6f7',
  bright_cyan = '#94e2d5',
  bright_white = '#a6adc8',
}

function mocha.setup()
  local colors = mocha.colors

  vim.cmd('highlight Normal guibg=' .. colors.background .. ' guifg=' .. colors.foreground)
  vim.cmd('highlight Cursor guibg=' .. colors.cursor)
  vim.cmd('highlight Visual guibg=' .. colors.selection_bg .. ' guifg=' .. colors.selection_fg)

  vim.cmd('highlight Comment guifg=' .. colors.bright_black .. ' gui=italic')
  vim.cmd('highlight Constant guifg=' .. colors.cyan)
  vim.cmd('highlight String guifg=' .. colors.green)
  vim.cmd('highlight Function guifg=' .. colors.blue)
  vim.cmd('highlight Identifier guifg=' .. colors.magenta)
  vim.cmd('highlight Statement guifg=' .. colors.red)
  vim.cmd('highlight Type guifg=' .. colors.yellow)
  vim.cmd('highlight PreProc guifg=' .. colors.bright_blue)
  vim.cmd('highlight Special guifg=' .. colors.bright_magenta)
  vim.cmd('highlight Error guifg=' .. colors.red .. ' gui=bold')

  vim.cmd('highlight Pmenu guibg=' .. colors.bright_black .. ' guifg=' .. colors.foreground)
  vim.cmd('highlight PmenuSel guibg=' .. colors.bright_blue .. ' guifg=' .. colors.background)

  vim.cmd('highlight LineNr guifg=' .. colors.bright_black)
  vim.cmd('highlight CursorLineNr guifg=' .. colors.bright_blue .. ' gui=bold')

  vim.cmd('highlight StatusLine guibg=' .. colors.bright_black .. ' guifg=' .. colors.foreground)
  vim.cmd('highlight StatusLineNC guibg=' .. colors.bright_black .. ' guifg=' .. colors.bright_black)

  vim.cmd('highlight TabLine guibg=' .. colors.bright_black .. ' guifg=' .. colors.foreground)
  vim.cmd('highlight TabLineSel guibg=' .. colors.bright_blue .. ' guifg=' .. colors.background)

  vim.cmd('highlight VertSplit guibg=' .. colors.background .. ' guifg=' .. colors.bright_black)
end

return mocha
