local storedValues = ac.storage{
    currentDisplayed="BOOST/OIL-TEMP",
    currentTwin = "BOOST/OIL-TEMP/NONE/NONE/NONE/NONE/NONE/NONE",

    currentActiveMenu = "SELECT",
    currentActive = "BOOST",
    shiftTreshold = 8000,

    tresholdValues= "1/75/120/120/875/50",

    autoDimming = false,
    brightnessAdjustment = false,
    gaugeTail = true,
    isScreenOn = true, 
    screenBrightness = 0.5
}

function storageUnpack(data,items,isnumber) --since ac storage doesn't support tables, this is a function that unpacks a string into a table, so it can be used
    local storedVals = {}
    for i=1,items do
        if isnumber then
            storedVals[i] = tonumber(string.split(data,'/')[i])
        else
            storedVals[i] = string.split(data,'/')[i]
        end
    end
    return storedVals
end

function storageUnpackNested(data,items) --same thing but with nested tables
    local storedVals = {{},{},{},{}}
    local k = 1 --just a simple iterator over the string
    for i=1,4 do
        for j=1,2 do
            storedVals[i][j] = string.split(data,'/')[k]
            k = k+1
        end
    end
    return storedVals
end

function storagePack(data) --prepairing string to store
    local storedString = ""
    for i=1, #data do
        storedString = storedString .. data[i]
        if i ~= #data then
            storedString = storedString .. "/"  
        end
    end
    return storedString
end

function storagePackNested(data) --same thing but with nested tables
    local storedString = ""
    for i=1, 4 do
        for j=1,2 do
            storedString = storedString .. data[i][j]
            if i*j ~= 8 then --eh, it works
                storedString = storedString .. "/" 
            end
        end
    end
    return storedString
end

--stored variables--

local currentTwin = storageUnpackNested(storedValues.currentTwin,8) --current twin menu configuration (all 4)
local currentDisplayed = storageUnpack(storedValues.currentDisplayed, 2) --current selected twin
local currentActiveMenu = storedValues.currentActiveMenu --might not need to store this
local currentActive = storedValues.currentActive --current active gauge + graph combo
local shiftTreshold = storedValues.shiftTreshold --current shift treshold
local tresholdValues = storageUnpack(storedValues.tresholdValues,6,true) --current tresholds set in the red menu

--button mapping--

local displayMesh = display.interactiveMesh{ mesh = "INT_BUTTON_NM", resolution = vec2(1024, 1024)}
local displayMesh2 = display.interactiveMesh{ mesh = "INT_BUTTONS_EMIS", resolution = vec2(512, 512)}
local btnMode = displayMesh2.clicked(vec2(423, 34),vec2(63, 24))
local btnMenu = displayMesh2.clicked(vec2(118, 246),vec2(63, 26))
local btnReturn = displayMesh2.clicked(vec2(2, 245),vec2(95, 29))
local btnDisp = displayMesh2.clicked(vec2(3, 107),vec2(61, 28))

local btnUp = displayMesh.clicked(vec2(581, 356),vec2(69, 47))
local btnDown = displayMesh.clicked(vec2(325, 350),vec2(72, 60))
local btnRight = displayMesh.clicked(vec2(460, 470),vec2(59, 69))
local btnLeft = displayMesh.clicked(vec2(453, 217),vec2(64, 72))
local btnMid = displayMesh.clicked(vec2(434, 324),vec2(111, 113))
local btnMidHold = displayMesh.pressed(vec2(434, 324),vec2(111, 113),1)

local maxValues = {["boost"]=-350, ["oilT"] = 70, ["waterT"] = 0, ["exhT"] = 0,["intT"]=0,["volt"] = 8}
local maxValues2 = {["boost"]=-350, ["oilT"] = 70, ["waterT"] = 0, ["exhT"] = 0,["intT"]=0,["volt"] = 8}

--aux variables for the gauges--

local leftPivot = vec2(282-40, 226)
local leftPos = vec2(190-40, 230)
local leftOffset = -40

local rightPos = vec2(620, 230)
local rightPivot = vec2(703, 226)
local rightOffset= 425

local maxTurboPercentage = 0
local maxOilPercentage = 0
local maxIDCPercentage = 0
local maxThrottlePercentage = 0
local maxFTorquePercentage = 0
local maxVoltPercentage = 0
local maxExhPercentage = 0
local maxTempPercentage = 0

local mfdSize= vec2(324,380) --size for mfd gauges


--tables with the stored values for the graphs--

function fillTable(yVal) --fills the tables with the initial coords
    local valTable = {}
    for i=0,300 do
        table.insert(valTable, vec2(465-(1.15*i),yVal))
    end
    return valTable
end

local boostVals = fillTable(332)
local throttleVals = fillTable(399)
local idcVals = fillTable(399)
local voltVals = fillTable(399)
local torqueVals = fillTable(399)
local oilVals = fillTable(399)
local exhVals = fillTable(399)
local intVals = fillTable(399)


--define some colours so we dont call them every tick--

local colours = {
    white = rgbm(1,1,1,1),
    red = rgbm(1,0,0,1),
    black = rgbm(0,0,0,1),
    none = rgbm(0,0,0,0),
    yellow = rgbm(1,1,0,1),
    green = rgbm(0,1,0,1),
    darkblue = rgbm(0,0.01,0.09,1),
    dimwhite = rgbm(1,1,1,0.1),
    lightgrey = rgbm(0.8,0.8,0.8,1),
    moderateorange = rgbm(0.85,0.60,0.50,1),
}


--twin menu variables--

local twinSelection= {{1,0},{0,0},{0,0}} --which of the buttons is being hovered in the main twin menu
local twinCoords = {{vec2(197,140),vec2(330,140)}, {vec2(197,300),vec2(330,300)}, {vec2(597,140),vec2(730,140)}, {vec2(597,300),vec2(730,300)}}
local currentTwinSetup = {0,1,0,0,0} --which of the 5 buttons is selected in the twin setup menu
local changedTwins = {0,0,0,0} --which of the 4 twins has been changed, used to draw yellow text
local twinTextColor = rgbm(1,1,1,1)
local activeIcon = {{0,0},{0,0},{0,0}} 
local isSelectingGauges = false
local isSelectingTwin = false
local isSelectingSide = false
local isSelectingLeft = false
local isSelectingRight = false
local hasSelectedLeft = false
local hasSelectedRight = false
local colorMode = true
local selectingColor = rgbm(0,1,0,0)
local currentTwinNo = 1 --current twin selected on the setup menu

--menu variables --

local modeNumber = 1 --current mode selected, increments when clicking the button: 1- Bar Menu / 2- TWIN/ 3- Gauge +  Graph combo
local isMenuActive = false --was the 'menu' button clicked, causing the menu to open?
local isSelectActive = false --did the user select the 'select' menu?
local isShiftActive = false  --did the user select the 'shift up' menu?
local isRedActive = false  --did the user select the 'red zone' menu?
local menuOptions = {1,0,0}
local menu1Options = {0,1,0}
local activeMenu = {"SELECT","RED ZONE", "SHIFT UP"}

--storing prev menu variables (used for return) --

local prevModeNumber = modeNumber
local prevIsMenuActive = isMenuActive
local prevIsSelectActive = isSelectActive
local prevIsShiftActive = isShiftActive
local prevIsRedActive = isRedActive

-- graph menu variables--

local selectedMode3 = {{1,0,0,0},{0,0,0,0}}
local activeMode3 = {{"BOOST","OIL-TEMP","F-TORQUE","VOLT"},{"THROTTLE","INJECTOR","EXH-TEMP","INT-TEMP"}}

--shift mode variables--

local currentShiftTreshold = 3
local tresholds = {5000,6000,7000,8000,9000,10000}

-- red menu variables --

local activeRed = {true, false, false, false, false, false, false}
local redColors = {colours["yellow"],colours["white"],colours["white"],colours["white"],colours["white"]}


--display menu variables--

local activeDisplay = {true,false,false,false}
local autoDimming = storedValues.autoDimming  --storing this
local brightnessAdjustment = storedValues.brightnessAdjustment  --storing this
local gaugeTail = storedValues.gaugeTail --storing this 
local isScreenOn =  storedValues.isScreenOn  --storing this 
local screenBrightness = storedValues.screenBrightness --storing this

--boot up animation stuff--

local booted = false
local bootup = ui.MediaPlayer()
bootup:setSource('bootup.mp4'):setAutoPlay(true)


--switchover when bars flash red--

local switchOver = false

function drawMenuBars(basex, basey, sizex, sizey, redMenu)
    if not redMenu then --different behaviour for red zone menu
        display.rect{pos= vec2(basex,basey), size= vec2(sizex,sizey), color= colours["white"]}
        display.rect{pos= vec2(basex+5,basey+5), size= vec2(sizex-10,sizey-10), color= colours["darkblue"]}
        display.rect{pos= vec2(basex+215,basey), size= vec2(sizex-440,sizey), color= colours["white"]}
        display.rect{pos= vec2(basex+220,basey+5), size= vec2(sizex-450,sizey-10), color= colours["darkblue"]}
        display.rect{pos= vec2(basex+215,basey), size= vec2(sizex-730,sizey), color= colours["white"]}
        display.rect{pos= vec2(basex+220,basey+5), size= vec2(sizex-740,sizey-10), color= colours["darkblue"]}
    else
        display.rect{pos= vec2(basex+215,basey), size= vec2(sizex-440,sizey), color= colours["white"]}
        display.rect{pos= vec2(basex+220,basey+5), size= vec2(sizex-450,sizey-10), color= colours["darkblue"]}
        display.rect{pos= vec2(basex+215,basey), size= vec2(sizex-690,sizey), color= colours["white"]}
        display.rect{pos= vec2(basex+220,basey+5), size= vec2(sizex-700,sizey-10), color= colours["darkblue"]}
    end
   
end

function drawBarMenuText(starterx)
    display.text{pos = vec2(starterx, 55), letter = vec2(35,70), spacing = -10,text = "BOOST", font = "MFDArialItallic", color= colours["white"]}
    display.text{pos = vec2(starterx-5, 115), letter = vec2(35,70), spacing = -11,text = "THROTTLE", font = "MFDArialItallic", color= colours["white"]}
    display.text{pos = vec2(starterx-5, 175), letter = vec2(35,70), spacing = -11,text = "INJECTOR", font = "MFDArialItallic", color= colours["white"]}
    display.text{pos = vec2(starterx, 235), letter = vec2(35,70), spacing = -15,text = "OIL", font = "MFDArialItallic", color= colours["white"]}
    display.text{pos = vec2(starterx+55, 235), letter = vec2(35,70),text = "-", font = "MFDArialItallic", color= colours["white"]}
    display.text{pos = vec2(starterx+70, 235), letter = vec2(35,70), spacing = -10,text = "TEMP", font = "MFDArialItallic", color= colours["white"]}

    display.text{pos = vec2(starterx+5, 295), letter = vec2(35,70),text = "W", font = "MFDArialItallic", color= colours["white"]}
    display.text{pos = vec2(starterx+30, 295), letter = vec2(35,70),text = "-", font = "MFDArialItallic", color= colours["white"]}
    display.text{pos = vec2(starterx+50, 295), letter = vec2(35,70), spacing = -10,text = "TEMP", font = "MFDArialItallic", color= colours["white"]}
    
    display.text{pos = vec2(starterx, 355), letter = vec2(35,70), spacing = -12,text = "EXH", font = "MFDArialItallic", color= colours["white"]}
    display.text{pos = vec2(starterx+65, 355), letter = vec2(35,70),text = "-", font = "MFDArialItallic", color= colours["white"]}
    display.text{pos = vec2(starterx+80, 355), letter = vec2(35,70), spacing = -10,text = "TEMP", font = "MFDArialItallic", color= colours["white"]}

    display.text{pos = vec2(starterx-5, 415), letter = vec2(35,70), spacing = -12,text = "INT", font = "MFDArialItallic", color= colours["white"]}
    display.text{pos = vec2(starterx+55, 415), letter = vec2(35,70),text = "-", font = "MFDArialItallic", color= colours["white"]}
    display.text{pos = vec2(starterx+70, 415), letter = vec2(35,70), spacing = -10,text = "TEMP", font = "MFDArialItallic", color= colours["white"]}
end

function idcLevel(rpm)
    return math.saturate(rpm/8000)*100-10 --find accurate equation
end

function getBarColor(currentval,treshold)
    if currentval < treshold then
        return colours["green"]
    else 
        return colours["red"]
    end
end

function displayCelsiusCustomInput(input, ypos, boundary, boundaryval)
    if boundary and input-boundaryval <= 0 then
        display.text{width=205,pos = vec2(670, ypos),alignment=1, letter = vec2(40, 40), spacing = -15,text="---", font = "Microsquare", color= colours["white"]}
    elseif boundary then
        display.text{width=205,pos = vec2(670, ypos),alignment=1, letter = vec2(40, 40), spacing = -15,text=string.format("%.0f",input), font = "Microsquare", color= colours["white"]}
    else
        display.text{width=205,pos = vec2(670, ypos),alignment=1, letter = vec2(40, 40), spacing = -15,text=string.format("%.0f",input), font = "Microsquare", color= colours["white"]}
    end
    display.text{pos = vec2(869, ypos-4), letter = vec2(20, 25),text="o", font = "c7_mid", color= colours["white"]}
    display.text{pos = vec2(880, ypos-4), letter = vec2(32, 55),text="C", font = "c7_mid", color= colours["white"]}
end

function displayPercentageCustomInput(input, ypos)
    display.text{width=200,pos = vec2(670, ypos),alignment=1, letter = vec2(40, 35), spacing = -15,text=string.format("%.1f",input), font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(872, ypos-5), letter = vec2(35, 50),text="%", font = "c7_mid", color= colours["white"]}
end

