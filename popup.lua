local pd <const> = playdate
local gfx <const> = pd.graphics

class('Popup').extends(gfx.sprite)

function Popup:init(z)
  self.visible = false
  self.sprites = {
    bg = gfx.sprite.new(),
    icon = gfx.sprite.new(),
    title = nil,
    subtitle = nil,
    text = nil,
    actions = nil
  }
  self.childSprites = {}
  self.startZ = z

  self:drawBackground()
end

function Popup:drawBackground()
  local image <const> = gfx.image.new("images/popup")
  assert(image)

  self.sprites.bg:setImage(image)
  self.sprites.bg:setZIndex(self.startZ)
  self.sprites.bg:setCenter(0,0)
end

function Popup:show(label)
  local image <const> = gfx.image.new("images/popups/"..string.lower(label))
  assert(image)

  -- show the background
  self.sprites.bg:add()

  -- add the logo
  self.sprites.icon:setImage(image)
  self.sprites.icon:setZIndex(self.startZ + 1)
  self.sprites.icon:setCenter(0, 0)
  self.sprites.icon:moveTo(56, 50)
  self.sprites.icon:add()

  self.visible = true
end

function Popup:hide()
  for name, sprite in pairs(self.sprites) do
    print('removing', name, sprite)
    sprite:remove()
  end

  self.visible = false
end

function Popup:update()
  if pd.buttonJustPressed(pd.kButtonA) then
    if (self.visible) then
      self:hide()
    end
  end

  if pd.buttonJustPressed(pd.kButtonB) then
    print('popup: B pressed')
  end
end
