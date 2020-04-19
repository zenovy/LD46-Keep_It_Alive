local Constants = require "Constants"
local GameData = require "GameData"

EndMenu = {}

local ORIGIN = {20, 140}
local BOTTOM_PADDING = 20
local LINE_HEIGHT = 30

local WIN_SENTENCES = {
  "You Won!",
  "Chats Had: ",
  "Pizzas Consumed: ",
  "Balloons Released: ",
  "Stereos Bought: ",
  "Score Breakdown: ",
  "Guests ",
  "Enthusiasm ",
  "Money ",
  "Total Score: ",
}

local LOSE_SENTENCES = {
  "Everyone left the party...",
}

function EndMenu:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function EndMenu:draw(isWin)
  love.graphics.setColor(0, 0, 0, 0.8)
  local width = GameData.windowWidth / 2 - 5
  local height = GameData.windowHeight - ORIGIN[2] - BOTTOM_PADDING
  love.graphics.rectangle('fill', ORIGIN[1], ORIGIN[2], width, height)
  love.graphics.setColor(1, 1, 1)
  love.graphics.setFont(GameData.feedbackFont)

  local chatTimes = (GameData[Constants.friendBoost.name .. 'Times'] and GameData[Constants.friendBoost.name .. 'Times']) or 0
  local pizzaTimes = (GameData[Constants.pizzaBoost.name .. 'Times'] and GameData[Constants.pizzaBoost.name .. 'Times']) or 0
  local balloonTimes = (GameData[Constants.balloonBoost.name .. 'Times'] and GameData[Constants.balloonBoost.name .. 'Times']) or 0
  local stereoTimes = (GameData[Constants.stereoBoost.name .. 'Times'] and GameData[Constants.stereoBoost.name .. 'Times']) or 0
  local pawnScore = #GameData.pawnList * 10
  local enthusiasmScore = math.ceil(GameData.enthusiasmScore * 100)
  local moneyScore = GameData.money
  local totalScore = pawnScore + enthusiasmScore + moneyScore
  if isWin then
    love.graphics.printf(WIN_SENTENCES[1], ORIGIN[1] + 5, ORIGIN[2] + 10, width)
    love.graphics.printf(WIN_SENTENCES[2] .. chatTimes, ORIGIN[1] + 5, ORIGIN[2] + 60, width)
    love.graphics.printf(WIN_SENTENCES[3] .. pizzaTimes, ORIGIN[1] + 5, ORIGIN[2] + 90, width)
    love.graphics.printf(WIN_SENTENCES[4] .. balloonTimes, ORIGIN[1] + 5, ORIGIN[2] + 120, width)
    love.graphics.printf(WIN_SENTENCES[5] .. stereoTimes, ORIGIN[1] + 5, ORIGIN[2] + 150, width)
    
    love.graphics.printf(WIN_SENTENCES[6], ORIGIN[1] + 5, ORIGIN[2] + 200, width)
    love.graphics.printf(WIN_SENTENCES[7] .. '+' .. pawnScore, ORIGIN[1] + 15, ORIGIN[2] + 230, width)
    love.graphics.printf(WIN_SENTENCES[8] .. '+' .. enthusiasmScore, ORIGIN[1] + 15, ORIGIN[2] + 260, width)
    love.graphics.printf(WIN_SENTENCES[9] .. '+' .. moneyScore, ORIGIN[1] + 15, ORIGIN[2] + 290, width)
    love.graphics.printf(WIN_SENTENCES[10] .. '+' .. totalScore, ORIGIN[1] + 5, ORIGIN[2] + 350, width)
  else
    love.graphics.printf(LOSE_SENTENCES[1], ORIGIN[1] + 5, ORIGIN[2] + 10, width)
    love.graphics.printf(WIN_SENTENCES[2] .. chatTimes, ORIGIN[1] + 5, ORIGIN[2] + 40, width)
    love.graphics.printf(WIN_SENTENCES[3] .. pizzaTimes, ORIGIN[1] + 5, ORIGIN[2] + 70, width)
    love.graphics.printf(WIN_SENTENCES[4] .. balloonTimes, ORIGIN[1] + 5, ORIGIN[2] + 100, width)
    love.graphics.printf(WIN_SENTENCES[5] .. stereoTimes, ORIGIN[1] + 5, ORIGIN[2] + 130, width)

    love.graphics.printf(WIN_SENTENCES[6], ORIGIN[1] + 5, ORIGIN[2] + 200, width)
    love.graphics.printf(WIN_SENTENCES[7] .. '+' .. pawnScore, ORIGIN[1] + 15, ORIGIN[2] + 230, width)
    love.graphics.printf(WIN_SENTENCES[8] .. '+' .. enthusiasmScore, ORIGIN[1] + 15, ORIGIN[2] + 260, width)
    love.graphics.printf(WIN_SENTENCES[9] .. '+' .. moneyScore, ORIGIN[1] + 15, ORIGIN[2] + 290, width)
    love.graphics.printf('Lose Factor: - 100', ORIGIN[1] + 15, ORIGIN[2] + 320, width)
    love.graphics.printf(WIN_SENTENCES[10] .. '+' .. (totalScore - 100), ORIGIN[1] + 5, ORIGIN[2] + 380, width)
  end
  
end

return EndMenu