function  SXM(varargin)

%sSize = get(0,'screensize');

addpath('../../matlab_nanonis/NanoLib/')

%  Create and then hide the UI as it is being constructed.
hSXM = figure('Name','SXM_Viewer','Visible','off',...
    'Position',[50,50,340,650],'Tag','SXM_Viewer');

set(hSXM,'DeleteFcn',@closeViewer)

SXM_CreateFcn(hSXM);

SXM_OpeningFcn(hSXM, guidata(hSXM), varargin)

% set dialog to visible
hSXM.Visible = 'on';

% wait for closing of the main figure.
% uiwait(hSXM);

function SXM_OpeningFcn(~, handles, varargin)
    
handles.hSystem.UserData = '/';
handles.hFolderName.UserData = '/Volumes/micro/CLAM2/hpt_c6.2/Nanonis/Data/';
handles.hSystem.String = 'OS X';
if ispc
    handles.hSystem.String = 'Windows';
    handles.hSystem.UserData = '\';
    handles.hFolderName.UserData = 'Z:\CLAM2\hpt_c6.2\Nanonis\Data\';
end


function SXM_CreateFcn(hObject,handles)
%-------------------------------------------------------------------------%
px = 20;
py = 570;

handles.hSystem = uicontrol('Parent',hObject,'Style','text',...
    'Position',[px,py+55,300,15],'String','OP System','HorizontalAlignment','left');

handles.hFolderName = uicontrol('Parent',hObject,'Style','edit',...
    'String','actualfolder','Position',[px,py+30,300,25],'HorizontalAlignment','left',...
    'Callback',@(hObject,eventdata)hFolderName_Callback(hObject,eventdata,guidata(hObject)));

handles.hOpenFolder = uicontrol('Parent',hObject,'Style','pushbutton',...
    'Position',[px,py,300,25],'String','Open',...
    'Callback',@(hObject,eventdata)hOpenFolder_Callback(hObject,eventdata,guidata(hObject)));


%-------------------------------------------------------------------------%
px = 20;
py = 20;

handles.hFileList = uicontrol('Parent',hObject,'Style','listbox',...
    'Position',[px,py+300,300,240],'String','Files list',...
    'Callback',@(hObject,eventdata)hFileList_Callback(hObject,eventdata,guidata(hObject)));


handles.hInfoList = uicontrol('Parent',hObject,'Style','listbox',...
    'Position',[px,py,300,280],'String','Files info list');



% Choose default command line output for SXM_Combine_Channels
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);


% ------------------------------ GUI CALL BACK ----------------------------

function hFolderName_Callback(hObject, eventdata, handles)
% hObject    handle to hFolderName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of hFolderName as text
%        str2double(get(hObject,'String')) returns contents of hFolderName as a double
loadFiles(hObject,handles)
showFiles(hObject,handles,eventdata)

% --- Executes on button press in hOpenFolder.
function hOpenFolder_Callback(hObject, eventdata, handles)
% hObject    handle to hOpenFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% input file names
startFolderName = sprintf('%s%s',handles.hFolderName.UserData,handles.hSystem.UserData);
folderName = uigetdir(startFolderName,'Select SXM folder');
if isequal(folderName,0)
    fprintf('user choose cancel.\n');
    return
end
folderName = sprintf('%s%s',folderName,handles.hSystem.UserData);
handles.hFolderName.String = folderName;

loadFiles(hObject,handles)
showFiles(hObject,handles,eventdata)

% --- Executes on selection change in hFileList.
function hFileList_Callback(hObject, eventdata, handles)
% hObject    handle to hFileList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns hFileList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from hFileList
%hSXMLoad_Callback(hObject, eventdata, handles)
showFiles(hObject,handles,eventdata);

% ------------------------------ USER FUNCTIONS ---------------------------

function loadFiles(hObject,handles)

folderName = handles.hFolderName.String;
handles.hFolderName.UserData = fileparts(handles.hFolderName.String(1:end-1));

% get all sxm
fileNames = dir(sprintf('%s*.sxm',folderName));
if isempty(fileNames)
    str = 'no sxm files found in dir.';
    fprintf('%s\n',str);
    handles.hFileList.String = str;
    return
end

% clear listbox
handles.hFileList.String = '';
% fill listbox
progress = linspace(1/numel(fileNames),1,numel(fileNames));
wbar = waitbar(0,'searching SXM measurements');
kk = 1;
userData = struct('sxm',[]);
s = cell(numel(fileNames),1);
for ii = 1:numel(fileNames)
    wbar = waitbar(progress(ii),wbar);
    sxm = sxm.load.loadProcessedSxM (sprintf('%s%s%s',folderName,handles.hSystem.UserData,fileNames(ii).name));
    userData(kk).sxm = sxm;
    s{kk} = fileNames(ii).name;
    kk = kk +1;
end
close(wbar)

if ~exist('userData','var')
    str = {'no sxm files';'files found in dir.'};
    fprintf('%s%s\n',str{:});
    handles.hFileList.String = str;
    return
end

% save values to list
handles.hFileList.UserData= userData;
handles.hFileList.String = s;


function showFiles(hObject,handles,~)

userData = handles.hFileList.UserData(handles.hFileList.Value);

handles.hInfoList.String = '';
%%
fields = fieldnames(userData.sxm.header);
s = cell(numel(fields),1);
for i = 1:numel(fields);
  cc = userData.sxm.header.(fields{i});
  if isstr(cc)
      s{i} = sprintf('%s = %s',fields{i},cc);
  else
      s{i} = sprintf('%s = %s',fields{i},mat2str(cc));
  end
end
handles.hInfoList.String = s;
%%

allFig = findobj('Tag',userData.sxm.header.scan_file);
if ~isempty(allFig)
    figure(allFig);
    return
end

% retrive screensize
sSize = get(0,'screensize');

nCh = numel(userData.sxm.channels);

[nRow,nCol,~] = utility.fitFig2Screen(nCh,[380,50,sSize(3)-380,sSize(4)-200]);
figure('Position',[380,50,(sSize(4)-100)*nRow/nCol,sSize(4)-200],...
    'Tag',userData.sxm.header.scan_file,...
    'WindowStyle','Docked');

for iCh = nCh:-1:1
    %f(iCh) = figure('Position',figPosition(iCh,:),'Tag','sxm_figure');
    sp = subplot(nCol,nRow,iCh);
    sp_outPos =  get(gca,'OuterPosition');
    
    p = sxm.plot.plotChannel(userData.sxm.channels(iCh),userData.sxm.header);
    colormap(sxm.op.nanonisMap(128))
    
    % plotData automatically sets
    % 'FontSize'=12  and 'OuterPosition'=[0,0,1,1]
    set(sp,'OuterPosition',sp_outPos);
    set(sp,'FontSize',9)
    
    set(p,'ButtonDownFcn',@(hObject,eventdata)plotThis(hObject,eventdata,userData.sxm,iCh))
end

function closeViewer(~,~)

fprintf('close all windows\n');
close all

function plotThis(~,~,sxm,channel)
f = figure;
f.Units = 'Centimeters';
fpos = f.Position;
f.Position = [fpos(1:2),7.8,7.9];
p = sxm.plot.plotChannel(sxm.channels(channel),sxm.header);
p.Parent.FontSize = 8;
colormap(sxm.op.nanonisMap(128))
%pause(100/1000);
%f.Visible = 'off';
%print(f,'-clipboard','-dbitmap')
%disp('copied to clipboard')
%delete(f)