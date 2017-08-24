function pnhdl = pnl_modif_contrast(pr_hdl,pst,glb_fcts)
dflt_size = [200 240];
unts = get(pr_hdl,'Unit');
rsz_fc = resize_factor(pst,unts,dflt_size);
panel_hdl = uipanel('Parent',pr_hdl,'Unit',unts,'Position',pst...
    ,'Tag','pnl_contrast','Visible','off');
pnhdl.hndl = panel_hdl;
pnhdl.default_settings = @default_settings;
uicontrol('Parent',panel_hdl,'Style','text','String','red'...
    ,'Position',[80 220 40 15].*rsz_fc);
sld(1) = uicontrol('Parent',panel_hdl,'Style','slider','Unit',unts...
    ,'Position',[90 25 20 195].*rsz_fc,'Tag','red');
edt(1) = uicontrol('Parent',panel_hdl,'Style','edit','Unit',unts...
    ,'Position',[85 5 30 20].*rsz_fc,'Tag','red');
uicontrol('Parent',panel_hdl,'Style','text','String','green'...
    ,'Position',[120 220 40 15].*rsz_fc);
sld(2) = uicontrol('Parent',panel_hdl,'Style','slider','Unit',unts...
    ,'Position',[130 25 20 195].*rsz_fc,'Tag','green');
edt(2) = uicontrol('Parent',panel_hdl,'Style','edit','Unit',unts...
    ,'Position',[125 5 30 20].*rsz_fc,'Tag','green');
uicontrol('Parent',panel_hdl,'Style','text','String','blue'...
    ,'Position',[165 220 30 15].*rsz_fc);
sld(3) = uicontrol('Parent',panel_hdl,'Style','slider','Unit',unts...
    ,'Position',[170 25 20 195].*rsz_fc,'Tag','blue');
edt(3) = uicontrol('Parent',panel_hdl,'Style','edit','Unit',unts...
    ,'Position',[165 5 30 20].*rsz_fc,'Tag','blue');
set(sld,'Value',0,'Callback',{@sld_Callback});
set(edt,'String','0','BackgroundColor',[1 1 1],'Callback',{@edt_Callback});
chk_sync = uicontrol('Parent',panel_hdl,'Style','checkbox','Unit',unts...
    ,'Position',[10 220 70 15].*rsz_fc,'Tag','sync','Value',0 ...
    ,'String','Synchronize');
bttn_add = uicontrol('Parent',panel_hdl,'Style','pushbutton','Unit',unts...
    ,'Position',[10 10 70 70].*rsz_fc,'Tag','add','String','Accept'...
    ,'Callback',{@bttn_add_Callback});
str_mod = [];
val_mod = [];
    function sld_Callback(source,eventdata)
        if get(chk_sync,'Value')
            conchng = get(source,'Value')*[1 1 1];
            set(sld,'Value',get(source,'Value'));
        else
            conchng = [get(sld(1),'Value') get(sld(2),'Value')...
                get(sld(3),'Value')];
        end
        for i=1:3
            str = num2str(conchng(i)*100);
            set(edt(i),'String',str);
        end
        str_mod = ['con:' num2str(conchng(1)*100) '%r | '...
            num2str(conchng(2)*100) '%g | '...
            num2str(conchng(3)*100) '%b'];
        val_mod = conchng;
        data = glb_fcts.get_data();
        if ~isempty(data)
            pic = glb_fcts.get_act_pict();
            md = glb_fcts.get_act_modif();
            glb_fcts.modification_preview(...
                contrast_corr(data(pic).picture(md).data,conchng));
        end
    end
    function edt_Callback(source,eventdata)
        str = get(source,'String');
        Tag = get(source,'Tag');
        val = str2double(str);
        if~isnan(val)&&val>=0&&val<=100
            for i=1:3
                if strcmp(Tag,get(sld(i),'Tag'))
                    if get(chk_sync,'Value')
                        set(sld,'Value',0.01*val);
                        set(edt,'String',num2str(val));
                    else
                        set(sld(i),'Value',0.01*val);
                        set(source,'String',num2str(val));
                    end
                    break;
                end
            end
        else
            for i=1:3
                if strcmp(Tag,get(sld(i),'Tag'))
                    set(source,'String',num2str(get(sld(i),'Value')*100));
                    break;
                end
            end
        end
    end
    function bttn_add_Callback(source,eventdata)
        data = glb_fcts.get_data();
        pic = glb_fcts.get_act_pict();
        md = glb_fcts.get_act_modif();
        if ~isempty(str_mod)&&~isempty(data)
            mdnew = length(data(pic).picture) + 1;
            data(pic).picture(mdnew).data = glb_fcts.get_preview_data();
            data(pic).picture(mdnew).modifstepsstr...
                = [data(pic).picture(md).modifstepsstr {str_mod}];
            data(pic).picture(mdnew).modifstepsval...
                = [data(pic).picture(md).modifstepsval {val_mod}];
            glb_fcts.set_data(data);
            default_settings();
            glb_fcts.set_act_modif(mdnew);
            glb_fcts.refresh();
        end
    end
    function default_settings()
        set(sld,'Value',0);
        set(edt,'String','0');
        str_mod = [];
        val_mod = [];
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