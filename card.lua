local pd <const> = playdate
local gfx <const> = pd.graphics

class('Card').extends(gfx.sprite)

function Card:init(label, xId, yId, xPos, yPos)
  self.label = string.lower(label)
  self.xId = xId
  self.yId = yId
  -- keep track of which side is showing and which side was showing last frame
  -- so that we only need to update() if a change occurs
  self.side = 'back'
  self.lastSide = 'back'

  local back = gfx.image.new("images/cards/back")

  self:setImage(back)
  self:setCenter(0,0)
  self:moveTo(xPos, yPos)
end

function Card:update()
  if self.side ~= self.lastShow then
    if self.side == 'back' then
      local image = gfx.image.new("images/cards/back")
      self:setImage(image)
    elseif self.side == 'front' then
      local image = gfx.image.new("images/cards/"..self.label)
      self:setImage(image)
    end

    self.lastShow = self.side
  end
end

function Card:flip()
  print(self.label)
  if self.side == 'back' then
    self.side = 'front'
  else
    self.side = 'back'
  end
end
