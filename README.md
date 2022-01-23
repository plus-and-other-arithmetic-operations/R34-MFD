## R34 Multi Function Display
Fully functional MFD made in LUA for the asc_nissan_r34_nur.

For now, it requires different data.files, as it needs to override the shift up light control

# Installation:

- Set up CM to use unpacked folder and delete the first entry of digital_instruments.ini
- Head over to `C:\Program Files (x86)\Steam\steamapps\common\assettocorsa\content\cars\asc_nissan_r34_nur\extension`
- Place the downloaded files in the directory, overwriting the old ones.
- Enjoy!


# TO-DO

# Feature Implementation
Stuff that needs to be added to complete the base implementation of the MFD
- [x] Port to new touge version
- [x] Implement select screen with h ell's textures
- [x] Implement shift up screen
- [ ] Implement return button
- [ ] Port to ks r34 cars
- [x] Implement Red Zone Menu
- [x] Implement menu switchover when treshold is exceeded
- [x] Add resetting max values on bar menu when middle joystick button pressed
- [ ] TWIN menu
- [x] Implement display menu
- [x] Add start animation
- [ ] Store saved settings in a way that it persists between sessions 
- [x] Add dimming (draw opaque rectangle over)


# Gauges
Stuff that needs to be fixed to finalize the gauge implementation
- [x] Correct turbo gauge scale
- [x] Re-code gauge pivot logic using `offset=` - NOT DOABLE FOR NOW, SKILL ISSUE
- [x] Correct turbo number reading
- [x] Add small unit text to each gauge
- [x] Maybe generalize gauge functions to simplify code? - NOT DOABLE FOR NOW, SKILL ISSUE
- [x] Tweak circular gauges to make them look less weird on rotation
- [x] Link shift up selection to emissive (use setExtraX and tweak emissive cfg)
- [ ] Draw --- text when below certain threshold
- [x] Add toggleable gauge tail
- [x] Interior temp gauge missing icon
- [x] Make gauges flash red when maxxed out
- [ ] Weird needle on oil temp gauge

# Graph
Stuff that needs to be fixed to finalize the graph implementation
- [x] Make intercooler temperature/exhaust temperature graphs
- [x] Code hard limit in boost & other graphs if necessary math.min(314,...)
- [ ] Graph dropping off at the edge
- [ ] Turbo reading is off


# Textures
Stuff that needs to be fixed to finalize the visuals
- [x] Get rid of placeholder textures (wait for h ell)
- [ ] Change textures to match the real thing

# Accuracy (making it true to IRL)
Stuff that needs to make the MFD true to its real life counterpart
- [x] Check outline selection thickness
- [x] Check if memory in selected menus is needed or not (It isn't)
- [x] Correct circular gauge behaviour and layering
- [ ] Find accurate text font
- [x] Change interior temp to intercooler temp
- [x] Find accurate attesa car variable (not really doable atm)

# Misc code improvements
Stuff that needs to be fixed to make the code more compliant to good practices, run faster, etc.

- [ ] Select menu font spacing
- [x] Optimize bar menu
- [x] Fix ilja's mess
- [x] Figure out greyed out select screen
- [x] Generalize Menu screen


**Credits:**

 >黒狼#2628: Base car to work with;
 >
 >plus#3477: Code;
 >
 >h ell#6726: Textures;
 >
 >mehdi2344#1623: Reference, bug testing, vetting, overall knowledge about the system.
