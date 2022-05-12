local pd <const> = playdate
local gfx <const> = pd.graphics

class('Card').extends(gfx.sprite)

function Card:init(xId, yId, xPos, yPos)
  self.xId = xId
  self.yId = yId

  local image = gfx.image.new("images/card")

  self:setImage(image)
  self:setCenter(0,0)
  self:moveTo(xPos, yPos)
end

function Card:show()
  print('show', self.xId, self.yId)
end
