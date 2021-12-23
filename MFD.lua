function drawMenuBars(basex, basey, sizex, sizey)
    display.rect{pos= vec2(basex,basey), size= vec2(sizex,sizey), color= rgbm(1,1,1,1)}
    display.rect{pos= vec2(basex+5,basey+5), size= vec2(sizex-10,sizey-10), color= rgbm(0,0.01,0.09,1)}
    display.rect{pos= vec2(basex+215,basey), size= vec2(sizex-440,sizey), color= rgbm(1,1,1,1)}
    display.rect{pos= vec2(basex+220,basey+5), size= vec2(sizex-450,sizey-10), color= rgbm(0,0.01,0.09,1)}
    display.rect{pos= vec2(basex+215,basey), size= vec2(sizex-730,sizey), color= rgbm(1,1,1,1)}
    display.rect{pos= vec2(basex+220,basey+5), size= vec2(sizex-740,sizey-10), color= rgbm(0,0.01,0.09,1)}
   
end

function drawBarMenuText(starterx)
    display.text{pos = vec2(starterx, 60), letter = vec2(45, 35), spacing = -15,text = "BOOST", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(starterx, 120), letter = vec2(40, 35), spacing = -15,text = "THROTTLE", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(starterx-5, 180), letter = vec2(40, 35), spacing = -15,text = "INJECTOR", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(starterx, 240), letter = vec2(40, 35), spacing = -15,text = "OIL-TEMP", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(starterx+5, 300), letter = vec2(40, 35), spacing = -15,text = "W-TEMP", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(starterx, 360), letter = vec2(40, 35), spacing = -15,text = "EXH-TEMP", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(starterx, 420), letter = vec2(40, 35), spacing = -15,text = "INT-TEMP", font = "Microsquare", color= rgbm(1,1,1,1)}
end

function idcLevel(rpm)
    return math.saturate(rpm/8000)*100-10 --find accurate equation
end

local maxValues = {["boost"]=-2, ["oilT"] = 70, ["waterT"] = 0, ["exhT"] = 0,["intT"]=0,["volt"] = 8}
local tresholdValues = {["boost"]=1, ["throttle"]=75,["injector"]=75,["oilT"] = 120, ["waterT"] = 120, ["exhT"] = 875,["intT"]=50}

function getBarColor(currentval,treshold)
    if currentval < treshold then
        return rgbm(0,1,0,1)
    else 
        return rgbm(1,0,0,1)
    end
end

function displayCelsiusCustomInput(input, ypos, boundary, boundaryval)
    if boundary and input-boundaryval <= 0 then
        display.text{width=205,pos = vec2(670, ypos),alignment=1, letter = vec2(40, 40), spacing = -15,text="---", font = "Microsquare", color= rgbm(1,1,1,1)}
    elseif boundary then
        display.text{width=205,pos = vec2(670, ypos),alignment=1, letter = vec2(40, 40), spacing = -15,text=string.format("%.0f",input), font = "Microsquare", color= rgbm(1,1,1,1)}
    else
        display.text{width=205,pos = vec2(670, ypos),alignment=1, letter = vec2(40, 40), spacing = -15,text=string.format("%.0f",input), font = "Microsquare", color= rgbm(1,1,1,1)}
    end
    display.text{pos = vec2(869, ypos-4), letter = vec2(20, 25),text="o", font = "c7_mid", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(880, ypos-4), letter = vec2(32, 55),text="C", font = "c7_mid", color= rgbm(1,1,1,1)}
end

function displayPercentageCustomInput(input, ypos)
    display.text{width=200,pos = vec2(670, ypos),alignment=1, letter = vec2(40, 35), spacing = -15,text=string.format("%.1f",input), font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(872, ypos-5), letter = vec2(35, 50),text="%", font = "c7_mid", color= rgbm(1,1,1,1)}
end

function drawBarMenuGreenBars()

    --boost bar--
    
    displayedPressure = (car.turboBoost+0.3)*10
    maxValues["boost"] = math.max(maxValues["boost"],displayedPressure)

    display.horizontalBar{pos= vec2(410,55), size= vec2(285,45), delta=0, activeColor= rgbm(1,1,1,1), inactiveColor= rgbm(0,0,0,0), total=15, active=maxValues["boost"]}
    display.horizontalBar{pos= vec2(405 ,55), size= vec2(285,45), delta=0, activeColor=rgbm(0,0.01,0.09,1), inactiveColor= rgbm(0,0,0,0), total=15, active=maxValues["boost"]}
    display.horizontalBar{pos= vec2(405,55), size= vec2(285,45), delta=0, activeColor= getBarColor(2*math.floor(car.turboBoost*100)/100-0.3, tresholdValues["boost"]), inactiveColor= rgbm(0,0,0,0), total=15, active=displayedPressure}

    display.text{width=205,pos = vec2(605, 60),alignment=1, letter = vec2(40, 35), spacing = -18,text=string.format("%.2f", 2*math.floor(car.turboBoost*100)/100-0.3), font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(845, 55), letter = vec2(30, 50), spacing = -10,text="kPa", font = "c7_mid", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(802, 55), letter = vec2(15, 30), spacing = -3,text="x100", font = "c7_mid", color= rgbm(1,1,1,1)}

    --throttle bar (no max) --

    display.horizontalBar{pos= vec2(405,115), size= vec2(285,45), delta=0, activeColor= getBarColor(car.gas*100,tresholdValues["throttle"]), inactiveColor= rgbm(0,0,0,0), total=100, active=car.gas*100}
    displayPercentageCustomInput(car.gas*100,120)
   
    --idc bar (no max?)--

    display.horizontalBar{pos= vec2(405,175), size= vec2(285,45), delta=0, activeColor= getBarColor(idcLevel(car.rpm),tresholdValues["injector"]), inactiveColor= rgbm(0,0,0,0), total=100, active=idcLevel(car.rpm)}    
    displayPercentageCustomInput(idcLevel(car.rpm),180)

    --oil temp bar--

    maxValues["oilT"] = math.max(maxValues["oilT"],car.oilTemperature)

    display.horizontalBar{pos= vec2(410,235), size= vec2(285,45), delta=0, activeColor= rgbm(1,1,1,1), inactiveColor= rgbm(0,0,0,0), total=150, active=maxValues["oilT"]-70}
    display.horizontalBar{pos= vec2(405,235), size= vec2(285,45), delta=0, activeColor=rgbm(0,0.01,0.09,1), inactiveColor= rgbm(0,0,0,0), total=150, active=maxValues["oilT"]-70}
    display.horizontalBar{pos= vec2(405,235), size= vec2(285,45), delta=0, activeColor= getBarColor(car.oilTemperature,tresholdValues["oilT"]), inactiveColor= rgbm(0,0,0,0), total=150, active=car.oilTemperature-70}
    
    displayCelsiusCustomInput(car.oilTemperature, 237, true, 70)

    --water temp bar--

    maxValues["waterT"] = math.max(maxValues["waterT"],car.waterTemperature)

    display.horizontalBar{pos= vec2(410,295), size= vec2(285,45), delta=0, activeColor= rgbm(1,1,1,1), inactiveColor= rgbm(0,0,0,0), total=150, active=maxValues["waterT"]-70}
    display.horizontalBar{pos= vec2(405,295), size= vec2(285,45), delta=0, activeColor=rgbm(0,0.01,0.09,1), inactiveColor= rgbm(0,0,0,0), total=150, active=maxValues["waterT"]-70}
    display.horizontalBar{pos= vec2(405,295), size= vec2(285,45), delta=0, activeColor = getBarColor(car.waterTemperature,tresholdValues["waterT"]), inactiveColor= rgbm(0,0,0,0), total=150, active=car.waterTemperature-70}

    displayCelsiusCustomInput(car.waterTemperature, 297, true, 70)

    --exhaust temp bar--
    maxValues["exhT"] = math.max(maxValues["exhT"],car.exhaustTemperature)

    display.horizontalBar{pos= vec2(410,355), size= vec2(285,45), delta=0, activeColor= rgbm(1,1,1,1), inactiveColor= rgbm(0,0,0,0), total=1000, active=maxValues["exhT"]}
    display.horizontalBar{pos= vec2(405,355), size= vec2(285,45), delta=0, activeColor=rgbm(0,0.01,0.09,1), inactiveColor= rgbm(0,0,0,0), total=1000, active=maxValues["exhT"]}
    display.horizontalBar{pos= vec2(405,355), size= vec2(285,45), delta=0, activeColor= getBarColor(car.exhaustTemperature,tresholdValues["exhT"]), inactiveColor= rgbm(0,0,0,0), total=1000, active=car.exhaustTemperature}
        
    displayCelsiusCustomInput(car.exhaustTemperature, 357) --omitting boundary flag is the same as typing false

    --interior temp bar--

    maxValues["intT"] = math.max(maxValues["intT"],ac.getSimState().ambientTemperature-23)

    display.horizontalBar{pos= vec2(410,415), size= vec2(285,45), delta=0, activeColor= rgbm(1,1,1,1), inactiveColor= rgbm(0,0,0,0), total=10, active=maxValues["intT"]}
    display.horizontalBar{pos= vec2(405,415), size= vec2(285,45), delta=0, activeColor=rgbm(0,0.01,0.09,1), inactiveColor= rgbm(0,0,0,0), total=10, active=maxValues["intT"]}
    display.horizontalBar{pos= vec2(405,415), size= vec2(285,45), delta=0, activeColor= getBarColor(ac.getSimState().ambientTemperature,tresholdValues["intT"]), inactiveColor= rgbm(0,0,0,0), total=10, active=ac.getSimState().ambientTemperature-23}

    displayCelsiusCustomInput(ac.getSimState().ambientTemperature, 417,true,0)
    --drawing all icons--

    display.image{image ="MFD.png",pos = vec2(310,57),size = vec2(60,50),color = rgbm(1,1,1,1), uvStart = vec2(1416/1536,282/1210),uvEnd = vec2(1530/1536, 374/1210)} --turbo icon
    display.image{image ="MFD.png",pos = vec2(310,113),size = vec2(60,50),color = rgbm(1,1,1,1), uvStart = vec2(1416/1536,650/1210),uvEnd = vec2(1530/1536, 742/1210)} -- throttle icon
    display.image{image ="MFD.png",pos = vec2(310,175),size = vec2(60,50),color = rgbm(1,1,1,1), uvStart = vec2(1416/1536,750/1210),uvEnd = vec2(1530/1536, 842/1210)} -- injector icon
    display.image{image ="MFD.png",pos = vec2(310,235),size = vec2(60,50),color = rgbm(1,1,1,1), uvStart = vec2(1416/1536,370/1210),uvEnd = vec2(1530/1536, 462/1210)} -- oil icon
    display.image{image ="MFD.png",pos = vec2(310,295),size = vec2(60,50),color = rgbm(1,1,1,1), uvStart = vec2(1416/1536,190/1210),uvEnd = vec2(1530/1536, 282/1210)} --water icon
    display.image{image ="MFD.png",pos = vec2(310,360),size = vec2(60,50),color = rgbm(1,1,1,1), uvStart = vec2(1416/1536,850/1210),uvEnd = vec2(1530/1536, 940/1210)} -- exhaust icon
    display.image{image ="MFD.png",pos = vec2(310,412),size = vec2(60,50),color = rgbm(1,1,1,1), uvStart = vec2(1416/1536,932/1210),uvEnd = vec2(1530/1536, 1024/1210)} -- int icon

