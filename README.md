## R34 Multi Function Display
Fully functional MFD made in LUA for the asc_nissan_r34_nur.

# Installation:

- Head over to `C:\Program Files (x86)\Steam\steamapps\common\assettocorsa\content\cars\asc_nissan_r34_nur\extension`
- Place the downloaded files in the directory, overwriting the old ones.
- Enjoy!


# TO-DO

# Feature Implementation
Stuff that needs to be added to complete the base implementation of the MFD
- [x] Implement select screen with h ell's textures
- [ ] Implement shift up screen
- [ ] Port to ks r34 cars

# Gauges
Stuff that needs to be fixed to finalize the gauge implementation
- [ ] Correct turbo gauge scale
- [ ] Re-code gauge pivot logic using `offset=`
- [ ] Add small unit text to each gauge
- [ ] Maybe generalize gauge functions to simplify code?
- [ ] Tweak circular gauges to make them look less weird on rotation

# Graph
Stuff that needs to be fixed to finalize the graph implementation
- [ ] Make intercooler temperature/exhaust temperature graphs
- [ ] Code hard limit in boost & other graphs if necessary math.min(314,...)

# Textures
Stuff that needs to be fixed to finalize the visuals
- [x] Get rid of placeholder textures (wait for h ell)
- [ ] Change textures to match the real thing

# Accuracy (making it true to IRL)
Stuff that needs to make the MFD true to its real life counterpart
- [ ] Check outline selection thickness
- [x] Check if memory in selected menus is needed or not (It isn't)
- [ ] Find accurate text font

# Misc code improvements
Stuff that needs to be fixed to make the code more compliant to good practices, run faster, etc.
- [ ] Optimize bar menu
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
