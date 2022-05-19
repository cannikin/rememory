local pd <const> = playdate
local gfx <const> = pd.graphics

class('Scoreboard').extends(gfx.sprite)

function Scoreboard:init(x, y, labels)
  -- scoreboard size and position
  self.paddingX = 12
  self.paddingY = 8
  self.posX = x
  self.posY = y

  -- setup list of labels
  self.labels = labels
  self.foundMap = {}

  -- setup fonts
  self.halfFont = gfx.font.new('fonts/Roobert/Roobert-10-Bold-Halved')
  self.font = gfx.font.new('fonts/Roobert/Roobert-10-Bold')

  -- text sprite showing list of found matches
  self.text = gfx.sprite.new()
  self.text:setZIndex(20)
  self.text:setCenter(0, 0)
  self.text:moveTo(self.posX + self.paddingX, self.posY + self.paddingY)
  self.text:add()

  self:drawBackground()
  self:update()
end

-- only called when a match is found
function Scoreboard:update(label)
  if label then
    self.foundMap[string.lower(label)] = true
  end

  local textImage = gfx.image.new(98, 240)
  gfx.pushContext(textImage)
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    for i=1,#self.labels do
      if self.foundMap[string.lower(self.labels[i])] then
        self.font:drawText(self.labels[i], 0, 19 * (i - 1))
      else
        self.halfFont:drawText(self.labels[i], 0, 19 * (i - 1))
      end
    end
  gfx.popContext()

  self.text:setImage(textImage)
end

function Scoreboard:remove()
  self.bg:remove()
  self.text:remove()
end

function Scoreboard:drawBackground(x, y)
  local bgImage = gfx.image.new(98, 240, gfx.kColorBlack)
  self.bg = gfx.sprite.new(bgImage)

  self.bg:setZIndex(10)
  self.bg:setCenter(0, 0)
  self.bg:moveTo(self.posX, self.posY)
  self.bg:add()
end
