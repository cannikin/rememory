import "CoreLibs/crank"
import "CoreLibs/easing"
import "CoreLibs/frameTimer"
import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

import "components/card"
import "components/gameOver"
import "components/select"
import "components/popup"
import "lib/utility"

local pd <const> = playdate
local gfx <const> = pd.graphics

local config = pd.datastore.read()
if not config then
  config = { sounds = true }
  pd.datastore.write(config)
end

CARD_BACK = gfx.image.new("images/cards/back")
CARD_FLIP_FRAMES = {
  gfx.image.new("images/cards/flip1"),
  gfx.image.new("images/cards/flip2"),
  gfx.image.new("images/cards/flip3"),
  gfx.image.new("images/cards/flip4")
}

function setupMenu()
  local menu <const> = pd.getSystemMenu()
  menu:addCheckmarkMenuItem('sounds', config.sounds, function(value)
    config.sounds = value
    pd.datastore.write(config)
  end)
  menu:addMenuItem('start over', function()
    restartGame()
  end)
end

function startGame()
  -- so we can track how long you've been playing for by the end of the game
  playdate.resetElapsedTime()

  -- size of the board
  board = { cols = 8, rows = 4, xGap = 8, yGap = -2, xMargin = 0, yMargin = 5 }

  -- get all data keys and randomize
  local ids = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 }

  -- randomized card ids, one for each card on the board
  cardIds = shuffle(concat(shuffle(ids), shuffle(ids)))

  -- which cards are showing
  showing = {}

  -- if there's currently a 2-card mismatch showing
  mismatch = false

  -- globally track crank position
  crankTicks = 0

  filePlayer = pd.sound.fileplayer.new(3)
  soundMeta = {
    flip = {
      counter = 1,
      max = 2
    },
    match = {
      counter = 1,
      max = 8
    },
    mismatch = {
      counter = 1,
      max = 7
    }
  }

  -- track how many matches were bad, for showing on the end screen
  mismatchCounter = 0

  -- tracks whether cards should have the opposite behavior. if `true`, then
  -- flipping them to their BACK will be considered showing for matches
  inverted = false

  -- track the most recent sequence of keys pressed, for secrets!
  keyBuffer = {}

  CHEATS = {
    konami = {
      keys = { 'u', 'u', 'd', 'd', 'l', 'r', 'l', 'r', 'b', 'a' },
      activated = false
    }
  }

  cards = setupBoard()
  selector = setupSelector()
  popup = Popup(30)
  gameOver = GameOver()
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
  local card <const> = Card(0, 0, 0, 0, 0)
  local cards = {}

  -- place cards on the board
  for i=1,board.cols do
    cards[i] = {}
    for j=1,board.rows do
      local cardNumber = i + ((j - 1) * board.cols)
      local spawnX = card.width * (i - 1) + (board.xGap * i) + board.xMargin
      local spawnY = card.height * (j - 1) + (board.yGap * j) + board.yMargin
      cards[i][j] = Card(cardIds[cardNumber], i, j, spawnX, spawnY)
      cards[i][j]:add()
    end
  end

  return cards
end

-- The Selector is the little box that highlights the selected card.
-- It's responsible for moving itself around the screen when you use the d-pad
-- or crank. What happens when you press A on a card is handled in update() below
function setupSelector()
  local card <const> = Card(0, 0, 0, 0, 0)
  local options <const> = {
    cols = board.cols,
    rows = board.rows,
    colWidth = card.width,
    rowHeight = card.height,
    xGap = board.xGap,
    yGap = board.yGap,
    xMargin = board.xMargin,
    yMargin = board.yMargin,
    startX = 5,
    startY = 5
  }

  return Select(options)
end

