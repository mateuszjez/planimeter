function pnhdl = pnl_modif_intensity(pr_hdl,pst,glb_fcts)
dflt_size = [200 240];
unts = get(pr_hdl,'Unit');
rsz_fc = resize_factor(pst,unts,dflt_size);
panel_hdl = uipanel('Parent',pr_hdl,'Unit',unts,'Position',pst...
    ,'Tag','pnl_intensity','Visible','off');
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
set(sld,'Value',0.5,'Callback',{@sld_Callback});
set(edt,'String','1','BackgroundColor',[1 1 1],'Callback',{@edt_Callback});
chk_sync = uicontrol('Parent',panel_hdl,'Style','checkbox','Unit',unts...
    ,'Position',[10 220 70 15].*rsz_fc,'Tag','sync','Value',0 ...
    ,'String','Synchronize');
axs = axes('Parent',panel_hdl,'Unit',unts...
    ,'Position',[10 145 70 70].*rsz_fc,'Tag','int_fun');
int_fun_tab = (0:0.01:1)';
plt(1) = plot(axs,int_fun_tab,int_fun_tab,'r-'); hold on
plt(2) = plot(axs,int_fun_tab,int_fun_tab,'g-'); hold on
plt(3) = plot(axs,int_fun_tab,int_fun_tab,'b-'); hold off
set(axs,'XTickLabel',[],'YTickLabel',[],'XTick',[],'YTick',[]);
gr_rd = uibuttongroup('Parent',panel_hdl,'Unit',unts...
    ,'Position',[10 100 70 40].*rsz_fc...
    ,'SelectionChangeFcn',{@gr_rd_SelectionChangeFcn});
rdbttn(1) = uicontrol('Parent',gr_rd,'Style','Radio','Unit',unts...
    ,'Position',[5 20 60 15].*rsz_fc,'Tag','mode1','String','Mode 1');
rdbttn(2) = uicontrol('Parent',gr_rd,'Style','Radio','Unit',unts...
    ,'Position',[5 5 60 15].*rsz_fc,'Tag','mode2','String','Mode 2');
bttn_add = uicontrol('Parent',panel_hdl,'Style','pushbutton','Unit',unts...
    ,'Position',[10 10 70 70].*rsz_fc,'Tag','add','String','Accept'...
    ,'Callback',{@bttn_add_Callback});
str_mod = [];
val_mod = [];

    function sld_Callback(source,eventdata)
        if get(chk_sync,'Value')
            intchng = 10^(2*get(source,'Value')-1)*[1 1 1];
            set(sld,'Value',get(source,'Value'));
        else
            intchng = [10^(2*get(sld(1),'Value')-1)...
                10^(2*get(sld(2),'Value')-1)...
                10^(2*get(sld(3),'Value')-1)];
        end
        for i=1:3
            str = num2str(intchng(i));
            set(edt(i),'String',str);
        end
        str_mod = ['int:' num2str(intchng(1)) 'r | '...
            num2str(intchng(2)) 'g | '...
            num2str(intchng(3)) 'b | ' ...
            get(get(gr_rd,'SelectedObject'),'Tag')];
        val_mod.rgb = intchng;
        val_mod.mode = get(get(gr_rd,'SelectedObject'),'Tag');
        refresh();
    end
    function edt_Callback(source,eventdata)
        str = get(source,'String');
        Tag = get(source,'Tag');
        val = str2double(str);
        if~isnan(val)&&val>=0.1&&val<=10
            for i=1:3
                if strcmp(Tag,get(sld(i),'Tag'))
                    if get(chk_sync,'Value')
                        set(sld,'Value',0.5*(log10(val)+1));
                        set(edt,'String',num2str(val))
                    else
                        set(sld(i),'Value',0.5*(log10(val)+1));
                        set(source,'String',num2str(val));
                    end
                    break;
                end
            end
            refresh();
        else
            for i=1:3
                if strcmp(Tag,get(sld(i),'Tag'))
                    set(source,'String'...
                        ,num2str(10^(2*get(sld(i),'Value')-1)));
                    break;
                end
            end
        end
    end
    function gr_rd_SelectionChangeFcn(source,eventdata)
        refresh();
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
    function refresh()
        intchng = [10^(2*get(sld(1),'Value')-1)...
            10^(2*get(sld(2),'Value')-1)...
            10^(2*get(sld(3),'Value')-1)];
        for i=1:3
            YData = intens_corr(int_fun_tab,intchng(i),1 ...
            ,get(get(gr_rd,'SelectedObject'),'Tag') );
            set(plt(i),'YData',YData);
        end
            data = glb_fcts.get_data();
            if ~isempty(data)
                pic = glb_fcts.get_act_pict();
                md = glb_fcts.get_act_modif();
                glb_fcts.modification_preview(...
                    intens_corr(data(pic).picture(md).data,intchng...
                    ,get(chk_sync,'Value')...
                    ,get(get(gr_rd,'SelectedObject'),'Tag') ));
            end
    end
    function default_settings()
        set(sld,'Value',0.5);
        set(edt,'String','1');
        set(plt,'YData',int_fun_tab);
        str_mod = [];
        val_mod = [];
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