function drawBarMenuGreenBars()

    --boost bar--
    
    displayedPressure = (car.turboBoost+0.3)*10
    maxValues["boost"] = math.max(maxValues["boost"],displayedPressure)
    boostBar = math.max(0,(maxValues["boost"]+0.3)*15)
    ui.drawRectFilled(vec2(405,55),vec2(410+displayedPressure*15,100),getBarColor(2*math.floor(car.turboBoost*100)/100-0.3, tresholdValues[1]))
    ui.drawRectFilled(vec2(405+boostBar,55),vec2(405+boostBar+5,100),colours["white"]) --more optimized than using horizontal bar

    display.text{width=205,pos = vec2(605, 60),alignment=1, letter = vec2(40, 35), spacing = -18,text=string.format("%.2f", 2*math.floor(car.turboBoost*100)/100-0.3), font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(845, 55), letter = vec2(30, 50), spacing = -10,text="kPa", font = "c7_mid", color= colours["white"]}
    display.text{pos = vec2(802, 55), letter = vec2(15, 30), spacing = -3,text="x100", font = "c7_mid", color= colours["white"]}

    --throttle bar (no max) --

    display.horizontalBar{pos= vec2(405,115), size= vec2(290,45), delta=0, activeColor= colours["green"], inactiveColor= colours["none"], total=100, active=car.gas*100}
    displayPercentageCustomInput(car.gas*100,120)
   
    --idc bar (no max?)--

    display.horizontalBar{pos= vec2(405,175), size= vec2(285,45), delta=0, activeColor= getBarColor(idcLevel(car.rpm),tresholdValues[2]), inactiveColor= colours["none"], total=100, active=idcLevel(car.rpm)}    
    displayPercentageCustomInput(idcLevel(car.rpm),180)

    --oil temp bar--

    maxValues["oilT"] = math.max(maxValues["oilT"],car.oilTemperature)
    oilBar = math.max(0,maxValues["oilT"]-70)
    ui.drawRectFilled(vec2(405,235),vec2(410+car.oilTemperature-70,280),getBarColor(car.oilTemperature,tresholdValues[3]))
    ui.drawRectFilled(vec2(405+oilBar,235),vec2(405+oilBar+5,280),colours["white"]) --more optimized than using horizontal bar   
    displayCelsiusCustomInput(car.oilTemperature, 237, true, 70)

    --water temp bar--

    maxValues["waterT"] = math.max(maxValues["waterT"],car.waterTemperature)
    waterBar = math.max(0,maxValues["waterT"]-70)
    ui.drawRectFilled(vec2(405,295),vec2(410+car.waterTemperature-70,340),getBarColor(car.waterTemperature,tresholdValues[4]))
    ui.drawRectFilled(vec2(405+waterBar,295),vec2(405+waterBar+5,340),colours["white"])
    displayCelsiusCustomInput(car.waterTemperature, 297, true, 70)

    --exhaust temp bar--
    maxValues["exhT"] = math.max(maxValues["exhT"],car.exhaustTemperature)
    exhBar = math.max(0,maxValues["exhT"]*0.29)
    
    ui.drawRectFilled(vec2(405,355),vec2(410+car.exhaustTemperature*0.29,400),getBarColor(car.exhaustTemperature,tresholdValues[5]))
    ui.drawRectFilled(vec2(405+exhBar,355),vec2(405+exhBar+5,400),colours["white"])        
    displayCelsiusCustomInput(car.exhaustTemperature, 357) --omitting boundary flag is the same as typing false

    --intercooler temp bar, not very realistic, oh well--

    local intercoolerTemp = math.min(car.exhaustTemperature/10, 100) --coding hard limit
    maxValues["intT"] = math.max(maxValues["intT"],car.exhaustTemperature/10)
    intBar = math.max(0,maxValues["intT"]*2.9)
    
    ui.drawRectFilled(vec2(405,415),vec2(410+(intercoolerTemp)*2.8,460),colours["green"])
    ui.drawRectFilled(vec2(405+intBar,415),vec2(405+intBar+5,460),colours["white"])    
    displayCelsiusCustomInput(intercoolerTemp, 417,true,0)

    --drawing all icons--

    display.image{image ="MFD.png",pos = vec2(310,57),size = vec2(60,50),color = colours["white"], uvStart = vec2(1416/1536,282/1210),uvEnd = vec2(1530/1536, 374/1210)} --turbo icon
    display.image{image ="MFD.png",pos = vec2(310,113),size = vec2(60,50),color = colours["white"], uvStart = vec2(1416/1536,650/1210),uvEnd = vec2(1530/1536, 742/1210)} -- throttle icon
    display.image{image ="MFD.png",pos = vec2(310,175),size = vec2(60,50),color = colours["white"], uvStart = vec2(1416/1536,750/1210),uvEnd = vec2(1530/1536, 842/1210)} -- injector icon
    display.image{image ="MFD.png",pos = vec2(310,235),size = vec2(60,50),color = colours["white"], uvStart = vec2(1416/1536,370/1210),uvEnd = vec2(1530/1536, 462/1210)} -- oil icon
    display.image{image ="MFD.png",pos = vec2(310,295),size = vec2(60,50),color = colours["white"], uvStart = vec2(1416/1536,190/1210),uvEnd = vec2(1530/1536, 282/1210)} --water icon
    display.image{image ="MFD.png",pos = vec2(310,360),size = vec2(60,50),color = colours["white"], uvStart = vec2(1416/1536,850/1210),uvEnd = vec2(1530/1536, 940/1210)} -- exhaust icon
    display.image{image ="MFD.png",pos = vec2(310,412),size = vec2(60,50),color = colours["white"], uvStart = vec2(1416/1536,932/1210),uvEnd = vec2(1530/1536, 1024/1210)} -- int icon

end

setInterval(function()  --if middle button is held, reset max values
    if btnMidHold() then        
        maxValues = {["boost"]=-350, ["oilT"] = 70, ["waterT"] = 0, ["exhT"] = 0,["intT"]=0,["volt"] = 8}
    end
end
,1.5)

function drawBarMenu()
    local starterx=60
    local startery=50

    for i = 0, 6 do --drawing the outlines of every bar...
       drawMenuBars(starterx, startery, 860, 55, false) 
       startery=startery+60
    end
    
    drawBarMenuText(starterx+10)
    drawBarMenuGreenBars()
end

function drawIntGauge(sidePivot, sidePos,sideOffset)
    local tempPercentage = math.min(100, car.exhaustTemperature/10)
    maxTempPercentage = math.max(maxTempPercentage,tempPercentage)
    local maxRotation = (-maxTempPercentage) * 2.65 --2.65 is the rotation deg /100

    display.text{pos = vec2(sideOffset+110,405), letter = vec2(40,60), spacing = -5,text="C", font = "c7_mid", color= colours["white"]}
    display.text{pos = vec2(sideOffset+95,400), letter = vec2(25,40), spacing = 0,text="o", font = "c7_mid", color= colours["white"]}
    display.text{pos = vec2(sideOffset+52,402), letter = vec2(40,60), spacing = 60,text="[]", font = "c7_mid", color= colours["white"]}

    for i = 1, 80 do
        local thisRotation = (-tempPercentage) * 2.65 -- "-" turns rotation counter clockwise
        ui.beginRotation()
        ui.beginRotation()
        if gaugeTail then
            display.rect {pos = sidePos, size = vec2(21, 120), color = colours["green"]}
        end
        if i==80 then
            display.rect {pos = sidePos, size = vec2(7, 120), color = colours["red"]}
        end
        ui.endRotation(35)
        if tempPercentage > (100 / 80 * i) then
            thisRotation = -(100 / 80 * i) * 2.65
        end
        
        ui.endPivotRotation(thisRotation + 142, sidePivot)

        ui.beginRotation()
        ui.beginRotation()
        display.rect {pos = vec2(sidePos.x+5, sidePos.y-5), size = vec2(7, 115), color = colours["white"]}
        ui.endRotation(35)
        ui.endPivotRotation(maxRotation + 140, sidePivot)
    end

    display.image{image ="MFD.png",pos = vec2(sideOffset+125,70),size = mfdSize,color = colours["white"], uvStart = vec2(0,520/1210),uvEnd = vec2(435/1536, 1024/1210)} --3rd gauge
    display.image{image ="MFD.png",pos = vec2(sideOffset+310,230),size = vec2(90,70),color = colours["white"], uvStart = vec2(1416/1536,932/1210),uvEnd = vec2(1530/1536, 1024/1210)} -- int icon

    maxValues["intT"] = math.max(maxValues["intT"],tempPercentage)

    display.text{width=205,pos = vec2(sideOffset+230, 318),alignment=1, letter = vec2(60, 50), spacing = -25,text=math.floor(maxValues["intT"]), font = "Microsquare", color= colours["black"]}
    display.text{width=205,pos = vec2(sideOffset+230, 315),alignment=1, letter = vec2(60, 50), spacing = -25,text=math.floor(maxValues["intT"]), font = "Microsquare", color= colours["white"]}
    
    display.text{pos = vec2(sideOffset+230, 390), letter = vec2(45,40), spacing = -19,text="0", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(sideOffset+140, 360), letter = vec2(45,40), spacing = -19,text="10", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(sideOffset+80, 310), letter = vec2(45,40), spacing = -19,text="20", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(sideOffset+55, 230), letter = vec2(45,40), spacing = -19,text="30", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(sideOffset+65, 150), letter = vec2(45,40), spacing = -19,text="40", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(sideOffset+100, 85), letter = vec2(45,40), spacing = -19,text="45", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(sideOffset+175, 35), letter = vec2(45,40), spacing = -19,text="60", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(sideOffset+270, 30), letter = vec2(45,40), spacing = -19,text="70", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(sideOffset+360,60), letter = vec2(45,40), spacing = -19,text="80", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(sideOffset+410,130), letter = vec2(45,40), spacing = -19,text="90", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(sideOffset+420,200), letter = vec2(45,40), spacing = -19,text="100", font = "Microsquare", color= colours["white"]}
end

function drawExhGauge(sidePivot, sidePos, sideOffset)
    local exhPercentage = (car.exhaustTemperature*100)/1000 -- conversion to %
    maxExhPercentage = math.max(maxExhPercentage,exhPercentage)
    local maxRotation = (-maxExhPercentage) * 2.65 --2.65 is the rotation deg /100

    display.text{pos = vec2(sideOffset+110,405), letter = vec2(40,60), spacing = -5,text="C", font = "c7_mid", color= colours["white"]}
    display.text{pos = vec2(sideOffset+95,400), letter = vec2(25,40), spacing = 0,text="o", font = "c7_mid", color= colours["white"]}
    display.text{pos = vec2(sideOffset+52,402), letter = vec2(40,60), spacing = 60,text="[]", font = "c7_mid", color= colours["white"]}

    for i = 1, 80 do
        local thisRotation = (-exhPercentage) * 2.65 -- "-" turns rotation counter clockwise
        ui.beginRotation()
        ui.beginRotation()
        if gaugeTail then
            display.rect {pos = sidePos, size = vec2(21, 120), color = getBarColor(car.exhaustTemperature,tresholdValues[5])}
        end
        if i==80 then
            display.rect {pos = sidePos, size = vec2(7, 120), color = colours["red"]}
        end
        ui.endRotation(35)
        if exhPercentage > (100 / 80 * i) then
            thisRotation = -(100 / 80 * i) * 2.65
        end
        
        ui.endPivotRotation(thisRotation + 142, sidePivot)

        ui.beginRotation()
        ui.beginRotation()
        display.rect {pos = vec2(sidePos.x+5, sidePos.y-5), size = vec2(7, 115), color = colours["white"]}
        ui.endRotation(35)
        ui.endPivotRotation(maxRotation + 141, sidePivot)
    end

    display.image{image ="MFD.png",pos = vec2(sideOffset+125,70),size = mfdSize,color = colours["white"], uvStart = vec2(0,520/1210),uvEnd = vec2(435/1536, 1024/1210)} --3rd gauge
  

    maxValues["exhT"] = math.max(maxValues["exhT"],car.exhaustTemperature)

    display.text{width=205,pos = vec2(sideOffset+230, 318),alignment=1, letter = vec2(55, 45), spacing = -25,text=math.floor(maxValues["exhT"]), font = "Microsquare", color= colours["black"]}
    display.text{width=205,pos = vec2(sideOffset+230, 315),alignment=1, letter = vec2(55, 45), spacing = -25,text=math.floor(maxValues["exhT"]), font = "Microsquare", color= colours["white"]}
    
    display.text{pos = vec2(sideOffset+255, 385), letter = vec2(40,35), spacing = -16,text="0", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(sideOffset+135, 365), letter = vec2(40,35), spacing = -16,text="100", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(sideOffset+65, 310), letter = vec2(40,35), spacing = -16,text="200", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(sideOffset+40, 235), letter = vec2(40,35), spacing = -16,text="300", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(sideOffset+45, 155), letter = vec2(40,35), spacing = -16,text="400", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(sideOffset+85, 90), letter = vec2(40,35), spacing = -16,text="500", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(sideOffset+165, 45), letter = vec2(40,35), spacing = -16,text="600", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(sideOffset+265, 35), letter = vec2(40,35), spacing = -16,text="700", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(sideOffset+355, 65), letter = vec2(40,35), spacing = -16,text="800", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(sideOffset+410, 130), letter = vec2(40,35), spacing = -16,text="900", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(sideOffset+420, 205), letter = vec2(35,35), spacing = -16,text="1000", font = "Microsquare", color= colours["white"]}
end

function drawVoltGauge(sidePivot, sidePos, sideOffset)
    local voltPercentage = (((car.batteryVoltage-8)*100)/8) -- conversion to %
    maxVoltPercentage = math.max(maxVoltPercentage,voltPercentage)
    local maxRotation = (-maxVoltPercentage) * 2.3 --2.3 is the rotation deg /100

    display.text{pos = vec2(sideOffset+120,395), letter = vec2(50,70), spacing = -5,text="v", font = "c7_mid", color= colours["white"]}
    display.text{pos = vec2(sideOffset+82,413), letter = vec2(35,40), spacing = -7,text="[  ]", font = "c7_mid", color= colours["white"]}
    
    for i = 1, 40 do
        local thisRotation = (-voltPercentage) * 2.3 -- "-" turns rotation counter clockwise
        ui.beginRotation()
        ui.beginRotation()
        if gaugeTail then
            display.rect {pos = sidePos,size = vec2(16, 120),color = colours["green"]}
        end
        if i==40 then
            display.rect {pos = sidePos,size = vec2(7, 120),color = colours["red"]}
        end
        ui.endRotation(35)
        if voltPercentage > (100 / 40 * i) then
            thisRotation = -(100 / 40 * i) * 2.3
        end
        
        ui.endPivotRotation(thisRotation + 140, sidePivot)

        ui.beginRotation()
        ui.beginRotation()
        display.rect {pos = vec2(sidePos.x+5, sidePos.y-5),size = vec2(7, 120),color = colours["white"]}
        ui.endRotation(35)
        ui.endPivotRotation(maxRotation + 138, sidePivot)
    end

    display.image{image ="MFD.png",pos = vec2(sideOffset+128,70),size = mfdSize,color = colours["white"], uvStart = vec2(895/1536,523/1210),uvEnd = vec2(1335/1536,1024/1210)} --1st gauge
    display.image{image ="MFD.png",pos = vec2(sideOffset+310,235),size=vec2(90,70),color = colours["white"], uvStart = vec2(1416/1536,550/1210),uvEnd = vec2(1530/1536, 642/1210)} -- volt icon

    maxValues["volt"] = math.max(maxValues["volt"],car.batteryVoltage)

    display.text{width=205,pos = vec2(sideOffset+240, 318),alignment=1, letter = vec2(55, 50), spacing = -25,text=string.format("%.1f", maxValues["volt"]), font = "Microsquare", color= colours["black"]}
    display.text{width=205,pos = vec2(sideOffset+238, 315),alignment=1, letter = vec2(55, 50), spacing = -25,text=string.format("%.1f", maxValues["volt"]), font = "Microsquare", color= colours["white"]}

    display.text{pos = vec2(sideOffset+245, 385), letter = vec2(50,45), spacing = -25,text="8", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(sideOffset+140, 355), letter = vec2(50,45), spacing = -25,text="9", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(sideOffset+65, 290), letter = vec2(50,45), spacing = -25,text="10", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(sideOffset+50, 200), letter = vec2(50,45), spacing = -25,text="11", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(sideOffset+75, 100), letter = vec2(50,45), spacing = -25,text="12", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(sideOffset+145, 45), letter = vec2(50,45), spacing = -25,text="13", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(sideOffset+235, 25), letter = vec2(50,45), spacing = -25,text="14", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(sideOffset+320, 40), letter = vec2(50,45), spacing = -25,text="15", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(sideOffset+385, 95), letter = vec2(50,45), spacing = -25,text="16", font = "Microsquare", color= colours["white"]}

