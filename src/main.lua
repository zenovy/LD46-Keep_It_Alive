vector = require "lib/vector"

Pawn = require "Pawn"
Boost = require "Boost"
EnthusiasmMeter = require "EnthusiasmMeter"
MoneyMeter = require "MoneyMeter"
BoostSelectionMenu = require "BoostSelectionMenu"

StartMenu = require "StartMenu"
EndMenu = require "EndMenu"

Constants = require "Constants"
GameData = require "GameData"
UtilFuncs = require "UtilFuncs"

-- Debug variables
local fps = 0
local debugMode = false

local boostList = Boost.boostList
local selectedBoostNum = 1
local boostSelectionMenu = nil

-- Game state variables
local lastTime = nil

local cursorList = {}
local furniture = {}
local floor, door

local pawnSpawnMeter = 0

GameData.game = {
  isActive = false,
  isFinished = false,
  isWin = false,
}

function love.load()
  math.randomseed(os.time())
  if arg[#arg] == "-debug" then require("mobdebug").start() end -- Enables debugging in ZeroBrane
  GameData.windowWidth = love.graphics.getWidth()
  GameData.windowHeight = love.graphics.getHeight()

  -- Load images assets
  floor = love.graphics.newImage('assets/floor.png')
  door = love. graphics.newImage('assets/door.png')
  local couch = love.graphics.newImage('assets/couch.png')
  local carpet = love.graphics.newImage('assets/carpet.png')

  -- Cursors (not supported in love.js)
--  local balloonCursor = love.mouse.newCursor('assets/balloon-cursor.png', 20, 20)
--  local pizzaCursor = love.mouse.newCursor('assets/pizza-cursor.png', 16, 16)
--  local stereoCursor = love.mouse.newCursor('assets/music-note.png', 24, 24)
--  cursorList = {nil, pizzaCursor, balloonCursor, stereoCursor}

  -- Fonts
  GameData.regularFont = love.graphics.getFont()
  GameData.feedbackFont = love.graphics.newFont(Constants.feedbackFontSize)
  GameData.bigFont = love.graphics.newFont(Constants.bigFontSize)

  Boost.BoostLoad()

  -- Initial pawns
  GameData.pawnList = {}
  table.insert(GameData.pawnList, Pawn:new({position = vector(230, 200), isActive = true, isInside = true, color = UtilFuncs.randomColor()}))
  table.insert(GameData.pawnList, Pawn:new({position = vector(400, 300), isActive = true, isInside = true, color = UtilFuncs.randomColor()}))

  -- Background assets
  table.insert(furniture, {x = 200, y = 130, scale = 4, image = couch})
  table.insert(furniture, {x = 350, y = 200, scale = 4, image = carpet})

  -- Initialize Subcomponents
  enthusiasmMeter = EnthusiasmMeter:new()
  moneyMeter = MoneyMeter:new()
  boostSelectionMenu = BoostSelectionMenu:new()
  startMenu = StartMenu:new()
  endMenu = EndMenu:new()
end

function love.update(dt)
  if not GameData.game.isActive then return end
  GameData.timeLeft = GameData.timeLeft - dt
  if GameData.timeLeft <= 0 then
    GameData.timeLeft = 0
    GameData.game.isActive = false
    GameData.game.isFinished = true
    GameData.game.isWin = true
    return
  end

  local enthusiasmSum = 0
  for _, pawn in pairs(GameData.pawnList) do
    pawn:update(dt) -- not relevant to rest of what's going on here but no need
    enthusiasmSum = enthusiasmSum + pawn.enthusiasm
  end
  enthusiasmSum = enthusiasmSum / #GameData.pawnList
  GameData.enthusiasmScore = enthusiasmSum
  GameData.money = moneyMeter.amount
  
  if enthusiasmSum <= 0 then
    enthusiasmSum = 0
    GameData.game.isActive = false
    GameData.game.isFinished = true
    GameData.game.isWin = false
    return
  end

  enthusiasmMeter.percentFilled = math.max(0, enthusiasmSum)
  fps = math.ceil(1 / dt)

  for _, pawn in pairs(GameData.pawnList) do
    pawn:update(dt)
  end

  pawnSpawnMeter = pawnSpawnMeter + Constants.newPawnFactor * enthusiasmMeter.percentFilled * dt
  if pawnSpawnMeter >= 1 and math.random() < 0.8 then -- add in a bit of randomness
      local x, y = math.random(Constants.room[1], Constants.room[3]), math.random(Constants.room[2], Constants.room[4])
      table.insert(GameData.pawnList, Pawn:new({targetPosition = vector(x, y), color = UtilFuncs.randomColor()}))
      moneyMeter.amount = moneyMeter.amount + Constants.cashPerNewPawn
    pawnSpawnMeter = 0
  end

  for i, boost in pairs(boostList) do
    boost:update(dt, GameData.pawnList, love.mouse.getPosition())
  end
end

function love.draw()
  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(floor, Constants.room[1], Constants.room[2])
  for _, item in pairs(furniture) do
    love.graphics.draw(item.image, item.x, item.y, 0, item.scale, item.scale)
  end

  -- if cursorList[selectedBoostNum] then love.mouse.setCursor(cursorList[selectedBoostNum]) end

  local mousePosX, mousePosY = love.mouse.getPosition()
  
  -- Draw Pawns
  for _, pawn in pairs(GameData.pawnList) do
    pawn:draw()
  end
  
  -- Draw Pawns' Enthusiasm Bars
  for _, pawn in pairs(GameData.pawnList) do
    pawn:drawEnthusiasmBar()
  end
  
  for _, boost in pairs(boostList) do
    boost:draw(moneyMeter.amount, mousePosX, mousePosY)
  end
  
  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(door, Constants.door.x - 80, Constants.door.y - 40, 0, 2, 2)
  
  -- Draw UI
  enthusiasmMeter:draw()
  moneyMeter:draw(#GameData.pawnList)
  boostSelectionMenu:draw()

  -- Draw Debug UI
  if debugMode then
    love.graphics.print('FPS: ' .. tostring(fps))
  end

  if not GameData.game.isActive then
    if GameData.game.isFinished then
      endMenu:draw(GameData.game.isWin)
    else
      startMenu.draw()
    end
  end
end

function love.mousepressed(x, y, button)
  if GameData.game.isActive and button == 1 then
    boostList[selectedBoostNum]:place(moneyMeter)
  end
end

function love.keypressed(key)
  if (key == 'space') and not GameData.game.isActive then
    GameData.game.isActive = true
    GameData.game.isWin = false
    GameData.game.isFinished = false
    boostList[selectedBoostNum].isSelected = true
  end

  if GameData.game.isActive then
    local selectedBoostInput = tonumber(key)

    if selectedBoostInput and (selectedBoostInput > 0 and selectedBoostInput <= #boostList) then
      boostSelectionMenu.selectedItem = selectedBoostInput
      selectedBoostNum = selectedBoostInput
      for i, boost in pairs(boostList) do
        boost.isSelected = (i == selectedBoostInput)
      end
    end
  end
end
