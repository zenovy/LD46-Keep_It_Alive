vector = require "lib/vector"

Pawn = require "Pawn"
EnthusiasmMeter = require "EnthusiasmMeter"

local fps = 0

local debugMode = true

local mousePosition = vector()

local lastTime = 0

local pawnList = {}

function love.load()
  if arg[#arg] == "-debug" then require("mobdebug").start() end -- Enables debugging in ZeroBrane
  
  table.insert(pawnList, Pawn:new({position = vector(50, 50)}))
  table.insert(pawnList, Pawn:new({position = vector(25, 25)}))
  enthusiasmMeter = EnthusiasmMeter:new()

end

function love.update(dt)
  mousePosition.x, mousePosition.y = love.mouse.getPosition()
  fps = math.ceil(1 / dt)
  if lastTime - love.timer.getTime() > 1 then
    
  end
end

function love.draw()
  for _, pawn in pairs(pawnList) do
    pawn:draw()
  end
  
  enthusiasmMeter:draw()
  if debugMode then
    love.graphics.print('FPS: ' .. tostring(fps))
  end
end
