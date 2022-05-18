local pd <const> = playdate
local gfx <const> = pd.graphics

class('Card').extends(gfx.sprite)

function Card:init(label, xId, yId, xPos, yPos)
  self.label = label
  self.xId = xId
  self.yId = yId
  -- keep track of which side is showing and which side was showing last frame
  -- so that we only need to update() if a change occurs
  self.side = 'back'
  self.visible = true

  self.back = gfx.image.new("images/cards/back")
  self.front = gfx.image.new("images/cards/"..string.lower(self.label))

  self:setImage(self.back)
  self:setCenter(0,0)
  self:moveTo(xPos, yPos)
end

function Card:update()
  Card.super.update(self)

  if self.side ~= self.lastShow then
    print('gonna flip')

    if self.side == 'back' then
      if inverted then self:setImage(self.front) else self:setImage(self.back) end
    elseif self.side == 'front' then
      if inverted then self:setImage(self.back) else self:setImage(self.front) end
    end

    self.lastShow = self.side
  end
end

function Card:remove()
  self.visible = false
  Card.super.remove(self)
end

function Card:flip(side)
  print('flip()')
  if (self.visible) then
    if side then
      print('set', side)
      self.side = side
    elseif self.side == 'back' then
      print('guessed front')
      self.side = 'front'
    else
      print('guessed back')
      self.side = 'back'
    end
  end
end

function Card:isShowing()
  return self.visible and self.side == 'front'
end
