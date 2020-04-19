local GameData = require "GameData"

StartMenu = {}

local ORIGIN = {20, 140}
local BOTTOM_PADDING = 20
local LINE_HEIGHT = 30

local SENTENCES = {
  "Welcome to 'Save The Party!'",
  "Keep the party alive until dawn using party supplies to fill the blue Enthusiasm meter (at top-right).",
  "Use number keys 1-4 to select a party supply, and click to place it.",
  "New guests will come to a more enthusiastic party and you'll earn a $10 cover charge each time. Try to have the most guests and the most money by dawn!",
  "> Press [SPACE] to begin.",
}


function StartMenu:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function StartMenu:draw()
  love.graphics.setColor(0, 0, 0, 0.8)
  local width = GameData.windowWidth / 2 - 5
  local height = GameData.windowHeight - ORIGIN[2] - BOTTOM_PADDING
  love.graphics.rectangle('fill', ORIGIN[1], ORIGIN[2], width, height)
  love.graphics.setColor(1, 1, 1)
  love.graphics.setFont(GameData.feedbackFont)
  -- Unfortunately, can't place sentences using for-loop due to text wrapping.
  love.graphics.printf(SENTENCES[1], ORIGIN[1] + 5, ORIGIN[2] + 10, width)
  love.graphics.printf(SENTENCES[2], ORIGIN[1] + 5, ORIGIN[2] + 40, width)
  love.graphics.printf(SENTENCES[3], ORIGIN[1] + 5, ORIGIN[2] + 120, width)
  love.graphics.printf(SENTENCES[4], ORIGIN[1] + 5, ORIGIN[2] + 180, width)
  love.graphics.printf(SENTENCES[5], ORIGIN[1] + 20, ORIGIN[2] + 340, width)
end

return StartMenu