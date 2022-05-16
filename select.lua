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

  -- keep track if something is in the process of shaking
  self.shakeTimer = nil

  local image = gfx.image.new("images/select")
  assert(image)

  self:setImage(image)
  self:setCenter(0,0)
  self:moveTo(options.startX, options.startY)
  self:add()
end

function Select:update()
  Select.super.update(self)

  -- ignore inputs if select box is currently shaking
  if (self.shakeTimer or self.moveTimer) then
    return
  end

  -- TODO: skip cards that are missing?

  if pd.buttonJustPressed(pd.kButtonUp) then
    if self.selected.row - 1 >= 1 then
      self.selected.row -= 1
    else
      self:shake('up')
    end
  end

  if pd.buttonJustPressed(pd.kButtonRight) then
    if self.selected.col + 1 <= self.cols then
      self.selected.col += 1
    else
      self:shake('right')
    end
  end

  if pd.buttonJustPressed(pd.kButtonDown) then
    if self.selected.row + 1 <= self.rows then
      self.selected.row += 1
    else
      self:shake('down')
    end
  end

  if pd.buttonJustPressed(pd.kButtonLeft) then
    if self.selected.col - 1 >= 1 then
      self.selected.col -= 1
    else
      self:shake('left')
    end
  end

  if crankTicks == 1 then
    -- clockwise
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

function Select:shake(dir)
  if (self.shakeTimer) then
    return
  end

  local startX = self.x
  local startY = self.y

  if dir == 'left-right' then
    self.shakeTimer = pd.timer.new(100, -3, 3, pd.easingFunctions.linear)
    self.shakeTimer.reverses = true
  else
    self.shakeTimer = pd.timer.new(100, 0, 2, pd.easingFunctions.linear)
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
      self:moveTo(startX + timer.value, self.y)
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

  local newX = self.colWidth * (self.selected.col - 1)
  -- gap between cols
  newX += self.gap * self.selected.col - (self.width - self.colWidth) / 2
  local newY = self.rowHeight * (self.selected.row - 1)
  -- gap between rows
  newY += self.gap * self.selected.row - (self.height - self.rowHeight) / 2

  if math.ceil(self.x) ~= newX then
    -- horizontal
    self.moveTimer = pd.timer.new(150, self.x, newX, pd.easingFunctions.outQuad)
    self.moveTimer.updateCallback = function(timer)
      self:moveTo(math.ceil(timer.value), self.y)
    end
    self.moveTimer.timerEndedCallback = function()
      self:moveTo(newX, newY)
      self.moveTimer = nil
    end
  elseif math.ceil(self.y) ~= newY then
    -- vertical
    self.moveTimer = pd.timer.new(150, self.y, newY, pd.easingFunctions.outQuad)
    self.moveTimer.updateCallback = function(timer)
      self:moveTo(self.x, math.ceil(timer.value))
    end
    self.moveTimer.timerEndedCallback = function()
      self:moveTo(newX, newY)
      self.moveTimer = nil
    end
  end
end

function Select:which()
  return self.selected
end
