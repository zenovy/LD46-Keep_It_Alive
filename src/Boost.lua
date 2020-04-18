
local defaultRadius = 100
local defaultLifetime = 2 -- seconds
local defaultCost = 20

Boost = {radius = defaultRadius, timeSincePlaced = 0, lifetime = defaultLifetime, cost = defaultCost}
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
end

return Boost