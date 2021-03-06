vector = require "lib/vector"

local Constants = require "Constants"
local GameData = require "GameData"
local UtilFuncs = require "UtilFuncs"

local PAWN_SPAWN = vector(300, 550)

Pawn = {
  position = PAWN_SPAWN:clone(),
  size = Constants.basePawnSize,
  enthusiasm = Constants.initialEnthusiasm,
  isActive = false,
  isInside = false,
  isMoving = false,
  color = {0.5, 0.5, 0.5}
}

function Pawn:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Pawn:update(dt)
  if self.isActive then
    self.enthusiasm = math.max(0, self.enthusiasm - Constants.enthusiasmDecay * dt)
    if self.destination then
      self.position = self.position + (self.destination - self.position):normalized() * Constants.walkSpeed
      if self.position:dist2(self.destination) < 1 then
        self.destination = nil
      end
    else
      local rand = math.random()
      if rand < Constants.moveChance * dt then
        -- base direction off same random; don't bias due to condition
        local direction = rand / Constants.moveChance / dt * 2 * math.pi
        local moveVec = vector(math.sin(direction), math.cos(direction))
        local moveVecActual = moveVec:normalized() * Constants.moveDist * math.random()
        local attemptPos = self.position + moveVecActual
        self.destination = vector(UtilFuncs.clampToBounds(attemptPos.x, attemptPos.y, unpack(Constants.room)))
      end
    end
  elseif self.isInside then
    local direction = self.targetPosition - self.position
    self.position = self.position + Constants.walkSpeed * direction:normalized() 
    if self.targetPosition:dist2(self.position) < 1 then self.isActive = true end
  else
    local direction = Constants.door - self.position
    self.position = self.position + Constants.walkSpeed * direction:normalized()
    if Constants.door:dist2(self.position) < 1 then self.isInside = true end
  end
end

function Pawn:draw()
  -- BODY
  love.graphics.setColor(self.color)
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
  
  if not self.isInside then
    love.graphics.setColor(0, 1, 0, 0.8)
    love.graphics.print("+$" .. tostring(Constants.cashPerNewPawn), self.position.x + 10, self.position.y)
  end
end

function Pawn:drawEnthusiasmBar()
  local width = self.size
  local height = self.size / 3
  -- hollow rectangle in filled rectangle
  love.graphics.setColor(0.8, 0.8, 0)
  love.graphics.rectangle('fill', self.position.x - self.size / 2, self.position.y - Constants.pawnBarPadding - self.size, width * self.enthusiasm, height)
  love.graphics.setLineWidth(1)
  love.graphics.setColor(1, 1, 1)
  love.graphics.rectangle('line', self.position.x - self.size / 2, self.position.y - Constants.pawnBarPadding - self.size, width, height)
end

return Pawn