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
sampleCard = Card(0, 0, 0, 0)

-- setup playing board
cards = {}
gridX = 6
gridY = 4
-- which card is currently selected
selectedX = 1
selectedY = 1

local gap = 8

for i=1,gridX do
  cards[i] = {}
  for j=1,gridY do
    local spawnX = sampleCard.width * (i - 1) + (gap * i)
    local spawnY = sampleCard.height * (j - 1) + (gap * j)
    cards[i][j] = Card(i, j, spawnX, spawnY)
    cards[i][j]:add()
  end
end

-- setup selection rectangle
select = Select(5, 5)
selectGap = 5

function pd.update()
  local positionX = select.x
  local positionY = select.y

  if pd.buttonJustPressed(pd.kButtonUp) then
    if selectedY - 1 >= 1 then
      selectedY -= 1
    else
      -- shake selection sprite
    end
  end

  if pd.buttonJustPressed(pd.kButtonRight) then
    if selectedX + 1 <= gridX then
      selectedX += 1
    else
      -- shake
    end
  end

  if pd.buttonJustPressed(pd.kButtonDown) then
    if selectedY + 1 <= gridY then
      selectedY += 1
    else
      -- shake
    end
  end

  if pd.buttonJustPressed(pd.kButtonLeft) then
    if selectedX - 1 >= 1 then
      selectedX -= 1
    else
      -- shake
    end
  end

  -- move selection box
  local newX = sampleCard.width * (selectedX - 1) + (8 * selectedX) - (select.width - sampleCard.width) / 2
  local newY = sampleCard.height * (selectedY - 1) + (8 * selectedY) - (select.height - sampleCard.height) / 2
  select:moveTo(newX, newY)

  if pd.buttonJustPressed(pd.kButtonA) then
    cards[selectedX][selectedY]:show()
    -- print('show', cards[selectedX][selectedY].xId, cards[selectedX][selectedY].yId)
  end
  -- Call the functions below in playdate.update() to draw sprites and keep
  -- timers updated. (We aren't using timers in this example, but in most
  -- average-complexity games, you will.)

  gfx.sprite.update()
  pd.timer.updateTimers()

end
