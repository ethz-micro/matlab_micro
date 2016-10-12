# --------------------------------------------------
#  SXM viewer
# --------------------------------------------------

The SXM viewer allows to open sxm files and have a fast overview of all channels stored within a SXM image.

In order to use the SXM viewer you need to set local paths for the NanoLib and the path to directory where images are saved.
To this end you have to save in the same directory where where 'SXM.m' is (this directory) a MATLAB script called 'localVariables.m' with the following informations:

nanoPath = '../../matlab_nanonis/NanoLib/'; % local path to NanoLib
sxmPath = '/Volumes/micro/CLAM2/hpt_c6.2/Nanonis/Data/'; % your path to sxm data