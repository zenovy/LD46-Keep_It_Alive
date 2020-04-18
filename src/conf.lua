function love.conf(t)
  t.window.title = "GAME"
  -- love.js seems to multiply width and height by 2 sometimes
  t.window.width = 400
  t.window.height = 300

  t.modules.joystick = false
  t.modules.physics = false
end

