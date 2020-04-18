vector = require "lib/vector"

Pawn = require "Pawn"
Boost = require "Boost"
EnthusiasmMeter = require "EnthusiasmMeter"
MoneyMeter = require "MoneyMeter"
BoostSelectionMenu = require "BoostSelectionMenu"

Constants = require "Constants"
UtilFuncs = require "UtilFuncs"

local fps = 0

local debugMode = true

local lastTime = nil

local pawnList = {}
local boostList = {}

local selectedBoost = nil
local selectedBoostType = nil
local placedBoostList = {}
local boostSelectionMenu = nil

local lose = false

function love.load()
  math.randomseed(os.time())
  if arg[#arg] == "-debug" then require("mobdebug").start() end -- Enables debugging in ZeroBrane
  
  table.insert(pawnList, Pawn:new({position = vector(230, 200), isActive = true}))
  table.insert(pawnList, Pawn:new({position = vector(400, 300), isActive = true}))
  enthusiasmMeter = EnthusiasmMeter:new()
  moneyMeter = MoneyMeter:new()
  boostSelectionMenu = BoostSelectionMenu:new()

  -- TODO: When picking boosts is implemented, this won't initialize here
  selectedBoost = Boost.FriendBoost:new()
  selectedBoostType = Boost.FriendBoost
  regularFont = love.graphics.getFont()
  bigFont = love.graphics.newFont(Constants.bigFontSize)
end

function love.update(dt)
  if lose then return end
  if selectedBoost then
    selectedBoost.position.x, selectedBoost.position.y = love.mouse.getPosition()
  end
  local enthusiasmSum = 0
  for _, pawn in pairs(pawnList) do
    pawn:update(dt) -- not relevant to rest of what's going on here but no need
    enthusiasmSum = enthusiasmSum + pawn.enthusiasm
  end
  enthusiasmSum = enthusiasmSum / #pawnList
  
  if enthusiasmSum < Constants.LOSE_PERCENT then
    lose = true
    return
  end

  enthusiasmMeter.percentFilled = math.max(0, enthusiasmSum)
  fps = math.ceil(1 / dt)

  for _, pawn in pairs(pawnList) do
    pawn:update(dt)
  end

  if not lastTime then lastTime = love.timer.getTime() end
  
  -- TODO: These events are jittery (at most 1/sec), should feel more fluid, also should decouple pawn shuffling w/ new pawns
  if (love.timer.getTime() - lastTime) > 1 then
    -- Insert a new pawn (chance based on enthusiasm)
    local rand = math.random()
    if rand < enthusiasmMeter.percentFilled * Constants.newPawnFactor then
      local x, y = math.random(Constants.room[1], Constants.room[3]), math.random(Constants.room[2], Constants.room[4])
      table.insert(pawnList, Pawn:new({targetPosition = vector(x, y)}))
      moneyMeter.amount = moneyMeter.amount + Constants.cashPerNewPawn
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
  -- Draw Constants.room
  love.graphics.setColor(0.4, 0, 0)
  love.graphics.rectangle('fill', Constants.room[1], Constants.room[2], Constants.room[3] - Constants.room[1], Constants.room[4] - Constants.room[2])
  
  -- Draw Boost under cursor
  if selectedBoost then
    selectedBoost:draw()
  end
  
  for _, boost in pairs(placedBoostList) do
    boost:draw()
  end
  
  -- Draw Pawns
  for _, pawn in pairs(pawnList) do
    pawn:draw()
  end
  
  -- Draw Pawns' Enthusiasm Bars
  for _, pawn in pairs(pawnList) do
    pawn:drawEnthusiasmBar()
  end

  
  -- Draw UI
  enthusiasmMeter:draw()
  moneyMeter:draw()
  boostSelectionMenu:draw()
  
  -- Draw Lose UI
  if lose then
    love.graphics.setFont(bigFont)
    love.graphics.print("YOU LOSE!", love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
    love.graphics.setFont(regularFont)
  end

  -- Draw Debug UI
  if debugMode then
    love.graphics.print('FPS: ' .. tostring(fps))
  end
end

function love.mousepressed(x, y, button)
  if not lose and button == 1 and selectedBoost and moneyMeter.amount >= selectedBoost.cost then
    moneyMeter.amount = moneyMeter.amount - selectedBoost.cost
    table.insert(placedBoostList, selectedBoost)
    selectedBoost:toggleEffect()
    selectedBoost = selectedBoostType:new() 
  end
end

function love.keypressed(key)
  if key == "1" then
    selectedBoostType = Boost.FriendBoost
  elseif key == "2" then
    selectedBoostType = Boost.BalloonBoost
  end
  selectedBoost = selectedBoostType:new()
end


