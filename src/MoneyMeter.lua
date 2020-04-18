local padding = 30

MoneyMeter = {amount = 10}

function MoneyMeter:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  o.x = love.graphics.getWidth() - padding * 2
  o.y = padding
  return o
end

function MoneyMeter:draw()
  love.graphics.setColor(1, 1, 1)
  love.graphics.print('$: ' .. tostring(self.amount), self.x, self.y)
end

return MoneyMeter