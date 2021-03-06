local Constants = require "Constants"
local GameData = require "GameData"

local TIME_TO_SHOW_NOT_ENOUGH = 1 -- seconds until 'not enough $' text disappears

Boost = {
  radius = Constants.defaultBoostRadius,
  lifetime = Constants.defaultBoostLifetime,
  cost = Constants.defaultBoostCost,
  hasBeenPlaced = false,
  timeSincePlaced = 0,
  boostEnthusiasmRate = Constants.defaultBoostEnthusiasmRate,
  balloons = {},
}

local boostRef = Boost

function Boost:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  o.position = vector:new()
  return o
end

function BoostLoad()
  Boost.balloonSprites = {
    love.graphics.newImage('assets/balloon-red.png'),
    love.graphics.newImage('assets/balloon-blue.png'),
    love.graphics.newImage('assets/balloon-green.png'),
  }

  Boost.stereoSprites = {
    love.graphics.newImage('assets/stereo-1.png'),
    love.graphics.newImage('assets/stereo-2.png'),
    love.graphics.newImage('assets/stereo-3.png'),
    love.graphics.newImage('assets/stereo-4.png'),
  }
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
  if (self.hasBeenPlaced and self.isSelected) or (self.isSelected and self.cost > money) and GameData.game.isActive then
    love.graphics.setColor(self.color)
    love.graphics.setLineWidth(1)
    love.graphics.circle('line', mousePosX, mousePosY, self.radius)
  end

  local lineType = 'fill'
  if self.timeSincePlaced > 0 then
    -- Pulse the placed boosts
    local pulseFactor = math.sin(self.timeSincePlaced * 10) * 0.1
    love.graphics.setColor(self.color[1] + pulseFactor, self.color[2] + pulseFactor, self.color[3] + pulseFactor, 0.5)
  else
    lineType = (self.cost > money and 'line') or lineType
    
    love.graphics.setColor(self.color[1], self.color[2], self.color[3], 0.9)
  end

  love.graphics.circle(lineType, self.position.x, self.position.y, self.radius)
  love.graphics.setColor(0, 0, 0)
  if self.timeSincePlaced > 0 then
    love.graphics.setFont(GameData.feedbackFont)
    love.graphics.print(math.ceil(self.lifetime - self.timeSincePlaced), self.position.x - 5, self.position.y - 10)
    love.graphics.setFont(GameData.regularFont)
  end

  -- Show how much it cost
  if self.timeSincePlaced > 0 and self.timeSincePlaced < 1 and self.cost > 0 then
    love.graphics.setColor(1, 0, 0)
    love.graphics.setFont(GameData.feedbackFont)
    love.graphics.print('-$' .. tostring(self.cost), self.position.x + self.radius / 3, self.position.y - self.radius / 3)
    love.graphics.setFont(GameData.regularFont)
  end

  if not self.hasBeenPlaced and self.showNotEnough then
    love.graphics.setColor(1, 0, 0)
    love.graphics.setFont(GameData.feedbackFont)
    love.graphics.print('Not enough $', mousePosX + self.radius / 3, mousePosY - self.radius / 3)
    love.graphics.setFont(GameData.regularFont)
  end

end

function Boost:place(moneyMeter)
  if moneyMeter.amount >= self.cost and not self.hasBeenPlaced then
    moneyMeter.amount = moneyMeter.amount - self.cost
    self.hasBeenPlaced = true
    GameData[self.name .. 'Times'] = (GameData[self.name .. 'Times'] and GameData[self.name .. 'Times'] + 1) or 1
  elseif moneyMeter.amount < self.cost then
    self.showNotEnough = true
    self.timeSinceShownNotEnough = 0
  end
end

local FriendBoost = Boost:new(Constants.friendBoost)
local PizzaBoost = Boost:new(Constants.pizzaBoost)
local BalloonBoost = Boost:new(Constants.balloonBoost)
local StereoBoost = Boost:new(Constants.stereoBoost)

function BalloonBoost:draw(money, mousePosX, mousePosY)
  boostRef.draw(self, money, mousePosX, mousePosY) -- for some reason can't just call Boost.draw(self)
  if self.hasBeenPlaced then
    for _, balloon in pairs(self.balloons) do
      love.graphics.setColor(1, 1, 1)
      love.graphics.draw(balloon.image, balloon.x, balloon.y)
      balloon.dy = balloon.dy - 0.1 * balloon.floatRate
      balloon.y = balloon.y + balloon.dy
      balloon.floatRate = balloon.floatRate + math.random() * 0.1
    end
  end
end

function BalloonBoost:place(moneyMeter)
  if moneyMeter.amount >= self.cost and not self.hasBeenPlaced then
    self.balloons = {}
    for i = 1, #Boost.balloonSprites do
      local balloonImage = Boost.balloonSprites[i]
      local spacingFactor = i / #Boost.balloonSprites -- keeps an even distribution

      local distanceFromCenter = self.radius * spacingFactor * math.random()
      local degreeFromZero = (2 * math.pi) * spacingFactor * math.random()
      local x = self.position.x + math.cos(degreeFromZero) * distanceFromCenter
      local y = self.position.y + math.sin(degreeFromZero) * distanceFromCenter

      table.insert(self.balloons, {
          image = balloonImage,
          x = x,
          y = y,
          dy = 0,
          floatRate = math.random() * 0.1
        })
    end
  end
  boostRef.place(self, moneyMeter)
end

function StereoBoost:draw(money, mousePosX, mousePosY)
  boostRef.draw(self, money, mousePosX, mousePosY) -- for some reason can't just call Boost.draw(self)
  if self.hasBeenPlaced then
    local i = math.ceil(self.timeSincePlaced * 10) % 4 + 1
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(Boost.stereoSprites[i], self.position.x, self.position.y)
  end
end

return {
  BoostLoad = BoostLoad,
  boostList = {
    FriendBoost,
    PizzaBoost,
    BalloonBoost,
    StereoBoost,
  }
}