-- records a key press, only tracking the last 10 keys
function recordKey(key)
  table.insert(keyBuffer, #keyBuffer + 1, key)
  if #keyBuffer > 10 then
    table.remove(keyBuffer, 1)
  end
end

-- if two mismatched cards are shown, as soon as a button is pressed or the
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
       -- track these locally so that if the user is clicking around fast and
       -- resets what's showing, we don't lose the reference that these two
       -- were pointing at inside the timer
       local secondFlip = showing[2]

       showing[1]:flip('back')
       pd.timer.performAfterDelay(100, function()
         secondFlip:flip('back')
       end)

       mismatch = false

       -- reset what cards are tracked as showing so that if someone clicks
       -- around before the outgoing animation is done, it doesn't think there
       -- are two cards on the screen still

       -- TODO I bet there's a bug here where secondFlip is a reference and is set to nothing when this happens, making it so the second card can't be turned back over
       showing = {}
  end
end

function handleMatch(one, two)
  pd.timer.performAfterDelay(350, function()
    play("match")
    removeMatch(one, two)
  end)
end

function removeMatch(one, two)
  one:remove()
  pd.timer.performAfterDelay(250, function()
    two:remove()

    -- give the last card a chance to animate off the screen before
    -- show Game Over screen
    pd.timer.performAfterDelay(500, function()
      handleGameOver()
    end)
  end)
end

function handleGameOver()
  local done = true
  for i=1,board.cols do
    for j=1,board.rows do
      if cards[i][j].visible then
        done = false
        break
      end
    end
  end
  if done then
    selector:remove()
    gameOver:show(board.rows * board.cols / 2, mismatchCounter)
    play("gameover")
  end
end

function play(name)
  if not config.sounds then return end

  -- filePlayer can only play one thing at a time so make sure nothing else is
  filePlayer:stop()

  local meta = soundMeta[name]
  if meta then
    filePlayer:load("sounds/"..name..meta.counter)
    meta.counter += 1
    if meta.counter > meta.max then
      meta.counter = 1
    end
  else
    filePlayer:load("sounds/"..name)
  end
  filePlayer:play()
end

-- What to do when pressing the A button
function handleA()
  if pd.buttonJustPressed(pd.kButtonA) then
    recordKey('a')

    -- if the popup is visible, let it worry about buttons
    if (popup.visible) then
      return
    end

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
    showing = {}
    for i=1,board.cols do
      for j=1,board.rows do
        if cards[i][j]:isShowing() then
          showing[#showing+1] = cards[i][j]
        end
      end
    end

    -- are there exactly two cards visible?
    if (#showing == 2) then
      if showing[1].id == showing[2].id then
        handleMatch(showing[1], showing[2])
      else
        -- not a match :(
        selector:shake('left-right')
        pd.timer.performAfterDelay(400, function()
          mismatchSoundIncrement = play("mismatch")
        end)
        -- keep track so that when the cursor next moves or button pressed,
        -- we'll know to flip the cards back over
        mismatch = true
        mismatchCounter += 1
      end
    end

    play("flip")
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

function handleCheats()
  if CHEATS.konami.activated then return end -- already cheated
  if #keyBuffer < 10 then return end         -- not enough keys in buffer

  local activate = true
  for i=1,#CHEATS.konami.keys do
    if keyBuffer[i] ~= CHEATS.konami.keys[i] then
      activate = false
    end
  end

  if not activate then return end -- buffer didn't match cheat code

  CHEATS.konami.activated = true
  play("konami")
  inverted = true

  -- reveal the board
  for i=1,board.rows do
    for j=1,board.cols do
      pd.timer.performAfterDelay(75 * j + ((i - 1) * board.cols * 50), function()
        -- hack to trick the cards into updating themselves when becoming
        -- inverted - otherwise it thinks it's already showing the correct side
        cards[j][i].lastShow = 'front'
        cards[j][i]:flip('back')
      end)
    end
  end

end

function pd.update()
  -- crankTicks can only be called one per update loop so do it here for
  -- everyone to use the value
  crankTicks = pd.getCrankTicks(12)

  -- if there are any mismatches visible
  handleMismatch()

  -- if the popup is visible, it should start listening for key presses
  popup:update()
  gameOver:update()

  -- check if a secret code has been entered!
  handleCheats()

  -- watch for inputs
  handleA()
  handleB()
  handleD()

  -- tell the playdate to do its thing
  gfx.sprite.update()
  pd.timer.updateTimers()
  pd.frameTimer.updateTimers()
end

setupMenu()
startGame()

-- pd.timer.performAfterDelay(200, function()
--   popup:show(DATA['firebase'], function() end)
-- end)
