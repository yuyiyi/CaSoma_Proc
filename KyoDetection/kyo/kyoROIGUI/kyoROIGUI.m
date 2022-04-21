function varargout = kyoROIGUI(varargin)


% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @kyoROIGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @kyoROIGUI_OutputFcn, ...
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


% --- Executes just before kyoROIGUI is made visible.
function kyoROIGUI_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for kyoROIGUI
handles.output = hObject;

% set up
handles.rawF=varargin{1};
handles.referenceImage=max(handles.rawF,[],3);
sz=size(handles.referenceImage);
handles.ROImasks=zeros([sz 1]);
handles.ROImasksToggles=zeros(1,1);
if size(varargin,2)>1
    handles.ROImasks=varargin{2};
    handles.currentROIindex = size(handles.ROImasks,3);
end

handles.roiXspan=25;
handles.roiYspan=12;
handles.maxInd=100; % Maximum value in the color axis of the reference image
UpdateAxes(hObject, handles);
set(handles.storeRoi,'Enable','off');
set(handles.cancel,'Enable','off');

handles.semiautoROIs=0;
handles.deleteROIsOn=0;

guidata(hObject, handles);



% --- Outputs from this function are returned to the command line.
function varargout = kyoROIGUI_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;


% --- Executes on button press in semiautoRoi.
function semiautoRoi_Callback(hObject, eventdata, handles)
h_im = findobj('Tag','ROIviewWindow');
currentState=get(h_im,'HitTest');
if strcmp(currentState,'on')
    set(h_im,'HitTest','off');
    handles.semiautoROIs=1;
    set(handles.storeRoi,'Enable','off');
    set(handles.newRoi,'Enable','off');
    set(handles.deleteROIs,'Enable','off');
elseif strcmp(currentState,'off')
    set(h_im,'HitTest','on');
    handles.semiautoROIs=0;
    set(handles.newRoi,'Enable','on');
    set(handles.deleteROIs,'Enable','on');
end
guidata(hObject, handles);


% --- Executes on button press in cancel.
function cancel_Callback(hObject, eventdata, handles)
sz=size(handles.ROImasks);
if handles.semiautoROIs
    if size(handles.ROImasks,3)==1
        handles.ROImasks=zeros([sz 1]);
        set(handles.cancel,'Enable','off');
    else
        r=handles.currentROIindex;
        handles.ROImasks(:,:,r)=[];
        handles.currentROIindex=handles.currentROIindex-1;
    end
    UpdateAxes(hObject, handles);
    h_im = findobj('Tag','ROIviewWindow');
    set(h_im,'HitTest','off')
else
    delete(handles.currentROI);
    set(handles.newRoi,'Enable','on');
    set(handles.storeRoi,'Enable','off');
    set(handles.cancel,'Enable','off');
    set(handles.semiautoRoi,'Enable','on');
end
guidata(hObject, handles);


% --- Executes on button press in newRoi.
function newRoi_Callback(hObject, eventdata, handles)
set(handles.semiautoRoi,'Enable','off');
set(handles.newRoi,'Enable','off');
handles.currentROI = imfreehand;
if size(handles.ROImasks,3)==1 && sum(sum(handles.ROImasks(:,:,1)))==0
    handles.currentROIindex = 1;
else
    handles.currentROIindex = size(handles.ROImasks,3)+1;
end
set(handles.storeRoi,'Enable','on');
set(handles.cancel,'Enable','on');
guidata(hObject, handles);


% --- Executes on button press in storeRoi.
function storeRoi_Callback(hObject, eventdata, handles)
h_im = findobj('Tag','ROIviewWindow');
handles.currentMask = createMask(handles.currentROI,h_im);
handles.ROImasks(:,:,handles.currentROIindex)=handles.currentMask;
delete(handles.currentROI);
UpdateAxes(hObject, handles);
set(handles.storeRoi,'Enable','off');
set(handles.cancel,'Enable','off');
set(handles.newRoi,'Enable','on');
set(handles.semiautoRoi,'Enable','on');
guidata(hObject, handles);


% --- Executes on button press in exportRois.
function exportRois_Callback(hObject, eventdata, handles)
assignin('base','ROIsFromGUI',handles.ROImasks);
guidata(hObject, handles);

function UpdateAxes(hObject, handles)

delete(findobj('Tag','ROIviewWindow'));

% Draw the reference image
a = handles.referenceImage;
a=double(a);
handles.referenceImageRGB = ind2rgb(round(size(gray(256),1)*(a/handles.maxInd)),gray(256));

