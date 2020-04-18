vector = require "lib/vector"

Pawn = require "Pawn"
EnthusiasmMeter = require "EnthusiasmMeter"

local fps = 0

local debugMode = true

local mousePosition = vector()

local lastTime = nil

local pawnList = {}

local moveChance = 0.2
local moveDist = 10

function love.load()
  if arg[#arg] == "-debug" then require("mobdebug").start() end -- Enables debugging in ZeroBrane
  
  table.insert(pawnList, Pawn:new({position = vector(230, 200)}))
  table.insert(pawnList, Pawn:new({position = vector(400, 300)}))
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
  
  -- TODO: These events are jittery (at most 1/sec), should feel more fluid, also should decouple pawn shuffling w/ new pawns
  if (love.timer.getTime() - lastTime) > 1 then
    -- Insert a new pawn (chance based on enthusiasm)
    local rand = math.random()
    if rand < enthusiasmMeter.percentFilled then
      local x = math.random() * 300
      local y = math.random() * 300
      table.insert(pawnList, Pawn:new({position = vector(x, y)}))
    end

    -- Shuffle pawns around
    for _, pawn in pairs(pawnList) do
      local rand = math.random()
      if rand < moveChance then
        -- base direction off same random; don't bias due to condition
        local direction = rand / moveChance * 2 * math.pi
        local moveVec = vector(math.sin(direction), math.cos(direction))
        pawn.position = pawn.position + moveVec:normalized() * moveDist
      end
    end
    lastTime = nil
  end
end

function love.draw()
  local mousePositionX, mousePositionY = love.mouse.getPosition()

  love.graphics.setColor(1, 1, 1, 0.5)
  love.graphics.circle('fill', mousePositionX, mousePositionY, 50)

  for _, pawn in pairs(pawnList) do
    pawn:draw()
  end
  
  for _, pawn in pairs(pawnList) do
    pawn:drawEnthusiasmBar()
  end
  
  enthusiasmMeter:draw()
  if debugMode then
    love.graphics.print('FPS: ' .. tostring(fps))
  end
end

function love.mousepressed(x, y, button)
  if button == 1 then
    for _, pawn in pairs(pawnList) do
      -- TODO this will need some polishing to get the distance from 'middle' of pawn right
      local pawnX = pawn.position.x
      local pawnY = pawn.position.y
      if math.sqrt((pawnX - x) ^ 2 + (pawnY - y) ^ 2) < 50 then
        pawn.enthusiasm = 1
      end
    end
    
  end
  
end