end

function drawBarMenu()
    local starterx=60
    local startery=50

    for i = 0, 6 do --drawing the outlines of every bar...
       drawMenuBars(starterx, startery, 860, 55) 
       startery=startery+60
    end
    
    drawBarMenuText(starterx)
    drawBarMenuGreenBars()
end

local leftPivot = vec2(282-40, 226)
local leftPos = vec2(190-40, 230)

local rightPos = vec2(620, 230)
local rightPivot = vec2(703, 226)

local leftOffset = -40
local rightOffset= 425
local maxTurboPercentage = 0
local maxOilPercentage = 0
local maxIDCPercentage = 0
local maxThrottlePercentage = 0
local maxFTorquePercentage = 0
local maxVoltPercentage = 0
local maxExhPercentage = 0
local maxTempPercentage = 0
local mfdSize= vec2(324,380)

function drawIntGauge(sidePivot, sidePos,sideOffset)
    local tempPercentage = ac.getSimState().ambientTemperature
    maxTempPercentage = math.max(maxTempPercentage,tempPercentage)
    local maxRotation = (-maxTempPercentage) * 2.65 --2.65 is the rotation deg /100

    for i = 1, 80 do
        local thisRotation = (-tempPercentage) * 2.65 -- "-" turns rotation counter clockwise
        ui.beginRotation()
        ui.beginRotation()
        display.rect {
            -- draws rectangle
            pos = sidePos,
            size = vec2(21, 120),
            color = rgbm(0,1,0,1)
        }
        if i==80 then
            display.rect {
                -- draws rectangle
                pos = sidePos,
                size = vec2(7, 120),
                color = rgbm(1,0,0,1)
            }
        end
        ui.endRotation(35)
        if tempPercentage > (100 / 80 * i) then
            thisRotation = -(100 / 80 * i) * 2.65
        end
        
        ui.endPivotRotation(thisRotation + 142, sidePivot)

        ui.beginRotation()
        ui.beginRotation()
        display.rect {
            -- draws rectangle
            pos = vec2(sidePos.x+5, sidePos.y-5),
            size = vec2(7, 115),
            color = rgbm(1,1,1,1)
        }
        ui.endRotation(35)
        ui.endPivotRotation(maxRotation + 140, sidePivot)
    end

    display.image{image ="MFD.png",pos = vec2(sideOffset+125,70),size = mfdSize,color = rgbm(1,1,1,1), uvStart = vec2(0,520/1210),uvEnd = vec2(435/1536, 1024/1210)} --3rd gauge
    
    maxValues["intT"] = math.max(maxValues["intT"],ac.getSimState().ambientTemperature)

    display.text{width=205,pos = vec2(sideOffset+230, 318),alignment=1, letter = vec2(60, 50), spacing = -25,text=math.floor(maxValues["intT"]), font = "Microsquare", color= rgbm(0,0,0,1)}
    display.text{width=205,pos = vec2(sideOffset+230, 315),alignment=1, letter = vec2(60, 50), spacing = -25,text=math.floor(maxValues["intT"]), font = "Microsquare", color= rgbm(1,1,1,1)}
    
    display.text{pos = vec2(sideOffset+230, 390), letter = vec2(45,40), spacing = -19,text="0", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(sideOffset+140, 360), letter = vec2(45,40), spacing = -19,text="10", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(sideOffset+80, 310), letter = vec2(45,40), spacing = -19,text="20", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(sideOffset+55, 230), letter = vec2(45,40), spacing = -19,text="30", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(sideOffset+65, 150), letter = vec2(45,40), spacing = -19,text="40", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(sideOffset+100, 85), letter = vec2(45,40), spacing = -19,text="45", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(sideOffset+175, 35), letter = vec2(45,40), spacing = -19,text="60", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(sideOffset+270, 30), letter = vec2(45,40), spacing = -19,text="70", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(sideOffset+360,60), letter = vec2(45,40), spacing = -19,text="80", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(sideOffset+410,130), letter = vec2(45,40), spacing = -19,text="90", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(sideOffset+420,200), letter = vec2(45,40), spacing = -19,text="100", font = "Microsquare", color= rgbm(1,1,1,1)}
end

