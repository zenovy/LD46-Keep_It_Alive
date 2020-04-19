local vector = require "lib/vector"

Constants ={
  -- Balancing Constants
  cashPerNewPawn = 10,
  newPawnFactor = 0.5,
  initialEnthusiasm = 0.75,
  enthusiasmDecay = 0.04,
  defaultBoostCost = 20,
  defaultBoostRadius = 80,
  defaultBoostEnthusiasmRate = 1,
  defaultBoostLifetime = 1, -- seconds
  startingCash = 50,
  
  room = {100, 120, 700, 500},
  door = vector(300, 480),
  bigFontSize = 40,
  walkSpeed = 0.5,
  moveChance = 0.3, -- chance to move every second
  moveDist = 30,

  -- Visuals
  basePawnSize = 12,
  pawnBarPadding = 5,
  feedbackFontSize = 20,

  -- Boost Data
  friendBoost = {
    name = "Chat",
    boostEnthusiasmRate = 0.5,
    color = {0, 1, 0},
    cost = 0,
    lifetime = 3,
    radius = 20,
  },
  pizzaBoost = {
    name = "Pizza",
    boostEnthusiasmRate = 0.2,
    color = {0.8, 0, 0},
    cost = 5,
    lifetime = 4,
    radius = 70,
  },
  balloonBoost = {
    name = "Balloon",
    boostEnthusiasmRate = 0.4,
    color = {0, 1, 1},
    cost = 25,
    lifetime = 3,
    radius = 120,
  },
  stereoBoost = {
    name = "Stereo",
    boostEnthusiasmRate = 0.5,
    color = {0.5, 0.5, 0.5, 0.2},
    cost = 50,
    lifetime = 7,
    radius = 200,
  },
}

return Constants