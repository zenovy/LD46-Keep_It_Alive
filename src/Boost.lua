
local defaultRadius = 100
local defaultLifetime = 2 -- seconds
local defaultCost = 20

local BALLOON_RADIUS = 6
local NUM_BALLOONS = 5

Boost = {radius = defaultRadius, timeSincePlaced = 0, lifetime = defaultLifetime, cost = defaultCost, hasEffect = false}
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
      pawn.enthusiasm = math.min(1, pawn.enthusiasm + 0.1 * dt)
    end
  end
end

function Boost:draw()
  -- TODO make them glow/pulse if they're placed - use sin(x) function iterator-type thing
  love.graphics.setColor(1, 1, 1, 0.5)
  love.graphics.circle('fill', self.position.x, self.position.y, self.radius)
  if self.hasEffect then
    for _, balloon in pairs(self.balloons) do
      love.graphics.setColor(1, 1, 1)
      love.graphics.line(balloon.x, balloon.y, balloon.x, balloon.y + BALLOON_RADIUS * 5)
      love.graphics.setColor(unpack(balloon.color))
      love.graphics.circle('fill', balloon.x, balloon.y, BALLOON_RADIUS)
      balloon.dy = balloon.dy - 0.1 * balloon.floatRate
      balloon.y = balloon.y + balloon.dy
      balloon.floatRate = balloon.floatRate + math.random() * 0.1
    end
  end
end

function Boost:toggleEffect()
  self.hasEffect = true
  self.balloons = {}
  for i = 1, NUM_BALLOONS do
    local distanceFromCenter = math.random() * self.radius * 0.6 + self.radius * 0.2
    local degreeFromZero = math.random() * 2 * math.pi
    local x = self.position.x + math.cos(degreeFromZero) * distanceFromCenter
    local y = self.position.y + math.sin(degreeFromZero) * distanceFromCenter
    table.insert(self.balloons, {x = x, y = y, dy = 0, floatRate = math.random() * 0.1, color = {math.random(), math.random(), math.random()}})
  end
end

return Boost