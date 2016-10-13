# ==================================================
#  SXM viewer
# ==================================================

The SXM viewer allows to open sxm files and have a fast overview of all channels stored within a SXM image.

# --------------------------------------------------
#  Setup
# --------------------------------------------------

In order to use the SXM viewer you need to set local paths for the NanoLib and the path to directory where images are saved.
To this end you have to save a MATLAB script called ‘viewerSettings’ in the same directory  where ‘SXM.m’ is (this directory) with the following informations:

% local path to NanoLib. variable ‘nanoPath’ MUST be a cell.
nanoPath = {‘../../matlab_nanonis/NanoLib/‘};
% your path to sxm data
sxmPath = '/Volumes/micro/CLAM2/hpt_c6.2/Nanonis/Data/';

# --------------------------------------------------
#  Usage
# --------------------------------------------------

1. Run SXM viewer main file:
   >> SXM

2. Select the process type in the popupmenu (default = Raw)

3. Press open button and search for the directory where measurements are;

3. Press items in the list box in order to let them appear in a new figure;

4. Press on plotted channels to export them on a new figure.