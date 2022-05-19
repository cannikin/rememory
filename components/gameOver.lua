local pd <const> = playdate
local gfx <const> = pd.graphics

class('GameOver').extends(Object)

function GameOver:init(matches, mismatches)
  self.visible = false
  self.startZ = 100
  self.matches = matches
  self.mismatches = mismatches

  self.fonts = {
    roobert24 = gfx.font.new('fonts/Roobert/Roobert-20-Medium'),
    roobert11 = gfx.font.new('fonts/Roobert/Roobert-11-Bold'),
    roobert10 = gfx.font.new('fonts/Roobert/Roobert-10-Bold'),
    nontendo = gfx.font.new('fonts/Nontendo/Nontendo-Light'),
  }
  self.sprites = {
    bg = gfx.sprite.new(),
    title = gfx.sprite.new(),
    stats = gfx.sprite.new(),
    substats = gfx.sprite.new(),
    again = gfx.sprite.new(),
    tip = gfx.sprite.new()
  }
  self.spritePositions = {
    bg = { x = 8, y = 8 },
    title = { x = 0, y = 30 },
    stats = { x = 0, y = 70 },
    substats = { x = 0, y = 106 },
    again = { x = 0, y = 136 },
    tip = { x = 0, y = 190 }
  }

  -- setup sprite positions once so we don't have to worry about it again
  self.sprites.bg:setZIndex(self.startZ)
  self.sprites.bg:setCenter(0,0)
  self.sprites.bg:moveTo(self.spritePositions.bg.x, self.spritePositions.bg.y)

  self.sprites.title:setZIndex(self.startZ + 1)
  self.sprites.title:setCenter(0, 0)
  self.sprites.title:moveTo(self.spritePositions.title.x, self.spritePositions.title.y)

  self.sprites.stats:setZIndex(self.startZ + 2)
  self.sprites.stats:setCenter(0, 0)
  self.sprites.stats:moveTo(self.spritePositions.stats.x, self.spritePositions.stats.y)

  self.sprites.substats:setZIndex(self.startZ + 3)
  self.sprites.substats:setCenter(0, 0)
  self.sprites.substats:moveTo(self.spritePositions.substats.x, self.spritePositions.substats.y)

  self.sprites.again:setZIndex(self.startZ + 4)
  self.sprites.again:setCenter(0, 0)
  self.sprites.again:moveTo(self.spritePositions.again.x, self.spritePositions.again.y)

  self.sprites.tip:setZIndex(self.startZ + 5)
  self.sprites.tip:setCenter(0, 0)
  self.sprites.tip:moveTo(self.spritePositions.tip.x, self.spritePositions.tip.y)
end

function GameOver:show(matches, mismatches)
  self:draw(matches, mismatches)

  for name, sprite in pairs(self.sprites) do
    self.sprites[name]:add()
  end

  self.visible = true
end

function GameOver:draw(matches, mismatches)
  -- background
  local bgImage = gfx.image.new(286, 224)
  gfx.pushContext(bgImage)
    -- fill
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRoundRect(0, 0, 286, 224, 6)

    -- stroke
    gfx.setLineWidth(3)
    gfx.setColor(gfx.kColorBlack)
    gfx.setStrokeLocation(gfx.kStrokeInside)
    gfx.drawRoundRect(0, 0, 286, 224, 6)
  gfx.popContext()

  self.sprites.bg:setImage(bgImage)

  -- title
  local titleImage = gfx.image.new(286, 40)
  gfx.pushContext(titleImage)
    self.fonts.roobert24:drawTextAligned("Great Memory!", titleImage.width/2, 0, kTextAlignment.center)
  gfx.popContext()
  self.sprites.title:setImage(titleImage)

  -- stats
  local time = pd.getElapsedTime()
  local minutes = math.floor(time / 60)

  local minuteText = "minutes"
  if minutes == 1 then
    minuteText = "minute"
  end

  local seconds = math.floor(time - minutes * 60)
  local secondText = "seconds"
  if seconds == 1 then
    secondText = "second"
  end

  local text = "You found "..math.floor(matches).." matches in \n"..minutes.." minutes and "..seconds.." seconds"
  local statsImage = gfx.image.new(286, 40)
  gfx.pushContext(statsImage)
    self.fonts.roobert10:drawTextAligned(text, statsImage.width/2, 0, kTextAlignment.center)
  gfx.popContext()
  self.sprites.stats:setImage(statsImage)

  local substatsImage = gfx.image.new(286, 40)
  gfx.pushContext(substatsImage)
    self.fonts.nontendo:drawTextAligned("(and found "..mismatches.." mismatched pairs)", substatsImage.width/2, 0, kTextAlignment.center)
  gfx.popContext()
  self.sprites.substats:setImage(substatsImage)

  local againImage = gfx.image.new(286, 40)
  gfx.pushContext(againImage)
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRoundRect(againImage.width/2 - 60, 0, 120, 36, 4)
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    self.fonts.roobert10:drawTextAligned("Try Again?", againImage.width/2, 10, kTextAlignment.center)
    gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
  gfx.popContext()
  self.sprites.again:setImage(againImage)

  local tipImage = gfx.image.new(286, 40)
  gfx.pushContext(tipImage)
    self.fonts.nontendo:drawTextAligned("Did you know you can turn off\ninfo cards and sounds in the Menu?", tipImage.width/2, 0, kTextAlignment.center)
  gfx.popContext()
  self.sprites.tip:setImage(tipImage)
end

function GameOver:update()
  if (self.visible and (pd.buttonJustPressed(pd.kButtonA) or pd.buttonJustPressed(pd.kButtonB))) then
    for i=1,#self.sprites do
      self.sprites[i]:remove()
    end
    restartGame()
  end
end
