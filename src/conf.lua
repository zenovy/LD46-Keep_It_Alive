function love.conf(t)
  t.window.title = "Keep The Party Alive!"
  -- love.js seems to multiply width and height by 2 sometimes
  t.window.width = 800
  t.window.height = 600

  t.modules.joystick = false
  t.modules.physics = false
end
