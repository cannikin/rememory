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

function start()
  -- size of the board
  board = { cols = 6, rows = 4, gap = 8}
  -- which matches we're looking for
  labels = { "React", "GraphQL", "Prisma", "TypeScript", "Jest", "Storybook", "Webpack", "Babel", "Auth0", "Netlify", "Vercel", "Render" }
  cardLabels = concat(shuffle(labels), shuffle(labels))

  -- keep track of which pairs have been found and if any changed since the last update()
  foundMap = {}
  previousFound = {}
  for i=1,#labels do
    foundMap[labels[i]] = false
    previousFound[labels[i]] = false
  end

  -- 2 dimensional array of cards on the board
  cards = {}
  -- sprite which shows a highlighted card to be interacted with
  selector = {}
  showDescriptions = true

  setupMenu()
  setupBoard()
  setupSelector()
  setupScoreboard()
end

-- removes any existing sprites from the stack so they can get redrawn from scratch
function restart()
  scoreboard:remove()
  selector:remove()
  for i=1,board.cols do
    for j=1,board.rows do
      cards[i][j]:remove()
    end
  end

  start()
end

function setupMenu()
  local menu = pd.getSystemMenu()
  menu:addCheckmarkMenuItem('popups', true, function()
    showDescriptions = not showDescriptions
  end)
  menu:addMenuItem('start over', true, function()
    restart()
  end)
end

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

-- The Selector is the little box that highlights the selected card.
-- It's responsible for moving itself around the screen when you use the d-pad
-- or crank. What happens when you press A on a card is handled in update() below
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

-- The Scoreboard is the box on the right that keeps track of the cards you've
-- matched so far.
function setupScoreboard()
  scoreboard = Scoreboard(302, 0, labels)
end

-- What to do when pressing the A button
function handleA()
  if pd.buttonJustPressed(pd.kButtonA) then
    local selected = selector:which()
    cards[selected.col][selected.row]:flip()

    local showing = {}
    for i=1,board.cols do
      for j=1,board.rows do
        if cards[i][j]:isShowing() then
          showing[#showing+1] = cards[i][j]
        end
      end
    end

    if (#showing == 2) then
      if showing[1].label == showing[2].label then
        print('match!')

        pd.timer.performAfterDelay(1000, function()
          scoreboard:update(showing[1].label)
          showing[1]:remove()
          showing[2]:remove()
        end)
      else
        print('nope')

        pd.timer.performAfterDelay(1000, function()
          showing[1]:flip()
          showing[2]:flip()
        end)
      end
    end
  end
end

-- What to do when pressing the B button
function handleB()
  if pd.buttonJustPressed(pd.kButtonB) then
    print('B pressed')
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
  handleB()

  gfx.sprite.update()
  pd.timer.updateTimers()

  -- check to see if any two matching cards are showing
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

start()
