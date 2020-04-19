UtilFuncs = {
  clampToBounds = function(x, y, xBoundLow, yBoundLow, xBoundHigh, yBoundHigh)
    return math.min(math.max(x, xBoundLow), xBoundHigh), math.min(math.max(y, yBoundLow), yBoundHigh)
  end,
  randomColor = function() return {math.random(), math.random(), math.random()} end,
}

return UtilFuncs