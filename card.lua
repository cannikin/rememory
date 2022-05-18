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
    if self.side == 'back' then
      if inverted then self:setImage(self.front) else self:setImage(self.back) end
    elseif self.side == 'front' then
      if inverted then self:setImage(self.back) else self:setImage(self.front) end
    end

    self.lastShow = self.side
  end
end

function Card:remove()
  local startX = self.x
  local startY = self.y
  local endX = self.x
  local endY = self.y
  local removeTimer = nil

  local dir = math.random(4)

  if dir == 1 then     -- top
    endY = -self.height
  elseif dir == 2 then -- right
    endX = 400
  elseif dir == 3 then -- bottom
    endY = 240
  elseif dir == 4 then -- left
    endX = -self.width
  end

  if dir % 2 == 0 then -- horizontal
    removeTimer = pd.timer.new(300, startX, endX, pd.easingFunctions.inBack)
    removeTimer.updateCallback = function(timer)
      self:moveTo(timer.value, startY)
    end
  else                -- vertical
    removeTimer = pd.timer.new(300, startY, endY, pd.easingFunctions.inBack)
    removeTimer.updateCallback = function(timer)
      self:moveTo(startX, timer.value)
    end
  end

  removeTimer.timerEndedCallback = function()
    self.visible = false
    Card.super.remove(self)
  end
end

function Card:flip(side)
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
