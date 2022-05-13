import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import "card"
import "select"
import "scoreboard"

local pd <const> = playdate
local gfx <const> = pd.graphics

-- size of the board
local board = { cols = 6, rows = 4, gap = 8}
-- 2 dimensional array of cards on the board
local cards = {}
-- sprite which shows a highlighted card to be interacted with
local selector

function setupBoard()
  local card = Card(0, 0, 0, 0)

  for i=1,board.cols do
    cards[i] = {}
    for j=1,board.rows do
      local spawnX = card.width * (i - 1) + (board.gap * i)
      local spawnY = card.height * (j - 1) + (board.gap * j)
      cards[i][j] = Card(i, j, spawnX, spawnY)
      cards[i][j]:add()
    end
  end
end

function setupSelector()
  local card = Card(0, 0, 0, 0)
  local options = {
    cols = board.cols,
    rows = board.rows,
    colWidth = card.width,
    rowHeight = card.height,
    gap = board.gap,
    startX = 5,
    startY = 5
  }

  selector = Select(options)
end

function setupScoreboard()
  scoreboard = Scoreboard(302, 0)
end

function handleA()
  if pd.buttonJustPressed(pd.kButtonA) then
    local selected = selector:which()
    cards[selected.col][selected.row]:show()
  end
end

function pd.update()
  handleA()

  gfx.sprite.update()
  pd.timer.updateTimers()
end

setupScoreboard()
setupBoard()
setupSelector()
