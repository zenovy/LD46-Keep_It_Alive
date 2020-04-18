vector = require "lib/vector"

-- Constants
local width = 100
local padding = 5
local height = 20

EnthusiasmMeter = {percentFilled = 0.9}
function EnthusiasmMeter:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  o.x = love.graphics.getWidth() - width - padding
  o.y = padding
  return o
end

function EnthusiasmMeter:draw()
  -- hollow rectangle in filled rectangle
  love.graphics.setLineWidth(5)
  love.graphics.setColor(0, 0.8, 0.8)
  love.graphics.rectangle('fill', self.x, self.y, width * self.percentFilled, height)
  love.graphics.setColor(1, 1, 1)
  love.graphics.rectangle('line', self.x, self.y, width, height)
end

return EnthusiasmMeter