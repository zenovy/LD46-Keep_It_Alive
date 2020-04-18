vector = require "lib/vector"

Pawn = require "Pawn"
EnthusiasmMeter = require "EnthusiasmMeter"

local fps = 0

local debugMode = true

local mousePosition = vector()

local lastTime = nil

local pawnList = {}

function love.load()
  if arg[#arg] == "-debug" then require("mobdebug").start() end -- Enables debugging in ZeroBrane
  
  table.insert(pawnList, Pawn:new({position = vector(50, 50)}))
  table.insert(pawnList, Pawn:new({position = vector(25, 25)}))
  enthusiasmMeter = EnthusiasmMeter:new()

end

function love.update(dt)
  local enthusiasmSum = 0
  for _, pawn in pairs(pawnList) do
    enthusiasmSum = enthusiasmSum + pawn.enthusiasm
  end
  enthusiasmSum = enthusiasmSum / #pawnList
  
  enthusiasmMeter.percentFilled = enthusiasmSum
  mousePosition.x, mousePosition.y = love.mouse.getPosition()
  fps = math.ceil(1 / dt)
  if not lastTime then lastTime = love.timer.getTime() end
  if (love.timer.getTime() - lastTime) > 1 then
    local rand = math.random()
    if rand < enthusiasmMeter.percentFilled then
      local x = math.random() * 300
      local y = math.random() * 300
      table.insert(pawnList, Pawn:new({position = vector(x, y)}))
    end
    
    lastTime = nil
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