end

function drawFTorqueGauge(sidePivot, sidePos,sideOffset)
    local torquePercentage = math.abs(car.drivetrainTorque)/6 -- conversion to %
    maxFTorquePercentage = math.max(maxFTorquePercentage,torquePercentage)
    local maxRotation = (-maxFTorquePercentage) * 2.5 --2.5 is the rotation deg /100

    display.text{pos = vec2(sideOffset+80,415), letter = vec2(30,45), spacing = -10,text="x10", font = "c7_mid", color= colours["white"]}
    display.text{pos = vec2(sideOffset+150,415), letter = vec2(25,45), spacing = 10,text="Nm", font = "c7_mid", color= colours["white"]}
    display.text{pos = vec2(sideOffset+151,401), letter = vec2(55,55), spacing = 10,text=".", font = "c7_mid", color= colours["white"]}
    display.text{pos = vec2(sideOffset+52,402), letter = vec2(40,60), spacing = 9,text="[  ]", font = "c7_mid", color= colours["white"]}

    for i = 1, 80 do
        local thisRotation = (-torquePercentage) * 2.5 -- "-" turns rotation counter clockwise
        ui.beginRotation()
        ui.beginRotation()
        if gaugeTail then
            display.rect {pos = sidePos,size = vec2(21, 120),color = colours["green"]}
        end
        if i==80 then
            display.rect {pos = sidePos,size = vec2(7, 120),color = colours["red"]}
        end
        ui.endRotation(35)
        if torquePercentage > (100 / 80 * i) then
            thisRotation = -(100 / 80 * i) * 2.5
        end
        
        ui.endPivotRotation(thisRotation + 138, sidePivot)

        ui.beginRotation()
        ui.beginRotation()
        display.rect {pos = vec2(sidePos.x+5, sidePos.y-5),size = vec2(7, 115),color = colours["white"]}
        ui.endRotation(35)
        ui.endPivotRotation(maxRotation + 135, sidePivot)
    end

    display.image{image ="MFD.png",pos = vec2(sideOffset+128,70),size = mfdSize,color = colours["white"], uvStart = vec2(0,0),uvEnd = vec2(435/1536, 506/1210)} --1st gauge
    display.image{image ="MFD.png",pos = vec2(sideOffset+310,235),size=vec2(90,70),color = colours["white"], uvStart = vec2(1416/1536,450/1210),uvEnd = vec2(1530/1536, 542/1210)} -- torque icon

    
    if math.floor(maxFTorquePercentage/6) > 0 then
        display.text{width=205,pos = vec2(sideOffset+245, 318),alignment=1, letter = vec2(65, 50), spacing = -25,text= math.floor(maxFTorquePercentage/6), font = "Microsquare", color= colours["black"]}
        display.text{width=205,pos = vec2(sideOffset+242, 315),alignment=1, letter = vec2(65, 50), spacing = -25,text= math.floor(maxFTorquePercentage/6), font = "Microsquare", color= colours["white"]}
    else
        display.text{width=205,pos = vec2(sideOffset+245, 318),alignment=1, letter = vec2(65, 50), spacing = -25,text= "---", font = "Microsquare", color= colours["black"]}
        display.text{width=205,pos = vec2(sideOffset+242, 315),alignment=1, letter = vec2(65, 50), spacing = -25,text= "---", font = "Microsquare", color= colours["white"]}
    end
    
    display.text{pos = vec2(sideOffset+250, 385), letter = vec2(50,45), spacing = -20,text="0", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(sideOffset+155, 355), letter = vec2(50,45), spacing = -20,text="2", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(sideOffset+80, 250), letter = vec2(50,45), spacing = -20,text="4", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(sideOffset+85, 150), letter = vec2(50,45), spacing = -20,text="6", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(sideOffset+120, 85), letter = vec2(50,45), spacing = -20,text="8", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(sideOffset+155, 40), letter = vec2(50,45), spacing = -20,text="10", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(sideOffset+220, 20), letter = vec2(50,45), spacing = -20,text="15", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(sideOffset+295, 30), letter = vec2(50,45), spacing = -20,text="20", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(sideOffset+360, 52), letter = vec2(50,45), spacing = -20,text="25", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(sideOffset+400, 92), letter = vec2(50,45), spacing = -20,text="30", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(sideOffset+425, 150), letter = vec2(50,45), spacing = -20,text="40", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(sideOffset+435, 200), letter = vec2(50,45), spacing = -20,text="50", font = "Microsquare", color= colours["white"]}

end

function drawThrottleGauge(sidePivot, sidePos, sideOffset)
    local throttlePercentage = (car.gas*100) -- conversion to %

    display.text{pos = vec2(sideOffset+117,402), letter = vec2(45,65), spacing = -5,text="%", font = "c7_mid", color= colours["white"]}
    display.text{pos = vec2(sideOffset+82,413), letter = vec2(35,40), spacing = -7,text="[  ]", font = "c7_mid", color= colours["white"]}

    for i = 1, 80 do
        local thisRotation = (-throttlePercentage) * 2.25 -- "-" turns rotation counter clockwise
        ui.beginRotation()
        ui.beginRotation()
        if gaugeTail then
            display.rect {pos = sidePos,size = vec2(21, 120),color = colours["green"]}
        end
        if i==80 then
            display.rect {pos = sidePos, size = vec2(7, 120), color = colours["red"]}
        end
        ui.endRotation(35)
        if throttlePercentage > (100 / 80 * i) then
            thisRotation = -(100 / 80 * i) * 2.25
        end
        
        ui.endPivotRotation(thisRotation + 138, sidePivot)

    end

    display.image{image ="MFD.png",pos = vec2(sideOffset+125,70),size = mfdSize,color = colours["white"], uvStart = vec2(440/1536,0),uvEnd = vec2(872/1536, 506/1210)} --2nd gauge
    display.image{image ="MFD.png",pos = vec2(sideOffset+310,235),size=vec2(90,70),color = colours["white"], uvStart = vec2(1416/1536,650/1210),uvEnd = vec2(1530/1536, 742/1210)} -- throttle icon
    display.text{pos = vec2(sideOffset+245, 380), letter = vec2(50,45), spacing = -25,text="0", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(sideOffset+105, 335), letter = vec2(50,45), spacing = -25,text="20", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(sideOffset+50, 200), letter = vec2(50,45), spacing = -25,text="40", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(sideOffset+100, 75), letter = vec2(50,45), spacing = -25,text="60", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(sideOffset+240, 25), letter = vec2(50,45), spacing = -25,text="80", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(sideOffset+370, 80), letter = vec2(50,45), spacing = -25,text="100", font = "Microsquare", color= colours["white"]}

end

function drawInjectorGauge(sidePivot, sidePos, sideOffset)
    
    local idcPercentage = idcLevel(car.rpm) -- conversion to %
    local thisRotation = (-idcPercentage) * 2.25 -- "-" turns rotation counter clockwise
    
    display.text{pos = vec2(sideOffset+117,402), letter = vec2(45,65), spacing = -5,text="%", font = "c7_mid", color= colours["white"]}
    display.text{pos = vec2(sideOffset+82,413), letter = vec2(35,40), spacing = -7,text="[  ]", font = "c7_mid", color= colours["white"]}

    for i = 1, 80 do
        
        ui.beginRotation()
        ui.beginRotation()
        if gaugeTail then
            display.rect {pos = sidePos,size = vec2(20, 120),color = getBarColor(idcLevel(car.rpm),tresholdValues[2])}
        end
        if i==80 then
            display.rect {pos = sidePos,size = vec2(7, 120),color = colours["red"]}
        end
        ui.endRotation(35)

        if idcPercentage > (100 / 80 * i) then
            thisRotation = -(100 / 80 * i) * 2.25
        end

        ui.endPivotRotation(thisRotation + 140,sidePivot)

    end

    display.image{image ="MFD.png",pos = vec2(sideOffset+125,70),size = mfdSize,color = colours["white"], uvStart = vec2(440/1536,0),uvEnd = vec2(872/1536, 506/1210)} --2nd gauge
    display.image{image ="MFD.png",pos = vec2(sideOffset+330,240),size = vec2(90,70),color = colours["white"], uvStart = vec2(1416/1536,750/1210),uvEnd = vec2(1530/1536, 842/1210)} -- injector icon
    display.text{pos = vec2(sideOffset+245, 380), letter = vec2(55,45), spacing = -25,text="0", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(sideOffset+105, 335), letter = vec2(55,45), spacing = -25,text="20", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(sideOffset+50, 200), letter = vec2(55,45), spacing = -25,text="40", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(sideOffset+100, 75), letter = vec2(55,45), spacing = -25,text="60", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(sideOffset+240, 25), letter = vec2(55,45), spacing = -25,text="80", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(sideOffset+370, 80), letter = vec2(55,45), spacing = -25,text="100", font = "Microsquare", color= colours["white"]}

end

function drawTurboGauge(sidePivot, sidePos, sideOffset)
    
    local turboPercentage = ((car.turboBoost+0.32)*0.689 * 100) -- conversion to %
    local thisRotation = (-turboPercentage) * 2.8 -- "-" turns rotation counter clockwise
    maxTurboPercentage = math.max(maxTurboPercentage,turboPercentage)
    local maxRotation = (-maxTurboPercentage+1) * 2.8

    display.text{pos = vec2(sideOffset+85,400), letter = vec2(30,40), spacing = -5,text="x100", font = "c7_mid", color= colours["white"]}
    display.text{pos = vec2(sideOffset+95,430), letter = vec2(25,40), spacing = 0,text="mmHg", font = "c7_mid", color= colours["white"]}
    display.text{pos = vec2(sideOffset+64,413), letter = vec2(20,40), spacing = 13,text="[   ]", font = "c7_mid", color= colours["white"]}

    display.text{pos = vec2(sideOffset+430,2), letter = vec2(15,25), spacing = -5,text="2", font = "c7_mid", color= colours["white"]}
    display.text{pos = vec2(sideOffset+325,5), letter = vec2(25,40), spacing = -5,text="kglcm", font = "c7_mid", color= colours["white"]}
    display.text{pos = vec2(sideOffset+310,2), letter = vec2(20,40), spacing = 13,text="[   ]", font = "c7_mid", color= colours["white"]}
    
    for i = 1, 40 do
        
        ui.beginRotation()
        ui.beginRotation()

        if gaugeTail then
            display.rect {pos = sidePos, size = vec2(20, 120), color = getBarColor(2*math.floor(car.turboBoost*100)/100-0.3, tresholdValues[1])}
        end
        if i==40 then
            display.rect {pos = sidePos, size = vec2(7, 120), color = colours["red"]}
        end
        ui.endRotation(35)

        if turboPercentage > (100 / 40 * i) then
            thisRotation = -(100 / 40 * i) * 2.8
        end

        ui.endPivotRotation(thisRotation + 146,sidePivot)
        ui.beginRotation()
        ui.beginRotation()
        display.rect {pos = vec2(sidePos.x+5, sidePos.y-5), size = vec2(7, 115), color = colours["white"]}
        ui.endRotation(35)
        ui.endPivotRotation(maxRotation + 145.5,sidePivot)
    end

    display.image{image ="MFD.png",pos = vec2(sideOffset+125,70),size = mfdSize,color = colours["white"], uvStart = vec2(440/1536,520/1210),uvEnd = vec2(872/1536, 1024/1210)} --4th gauge
    display.image{image ="MFD.png",pos = vec2(sideOffset+330,240),size = vec2(90,70),color = colours["white"], uvStart = vec2(1416/1536,282/1210),uvEnd = vec2(1530/1536, 374/1210)} --turbo icon 
    
    if car.turboBoost < 0.12 then --christ, this sucks so much
        displayedPressure = -350 + math.saturate(car.gas)*3.50
    elseif car.turboBoost < 0.5 and car.turboBoost > 0.12 then
        displayedPressure = car.turboBoost-0.14
    else
        displayedPressure = car.turboBoost+0.02
    end
    maxValues2["boost"] = math.max(maxValues2["boost"],displayedPressure)

    if maxValues2["boost"] < 0 then
        display.text{width=205,pos = vec2(sideOffset+245, 318),alignment=1, letter = vec2(50, 40), spacing = -22,text=math.floor(maxValues2["boost"]), font = "Microsquare", color= colours["black"]}
        display.text{width=205,pos = vec2(sideOffset+242, 315),alignment=1, letter = vec2(50, 40), spacing = -22,text=math.floor(maxValues2["boost"]), font = "Microsquare", color= colours["white"]}
    else
        display.text{width=205,pos = vec2(sideOffset+245, 318),alignment=1, letter = vec2(50, 40), spacing = -22,text=string.format("%.2f", maxValues2["boost"]), font = "Microsquare", color= colours["black"]}
        display.text{width=205,pos = vec2(sideOffset+242, 315),alignment=1, letter = vec2(50, 40), spacing = -22,text=string.format("%.2f", maxValues2["boost"]), font = "Microsquare", color= colours["white"]}
    end

    display.text{pos = vec2(sideOffset+170, 370), letter = vec2(40,40), spacing = -20,text="-6", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(sideOffset+100, 335), letter = vec2(40,40), spacing = -20,text="-4", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(sideOffset+60, 280), letter = vec2(40,40), spacing = -20,text="-2", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(sideOffset+75, 215), letter = vec2(40,40), spacing = -20,text="0", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(sideOffset+65, 120), letter = vec2(40,40), spacing = -25,text="0.2", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(sideOffset+140, 50), letter = vec2(40,40), spacing = -25,text="0.4", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(sideOffset+240, 25), letter = vec2(40,40), spacing = -25,text="0.6", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(sideOffset+330, 40), letter = vec2(40,40), spacing = -25,text="0.8", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(sideOffset+400, 110), letter = vec2(40,40), spacing = -25,text="1.0", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(sideOffset+420, 205), letter = vec2(40,40), spacing = -25,text="1.2", font = "Microsquare", color= colours["white"]}
end


