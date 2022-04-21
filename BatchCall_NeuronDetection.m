function BatchCall_NeuronDetection(handles, k)

handles = cellprocess_batch_init(handles, 0);
[imagefolder, imagefilename, fext] = fileparts(handles.Datalist{k});
handles.filepath = imagefolder;
handles.filename = [imagefilename, fext];
handles.fext = fext;

%% load registration parameters if exist
RegPara = []; 
if strcmp(fext, '.mat')
    variableinfo = who('-file', handles.Datalist{k});
    if ismember('RegPara', variableinfo)
        load(handles.Datalist{k}, 'RegPara')        
        handles.RegPara = RegPara;
        handles.Regfile = handles.filename;
    end
else
    filenamesub = split(imagefilename,'_');
    if length(filenamesub)>1
        Regfilename = '';
        for i = 1:length(filenamesub)-1
            Regfilename = strcat(Regfilename, filenamesub{i}, '_');
        end
        Regfile = dir(fullfile(handles.filepath, [Regfilename, '*.mat']));
        if ~isempty(Regfile)
            for i = 1:length(Regfile)
            variableinfo = who('-file', fullfile(Regfile(i).folder, Regfile(i).name));
            if ismember('RegPara', variableinfo)
                handles.Regfile = Regfile(i).name;
                load(fullfile(Regfile(i).folder, Regfile(i).name), 'RegPara')        
                handles.RegPara = RegPara;
            end
            end
        end
    end
end
      
%% load movie
f_wait = waitbar(0, sprintf('Loading Data %d', k), ...
    'Name', 'Loading Data');
if strcmp(fext, '.mat') 
    [loadmovieflag, Mem_max, w, handles] = loadbin_init(handles);
    handles = Call_loadbin(loadmovieflag, Mem_max, w, f_wait, handles);
else
    [loadmovieflag, I1, Mem_max, w, handles] = loadmovie_init(handles);
    handles = Call_loadmovieV2(loadmovieflag, I1, Mem_max, w, f_wait, handles);
end
handles.savename = handles.savenamelist{k};
% assignin('base', 'movF', handles.movF)
% assignin('base', 'mov', handles.mov)

%% Neuron detection based on kurtosis and suite2p
%     g_wait = waitbar(0.5,sprintf('Auto feature detection data %d', k), 'Name', 'Processing Data');
    TraceROIPara = handles.defaultPara;
    TraceROIPara.useGPU = handles.useGPU; % if you can use a GPU in matlab this accelerate registration approx 3 times
    TraceROIPara.resultsavepath = handles.savepath;
    TraceROIPara.minarea = handles.minarea; % minimal cell size
    TraceROIPara.maxarea = TraceROIPara.minarea*20; % maximal cell size
    TraceROIPara.subtractPara = handles.subtractpara;
    TraceROIPara.KurtosisMapSegPara = handles.SegPara;
%     TraceROIPara
    save(fullfile(handles.savepath, handles.savename), 'TraceROIPara', '-v7.3');
    
    Img = handles.im_norm;
    [Ly, Lx] = size(Img);
    displayit = 0;         
    roi_kurt = [];
    %%%% processing large field imaging 
    if handles.size(1)*handles.size(2)<=600^2
        %%%%% kurtosis detection
        tic
        [movKurt_ori, ~, roi_kurt] =...
            batchKurt_analysis(handles.movF,...
            TraceROIPara.minarea, displayit,...
            TraceROIPara.KurtosisMapSegPara);
        fprintf('done kurtosis feature detection: ')
        toc
