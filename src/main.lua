vector = require "lib/vector"

Pawn = require "Pawn"
EnthusiasmMeter = require "EnthusiasmMeter"

local fps = 0

local debugMode = true

local mousePosition = vector()

function love.load()
  if arg[#arg] == "-debug" then require("mobdebug").start() end -- Enables debugging in ZeroBrane
  
  pawn1 = Pawn:new({position = vector(50, 50)})
  pawn2 = Pawn:new({position = vector(25, 25)})
  enthusiasmMeter = EnthusiasmMeter:new()

end

function love.update(dt)
  mousePosition.x, mousePosition.y = love.mouse.getPosition()
  fps = math.ceil(1 / dt)
end

function love.draw()
  pawn1:draw()
  pawn2:draw()
  enthusiasmMeter:draw()
  if debugMode then
    love.graphics.print('FPS: ' .. tostring(fps))
  end
end
