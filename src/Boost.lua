Constants = require "Constants"

local BALLOON_RADIUS = 6
local NUM_BALLOONS = 5

local DEFAULT_COLOR = {1, 1, 1}

Boost = {
  radius = Constants.defaultBoostRadius,
  lifetime = Constants.defaultBoostLifetime,
  cost = Constants.defaultBoostCost,
  hasEffect = false,
  timeSincePlaced = 0,
  color = DEFAULT_COLOR,
}
local originalBoost = Boost

function Boost:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  o.position = vector:new()
  return o
end

function Boost:update(dt, pawnList)
  self.timeSincePlaced = self.timeSincePlaced + dt
  if self.timeSincePlaced > self.lifetime then
    return true -- kill boost
  end

  for _, pawn in pairs(pawnList) do
    -- TODO this will need some polishing to get the distance from 'middle' of pawn right
    local pawnX = pawn.position.x
    local pawnY = pawn.position.y
    if math.sqrt((pawnX - self.position.x) ^ 2 + (pawnY - self.position.y) ^ 2) < self.radius then
      pawn.enthusiasm = math.min(1, pawn.enthusiasm + Constants.defaultBoostEnthusiasmRate * dt)
    end
  end
end

function Boost:draw()
  if self.timeSincePlaced > 0 then
    local pulseFactor = math.sin(self.timeSincePlaced * 10) * 0.2
    love.graphics.setColor(self.color[1] + pulseFactor, self.color[2] + pulseFactor, self.color[3] + pulseFactor, 0.5)
  else
    love.graphics.setColor(self.color[1], self.color[2], self.color[3], 0.8)
  end
  
  love.graphics.circle('fill', self.position.x, self.position.y, self.radius)
end

function Boost:toggleEffect()
  self.balloons = {}
  for i = 1, NUM_BALLOONS do
    local distanceFromCenter = math.random() * self.radius * 0.6 + self.radius * 0.2
    local degreeFromZero = math.random() * 2 * math.pi
    local x = self.position.x + math.cos(degreeFromZero) * distanceFromCenter
    local y = self.position.y + math.sin(degreeFromZero) * distanceFromCenter
    table.insert(self.balloons, {x = x, y = y, dy = 0, floatRate = math.random() * 0.1, color = {math.random(), math.random(), math.random()}})
  end
  self.hasEffect = true
end


local FriendBoost = Boost:new({radius = 40, color = {0, 1, 0}, cost = 5, lifetime = 2})
local BalloonBoost = Boost:new({lifetime = 6})
local PizzaBoost = Boost:new({radius = 40, color = {0, 1, 0}, cost = 5, lifetime = 2})

function BalloonBoost:draw()
  originalBoost.draw(self) -- for some reason can't just call Boost.draw(self)
  if self.hasEffect then
    for _, balloon in pairs(self.balloons) do
      love.graphics.setColor(1, 1, 1)
      love.graphics.setLineWidth(1)
      love.graphics.line(balloon.x, balloon.y, balloon.x, balloon.y + BALLOON_RADIUS * 5)
      love.graphics.setColor(unpack(balloon.color))
      love.graphics.circle('fill', balloon.x, balloon.y, BALLOON_RADIUS)
      balloon.dy = balloon.dy - 0.1 * balloon.floatRate
      balloon.y = balloon.y + balloon.dy
      balloon.floatRate = balloon.floatRate + math.random() * 0.1
    end
  end
end

return {
  BalloonBoost = BalloonBoost,
  FriendBoost = FriendBoost,
}
