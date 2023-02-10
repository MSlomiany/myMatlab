# My Matlab

This repository contains functions, objects and scripts for Matlab I've created during my studies. They are mostly useful for data analysis. 

Most useful scripts (in my opinion):

## myISA (function)

**[myISA](https://github.com/MSlomiany/myMatlab/blob/main/functions/myISA.m)** - my version of International Standard Atmoshere covering altitude range from 0 to 80 km, as MATLAB built-in fuction works properly only up to 12 km. At the time myISA returns only temperature and pressure at given altitude.

## utility (object with static methods)

**[utility](https://github.com/MSlomiany/myMatlab/blob/main/objects/utility.m)** - is an object which allow to change groot settings and helps with formatting figures. I used it a lot as it reduce lines of code needed to create good-loking plots. Typical use case:

Call this static method which clears all workspace and resets Matlab setting to defaults
```matlab
utility.init();
```
Create `utility` type object. `utility.init()` must be called before creating any object as it clears whole workspace. Constructor requires three argumets. They act as follows:
+ **Print figures**. For the first argument, pass `1` to print figures opened during script execution. They will be saved in a current path folder (in a folder with your script) and named as `script_name_index.png`. If you pass `0` figures will not be saved.
+ **Close figures**. For the second argument pass `1` if you want to close all figures when your script finishes execution. I find it useful during debugging when I focus on variables in the workspace and I don't want to be disturbed by popping-up figures.
+ **Run the next script**. For the last argument pass `1` if you want to open next script. This feature works only if you name your scripts in a manner `name_index`. For example, if your first script is named `p1.m`, the second must be named `p2.m` to be automatically executed.

```matlab
utility = utility(0,0,0);
```
Then, in the last line of the script invoke method `utility.endcript()`. Note that this isn't a static method and requires initialized object.

```matlab
utility.endscript();
```
