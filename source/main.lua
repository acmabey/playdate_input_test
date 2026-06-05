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

-- Set up variables to avoid redrawing unnecessarily
local staticInfoDrawn = false
local lastDrawnCrankAngles = {}
local pressedButton = "none"
local lastKnownPressedButton = ""
local lastKnownDockState = true

-- Up/Right/Down/Left/B/A
local lastKnownButtonStates = {true, true, true, true, true, true}
local crankTextWidth, crankTextHeight = gfx.getTextSize("Crank position: ")
local buttonTextWidth, buttonTextHeight = gfx.getTextSize("Button Pressed: ")
local dockTextWidth, dockTextHeight = gfx.getTextSize("Crank Docked: ")


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

local pont = gfx.font.new("/fonts/pont")
gfx.setFont(pont)

-- Prepare the sprite frames
local smallGirlSprite = {}
local smallBoySprite = {}
local frameCounter = 0
local currentFrame = 1
local lastFrame = 1

-- first, set i = 0. loop until i = 5, increment i by 1 every iteration
for i = 0, 5, 1
do
    table.insert(smallBoySprite, gfx.image.new("/images/32x boy" .. i .. ".png"))
    table.insert(smallGirlSprite, gfx.image.new("/images/32x girl" .. i .. ".png"))
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

-- Set the pen to white
local function setPenWhite()
    gfx.setColor(gfx.kColorWhite)
end

-- Set the pen to black
local function setPenBlack()
    gfx.setColor(gfx.kColorBlack)
end

