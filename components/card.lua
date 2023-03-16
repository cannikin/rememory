local pd <const> = playdate
local gfx <const> = pd.graphics

class('Card').extends(gfx.sprite)

function Card:init(id, xId, yId, xPos, yPos)
  self.id = id
  -- we only have 16 unique cards so if the id is 17 or greater then get us back
  -- to a 1-16 index
  if (id > 16) then
    self.id = id - 16
  end
  self.xId = xId
  self.yId = yId
  -- keep track of which side is showing and which side was showing last frame
  -- so that we only need to update() if a change occurs
  self.side = 'back'
  self.visible = true
  self.flipAnimationFrames = 2
  self.front = gfx.image.new("images/cards/card"..self.id)

  self:setImage(CARD_BACK)
  self:setCenter(0,0)
  self:moveTo(xPos, yPos)
end

function Card:update()
  Card.super.update(self)

  if self.side ~= self.lastShow then
    if self.side == 'back' then
      local timer = pd.frameTimer.new(#CARD_FLIP_FRAMES + 1)

      timer.updateCallback = function(timer)
        print(self.y)
        if timer.frame == 5 then
          if inverted then self:setImage(self.front) else self:setImage(CARD_BACK) end
        else
          self:setImage(CARD_FLIP_FRAMES[#CARD_FLIP_FRAMES + 1 - timer.frame])
        end
      end
    elseif self.side == 'front' then
      local timer = pd.frameTimer.new((#CARD_FLIP_FRAMES + 1) * self.flipAnimationFrames)

      timer.updateCallback = function(timer)
        print(self.y)
        if (timer.frame % self.flipAnimationFrames == 0) then
          local step = timer.frame / self.flipAnimationFrames

          if step == 5 then
            if inverted then self:setImage(CARD_BACK) else self:setImage(self.front) end
          else
            self:setImage(CARD_FLIP_FRAMES[step])
          end
        end
      end
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
      self.side = side
    elseif self.side == 'back' then
      self.side = 'front'
    else
      self.side = 'back'
    end
  end
end

function Card:isShowing()
  return self.visible and self.side == 'front'
end
