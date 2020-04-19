vector = require "lib/vector"

Pawn = require "Pawn"
Boost = require "Boost"
EnthusiasmMeter = require "EnthusiasmMeter"
MoneyMeter = require "MoneyMeter"
BoostSelectionMenu = require "BoostSelectionMenu"

Constants = require "Constants"
UtilFuncs = require "UtilFuncs"

-- Debug variables
local fps = 0
local debugMode = false

local boostList = Boost.boostList
local selectedBoostNum = 1
local boostSelectionMenu = nil

-- Game state variables
local lastTime = nil
local lose = false

local pawnList = {}
local cursorList = {}
local furniture = {}
local floor

function love.load()
  math.randomseed(os.time())
  if arg[#arg] == "-debug" then require("mobdebug").start() end -- Enables debugging in ZeroBrane

  -- Load images assets
  floor = love.graphics.newImage('assets/floor.png')
  local couch = love.graphics.newImage('assets/couch.png')
  local carpet = love.graphics.newImage('assets/carpet.png')

  -- Cursors (not supported in love.js)
--  local balloonCursor = love.mouse.newCursor('assets/balloon-cursor.png', 20, 20)
--  local pizzaCursor = love.mouse.newCursor('assets/pizza-cursor.png', 16, 16)
--  local stereoCursor = love.mouse.newCursor('assets/music-note.png', 24, 24)
--  cursorList = {nil, pizzaCursor, balloonCursor, stereoCursor}

  -- Fonts
  regularFont = love.graphics.getFont()
  feedbackFont = love.graphics.newFont(Constants.feedbackFontSize)
  bigFont = love.graphics.newFont(Constants.bigFontSize)

  Boost.BoostLoad()

  -- Initial pawns
  table.insert(pawnList, Pawn:new({position = vector(230, 200), isActive = true, isInside = true}))
  table.insert(pawnList, Pawn:new({position = vector(400, 300), isActive = true, isInside = true}))

  -- Background assets
  table.insert(furniture, {x = 200, y = 160, scale = 4, image = couch})
  table.insert(furniture, {x = 350, y = 200, scale = 4, image = carpet})

  -- Initialize Subcomponents
  enthusiasmMeter = EnthusiasmMeter:new()
  moneyMeter = MoneyMeter:new()
  boostSelectionMenu = BoostSelectionMenu:new()

  boostList[selectedBoostNum].isSelected = true
end

function love.update(dt)
  if lose then return end

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

  for i, boost in pairs(boostList) do
    boost:update(dt, pawnList, love.mouse.getPosition())
  end
end

function love.draw()
  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(floor, Constants.room[1], Constants.room[2])
  for _, item in pairs(furniture) do
    love.graphics.draw(item.image, item.x, item.y, 0, item.scale, item.scale)
  end

  if cursorList[selectedBoostNum] then love.mouse.setCursor(cursorList[selectedBoostNum]) end

  local mousePosX, mousePosY = love.mouse.getPosition()
  
  -- Draw Pawns
  for _, pawn in pairs(pawnList) do
    pawn:draw()
  end
  
  -- Draw Pawns' Enthusiasm Bars
  for _, pawn in pairs(pawnList) do
    pawn:drawEnthusiasmBar()
  end
  
  for _, boost in pairs(boostList) do
    boost:draw(moneyMeter.amount, mousePosX, mousePosY)
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
  if not lose and button == 1 then
    boostList[selectedBoostNum]:place(moneyMeter)
  end
end

function love.keypressed(key)
  local selectedBoostInput = tonumber(key)

  if selectedBoostInput and (selectedBoostInput > 0 and selectedBoostInput <= #boostList) then
    boostSelectionMenu.selectedItem = selectedBoostInput
    selectedBoostNum = selectedBoostInput
    for i, boost in pairs(boostList) do
      boost.isSelected = (i == selectedBoostInput)
    end
  end
end