function drawOilTempGauge(sidePivot, sidePos, sideOffset)
  
    local oilPercentage = 13+(((car.oilTemperature-80)*100)/80) -- conversion to %
    maxOilPercentage = math.max(maxOilPercentage,oilPercentage)
    local maxOilRotation = (-maxOilPercentage) * 2.3

    display.text{pos = vec2(sideOffset+110,405), letter = vec2(40,60), spacing = -5,text="C", font = "c7_mid", color= colours["white"]}
    display.text{pos = vec2(sideOffset+95,400), letter = vec2(25,40), spacing = 0,text="o", font = "c7_mid", color= colours["white"]}
    display.text{pos = vec2(sideOffset+52,402), letter = vec2(40,60), spacing = 60,text="[]", font = "c7_mid", color= colours["white"]}


    for i = 1, 80 do
        local thisRotation = (-oilPercentage) * 2.3 -- "-" turns rotation counter clockwise
        ui.beginRotation()
        ui.beginRotation()
        if gaugeTail then
            display.rect {pos = sidePos, size = vec2(21, 120), color = getBarColor(car.oilTemperature,tresholdValues[3])}
        end
        if i==80 then
            display.rect {pos = sidePos,size = vec2(7, 120),color = colours["red"]}
        end
        ui.endRotation(35)
        if oilPercentage > (100 / 80 * i) then
            thisRotation = -(100 / 80 * i) * 2.3
        end
        
        ui.endPivotRotation(thisRotation + 141.2, sidePivot-5)

        ui.beginRotation()
        ui.beginRotation()
        display.rect {pos = vec2(sidePos.x+5, sidePos.y-5),size = vec2(7, 115),color = colours["white"]}
        ui.endRotation(35)
        ui.endPivotRotation(maxOilRotation + 140, sidePivot)
    end

    display.image{image ="MFD.png",pos = vec2(sideOffset+125,70),size = mfdSize,color = colours["white"], uvStart = vec2(889/1536,524/1210),uvEnd = vec2(1324/1536, 1024/1210)} --3rd gauge
    display.image{image ="MFD.png",pos = vec2(sideOffset+330,240),size = vec2(90,70),color = colours["white"], uvStart = vec2(1416/1536,370/1210),uvEnd = vec2(1530/1536, 462/1210)} -- oil icon
    
    maxValues["oilT"] = math.max(maxValues["oilT"],car.oilTemperature)

    if math.floor(maxValues["oilT"]) > 70 then
        display.text{width=205,pos = vec2(sideOffset+230, 318),alignment=1, letter = vec2(60, 50), spacing = -25,text=math.floor(maxValues["oilT"]), font = "Microsquare", color= colours["black"]}
        display.text{width=205,pos = vec2(sideOffset+230, 315),alignment=1, letter = vec2(60, 50), spacing = -25,text=math.floor(maxValues["oilT"]), font = "Microsquare", color= colours["white"]}
    else
        display.text{width=205,pos = vec2(sideOffset+230, 318),alignment=1, letter = vec2(60, 50), spacing = -25,text="---", font = "Microsquare", color= colours["black"]}
        display.text{width=205,pos = vec2(sideOffset+230, 315),alignment=1, letter = vec2(60, 50), spacing = -25,text="---", font = "Microsquare", color= colours["white"]}
    end
    
    display.text{pos = vec2(sideOffset+230, 390), letter = vec2(45,40), spacing = -20,text="70", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(sideOffset+140, 360), letter = vec2(45,40), spacing = -20,text="80", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(sideOffset+70, 280), letter = vec2(45,40), spacing = -20,text="90", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(sideOffset+43, 200), letter = vec2(45,40), spacing = -22,text="100", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(sideOffset+60, 110), letter = vec2(45,40), spacing = -20,text="110", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(sideOffset+120, 50), letter = vec2(45,40), spacing = -20,text="120", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(sideOffset+225, 25), letter = vec2(45,40), spacing = -20,text="130", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(sideOffset+320, 45), letter = vec2(45,40), spacing = -20,text="140", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(sideOffset+395,110), letter = vec2(45,40), spacing = -20,text="150", font = "Microsquare", color= colours["white"]}

end



