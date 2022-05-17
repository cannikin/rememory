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
import "popup"

local pd <const> = playdate
local gfx <const> = pd.graphics

local config = pd.datastore.read()
if not config then
  config = { showDescriptions = true }
  pd.datastore.write(config)
end

local DATA_INDEX <const> = { "react", "graphql", "prisma", "typescript", "jest", "storybook", "webpack", "babel", "auth0", "supabase", "netlify", "vercel" }

local DATA <const> = {
  react = {
    title = "React",
    subtitle = "Frontend Rendering",
    desc = "The world’s most popular rendering\nengine powers Redwood’s web\nfrontend. And just wait until you\nyou try Redwood's router.",
    url = "https://reactjs.org"
  },
  graphql = {
    title = "GraphQL",
    infoTitle = "GraphQL Yoga",
    subtitle = "API Engine",
    desc = "Some text goes here",
    url = "https://graphql-yoga.com"
  },
  prisma = {
    title = "Prisma",
    subtitle = "Database Access and ORM",
    desc = "Some text goes here",
    url = "https://prisma.io"
  },
  typescript = {
    title = "TypeScript",
    subtitle = "JavaScript + Types",
    desc = "Some text goes here",
    url = "https://typescriptlang.org"
  },
  jest = {
    title = "Jest",
    subtitle = "Testing Framework",
    desc = "Some text goes here",
    url = "https://jestjs.io"
  },
  storybook = {
    title = "Storybook",
    subtitle = "UI Component Builder",
    desc = "Some text goes here",
    url = "https://storybook.js.org"
  },
  webpack = {
    title = "Webpack",
    subtitle = "Module Bundler",
    desc = "Some text goes here",
    url = "https://webpack.js.org"
  },
  babel = {
    title = "Babel",
    subtitle = "JavaScript Compiler",
    desc = "Some text goes here",
    url = "https://babeljs.io"
  },
  auth0 = {
    title = "Auth0",
    subtitle = "Hosted Auth Provider",
    desc = "Some text goes here",
    url = "https://auth0.com"
  },
  netlify = {
    title = "Netlify",
    subtitle = "Build & Deploy",
    desc = "Some text goes here",
    url = "https://www.netlify.com"
  },
  vercel = {
    title = "Vercel",
    subtitle = "Build & Deploy",
    desc = "Some text goes here",
    url = "https://vercel.com"
  },
  supabase = {
    title = "Supabase",
    subtitle = "Auth & Database Provider",
    desc = "Some text goes here",
    url = "https://supabase.com"
  }
}

function setupMenu()
  local menu <const> = pd.getSystemMenu()
  menu:addCheckmarkMenuItem('info cards', config.showDescriptions, function()
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

  local labels = {}
  local titles = {}
  for _, label in ipairs(DATA_INDEX) do
    table.insert(labels, #labels + 1, label)
    table.insert(titles, #titles + 1, DATA[label].title)
  end

  -- randomized labels list, one for each card on the board
  cardLabels = concat(shuffle(labels), shuffle(labels))

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

  cards = setupBoard()
  selector = setupSelector()
  scoreboard = Scoreboard(302, 0, titles)
  popup = Popup(30)
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
  local cards = {}

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

  return cards
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

  return Select(options)
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

function handleMatch(one, two)
  scoreboard:update(one.label)
  sounds.match:play()
  one:remove()
  two:remove()

  print(config.showDescriptions)
  if config.showDescriptions then
    popup:show(DATA[one.label])
  end
end

-- What to do when pressing the A button
function handleA()
  -- if the popup is visible, let it worry about buttons
  if (popup.visible) then
    return
  end

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
        handleMatch(showing[1], showing[2])
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

  popup:update()

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

popup:show(DATA.react)
