local pd <const> = playdate
local gfx <const> = pd.graphics

class('Select').extends(gfx.sprite)

function Select:init(x, y)
  local image = gfx.image.new("images/select")
  assert(image)

  self:setImage(image)
  self:setCenter(0,0)
  self:moveTo(x, y)
  self:add()
end
