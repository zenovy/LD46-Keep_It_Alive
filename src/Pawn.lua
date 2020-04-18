vector = require "lib/vector"

local baseSize = 12
local barHeadPadding = 5
local decayPerSecond = 0.01

Pawn = {position = vector(15, 15), size = baseSize, enthusiasm = 0.5}
function Pawn:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Pawn:update(dt)
  self.enthusiasm = math.max(0, self.enthusiasm - decayPerSecond * dt)
end

function Pawn:draw()
  -- BODY
  love.graphics.setColor(0.8, 0.8, 0)
  love.graphics.ellipse('fill', self.position.x, self.position.y + self.size * 1, self.size * 0.75, self.size * 2)
   -- Body outline so that pawns on top of eachother look good
  love.graphics.setColor(0, 0, 0)
  love.graphics.setLineWidth(1)
  love.graphics.ellipse('line', self.position.x, self.position.y + self.size * 1, self.size * 0.75, self.size * 2)
  
  -- HEAD
  love.graphics.setColor(1, 1, 1)
  love.graphics.circle('fill', self.position.x, self.position.y, self.size)
   -- Head outline to cut off head and body for style
  love.graphics.setColor(0, 0, 0)
  love.graphics.setLineWidth(2)
  love.graphics.circle('line', self.position.x, self.position.y, self.size)
end
function Pawn:drawEnthusiasmBar()
  local width = self.size
  local height = self.size / 3
  -- hollow rectangle in filled rectangle
  love.graphics.setColor(0.8, 0.8, 0)
  love.graphics.rectangle('fill', self.position.x - self.size / 2, self.position.y - barHeadPadding - self.size, width * self.enthusiasm, height)
  love.graphics.setLineWidth(1)
  love.graphics.setColor(1, 1, 1)
  love.graphics.rectangle('line', self.position.x - self.size / 2, self.position.y - barHeadPadding - self.size, width, height)
end

return Pawn