function drawExhGauge(sidePivot, sidePos, sideOffset)
    local exhPercentage = (car.exhaustTemperature*100)/1000 -- conversion to %
    maxExhPercentage = math.max(maxExhPercentage,exhPercentage)
    local maxRotation = (-maxExhPercentage) * 2.65 --2.65 is the rotation deg /100

    for i = 1, 80 do
        local thisRotation = (-exhPercentage) * 2.65 -- "-" turns rotation counter clockwise
        ui.beginRotation()
        ui.beginRotation()
        display.rect {
            -- draws rectangle
            pos = sidePos,
            size = vec2(21, 120),
            color = rgbm(0,1,0,1)
        }
        if i==80 then
            display.rect {
                -- draws rectangle
                pos = sidePos,
                size = vec2(7, 120),
                color = rgbm(1,0,0,1)
            }
        end
        ui.endRotation(35)
        if exhPercentage > (100 / 80 * i) then
            thisRotation = -(100 / 80 * i) * 2.65
        end
        
        ui.endPivotRotation(thisRotation + 142, sidePivot)

        ui.beginRotation()
        ui.beginRotation()
        display.rect {
            -- draws rectangle
            pos = vec2(sidePos.x+5, sidePos.y-5),
            size = vec2(7, 115),
            color = rgbm(1,1,1,1)
        }
        ui.endRotation(35)
        ui.endPivotRotation(maxRotation + 141, sidePivot)
    end

    display.image{image ="MFD.png",pos = vec2(sideOffset+125,70),size = mfdSize,color = rgbm(1,1,1,1), uvStart = vec2(0,520/1210),uvEnd = vec2(435/1536, 1024/1210)} --3rd gauge
  

    maxValues["exhT"] = math.max(maxValues["exhT"],car.exhaustTemperature)

    display.text{width=205,pos = vec2(sideOffset+230, 318),alignment=1, letter = vec2(55, 45), spacing = -25,text=math.floor(maxValues["exhT"]), font = "Microsquare", color= rgbm(0,0,0,1)}
    display.text{width=205,pos = vec2(sideOffset+230, 315),alignment=1, letter = vec2(55, 45), spacing = -25,text=math.floor(maxValues["exhT"]), font = "Microsquare", color= rgbm(1,1,1,1)}
    
    display.text{pos = vec2(sideOffset+255, 385), letter = vec2(40,35), spacing = -16,text="0", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(sideOffset+135, 365), letter = vec2(40,35), spacing = -16,text="100", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(sideOffset+65, 310), letter = vec2(40,35), spacing = -16,text="200", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(sideOffset+40, 235), letter = vec2(40,35), spacing = -16,text="300", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(sideOffset+45, 155), letter = vec2(40,35), spacing = -16,text="400", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(sideOffset+85, 90), letter = vec2(40,35), spacing = -16,text="500", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(sideOffset+165, 45), letter = vec2(40,35), spacing = -16,text="600", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(sideOffset+265, 35), letter = vec2(40,35), spacing = -16,text="700", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(sideOffset+355, 65), letter = vec2(40,35), spacing = -16,text="800", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(sideOffset+410, 130), letter = vec2(40,35), spacing = -16,text="900", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(sideOffset+420, 205), letter = vec2(35,35), spacing = -16,text="1000", font = "Microsquare", color= rgbm(1,1,1,1)}
end

function drawVoltGauge(sidePivot, sidePos, sideOffset)
    local voltPercentage = (((car.batteryVoltage-8)*100)/8) -- conversion to %
    maxVoltPercentage = math.max(maxVoltPercentage,voltPercentage)
    local maxRotation = (-maxVoltPercentage) * 2.3 --2.3 is the rotation deg /100
    
    for i = 1, 40 do
        local thisRotation = (-voltPercentage) * 2.3 -- "-" turns rotation counter clockwise
        ui.beginRotation()
        ui.beginRotation()
        display.rect {pos = sidePos,size = vec2(16, 120),color = rgbm(0,1,0,1)}
        if i==40 then
            display.rect {pos = sidePos,size = vec2(7, 120),color = rgbm(1,0,0,1)}
        end
        ui.endRotation(35)
        if voltPercentage > (100 / 40 * i) then
            thisRotation = -(100 / 40 * i) * 2.3
        end
        
        ui.endPivotRotation(thisRotation + 140, sidePivot)

        ui.beginRotation()
        ui.beginRotation()
        display.rect {pos = vec2(sidePos.x+5, sidePos.y-5),size = vec2(7, 120),color = rgbm(1,1,1,1)}
        ui.endRotation(35)
        ui.endPivotRotation(maxRotation + 138, sidePivot)
    end

    display.image{image ="MFD.png",pos = vec2(sideOffset+128,70),size = mfdSize,color = rgbm(1,1,1,1), uvStart = vec2(895/1536,523/1210),uvEnd = vec2(1335/1536,1024/1210)} --1st gauge
    display.image{image ="MFD.png",pos = vec2(sideOffset+310,235),size=vec2(90,70),color = rgbm(1,1,1,1), uvStart = vec2(1416/1536,550/1210),uvEnd = vec2(1530/1536, 642/1210)} -- volt icon

    maxValues["volt"] = math.max(maxValues["volt"],car.batteryVoltage)

    display.text{width=205,pos = vec2(sideOffset+240, 318),alignment=1, letter = vec2(55, 50), spacing = -25,text=string.format("%.1f", maxValues["volt"]), font = "Microsquare", color= rgbm(0,0,0,1)}
    display.text{width=205,pos = vec2(sideOffset+238, 315),alignment=1, letter = vec2(55, 50), spacing = -25,text=string.format("%.1f", maxValues["volt"]), font = "Microsquare", color= rgbm(1,1,1,1)}

    display.text{pos = vec2(sideOffset+245, 385), letter = vec2(50,45), spacing = -25,text="8", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(sideOffset+140, 355), letter = vec2(50,45), spacing = -25,text="9", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(sideOffset+65, 290), letter = vec2(50,45), spacing = -25,text="10", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(sideOffset+50, 200), letter = vec2(50,45), spacing = -25,text="11", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(sideOffset+75, 100), letter = vec2(50,45), spacing = -25,text="12", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(sideOffset+145, 45), letter = vec2(50,45), spacing = -25,text="13", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(sideOffset+235, 25), letter = vec2(50,45), spacing = -25,text="14", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(sideOffset+320, 40), letter = vec2(50,45), spacing = -25,text="15", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(sideOffset+385, 95), letter = vec2(50,45), spacing = -25,text="16", font = "Microsquare", color= rgbm(1,1,1,1)}

end


function drawFTorqueGauge(sidePivot, sidePos,sideOffset)
    local torquePercentage = math.abs(car.drivetrainTorque)/6 -- conversion to %
    maxFTorquePercentage = math.max(maxFTorquePercentage,torquePercentage)
    local maxRotation = (-maxFTorquePercentage) * 2.5 --2.5 is the rotation deg /100

    for i = 1, 80 do
        local thisRotation = (-torquePercentage) * 2.5 -- "-" turns rotation counter clockwise
        ui.beginRotation()
        ui.beginRotation()
        display.rect {pos = sidePos,size = vec2(21, 120),color = rgbm(0,1,0,1)}
        if i==80 then
            display.rect {pos = sidePos,size = vec2(7, 120),color = rgbm(1,0,0,1)}
        end
        ui.endRotation(35)
        if torquePercentage > (100 / 80 * i) then
            thisRotation = -(100 / 80 * i) * 2.5
        end
        
        ui.endPivotRotation(thisRotation + 138, sidePivot)

        ui.beginRotation()
        ui.beginRotation()
        display.rect {pos = vec2(sidePos.x+5, sidePos.y-5),size = vec2(7, 115),color = rgbm(1,1,1,1)}
        ui.endRotation(35)
        ui.endPivotRotation(maxRotation + 135, sidePivot)
    end

    display.image{image ="MFD.png",pos = vec2(sideOffset+128,70),size = mfdSize,color = rgbm(1,1,1,1), uvStart = vec2(0,0),uvEnd = vec2(435/1536, 506/1210)} --1st gauge
    display.image{image ="MFD.png",pos = vec2(sideOffset+310,235),size=vec2(90,70),color = rgbm(1,1,1,1), uvStart = vec2(1416/1536,450/1210),uvEnd = vec2(1530/1536, 542/1210)} -- torque icon
    
    display.text{width=205,pos = vec2(sideOffset+245, 318),alignment=1, letter = vec2(65, 50), spacing = -25,text= math.floor(maxFTorquePercentage), font = "Microsquare", color= rgbm(0,0,0,1)}
    display.text{width=205,pos = vec2(sideOffset+242, 315),alignment=1, letter = vec2(65, 50), spacing = -25,text= math.floor(maxFTorquePercentage), font = "Microsquare", color= rgbm(1,1,1,1)}
    
    display.text{pos = vec2(sideOffset+250, 385), letter = vec2(50,45), spacing = -20,text="0", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(sideOffset+155, 355), letter = vec2(50,45), spacing = -20,text="2", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(sideOffset+80, 250), letter = vec2(50,45), spacing = -20,text="4", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(sideOffset+85, 150), letter = vec2(50,45), spacing = -20,text="6", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(sideOffset+120, 85), letter = vec2(50,45), spacing = -20,text="8", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(sideOffset+155, 40), letter = vec2(50,45), spacing = -20,text="10", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(sideOffset+220, 20), letter = vec2(50,45), spacing = -20,text="15", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(sideOffset+295, 30), letter = vec2(50,45), spacing = -20,text="20", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(sideOffset+360, 52), letter = vec2(50,45), spacing = -20,text="25", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(sideOffset+400, 92), letter = vec2(50,45), spacing = -20,text="30", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(sideOffset+425, 150), letter = vec2(50,45), spacing = -20,text="40", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(sideOffset+435, 200), letter = vec2(50,45), spacing = -20,text="50", font = "Microsquare", color= rgbm(1,1,1,1)}

