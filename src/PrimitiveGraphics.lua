

function drawBalloon(x, y, size, color)
  love.graphics.setColor(1, 1, 1)
  love.graphics.line(x, y, x, y + size * 5)
  love.graphics.setColor(unpack(color))
  love.graphics.ellipse('fill', x, y, size, size * 1.2)
end

return {
  drawBalloon = drawBalloon
}
