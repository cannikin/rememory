-- Name this file `main.lua`. Your game can use multiple source files if you wish
-- (use the `import "myFilename"` command), but the simplest games can be written
-- with just `main.lua`.

-- You'll want to import these in just about every project you'll work on.

import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import "card"
import "select"

-- Declaring this "gfx" shorthand will make your life easier. Instead of having
-- to preface all graphics calls with "playdate.graphics", just use "gfx."
-- Performance will be slightly enhanced, too.
-- NOTE: Because it's local, you'll have to do it in every .lua source file.

local pd <const> = playdate
local gfx <const> = pd.graphics
-- instantiate a single card so we know its dimensions
local sampleCard <const> = Card(0,0)

-- setup playing board
cards = {}
local gap = 8

for i=1,6 do
  cards[i] = {}
  for j=1,4 do
    cards[i][j] = Card(sampleCard.width * (i - 1) + (gap * i), sampleCard.height * (j - 1) + (gap * j))
    cards[i][j]:add()
  end
end

-- setup selection rectangle
select = Select(5,5)

-- keep track of how far we should move the selection when the keyboard is used
moveSelectionX = select.width + 2
moveSelectionY = select.height + 2

-- We want an environment displayed behind our sprite.
-- There are generally two ways to do this:
-- 1) Use setBackgroundDrawingCallback() to draw a background image. (This is what we're doing below.)
-- 2) Use a tilemap, assign it to a sprite with sprite:setTilemap(tilemap),
--       and call :setZIndex() with some low number so the background stays behind
--       your other sprites.

-- local backgroundImage = gfx.image.new( "images/background1" )
-- assert( backgroundImage )
--
-- gfx.sprite.setBackgroundDrawingCallback(
--   function( x, y, width, height )
--     gfx.setClipRect( x, y, width, height ) -- let's only draw the part of the screen that's dirty
--     backgroundImage:draw( 0, 0 )
--     gfx.clearClipRect() -- clear so we don't interfere with drawing that comes after this
--   end
-- )


-- `playdate.update()` is the heart of every Playdate game.
-- This function is called right before every frame is drawn onscreen.
-- Use this function to poll input, run game logic, and move sprites.

function pd.update()

  -- Poll the d-pad and move our player accordingly.
  -- (There are multiple ways to read the d-pad; this is the simplest.)
  -- Note that it is possible for more than one of these directions
  -- to be pressed at once, if the user is pressing diagonally.
  local positionX = select.x
  local positionY = select.y

  if pd.buttonJustPressed( pd.kButtonUp ) then
    local newY = positionY - moveSelectionY
    if newY > 0 then
      select:moveBy( 0, -moveSelectionY)
    end
  end
  if pd.buttonJustPressed( pd.kButtonRight ) then
    local newX = positionX + moveSelectionX
    if newX < 300 then
      select:moveBy( moveSelectionX, 0 )
    end
  end
  if pd.buttonJustPressed( pd.kButtonDown ) then
    local newY = positionY + moveSelectionY
    if newY < 240 then
      select:moveBy( 0, moveSelectionY )
    end
  end
  if pd.buttonJustPressed( pd.kButtonLeft ) then
    local newX = positionX - moveSelectionX
    if newX > 0 then
      select:moveBy( -moveSelectionX, 0 )
    end
  end

  -- Call the functions below in playdate.update() to draw sprites and keep
  -- timers updated. (We aren't using timers in this example, but in most
  -- average-complexity games, you will.)

  gfx.sprite.update()
  pd.timer.updateTimers()

end