-- Draw a circle with a line indicating the crank's angle/position
local function drawCrankAngle(xPosition, crankPosition, rotationIncrement, size, circleID)
    
    print(pont)

    local drawnAngle = (crankPosition // rotationIncrement) * rotationIncrement
    
    if lastDrawnCrankAngles[circleID] ~= drawnAngle then
        setPenWhite()
        gfx.fillRect(xPosition - size, 85, 60, 60)
        setPenBlack()

        local lineLength = size - 1
        local radians = math.rad((crankPosition // rotationIncrement) * rotationIncrement - 90)
        local endPointX = xPosition + lineLength * math.cos(radians)
        local endPointY = 115 + lineLength * math.sin(radians)

        gfx.drawCircleAtPoint(xPosition, 115, size)
        gfx.drawTextAligned(""..rotationIncrement, xPosition, 67, kTextAlignment.right)
        gfx.drawCircleAtPoint(xPosition + 5, 71, 3)
    
        gfx.drawLine(xPosition, 115, endPointX, endPointY)

        lastDrawnCrankAngles[circleID] = drawnAngle
    end
end

-- advance sprite animation every 15 frames (2fps animation)
local function advanceSprite(frameNumber)
    lastFrame = currentFrame
    if frameNumber == 15 then
        currentFrame = (currentFrame % 6) + 1
    end

    if currentFrame ~= lastFrame then
        setPenWhite()
        gfx.fillRect(5, 150, 32, 32)
        gfx.fillRect(5, 183, 32, 32)

        smallGirlSprite[currentFrame]:drawAnchored(5, 150, 0.0, 0.0)
        smallBoySprite[currentFrame]:drawAnchored(5, 183, 0.0, 0.0)
    end
end

-- Clear out the crank indicator pop up: if sprites are being used, use AddDirtyRect(x, y, w, h)
function pd.crankUndocked()
    local x, y, w, h = pd.ui.crankIndicator:getBounds()
    setPenWhite()
    gfx.fillRect(x, y, w, h)
    setPenBlack()
end

-- playdate.update function is required in every project!
function playdate.update()
    if pd.isCrankDocked() then
        pd.ui.crankIndicator:draw()
    end

    local intCrankPosition = math.floor(pd.getCrankPosition());

    lastKnownPressedButton = pressedButton
    pressedButton = "none"

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

    -- draw information and graphics to the screen
    if not staticInfoDrawn then
        gfx.drawTextAligned("Crank position: " ..intCrankPosition, 10, 10, kTextAlignment.left)
        gfx.drawTextAligned("Button pressed: " ..pressedButton, 10, 30, kTextAlignment.left)
        gfx.drawTextAligned("Crank docked: " ..tostring(pd.isCrankDocked()), 10, 50, kTextAlignment.left)
        
        local dPadShape = pd.geometry.polygon.new(table.unpack(flattened))
        dPadShape:close()
        gfx.drawPolygon(dPadShape)

        staticInfoDrawn = true
    end

    if intCrankPosition ~= lastDrawnCrankAngles[1] then
        setPenWhite()
        gfx.fillRect(crankTextWidth + 12, 10, 30, crankTextHeight)
        setPenBlack()
        gfx.drawTextAligned(""..intCrankPosition, 12 + crankTextWidth, 10, kTextAlignment.left)
    end

    if pressedButton ~= lastKnownPressedButton then
        setPenWhite()
        gfx.fillRect(buttonTextWidth + 11, 30, 40, buttonTextHeight)
        setPenBlack()
        gfx.drawTextAligned(""..pressedButton, 12 + buttonTextWidth, 30, kTextAlignment.left)
    end

    if pd.isCrankDocked() ~= lastKnownDockState then
        setPenWhite()
        gfx.fillRect(dockTextWidth + 11, 50, 40, 15)
        setPenBlack()
        gfx.drawTextAligned(tostring(pd.isCrankDocked()), 12 + dockTextWidth, 50, kTextAlignment.left)
    end

    lastKnownDockState = pd.isCrankDocked()

    pd.drawFPS(380, 5)

    -- Crank position indicators
    drawCrankAngle(35, intCrankPosition, 1, 30, 1)
    drawCrankAngle(95, intCrankPosition, 5, 30, 2)
    drawCrankAngle(155, intCrankPosition, 15, 30, 3)

    -- button representations
    if lastKnownButtonStates[1] ~= pd.buttonIsPressed(pd.kButtonUp) then
        if pd.buttonIsPressed(pd.kButtonUp) then
            gfx.fillRect(231, 6, 14, 14)
        else
            setPenWhite()
            gfx.fillRect(231, 6, 14, 14)
            setPenBlack()
        end
    end

    if lastKnownButtonStates[2] ~= pd.buttonIsPressed(pd.kButtonRight) then    
        if pd.buttonIsPressed(pd.kButtonRight) then
            gfx.fillRect(260, 36, 15, 14)
        else 
            setPenWhite()
            gfx.fillRect(260, 36, 15, 14)
            setPenBlack()
        end
    end

    if lastKnownButtonStates[3] ~= pd.buttonIsPressed(pd.kButtonDown) then
        if pd.buttonIsPressed(pd.kButtonDown) then
            gfx.fillRect(231, 65, 14, 15)
        else
            setPenWhite()
            gfx.fillRect(231, 65, 14, 15)
            setPenBlack()
        end
    end

    if lastKnownButtonStates[4] ~= pd.buttonIsPressed(pd.kButtonLeft) then
        if pd.buttonIsPressed(pd.kButtonLeft) then
            gfx.fillRect(201, 36, 14, 14)
        else
            setPenWhite()
            gfx.fillRect(201, 36, 14, 14)
            setPenBlack()
        end
    end

    local circleY = 28
    local circleDiameter = 30

    if pd.buttonIsPressed(pd.kButtonB) ~= lastKnownButtonStates[5] then
        setPenWhite()
        gfx.fillRect(290, circleY, circleDiameter, circleDiameter)
        setPenBlack()

        if pd.buttonIsPressed(pd.kButtonB) then
            gfx.fillCircleInRect(290, circleY, circleDiameter, circleDiameter)
        else
            gfx.drawCircleInRect(290, circleY, circleDiameter, circleDiameter)
            gfx.drawTextAligned("B", 305, circleY + 7, kTextAlignment.center)
        end
    end

    if pd.buttonIsPressed(pd.kButtonA) ~= lastKnownButtonStates[6] then
        setPenWhite()
        gfx.fillRect(330, circleY, circleDiameter, circleDiameter)
        setPenBlack()

        if pd.buttonIsPressed(pd.kButtonA) then
            gfx.fillCircleInRect(330, circleY, circleDiameter, circleDiameter)
        else
            gfx.drawCircleInRect(330, circleY, circleDiameter, circleDiameter)
            gfx.drawTextAligned("A", 345, circleY + 7, kTextAlignment.center)
        end
    end

    lastKnownButtonStates[1] = pd.buttonIsPressed(pd.kButtonUp)
    lastKnownButtonStates[2] = pd.buttonIsPressed(pd.kButtonRight)
    lastKnownButtonStates[3] = pd.buttonIsPressed(pd.kButtonDown)
    lastKnownButtonStates[4] = pd.buttonIsPressed(pd.kButtonLeft)
    lastKnownButtonStates[5] = pd.buttonIsPressed(pd.kButtonB)
    lastKnownButtonStates[6] = pd.buttonIsPressed(pd.kButtonA)

    -- draw and animate sprites
    frameCounter = (frameCounter + 1) % 16
    advanceSprite(frameCounter)

end
