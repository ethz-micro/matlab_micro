function file=loadProcessed3ds(varargin)
%% comment to update !!
%LOADPROCESSEDDAT - loads a file.dat calling the function loaddat.m 
% provided by Nanonis. And process the header and the data according
% to the type of experiment by calling – automatically – 
% the corresponding experiment_#.
% 
% Syntax: 
%   file = LOADPROCESSEDDAT() ask for a fileName.dat and load it.
%   file = LOADPROCESSEDDAT(fileName) load the file named fileName.dat.
%   file = LOADPROCESSEDDAT(fileName,pathName) load the file named 
%          fileName.dat at a given pathName.
%
% Inputs:
%    fileName - name of file.
%    pathName - path of the file
%
% Outputs:
%    file - structure with fields: header and channels
%
% Example:
%   file = dat.load.loaddat(fn);
%
% See also dat.plot.plotData.m

% September 2016

%------------- BEGIN CODE --------------

% open document
if isempty(varargin)
    [fN,pN] = uigetfile('*.dat');
    if isequal(fN,0)
        disp('User selected Cancel')
        file = nan;
        return
    end
elseif length(varargin) == 1
    % check if path and file are provided together
    [pN,fN,ext] = fileparts(varargin{1});
    
    fN = sprintf('%s%s',fN,ext);
    
    if isempty(pN)
        pN = pwd;
    end
    
    if strcmp(getenv('OS'),'Windows_NT')
        pN = [pN,'\']; %pwd: print working directory
    else
        pN = [pN,'/']; %pwd: print working directory
    end
    
else
    pN = varargin{2};
    fN = varargin{1};
end

display(['read file: ' fN]);

% get header
fileName = [pN,fN];

header = clam.load.load3ds(fileName);

% Default parameters values in the header.
header.grid_points = prod(header.grid_dim);

allData = nan(header.grid_points,header.points,numel(header.channels));
allPar = nan(header.grid_points,4);
for i = 1:header.grid_points
    [~,data,par] = clam.load.load3ds(fileName,i-1);
    if isempty(data)
        header.grid_points = i-1;
        allData(i:end,:,:) = [];
        allPar(i:end,:,:) = [];
        break;
    end
    allData(i,:,:) = data;
    allPar(i,:,:) = par;    
end


header.parameter = allPar;

% first channel
for i = 1
    channels(i).data = allData(:,:,i)';
    [s,r] = strtok(header.channels{i},'[]');
    channels(i).Name = s;
    channels(i).Unit = regexprep(r, '(\(|\)|\[|\])', '');
    channels(i).Direction = 'Both';
end
% first channel
for i = 2:numel(header.channels)
    channels(i).data = allData(:,:,i)';
    str = header.channels{i}(1:end-5);
    [s,r] = strtok(str,'[]');
    channels(i).Name = s;
    channels(i).Unit = regexprep(r, '(\(|\)|\[|\])', '');
    channels(i).Direction = header.channels{i}(end-3:end-1);
end


%add number of points to header
% header.points = size(channels(1).data,1);

% save file info to header
header.path = pN;
header.file = fN;

% save to output
file = struct('header',header,'channels',channels);

end