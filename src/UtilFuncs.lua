UtilFuncs = {
  clampToBounds = function(x, y, xBoundLow, yBoundLow, xBoundHigh, yBoundHigh)
    return math.min(math.max(x, xBoundLow), xBoundHigh), math.min(math.max(y, yBoundLow), yBoundHigh)
  end,
}

return UtilFuncs