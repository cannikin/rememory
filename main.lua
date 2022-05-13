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
import "scoreboard"

-- Declaring this "gfx" shorthand will make your life easier. Instead of having
-- to preface all graphics calls with "playdate.graphics", just use "gfx."
-- Performance will be slightly enhanced, too.
-- NOTE: Because it's local, you'll have to do it in every .lua source file.

local pd <const> = playdate
local gfx <const> = pd.graphics

local cards = {}
local sampleCard = Card(0, 0, 0, 0)
local board = {}
board['cols'] = 6
board['rows'] = 4
board['gap'] = 8
local selected = {}
selected['col'] = 1
selected['row'] = 1
local selector

function setupBoard()
  for i=1,board.cols do
    cards[i] = {}
    for j=1,board.rows do
      local spawnX = sampleCard.width * (i - 1) + (board.gap * i)
      local spawnY = sampleCard.height * (j - 1) + (board.gap * j)
      cards[i][j] = Card(i, j, spawnX, spawnY)
      cards[i][j]:add()
    end
  end
end

function setupSelector()
  selector = Select(5, 5)
end

function setupScoreboard()
  scoreboard = Scoreboard(302, 0)
  scoreboard:add()
end

function handleMove()
  local positionX = selector.x
  local positionY = selector.y

  if pd.buttonJustPressed(pd.kButtonUp) then
    if selected.row - 1 >= 1 then
      selected.row -= 1
    else
      -- shake selection sprite
    end
  end

  if pd.buttonJustPressed(pd.kButtonRight) then
    if selected.col + 1 <= board.cols then
      selected.col += 1
    else
      -- shake
    end
  end

  if pd.buttonJustPressed(pd.kButtonDown) then
    if selected.row + 1 <= board.rows then
      selected.row += 1
    else
      -- shake
    end
  end

  if pd.buttonJustPressed(pd.kButtonLeft) then
    if selected.col - 1 >= 1 then
      selected.col -= 1
    else
      -- shake
    end
  end

  -- move selection box
  local newX = sampleCard.width * (selected.col - 1) + (8 * selected.col) - (selector.width - sampleCard.width) / 2
  local newY = sampleCard.height * (selected.row - 1) + (8 * selected.row) - (selector.height - sampleCard.height) / 2
  selector:moveTo(newX, newY)
end

function handleA()
  if pd.buttonJustPressed(pd.kButtonA) then
    cards[selected.col][selected.row]:show()
  end
end

function pd.update()
  handleMove()
  handleA()

  gfx.sprite.update()
  pd.timer.updateTimers()
end

setupScoreboard()
setupBoard()
setupSelector()
