local Constants = require "Constants"
local Colors = require "Colors"

local WIDTH = 250
local HEIGHT = 110

local scale = 1.2

local padding = 10
local spacingBetweenIcons = 60

local icons = {}

BoostSelectionMenu = {
}

function BoostSelectionMenu:new()
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  o.x = (love.graphics.getWidth() - WIDTH) / 2
  o.y = 0
  o.selectedItem = 1
  table.insert(icons, {cost = Constants.friendBoost.cost, text = Constants.friendBoost.name, image = love.graphics.newImage('assets/hi.png')})
  table.insert(icons, {cost = Constants.pizzaBoost.cost, text = Constants.pizzaBoost.name, image = love.graphics.newImage('assets/pizza.png')})
  table.insert(icons, {cost = Constants.balloonBoost.cost, text = Constants.balloonBoost.name, image = love.graphics.newImage('assets/balloons.png')})
  table.insert(icons, {cost = Constants.stereoBoost.cost, text = Constants.stereoBoost.name, image = love.graphics.newImage('assets/music-note.png')})
  return o
end

function BoostSelectionMenu:update(dt)
end

function BoostSelectionMenu:draw()
  love.graphics.setColor(Colors.menuBackground)
  love.graphics.rectangle('fill', self.x, self.y, WIDTH, HEIGHT)
  for i = 1, #icons do
    local xPos = self.x + padding + spacingBetweenIcons * (i - 1)
    local yPos = self.y + 30
    love.graphics.setColor(Colors.uiText)
    love.graphics.printf('$' .. tostring(icons[i].cost), xPos, yPos - 20, 50, "center")
    love.graphics.printf(icons[i].text, xPos, yPos - 5, 50, "center")
    love.graphics.printf('(' .. tostring(i) .. ')', xPos, yPos + 60, 50, "center")
    if i == self.selectedItem then
      love.graphics.setColor(Colors.uiText)
    else
      love.graphics.setColor(Colors.dimmedMenuItem)
    end
    love.graphics.draw(icons[i].image, xPos, yPos + 10, 0, scale, scale)
  end
end

return BoostSelectionMenu