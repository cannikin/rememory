local pd <const> = playdate
local gfx <const> = pd.graphics

class('Scoreboard').extends(gfx.sprite)

function Scoreboard:init(x, y)
  local bg = gfx.image.new(98, 240, gfx.kColorBlack)

  self:setImage(bg)
  self:setCenter(0, 0)
  self:moveTo(x, y)
end
