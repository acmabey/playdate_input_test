# playdate_input_test
small playdate 'game' to display inputs & test out basic functions, made from SquidGod's template: https://github.com/SquidGodDev/playdate-template

### Features
* graphical representation of inputs & their states
    * d-pad, a/b buttons which highlight when pressed
    * crank position drawn three times with different rotational increments, showing how different levels of interpolation look/feel
* sprite animation
    * 32x32 sprite looping an idle animation
* minimal screen updates
    * only areas of the screen that are updated in each frame will be redrawn