end

function drawThrottleGauge(sidePivot, sidePos, sideOffset)
    local throttlePercentage = (car.gas*100) -- conversion to %

    for i = 1, 80 do
        local thisRotation = (-throttlePercentage) * 2.25 -- "-" turns rotation counter clockwise
        ui.beginRotation()
        ui.beginRotation()
        display.rect {
            -- draws rectangle
            pos = sidePos,
            size = vec2(21, 120),
            color = rgbm(0,1,0,1)
        }
        if i==80 then
            display.rect {
                -- draws rectangle
                pos = sidePos,
                size = vec2(7, 120),
                color = rgbm(1,0,0,1)
            }
        end
        ui.endRotation(35)
        if throttlePercentage > (100 / 80 * i) then
            thisRotation = -(100 / 80 * i) * 2.25
        end
        
        ui.endPivotRotation(thisRotation + 138, sidePivot)

    end

    display.image{image ="MFD.png",pos = vec2(sideOffset+125,70),size = mfdSize,color = rgbm(1,1,1,1), uvStart = vec2(440/1536,0),uvEnd = vec2(872/1536, 506/1210)} --2nd gauge
    display.image{image ="MFD.png",pos = vec2(sideOffset+310,235),size=vec2(90,70),color = rgbm(1,1,1,1), uvStart = vec2(1416/1536,650/1210),uvEnd = vec2(1530/1536, 742/1210)} -- throttle icon
    display.text{pos = vec2(sideOffset+245, 380), letter = vec2(50,45), spacing = -25,text="0", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(sideOffset+105, 335), letter = vec2(50,45), spacing = -25,text="20", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(sideOffset+50, 200), letter = vec2(50,45), spacing = -25,text="40", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(sideOffset+100, 75), letter = vec2(50,45), spacing = -25,text="60", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(sideOffset+240, 25), letter = vec2(50,45), spacing = -25,text="80", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(sideOffset+370, 80), letter = vec2(50,45), spacing = -25,text="100", font = "Microsquare", color= rgbm(1,1,1,1)}

end

function drawInjectorGauge(sidePivot, sidePos, sideOffset)
    
    local idcPercentage = idcLevel(car.rpm) -- conversion to %
    local thisRotation = (-idcPercentage) * 2.25 -- "-" turns rotation counter clockwise
    
    for i = 1, 80 do
        
        ui.beginRotation()
        ui.beginRotation()
        display.rect {pos = sidePos,size = vec2(20, 120),color = rgbm(0,1,0,1)}
        if i==80 then
            display.rect {pos = sidePos,size = vec2(7, 120),color = rgbm(1,0,0,1)}
        end
        ui.endRotation(35)

        if idcPercentage > (100 / 80 * i) then
            thisRotation = -(100 / 80 * i) * 2.25
        end

        ui.endPivotRotation(thisRotation + 140,sidePivot)

    end

    display.image{image ="MFD.png",pos = vec2(sideOffset+125,70),size = mfdSize,color = rgbm(1,1,1,1), uvStart = vec2(440/1536,0),uvEnd = vec2(872/1536, 506/1210)} --2nd gauge
    display.image{image ="MFD.png",pos = vec2(sideOffset+330,240),size = vec2(90,70),color = rgbm(1,1,1,1), uvStart = vec2(1416/1536,750/1210),uvEnd = vec2(1530/1536, 842/1210)} -- injector icon
    display.text{pos = vec2(sideOffset+245, 380), letter = vec2(55,45), spacing = -25,text="0", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(sideOffset+105, 335), letter = vec2(55,45), spacing = -25,text="20", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(sideOffset+50, 200), letter = vec2(55,45), spacing = -25,text="40", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(sideOffset+100, 75), letter = vec2(55,45), spacing = -25,text="60", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(sideOffset+240, 25), letter = vec2(55,45), spacing = -25,text="80", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(sideOffset+370, 80), letter = vec2(55,45), spacing = -25,text="100", font = "Microsquare", color= rgbm(1,1,1,1)}

end

function drawTurboGauge(sidePivot, sidePos, sideOffset)
    
    local turboPercentage = ((car.turboBoost+0.32)*0.689 * 100) -- conversion to %
    local thisRotation = (-turboPercentage) * 2.8 -- "-" turns rotation counter clockwise
    maxTurboPercentage = math.max(maxTurboPercentage,turboPercentage)
    local maxRotation = (-maxTurboPercentage+1) * 2.8

     
    
    for i = 1, 40 do
        
        
        ui.beginRotation()
        ui.beginRotation()

        
        display.rect {
            -- draws rectangle
            pos = sidePos,
            size = vec2(20, 120),
            color = rgbm(0,1,0,1)
        }
        if i==40 then
            display.rect {
                -- draws rectangle
                pos = sidePos,
                size = vec2(7, 120),
                color = rgbm(1,0,0,1)
            }
        end
        ui.endRotation(35)

        if turboPercentage > (100 / 40 * i) then
            thisRotation = -(100 / 40 * i) * 2.8
        end

        ui.endPivotRotation(thisRotation + 146,sidePivot)
        ui.beginRotation()
        ui.beginRotation()
        display.rect {
            -- draws rectangle
             pos = vec2(sidePos.x+5, sidePos.y-5),
            size = vec2(7, 115),
            color = rgbm(1,1,1,1)
        }
        ui.endRotation(35)
        ui.endPivotRotation(maxRotation + 145.5,sidePivot)
    end

    displayedPressure = 2*(car.turboBoost*100)/100-0.2
    maxValues["boost"] = math.max(maxValues["boost"],displayedPressure)


    display.image{image ="MFD.png",pos = vec2(sideOffset+125,70),size = mfdSize,color = rgbm(1,1,1,1), uvStart = vec2(440/1536,520/1210),uvEnd = vec2(872/1536, 1024/1210)} --4th gauge
    display.image{image ="MFD.png",pos = vec2(sideOffset+330,240),size = vec2(90,70),color = rgbm(1,1,1,1), uvStart = vec2(1416/1536,282/1210),uvEnd = vec2(1530/1536, 374/1210)} --turbo icon
    
    display.text{width=205,pos = vec2(sideOffset+245, 318),alignment=1, letter = vec2(50, 40), spacing = -22,text=string.format("%.2f", maxValues["boost"]), font = "Microsquare", color= rgbm(0,0,0,1)}
    display.text{width=205,pos = vec2(sideOffset+242, 315),alignment=1, letter = vec2(50, 40), spacing = -22,text=string.format("%.2f", maxValues["boost"]), font = "Microsquare", color= rgbm(1,1,1,1)}

    display.text{pos = vec2(sideOffset+145, 375), letter = vec2(55,45), spacing = -35,text="-0.5", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(sideOffset+80, 270), letter = vec2(55,45), spacing = -35,text="0", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(sideOffset+60, 110), letter = vec2(55,45), spacing = -35,text="0.5", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(sideOffset+200, 25), letter = vec2(55,45), spacing = -35,text="1.0", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(sideOffset+355, 60), letter = vec2(55,45), spacing = -35,text="1.5", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(sideOffset+420, 195), letter = vec2(55,45), spacing = -35,text="2.0", font = "Microsquare", color= rgbm(1,1,1,1)}
end


