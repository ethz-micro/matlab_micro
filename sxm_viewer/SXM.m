function  SXM(varargin)

%sSize = get(0,'screensize');

%  Create and then hide the UI as it is being constructed.
hSXM = figure('Name','SXM_Viewer','Visible','off',...
    'Position',[50,-50,340,655],'Tag','SXM_Viewer');

SXM_CreateFcn(hSXM);

set(hSXM,'DeleteFcn',@(hObject,eventdata)closeViewer(hObject,eventdata,guidata(hSXM)))

openError = SXM_OpeningFcn(hSXM, guidata(hSXM), varargin);

if ~openError
    % set dialog to visible
    set(hSXM, 'menubar', 'none');
    hSXM.Visible = 'on';
end

% wait for closing of the main figure.
% uiwait(hSXM);

function openError = SXM_OpeningFcn(~, handles, varargin)

openError = false; 

if exist('viewerSettings.m','file')==2
    run('viewerSettings.m');
    addpath(nanoPath{:});
    handles.hFolderName.UserData = sxmPath;
    
    handles.hSystem.UserData = '/';
    handles.hSystem.String = 'OS X';
    if ispc
        handles.hSystem.String = 'Windows';
        handles.hSystem.UserData = '\';
    end
else
    openError = true;
    wdlg = warndlg({'1. Read readme.txt file';'2. Create file: viewerSettings.m';'3. Run SXM.m again'});
    waitfor(wdlg);
end

function SXM_CreateFcn(hObject,handles)
%-------------------------------------------------------------------------%
px = 20;
py = 570;

handles.hSystem = uicontrol('Parent',hObject,'Style','text',...
    'Position',[px,py+60,95,15],'String','OP System','HorizontalAlignment','left');

handles.hFolderName = uicontrol('Parent',hObject,'Style','edit',...
    'String','actualfolder','Position',[px,py+30,300,25],'HorizontalAlignment','left',...
    'Callback',@(hObject,eventdata)hFolderName_Callback(hObject,eventdata,guidata(hObject)));

handles.hProcessType = uicontrol('Parent',hObject,'Style','popup',...
    'Position',[px-5,py+7,150,15],'String',{'Raw','Mean','PlaneLineCorrection','Median'},...
    'HorizontalAlignment','left',...
    'Callback',@(hObject,eventdata)hProcessType_Callback(hObject,eventdata,guidata(hObject)));

handles.hOpenAll = uicontrol('Parent',hObject,'Style','checkbox',...
    'Position',[px+155,py-2,70,25],'string','load all',...
    'Value',1);

handles.hOpenFolder = uicontrol('Parent',hObject,'Style','pushbutton',...
    'Position',[px+240,py,60,25],'String','Open',...
    'Callback',@(hObject,eventdata)hOpenFolder_Callback(hObject,eventdata,guidata(hObject)));

% handles.hClean = uicontrol('Parent',hObject,'Style','pushbutton',...
%     'Position',[px+220,py,80,25],'String','Clean',...
%     'Callback',@(hObject,eventdata)hClean_Callback(hObject,eventdata,guidata(hObject)));


%-------------------------------------------------------------------------%
px = 20;
py = 20;

handles.hSValue = uicontrol('Parent',hObject,'Style','edit',...
    'Position',[px,py+500,40,25],'String','0.015');

