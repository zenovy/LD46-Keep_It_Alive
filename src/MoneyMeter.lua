Constants = require "Constants"
GameData = require "GameData"

MoneyMeter = {amount = Constants.startingCash}

function MoneyMeter:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  o.x = love.graphics.getWidth() - 150
  o.y = 30
  return o
end

function MoneyMeter:draw(numPawns)
  love.graphics.setColor(1, 1, 1)
  love.graphics.setFont(GameData.feedbackFont)
  love.graphics.print('$' .. tostring(self.amount), self.x, self.y)
  love.graphics.print('Guests: ' .. tostring(numPawns), self.x, self.y + 22)
  love.graphics.print('Time Left: ' .. math.ceil(GameData.timeLeft), self.x, self.y + 44)
  love.graphics.setFont(GameData.regularFont)
end

return MoneyMeter