setInterval(function()

    boostVals[1].y = math.max(75,332-(31.5*(math.floor(math.abs(car.turboBoost)*8))))
    
    for i = 1, 299,2 do
        boostVals[i+1].y=boostVals[i].y
        if i==1 then
            boostVals[i].y=boostVals[#boostVals].y
        else
            boostVals[i].y=boostVals[i-1].y
        end
    end
end
,0.1)

function drawTurboGraph() 

    local starterBoost = 12
    
    display.rect {pos = vec2(120,50),size = vec2(2, 350),color = colours["white"]}
    display.rect {pos = vec2(120,400),size = vec2(350, 2),color = colours["white"]}
    for i=0, 3 do 
        display.rect {pos = vec2(120+(116*i),50),size = vec2(2, 350),color = colours["dimwhite"]}
        display.rect {pos = vec2(120+(115*i),405),size = vec2(5, 20),color = colours["white"]}
    end

    display.text{pos = vec2(441, 425), letter = vec2(40,35), spacing = -17,text="0", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(317, 425), letter = vec2(40,35), spacing = -17,text="10", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(200, 425), letter = vec2(40,35), spacing = -17,text="20", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(87, 425), letter = vec2(40,35), spacing = -17,text="30", font = "Microsquare", color= colours["white"]}

    for i=0, 9 do
        display.text{width=90,alignment=1,pos = vec2(20,58+(33*i)), letter = vec2(40,35), spacing = -25,text=starterBoost/10, font = "Microsquare", color= colours["white"]}
        if starterBoost > 0.2 then
            starterBoost = starterBoost - 2
        else
            starterBoost = starterBoost - 20
        end
        display.rect {pos = vec2(108,73+(33*i)),size = vec2(10, 5),color = colours["white"]}
 
    end

    for i = 0, 9 do
        display.rect {pos = vec2(120,75+(33*i)),size = vec2(350, 2),color = colours["dimwhite"]}
        display.rect {pos = vec2(115,90+(33*i)),size = vec2(4, 4),color = colours["white"]}
    end
 
    for i = 3, 300 do
        ui.drawLine(boostVals[i-1], boostVals[i], colours["green"],1)
        
        
    end
 
end

setInterval(function()
    throttleVals[1].y = math.max(0,399-(324*car.gas)) 
    for i = 1, 299,2 do
        throttleVals[i+1].y=throttleVals[i].y
        if i==1 then
            throttleVals[i].y=throttleVals[#throttleVals].y
        else
            throttleVals[i].y=throttleVals[i-1].y
        end
    end
end
,0.1)

function drawThrottleGraph()   

    local starterThrottle = 100
    
    display.rect {pos = vec2(120,50),size = vec2(2, 350),color = colours["white"]}
    display.rect {pos = vec2(120,400),size = vec2(350, 2),color = colours["white"]}
    for i=0, 3 do 
        display.rect {pos = vec2(120+(116*i),50),size = vec2(2, 350),color = colours["dimwhite"]}
        display.rect {pos = vec2(120+(115*i),405),size = vec2(5, 20),color = colours["white"]}
    end

    display.text{pos = vec2(441, 425), letter = vec2(40,35), spacing = -20,text="0", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(317, 425), letter = vec2(40,35), spacing = -20,text="10", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(200, 425), letter = vec2(40,35), spacing = -20,text="20", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(87, 425), letter = vec2(40,35), spacing = -20,text="30", font = "Microsquare", color= colours["white"]}

    for i=0, 5 do
        display.text{width=90,alignment=1,pos = vec2(20,58+(64.9*i)), letter = vec2(40,35), spacing = -17,text=starterThrottle, font = "Microsquare", color= colours["white"]}
        starterThrottle = starterThrottle - 20
        display.rect {pos = vec2(108,73+(64.9*i)),size = vec2(10, 5),color = colours["white"]}
    end

    for i = 0, 5 do
        display.rect {pos = vec2(120,75+(64.9*i)),size = vec2(350, 2),color = colours["dimwhite"]} 
    end
 
    for i = 3, 300 do
        ui.drawLine(throttleVals[i-1], throttleVals[i], colours["green"],1)
        
    end 
end

setInterval(function()
    idcVals[1].y = math.max(0,399-(3.24*idcLevel(car.rpm)))   
    for i = 1, 299,2 do
        idcVals[i+1].y=idcVals[i].y
        if i==1 then
            idcVals[i].y=idcVals[#idcVals].y
        else
            idcVals[i].y=idcVals[i-1].y
        end
    end
end
,0.1)

function drawIDCGraph()   

    local starterIDC = 100
    
    display.rect {pos = vec2(120,50),size = vec2(2, 350),color = colours["white"]}
    display.rect {pos = vec2(120,400),size = vec2(350, 2),color = colours["white"]}
    for i=0, 3 do 
        display.rect {pos = vec2(120+(116*i),50),size = vec2(2, 350),color = colours["dimwhite"]}
        display.rect {pos = vec2(120+(115*i),405),size = vec2(5, 20),color = colours["white"]}
    end

    display.text{pos = vec2(441, 425), letter = vec2(40,35), spacing = -17,text="0", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(317, 425), letter = vec2(40,35), spacing = -17,text="10", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(200, 425), letter = vec2(40,35), spacing = -17,text="20", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(87, 425), letter = vec2(40,35), spacing = -17,text="30", font = "Microsquare", color= colours["white"]}

    for i=0, 5 do
        display.text{width=90,alignment=1,pos = vec2(20,58+(64.9*i)), letter = vec2(40,35), spacing = -17,text=starterIDC, font = "Microsquare", color= colours["white"]}
        starterIDC = starterIDC - 20
        display.rect {pos = vec2(108,73+(64.9*i)),size = vec2(10, 5),color = colours["white"]}
    end

    for i = 0, 5 do
        display.rect {pos = vec2(120,75+(64.9*i)),size = vec2(350, 2),color = colours["dimwhite"]}   
    end
    
    for i = 0, 4 do
        display.rect {pos = vec2(112,107.5+(64.9*i)),size = vec2(6, 3),color = colours["white"]}
    end

    for i = 3, 300 do
        ui.drawLine(idcVals[i-1], idcVals[i], colours["green"],1)
        
    end 
end

setInterval(function()
   
    voltVals[1].y = math.max(0,399-(3.24*(((car.batteryVoltage-8)*100)/8)))
    for i = 1, 299,2 do
        voltVals[i+1].y=voltVals[i].y
        if i==1 then
            voltVals[i].y=voltVals[#voltVals].y
        else
            voltVals[i].y=voltVals[i-1].y
        end
    end
end
,0.1)

function drawVoltGraph()   

    local starterVolt = 16
    
    display.rect {pos = vec2(120,50),size = vec2(2, 350),color = colours["white"]}
    display.rect {pos = vec2(120,400),size = vec2(350, 2),color = colours["white"]}
    for i=0, 3 do 
        display.rect {pos = vec2(120+(116*i),50),size = vec2(2, 350),color = colours["dimwhite"]}
        display.rect {pos = vec2(120+(115*i),405),size = vec2(5, 20),color = colours["white"]}
    end

    display.text{pos = vec2(441, 425), letter = vec2(40,35), spacing = -17,text="0", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(317, 425), letter = vec2(40,35), spacing = -17,text="10", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(200, 425), letter = vec2(40,35), spacing = -17,text="20", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(87, 425), letter = vec2(40,35), spacing = -17,text="30", font = "Microsquare", color= colours["white"]}

    for i=0, 8 do
        display.text{width=90,alignment=1,pos = vec2(20,58+(40.5*i)), letter = vec2(40,35), spacing = -17,text=starterVolt, font = "Microsquare", color= colours["white"]}
        starterVolt = starterVolt - 1
        display.rect {pos = vec2(108,73+(40.5*i)),size = vec2(10, 5),color = colours["white"]}
    end

    for i = 0, 8 do
        display.rect {pos = vec2(120,75+(40.5*i)),size = vec2(350, 2),color = colours["dimwhite"]}   
    end
    
    for i = 0, 7 do
        display.rect {pos = vec2(112,95.25+(40.5*i)),size = vec2(6, 3),color = colours["white"]}
    end

    for i = 3, 300 do
        ui.drawLine(voltVals[i-1], voltVals[i], colours["green"],1)
        
    end 
end

setInterval(function()
   
    torqueVals[1].y = math.max(0,399-(0.399*math.abs(car.drivetrainTorque)))
    for i = 1, 299,2 do
        torqueVals[i+1].y=torqueVals[i].y
        if i==1 then
            torqueVals[i].y=torqueVals[#torqueVals].y
        else
            torqueVals[i].y=torqueVals[i-1].y
        end
    end
end
,0.1)

function drawFTorqueGraph()   

    local starterTorque = 50
    
    display.rect {pos = vec2(120,50),size = vec2(2, 350),color = colours["white"]}
    display.rect {pos = vec2(120,400),size = vec2(350, 2),color = colours["white"]}
    for i=0, 3 do 
        display.rect {pos = vec2(120+(116*i),50),size = vec2(2, 350),color = colours["dimwhite"]}
        display.rect {pos = vec2(120+(115*i),405),size = vec2(5, 20),color = colours["white"]}
    end

    display.text{pos = vec2(441, 425), letter = vec2(40,35), spacing = -17,text="0", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(317, 425), letter = vec2(40,35), spacing = -17,text="10", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(200, 425), letter = vec2(40,35), spacing = -17,text="20", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(87, 425), letter = vec2(40,35), spacing = -17,text="30", font = "Microsquare", color= colours["white"]}

    for i=0, 10 do
        display.text{width=90,alignment=1,pos = vec2(20,58+(32.5*i)), letter = vec2(40,35), spacing = -17,text=starterTorque, font = "Microsquare", color= colours["white"]}
        if starterTorque >= 30 then
            starterTorque = starterTorque - 10
        elseif starterTorque > 10 then
            starterTorque = starterTorque - 5
        elseif starterTorque >= 0 then
            starterTorque = starterTorque - 2
        end
        display.rect {pos = vec2(108,73+(32.5*i)),size = vec2(10, 5),color = colours["white"]}
    end

    for i = 0, 10 do
        display.rect {pos = vec2(120,75+(32.5*i)),size = vec2(350, 2),color = colours["dimwhite"]}   
    end
    
    for i = 3, 300 do
        ui.drawLine(torqueVals[i-1], torqueVals[i], colours["green"],1)
        
    end 
end

setInterval(function()  
    oilVals[1].y = math.max(0,399-(3.24*13+(((car.oilTemperature-80)*100)/80)))
    for i = 1, 299,2 do
        oilVals[i+1].y=oilVals[i].y
        if i==1 then
            oilVals[i].y=oilVals[#oilVals].y
        else
            oilVals[i].y=oilVals[i-1].y
        end
    end
end
,0.1)

function drawOilTempGraph()
    local starterTemp = 150
    
    display.rect {pos = vec2(120,50),size = vec2(2, 350),color = colours["white"]}
    display.rect {pos = vec2(120,400),size = vec2(350, 2),color = colours["white"]}
    for i=0, 3 do 
        display.rect {pos = vec2(120+(116*i),50),size = vec2(2, 350),color = colours["dimwhite"]}
        display.rect {pos = vec2(120+(115*i),405),size = vec2(5, 20),color = colours["white"]}
    end

    display.text{pos = vec2(441, 425), letter = vec2(40,35), spacing = -17,text="0", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(317, 425), letter = vec2(40,35), spacing = -17,text="10", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(200, 425), letter = vec2(40,35), spacing = -17,text="20", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(87, 425), letter = vec2(40,35), spacing = -17,text="30", font = "Microsquare", color= colours["white"]}

    for i=0, 8 do
        display.text{width=90,alignment=1,pos = vec2(20,58+(40.5*i)), letter = vec2(40,35), spacing = -17,text=starterTemp, font = "Microsquare", color= colours["white"]}
        starterTemp = starterTemp - 10
        display.rect {pos = vec2(108,73+(40.5*i)),size = vec2(10, 5),color = colours["white"]}
    end

    for i = 0, 8 do
        display.rect {pos = vec2(120,75+(40.5*i)),size = vec2(350, 2),color = colours["dimwhite"]}   
    end
    
    for i = 0, 7 do
        display.rect {pos = vec2(112,95.25+(40.5*i)),size = vec2(6, 3),color = colours["white"]}
    end

    for i = 3, 300 do
        ui.drawLine(oilVals[i-1], oilVals[i], colours["green"],1)
    end 
end

setInterval(function()  
    exhVals[1].y = math.max(0,399-0.324*car.exhaustTemperature)
    for i = 1, 299,2 do
        exhVals[i+1].y=exhVals[i].y
        if i==1 then
            exhVals[i].y=exhVals[#exhVals].y
        else
            exhVals[i].y=exhVals[i-1].y
        end
    end
end
,0.1)

function drawExhGraph()
    local basey = 57
    local starterTemp = 1000
    display.rect {pos = vec2(120,50),size = vec2(2, 350),color = colours["white"]}
    display.rect {pos = vec2(120,400),size = vec2(350, 2),color = colours["white"]}
    for i=0, 3 do 
        display.rect {pos = vec2(120+(116*i),50),size = vec2(2, 350),color = colours["dimwhite"]}
        display.rect {pos = vec2(120+(115*i),405),size = vec2(5, 20),color = colours["white"]}
    end

    display.text{pos = vec2(441, 425), letter = vec2(40,35), spacing = -17,text="0", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(317, 425), letter = vec2(40,35), spacing = -17,text="10", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(200, 425), letter = vec2(40,35), spacing = -17,text="20", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(87, 425), letter = vec2(40,35), spacing = -17,text="30", font = "Microsquare", color= colours["white"]}

    for i=0,10 do
        display.text{width=120,alignment=1,pos = vec2(-10,basey+(33*i)), letter = vec2(35,30), spacing = -17,text=starterTemp, font = "Microsquare", color= colours["white"]}
        basey = basey
        starterTemp = starterTemp -100
    end

    for i = 0, 10 do
        display.rect {pos = vec2(108,73+(32.5*i)),size = vec2(10, 5),color = colours["white"]}
        display.rect {pos = vec2(120,75+(32.5*i)),size = vec2(350, 2),color = colours["dimwhite"]}   
    end
    
    for i = 0, 9 do
        display.rect {pos = vec2(112,90+(32.5*i)),size = vec2(6, 3),color = colours["white"]}
    end

    for i = 3, 300 do
        ui.drawLine(exhVals[i-1], exhVals[i], colours["green"],1)
    end 
end

setInterval(function()  
    intVals[1].y = math.max(0,399-3.24*car.exhaustTemperature/10)
    for i = 1, 299,2 do
        intVals[i+1].y=intVals[i].y
        if i==1 then
            intVals[i].y=intVals[#intVals].y
        else
            intVals[i].y=intVals[i-1].y
        end
    end
end
,0.1)

function drawIntGraph()
    local basey = 57
    local starterTemp = 100
    display.rect {pos = vec2(120,50),size = vec2(2, 350),color = colours["white"]}
    display.rect {pos = vec2(120,400),size = vec2(350, 2),color = colours["white"]}
    for i=0, 3 do 
        display.rect {pos = vec2(120+(116*i),50),size = vec2(2, 350),color = colours["dimwhite"]}
        display.rect {pos = vec2(120+(115*i),405),size = vec2(5, 20),color = colours["white"]}
    end

    display.text{pos = vec2(441, 425), letter = vec2(40,35), spacing = -17,text="0", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(317, 425), letter = vec2(40,35), spacing = -17,text="10", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(200, 425), letter = vec2(40,35), spacing = -17,text="20", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(87, 425), letter = vec2(40,35), spacing = -17,text="30", font = "Microsquare", color= colours["white"]}

    for i=0,10 do
        display.text{width=120,alignment=1,pos = vec2(-10,basey+(33*i)), letter = vec2(35,30), spacing = -17,text=starterTemp, font = "Microsquare", color= colours["white"]}
        basey = basey
        starterTemp = starterTemp - 10
    end

    for i = 0, 10 do
        display.rect {pos = vec2(108,73+(32.5*i)),size = vec2(10, 5),color = colours["white"]}
        display.rect {pos = vec2(120,75+(32.5*i)),size = vec2(350, 2),color = colours["dimwhite"]}   
    end
    
    for i = 0, 9 do
        display.rect {pos = vec2(112,90+(32.5*i)),size = vec2(6, 3),color = colours["white"]}
    end

    for i = 3, 300 do
        ui.drawLine(intVals[i-1], intVals[i], colours["green"],1)
    end 
end

function drawSelectMenu()
    display.text{pos = vec2(40, 5), letter = vec2(65,45), spacing = -32,text="SELECT", font = "Microsquare", color= colours["white"]}
    ui.drawRect(vec2(-170+(220*1),-121+(1*215)),vec2(8+(220*1),49+(1*215)),colours["yellow"],10,15,15)

    if btnDown() or btnUp() or btnRight() or btnLeft() then    
        for j=1,2 do
            
            for i=1,4 do  
                if selectedMode3[j][i] == 1 then
                    if btnDown() then
                        if j == 1 then
                            selectedMode3[j+1][i] = 1
                        else
                            selectedMode3[j-1][i] = 1
                        end
                          
                    elseif btnUp() then
                        if j == 1 then
                            selectedMode3[j+1][i] = 1
                        else
                            selectedMode3[j-1][i] = 1
                        end
                          
                        
                    elseif btnRight() then
                        if i == 4 then
                            selectedMode3[j][1] = 1
                        else
                            selectedMode3[j][i+1] = 1
                        end
                          
                    elseif btnLeft() then
                        if i == 1 then
                            selectedMode3[j][4] = 1
                        else
                            selectedMode3[j][i-1] = 1
                        end
                               
                    end
                    selectedMode3[j][i] = 0
                    goto continue
                end
            end
        end
    end

    ::continue::
    
    for i=1,4 do
        for j=1,2 do
            if selectedMode3[j][i] == 1 then
                ui.drawRect(vec2(-170+(220*i),-121+(j*215)),vec2(8+(220*i),49+(j*215)),colours["yellow"],10,15,15)
            elseif selectedMode3[j][i] == 0 then
                ui.drawRect(vec2(-170+(220*i),-121+(j*215)),vec2(8+(220*i),49+(j*215)),colours["darkblue"],10,15,20)
            end
            display.image{image ="MFD.png",pos = vec2(-170+(220*i),-125+(j*215)),size = vec2(185,175),color = colours["white"], uvStart = vec2(1356/1536,0/1210),uvEnd = vec2(1540/1536, 179/1210)}       
        end
    end


    if btnMid() then
        for i=1,4 do
            for j=1,2 do
                if selectedMode3[j][i] == 1 then
                    currentActive = activeMode3[j][i]
                    isSelectActive = false
                end
            end
        end
    end

    display.text{pos = vec2(55+(220*0),50+(0*215)), letter = vec2(55,40), spacing = -27,text="BOOST", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(40+(220*1),50+(0*215)), letter = vec2(50,40), spacing = -27,text="OIL-TEMP", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(35+(220*2),50+(0*215)), letter = vec2(50,40), spacing = -27,text="F-TORQUE", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(70+(220*3),50+(0*215)), letter = vec2(55,40), spacing = -27,text="VOLT", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(30+(220*0),50+(1*215)), letter = vec2(50,40), spacing = -27,text="THROTTLE", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(30+(220*1),50+(1*215)), letter = vec2(50,40), spacing = -27,text="INJECTOR", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(35+(220*2),50+(1*215)), letter = vec2(50,40), spacing = -27,text="EXH-TEMP", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(30+(220*3),50+(1*215)), letter = vec2(50,40), spacing = -27,text="INT-TEMP", font = "Microsquare", color= colours["white"]}
    
    display.image{image ="MFD.png",pos = vec2(100,150),size = vec2(85,70),color = colours["white"], uvStart = vec2(1416/1536,282/1210),uvEnd = vec2(1530/1536, 374/1210)} --turbo icon
    display.image{image ="MFD.png",pos = vec2(320,145),size = vec2(85,70),color = colours["white"], uvStart = vec2(1416/1536,370/1210),uvEnd = vec2(1530/1536, 462/1210)} -- oil icon
    display.image{image ="MFD.png",pos = vec2(538,140),size=vec2(85,70),color = colours["white"], uvStart = vec2(1416/1536,450/1210),uvEnd = vec2(1530/1536, 542/1210)} -- torque icon
    display.image{image ="MFD.png",pos = vec2(753,142),size=vec2(90,70),color = colours["white"], uvStart = vec2(1416/1536,550/1210),uvEnd = vec2(1530/1536, 642/1210)} -- battery icon
    display.image{image ="MFD.png",pos = vec2(95,360),size = vec2(85,70),color = colours["white"], uvStart = vec2(1416/1536,650/1210),uvEnd = vec2(1530/1536, 742/1210)} -- throttle icon
    display.image{image ="MFD.png",pos = vec2(316,360),size = vec2(85,70),color = colours["white"], uvStart = vec2(1416/1536,750/1210),uvEnd = vec2(1530/1536, 842/1210)} -- injector icon
    display.image{image ="MFD.png",pos = vec2(540,365),size = vec2(85,70),color = colours["white"], uvStart = vec2(1416/1536,850/1210),uvEnd = vec2(1530/1536, 940/1210)} -- exhaust icon
    display.image{image ="MFD.png",pos = vec2(752,355),size = vec2(85,70),color = colours["white"], uvStart = vec2(1416/1536,932/1210),uvEnd = vec2(1530/1536, 1024/1210)} -- int icon
    
end

function drawGraph()
    if currentActive == "BOOST" then
        drawTurboGauge(rightPivot,rightPos,rightOffset)
        drawTurboGraph()
    elseif currentActive == "F-TORQUE" then
        drawFTorqueGauge(rightPivot,rightPos,rightOffset)
        drawFTorqueGraph()
    elseif currentActive == "THROTTLE" then
        drawThrottleGauge(rightPivot,rightPos,rightOffset)
        drawThrottleGraph()
    elseif currentActive == "INJECTOR" then
        drawInjectorGauge(rightPivot,rightPos,rightOffset)
        drawIDCGraph()
    elseif currentActive == "VOLT" then
        drawVoltGauge(rightPivot,rightPos, rightOffset)
        drawVoltGraph()
    elseif currentActive == "OIL-TEMP" then 
        drawOilTempGauge(rightPivot,rightPos, rightOffset)
        drawOilTempGraph()
    elseif currentActive == "EXH-TEMP" then 
        drawExhGauge(rightPivot,rightPos, rightOffset)
        drawExhGraph()
    elseif currentActive == "INT-TEMP" then 
        drawIntGauge(rightPivot,rightPos, rightOffset)
        drawIntGraph()
    end
end

function handleBootupSequence()
    if not string.find(ac.getCarID(-1), "asc_") then
        os.showMessage("hi kai")
    end
end

function drawMenuMode()
    display.text{pos = vec2(50, 5), letter = vec2(60,60), spacing = -15,text="MENU", font = "MFDArial", color= colours["white"]}
    display.text{pos = vec2(55, 50), letter = vec2(40,60), spacing = -15,text="SELECT", font = "MFDArialItallic", color= colours["white"]}
    display.text{pos = vec2(268, 50), letter = vec2(36,60), spacing = -12,text="RED", font = "MFDArialItallic", color= colours["white"]}
    display.text{pos = vec2(349, 50), letter = vec2(36,60), spacing = -12,text="ZONE", font = "MFDArialItallic", color= colours["white"]}
    display.text{pos = vec2(482, 50), letter = vec2(38,60), spacing = -14.5,text="SHIFT", font = "MFDArialItallic", color= colours["white"]}
    display.text{pos = vec2(610, 50), letter = vec2(38,60), spacing = -15,text="UP", font = "MFDArialItallic", color= colours["white"]}

    if btnRight() or btnLeft() then    
        for i=1,3 do
            if menuOptions[i] == 1 then
                if btnRight() then
                    if i == 3 then
                        menuOptions[1] = 1
                    else
                        menuOptions[i+1]=1
                    end
                elseif btnLeft() then
                    if i == 1 then
                        menuOptions[3] = 1
                    else 
                        menuOptions[i-1]=1
                    end 
                end
                menuOptions[i] = 0
                goto continue            
            end
        end
    end
    ::continue::

    for i=1,3 do

        if menuOptions[i] == 1 then
            ui.drawRect(vec2(-170+(220*i),-121+215),vec2(8+(220*i),49+215),colours["yellow"],10,15,15)
        elseif menuOptions[i] == 0 then
            ui.drawRect(vec2(-170+(220*i),-121+215),vec2(8+(220*i),49+215),colours["none"],10,15,20)        
        end

        display.image{image ="MFD.png",pos = vec2(-173+(220*i),-121.5+215),size = vec2(185,175),color = colours["white"], uvStart = vec2((600+185*(i-1))/1536,1025/1210),uvEnd = vec2((785+185*(i-1))/1536, 1210/1210)}
    
    end

    if btnMid() then
        saveLastMenuState()
        if menuOptions[1] == 1 then
            currentActiveMenu = activeMenu[1]
            isSelectActive = true
        elseif menuOptions[2] == 1 then
            currentActiveMenu = activeMenu[2]
            isRedActive = true
        elseif menuOptions[3] == 1 then
            currentActiveMenu = activeMenu[3]
            isShiftActive = true
        end
        isMenuActive = false
        
    end
end

function drawMenu1Mode()

    display.text{pos = vec2(50, 5), letter = vec2(60,60), spacing = -15,text="MENU", font = "MFDArial", color= colours["white"]}
    display.text{pos = vec2(55, 50), letter = vec2(40,60), spacing = -15,text="SELECT", font = "MFDArialItallic", color= colours["white"]}
    display.text{pos = vec2(268, 50), letter = vec2(36,60), spacing = -12,text="RED", font = "MFDArialItallic", color= colours["white"]}
    display.text{pos = vec2(349, 50), letter = vec2(36,60), spacing = -12,text="ZONE", font = "MFDArialItallic", color= colours["white"]}
    display.text{pos = vec2(482, 50), letter = vec2(38,60), spacing = -14.5,text="SHIFT", font = "MFDArialItallic", color= colours["white"]}
    display.text{pos = vec2(610, 50), letter = vec2(38,60), spacing = -15,text="UP", font = "MFDArialItallic", color= colours["white"]}

    if btnRight() or btnLeft() then    
        for i=2,3 do
            if menu1Options[i] == 1 then
                if btnRight() then
                    if i == 3 then
                        menu1Options[2] = 1
                    else
                        menu1Options[i+1]=1
                    end
                elseif btnLeft() then
                    if i == 2 then
                        menu1Options[3] = 1
                    else 
                        menu1Options[i-1]=1
                    end 
                end
                menu1Options[i] = 0
                goto continue            
            end
        end
    end
    ::continue::

    for i=1,3 do

        if menu1Options[i] == 1 then
            ui.drawRect(vec2(-170+(220*i),-121+215),vec2(8+(220*i),49+215),colours["yellow"],10,15,15)
        elseif menu1Options[i] == 0 then
            ui.drawRect(vec2(-170+(220*i),-121+215),vec2(8+(220*i),49+215),colours["none"],10,15,20)        
        end
        if i==1 then
            display.image{image ="MFD.png",pos = vec2(-173+(220*i),-121.5+215),size = vec2(185,175),color = colours["white"], uvStart = vec2((600+185*(i-2))/1536,1025/1210),uvEnd = vec2((785+185*(i-2))/1536, 1210/1210)}
        else
            display.image{image ="MFD.png",pos = vec2(-173+(220*i),-121.5+215),size = vec2(185,175),color = colours["white"], uvStart = vec2((600+185*(i-1))/1536,1025/1210),uvEnd = vec2((785+185*(i-1))/1536, 1210/1210)}
        end
    
    end

    if btnMid() then
        saveLastMenuState()
        if menu1Options[2] == 1 then
            currentActiveMenu = activeMenu[2]
            isRedActive = true
        elseif menu1Options[3] == 1 then
            currentActiveMenu = activeMenu[3]
            isShiftActive = true    
        end
        isMenuActive = false     
        
    end
end

function drawShiftMenu()
    display.text{pos = vec2(50,0), letter = vec2(60,60), spacing = -20,text="SHIFT UP", font = "MFDArial", color= colours["white"]}
    display.image{image ="MFD.png",pos = vec2(320,85),size = vec2(350,350),color = colours["white"], uvStart = vec2(896/1536,151/1210),uvEnd = vec2(1266/1536, 521/1210)}
    display.image{image ="MFD.png",pos = vec2(820,160),size = vec2(80,270),color = colours["white"], uvStart = vec2(1295/1536,250/1210),uvEnd = vec2(1375/1536, 520/1210)}

    display.text{pos = vec2(460, 425), letter = vec2(50,45), spacing = -17,text="5", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(300, 330), letter = vec2(50,45), spacing = -17,text="6", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(280, 180), letter = vec2(50,45), spacing = -17,text="7", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(400, 50), letter = vec2(50,45), spacing = -17,text="8", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(585, 65), letter = vec2(50,45), spacing = -17,text="9", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(660, 215), letter = vec2(50,45), spacing = -17,text="10", font = "Microsquare", color= colours["white"]}

    display.text{pos = vec2(825,120), letter = vec2(40,40), spacing = -10,text="up", font = "MFDArial", color= colours["white"]}
    display.text{pos = vec2(790,430), letter = vec2(40,40), spacing = -10,text="down", font = "MFDArial", color= colours["white"]}
    display.text{pos = vec2(185,400), letter = vec2(30,40), spacing = -10,text="x1000", font = "c7_mid", color= colours["white"]}
    display.text{pos = vec2(185,430), letter = vec2(30,40), spacing = -10,text="r min", font = "c7_mid", color= colours["white"]}
    display.text{pos = vec2(200,430), letter = vec2(30,40), spacing = -10,text="/", font = "c7_mid", color= colours["white"]}
    display.text{pos = vec2(164,413), letter = vec2(20,40), spacing = 12,text="[   ]", font = "c7_mid", color= colours["white"]}
    local shiftPercentage = currentShiftTreshold*20 -- conversion to %
  
    if btnUp() then
        if currentShiftTreshold<5 then
            currentShiftTreshold = currentShiftTreshold+1
        end
    elseif btnDown() then
        if currentShiftTreshold>0 then
            currentShiftTreshold = currentShiftTreshold-1
        end
    elseif btnMid() then
        isShiftActive = false
        shiftTreshold = tresholds[currentShiftTreshold+1]
    elseif btnMenu() then -- if menu button was pressed, return to selection menu
        isShiftActive = false
        isMenuActive = true
    end
    
    if currentShiftTreshold ~= 0 then
        for i = 0, 65 do
            local thisRotation = (-shiftPercentage) * 2.697 -- "-" turns rotation counter clockwise
            ui.beginRotation()
            ui.beginRotation()

            display.rect {
                -- draws rectangle
                pos = vec2(462,265),
                size = vec2(10, 138),
                color = colours["green"]
            }

            ui.endRotation(-10,vec2(-50,0))
            if shiftPercentage > (100 /65 * i) then
                thisRotation = -(100 /65 * i) * 2.697
            end
            
            ui.endPivotRotation(thisRotation+10, vec2(330,321),vec2(156,-68))

        end
    else
        display.rect {
            pos = vec2(489,265),
            size = vec2(3, 138),
            color = colours["green"]
        }
    end


    display.image{image ="MFD.png",pos = vec2(320,85),size = vec2(350,350),color = colours["white"], uvStart = vec2(896/1536,151/1210),uvEnd = vec2(1266/1536, 521/1210)}
    display.image{image ="MFD.png",pos = vec2(820,160),size = vec2(80,270),color = colours["white"], uvStart = vec2(1295/1536,250/1210),uvEnd = vec2(1375/1536, 520/1210)}

end

function drawRedMenu()
    local redText = {"BOOST", "INJECTOR", "OIL-TEMP", "W-TEMP", "EXH-TEMP"}
    
    basex=165
    basey=80

    display.text{pos = vec2(40,10), letter = vec2(60,60), spacing = -20,text="RED ZONE", font = "MFDArial", color= colours["white"]}

    if btnUp() or btnDown() or btnLeft() or btnRight() then
        for i=1,7 do
            if activeRed[i]==true then
                if btnUp() then
                    if i==1 then
                        activeRed[6] = true
                    else
                        activeRed[i-1] = true
                    end

                elseif btnDown() then
                    if i == 6 then  
                        activeRed[1] = true

                    elseif i == 7 then
                        goto continue --if we're hovering over the reset button do nothing
                    else
                        activeRed[i+1] = true 
                    end

                elseif btnRight() or btnLeft() then
                    if i == 6 then
                        activeRed[i+1] = true
                    elseif i == 7 then
                        activeRed[i-1] = true
                    else
                        goto continue --do nothing
                    end
                end
                activeRed[i] = false
                goto continue
            end

        end

    end
    ::continue::
    
    for i = 0, 4 do --drawing the outlines of every bar...
        local currentColor = colours["white"]
        if activeRed[i+1] then
            ui.drawRect(vec2(basex-120,basey+2),vec2(basex+185,basey+52),colours["yellow"],5,15,15)
            currentColor = colours["yellow"]
        end
        display.image{image ="MFD.png",pos = vec2(basex-127,basey-5.5),size = vec2(345,65),color = colours["white"], uvStart = vec2(985/1536,0/1210),uvEnd = vec2(1356/1536, 71/1210)}
        drawMenuBars(basex-15,basey,995,55,true)
        
        display.text{pos = vec2(basex-113,basey+9), letter = vec2(34,35), spacing = -13,text=redText[i+1], font = "Microsquare", color= colours["black"]}
        display.text{pos = vec2(basex-115,basey+7), letter = vec2(34,35), spacing = -13,text=redText[i+1], font = "Microsquare", color= currentColor}
        basey=basey+65
        
    end
     
    if activeRed[6] then
        ui.drawRect(vec2(basex-120,basey-2),vec2(basex+16,basey+50),colours["yellow"],5,15,15)
        display.image{image ="MFD.png",pos = vec2(basex-127,basey-8),size = vec2(145,65),color = colours["white"], uvStart = vec2(985/1536,76/1210),uvEnd = vec2(1144/1536, 146/1210)}
        display.text{pos = vec2(basex-105,basey+2), letter = vec2(45,43), spacing = -16,text="END", font = "Microsquare", color= colours["black"]}
        display.text{pos = vec2(basex-108,basey-1), letter = vec2(45,43), spacing = -16,text="END", font = "Microsquare", color= colours["yellow"]}
        
    else
        display.image{image ="MFD.png",pos = vec2(basex-127,basey-8),size = vec2(145,65),color = colours["white"], uvStart = vec2(985/1536,76/1210),uvEnd = vec2(1144/1536, 146/1210)}
        display.text{pos = vec2(basex-105,basey+2), letter = vec2(45,43), spacing = -16,text="END", font = "Microsquare", color= colours["black"]}
        display.text{pos = vec2(basex-108,basey-1), letter = vec2(45,43), spacing = -16,text="END", font = "Microsquare", color= colours["white"]}
    end
    
    if activeRed[7] then
        ui.drawRect(vec2(basex+570,basey-2),vec2(basex+738,basey+50),colours["yellow"],5,15,15)
        display.image{image ="MFD.png",pos = vec2(basex+560,basey-8),size = vec2(180,65),color = colours["white"], uvStart = vec2(985/1536,76/1210),uvEnd = vec2(1144/1536, 146/1210)}
        display.text{pos = vec2(basex+579,basey+2), letter = vec2(43,43), spacing = -16,text="RESET", font = "Microsquare", color= colours["black"]}
        display.text{pos = vec2(basex+576,basey-1), letter = vec2(43,43), spacing = -16,text="RESET", font = "Microsquare", color= colours["yellow"]}
    else
        display.image{image ="MFD.png",pos = vec2(basex+560,basey-8),size = vec2(180,65),color = colours["white"], uvStart = vec2(985/1536,76/1210),uvEnd = vec2(1144/1536, 146/1210)}
        display.text{pos = vec2(basex+579,basey+2), letter = vec2(43,43), spacing = -16,text="RESET", font = "Microsquare", color= colours["black"]}
        display.text{pos = vec2(basex+576,basey-1), letter = vec2(43,43), spacing = -16,text="RESET", font = "Microsquare", color= colours["white"]}
    end

    basex = basex+95

    for i=1,5 do --figuring out which icon would be tinted yellow
        if activeRed[i] then
            redColors[i] = colours["yellow"]
        else
            redColors[i] = colours["white"]
        end
    end

    display.image{image ="MFD.png",pos = vec2(basex,83),size = vec2(80,60),color = redColors[1], uvStart = vec2(1416/1536,282/1210),uvEnd = vec2(1530/1536, 374/1210)} --turbo icon
    display.image{image ="MFD.png",pos = vec2(basex,148),size = vec2(80,55),color = redColors[2], uvStart = vec2(1416/1536,750/1210),uvEnd = vec2(1530/1536, 842/1210)} -- injector icon
    display.image{image ="MFD.png",pos = vec2(basex,216),size = vec2(85,55),color = redColors[3], uvStart = vec2(1416/1536,380/1210),uvEnd = vec2(1530/1536, 462/1210)} -- oil icon
    display.image{image ="MFD.png",pos = vec2(basex,276),size = vec2(80,60),color = redColors[4], uvStart = vec2(1416/1536,190/1210),uvEnd = vec2(1530/1536, 282/1210)} --water icon
    display.image{image ="MFD.png",pos = vec2(basex,345),size = vec2(90,60),color = redColors[5], uvStart = vec2(1416/1536,850/1210),uvEnd = vec2(1530/1536, 940/1210)} -- exhaust icon
    
    if btnLeft() or btnRight() then
        for i=1,5 do
            
            if i == 1 and activeRed[1] then --hacky but it works
                if btnRight() and tresholdValues[1] < 1.2 then
                    tresholdValues[1] = tresholdValues[1] + 0.2
                elseif btnLeft() and tresholdValues[1] > -0.6 then
                    tresholdValues[1] = tresholdValues[1] - 0.2
                end
            elseif i == 2 and activeRed[2] then
                if btnRight() and tresholdValues[2] < 100 then
                    tresholdValues[2] = tresholdValues[2] + 5
                elseif btnLeft() and tresholdValues[2] > 0 then
                    tresholdValues[2] = tresholdValues[2] - 5
                end
            elseif i == 3 and activeRed[3] then
                if btnRight() and tresholdValues[3] < 150 then
                    tresholdValues[3] = tresholdValues[3] + 5
                elseif btnLeft() and tresholdValues[3] > 0 then
                    tresholdValues[3] = tresholdValues[3] - 5
                end
            elseif i == 4 and activeRed[4] then
                if btnRight() and tresholdValues[4] < 150 then
                    tresholdValues[4] = tresholdValues[4] + 5
                elseif btnLeft() and tresholdValues[4] > 0 then
                    tresholdValues[4] = tresholdValues[4] - 5
                end
            elseif i == 5 and activeRed[5] then
                if btnRight() and tresholdValues[5] < 1000 then
                    tresholdValues[5] = tresholdValues[5] + 25
                elseif btnLeft() and tresholdValues[5] > 0 then
                    tresholdValues[5] = tresholdValues[5] - 25
                end
            end
        end
    end
    
    display.text{width=205,pos = vec2(605, 90),alignment=1, letter = vec2(40, 35), spacing = -18,text=string.format("%.2f", tresholdValues[1]), font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(845, 85), letter = vec2(30, 50), spacing = -10,text="kPa", font = "c7_mid", color= colours["white"]}
    display.text{pos = vec2(802, 85), letter = vec2(15, 30), spacing = -3,text="x100", font = "c7_mid", color= colours["white"]}

    displayPercentageCustomInput(tresholdValues[2],155)
    displayCelsiusCustomInput(tresholdValues[4], 280)
    displayCelsiusCustomInput(tresholdValues[3], 215)
    displayCelsiusCustomInput(tresholdValues[5], 345)

    boostRect = ((tresholdValues[1]+0.6)*10/1.8)*29
    ui.drawRectFilled(vec2(basex+110+boostRect,85),vec2(basex+110+boostRect+5,130),colours["red"])

    injectorRect = tresholdValues[2] *2.9 
    ui.drawRectFilled(vec2(basex+110+injectorRect,150),vec2(basex+110+injectorRect+5,195),colours["red"])

    oilTRect = (tresholdValues[3]/1.5)*2.9
    ui.drawRectFilled(vec2(basex+110+oilTRect,215),vec2(basex+110+oilTRect+5,260),colours["red"])

    waterTRect = (tresholdValues[4]/1.5)*2.9
    ui.drawRectFilled(vec2(basex+110+waterTRect,280),vec2(basex+110+waterTRect+5,325),colours["red"])

    exhTRect =  tresholdValues[5]*0.29
    ui.drawRectFilled(vec2(basex+110+exhTRect,345),vec2(basex+110+exhTRect+5,390),colours["red"])

    if btnMid() then
        if activeRed[6] then
            isRedActive=false
        elseif activeRed[7] then --reset
            tresholdValues[1] = 1
            tresholdValues[2] = 75
            tresholdValues[3] = 120
            tresholdValues[4] = 120
            tresholdValues[5] = 875
        end
    end

    if btnMenu() then -- if menu button was pressed, return to selection menu
        isRedActive = false
        isMenuActive = true
    end

end

function drawDisplayMenu()
    display.rect{pos= vec2(600,0), size= vec2(940,490), color= colours["darkblue"]}
    display.rect{pos= vec2(0,0), size= vec2(350,100), color= colours["darkblue"]}
    display.text{pos = vec2(50,25), letter = vec2(60,60), spacing = -22,text="DISPLAY", font = "MFDArial", color= colours["white"]}


    if btnMid() or btnUp() or btnDown() then
        
            for i=1,4 do
                if activeDisplay[i] == true then
                    if btnUp() then
                        if i==1 then
                            activeDisplay[4]=true
                        else
                            activeDisplay[i-1]=true
                        end
                    elseif btnDown() then
                        if i==4 then
                            activeDisplay[1]=true
                        else
                            activeDisplay[i+1]=true
                        end
                    elseif btnMid() then
                        if i == 1 then
                            autoDimming = not autoDimming
                            goto continue
                        elseif i==2 then
                            isScreenOn = not isScreenOn
                            goto continue
                        elseif i==3 then
                            gaugeTail = not gaugeTail
                            goto continue
                        elseif i==4 then
                            brightnessAdjustment = not brightnessAdjustment
                            goto continue
                        end
                    end
                activeDisplay[i]=false
                goto continue
                end
            end

    end
    ::continue::

    for i = 0,3 do
        if activeDisplay[i+1] then
            ui.drawRect(vec2(630,105+90*i),vec2(910,180+90*i),colours["yellow"],10,15,15)
        end
        display.image{image ="MFD.png",pos = vec2(620,100+90*i),size = vec2(290,85),color = colours["white"], uvStart = vec2(985/1536,76/1210),uvEnd = vec2(1144/1536, 146/1210)}
    end

    if autoDimming then
        display.image{image ="MFD.png",pos = vec2(615,116),size = vec2(340,45),color = colours["white"], uvStart = vec2(0/1536,1101/1210),uvEnd = vec2(233/1536, 1141/1210)}
    else
        display.image{image ="MFD.png",pos = vec2(615,116),size = vec2(340,45),color = colours["white"], uvStart = vec2(0/1536,1059/1210),uvEnd = vec2(233/1536, 1099/1210)}

    end

    display.image{image ="MFD.png",pos = vec2(678,204),size = vec2(200,55),color = colours["white"], uvStart = vec2(230/1536,1086/1210),uvEnd = vec2(355/1536, 1125/1210)}
    
    if gaugeTail then
        display.image{image ="MFD.png",pos = vec2(643,298.7),size = vec2(245,46),color = colours["white"], uvStart = vec2(230/1536,1127/1210),uvEnd = vec2(380/1536, 1169/1210)}
    else
        display.image{image ="MFD.png",pos = vec2(643,297.7),size = vec2(245,47),color = colours["white"], uvStart = vec2(230/1536,1167/1210),uvEnd = vec2(380/1536, 1210/1210)}
    end

    display.image{image ="MFD.png",pos = vec2(646,383),size = vec2(290,55),color = colours["white"], uvStart = vec2(0/1536,1150/1210),uvEnd = vec2(233/1536, 1200/1210)}

    local basecoordx = 220
    local basecoordy = 379
    local basesizey = 67
    local basesize = 200

    if brightnessAdjustment then
        display.rect{pos= vec2(basecoordx,basecoordy), size= vec2(basesize*2,basesizey), color= colours["lightgrey"]}
        display.rect{pos= vec2(basecoordx+3,basecoordy+3), size= vec2((basesize*2)-6,basesizey-6), color= colours["darkblue"]}  
        display.rect{pos= vec2(basecoordx+95,basecoordy), size= vec2(basesize+15,basesizey), color= colours["lightgrey"]}
        display.rect{pos= vec2(basecoordx+98,basecoordy+3), size= vec2((basesize+15)-6,basesizey-6), color= colours["darkblue"]}


        if (btnLeft() or btnRight()) and not autoDimming then    
                    if btnRight() and screenBrightness < 0.5 then
                        screenBrightness = screenBrightness + 0.1
                    elseif btnLeft() and screenBrightness > 0.1 then
                        screenBrightness = screenBrightness - 0.1
                    end
        end

        local brightnessRect = screenBrightness * (basesize+214)
        ui.drawRectFilled(vec2(basecoordx+97+brightnessRect,basecoordy+3),vec2(basecoordx+97+brightnessRect+3,basecoordy+basesizey-3),colours["green"])
        display.image{image ="MFD.png",pos = vec2(226,362),size = vec2(80,80),color = colours["white"], uvStart = vec2(230/1536,1036/1210),uvEnd = vec2(265/1536, 1085/1210)}
        display.image{image ="MFD.png",pos = vec2(538,362),size = vec2(80,80),color = colours["white"], uvStart = vec2(290/1536,1036/1210),uvEnd = vec2(325/1536, 1085/1210)}
    end
end

function drawTwinIcons()
    for i=1,4 do
        for j=1,2 do
            if currentTwin[i][j] == "BOOST" then
                display.image{image ="MFD.png",pos = twinCoords[i][j],size = vec2(80,70),color = colours["white"], uvStart = vec2(1416/1536,282/1210),uvEnd = vec2(1530/1536, 374/1210)} --turbo icon
            elseif currentTwin[i][j] == "OIL-TEMP" then
                display.image{image ="MFD.png",pos = twinCoords[i][j],size = vec2(80,70),color = colours["white"], uvStart = vec2(1410/1536,375/1210),uvEnd = vec2(1520/1536, 465/1210)} -- oil icon
            elseif currentTwin[i][j] == "THROTTLE" then
                display.image{image ="MFD.png",pos = twinCoords[i][j],size = vec2(80,70),color = colours["white"], uvStart = vec2(1416/1536,655/1210),uvEnd = vec2(1530/1536, 750/1210)} -- throttle icon
            elseif currentTwin[i][j] == "INJECTOR" then
                display.image{image ="MFD.png",pos = twinCoords[i][j],size = vec2(80,70),color = colours["white"], uvStart = vec2(1416/1536,750/1210),uvEnd = vec2(1530/1536, 842/1210)} -- injector icon
            elseif currentTwin[i][j] == "VOLT" then
                display.image{image ="MFD.png",pos = twinCoords[i][j],size = vec2(80,70),color = colours["white"], uvStart = vec2(1425/1536,560/1210),uvEnd = vec2(1535/1536, 645/1210)} -- volt icon
            elseif currentTwin[i][j] == "F-TORQUE" then
                display.image{image ="MFD.png",pos = twinCoords[i][j],size = vec2(80,70),color = colours["white"], uvStart = vec2(1410/1536,460/1210),uvEnd = vec2(1525/1536, 550/1210)} -- torque icon
            end
        end
    end
end

function drawTwinIcon(icon,pos)
    local iconPos

    if pos == "LEFT" then
        iconPos = vec2(72,52)
    elseif pos == "RIGHT" then
        iconPos = vec2(391,52)
    end

    if icon == "BOOST" then
        display.image{image ="MFD.png",pos = iconPos,size = vec2(80,70),color = colours["white"], uvStart = vec2(1416/1536,282/1210),uvEnd = vec2(1530/1536, 374/1210)} --turbo icon
    elseif icon == "OIL-TEMP" then
        display.image{image ="MFD.png",pos = iconPos,size = vec2(80,70),color = colours["white"], uvStart = vec2(1410/1536,375/1210),uvEnd = vec2(1520/1536, 465/1210)} -- oil icon
    elseif icon == "THROTTLE" then
        display.image{image ="MFD.png",pos = iconPos,size = vec2(80,70),color = colours["white"], uvStart = vec2(1416/1536,655/1210),uvEnd = vec2(1530/1536, 750/1210)} -- throttle icon
    elseif icon == "INJECTOR" then
        display.image{image ="MFD.png",pos = iconPos,size = vec2(80,70),color = colours["white"], uvStart = vec2(1416/1536,750/1210),uvEnd = vec2(1530/1536, 842/1210)} -- injector icon
    elseif icon == "VOLT" then
        display.image{image ="MFD.png",pos = iconPos,size = vec2(80,70),color = colours["white"], uvStart = vec2(1425/1536,560/1210),uvEnd = vec2(1535/1536, 645/1210)} -- volt icon
    elseif icon == "F-TORQUE" then
        display.image{image ="MFD.png",pos = iconPos,size = vec2(80,70),color = colours["white"], uvStart = vec2(1410/1536,460/1210),uvEnd = vec2(1525/1536, 550/1210)} -- torque icon
    end
    
end

setInterval(function()  --blinking green twin menu color
    if isSelectingGauges or isSelectingSide then
        if colorMode then
            selectingColor = colours["green"]
        else     
            selectingColor = colours["none"]
        end
        colorMode = not colorMode
    else
        selectingColor = colours["none"]
    end
end
,1)

function drawTwinButtons()

    display.text{pos = vec2(170, 85), letter = vec2(40,50), spacing = -10,text="LEFT", font = "MFDArial", color= colours["white"]} --left and right text, not related to twin buttons but it's included here for cleaner code
    display.text{pos = vec2(490, 85), letter = vec2(40,50), spacing = -10,text="RIGHT", font = "MFDArial", color= colours["white"]}

    for i=1,5 do --drawing all twin buttons

        if isSelectingTwin and currentTwinSetup[i] == 1 then
            ui.drawRect(vec2(676,-20+80*i),vec2(903,44+80*i),colours["yellow"],6,15,15) --yellow outlines
        end

        if isSelectingGauges then --only grey out 4 twin buttons if we're selecting gauges
            display.image{image ="MFD.png",pos = vec2(660,-30+80*i),size = vec2(250,85),color = colours["moderateorange"], uvStart = vec2(985/1536,76/1210),uvEnd = vec2(1144/1536, 146/1210)}
        else 
            display.image{image ="MFD.png",pos = vec2(660,-30+80*i),size = vec2(250,85),color = colours["white"], uvStart = vec2(985/1536,76/1210),uvEnd = vec2(1144/1536, 146/1210)}
        end
        if i > 1 then
            display.text{pos = vec2(682,-13+80*i), letter = vec2(50,45), spacing = -17,text="TWIN", font = "Microsquare", color= colours["black"]}
            display.text{pos = vec2(837,-13+80*i), letter = vec2(50,45), spacing = -12,text=i-1, font = "Microsquare", color= colours["black"]}
            if changedTwins[i-1] == 1 then
                display.text{pos = vec2(680,-15+80*i), letter = vec2(50,45), spacing = -17,text="TWIN", font = "Microsquare", color= twinTextColor}
                display.text{pos = vec2(835,-15+80*i), letter = vec2(50,45), spacing = -12,text=i-1, font = "Microsquare", color= twinTextColor}
            else
                display.text{pos = vec2(680,-15+80*i), letter = vec2(50,45), spacing = -17,text="TWIN", font = "Microsquare", color= colours["white"]}
                display.text{pos = vec2(835,-15+80*i), letter = vec2(50,45), spacing = -12,text=i-1, font = "Microsquare", color= colours["white"]}
            end
            
        else
            display.text{pos = vec2(727,-13+80*i), letter = vec2(50,45), spacing = -17,text="END", font = "Microsquare", color= colours["black"]}
            display.text{pos = vec2(725,-15+80*i), letter = vec2(50,45), spacing = -17,text="END", font = "Microsquare", color= colours["white"]}
        end
    end
end

function drawTwinSelectButtons()
    local buttonText = {{"BOOST","OIL-TEMP"},{"F-TORQUE","VOLT"},{"INJECTOR","THROTTLE"}}

    if isSelectingGauges then --drawing the icons
        buttonColor = colours["white"]
    else
        buttonColor = colours["moderateorange"]
    end

    for i=1,3 do
        for j=1,2 do
            display.image{image ="MFD.png",pos = vec2(20+320*(j-1),-30+80*(i+1)),size = vec2(315,85),color = buttonColor, uvStart = vec2(985/1536,76/1210),uvEnd = vec2(1144/1536, 146/1210)}
            display.text{pos = vec2(47+315*(j-1),-13+80*(i+1)), letter = vec2(50,45), spacing = -17,text=buttonText[i][j], font = "Microsquare", color= colours["black"]} 
            display.text{pos = vec2(45+315*(j-1),-15+80*(i+1)), letter = vec2(50,45), spacing = -17,text=buttonText[i][j], font = "Microsquare", color= colours["white"]}
        end
    end
end

function drawTwinGreenFlashingButtons()

    if isSelectingLeft then
        ui.drawRectFilled(vec2(55,40),vec2(165,120),selectingColor,0,15) --green flashing color
    elseif isSelectingRight then
        ui.drawRectFilled(vec2(55+(320*(1)),40),vec2(165+(320*(1)),120),selectingColor,0,15)
    end

    for i=1,3 do
        for j=1,2 do  
            ui.drawRect(vec2(55+(320*(j-1)),40),vec2(165+(320*(j-1)),120),colours["white"],0,15,3) --green rectangle white outline 
        end
    end
    if currentTwinNo ~= 0 then
        drawTwinIcon(currentTwin[currentTwinNo][1], "LEFT")
        drawTwinIcon(currentTwin[currentTwinNo][2], "RIGHT")
    end

end

function drawTwinSetupMenu()
    local buttonText = {{"BOOST","OIL-TEMP"},{"F-TORQUE","VOLT"},{"INJECTOR","THROTTLE"}}
    local buttonColor = colours["moderateorange"]
    
    if isSelectingTwin and (btnDown() or btnUp() or btnMid()) then --initial end + twin buttons
        for i=1,5 do
            if currentTwinSetup[i] == 1 then
                if btnDown() then
                    if i==5 then
                        currentTwinSetup[1] = 1
                        currentTwinNo = 0
                    else
                        currentTwinSetup[i+1] = 1
                        currentTwinNo = i
                    end
                elseif btnUp() then
                    if i==1 then
                        currentTwinSetup[5] = 1
                        currentTwinNo = 4
                    elseif i==2 then
                        currentTwinSetup[i-1] = 1
                        currentTwinNo = 0
                    else
                        currentTwinSetup[i-1] = 1
                        currentTwinNo = i-2
                    end
                elseif btnMid() then
                    if i == 1 then --end button pressed
                        currentTwinNo = 1
                        currentTwinSetup = {0,1,0,0,0} --resetting the active buttons for the outline
                        changedTwins = {0,0,0,0} -- resetting changed twins
                        isTwinSetupOpen = false   
                    else
                        activeIcon[1][1]=1
                        currentTwinNo = i-1
                        changedTwins[currentTwinNo] = 1
                        twinTextColor = colours["yellow"]
                        isSelectingSide = true
                        isSelectingLeft = true
                    end
                    isSelectingTwin = false
                    goto continue
                end
                currentTwinSetup[i] = 0
                goto continue
            end
        end
    
   
    elseif isSelectingSide and (btnLeft() or btnRight() or btnMid()) then --side selection w flashing green light
        
        if (isSelectingLeft and (btnLeft() or btnRight())) then
            isSelectingLeft = false
            isSelectingRight = true
        elseif (isSelectingRight and (btnLeft() or btnRight())) then
            isSelectingLeft = true
            isSelectingRight = false
        elseif btnMid() then
            isSelectingGauges = true
            isSelectingSide = false
        end
    
    elseif isSelectingGauges and (btnLeft() or btnRight() or btnMid() or btnDown() or btnUp()) then
        twinTextColor = colours["yellow"]
        for i=1, 3 do
            for j=1,2 do
                if activeIcon[i][j] == 1 then
                    if btnUp() then
                        if i==1 then        
                            activeIcon[3][j] = 1
                        else
                            activeIcon[i-1][j] = 1
                        end
                    elseif btnDown() then
                        if i==3 then
                            activeIcon[1][j] = 1
                        else      
                            activeIcon[i+1][j] = 1
                        end
                    elseif btnLeft() then
                        if j==1 then        
                            activeIcon[i][2] = 1
                        else
                            activeIcon[i][j-1] = 1
                        end
                    elseif btnRight() then
                        if j==2 then
                            activeIcon[i][1] = 1
                        else
                            activeIcon[i][j+1] = 1
                        end
                    elseif btnMid() and isSelectingLeft then
                        isSelectingSide = true
                        isSelectingGauges = false
                        currentTwin[currentTwinNo][1] = buttonText[i][j]
                        hasSelectedLeft = true
                        activeIcon[i][j] = 0
                        activeIcon[1][1] = 1
                        --storedValues.currentTwin = storagePackNested(currentTwin)
                        goto continue 
                    elseif btnMid() and isSelectingRight then
                        isSelectingSide = true
                        isSelectingGauges = false
                        currentTwin[currentTwinNo][2] = buttonText[i][j]
                        hasSelectedRight = true
                        activeIcon[i][j] = 0
                        activeIcon[1][1] = 1
                        --storedValues.currentTwin = storagePackNested(currentTwin)
                        goto continue 
                    end
                    activeIcon[i][j] = 0
                    goto continue
                end
            end
        end
    end

    ::continue::

    if hasSelectedLeft and hasSelectedRight then --both selected, go back to twin selection
        isSelectingSide = false
        isSelectingGauges = false
        isSelectingTwin = true
        hasSelectedLeft = false
        hasSelectedRight = false
    end

    drawTwinButtons()

    drawTwinGreenFlashingButtons()

    if isSelectingGauges then --twin gauge selection outline
        for i=1,3 do
            for j=1,2 do
                if activeIcon[i][j] == 1 then
                    ui.drawRect(vec2(40+320*(j-1),-20+80*(i+1)),vec2(326+320*(j-1),44+80*(i+1)),colours["yellow"],6,15,15)
                end
            end          
        end
    end

    drawTwinSelectButtons()

end

function drawTwinMenu()
    
    display.text{pos = vec2(40, 5), letter = vec2(65,65), spacing = -20,text="SELECT", font = "MFDArial", color= colours["white"]}

    if btnDown() or btnUp() or btnRight() or btnLeft() then    
        for j=1,3 do
            for i=1,2 do  
                if twinSelection[j][i] == 1 then
                    if btnDown() then
                        if j == 3 then
                           twinSelection[j-2][i] = 1
                        else
                           twinSelection[j+1][i] = 1
                        end
                          
                    elseif btnUp() then
                        if j == 1 then
                           twinSelection[3][i] = 1
                        else
                           twinSelection[j-1][i] = 1
                        end
                          
                    elseif btnRight() then
                        if i == 2 then
                           twinSelection[j][1] = 1
                        else
                           twinSelection[j][i+1] = 1
                        end
                          
                    elseif btnLeft() then
                        if i == 1 then
                           twinSelection[j][2] = 1
                        else
                           twinSelection[j][i-1] = 1
                        end

                    end

                    twinSelection[j][i] = 0
                    goto continue
                end
            end
        end
    end

    ::continue::
    
    for i=1,2 do
        for j=1,3 do
            if twinSelection[3][i] == 1 then
                ui.drawRect(vec2(152,404),vec2(450,479),colours["yellow"],6,15,15)
            elseif twinSelection[j][i] == 1 then
                ui.drawRect(vec2(150+400*(i-1),110+160*(j-1)),vec2(450+400*(i-1),230+160*(j-1)),colours["yellow"],6,15,15)
            end
        end
    end

    drawTwinIcons()

    if btnMid() then
        for i=1,2 do
            for j=1,3 do
                if twinSelection[3][i] == 1 then
                    isTwinSetupOpen = true
                    isSelectingTwin = true
                elseif twinSelection[j][i] == 1 then
                    if j == 1 and i == 1 then --twin 1
                        currentDisplayed = currentTwin[1] 
                    elseif j == 2 and i == 1 then --twin 2
                        currentDisplayed = currentTwin[2]
                    elseif j == 1 and i == 2 then --twin 3
                        currentDisplayed = currentTwin[3]
                    elseif j == 2 and i == 2 then --twin 4
                        currentDisplayed = currentTwin[4]
                    end
                    if currentDisplayed[1] ~= "NONE" or currentDisplayed[2] ~= "NONE" then
                        isSelectActive = false
                    end
                end
            end
        end
        
    end

    if btnMenu() then -- if menu button was pressed, return to selection menu
        isSelectActive = false
        isMenuActive = true
    end

    display.text{pos = vec2(150,70), letter = vec2(50,45), spacing = -12,text="TWIN", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(150,230), letter = vec2(50,45), spacing = -12,text="TWIN", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(550,70), letter = vec2(50,45), spacing = -12,text="TWIN", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(550,230), letter = vec2(50,45), spacing = -12,text="TWIN", font = "Microsquare", color= colours["white"]}

    display.text{pos = vec2(325,70), letter = vec2(50,45), spacing = -12,text="1", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(325,230), letter = vec2(50,45), spacing = -12,text="2", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(725,70), letter = vec2(50,45), spacing = -12,text="3", font = "Microsquare", color= colours["white"]}
    display.text{pos = vec2(725,230), letter = vec2(50,45), spacing = -12,text="4", font = "Microsquare", color= colours["white"]}

    display.image{image ="MFD.png",pos = vec2(150,110),size = vec2(300,120),color = colours["white"], uvStart = vec2(1153/1536,1024/1210),uvEnd = vec2(1536/1536, 1210/1210)}
    display.image{image ="MFD.png",pos = vec2(150,270),size = vec2(300,120),color = colours["white"], uvStart = vec2(1153/1536,1024/1210),uvEnd = vec2(1536/1536, 1210/1210)}
    display.image{image ="MFD.png",pos = vec2(550,110),size = vec2(300,120),color = colours["white"], uvStart = vec2(1153/1536,1024/1210),uvEnd = vec2(1536/1536, 1210/1210)}
    display.image{image ="MFD.png",pos = vec2(550,270),size = vec2(300,120),color = colours["white"], uvStart = vec2(1153/1536,1024/1210),uvEnd = vec2(1536/1536, 1210/1210)}
    display.image{image ="MFD.png",pos = vec2(139,400),size = vec2(314,85),color = colours["white"], uvStart = vec2(985/1536,76/1210),uvEnd = vec2(1144/1536, 146/1210)}
    display.image{image ="MFD.png",pos = vec2(177,399),size = vec2(250,80),color = colours["white"], uvStart = vec2(14/1536,1020/1210),uvEnd = vec2(110/1536, 1060/1210)}
end


function drawTwins() --drawing the gauges

    if currentDisplayed[1] == "BOOST" then
        drawTurboGauge(leftPivot,leftPos,leftOffset)
    elseif currentDisplayed[1] == "OIL-TEMP" then
        drawOilTempGauge(leftPivot,leftPos, leftOffset)
    elseif currentDisplayed[1] == "F-TORQUE" then
        drawFTorqueGauge(leftPivot,leftPos,leftOffset)
    elseif currentDisplayed[1] == "VOLT" then
        drawVoltGauge(leftPivot,leftPos, leftOffset)
    elseif currentDisplayed[1] == "INJECTOR" then
        drawInjectorGauge(leftPivot,leftPos,leftOffset)
    elseif currentDisplayed[1] == "THROTTLE" then
        drawThrottleGauge(leftPivot,leftPos,leftOffset)
    end

    if currentDisplayed[2] == "BOOST" then
        drawTurboGauge(rightPivot,rightPos,rightOffset)
    elseif currentDisplayed[2] == "OIL-TEMP" then
        drawOilTempGauge(rightPivot,rightPos, rightOffset)
    elseif currentDisplayed[2] == "F-TORQUE" then
        drawFTorqueGauge(rightPivot,rightPos,rightOffset)
    elseif currentDisplayed[2] == "VOLT" then
        drawVoltGauge(rightPivot,rightPos, rightOffset)
    elseif currentDisplayed[2] == "INJECTOR" then
        drawInjectorGauge(rightPivot,rightPos,rightOffset)
    elseif currentDisplayed[2] == "THROTTLE" then
        drawThrottleGauge(rightPivot,rightPos,rightOffset)
    end
end

function modeBehaviour()
    if btnMode() and not isMenuActive and not isShiftActive and not isRedActive and not isSelectActive then --only changing mode if the menu isn't opened
        saveLastMenuState()
        modeNumber = modeNumber + 1
        if modeNumber == 4 then
            modeNumber=1
        end
    end 

    if btnMenu() and not isShiftActive and not isRedActive and not isSelectActive then --only opening and closing if the menu isn't opened
        saveLastMenuState()
        isMenuActive = not isMenuActive
    end

    

    if modeNumber == 1 then
        if isMenuActive then
            drawMenu1Mode()
        elseif isShiftActive then
            drawShiftMenu()
        elseif isRedActive then
            drawRedMenu()
        else
            drawBarMenu()
        end
    end

    if modeNumber == 2 then
        if isMenuActive then
            drawMenuMode()
        elseif isSelectActive then
            if isTwinSetupOpen then
                drawTwinSetupMenu()
            else
                drawTwinMenu()
            end
        elseif isShiftActive then
            drawShiftMenu()
        elseif isRedActive then
            drawRedMenu()    
        else
            drawTwins()
        end
    end

    if modeNumber == 3 then
        if isMenuActive then
            drawMenuMode()
        elseif isSelectActive then
            drawSelectMenu()
        elseif isRedActive then
            drawRedMenu()
        elseif isShiftActive then
            drawShiftMenu()
        else
            drawGraph()
        end
        
    end
end

function shiftLightBehaviour()
    if car.rpm >= shiftTreshold then
        ac.setExtraSwitch(4,true)
    else
        ac.setExtraSwitch(4,false)
    end
end

setInterval(function()  --switches to bar menu for 1 second if sensor limit was exceeded  
    if
    getBarColor(car.exhaustTemperature,tresholdValues[5]) == colours["red"] or 
    getBarColor(idcLevel(car.rpm),tresholdValues[2]) == colours["red"] or
    getBarColor(2*math.floor(car.turboBoost*100)/100-0.3, tresholdValues[1]) == colours["red"] or 
    getBarColor(car.oilTemperature,tresholdValues[3]) == colours["red"] or 
    getBarColor(car.waterTemperature,tresholdValues[4]) == colours["red"] or 
    getBarColor(car.exhaustTemperature,tresholdValues[5])	 == colours["red"] then  
        switchOver = true  
    else
        switchOver = false
    end
end
,1)

function detectSwitchover()
    if switchOver then
        display.rect{pos= vec2(0,0), size= vec2(940,490), color= colours["darkblue"]}
        drawBarMenu()
    end
end

function autoDimBehaviour()
    if autoDimming then
        display.rect{pos= vec2(0,0), size= vec2(940,490), color= rgbm(0,0.01,0.09,math.min(sim.timeHours/24,0.65))}      
    elseif brightnessAdjustment then
        display.rect{pos= vec2(0,0), size= vec2(940,490), color= rgbm(0,0.01,0.09,0.5-screenBrightness)}
    end
end

function saveState() --saves everything (even though it runs every frame, it only saves if changes are detected)
    storedValues.currentTwin = storagePackNested(currentTwin) 
    storedValues.currentDisplayed = storagePack(currentDisplayed)
    storedValues.currentActiveMenu = currentActiveMenu
    storedValues.currentActive = currentActive
    storedValues.shiftTreshold = shiftTreshold
    storedValues.tresholdValues = storagePack(tresholdValues)
    storedValues.autoDimming = autoDimming
    storedValues.brightnessAdjustment = brightnessAdjustment
    storedValues.gaugeTail = gaugeTail
    storedValues.isScreenOn = isScreenOn
    storedValues.screenBrightness = screenBrightness
end



function saveLastMenuState()
    prevModeNumber = modeNumber
    prevIsMenuActive = isMenuActive
    prevIsSelectActive = isSelectActive
    prevIsShiftActive = isShiftActive
    prevIsRedActive = isRedActive
end

function loadLastMenuState()
    local temp1 = modeNumber -- allows for infinite return loop
    local temp2 = isMenuActive
    local temp3 = isSelectActive
    local temp4 = isShiftActive
    local temp5 = isRedActive

    modeNumber = prevModeNumber 
    isMenuActive = prevIsMenuActive
    isSelectActive = prevIsSelectActive
    isShiftActive = prevIsShiftActive
    isRedActive = prevIsRedActive

    prevModeNumber = temp1
    prevIsMenuActive = temp2
    prevIsSelectActive = temp3
    prevIsShiftActive = temp4
    prevIsRedActive = temp5
end

function script.update(dt)
    
    if not isScreenOn then
        display.rect{pos= vec2(0,0), size= vec2(940,490), color= colours["black"]}
        if btnMid() or btnDisp() then
            isScreenOn = not isScreenOn
        end
    else
        display.rect{pos= vec2(0,0), size= vec2(940,490), color= colours["darkblue"]}
        if not bootup:ended() or bootup:ended() and car.gas < 0.1 and not booted then
            ui.drawImage(bootup, vec2(-10,0), vec2(1000, 512)) --lazy way of stretching the background
            ui.drawImage(bootup, vec2(100,47), vec2(900, 552))
            handleBootupSequence()
        else
            booted = true
        end

        if booted then
            shiftLightBehaviour()
            modeBehaviour()
            --detectSwitchover() disabled for now
            if btnDisp() then --hacky but easier to do this since it always opens on top of every menu
                isDisplayActive = not isDisplayActive
            end
            if isDisplayActive then
                drawDisplayMenu()
            end
            autoDimBehaviour()
            saveState()

            if btnReturn() then 
                loadLastMenuState()
            end
        end
    end
end
