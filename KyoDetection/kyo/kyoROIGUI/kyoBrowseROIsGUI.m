function varargout = kyoBrowseROIsGUI(varargin)
% KYOBROWSEROISGUI MATLAB code for kyoBrowseROIsGUI.fig
%      KYOBROWSEROISGUI, by itself, creates a new KYOBROWSEROISGUI or raises the existing
%      singleton*.
%
%      H = KYOBROWSEROISGUI returns the handle to a new KYOBROWSEROISGUI or the handle to
%      the existing singleton*.
%
%      KYOBROWSEROISGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in KYOBROWSEROISGUI.M with the given input arguments.
%
%      KYOBROWSEROISGUI('Property','Value',...) creates a new KYOBROWSEROISGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before kyoBrowseROIsGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to kyoBrowseROIsGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help kyoBrowseROIsGUI

% Last Modified by GUIDE v2.5 20-Nov-2013 00:02:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @kyoBrowseROIsGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @kyoBrowseROIsGUI_OutputFcn, ...
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


% --- Executes just before kyoBrowseROIsGUI is made visible.
function kyoBrowseROIsGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to kyoBrowseROIsGUI (see VARARGIN)

% Choose default command line output for kyoBrowseROIsGUI
handles.output = hObject;

handles.rois=varargin{1};
handles.ca_raw=varargin{2};

numRois = size(handles.rois,3);
handles.currentRoi=1;

if size(varargin,2)>2
    handles.keepToggle=varargin{3};
else
    handles.keepToggle=ones(1,numRois);
end

set(findobj('Tag','sliderROI'),'Min',1);
set(findobj('Tag','sliderROI'),'Max',numRois);
set(findobj('Tag','sliderROI'),'Val',handles.currentRoi);
set(findobj('Tag','sliderROI'),'SliderStep',[1/numRois 0.1/numRois]);
set(handles.roiIndicator, 'String', sprintf('%i',handles.currentRoi))
set(handles.checkbox1,'Value', handles.keepToggle(handles.currentRoi));

UpdateAxes(hObject, handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes kyoBrowseROIsGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = kyoBrowseROIsGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function sliderROI_Callback(hObject, eventdata, handles)
% hObject    handle to sliderROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.currentRoi=round(get(hObject,'Value'));
guidata(hObject, handles);
set(handles.roiIndicator, 'String', sprintf('%i',handles.currentRoi))
set(handles.checkbox1,'Value', handles.keepToggle(handles.currentRoi));
UpdateAxes(hObject,handles)
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function sliderROI_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1
handles.keepToggle(handles.currentRoi)=get(hObject,'Value');
guidata(hObject, handles);


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
assignin('base','ROI_keepToggles',handles.keepToggle);

function UpdateAxes(hObject, handles)

delete(findobj('Tag','ROIviewWindow'));

% Get basics
raw = handles.ca_raw;
roi = handles.rois(:,:,handles.currentRoi);

% Get the pixel time courses
%rois_inds = find(roi);
%mov = reshape(raw,[size(raw,1)*size(raw,2),size(raw,3)]);
tc = squeeze(sum(sum(bsxfun(@times,roi,raw),1),2))./sum(roi(:));

% Show ROI
imshow(roi,[0 1],'Parent',handles.axes1,'Border','tight','InitialMagnification','fit');

% Show time course
plot(handles.axes2,tc,'k');

guidata(hObject, handles);


