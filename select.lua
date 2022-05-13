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

  local image = gfx.image.new("images/select")
  assert(image)

  self:setImage(image)
  self:setCenter(0,0)
  self:moveTo(options.startX, options.startY)
  self:add()
end

function Select:update()
  Select.super.update(self)

  if pd.buttonJustPressed(pd.kButtonUp) then
    if self.selected.row - 1 >= 1 then
      self.selected.row -= 1
    else
      -- shake selection sprite
    end
  end

  if pd.buttonJustPressed(pd.kButtonRight) then
    if self.selected.col + 1 <= self.cols then
      self.selected.col += 1
    else
      -- shake
    end
  end

  if pd.buttonJustPressed(pd.kButtonDown) then
    if self.selected.row + 1 <= self.rows then
      self.selected.row += 1
    else
      -- shake
    end
  end

  if pd.buttonJustPressed(pd.kButtonLeft) then
    if self.selected.col - 1 >= 1 then
      self.selected.col -= 1
    else
      -- shake
    end
  end

  self:moveSelection()
end

function Select:moveSelection()
  local newX = self.colWidth * (self.selected.col - 1) + (self.gap * self.selected.col) - (self.width - self.colWidth) / 2
  local newY = self.rowHeight * (self.selected.row - 1) + (self.gap * self.selected.row) - (self.height - self.rowHeight) / 2

  self:moveTo(newX, newY)
end

function Select:which()
  return self.selected
end
