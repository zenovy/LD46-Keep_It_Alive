
local WIDTH = 400
local HEIGHT = 100

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
  o.y = love.graphics.getHeight() - HEIGHT
  o.selectedItem = 1
  table.insert(icons, {cost = 0, image = love.graphics.newImage('assets/hi.png')})
  table.insert(icons, {cost = 5, image = love.graphics.newImage('assets/pizza.png')})
  table.insert(icons, {cost = 20, image = love.graphics.newImage('assets/balloons.png')})
  table.insert(icons, {cost = 50, image = love.graphics.newImage('assets/music-note.png')})
  return o
end

function BoostSelectionMenu:update(dt)
end

function BoostSelectionMenu:draw()
  love.graphics.setColor(0.2, 0.2, 0.2)
  love.graphics.rectangle('fill', self.x, self.y, WIDTH, HEIGHT)
  love.graphics.setColor(0.7, 0.7, 0.7)
  for i = 1, #icons do
    local xPos = self.x + padding + spacingBetweenIcons * (i - 1)
    local yPos = self.y + 30
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf('$' .. tostring(icons[i].cost), xPos, yPos - 20, 50, "center")
    love.graphics.printf('(' .. tostring(i) .. ')', xPos, yPos + 50, 50, "center")
    if i == self.selectedItem then
      love.graphics.setColor(1, 1, 1)
    else
      love.graphics.setColor(0.5, 0.5, 0.5)
    end
    love.graphics.draw(icons[i].image, xPos, yPos, 0, scale, scale)
  end
end

return BoostSelectionMenu