Constants = require "Constants"
PrimitiveGraphics = require "PrimitiveGraphics"

local BALLOON_RADIUS = 6
local NUM_BALLOONS = 5

local TIME_TO_SHOW_NOT_ENOUGH = 1

local DEFAULT_COLOR = {1, 1, 1}

Boost = {
  radius = Constants.defaultBoostRadius,
  lifetime = Constants.defaultBoostLifetime,
  cost = Constants.defaultBoostCost,
  hasBeenPlaced = false,
  timeSincePlaced = 0,
  color = DEFAULT_COLOR,
  boostEnthusiasmRate = Constants.defaultBoostEnthusiasmRate,
}
local boostRef = Boost

function Boost:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  o.position = vector:new()
  return o
end

function Boost:update(dt, pawnList, mousePosX, mousePosY)
  if not self.isSelected then
    self.showNotEnough = false
    self.timeSinceShownNotEnough = 0
  end

  if not self.isSelected and not self.hasBeenPlaced then return end

  if self.isSelected and not self.hasBeenPlaced then
    self.position.x, self.position.y = mousePosX, mousePosY
  end

  if self.hasBeenPlaced then
    self.timeSincePlaced = self.timeSincePlaced + dt
    for _, pawn in pairs(pawnList) do
      -- TODO this will need some polishing on Pawn side to get the distance from 'middle' of pawn right
      if math.abs(pawn.position:dist(self.position)) < self.radius then
        pawn.enthusiasm = math.min(1, pawn.enthusiasm + self.boostEnthusiasmRate * dt)
      end
    end
  end
  
  if self.timeSincePlaced > self.lifetime then
    self.hasBeenPlaced = false
    self.timeSincePlaced = 0
  end

  if self.showNotEnough then
    self.timeSinceShownNotEnough = self.timeSinceShownNotEnough + dt
    if self.timeSinceShownNotEnough > TIME_TO_SHOW_NOT_ENOUGH then
      self.showNotEnough = false
      self.timeSinceShownNotEnough = 0
    end
  end

end

function Boost:draw(money, mousePosX, mousePosY)
  if not self.isSelected and not self.hasBeenPlaced then return end

  -- Draw outline if has already been placed OR not enough $
  if (self.hasBeenPlaced and self.isSelected) or (self.isSelected and self.cost > money) then
    love.graphics.setColor(self.color[1], self.color[2], self.color[3])
    love.graphics.setLineWidth(1)
    love.graphics.circle('line', mousePosX, mousePosY, self.radius)
  end

  local lineType = 'fill'
  if self.timeSincePlaced > 0 then
    -- Pulse the placed boosts
    local pulseFactor = math.sin(self.timeSincePlaced * 10) * 0.2
    love.graphics.setColor(self.color[1] + pulseFactor, self.color[2] + pulseFactor, self.color[3] + pulseFactor, 0.5)
  else
    lineType = (self.cost > money and 'line') or lineType
    
    love.graphics.setColor(self.color[1], self.color[2], self.color[3], 0.8)
  end

  love.graphics.circle(lineType, self.position.x, self.position.y, self.radius)

  -- Show how much it cost
  if self.timeSincePlaced > 0 and self.timeSincePlaced < 1 and self.cost > 0 then
    love.graphics.setColor(1, 0, 0)
    love.graphics.print('-$' .. tostring(self.cost), self.position.x + self.radius / 3, self.position.y - self.radius / 3)
  end

  if not self.hasBeenPlaced and self.showNotEnough then
    love.graphics.setColor(1, 0, 0)
    love.graphics.print('Not enough $', mousePosX + self.radius / 3, mousePosY - self.radius / 3)
  end

end

function Boost:place(moneyMeter)
  if moneyMeter.amount >= self.cost and not self.hasBeenPlaced then
    moneyMeter.amount = moneyMeter.amount - self.cost
    self.hasBeenPlaced = true

    -- TODO move into BalloonBoost derived method
    self.balloons = {}
    local balloonBrightnessFactor = 0.5
    for i = 1, NUM_BALLOONS do
      local spacingFactor = i / NUM_BALLOONS -- keeps an even distribution
      local distanceFromCenter = self.radius * spacingFactor
      local degreeFromZero = (2 * math.pi) * spacingFactor
      local x = self.position.x + math.cos(degreeFromZero) * distanceFromCenter
      local y = self.position.y + math.sin(degreeFromZero) * distanceFromCenter
      local color = {
        math.random() * (1 - balloonBrightnessFactor) + balloonBrightnessFactor,
        math.random() * (1 - balloonBrightnessFactor) + balloonBrightnessFactor,
        math.random() * (1 - balloonBrightnessFactor) + balloonBrightnessFactor,
      }
      table.insert(self.balloons, {x = x, y = y, dy = 0, floatRate = math.random() * 0.1, color = color})
    end
  elseif moneyMeter.amount < self.cost then
    self.showNotEnough = true
    self.timeSinceShownNotEnough = 0
  end

end

local FriendBoost = Boost:new({
    boostEnthusiasmRate = 0.2,
    color = {0, 1, 0},
    cost = 0,
    lifetime = 3,
    radius = 20,
  })

local BalloonBoost = Boost:new({
    boostEnthusiasmRate = 2,
    color = {0, 1, 1},
    cost = 20,
    lifetime = 2,
  })

local PizzaBoost = Boost:new({
    boostEnthusiasmRate = 1,
    color = {1, 0, 0},
    cost = 5,
    lifetime = 5,
    radius = 60,
  })

function BalloonBoost:draw(money, mousePosX, mousePosY)
  boostRef.draw(self, money, mousePosX, mousePosY) -- for some reason can't just call Boost.draw(self)
  if self.hasBeenPlaced then
    for _, balloon in pairs(self.balloons) do
      PrimitiveGraphics.drawBalloon(balloon.x, balloon.y, BALLOON_RADIUS, balloon.color)
      balloon.dy = balloon.dy - 0.1 * balloon.floatRate
      balloon.y = balloon.y + balloon.dy
      balloon.floatRate = balloon.floatRate + math.random() * 0.1
    end
  end
end

return {
  FriendBoost,
  PizzaBoost,
  BalloonBoost,
}
