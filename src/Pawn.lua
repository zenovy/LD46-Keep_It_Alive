vector = require "lib/vector"

local baseSize = 12
local barHeadPadding = 5
local decayPerSecond = 0.01
local WALK_SPEED = 0.5
local MOVE_CHANCE = 0.2
local MOVE_DIST = 10

local PAWN_SPAWN = vector(300, 550)
local DOOR = vector(300, 500)
local BOUNDS = {100, 100, 500, 500}

Pawn = {position = PAWN_SPAWN:clone(), size = baseSize, enthusiasm = 0.5, isActive = false, isInside = false}
function Pawn:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Pawn:update(dt)
  if self.isActive then
    self.enthusiasm = math.max(0, self.enthusiasm - decayPerSecond * dt)
    local rand = math.random()
    if rand < MOVE_CHANCE * dt then
      -- base direction off same random; don't bias due to condition
      local direction = rand / MOVE_CHANCE / dt * 2 * math.pi
      local moveVec = vector(math.sin(direction), math.cos(direction))
      local moveVecActual = moveVec:normalized() * MOVE_DIST
      local attemptPos = self.position + moveVecActual
      self.position.x, self.position.y = clampToBounds(attemptPos.x, attemptPos.y, unpack(BOUNDS))
    end
  elseif self.isInside then
    local direction = self.targetPosition - self.position
    self.position = self.position + WALK_SPEED * direction:normalized() 
    if self.targetPosition:dist2(self.position) < 1 then self.isActive = true end
  else
    local direction = DOOR - self.position
    self.position = self.position + WALK_SPEED * direction:normalized()
    if DOOR:dist2(self.position) < 1 then self.isInside = true end
  end
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