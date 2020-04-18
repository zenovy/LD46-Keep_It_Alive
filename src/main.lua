vector = require "lib/vector"

Pawn = require "Pawn"
Boost = require "Boost"
EnthusiasmMeter = require "EnthusiasmMeter"

local fps = 0

local debugMode = true

local lastTime = nil

local pawnList = {}
local boostList = {}

local selectedBoost = nil
local placedBoostList = {}

local moveChance = 0.2
local moveDist = 10

function love.load()
  if arg[#arg] == "-debug" then require("mobdebug").start() end -- Enables debugging in ZeroBrane
  
  table.insert(pawnList, Pawn:new({position = vector(230, 200)}))
  table.insert(pawnList, Pawn:new({position = vector(400, 300)}))
  enthusiasmMeter = EnthusiasmMeter:new()

  -- TODO: When picking boosts is implemented, this won't initialize here
  selectedBoost = Boost:new()
end

function love.update(dt)
  if selectedBoost then
    selectedBoost.position.x, selectedBoost.position.y = love.mouse.getPosition()
  end
  local enthusiasmSum = 0
  for _, pawn in pairs(pawnList) do
    enthusiasmSum = enthusiasmSum + pawn.enthusiasm
  end
  enthusiasmSum = enthusiasmSum / #pawnList
  
  enthusiasmMeter.percentFilled = enthusiasmSum
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
  
  local deletedItemsIndices = {}
  -- Update enthusiasm in boost
  for i, boost in pairs(placedBoostList) do
    local killBoost = boost:update(dt, pawnList)
    if killBoost then table.insert(deletedItemsIndices, i) end
  end
  
  -- This is to avoid removing items until after iterating
  local mod = 0
  for i in pairs(deletedItemsIndices) do
    table.remove(placedBoostList, i - mod)
    mod = mod + 1
  end  
end

function love.draw()
  for _, pawn in pairs(pawnList) do
    pawn:draw()
  end
  
  for _, pawn in pairs(pawnList) do
    pawn:drawEnthusiasmBar()
  end

  if selectedBoost then
    selectedBoost:draw()
  end
  
  for _, boost in pairs(placedBoostList) do
    boost:draw()
  end
  
  enthusiasmMeter:draw()
  if debugMode then
    love.graphics.print('FPS: ' .. tostring(fps))
  end
end

function love.mousepressed(x, y, button)
  if button == 1 and selectedBoost then
    table.insert(placedBoostList, selectedBoost)
    selectedBoost = nil
    -- TODO remove below line - just for testing
    selectedBoost = Boost:new() 
  end
end

