function varargout = NeuronImgProc_batch(varargin)
% Last Modified by GUIDE v2.5 27-Feb-2022 17:24:59
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @NeuronImgProc_batch_OpeningFcn, ...
                   'gui_OutputFcn',  @NeuronImgProc_batch_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before NeuronImgProc_batch is made visible.
function NeuronImgProc_batch_OpeningFcn(hObject, eventdata, handles, varargin)
addpath(genpath('regfun'))
addpath(genpath('KyoDetection'))
addpath(genpath('Suite2pDetection'))
scrsz = get(groot,'ScreenSize');
handles.scrsz = scrsz;
set( hObject, 'Units', 'pixels' );
position = get( hObject, 'Position' );
position(1) = 50;
position(2) = scrsz(4)-50;
set( hObject, 'Position', position );
[~, Mver] = version;    
handles.Mver = Mver;
handles.datatype = 1;
handles.Datalist = '';
handles.savepath = '';
if gpuDeviceCount>0
    handles.useGPU = 1;
    set(handles.ind_GPUNum, 'String', sprintf('%d GPU found', gpuDeviceCount))
    gpudev = gpuDevice(1);
    reset(gpudev)
    set(handles.useGPU_check,'Enable','on')
    set(handles.useGPU_check, 'Value',  handles.useGPU)
    fprintf('GPU Available memory')
    disp(gpudev.AvailableMemory)
    handles.gpudev.AvailableMemory = gpudev.AvailableMemory;
else
    handles.useGPU = 0;
    set(handles.ind_GPUNum, 'String', 'No GPU found')
    set(handles.useGPU_check,'Enable','off')
end

handles.saveSVDflag = 1;
handles.defaultPara = setdefaultpara;
handles = cellprocess_batch_init(handles, 1);
handles.output = hObject;
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = NeuronImgProc_batch_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

%%%%%%%%%%%%%%%%%%% set up file directory %%%%%%%%%%%%%%%%%%%%%%%%%%%%
function moviedata_check_Callback(hObject, eventdata, handles)
if get(hObject, 'Value') == 1
    handles.datatype = 1;
    set(handles.imageseq_check, 'Value', 0)
    set(handles.binfile_check, 'Value', 0)
end
handles.filepath = pwd;
handles.filename = '';
guidata(hObject, handles);
function imageseq_check_Callback(hObject, eventdata, handles)
if get(hObject, 'Value') == 1
    handles.datatype = 2;
    set(handles.moviedata_check, 'Value', 0)
    set(handles.binfile_check, 'Value', 0)
end
handles.filepath = pwd;
handles.filename = '';
guidata(hObject, handles);
% --- Executes on button press in binfile_check.
function binfile_check_Callback(hObject, eventdata, handles)
if get(hObject, 'Value') == 1
    handles.datatype = 3;
    set(handles.moviedata_check, 'Value', 0)
    set(handles.imageseq_check, 'Value', 0)
end
handles.filepath = pwd;
handles.filename = '';
guidata(hObject, handles);

function checkSaveSVD_Callback(hObject, eventdata, handles)
handles.saveSVDflag = get(hObject, 'Value');
guidata(hObject, handles);

%%%%%%%%%%%%%%%%% set parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function useGPU_check_Callback(hObject, eventdata, handles)
handles.useGPU = get(hObject, 'Value');
guidata(hObject, handles);
function minsizeIn_Callback(hObject, eventdata, handles)
handles.minarea = str2double(get(hObject, 'String'));
guidata(hObject, handles);
function SegPara1In_Callback(hObject, eventdata, handles)
handles.SegPara(1) = str2double(get(hObject, 'String'));
guidata(hObject, handles);
function SegPara2In_Callback(hObject, eventdata, handles)
handles.SegPara(2) = str2double(get(hObject, 'String'));
guidata(hObject, handles);
function SegPara3In_Callback(hObject, eventdata, handles)
handles.SegPara(3) = str2double(get(hObject, 'String'));
guidata(hObject, handles);
function subtractpara1In_Callback(hObject, eventdata, handles)
handles.subtractpara(1) = str2double(get(hObject, 'String'));
guidata(hObject, handles);
function subtractpara2In_Callback(hObject, eventdata, handles)
handles.subtractpara(2) = str2double(get(hObject, 'String'));
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%% Callbacks %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function browsesavepath_Callback(hObject, eventdata, handles)
savepath = uigetdir;
if savepath~=0
    handles.savepath = savepath;
    set(handles.edittext_savepath, 'String', handles.savepath);
