local pd <const> = playdate
local gfx <const> = pd.graphics

class('Select').extends(gfx.sprite)

function Select:init(xPos, yPos)
  local image = gfx.image.new("images/select")
  assert(image)

  self:setImage(image)
  self:setCenter(0,0)
  self:moveTo(xPos, yPos)
  self:add()
end
