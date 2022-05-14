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

local config = pd.datastore.read()
if not config then
  config = { showDescriptions = true }
  pd.datastore.write(config)
end

function setupMenu()
  local menu = pd.getSystemMenu()
  menu:addCheckmarkMenuItem('popups', config.showDescriptions, function()
    config.showDescriptions = not config.showDescriptions
    pd.datastore.write(config)
  end)
  menu:addMenuItem('start over', function()
    restartGame()
  end)
end

function startGame()
  -- size of the board
  board = { cols = 6, rows = 4, gap = 8}

  -- which matches we're looking for
  labels = { "React", "GraphQL", "Prisma", "TypeScript", "Jest", "Storybook", "Webpack", "Babel", "Auth0", "Netlify", "Vercel", "Render" }

  -- randomized labels list, one for each card on the board
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

  -- if a match is made there's a little delay before they are flipped back or
  -- removed, this timer keeps track
  matchTimer = nil

  -- if there's currently a 2-card mismatch showing
  mismatch = false

  -- globally track crank position
  crankTicks = 0

  sounds = {
    flip = pd.sound.sampleplayer.new("sounds/flip.wav"),
    match = pd.sound.sampleplayer.new("sounds/match.wav"),
    mismatch = pd.sound.sampleplayer.new("sounds/mismatch.wav")
  }

  setupBoard()
  setupSelector()
  setupScoreboard()
end

-- removes any existing sprites from the stack so they can get redrawn from scratch
function restartGame()
  gfx.sprite.removeAll()

  startGame()
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

  -- if a timer is already running don't let any other A button actions take place
  if matchTimer then
    return
  end

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

    -- are there exactly two cards visible?
    if (#showing == 2) then
      if showing[1].label == showing[2].label then
        scoreboard:update(showing[1].label)
        sounds.match:play()
        -- two matching cards are showing, hide them after a delay
        matchTimer = pd.timer.performAfterDelay(1000, function()
          showing[1]:remove()
          showing[2]:remove()
          matchTimer = nil
        end)
      else
        selector:shake('left-right')
        sounds.mismatch:play()
        -- when the cursor next moves, flip the cards back over
        mismatch = true
        -- two mismatched cards are showing, flip them back over after a delay
        -- matchTimer = pd.timer.performAfterDelay(500, function()
        --   showing[1]:flip()
        --   showing[2]:flip()
        --   matchTimer = nil
        -- end)
      end
    else
      -- if we're not going to play any other sound, play the card flip
      sounds.flip:play()
    end
  end
end

-- What to do when pressing the B button
function handleB()
  if pd.buttonJustPressed(pd.kButtonB) then
    print('B pressed')
  end
end

function pd.update()
  handleA()
  handleB()

  crankTicks = pd.getCrankTicks(12)

  gfx.sprite.update()
  pd.timer.updateTimers()

  if mismatch and (
     pd.buttonJustPressed(pd.kButtonUp) or
     pd.buttonJustPressed(pd.kButtonDown) or
     pd.buttonJustPressed(pd.kButtonLeft) or
     pd.buttonJustPressed(pd.kButtonRight) or
     crankTicks ~= 0) then
       flipAllCards('back')
       mismatch = false
  end
end

function flipAllCards(side)
  for i=1,board.cols do
    for j=1,board.rows do
      cards[i][j]:flip(side)
    end
  end
end

local bgImage = gfx.image.new("images/bg")
gfx.sprite.setBackgroundDrawingCallback(
  function(x, y, width, height)
    gfx.setClipRect(x, y, width, height)
    bgImage:draw(0, 0)
    gfx.clearClipRect()
  end
)

setupMenu()
startGame()
