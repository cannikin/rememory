local pd <const> = playdate
local gfx <const> = pd.graphics

class('Select').extends(gfx.sprite)

function Select:init(options)
  self.cols = options.cols
  self.rows = options.rows
  self.colWidth = options.colWidth
  self.rowHeight = options.rowHeight
  self.gap = options.gap
  self.selected = {}
  self.selected["col"] = 1
  self.selected["row"] = 1
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
  if (self.shakeTimer) then
    return
  end

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

  local crankDirection = pd.getCrankTicks(6)

  if crankDirection == 1 then
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
  elseif crankDirection == -1 then
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
  self.shakeTimer = pd.timer.new(100, 0, 2, pd.easingFunctions.linear)
  self.shakeTimer.updateCallback = function(timer)
    if dir == 'up' then
      self:moveTo(self.x, self.y - timer.value)
    elseif dir == 'down' then
      self:moveTo(self.x, self.y + timer.value)
    elseif dir == 'left' then
      self:moveTo(self.x - timer.value, self.y)
    elseif dir == 'right' then
      self:moveTo(self.x + timer.value, self.y)
    end
  end

  pd.timer.performAfterDelay(100, function()
    self.shakeTimer = nil
  end)
end

function Select:moveSelection()
  -- TODO: use timer to animate selection box moving
  local newX = self.colWidth * (self.selected.col - 1)
  local newXGap = self.gap * self.selected.col - (self.width - self.colWidth) / 2
  local newY = self.rowHeight * (self.selected.row - 1)
  local newYGap = self.gap * self.selected.row - (self.height - self.rowHeight) / 2

  self:moveTo(newX + newXGap, newY + newYGap)
end

function Select:which()
  return self.selected
end