end
guidata(hObject, handles);

function savenametable_CellEditCallback(hObject, eventdata, handles)
newname = get(hObject, 'Data');
for k = 1:length(newname)
    [~, filename, fext] = fileparts(newname{k});
    if ~strcmp(fext, '.mat')
        newname{k} = [filename, '.mat'];
    end
end
handles.savenamelist = newname(:,1)';
set(handles.savenametable, 'Data', handles.savenamelist')
guidata(hObject, handles);

function deletefiles_Callback(hObject, eventdata, handles)
if handles.savingflag == 1 
    msgbox('Batch processing inprogress')
else
    handles.Datalist = '';
    handles = cellprocess_batch_init(handles, 1);
end
guidata(hObject, handles);

function browse_Callback(hObject, eventdata, handles)
if handles.savingflag == 1 
    msgbox('Batch processing in progress', 'Warning','warn');
else
    handles = cellprocess_batch_init(handles, 1);
    [handles, ListOfImageNames] = listselectedfiles(handles);
    ListOfImageNames
    if ~isempty(handles.Datalist)        
        filetmp = split(handles.filepath, '\');
        if strcmp(filetmp{end-1}, 'processed') || strcmp(filetmp{end}, 'processed')
            handles.savepath = handles.filepath(1:end-10);
        else
            handles.savepath = handles.filepath;
        end
        set(handles.edittext_savepath, 'String', handles.savepath);
        set(handles.filelistbox,'Enable','on')
        set(handles.filelistbox, 'string', ListOfImageNames);
        set(handles.savenametable, 'Enable', 'on')
        set(handles.ind_fileNum, 'String',  length(handles.Datalist))
        for k = 1:length(handles.Datalist)
            [imagefolder, imagefilename, fext] = fileparts(handles.Datalist{k});
            if strcmp(fext, '.mat')
                savename = [regexprep(imagefilename(1:end-13),' ', '_'), '_trace.mat'];
            else
                savename = [regexprep(imagefilename,' ', '_'), '_trace.mat'];
            end
            handles.savenamelist{k} = savename;
        end
        set(handles.savenametable, 'Data', handles.savenamelist')
    end
end
assignin('base', 'handles', handles)
guidata(hObject, handles);

function Push_runbatch_Callback(hObject, eventdata, handles)
if ~isempty(handles.Datalist) && handles.savingflag == 0 
    handles.savingflag = 1;
    N = length(handles.Datalist);
    for k = 1:N
         %%%% load movie k for processing
        BatchCall_NeuronDetection(handles, k)
    end
    msgbox(sprintf('%d data were processed and saved in %s', N, handles.savepath), ...
        'Batch processing finished')
    handles.savingflag = 0;
elseif isempty(handles.datalist)
    msgbox('Please load in data for batch processing')
elseif handles.savingflag == 0
    msgbox('Batch processing inprogress')
end
handles.savingflag = 0;

function FinishProg_Callback(hObject, eventdata, handles)
if handles.savingflag == 1 
    msgbox('Batch processing inprogress')
else
    closereq();
end


%%%%%%%%%%%%%%%%%%%%%%% initialization %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function filelistbox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function SaveNamelistbox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edittext_maskpath_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function ind_GPUNum_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edittext_savepath_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function ind_fileNum_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function filelistbox_Callback(hObject, eventdata, handles)
tmp = get(hObject, 'Value');
function minsizeIn_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function SegPara1In_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function SegPara2In_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function SegPara3In_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function subtractpara1In_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function subtractpara2In_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
