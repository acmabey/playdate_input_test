-- Below is a small example program where you can move a circle
-- around with the crank. You can delete everything in this file,
-- but make sure to add back in a playdate.update function since
-- one is required for every Playdate game!
-- =============================================================

-- Importing libraries used for drawCircleAtPoint and crankIndicator
import "CoreLibs/graphics"
import "CoreLibs/ui"
import "CoreLibs/sprites"

-- Localizing commonly used globals
local pd <const> = playdate
local gfx <const> = playdate.graphics

-- Define the d-pad shape
local dPadPoints = {
    {200, 50},
    {200, 35},
    {230, 35},
    {230, 5},
    {245, 5},
    {245, 35},
    {275, 35},
    {275, 50},
    {245, 50},
    {245, 80},
    {230, 80},
    {230, 50}
}

local flattened = {}

for _, point in ipairs(dPadPoints) do
    table.insert(flattened, point[1])
    table.insert(flattened, point[2])
end

-- Prepare the sprite frames
local smallSprite = {}
local frameCounter = 0
CurrentFrame = 1

for i = 0, 5, 1
do
    table.insert(smallSprite, gfx.image.new("/images/sprite_" .. i .. ".png"))
end

-- Drawing player image
local playerImage = gfx.image.new(32, 32)
gfx.pushContext(playerImage)
    -- Draw outline
    gfx.drawRoundRect(4, 3, 24, 26, 1)
    -- Draw screen
    gfx.drawRect(7, 6, 18, 12)
    -- Draw eyes
    gfx.drawLine(10, 12, 12, 10)
    gfx.drawLine(12, 10, 14, 12)
    gfx.drawLine(17, 12, 19, 10)
    gfx.drawLine(19, 10, 21, 12)
    -- Draw crank
    gfx.drawRect(27, 15, 3, 9)
    -- Draw A/B buttons
    gfx.drawCircleInRect(16, 20, 4, 4)
    gfx.drawCircleInRect(21, 20, 4, 4)
    -- Draw D-Pad
    gfx.drawRect(8, 22, 6, 2)
    gfx.drawRect(10, 20, 2, 6)
gfx.popContext()

-- Defining helper function
local function ring(value, min, max)
	if (min > max) then
		min, max = max, min
	end
	return min + (value - min) % (max - min)
end

-- Draw a circle with a line indicating the crank's angle/position
local function drawCrankAngle(xPosition, crankPosition, rotationIncrement, size)
    gfx.drawCircleAtPoint(xPosition, 115, size)

    -- display angle in text
    gfx.drawTextAligned(""..rotationIncrement, xPosition, 67, kTextAlignment.right)
    gfx.drawCircleAtPoint(xPosition + 5, 71, 3)

    local radians = math.rad((crankPosition // rotationIncrement) * rotationIncrement - 90)
    local endPointX = xPosition + size * math.cos(radians)
    local endPointY = 115 + size * math.sin(radians)
    gfx.drawLine(xPosition, 115, endPointX, endPointY)
end

-- advance sprite animation every 15 frames (2fps animation)
local function advanceSprite(frameNumber)
    if frameNumber == 15 then
        CurrentFrame = (CurrentFrame % 6) + 1
    end

    smallSprite[CurrentFrame]:drawAnchored(5, 150, 0.0, 0.0)
end

-- playdate.update function is required in every project!
function playdate.update()
    -- Clear screen
    gfx.clear()
    -- Draw crank indicator if crank is docked
    if pd.isCrankDocked() then
        pd.ui.crankIndicator:draw()
    -- else
        -- Calculate velocity from crank angle 
        -- local crankPosition = pd.getCrankPosition() - 90
        --local xVelocity = math.cos(math.rad(crankPosition)) * playerVelocity
        --local yVelocity = math.sin(math.rad(crankPosition)) * playerVelocity
        -- Move player (add velocity to position)
        -- Loop player position -> uses "ring" function

    end
    -- get the crank position as an int
    local intCrankPosition = math.floor(pd.getCrankPosition());

    -- store the button being pressed
    local pressedButton = "none"
    if pd.buttonIsPressed(pd.kButtonA) then
        pressedButton = "a"
    elseif pd.buttonIsPressed(pd.kButtonB) then
        pressedButton = "b"
    elseif pd.buttonIsPressed(pd.kButtonUp) then
        pressedButton = "up"
    elseif pd.buttonIsPressed(pd.kButtonRight) then
        pressedButton = "right"
    elseif pd.buttonIsPressed(pd.kButtonDown) then
        pressedButton = "down"
    elseif pd.buttonIsPressed(pd.kButtonLeft) then
        pressedButton = "left"
    end

    -- report input information
    gfx.drawTextAligned("Crank position: " ..intCrankPosition, 10, 10, kTextAlignment.left)

    gfx.drawTextAligned("Button pressed: " ..pressedButton, 10, 30, kTextAlignment.left)

    pd.drawFPS(380, 5)

    -- draw crank indicator
    gfx.drawTextAligned("Crank docked: " ..tostring(pd.isCrankDocked()), 10, 50, kTextAlignment.left)

    drawCrankAngle(35, intCrankPosition, 1, 30)
    drawCrankAngle(95, intCrankPosition, 5, 30)
    drawCrankAngle(155, intCrankPosition, 15, 30)

    -- button representations
    local dPadShape = pd.geometry.polygon.new(table.unpack(flattened))
    dPadShape:close()
    gfx.drawPolygon(200, 50, 200, 35, 230, 35, 230, 5, 245, 5, 245, 35, 275, 35, 275, 50, 245, 50, 245, 80, 230, 80, 230, 50)

    if pd.buttonIsPressed(pd.kButtonUp) then
        gfx.fillRect(230, 5, 15, 15)
    end
    if pd.buttonIsPressed(pd.kButtonRight) then
        gfx.fillRect(260, 35, 15, 15)
    end
    if pd.buttonIsPressed(pd.kButtonDown) then
        gfx.fillRect(230, 65, 15, 15)
    end
    if pd.buttonIsPressed(pd.kButtonLeft) then
        gfx.fillRect(200, 35, 15, 15)
    end
    
    local circleY = 28
    local circleDiameter = 30

    if pd.buttonIsPressed(pd.kButtonB) then
        gfx.fillCircleInRect(290, circleY, circleDiameter, circleDiameter)
    else
        gfx.drawCircleInRect(290, circleY, circleDiameter, circleDiameter)
        gfx.drawTextAligned("B", 305, circleY + 7, kTextAlignment.center)
    end

    if pd.buttonIsPressed(pd.kButtonA) then
        gfx.fillCircleInRect(330, circleY, circleDiameter, circleDiameter)
    else
        gfx.drawCircleInRect(330, circleY, circleDiameter, circleDiameter)
        gfx.drawTextAligned("A", 345, circleY + 7, kTextAlignment.center)
    end


    -- y = 150 is 5px below the circles

    -- draw sprite at (5, 150)
    frameCounter = (frameCounter + 1) % 16
    advanceSprite(frameCounter)

end