%         assignin('base', 'roi_kurt', roi_kurt)
        save(fullfile(handles.savepath, handles.savename), 'movKurt_ori', '-append');

        %%%%% suite2p detection
        clear U; clear Sv; clear V
        tic
        fprintf('start suite2p feature detection: ')
        [TraceROIPara, U, Sv] = get_svdForROI_v3(TraceROIPara, handles.mov);
        [TraceROIPara, stat, res] = fast_cluster_neuropil_v3(TraceROIPara, handles.im_norm, U, Sv);
        fprintf('done suite2p feature detection: ')
        toc
        U = single(U);
        Sv = single(Sv);
        save(fullfile(handles.savepath, [handles.savename(1:end-10), '_SVDtraces.mat']),'U', 'Sv', 'res','stat', '-v7.3');
        clear U Sv         
    else
        handles.movF = reshape(handles.movF, [], size(handles.movF,3));
        handles.mov = reshape(handles.mov, [], size(handles.mov,3));
        roi_kurt = zeros(Ly, Lx);
        movKurt_ori = zeros(Ly, Lx);
        iclust = zeros(Ly*Lx,1);
        clust0 = max(iclust(:));
        M_all = zeros(1,Ly*Lx);
        lambdaAll = zeros(1,Ly*Lx);        
        r1 = max(1, round(Ly/500));
        c1 = max(1, round(Lx/500));
        [xx, yy] = meshgrid((1:Lx)/(Lx/c1), (1:Ly)/(Ly/r1));
        I_mask = ceil(xx) + (ceil(yy)-1)*c1;        
        for i = 1:max(I_mask(:))
            mask0 = zeros(size(I_mask));
            mask0(I_mask==i) = 1;
            if max(mask0(:))==0
                continue                
            end
            [a,b] = find(mask0==1);
            x1 = unique(a);
            y1 = unique(b);

            %%%%% kurtosis detection
            movFtmp = reshape(handles.movF(I_mask==i, :), length(x1), length(y1), size(handles.movF, 2));
            tic
            [movKurt_sub, ~, roi_kurtsub] =...
                batchKurt_analysis(movFtmp,...
                TraceROIPara.minarea, displayit,...
                TraceROIPara.KurtosisMapSegPara);
            fprintf('done kurtosis feature detection: ')
            toc
            movKurt_ori(mask0==1) = movKurt_sub;
            roi_kurt(mask0==1) = roi_kurtsub;            
            clear movFtmp
            
            movtmp = reshape(handles.mov(I_mask==i, :), length(x1), length(y1), size(handles.mov, 2));
            im_normtmp = reshape(handles.im_norm(I_mask==i), [length(x1), length(y1)]);
            %%%%% suite2p detection
            tic
            fprintf('start suite2p feature detection: ')
            [TraceROIPara, U, Sv] = get_svdForROI_v3(TraceROIPara, movtmp);
            [TraceROIPara, restmp] = fast_cluster_neuropil_masked(TraceROIPara, im_normtmp, U, Sv);
            iclust(I_mask==i) = restmp.iclust + clust0;
            clust0 = max(iclust(:));
            M_all(I_mask==i) = restmp.M;
            lambdaAll(I_mask==i) = restmp.lambda;
            fprintf('done suite2p feature detection: ')
            toc
            clear U Sv movtmp stattmp restmp           
        end
        res.iclust = iclust;
        res.M = M_all;
        res.lambda = lambdaAll;
        res.Ly = Ly;
        res.Lx = Lx;
        stat = get_stat(res);        
%         assignin('base', 'roi_kurt', roi_kurt)
%         assignin('base', 'I_mask', I_mask)
        save(fullfile(handles.savepath, handles.savename), 'movKurt_ori', '-append');
        save(fullfile(handles.savepath, [handles.savename(1:end-10), '_SVDtraces.mat']), 'res','stat', '-v7.3');        
        handles.movF = reshape(handles.movF, Ly, Lx, size(handles.movF,2));
        handles.mov = reshape(handles.mov, Ly, Lx, size(handles.mov,2));
    end    
    % find ROIs
    region = findROI(stat, roi_kurt, handles.movF, handles.RegPara, TraceROIPara, res);
    assignin('base', 'region', region)
    save(fullfile(handles.savepath, handles.savename), 'region', 'TraceROIPara', '-append');
    handles.roi = region;

    figure, showROI(Ly, Lx, region, Img);
    
%% process the whole movie and extract calcium traces
f_wait = waitbar(0, sprintf('Saving Data %d', k), 'Name', 'Saving Data');
if strcmp(fext, '.mat')
    Save_fullData_bin(handles, f_wait, TraceROIPara)
else
    tic
    [tcraw, tc, tcraw_pca, tc_pcasub] = kyoGetTCs_sutract_pca_v2(handles.mov, region, TraceROIPara.subtractPara);
    toc 
    Traces_full.tcraw = tcraw;
    Traces_full.tc = tc;
    Traces_full.tcraw_pca = tcraw_pca;
    Traces_full.tc_pcasub = tc_pcasub;
    handles.Traces_full = Traces_full;
    handles.TraceROIPara = TraceROIPara;    
    Save_fullData(handles, f_wait, TraceROIPara)    
end
% close(g_wait)
% delete(g_wait)