function drawOilTempGauge(sidePivot, sidePos, sideOffset)
  
    local oilPercentage = 13+(((car.oilTemperature-80)*100)/80) -- conversion to %
    maxOilPercentage = math.max(maxOilPercentage,oilPercentage)
    local maxOilRotation = (-maxOilPercentage) * 2.3


    for i = 1, 80 do
        local thisRotation = (-oilPercentage) * 2.3 -- "-" turns rotation counter clockwise
        ui.beginRotation()
        ui.beginRotation()
        display.rect {
            -- draws rectangle
            pos = sidePos,
            size = vec2(21, 120),
            color = rgbm(0,1,0,1)
        }
        if i==80 then
            display.rect {pos = sidePos,size = vec2(7, 120),color = rgbm(1,0,0,1)}
        end
        ui.endRotation(35)
        if oilPercentage > (100 / 80 * i) then
            thisRotation = -(100 / 80 * i) * 2.3
        end
        
        ui.endPivotRotation(thisRotation + 143, sidePivot)

        ui.beginRotation()
        ui.beginRotation()
        display.rect {pos = vec2(sidePos.x+5, sidePos.y-5),size = vec2(7, 115),color = rgbm(1,1,1,1)}
        ui.endRotation(35)
        ui.endPivotRotation(maxOilRotation + 140, sidePivot)
    end

    display.image{image ="MFD.png",pos = vec2(sideOffset+125,70),size = mfdSize,color = rgbm(1,1,1,1), uvStart = vec2(889/1536,524/1210),uvEnd = vec2(1324/1536, 1024/1210)} --3rd gauge
    display.image{image ="MFD.png",pos = vec2(sideOffset+330,240),size = vec2(90,70),color = rgbm(1,1,1,1), uvStart = vec2(1416/1536,370/1210),uvEnd = vec2(1530/1536, 462/1210)} -- oil icon
    
    maxValues["oilT"] = math.max(maxValues["oilT"],car.oilTemperature)

    display.text{width=205,pos = vec2(sideOffset+230, 318),alignment=1, letter = vec2(60, 50), spacing = -25,text=math.floor(maxValues["oilT"]), font = "Microsquare", color= rgbm(0,0,0,1)}
    display.text{width=205,pos = vec2(sideOffset+230, 315),alignment=1, letter = vec2(60, 50), spacing = -25,text=math.floor(maxValues["oilT"]), font = "Microsquare", color= rgbm(1,1,1,1)}
    
    display.text{pos = vec2(sideOffset+230, 390), letter = vec2(45,40), spacing = -20,text="70", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(sideOffset+140, 360), letter = vec2(45,40), spacing = -20,text="80", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(sideOffset+70, 280), letter = vec2(45,40), spacing = -20,text="90", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(sideOffset+35, 200), letter = vec2(45,40), spacing = -20,text="100", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(sideOffset+60, 110), letter = vec2(45,40), spacing = -20,text="110", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(sideOffset+120, 50), letter = vec2(45,40), spacing = -20,text="120", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(sideOffset+225, 25), letter = vec2(45,40), spacing = -20,text="130", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(sideOffset+320, 45), letter = vec2(45,40), spacing = -20,text="140", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(sideOffset+395,110), letter = vec2(45,40), spacing = -20,text="150", font = "Microsquare", color= rgbm(1,1,1,1)}

end


local throttleIndex = 1

function fillTable(yVal)
    return {
    vec2(465.0,yVal),vec2(463.85,yVal),vec2(462.7,yVal),vec2(461.55,yVal),vec2(460.4,yVal),vec2(459.25,yVal),vec2(458.1,yVal),vec2(456.95,yVal),vec2(455.8,yVal),vec2(454.65,yVal),
    vec2(453.5,yVal),vec2(452.35,yVal),vec2(451.2,yVal),vec2(450.05,yVal),vec2(448.9,yVal),vec2(447.75,yVal),vec2(446.6,yVal),vec2(445.45,yVal),vec2(444.3,yVal),vec2(443.15,yVal),
    vec2(442.0,yVal),vec2(440.85,yVal),vec2(439.7,yVal),vec2(438.55,yVal),vec2(437.4,yVal),vec2(436.25,yVal),vec2(435.1,yVal),vec2(433.95,yVal),vec2(432.8,yVal),vec2(431.65,yVal),
    vec2(430.5,yVal),vec2(429.35,yVal),vec2(428.2,yVal),vec2(427.05,yVal),vec2(425.9,yVal),vec2(424.75,yVal),vec2(423.6,yVal),vec2(422.45,yVal),vec2(421.3,yVal),vec2(420.15,yVal),
    vec2(419.0,yVal),vec2(417.85,yVal),vec2(416.7,yVal),vec2(415.55,yVal),vec2(414.4,yVal),vec2(413.25,yVal),vec2(412.1,yVal),vec2(410.95,yVal),vec2(409.8,yVal),vec2(408.65,yVal),
    vec2(407.5,yVal),vec2(406.35,yVal),vec2(405.2,yVal),vec2(404.05,yVal),vec2(402.9,yVal),vec2(401.75,yVal),vec2(400.6,yVal),vec2(399.45,yVal),vec2(398.3,yVal),vec2(397.15,yVal),
    vec2(396.0,yVal),vec2(394.85,yVal),vec2(393.7,yVal),vec2(392.55,yVal),vec2(391.4,yVal),vec2(390.25,yVal),vec2(389.1,yVal),vec2(387.95,yVal),vec2(386.8,yVal),vec2(385.65,yVal),
    vec2(384.5,yVal),vec2(383.35,yVal),vec2(382.2,yVal),vec2(381.05,yVal),vec2(379.9,yVal),vec2(378.75,yVal),vec2(377.6,yVal),vec2(376.45,yVal),vec2(375.3,yVal),vec2(374.15,yVal),
    vec2(373.0,yVal),vec2(371.85,yVal),vec2(370.7,yVal),vec2(369.55,yVal),vec2(368.4,yVal),vec2(367.25,yVal),vec2(366.1,yVal),vec2(364.95,yVal),vec2(363.8,yVal),vec2(362.65,yVal),
    vec2(361.5,yVal),vec2(360.35,yVal),vec2(359.2,yVal),vec2(358.05,yVal),vec2(356.9,yVal),vec2(355.75,yVal),vec2(354.6,yVal),vec2(353.45,yVal),vec2(352.3,yVal),vec2(351.15,yVal),
    vec2(350.0,yVal),vec2(348.85,yVal),vec2(347.7,yVal),vec2(346.55,yVal),vec2(345.4,yVal),vec2(344.25,yVal),vec2(343.1,yVal),vec2(341.95,yVal),vec2(340.8,yVal),vec2(339.65,yVal),
    vec2(338.5,yVal),vec2(337.35,yVal),vec2(336.2,yVal),vec2(335.05,yVal),vec2(333.9,yVal),vec2(332.75,yVal),vec2(331.6,yVal),vec2(330.45,yVal),vec2(329.3,yVal),vec2(328.15,yVal),
    vec2(327.0,yVal),vec2(325.85,yVal),vec2(324.7,yVal),vec2(323.55,yVal),vec2(322.4,yVal),vec2(321.25,yVal),vec2(320.1,yVal),vec2(318.95,yVal),vec2(317.8,yVal),vec2(316.65,yVal),
    vec2(315.5,yVal),vec2(314.35,yVal),vec2(313.2,yVal),vec2(312.05,yVal),vec2(310.9,yVal),vec2(309.75,yVal),vec2(308.6,yVal),vec2(307.45,yVal),vec2(306.3,yVal),vec2(305.15,yVal),
    vec2(304.0,yVal),vec2(302.85,yVal),vec2(301.7,yVal),vec2(300.55,yVal),vec2(299.4,yVal),vec2(298.25,yVal),vec2(297.1,yVal),vec2(295.95,yVal),vec2(294.8,yVal),vec2(293.65,yVal),
    vec2(292.5,yVal),vec2(291.35,yVal),vec2(290.2,yVal),vec2(289.05,yVal),vec2(287.9,yVal),vec2(286.75,yVal),vec2(285.6,yVal),vec2(284.45,yVal),vec2(283.3,yVal),vec2(282.15,yVal),
    vec2(281.0,yVal),vec2(279.85,yVal),vec2(278.7,yVal),vec2(277.55,yVal),vec2(276.4,yVal),vec2(275.25,yVal),vec2(274.1,yVal),vec2(272.95,yVal),vec2(271.8,yVal),vec2(270.65,yVal),
    vec2(269.5,yVal),vec2(268.35,yVal),vec2(267.2,yVal),vec2(266.05,yVal),vec2(264.9,yVal),vec2(263.75,yVal),vec2(262.6,yVal),vec2(261.45,yVal),vec2(260.3,yVal),vec2(259.15,yVal),
    vec2(258.0,yVal),vec2(256.85,yVal),vec2(255.7,yVal),vec2(254.55,yVal),vec2(253.4,yVal),vec2(252.25,yVal),vec2(251.1,yVal),vec2(249.95,yVal),vec2(248.8,yVal),vec2(247.65,yVal),
    vec2(246.5,yVal),vec2(245.35,yVal),vec2(244.2,yVal),vec2(243.05,yVal),vec2(241.9,yVal),vec2(240.75,yVal),vec2(239.6,yVal),vec2(238.45,yVal),vec2(237.3,yVal),vec2(236.15,yVal),
    vec2(235.0,yVal),vec2(233.85,yVal),vec2(232.7,yVal),vec2(231.55,yVal),vec2(230.4,yVal),vec2(229.25,yVal),vec2(228.1,yVal),vec2(226.95,yVal),vec2(225.8,yVal),vec2(224.65,yVal),
    vec2(223.5,yVal),vec2(222.35,yVal),vec2(221.2,yVal),vec2(220.05,yVal),vec2(218.9,yVal),vec2(217.75,yVal),vec2(216.6,yVal),vec2(215.45,yVal),vec2(214.3,yVal),vec2(213.15,yVal),
    vec2(212.0,yVal),vec2(210.85,yVal),vec2(209.7,yVal),vec2(208.55,yVal),vec2(207.4,yVal),vec2(206.25,yVal),vec2(205.1,yVal),vec2(203.95,yVal),vec2(202.8,yVal),vec2(201.65,yVal),
    vec2(200.5,yVal),vec2(199.35,yVal),vec2(198.2,yVal),vec2(197.05,yVal),vec2(195.9,yVal),vec2(194.75,yVal),vec2(193.6,yVal),vec2(192.45,yVal),vec2(191.3,yVal),vec2(190.15,yVal),
    vec2(189.0,yVal),vec2(187.85,yVal),vec2(186.7,yVal),vec2(185.55,yVal),vec2(184.4,yVal),vec2(183.25,yVal),vec2(182.1,yVal),vec2(180.95,yVal),vec2(179.8,yVal),vec2(178.65,yVal),
    vec2(177.5,yVal),vec2(176.35,yVal),vec2(175.2,yVal),vec2(174.05,yVal),vec2(172.9,yVal),vec2(171.75,yVal),vec2(170.6,yVal),vec2(169.45,yVal),vec2(168.3,yVal),vec2(167.15,yVal),
    vec2(166.0,yVal),vec2(164.85,yVal),vec2(163.7,yVal),vec2(162.55,yVal),vec2(161.4,yVal),vec2(160.25,yVal),vec2(159.1,yVal),vec2(157.95,yVal),vec2(156.8,yVal),vec2(155.65,yVal),
    vec2(154.5,yVal),vec2(153.35,yVal),vec2(152.2,yVal),vec2(151.05,yVal),vec2(149.9,yVal),vec2(148.75,yVal),vec2(147.6,yVal),vec2(146.45,yVal),vec2(145.3,yVal),vec2(144.15,yVal),
    vec2(143.0,yVal),vec2(141.85,yVal),vec2(140.7,yVal),vec2(139.55,yVal),vec2(138.4,yVal),vec2(137.25,yVal),vec2(136.1,yVal),vec2(134.95,yVal),vec2(133.8,yVal),vec2(132.65,yVal),
    vec2(131.5,yVal),vec2(130.35,yVal),vec2(129.2,yVal),vec2(128.05,yVal),vec2(126.9,yVal),vec2(125.75,yVal),vec2(124.6,yVal),vec2(123.45,yVal),vec2(122.3,yVal),vec2(121.15,yVal)
    }
