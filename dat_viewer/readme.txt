# ==================================================
#  DAT viewer
# ==================================================

The DAT viewer allows to open dat files and have a fast overview of all channels stored within a SXM image.

# --------------------------------------------------
#  Setup
# --------------------------------------------------

In order to use the DAT viewer you need to set local paths for the NanoLib and the path to directory where images are saved.
To this end you have to save in the same directory a MATLAB script called ‘settings.m’ where ‘DAT.m’ is (this directory)  with the following informations:

% local path to NanoLib. variable ‘nanoPath’ MUST be a cell.
nanoPath = {'../../matlab_nanonis/NanoLib/','../../matlab_nanonis_experiments/‘};
% your path to sxm data
datPath = '/Volumes/micro/CLAM2/hpt_c6.2/Nanonis/Data/';

# --------------------------------------------------
#  Usage
# --------------------------------------------------

1. Run DAT viewer main file:
   >> DAT

2. Press open button and search for the directory where measurements are;

3. Press items in the list box in order to let them appear in a new figure;

4. Press on plotted curves to export them on a new figure. Additionally one can press on the button ‘hold exported’ (blue capital letters when active) to plot all exported curves together.