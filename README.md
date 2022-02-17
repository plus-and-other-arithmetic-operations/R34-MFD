## R34 Multi Function Display
Fully functional MFD made in LUA for the asc_nissan_r34_nur.

For now, it requires different data.acd files, as it needs to override the shift up light control

# Installation:

- Unpack data
- Set up CM to use unpacked folder and delete the first entry of digital_instruments.ini
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

