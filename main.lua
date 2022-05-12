-- Name this file `main.lua`. Your game can use multiple source files if you wish
-- (use the `import "myFilename"` command), but the simplest games can be written
-- with just `main.lua`.

-- You'll want to import these in just about every project you'll work on.

import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

-- Declaring this "gfx" shorthand will make your life easier. Instead of having
-- to preface all graphics calls with "playdate.graphics", just use "gfx."
-- Performance will be slightly enhanced, too.
-- NOTE: Because it's local, you'll have to do it in every .lua source file.

local gfx <const> = playdate.graphics

-- Here's our player sprite declaration. We'll scope it to this file because
-- several functions need to access it.

local playerSprite = nil

-- A function to set up our game environment.

function myGameSetUp()

  -- Set up the player sprite.
  -- The :setCenter() call specifies that the sprite will be anchored at its center.
  -- The :moveTo() call moves our sprite to the center of the display.
--
  local select = gfx.image.new("Images/select")
  assert( select ) -- make sure the image was where we thought

  selection = gfx.sprite.new( select )
  selection:moveTo( 29, 33 ) -- this is where the center of the sprite is placed; (200,120) is the center of the Playdate screen
  selection:add() -- This is critical!

  -- keep track of how far we should move the selection when the keyboard is used
  moveSelectionX = selection.width + 2
  moveSelectionY = selection.height + 2

  print(selection:getSize())

  -- We want an environment displayed behind our sprite.
  -- There are generally two ways to do this:
  -- 1) Use setBackgroundDrawingCallback() to draw a background image. (This is what we're doing below.)
  -- 2) Use a tilemap, assign it to a sprite with sprite:setTilemap(tilemap),
  --       and call :setZIndex() with some low number so the background stays behind
  --       your other sprites.

  local backgroundImage = gfx.image.new( "images/background1" )
  assert( backgroundImage )

  gfx.sprite.setBackgroundDrawingCallback(
    function( x, y, width, height )
      gfx.setClipRect( x, y, width, height ) -- let's only draw the part of the screen that's dirty
      backgroundImage:draw( 0, 0 )
      gfx.clearClipRect() -- clear so we don't interfere with drawing that comes after this
    end
  )

end

-- Now we'll call the function above to configure our game.
-- After this runs (it just runs once), nearly everything will be
-- controlled by the OS calling `playdate.update()` 30 times a second.

myGameSetUp()

-- `playdate.update()` is the heart of every Playdate game.
-- This function is called right before every frame is drawn onscreen.
-- Use this function to poll input, run game logic, and move sprites.

function playdate.update()

  -- Poll the d-pad and move our player accordingly.
  -- (There are multiple ways to read the d-pad; this is the simplest.)
  -- Note that it is possible for more than one of these directions
  -- to be pressed at once, if the user is pressing diagonally.
  local positionX = selection.x
  local positionY = selection.y

  print("positionY", positionY, "positionX", positionX)

  if playdate.buttonJustPressed( playdate.kButtonUp ) then
    local newY = positionY - moveSelectionY
    if newY > 0 then
      selection:moveBy( 0, -moveSelectionY)
    end
  end
  if playdate.buttonJustPressed( playdate.kButtonRight ) then
    local newX = positionX + moveSelectionX
    if newX < 300 then
      selection:moveBy( moveSelectionX, 0 )
    end
  end
  if playdate.buttonJustPressed( playdate.kButtonDown ) then
    local newY = positionY + moveSelectionY
    if newY < 240 then
      selection:moveBy( 0, moveSelectionY )
    end
  end
  if playdate.buttonJustPressed( playdate.kButtonLeft ) then
    local newX = positionX - moveSelectionX
    if newX > 0 then
      selection:moveBy( -moveSelectionX, 0 )
    end
  end

  -- Call the functions below in playdate.update() to draw sprites and keep
  -- timers updated. (We aren't using timers in this example, but in most
  -- average-complexity games, you will.)

  gfx.sprite.update()
  playdate.timer.updateTimers()

end
