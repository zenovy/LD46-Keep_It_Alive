Constants = require "Constants"

MoneyMeter = {amount = Constants.startingCash}

function MoneyMeter:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  o.x = love.graphics.getWidth() - 105
  o.y = 30
  return o
end

function MoneyMeter:draw()
  love.graphics.setColor(1, 1, 1)
  love.graphics.setFont(feedbackFont)
  love.graphics.print('$: ' .. tostring(self.amount), self.x, self.y)
  love.graphics.setFont(regularFont)
end

return MoneyMeter