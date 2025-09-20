local mod = {}

-- Utility to convert hex to RGB
--- @param hex string
local function hex_to_rgb(hex)
  hex = hex:gsub('#', '')
  return tonumber('0x' .. hex:sub(1, 2)),
    tonumber('0x' .. hex:sub(3, 4)),
    tonumber('0x' .. hex:sub(5, 6))
end

-- Utility to convert RGB to hex
--- @param r integer
--- @param g integer
--- @param b integer
local function rgb_to_hex(r, g, b)
  return string.format('#%02x%02x%02x', r, g, b)
end

-- Clamp value between 0 and 255
--- @param v number
local function clamp(v)
  return math.max(0, math.min(255, math.floor(v + 0.5)))
end

-- Darken a color by a factor (0.0 - 1.0)
--- @param hex string
--- @param amount number
function mod.darken(hex, amount)
  local r, g, b = hex_to_rgb(hex)
  return rgb_to_hex(
    clamp(r * (1 - amount)),
    clamp(g * (1 - amount)),
    clamp(b * (1 - amount))
  )
end

-- Brighten a color by a factor (0.0 - 1.0)
--- @param hex string
--- @param amount number
function mod.brighten(hex, amount)
  local r, g, b = hex_to_rgb(hex)
  return rgb_to_hex(
    clamp(r + (255 - r) * amount),
    clamp(g + (255 - g) * amount),
    clamp(b + (255 - b) * amount)
  )
end

-- Mix two colors with a given ratio (0.0 - 1.0)
--- @param hex1 string
--- @param hex2 string
--- @param ratio number
function mod.mix(hex1, hex2, ratio)
  local r1, g1, b1 = hex_to_rgb(hex1)
  local r2, g2, b2 = hex_to_rgb(hex2)

  return rgb_to_hex(
    clamp(r1 * (1 - ratio) + r2 * ratio),
    clamp(g1 * (1 - ratio) + g2 * ratio),
    clamp(b1 * (1 - ratio) + b2 * ratio)
  )
end

-- Get foreground/background color of a highlight group
--- @param group string
--- @param attr 'fg' | 'bg'
function mod.get_hl_color(group, attr)
  local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = group, link = false })
  if not ok or not hl then
    return nil
  end

  local color = hl[attr]
  if not color then
    return nil
  end

  return string.format('#%06x', color)
end

return mod
