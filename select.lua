local pd <const> = playdate
local gfx <const> = pd.graphics

class('Select').extends(gfx.sprite)

function Select:init(options)
  self.cols = options.cols
  self.rows = options.rows
  self.colWidth = options.colWidth
  self.rowHeight = options.rowHeight
  self.gap = options.gap

  -- keep track of which col/row is currently selected
  self.selected = {}
  self.selected["col"] = 1
  self.selected["row"] = 1

  -- keep track if something is in the process of moving
  self.moveTimer = nil

  -- keep track of where we're currently going so that we can interrupt an
  -- animation and just move immediately there
  self.movingTo = {x = nil, y = nil}

  -- by default we want to animate the moving selector, but if we're using the
  -- crank we do *not* want to animate (feels weird)
  self.animateMove = true

  -- keep track if something is in the process of shaking
  self.shakeTimer = nil

  local image <const> = gfx.image.new("images/select")
  assert(image)

  self:setImage(image)
  self:setCenter(0,0)
  self:moveTo(options.startX, options.startY)
  self:add()
end

function Select:update()
  Select.super.update(self)

  -- ignore inputs if select box is currently shaking
  if (self.shakeTimer) then
    return
  end

  -- TODO: skip cards that are missing?

  if pd.buttonJustPressed(pd.kButtonUp) then
    self.animateMove = true
    self:snapTo()

    if self.selected.row - 1 >= 1 then
      self.selected.row -= 1
    else
      self:shake('up')
    end
  end

  if pd.buttonJustPressed(pd.kButtonRight) then
    self.animateMove = true
    self:snapTo()

    if self.selected.col + 1 <= self.cols then
      self.selected.col += 1
    else
      self:shake('right')
    end
  end

  if pd.buttonJustPressed(pd.kButtonDown) then
    self.animateMove = true
    self:snapTo()

    if self.selected.row + 1 <= self.rows then
      self.selected.row += 1
    else
      self:shake('down')
    end
  end

  if pd.buttonJustPressed(pd.kButtonLeft) then
    self.animateMove = true
    self:snapTo()

    if self.selected.col - 1 >= 1 then
      self.selected.col -= 1
    else
      self:shake('left')
    end
  end

  if crankTicks == 1 then
    -- clockwise
    self.animateMove = false

    self.selected.col += 1
    if self.selected.col > self.cols then
      self.selected.col = 1
      self.selected.row += 1
    end
    -- reset to top left if running off the bottom right corner
    if self.selected.row > self.rows then
      self.selected.row = 1
    end
  elseif crankTicks == -1 then
    -- counter clockwise
    self.animateMove = false

    self.selected.col -= 1
    if self.selected.col < 1 then
      self.selected.col = self.cols
      self.selected.row -= 1
    end
    -- reset to bottom right if running off the top left corner
    if self.selected.row < 1 then
      self.selected.row = self.rows
    end
  end

  self:moveSelection()
end

-- if we're in the process of moving, immediately move there and cancel any
-- timers that may be running
function Select:snapTo()
  if (self.movingTo.x) then
    self:moveTo(self.movingTo.x, self.movingTo.y)
    self.movingTo.x = nil
    self.movingTo.y = nil
  end
  if self.moveTimer then
    self.moveTimer:remove()
    self.moveTimer = nil
  end
end

function Select:shake(dir)
  -- if moving, stop that and get ready for shake
  if (self.moveTimer) then
    self:snapTo()
  end

  -- already shaking, don't do it again
  if (self.shakeTimer) then
    return
  end

  local startX <const> = self.x
  local startY <const> = self.y

  if dir == 'left-right' then
    self.shakeTimer = pd.timer.new(75, startX-3, startX+3, pd.easingFunctions.linear)
    self.shakeTimer.reverses = true
  else
    self.shakeTimer = pd.timer.new(75, 0, 3, pd.easingFunctions.linear)
    self.shakeTimer.reverses = true
  end

  self.shakeTimer.updateCallback = function(timer)
    if dir == 'up' then
      self:moveTo(self.x, startY - timer.value)
    elseif dir == 'down' then
      self:moveTo(self.x, startY + timer.value)
    elseif dir == 'left' then
      self:moveTo(startX - timer.value, self.y)
    elseif dir == 'right' then
      self:moveTo(startX + timer.value, self.y)
    elseif dir == 'left-right' then
      self:moveTo(timer.value, self.y)
    end
  end
  self.shakeTimer.timerEndedCallback = function()
    self:moveTo(startX, startY)
    self.shakeTimer = nil
  end
end

function Select:moveSelection()
  if (self.moveTimer or self.shakeTimer) then
    return
  end

  -- figure out what the final destination of the selector will be
  self.movingTo.x = self.colWidth * (self.selected.col - 1)
  self.movingTo.x += self.gap * self.selected.col - (self.width - self.colWidth) / 2
  self.movingTo.y = self.rowHeight * (self.selected.row - 1)
  self.movingTo.y += self.gap * self.selected.row - (self.height - self.rowHeight) / 2

  -- don't bother with the rest of this if we're not actually moving
  if self.x == self.movingTo.x and self.y == self.movingTo.y then
    return
  end

  -- if we're not animating, just move there and call it a day
  if not self.animateMove then
    self:snapTo()
    return
  end

  -- if we got here then we're animating the move
  if self.x ~= self.movingTo.x then     -- horizontal
    self.moveTimer = pd.timer.new(150, self.x, self.movingTo.x, pd.easingFunctions.outQuad)
    self.moveTimer.updateCallback = function(timer)
      self:moveTo(timer.value, self.movingTo.y)
    end
  elseif self.y ~= self.movingTo.y then -- vertical
    self.moveTimer = pd.timer.new(150, self.y, self.movingTo.y, pd.easingFunctions.outQuad)
    self.moveTimer.updateCallback = function(timer)
      self:moveTo(self.movingTo.x, timer.value)
    end
  end

  -- when the timer ends, snap to the end point (timer may have ended on some
  -- random decimal, close to but not exactly the end point)
  if self.moveTimer then
    self.moveTimer.timerEndedCallback = function()
      self:snapTo()
    end
  end
end

function Select:which()
  return self.selected
end