handles.hFileList = uicontrol('Parent',hObject,'Style','listbox',...
    'Position',[px,py+300,300,200],'String','Files list',...
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
showFiles(hObject,eventdata,handles)

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

% --- Executes on button press in hOpenFolder.
function hProcessType_Callback(~, ~, handles)
% hObject    handle to hOpenFolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

userData = handles.hFileList.UserData;
fileNames = handles.hFileList.String;
if ~strcmp(fileNames,'Files list')
    progress = linspace(1/numel(fileNames),1,numel(fileNames));
    wbar = waitbar(0,'searching SXM measurements');
    for ii = 1:numel(fileNames)
        wbar = waitbar(progress(ii),wbar);
        if ~isempty(userData(ii).sxmFile.header)
            userData(ii).sxmFile = loadSXM(fileNames{ii},handles);
        end
    end
    close(wbar);
end
% save values to list
handles.hFileList.UserData= userData;


% --- Executes on selection change in hFileList.
function hFileList_Callback(hObject, eventdata, handles)
% hObject    handle to hFileList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns hFileList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from hFileList
%hSXMLoad_Callback(hObject, eventdata, handles)
showFiles(hObject,eventdata,handles)

% ------------------------------ USER FUNCTIONS ---------------------------

function loadFiles(~,handles)

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
userData = struct('sxmFile',[]);
s = cell(numel(fileNames),1);
for ii = 1:numel(fileNames)
    wbar = waitbar(progress(ii),wbar);
% <<<<<<< HEAD
%     if ii == 1
%         sxmFile = sxm.load.loadProcessedSxM (...
%             sprintf('%s%s%s',folderName,handles.hSystem.UserData,fileNames(ii).name),...
%             handles.hProcessType.String{handles.hProcessType.Value});
%         sxmFile = processData(sxmFile,handles);
% =======
    if ii == 1 || handles.hOpenAll.Value
        sxmFile = loadSXM(fileNames(ii).name,handles);
% >>>>>>> e162fd276de6952b8c9f8f81337099bbabbd6e0f
    else
        sxmFile = struct('header',[],'channels',[]);
    end
         
    userData(kk).sxmFile = sxmFile;
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

function sxmFile = loadSXM(fileName,handles)
folderName = handles.hFolderName.String;
sxmFile = sxm.load.loadProcessedSxM(...
    sprintf('%s%s%s',folderName,handles.hSystem.UserData,fileName),...
    handles.hProcessType.String{handles.hProcessType.Value});

function showFiles(hObject,eventdata,handles)

newLoad = false;
% check if user data is empty. if yes, load data
if isempty(handles.hFileList.UserData(handles.hFileList.Value).sxmFile.header)
    fileName = handles.hFileList.String{handles.hFileList.Value};
% <<<<<<< HEAD
%     sxmFile = sxm.load.loadProcessedSxM (...
%         sprintf('%s%s%s',folderName,handles.hSystem.UserData,fileName),...
%         handles.hProcessType.String{handles.hProcessType.Value});
%     
%     sxmFile =  processData(sxmFile,handles);
%     
% =======
    hdlg = helpdlg(sprintf('open: %s',fileName));
    sxmFile = loadSXM(fileName,handles);
% >>>>>>> e162fd276de6952b8c9f8f81337099bbabbd6e0f
    handles.hFileList.UserData(handles.hFileList.Value).sxmFile = sxmFile;
    newLoad = true;
    close(hdlg);
end

userData = handles.hFileList.UserData(handles.hFileList.Value);

handles.hInfoList.String = '';

fields = fieldnames(userData.sxmFile.header);
s = cell(numel(fields),1);
for i = 1:numel(fields)
  cc = userData.sxmFile.header.(fields{i});
  if ischar(cc)
      s{i} = sprintf('%s = %s',fields{i},cc);
  else
      s{i} = sprintf('%s = %s',fields{i},mat2str(cc));
  end
end
handles.hInfoList.String = s;
%%
tagString = sprintf('%d: %s',handles.hProcessType.Value,userData.sxmFile.header.scan_file);
allFig = findobj('Tag',tagString);
if ~isempty(allFig) && ~newLoad
    figure(allFig);
    return
end

% retrive screensize
sSize = get(0,'screensize');

nCh = numel(userData.sxmFile.channels);

[nRow,nCol,~] = utility.fitFig2Screen(nCh,[380,50,sSize(3)-380,sSize(4)-200]);
figure('Position',[380,50,(sSize(4)-100)*nRow/nCol,sSize(4)-200],...
    'Tag',tagString,...
    'WindowStyle','Docked');

for iCh = nCh:-1:1
    sp = subplot(nCol,nRow,iCh);
    sp_outPos =  get(gca,'OuterPosition');
    
    p = sxm.plot.plotChannel(userData.sxmFile.channels(iCh),userData.sxmFile.header);
    colormap(sxm.op.nanonisMap(128))
    
    % plotData automatically sets
    % 'FontSize'=12  and 'OuterPosition'=[0,0,1,1]
    set(sp,'OuterPosition',sp_outPos);
    set(sp,'FontSize',9)
    
    set(p,'ButtonDownFcn',@(hObject,eventdata)plotThis(hObject,eventdata,userData.sxmFile,iCh))
end

% <<<<<<< HEAD
% function sxmFile = processData(sxmFile,handles) %Gabriele
% 
%     %disp(handles.hSValue.String)
%     %Add datas
%     fwdbwd = {'forward','backward'};
%     for i = 1:2
%         chList = utility.getChannel(sxmFile.channels,'Channel_',fwdbwd{i});
%         if chList ~ []
%             SFMChn = utility.combineChannel(sxmFile,'4 channels',chList,1/4*[1,1,1,1]);
%             INPChn = utility.combineChannel(sxmFile,'INP',chList,0.015*[1,0,-1,0]);
%             INPDenChn = utility.combineChannel(sxmFile,'INPD',chList,[1,0,1,0]);
%             INPChn.data = INPChn.data/INPDenChn.data;
%             OOPChn = utility.combineChannel(sxmFile,'OOP',chList,0.015*[0,1,0,-1]);
%             OOPDenChn = utility.combineChannel(sxmFile,'OOP',chList,[0,1,0,1]);
%             OOPChn.data = OOPChn.data/OOPDenChn.data;
%             
%             iCh = numel(sxmFile.channels);
%             
%             sxmFile.channels(iCh+1).Name = SFMChn.Name;
%             sxmFile.channels(iCh+1).Direction = SFMChn.Direction;
%             sxmFile.channels(iCh+1).data = SFMChn.data;
%             sxmFile.channels(iCh+1).Unit = SFMChn.Unit;
%             
%             sxmFile.channels(iCh+2).Name = INPChn.Name;
%             sxmFile.channels(iCh+2).Direction = INPChn.Direction;
%             sxmFile.channels(iCh+2).data = INPChn.data;
%             sxmFile.channels(iCh+2).Unit = INPChn.Unit;
%             
%             sxmFile.channels(iCh+3).Name = OOPChn.Name;
%             sxmFile.channels(iCh+3).Direction = OOPChn.Direction;
%             sxmFile.channels(iCh+3).data = OOPChn.data;
%             sxmFile.channels(iCh+3).Unit = OOPChn.Unit;
%             
%         end
%         
%     end
% 
% =======
function closeViewer(hObject,eventdata,handles)
% >>>>>>> e162fd276de6952b8c9f8f81337099bbabbd6e0f

fprintf('close all windows\n');
delete(hObject);

function plotThis(~,~,sxmFile,channel)
f = figure;
set(f,'Position',[400 100 512 512],'PaperUnits','Points','PaperSize',[512,512],'PaperPosition',[0,0,512,512]);
p = sxm.plot.plotChannel(sxmFile.channels(channel),sxmFile.header);
p.Parent.FontSize = 10;
colormap(sxm.op.nanonisMap(128))
print(f,'-clipboard','-dbitmap')
disp('copied to clipboard')
%delete(f)