roiColor=ones([size(a) 3]);
roi3=roiColor;
cm=colorcube(64);
alpha=0.5;
if sum(sum(handles.ROImasks))~=0
    for r=1:size(handles.ROImasks,3)
        roi=handles.ROImasks(:,:,r);
        roi3(:,:,1)=roi;
        roi3(:,:,2)=roi;
        roi3(:,:,3)=roi;
        r2=r-(floor((r-1)/64)*64);
        roiColor(:,:,1)=roi.*cm(r2,1);
        roiColor(:,:,2)=roi.*cm(r2,2);
        roiColor(:,:,3)=roi.*cm(r2,3);
        handles.referenceImageRGB(roi3==1)=((1-alpha).*handles.referenceImageRGB(roi3==1))+(alpha.*roiColor(roi3==1));
    end
end
handles.referenceImageH = imshow(handles.referenceImageRGB,'Border','tight','InitialMagnification','fit');
set(gca,'DataAspectRatio',[1 size(a,1)/size(a,2) 1])
hold on
if sum(sum(handles.ROImasks))~=0
    for r=1:size(handles.ROImasks,3)
        roi=handles.ROImasks(:,:,r);
        stats = regionprops(roi, 'Centroid');
        numLabel=sprintf('%i',r);
        h=text(stats.Centroid(1)-2,stats.Centroid(2),numLabel,'Color',[0 0 0]);
        set(h,'HitTest','off');
    end
end
set(handles.referenceImageH,'Tag','ROIviewWindow')

guidata(hObject, handles);


% --- Executes on mouse press over figure background.
function figure1_ButtonDownFcn(hObject, eventdata, handles)
cpData = get(gca, 'CurrentPoint');
cp = round(cpData(2,1:2));
sz=size(handles.ROImasks);
if (min(cp) > 0)&&(cp(1)<=sz(2))&&(cp(2)<=sz(1))
    
    % semi-auto ROI selection
    if handles.semiautoROIs
        % extract the region around the clicked point and analyze it
        xstart=max(1,cp(1)-handles.roiXspan);
        xend=min(sz(2),cp(1)+handles.roiXspan);
        ystart=max(1,cp(2)-handles.roiYspan);
        yend=min(sz(1),cp(2)+handles.roiYspan);
        localarea=handles.referenceImage(ystart:yend,xstart:xend);
        handles.currentMask = zeros(sz(1),sz(2));
        handles.currentMask(ystart:yend,xstart:xend) = kyoGetCellMask(localarea);
        % take the output and send it to a new ROI
        if size(handles.ROImasks,3)==1 && sum(sum(handles.ROImasks(:,:,1)))==0
            handles.currentROIindex = 1;
        else
            handles.currentROIindex = size(handles.ROImasks,3)+1;
        end
        handles.ROImasks(:,:,handles.currentROIindex)=handles.currentMask;
        handles.ROImasksToggles(handles.currentROIindex)=1;
        
        UpdateAxes(hObject, handles);
        set(handles.cancel,'Enable','on');
        h_im = findobj('Tag','ROIviewWindow');
        set(h_im,'HitTest','off')
    end
    
    if handles.deleteROIsOn
        % run through all of ROIs and see if the clikced point is inside
        % any of them. If so, then delete that ROI and redraw the image.
        % If not, then don't do anything.
       
        for r=1:sz(3)
            if (handles.ROImasks(cp(2),cp(1),r)>0) % hit
                handles.ROImasks(:,:,r)=[]; % delete this roi
                UpdateAxes(hObject, handles);
                set(handles.cancel,'Enable','on');
                h_im = findobj('Tag','ROIviewWindow');
                set(h_im,'HitTest','off')
                break
            end
        end
    end
    
end
guidata(hObject, handles);


% --- Executes on mouse press over axes background.
function axes1_ButtonDownFcn(hObject, eventdata, handles)


% --- Executes on button press in deleteROIs.
function deleteROIs_Callback(hObject, eventdata, handles)
h_im = findobj('Tag','ROIviewWindow');
currentState=get(h_im,'HitTest');

if handles.deleteROIsOn==0
    handles.deleteROIsOn=1;
    set(handles.storeRoi,'Enable','off');
    set(handles.newRoi,'Enable','off');
    set(handles.semiautoRoi,'Enable','off');
    set(handles.cancel,'Enable','off');
    if strcmp(currentState,'on')
        set(h_im,'HitTest','off');
    end
else
    handles.deleteROIsOn=0;
    set(handles.newRoi,'Enable','on');
    set(handles.semiautoRoi,'Enable','on');
    set(handles.cancel,'Enable','off');
    if strcmp(currentState,'off')
        set(h_im,'HitTest','on');
    end
end    
guidata(hObject, handles);
