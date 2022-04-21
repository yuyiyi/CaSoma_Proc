function [handles, RegPara] = callregistration_crossStack(handles)
[userview, systemview] = memory;
fprintf('Available memory')
disp(systemview.PhysicalMemory.Available)
Mem_max = systemview.PhysicalMemory.Available;
if handles.useGPU
    Mem_max = min(systemview.PhysicalMemory.Available, handles.gpudev.AvailableMemory/2);
end

for k = 1:length(handles.Datalist)
    clear RegPara
    RegPara.savepath               = handles.savepath;
    RegPara.MultiStackReg          = handles.crossSessionReg;
    RegPara.useGPU                 = handles.useGPU; % if you can use a GPU in matlab this accelerate registration approx 3 times
    RegPara.PhaseCorrelation       = 1; % set to 0 for non-whitened cross-correlation
    RegPara.SubPixel               = Inf; % 2 is alignment by 0.5 pixel, Inf is the exact number from phase correlation
    frac = k/length(handles.Datalist)*0.1;
    f_wait = waitbar(frac, sprintf('Register data %d of %d', k, length(handles.Datalist)));
    [RegPara, imageinfo, figuretitlename, continueflag, w, fext]...
        = get_imageinfo(handles, k, RegPara);
    if continueflag == 0
        continue
    end
    
    %%%%% registration initialization
    Nbatch = min(floor(Mem_max/w.bytes/4), RegPara.Imagelength(1));
    fprintf([figuretitlename, ' registration initializing \n'])
    tic
    RegPara.NimgFirstRegistration  = max(min(100, RegPara.Imagelength(1)*0.2), 1);
    RegPara.NimgFirstRegistration = min(RegPara.NimgFirstRegistration, Nbatch);
    [RegPara, ds_val_threshold] = Call_initialReg(RegPara, handles, k, fext, imageinfo, Nbatch);
    
    assignin('base', 'RegPara', RegPara);
    
    fprintf([figuretitlename, ' registration initialized '])
    toc
    frac = k/length(handles.Datalist)*0.2;
    waitbar(frac, f_wait, sprintf('Register data %d of %d', k, length(handles.Datalist)));

    %%%% registration per stack
    [dregmode, Nbatch, savegrad] = reg_dregmode(handles, RegPara, figuretitlename, w, Nbatch); 
    sample_maxL =  round(4/(w.bytes/(10^9))); % limite tif size to 4GB
    ds_raw_all = []; CorrAll = []; 
    ds_correct_all = [];
    f_snr = []; f_max = 0; f_min = 0;
    ds_default = [0, 0];
    RegTarget_tmp = RegPara.mimg;
    meanImg_PreReg = []; meanImg_PostReg = [];
    binfileid = 0;
    samplefileid = 1;
    samplelength = 0;
    indxr_base = 0;
    dreg = [];
    tic
    for k1 = 1:length(imageinfo)        
        imageinfo_sub = imfinfo(fullfile(imageinfo(k1).folder, imageinfo(k1).name));
        imglist = 1:length(imageinfo_sub);
        ix0 = 0; 
        while ix0<RegPara.Imagelength(k1)
            clear mov sampledreg    
            indxr = ix0 + (1:Nbatch);   
            indxr(indxr>length(imglist)) = [];
            frac = k/length(handles.Datalist)*indxr(end)/sum(RegPara.Imagelength)*0.8;
            waitbar(frac, f_wait, sprintf('Register data %d of %d', k, length(handles.Datalist)));

            f_sub = [];
            mov = zeros([size(RegPara.mimg), length(indxr)], RegPara.RawPrecision);
            for j = indxr(1):indxr(length(indxr))
                I1 = imread(fullfile(handles.Datalist{k}, imageinfo(k1).name), j);
                if handles.lowSNR
                    f_sub = cat(1, f_sub, quantile(single(I1(:)), 0.8));
                end
                mov(:,:,j-ix0) = I1; 
            end
            if handles.lowSNR
                if max(mov(:)) > f_max
                    f_max = max(mov(:));
                end
                if ix0 == 0
                    f_min = min(mov(:));
                elseif min(mov(:)) < f_min
                    f_min = min(mov(:));
                end
            end
            meanImg_PreReg = cat(3, meanImg_PreReg, mean(single(mov),3));
            [ds_raw, Corr_raw]  = registration_offsets_modified(mov, RegPara, 0);
            id_lowCorr = intersect(find(Corr_raw<0.1), find(max(ds_raw,[],2)>20));
            [~, igood] = sort(Corr_raw, 'descend');
            if ~isempty(id_lowCorr)
                RegPara_tmp = RegPara;
                RegPara_tmp.mimg = RegTarget_tmp;
                [ds_raw, Corr_raw]  = registration_offsets_modified(mov, RegPara_tmp, 0);
                id_lowCorr1 = intersect(find(Corr_raw<0.1), find(max(ds_raw,[],2)>20));
                [~, igood] = sort(Corr_raw, 'descend');
                if ~isempty(id_lowCorr1)
                    idsel = igood(1:min(100, ceil(length(igood)/2)));
                    idsel = setdiff(idsel, id_lowCorr1);
                    dregtmp = register_movie(mov(:,:,idsel), RegPara, ds_raw(idsel,:));
                    RegTarget_tmp = mean(dregtmp, 3);
                    RegPara_tmp.mimg = RegTarget_tmp;
                    [ds_raw, Corr_raw]  = registration_offsets_modified(mov, RegPara_tmp, 0);
                end
            end
            CorrAll = cat(1,CorrAll, Corr_raw);
            ds_raw_all = cat(1,ds_raw_all, ds_raw);      
            ds_correct = ds_raw;

    %         if handles.lowSNR
    %             f_snr = cat(1, f_snr, f_sub);
    %             RegPara.snrthreshold = quantile(single(mov(:)),0.8);
    %         end
    %         if  handles.lowSNR || min(Corr_raw)<0.15
    %             registration_largemotion
    %         end

            ds_default = ds_correct(end,:);
            ds_correct_all = cat(1, ds_correct_all, ds_correct); 

            if dregmode > 0
                dregbatch = zeros([size(RegPara.mimg), length(indxr)], RegPara.RawPrecision);
                dregbatch = register_movie(mov, RegPara, ds_correct);
                meanImg_PostReg = cat(3, meanImg_PostReg, mean(single(dregbatch),3));
                if handles.savesubsampletif == 1
                    sampledreg = dregbatch(:,:,1:savegrad:length(indxr)); 
                    [samplelength, samplefileid] = ...
                        savesubtif(handles, sampledreg, RegPara, samplefileid, ...
                        sample_maxL, samplelength);
                end
                if  handles.savetoTif == 1
                    saveDregdata(dregbatch, indxr, RegPara, handles, imageinfo_sub, fext, k, indxr_base)
                elseif  handles.savetoBin == 1                
                    dreg = cat(3, dreg, dregbatch);               
                    if size(dreg, 3) >= floor(handles.binMaxsize/(w.bytes/(10^9))) ...
                            || indxr_base + ix0 + Nbatch >= sum(RegPara.Imagelength)
                        binfileid = binfileid+1;
                        RegPara.binfilelength(binfileid) = size(dreg, 3);
                        RegPara.savename{binfileid} = sprintf([RegPara.savenamebase,'_%03d.bin'], binfileid);
                        nametmp = fullfile(handles.savepath, RegPara.savename{binfileid}); 
                        fid = fopen(nametmp, 'w');
                        fwrite(fid, dreg, RegPara.RawPrecision);
                        fclose(fid);
                        dreg = [];
                    end
                end
                RegTarget_tmp = mean(dregbatch(:,:,igood(1:ceil(length(igood)/2))), 3);
            elseif dregmode==0
                sampledreg = register_movie(mov(:,:,1:savegrad:end), RegPara, ds_correct(1:savegrad:end,:));  
                [samplelength, samplefileid] = ...
                    savesubtif(handles, sampledreg, RegPara, samplefileid, ...
                    sample_maxL, samplelength);       
                meanImg_PostReg = cat(3, meanImg_PostReg, mean(single(sampledreg),3));
                RegTarget_tmp = mean(sampledreg, 3);
            end        
            fprintf([figuretitlename, ' registration progressed ',...
                num2str(round(ix0/sum(RegPara.Imagelength)*100)), '%%', ' ']);
            toc
            clear dregbatch mov
            ix0 = ix0 + Nbatch;
        end

        indxr_base = indxr_base + RegPara.Imagelength(k1);
    end
        fprintf([figuretitlename, ' registration progressed ','100%% ']);
        toc        
        RegPara.ds_raw_all = ds_raw_all;
        RegPara.dsall = ds_correct_all;
        RegPara.CorrAll = CorrAll;
        RegPara.f_signal = f_snr;
        RegPara.f_max = f_max;
        RegPara.f_min = f_min;
        
        frac = k/length(handles.Datalist);
        waitbar(frac, f_wait, sprintf('Register data %d of %d', k, length(handles.Datalist)));

        meanImg_PreReg = mean(meanImg_PreReg,3);
        meanImg_PreReg = meanImg_PreReg-min(meanImg_PreReg(:));
        meanImg_PreReg = uint8(ceil(meanImg_PreReg/max(meanImg_PreReg(:))*255));
        meanImg_PostReg = mean(meanImg_PostReg,3);
        meanImg_PostReg = meanImg_PostReg-min(meanImg_PostReg(:));
        meanImg_PostReg = uint8(ceil(meanImg_PostReg/max(meanImg_PostReg(:))*255));
        RegPara.meanImg_PreReg = meanImg_PreReg;
        RegPara.meanImg_PostReg = meanImg_PostReg;

    assignin('base', 'RegPara', RegPara)
    %%%%%%% show results %%%%%%%%%%%
    if handles.showresult
        showregresult(RegPara, figuretitlename)    
    end
    
    %%%%%% save registration results %%%%%%
    save(fullfile(RegPara.savepath, [RegPara.savenamebase,'Parameter.mat']), 'RegPara');  
    fprintf([figuretitlename, ' registration results saved ']);
    toc
    close(f_wait)
    delete(f_wait)
end

