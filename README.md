## R34 Multi Function Display
Fully functional MFD made in LUA for the asc_nissan_r34_nur.

# FAQ

> Pressing the Extra E button makes the rev light flash?

- Yes. Extra E is merely a proxy extra switch used by the script to toggle the Rev Light on and off.

> The script doesn't work for me! 

- Lua scriptable displays were added in CSP 1.76. You need this version for it to work. This is explicit in the video's description.

> I can't switch modes!

- Refer to the user guide pdf present in the car's folder for instructions on how to use the display.

> The screen is too dark!

- Refer to the user guide pdf present in the car's folder for instructions on how to use the display - you can manually tweak the screen brightness. Furthermore, the screen's brightness may be heavily influenced by your install.

> My display has no fonts!

- Please download the most recent version, or follow the installation steps below. 

# Installation:

- Head over to `C:\Program Files (x86)\Steam\steamapps\common\assettocorsa\content\cars\asc_nissan_r34_nur\extension`
- DONT REPLACE THE EXT_CONFIG. Copy the relevant cfg section to the ext_config file
- Install the fonts
- Place the rest of the downloaded files in the directory, overwriting the old ones
- Enjoy!

# IMPORTANT

Due to the MFD locally storing the settings, if any bug occurs and the settings get corrupted, you need to manually delete them in `C:\Users\...\Documents\Assetto Corsa\cfg\extension\state\lua\car_script\asc_nissan_r34_nur.ini`


# WHAT MAY OR MAY NOT BE DONE IN THE FUTURE

- [ ] LUTs for readings, so they can actually be accurate
- [ ] Rewrite circular gauges, so they are accurate (red needle is overlaying the grey centre)
- [ ] Redo a small behaviour innacuracy in the twin setup menu

**Credits:**

 >黒狼#2628: Base car to work with;
 >
 >plus#3477: Code;
 >
 >h ell#6726: Textures;

