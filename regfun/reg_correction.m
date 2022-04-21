%         id_notreg = intersect(find(Corr<0.12), find(f_sub<RegPara.snrthreshold)); % not register images without significant signal         
        ds_val = sqrt(sum(ds_raw.^2,2));        
        id_notreg = intersect(find(Corr_raw<0.12), find(ds_val>ds_val_threshold)); % not register images without significant signal  
        if ~isempty(id_notreg)
            for j = 1:length(id_notreg)
                if id_notreg(j)<=3
                    ds_correct(id_notreg(j),:) = ds_default;
                else
                    ix1 = id_notreg(j)-3:id_notreg(j)-1;
                    ds_correct(id_notreg(j),:) = mean(ds_correct(ix1,:),1);
                end
            end
        end

