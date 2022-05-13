local pd <const> = playdate
local gfx <const> = pd.graphics

class('Scoreboard').extends(gfx.sprite)

function Scoreboard:init(x, y)
  local paddingX = 8
  local paddingY = 8
  local bgImage = gfx.image.new(98, 240, gfx.kColorBlack)
  self.bg = gfx.sprite.new(bgImage)

  self.bg:setZIndex(10)
  self.bg:setCenter(0, 0)
  self.bg:moveTo(x, y)

  local textImage = gfx.image.new(98, 240)
  gfx.pushContext(textImage)
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    gfx.drawText("*RedwoodJS\nMemory*", 0, 0)

    gfx.drawText("React\nGraphQL\nPrisma", 0, 40)
  gfx.popContext()
  self.textTitle = gfx.sprite.new(textImage)
  self.textTitle:setZIndex(20)
  self.textTitle:setCenter(0, 0)
  self.textTitle:moveTo(x + paddingX, y + paddingY)

  self.bg:add()
  self.textTitle:add()
end