end


local boostVals = fillTable(390)
setInterval(function()

    boostVals[1].y = 390-(31.5*(math.floor(math.abs(car.turboBoost)*10)))
    
    for i = 1, 298,2 do
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

    local starterBoost = 2
    
    display.rect {pos = vec2(120,50),size = vec2(2, 350),color = rgbm(1,1,1,1)}
    display.rect {pos = vec2(120,400),size = vec2(350, 2),color = rgbm(1,1,1,1)}
    for i=0, 3 do 
        display.rect {pos = vec2(120+(116*i),50),size = vec2(2, 350),color = rgbm(1,1,1,0.1)}
        display.rect {pos = vec2(120+(115*i),405),size = vec2(5, 20),color = rgbm(1,1,1,1)}
    end

    display.text{pos = vec2(441, 425), letter = vec2(40,35), spacing = -17,text="0", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(317, 425), letter = vec2(40,35), spacing = -17,text="10", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(200, 425), letter = vec2(40,35), spacing = -17,text="20", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(87, 425), letter = vec2(40,35), spacing = -17,text="30", font = "Microsquare", color= rgbm(1,1,1,1)}

    for i=0, 5 do
        display.text{width=90,alignment=1,pos = vec2(20,58+(60*i)), letter = vec2(40,35), spacing = -25,text=starterBoost, font = "Microsquare", color= rgbm(1,1,1,1)}
        starterBoost = starterBoost - 0.5
        display.rect {pos = vec2(108,73+(60*i)),size = vec2(10, 5),color = rgbm(1,1,1,1)}
    end

    for i = 0, 30 do
        display.rect {pos = vec2(120,75+(10*i)),size = vec2(350, 2),color = rgbm(1,1,1,0.1)}
        display.rect {pos = vec2(115,73+(10*i)),size = vec2(4, 4),color = rgbm(1,1,1,1)}
    end
 
    for i = 3, 300 do
        ui.drawLine(boostVals[i-1], boostVals[i], rgbm(0,1,0,1),1)
        
        
    end
 
end

local throttleVals = fillTable(399)
setInterval(function()
    throttleVals[1].y = 399-(324*car.gas)   
    for i = 1, 298,2 do
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
    
    display.rect {pos = vec2(120,50),size = vec2(2, 350),color = rgbm(1,1,1,1)}
    display.rect {pos = vec2(120,400),size = vec2(350, 2),color = rgbm(1,1,1,1)}
    for i=0, 3 do 
        display.rect {pos = vec2(120+(116*i),50),size = vec2(2, 350),color = rgbm(1,1,1,0.1)}
        display.rect {pos = vec2(120+(115*i),405),size = vec2(5, 20),color = rgbm(1,1,1,1)}
    end

    display.text{pos = vec2(441, 425), letter = vec2(40,35), spacing = -20,text="0", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(317, 425), letter = vec2(40,35), spacing = -20,text="10", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(200, 425), letter = vec2(40,35), spacing = -20,text="20", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(87, 425), letter = vec2(40,35), spacing = -20,text="30", font = "Microsquare", color= rgbm(1,1,1,1)}

    for i=0, 5 do
        display.text{width=90,alignment=1,pos = vec2(20,58+(64.9*i)), letter = vec2(40,35), spacing = -17,text=starterThrottle, font = "Microsquare", color= rgbm(1,1,1,1)}
        starterThrottle = starterThrottle - 20
        display.rect {pos = vec2(108,73+(64.9*i)),size = vec2(10, 5),color = rgbm(1,1,1,1)}
    end

    for i = 0, 5 do
        display.rect {pos = vec2(120,75+(64.9*i)),size = vec2(350, 2),color = rgbm(1,1,1,0.1)} 
    end
 
    for i = 3, 300 do
        ui.drawLine(throttleVals[i-1], throttleVals[i], rgbm(0,1,0,1),1)
        
    end 
end

local idcVals = fillTable(399)
setInterval(function()
    idcVals[1].y = 399-(3.24*idcLevel(car.rpm))   
    for i = 1, 298,2 do
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
    
    display.rect {pos = vec2(120,50),size = vec2(2, 350),color = rgbm(1,1,1,1)}
    display.rect {pos = vec2(120,400),size = vec2(350, 2),color = rgbm(1,1,1,1)}
    for i=0, 3 do 
        display.rect {pos = vec2(120+(116*i),50),size = vec2(2, 350),color = rgbm(1,1,1,0.1)}
        display.rect {pos = vec2(120+(115*i),405),size = vec2(5, 20),color = rgbm(1,1,1,1)}
    end

    display.text{pos = vec2(441, 425), letter = vec2(40,35), spacing = -17,text="0", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(317, 425), letter = vec2(40,35), spacing = -17,text="10", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(200, 425), letter = vec2(40,35), spacing = -17,text="20", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(87, 425), letter = vec2(40,35), spacing = -17,text="30", font = "Microsquare", color= rgbm(1,1,1,1)}

    for i=0, 5 do
        display.text{width=90,alignment=1,pos = vec2(20,58+(64.9*i)), letter = vec2(40,35), spacing = -17,text=starterIDC, font = "Microsquare", color= rgbm(1,1,1,1)}
        starterIDC = starterIDC - 20
        display.rect {pos = vec2(108,73+(64.9*i)),size = vec2(10, 5),color = rgbm(1,1,1,1)}
    end

    for i = 0, 5 do
        display.rect {pos = vec2(120,75+(64.9*i)),size = vec2(350, 2),color = rgbm(1,1,1,0.1)}   
    end
    
    for i = 0, 4 do
        display.rect {pos = vec2(112,107.5+(64.9*i)),size = vec2(6, 3),color = rgbm(1,1,1,1)}
    end

    for i = 3, 300 do
        ui.drawLine(idcVals[i-1], idcVals[i], rgbm(0,1,0,1),1)
        
    end 
end

local voltVals = fillTable(399)
setInterval(function()
   
    voltVals[1].y = 399-(3.24*(((car.batteryVoltage-8)*100)/8))   
    for i = 1, 298,2 do
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
    
    display.rect {pos = vec2(120,50),size = vec2(2, 350),color = rgbm(1,1,1,1)}
    display.rect {pos = vec2(120,400),size = vec2(350, 2),color = rgbm(1,1,1,1)}
    for i=0, 3 do 
        display.rect {pos = vec2(120+(116*i),50),size = vec2(2, 350),color = rgbm(1,1,1,0.1)}
        display.rect {pos = vec2(120+(115*i),405),size = vec2(5, 20),color = rgbm(1,1,1,1)}
    end

    display.text{pos = vec2(441, 425), letter = vec2(40,35), spacing = -17,text="0", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(317, 425), letter = vec2(40,35), spacing = -17,text="10", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(200, 425), letter = vec2(40,35), spacing = -17,text="20", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(87, 425), letter = vec2(40,35), spacing = -17,text="30", font = "Microsquare", color= rgbm(1,1,1,1)}

    for i=0, 8 do
        display.text{width=90,alignment=1,pos = vec2(20,58+(40.5*i)), letter = vec2(40,35), spacing = -17,text=starterVolt, font = "Microsquare", color= rgbm(1,1,1,1)}
        starterVolt = starterVolt - 1
        display.rect {pos = vec2(108,73+(40.5*i)),size = vec2(10, 5),color = rgbm(1,1,1,1)}
    end

    for i = 0, 8 do
        display.rect {pos = vec2(120,75+(40.5*i)),size = vec2(350, 2),color = rgbm(1,1,1,0.1)}   
    end
    
    for i = 0, 7 do
        display.rect {pos = vec2(112,95.25+(40.5*i)),size = vec2(6, 3),color = rgbm(1,1,1,1)}
    end

    for i = 3, 300 do
        ui.drawLine(voltVals[i-1], voltVals[i], rgbm(0,1,0,1),1)
        
    end 
end

local torqueVals = fillTable(399)
setInterval(function()
   
    torqueVals[1].y = 399-(0.324*math.abs(car.drivetrainTorque))   
    for i = 1, 298,2 do
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
    
    display.rect {pos = vec2(120,50),size = vec2(2, 350),color = rgbm(1,1,1,1)}
    display.rect {pos = vec2(120,400),size = vec2(350, 2),color = rgbm(1,1,1,1)}
    for i=0, 3 do 
        display.rect {pos = vec2(120+(116*i),50),size = vec2(2, 350),color = rgbm(1,1,1,0.1)}
        display.rect {pos = vec2(120+(115*i),405),size = vec2(5, 20),color = rgbm(1,1,1,1)}
    end

    display.text{pos = vec2(441, 425), letter = vec2(40,35), spacing = -17,text="0", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(317, 425), letter = vec2(40,35), spacing = -17,text="10", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(200, 425), letter = vec2(40,35), spacing = -17,text="20", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(87, 425), letter = vec2(40,35), spacing = -17,text="30", font = "Microsquare", color= rgbm(1,1,1,1)}

    for i=0, 10 do
        display.text{width=90,alignment=1,pos = vec2(20,58+(32.5*i)), letter = vec2(40,35), spacing = -17,text=starterTorque, font = "Microsquare", color= rgbm(1,1,1,1)}
        if starterTorque >= 30 then
            starterTorque = starterTorque - 10
        elseif starterTorque > 10 then
            starterTorque = starterTorque - 5
        elseif starterTorque >= 0 then
            starterTorque = starterTorque - 2
        end
        display.rect {pos = vec2(108,73+(32.5*i)),size = vec2(10, 5),color = rgbm(1,1,1,1)}
    end

    for i = 0, 10 do
        display.rect {pos = vec2(120,75+(32.5*i)),size = vec2(350, 2),color = rgbm(1,1,1,0.1)}   
    end
    
    for i = 3, 300 do
        ui.drawLine(torqueVals[i-1], torqueVals[i], rgbm(0,1,0,1),1)
        
    end 
end

local oilVals = fillTable(399)
setInterval(function()  
    oilVals[1].y = 399-(3.24*13+(((car.oilTemperature-80)*100)/80))   
    for i = 1, 298,2 do
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
    
    display.rect {pos = vec2(120,50),size = vec2(2, 350),color = rgbm(1,1,1,1)}
    display.rect {pos = vec2(120,400),size = vec2(350, 2),color = rgbm(1,1,1,1)}
    for i=0, 3 do 
        display.rect {pos = vec2(120+(116*i),50),size = vec2(2, 350),color = rgbm(1,1,1,0.1)}
        display.rect {pos = vec2(120+(115*i),405),size = vec2(5, 20),color = rgbm(1,1,1,1)}
    end

    display.text{pos = vec2(441, 425), letter = vec2(40,35), spacing = -17,text="0", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(317, 425), letter = vec2(40,35), spacing = -17,text="10", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(200, 425), letter = vec2(40,35), spacing = -17,text="20", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(87, 425), letter = vec2(40,35), spacing = -17,text="30", font = "Microsquare", color= rgbm(1,1,1,1)}

    for i=0, 8 do
        display.text{width=90,alignment=1,pos = vec2(20,58+(40.5*i)), letter = vec2(40,35), spacing = -17,text=starterTemp, font = "Microsquare", color= rgbm(1,1,1,1)}
        starterTemp = starterTemp - 10
        display.rect {pos = vec2(108,73+(40.5*i)),size = vec2(10, 5),color = rgbm(1,1,1,1)}
    end

    for i = 0, 8 do
        display.rect {pos = vec2(120,75+(40.5*i)),size = vec2(350, 2),color = rgbm(1,1,1,0.1)}   
    end
    
    for i = 0, 7 do
        display.rect {pos = vec2(112,95.25+(40.5*i)),size = vec2(6, 3),color = rgbm(1,1,1,1)}
    end

    for i = 3, 300 do
        ui.drawLine(oilVals[i-1], oilVals[i], rgbm(0,1,0,1),1)
    end 
end

local displayMesh = display.interactiveMesh{ mesh = "INT_BUTTON_NM", resolution = vec2(512, 512)}
local displayMesh2 = display.interactiveMesh{ mesh = "INT_BUTTONS", resolution = vec2(512, 512)}
local btnMode = displayMesh2.clicked(vec2(423, 34),vec2(63, 24))
local btnMenu = displayMesh2.clicked(vec2(118, 246),vec2(63, 26))
local btnRight = displayMesh.clicked(vec2(229, 241),vec2(28, 25))
local btnLeft = displayMesh.clicked(vec2(226, 112),vec2(34, 32))
local btnDown = displayMesh.clicked(vec2(165, 177),vec2(32, 25))
local btnUp = displayMesh.clicked(vec2(291, 177),vec2(28, 27))
local btnMid = displayMesh.clicked(vec2(216, 164),vec2(54, 54))

local modeNumber = 3
local isMenuActive = false
local isSelectActive = false

local menuOptions = {1,0,0}
local activeMenu = {"SELECT","RED ZONE", "SHIFT UP"}
local currentActiveMenu = "SELECT"

local selectedMode3 = {{1,0,0,0},{0,0,0,0}}
local activeMode3 = {{"BOOST","OIL-TEMP","F-TORQUE","VOLT"},{"THROTTLE","INJECTOR","EXH-TEMP","INT-TEMP"}}
local currentActive = "BOOST"


function drawSelectMenu()
    display.text{pos = vec2(40, 5), letter = vec2(65,45), spacing = -32,text="SELECT", font = "Microsquare", color= rgbm(1,1,1,1)}
    ui.drawRect(vec2(-170+(220*1),-121+(1*215)),vec2(8+(220*1),49+(1*215)),rgbm(1,1,0,1),10,15,15)

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
                        if j== 1 then
                            selectedMode3[j+1][i] = 1
                        else
                            selectedMode3[j-1][i] = 1
                        end
                          
                        
                    elseif btnRight() then
                        if i== 4 then
                            selectedMode3[j][1] = 1
                        else
                            selectedMode3[j][i+1] = 1
                        end
                          
                    elseif btnLeft() then
                        if i== 1 then
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
                ui.drawRect(vec2(-170+(220*i),-121+(j*215)),vec2(8+(220*i),49+(j*215)),rgbm(1,1,0,1),10,15,15)
            elseif selectedMode3[j][i] == 0 then
                ui.drawRect(vec2(-170+(220*i),-121+(j*215)),vec2(8+(220*i),49+(j*215)),rgbm(0,0.01,0.09,1),10,15,20)
            end
            display.image{image ="MFD.png",pos = vec2(-170+(220*i),-125+(j*215)),size = vec2(185,175),color = rgbm(1,1,1,1), uvStart = vec2(1356/1536,0/1210),uvEnd = vec2(1540/1536, 179/1210)}       
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

    display.text{pos = vec2(55+(220*0),50+(0*215)), letter = vec2(55,40), spacing = -27,text="BOOST", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(40+(220*1),50+(0*215)), letter = vec2(50,40), spacing = -27,text="OIL-TEMP", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(35+(220*2),50+(0*215)), letter = vec2(50,40), spacing = -27,text="F-TORQUE", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(70+(220*3),50+(0*215)), letter = vec2(55,40), spacing = -27,text="VOLT", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(30+(220*0),50+(1*215)), letter = vec2(50,40), spacing = -27,text="THROTTLE", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(30+(220*1),50+(1*215)), letter = vec2(50,40), spacing = -27,text="INJECTOR", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(35+(220*2),50+(1*215)), letter = vec2(50,40), spacing = -27,text="EXH-TEMP", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(30+(220*3),50+(1*215)), letter = vec2(50,40), spacing = -27,text="INT-TEMP", font = "Microsquare", color= rgbm(1,1,1,1)}
    
    display.image{image ="MFD.png",pos = vec2(100,150),size = vec2(85,70),color = rgbm(1,1,1,1), uvStart = vec2(1416/1536,282/1210),uvEnd = vec2(1530/1536, 374/1210)} --turbo icon
    display.image{image ="MFD.png",pos = vec2(320,145),size = vec2(85,70),color = rgbm(1,1,1,1), uvStart = vec2(1416/1536,370/1210),uvEnd = vec2(1530/1536, 462/1210)} -- oil icon
    display.image{image ="MFD.png",pos = vec2(538,140),size=vec2(85,70),color = rgbm(1,1,1,1), uvStart = vec2(1416/1536,450/1210),uvEnd = vec2(1530/1536, 542/1210)} -- torque icon
    display.image{image ="MFD.png",pos = vec2(753,142),size=vec2(90,70),color = rgbm(1,1,1,1), uvStart = vec2(1416/1536,550/1210),uvEnd = vec2(1530/1536, 642/1210)} -- battery icon
    display.image{image ="MFD.png",pos = vec2(95,360),size = vec2(85,70),color = rgbm(1,1,1,1), uvStart = vec2(1416/1536,650/1210),uvEnd = vec2(1530/1536, 742/1210)} -- throttle icon
    display.image{image ="MFD.png",pos = vec2(316,360),size = vec2(85,70),color = rgbm(1,1,1,1), uvStart = vec2(1416/1536,750/1210),uvEnd = vec2(1530/1536, 842/1210)} -- injector icon
    display.image{image ="MFD.png",pos = vec2(540,365),size = vec2(85,70),color = rgbm(1,1,1,1), uvStart = vec2(1416/1536,850/1210),uvEnd = vec2(1530/1536, 940/1210)} -- exhaust icon
    display.image{image ="MFD.png",pos = vec2(752,355),size = vec2(85,70),color = rgbm(1,1,1,1), uvStart = vec2(1416/1536,932/1210),uvEnd = vec2(1530/1536, 1024/1210)} -- int icon
    
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
    else
        drawTurboGauge(rightPivot,rightPos,rightOffset)
        drawTurboGraph()
    end
end

function drawMenuMode(isGreyedOut)
    display.text{pos = vec2(50, 0), letter = vec2(60,50), spacing = -22,text="MENU", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(40, 50), letter = vec2(50,40), spacing = -20,text="SELECT", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(250, 50), letter = vec2(45,40), spacing = -20,text="RED ZONE", font = "Microsquare", color= rgbm(1,1,1,1)}
    display.text{pos = vec2(475, 50), letter = vec2(45,40), spacing = -20,text="SHIFT UP", font = "Microsquare", color= rgbm(1,1,1,1)}


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
            ui.drawRect(vec2(-170+(220*i),-121+215),vec2(8+(220*i),49+215),rgbm(1,1,0,1),10,15,15)
        elseif menuOptions[i] == 0 then
            ui.drawRect(vec2(-170+(220*i),-121+215),vec2(8+(220*i),49+215),rgbm(0,0.01,0.09,1),10,15,20)        
        end
        --if i==1 and isGreyedOut then
        --    display.image{image ="MFD.png",pos = vec2(-173+(220*i),-121.5+215),size = vec2(185,175),color = rgbm(1,1,1,1), uvStart = vec2((600+185*(i-2))/1536,1025/1210),uvEnd = vec2((785+185*(i-2))/1536, 1210/1210)}
        --else
            display.image{image ="MFD.png",pos = vec2(-173+(220*i),-121.5+215),size = vec2(185,175),color = rgbm(1,1,1,1), uvStart = vec2((600+185*(i-1))/1536,1025/1210),uvEnd = vec2((785+185*(i-1))/1536, 1210/1210)}
        --end
    
    end

    if btnMid() then
        
        if menuOptions[1] == 1 then
            currentActiveMenu = activeMenu[1]
            if modeNumber == 3 then
                isSelectActive = true
            end
        
        elseif menuOptions[2] == 1 then
            currentActiveMenu = activeMenu[2]
            if modeNumber == 3 then
                isSelectActive = true
            end
        
        elseif menuOptions[3] == 1 then
            currentActiveMenu = activeMenu[3]
            if modeNumber == 3 then
                isSelectActive = true
            end
        end
        isMenuActive = false
        
    end


end

function modeBehaviour()
    if btnMode() then
        modeNumber = modeNumber+1
        if modeNumber == 4 then
            modeNumber=1
        end
    end 

    if btnMenu() then
        isMenuActive = not isMenuActive
    end

    if modeNumber == 1 then
        if isMenuActive then
            drawMenuMode(true)
        else
            drawBarMenu()
        end
    end

    if modeNumber == 2 then
        if isMenuActive then
            drawMenuMode()
        else
            drawOilTempGauge(leftPivot,leftPos, leftOffset)
            drawTurboGauge(rightPivot,rightPos,rightOffset)
        end
    end

    if modeNumber == 3 then
        if isMenuActive then
            drawMenuMode()
        elseif isSelectActive then
            drawSelectMenu()
        else
            drawGraph()
        end
        
    end
end

function update(dt)
    display.rect{pos= vec2(0,0), size= vec2(940,490), color= rgbm(0,0.01,0.09,1)}
    
    --drawTurboGauge(rightPivot,rightPos,rightOffset)
    --drawTurboGraph()
    
    --drawThrottleGauge(rightPivot,rightPos,rightOffset)
    --drawThrottleGraph()

    --drawInjectorGauge(rightPivot,rightPos,rightOffset)
    --drawIDCGraph()

    --drawVoltGauge(rightPivot,rightPos, rightOffset)
    --drawVoltGraph()

    --drawOilTempGauge(rightPivot,rightPos, rightOffset)
    --drawOilTempGraph()


    --drawFTorqueGauge(rightPivot,rightPos,rightOffset)
    --drawFTorqueGraph()

    --drawExhGauge(rightPivot,rightPos,rightOffset)
    
    --drawIntGauge(leftPivot,leftPos,leftOffset)
    
    drawMenuMode(true)
    
    --modeBehaviour()


    --drawSelectMenu()
    --drawBarMenu()

end