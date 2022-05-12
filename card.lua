local pd <const> = playdate
local gfx <const> = pd.graphics

class('Card').extends(gfx.sprite)

function Card:init(x, y)
  local image = gfx.image.new("images/card")

  self:setImage(image)
  self:setCenter(0,0)
  self:moveTo(x, y)
end

function Card.show()
  print('show')
end
