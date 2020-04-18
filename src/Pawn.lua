vector = require "lib/vector"

local baseSize = 10

Pawn = {position = vector(15, 15), size = baseSize}
function Pawn:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Pawn:draw(pawn)
  love.graphics.setColor(0.8, 0.8, 0)
  love.graphics.ellipse('fill', self.position.x, self.position.y + self.size * 1, self.size * 0.75, self.size * 2)
  love.graphics.setColor(1, 1, 1)
  love.graphics.circle('fill', self.position.x, self.position.y, self.size)
  love.graphics.setColor(0, 0, 0)
  love.graphics.circle('line', self.position.x, self.position.y, self.size)
end

return Pawn