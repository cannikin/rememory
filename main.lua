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
  local menu <const> = pd.getSystemMenu()
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

  -- get all sounds in memory
  sounds = {
    flip = pd.sound.sampleplayer.new("sounds/flip.wav"),
    match = pd.sound.sampleplayer.new("sounds/match.wav"),
    mismatch = pd.sound.sampleplayer.new("sounds/mismatch.wav")
  }

  -- track the most recent sequence of keys pressed, for secrets!
  keyBuffer = {}

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
  -- draw background
  local bgImage <const> = gfx.image.new("images/bg")
  gfx.sprite.setBackgroundDrawingCallback(
    function(x, y, width, height)
      gfx.setClipRect(x, y, width, height)
      bgImage:draw(0, 0)
      gfx.clearClipRect()
    end
  )

  -- sample card so we can get its size
  local card <const> = Card('', 0, 0, 0, 0)

  -- place cards on the board
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
  local card <const> = Card('', 0, 0, 0, 0)
  local options <const> = {
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

-- flips all cards to either their front or back sides
function flipAllCards(side)
  for i=1,board.cols do
    for j=1,board.rows do
      cards[i][j]:flip(side)
    end
  end
end

-- records a key press, only tracking the last 10 keys
function recordKey(key)
  table.insert(keyBuffer, #keyBuffer + 1, key)
  if #keyBuffer > 10 then
    table.remove(keyBuffer, 1)
  end
end

-- if two mismatched cards are showm, as soon as a button is pressed or the
-- crank turns, flip them back over
function handleMismatch()
  if not mismatch then
    return
  end

  if pd.buttonJustPressed(pd.kButtonUp) or
     pd.buttonJustPressed(pd.kButtonDown) or
     pd.buttonJustPressed(pd.kButtonLeft) or
     pd.buttonJustPressed(pd.kButtonRight) or
     pd.buttonJustPressed(pd.kButtonA) or
     crankTicks ~= 0 then
       flipAllCards('back')
       mismatch = false
  end
end

-- What to do when pressing the A button
function handleA()
  -- if a timer is already running don't let any other A button actions take place
  if matchTimer then
    return
  end

  -- TODO: if a mismatch is present and someone presses A, hide cards
  -- unless the card to flip is one of the mismatched ones, then it should show

  if pd.buttonJustPressed(pd.kButtonA) then
    recordKey('a')

    -- flip over the card that's currently selected, if visible
    local selected = selector:which()
    if cards[selected.col][selected.row].visible then
      cards[selected.col][selected.row]:flip()
    else
      -- card is already matched and off the table
      selector:shake('left-right')
      return
    end

    -- record all cards currently visible
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
        -- we have a match :)
        scoreboard:update(showing[1].label)
        sounds.match:play()
        matchTimer = pd.timer.performAfterDelay(1000, function()
          showing[1]:remove()
          showing[2]:remove()
          matchTimer = nil
        end)
      else
        -- not a match :(
        selector:shake('left-right')
        sounds.mismatch:play()
        -- keep track so that when the cursor next moves or button pressed,
        -- we'll know to flip the cards back over
        mismatch = true
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
    recordKey('b')
  end
end

function handleD()
  if pd.buttonJustPressed(pd.kButtonUp) then
    recordKey('u')
  end
  if pd.buttonJustPressed(pd.kButtonDown) then
    recordKey('d')
  end
  if pd.buttonJustPressed(pd.kButtonLeft) then
    recordKey('l')
  end
  if pd.buttonJustPressed(pd.kButtonRight) then
    recordKey('r')
  end
end

function pd.update()
  -- crankTicks can only be called one per update loop so do it here for
  -- everyone to use the value
  crankTicks = pd.getCrankTicks(12)

  handleMismatch()

  -- watch for inputs
  handleA()
  handleB()
  handleD()

  -- draw everything
  gfx.sprite.update()
  pd.timer.updateTimers()
end

setupMenu()
startGame()
