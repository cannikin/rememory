import "CoreLibs/crank"
import "CoreLibs/easing"
import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import "utility"
import "card"
import "select"
import "scoreboard"

local pd <const> = playdate
local gfx <const> = pd.graphics

-- size of the board
local board = { cols = 6, rows = 4, gap = 8}
-- which matches we're looking for
local labels = { "React", "GraphQL", "Prisma", "TypeScript", "Jest", "Storybook", "Webpack", "Babel", "Auth0", "Netlify", "Vercel", "Render" }
local cardLabels = concat(shuffle(labels), shuffle(labels))

-- keep track of which pairs have been found and if any changed since the last update()
local foundMap = {}
local previousFound = {}
for i=1,#labels do
  foundMap[labels[i]] = false
  previousFound[labels[i]] = false
end

-- 2 dimensional array of cards on the board
local cards = {}
-- sprite which shows a highlighted card to be interacted with
local selector

function setupBoard()
  local card = Card('', 0, 0, 0, 0)

  for i=1,board.cols do
    cards[i] = {}
    for j=1,board.rows do
      local cardNumber = i + ((j - 1) * board.cols)
      local spawnX = card.width * (i - 1) + (board.gap * i)
      local spawnY = card.height * (j - 1) + (board.gap * j)
      cards[i][j] = Card(cardLabels[cardNumber], i, j, spawnX, spawnY)
      cards[i][j]:add()
    end
  end
end

function setupSelector()
  local card = Card('', 0, 0, 0, 0)
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
  scoreboard = Scoreboard(302, 0, labels)
end

function handleA()
  if pd.buttonJustPressed(pd.kButtonA) then
    local selected = selector:which()
    cards[selected.col][selected.row]:flip()
    foundMap["Storybook"] = true
  end
end

function checkForMatches()
  -- check if any new matches have been found
  for i=1,#labels do
    if foundMap[labels[i]] ~= previousFound[labels[i]] then
      scoreboard:update(labels[i])
    end
  end

  -- update previousFound to current
  for i=1,#labels do
    previousFound[labels[i]] = foundMap[labels[i]]
  end
end

function pd.update()
  handleA()

  gfx.sprite.update()
  pd.timer.updateTimers()
  checkForMatches()
end

local bgImage = gfx.image.new("images/bg")
gfx.sprite.setBackgroundDrawingCallback(
  function(x, y, width, height)
    gfx.setClipRect(x, y, width, height)
    bgImage:draw(0, 0)
    gfx.clearClipRect()
  end
)

setupScoreboard()
setupBoard()
setupSelector()
