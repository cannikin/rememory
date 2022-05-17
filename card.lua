local pd <const> = playdate
local gfx <const> = pd.graphics

class('Card').extends(gfx.sprite)

function Card:init(label, xId, yId, xPos, yPos)
  self.label = label
  self.xId = xId
  self.yId = yId
  -- keep track of which side is showing and which side was showing last frame
  -- so that we only need to update() if a change occurs
  self.side = 'back'
  self.lastSide = 'back'
  self.visible = true

  local back = gfx.image.new("images/cards/back")

  self:setImage(back)
  self:setCenter(0,0)
  self:moveTo(xPos, yPos)
end

function Card:update()
  Card.super.update(self)

  if self.side ~= self.lastShow then
    local image = nil

    if self.side == 'back' then
      if pd.isSimulator then
        image = gfx.image.new("images/cards/"..string.lower(self.label))
      else
        image = gfx.image.new("images/cards/back")
      end

      self:setImage(image)
    elseif self.side == 'front' then
      if pd.isSimulator then
        image = gfx.image.new("images/cards/back")
      else
        image = gfx.image.new("images/cards/"..string.lower(self.label))
      end

      self:setImage(image)
    end

    self.lastShow = self.side
  end
end

function Card:remove()
  self.visible = false
  Card.super.remove(self)
end

function Card:flip(side)
  if (self.visible) then
    if side then
      self.side = side
    elseif self.side == 'back' then
      self.side = 'front'
    else
      self.side = 'back'
    end
  end
end

function Card:isShowing()
  return self.visible and self.side == 'front'
end
