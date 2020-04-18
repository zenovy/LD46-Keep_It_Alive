
local WIDTH = 400
local HEIGHT = 50

BoostSelectionMenu = {
}

function BoostSelectionMenu:new()
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  o.x = (love.graphics.getWidth() - WIDTH) / 2
  o.y = love.graphics.getHeight() - HEIGHT
  return o
end

function BoostSelectionMenu:update(dt)
end

function BoostSelectionMenu:draw()
  love.graphics.setColor(0.2, 0.2, 0.2)
  love.graphics.rectangle('fill', self.x, self.y, WIDTH, HEIGHT)
end

return BoostSelectionMenu