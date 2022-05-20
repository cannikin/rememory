local pd <const> = playdate
local gfx <const> = pd.graphics

class('Popup').extends(Object)

function Popup:init(z)
  self.visible = false
  self.startZ = z

  -- timer to keep track of animating the popup box sliding on/off the screen
  self.timer = nil

  -- where to start/stop the animation when flying off the screen
  self.startX = -400
  self.endX = 400
  self.startY = 0
  self.endY = 0

  -- function to call when dismissed
  self.dismissCallback = function() end

  self.fonts = {
    title = gfx.font.new('fonts/Roobert/Roobert-11-Bold'),
    subtitle = gfx.font.new('fonts/Roobert/Roobert-10-Bold'),
    desc = gfx.font.new('fonts/Nontendo/Nontendo-Light'),
    url = gfx.font.new('fonts/Roobert/Roobert-10-Bold')
  }
  self.sprites = {
    bg = gfx.sprite.new(),
    window = gfx.sprite.new(),
    icon = gfx.sprite.new(),
    title = gfx.sprite.new(),
    subtitle = gfx.sprite.new(),
    desc = gfx.sprite.new(),
    url = gfx.sprite.new()
  }
  self.spritePositions = {
    bg = { x = 0, y = 0 },
    window = { x = 0, y = 0 },
    icon = { x = 56, y = 50 },
    title = { x = 162, y = 48 },
    subtitle = { x = 162, y = 71 },
    desc = { x = 162, y = 96 },
    url = { x = 57, y = 160 }
  }

  -- setup sprite positions once so we don't have to worry about it again
  self.sprites.bg:setZIndex(self.startZ)
  self.sprites.bg:setCenter(0,0)
  self.sprites.bg:moveTo(self.spritePositions.bg.x, self.spritePositions.bg.y)

  self.sprites.window:setZIndex(self.startZ + 1)
  self.sprites.window:setCenter(0,0)
  self.sprites.window:moveTo(self.spritePositions.window.x + self.startX, self.spritePositions.window.y + self.startY)

  self.sprites.icon:setZIndex(self.startZ + 2)
  self.sprites.icon:setCenter(0, 0)
  self.sprites.icon:moveTo(self.spritePositions.icon.x + self.startX, self.spritePositions.icon.y + self.startY)

  self.sprites.url:setZIndex(self.startZ + 3)
  self.sprites.url:setCenter(0, 0)
  self.sprites.url:moveTo(self.spritePositions.url.x + self.startX, self.spritePositions.url.y + self.startY)

  self.sprites.title:setZIndex(self.startZ + 4)
  self.sprites.title:setCenter(0, 0)
  self.sprites.title:moveTo(self.spritePositions.title.x + self.startX, self.spritePositions.title.y + self.startY)

  self.sprites.subtitle:setZIndex(self.startZ + 5)
  self.sprites.subtitle:setCenter(0, 0)
  self.sprites.subtitle:moveTo(self.spritePositions.subtitle.x + self.startX, self.spritePositions.subtitle.y + self.startY)

  self.sprites.desc:setZIndex(self.startZ + 6)
  self.sprites.desc:setCenter(0, 0)
  self.sprites.desc:moveTo(self.spritePositions.desc.x + self.startX, self.spritePositions.desc.y + self.startY)
end

function Popup:draw(data, blurred)

  -- bg
  self.sprites.bg:setImage(blurred)

  -- window
  local window <const> = gfx.image.new("images/popup")
  self.sprites.window:setImage(window)

  -- icon
  local icon <const> = gfx.image.new("images/popups/"..(data.icon or string.lower(data.title)))
  self.sprites.icon:setImage(icon)

  -- url
  local urlImage = gfx.image.new(100, 30)
  gfx.pushContext(urlImage)
    gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
    self.fonts.desc:drawTextAligned(data.url, 44, 0, kTextAlignment.center)
  gfx.popContext()
  self.sprites.url:setImage(urlImage)

  -- title
  if data.infoTitle or data.title then
    local titleImage = gfx.image.new(192, 24)
    gfx.pushContext(titleImage)
      gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
      self.fonts.title:drawText(data.infoTitle or data.title, 0, 0)
    gfx.popContext()
    self.sprites.title:setImage(titleImage)
  end

  -- subtitle
  if data.subtitle then
    local subtitleImage = gfx.image.new(192, 20)
    gfx.pushContext(subtitleImage)
      gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
      self.fonts.subtitle:drawText(data.subtitle, 0, 0)
    gfx.popContext()
    self.sprites.subtitle:setImage(subtitleImage)
  end

  -- description
  if data.desc then
    local descImage = gfx.image.new(192, 100)
    gfx.pushContext(descImage)
      gfx.setImageDrawMode(gfx.kDrawModeFillBlack)
      self.fonts.desc:drawText(data.desc, 0, 0, 3)
    gfx.popContext()
    self.sprites.desc:setImage(descImage)
  end
end

function Popup:update()
  if pd.buttonJustPressed(pd.kButtonA) or pd.buttonJustPressed(pd.kButtonB) then
    if (self.visible) then
      self:dismiss()
    end
  end
end

-- accepts the data to show in the popup as well as a callback to invoke when
-- the modal is dismissed
function Popup:show(data, callback)
  self.dismissCallback = callback

  local screen = gfx.getDisplayImage()
  local blurred = screen:blurredImage(2, 1, gfx.image.kDitherTypeDiagonalLine, false)

  self:draw(data, blurred)

  -- add sprites to render stack
  for name, sprite in pairs(self.sprites) do
    self.sprites[name]:add()
  end

  -- animate popup flying in
  self.timer = pd.timer.new(800, -400, 0, pd.easingFunctions.outBack)
  self.timer.updateCallback = function(timer)
    for name, sprite in pairs(self.sprites) do
      if name ~= 'bg' then
        sprite:moveTo(self.spritePositions[name].x + timer.value, sprite.y)
      end
    end
  end

  self.visible = true
end

function Popup:dismiss()
  self.timer = pd.timer.new(400, 0, 400, pd.easingFunctions.inBack)
  self.timer.updateCallback = function(timer)
    for name, sprite in pairs(self.sprites) do
      if name ~= 'bg' then
        sprite:moveTo(self.spritePositions[name].x + timer.value, sprite.y)
      end
    end
  end

  -- remove sprites from the stack
  self.timer.timerEndedCallback = function()
    for name, sprite in pairs(self.sprites) do
      sprite:remove()
    end

    -- get sprites back over to the left side
    for name, sprite in pairs(self.sprites) do
      if name ~= 'bg' then
        sprite:moveTo(self.spritePositions[name].x + self.startX, self.spritePositions[name].y + self.startY)
      end
    end

    self.dismissCallback()

    self.visible = false
  end
end
