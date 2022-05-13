local pd <const> = playdate
local gfx <const> = pd.graphics

class('Card').extends(gfx.sprite)

function Card:init(xId, yId, xPos, yPos)
  self.xId = xId
  self.yId = yId
  self.side = 'back'
  self.lastSide = 'back'

  local image = gfx.image.new("images/card")

  self:setImage(image)
  self:setCenter(0,0)
  self:moveTo(xPos, yPos)
end

function Card:update()
  if self.side ~= self.lastShow then
    if self.side == 'back' then
      local image = gfx.image.new("images/card")
      self:setImage(image)
    elseif self.side == 'front' then
      local image = gfx.image.new("images/card-react")
      self:setImage(image)
    end
    self.lastShow = self.side
  end
end

function Card:show()
  print('show', self.xId, self.yId)
  if self.side == 'back' then
    self.side = 'front'
  else
    self.side = 'back'
  end
end
