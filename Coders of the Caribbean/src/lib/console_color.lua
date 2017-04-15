if not Console then Console = {} end

Console.Color = {
  reset = '\x1b[0m',
  red = '\x1b[31m',
  green = '\x1b[32m',
  yellow = '\x1b[33m',
  blue = '\x1b[34m',
  magenta = '\x1b[35m',
  cyan = '\x1b[36m',
  white = '\x1b[37m',
  gray = '\x1b[38;5;250m',
  pink = '\x1b[38;5;175m'
}

Console.colorize = function(colorName, string)
  return Console.Color[colorName] .. string .. Console.Color.reset
end