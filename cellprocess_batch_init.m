function handles = cellprocess_batch_init(handles, batchini)
close(figure(7))  % cross-session registration
if batchini
    % default parameters
    handles.minarea = handles.defaultPara.minarea;
    set(handles.minsizeIn, 'String', num2str(handles.minarea))
    handles.SegPara = handles.defaultPara.KurtosisMapSegPara;
    set(handles.SegPara1In, 'String', num2str(handles.SegPara(1)))
    set(handles.SegPara2In, 'String', num2str(handles.SegPara(2)))
    set(handles.SegPara3In, 'String', num2str(handles.SegPara(3)))
    handles.subtractpara = handles.defaultPara.subtractPara;
    set(handles.subtractpara1In, 'String', num2str(handles.subtractpara(1)))
    set(handles.subtractpara2In, 'String', num2str(handles.subtractpara(2)))

    % reset data and saving directory
    handles.savingflag = 0;
    handles.savenamelist = '';
    handles.filepath = '';
    set(handles.savenametable, 'Data', handles.savenamelist')
    set(handles.savenametable, 'Enable', 'off')    
    set(handles.edittext_savepath, 'String',  handles.savepath)
    handles.currentImagelist = '';
    if handles.datatype == 1
        set(handles.moviedata_check, 'Value', 1)
        set(handles.imageseq_check, 'Value', 0)
        set(handles.binfile_check, 'Value', 0)
    elseif handles.datatype == 2
        set(handles.moviedata_check, 'Value', 0)
        set(handles.imageseq_check, 'Value', 1)
        set(handles.binfile_check, 'Value', 0)
    elseif handles.datatype == 3
        set(handles.moviedata_check, 'Value', 0)
        set(handles.imageseq_check, 'Value', 0)
        set(handles.binfile_check, 'Value', 1)
    end
    set(handles.filelistbox,'Enable','off')
    set(handles.filelistbox, 'string', handles.Datalist);
    set(handles.ind_fileNum, 'String',  length(handles.Datalist))
    
    set(handles.checkSaveSVD, 'Value', handles.saveSVDflag)
end

handles.savename = '';
handles.filename = '';
handles.fext = '';
handles.Regfile = '';

handles.movieinputgrad = 1;
handles.imagelength = [];
handles.imageinfo = [];

handles.im_norm = [];
handles.size = [];
handles.movF = [];
handles.mov = [];
handles.roi = [];
handles.Traces_full = [];
handles.TraceROIPara = [];

handles.BitsPerSample = [];
handles.bytesPerImage = [];
handles.RawPrecision = '';
handles.WorkingPrecision = '';
handles.movieframeID = [];

handles.RegPara = [];

