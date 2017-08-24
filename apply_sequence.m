function apply_sequence(glb_fcts)
    data = glb_fcts.get_data();
    if ~isempty(data)
        pic = glb_fcts.get_act_pict();
        md = glb_fcts.get_act_modif();
        data_temp = data(pic).picture(md).data;
        mod_sequence = glb_fcts.get_cp_mod_sequence();
        Nsq = length(mod_sequence.modifstepsstr);
        for sq=1:Nsq
            str = mod_sequence.modifstepsstr{sq};
            val = mod_sequence.modifstepsval{sq};
            switch str(1:3)
                case 'rgb'
                    data_temp(:,:,1) = data_temp(:,:,1)*val(1);
                    data_temp(:,:,2) = data_temp(:,:,2)*val(2);
                    data_temp(:,:,3) = data_temp(:,:,3)*val(3);
                case 'rev'
                    data_temp = 1 - data_temp;
                case 'con'
                    data_temp = contrast_corr(data_temp,val);
                case 'int'
                    data_temp = intens_corr(data_temp,val.rgb,0,val.mode);
            end
        end
        mdnew = length(data(pic).picture) + 1;
        data(pic).picture(mdnew).data = data_temp;
        data(pic).picture(mdnew).modifstepsstr = [mod_sequence.modifstepsstr...
            data(pic).picture(md).modifstepsstr];
        data(pic).picture(mdnew).modifstepsval = [mod_sequence.modifstepsval...
            data(pic).picture(md).modifstepsval];
        glb_fcts.set_data(data);
        glb_fcts.refresh();
        glb_fcts.set_act_modif(mdnew);
        
    end
end

function img = contrast_corr(img,col_corr)
    %image should be in double
    for i=1:3
        if col_corr(i)>0
            col_ch = img(:,:,i);
            col_m = mean(mean(col_ch));
            col_ch(col_ch>=col_m) = col_ch(col_ch>=col_m) ...
                + (1 - col_ch(col_ch>=col_m))*col_corr(i);
            col_ch(col_ch<col_m) = col_ch(col_ch<col_m) ...
                + (0 - col_ch(col_ch<col_m))*col_corr(i);
            img(:,:,i) = col_ch;
        end
    end
end
function img = intens_corr(img,col_corr,synch,mode)
    %image should be in double
    if strcmp(mode,'mode1')
        funct1 = @(x,a)x.^(1/a);
        funct2 = @(x,a)1-(1-x).^a;
    else
        funct1 = @(x,a)1-(1-x).^a;
        funct2 = @(x,a)x.^(1/a);
    end
    if synch
        if col_corr(1)<1; img = funct1(img,col_corr(1)); end
        if col_corr(1)>1; img = funct2(img,col_corr(1)); end
    else
        for i=1:3
            if col_corr(i)<1; img(:,:,i) = funct1(img(:,:,i),col_corr(i)); end
            if col_corr(i)>1; img(:,:,i) = funct2(img(:,:,i),col_corr(i)); end
        end
    end
end
