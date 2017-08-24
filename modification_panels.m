function pnhdl = modification_panels(pr_hdl,pst,glb_fcts)
dflt_size = [200 265];
unts = get(pr_hdl,'Unit');
rsz_fc = resize_factor(pst,unts,dflt_size);
pnl_main = uipanel('Parent',pr_hdl,'Unit',unts,'Position',pst...
    ,'Tag','pnl_modif');
pnhdl.hndl = pnl_main;
pnhdl.refresh = @refresh;
pnhdl.default_settings = @default_settings;
mod_pst = [0 0 200 240].*rsz_fc;
modif_col = pnl_modif_color(pnl_main,mod_pst,glb_fcts);
modif_con = pnl_modif_contrast(pnl_main,mod_pst,glb_fcts);
modif_int = pnl_modif_intensity(pnl_main,mod_pst,glb_fcts);
modif_drawfill = pnl_modif_drawfill(pnl_main,mod_pst,glb_fcts,@chkbx_Callback);
pnhdl.draw_in_preview = modif_drawfill.draw_in_preview;
pnhdl.fill_in_preview = modif_drawfill.fill_in_preview;
pnhdl.color_action = @color_action;
chkbx = modif_drawfill.chkbx;
pnl_modif(1) = modif_col.hndl;
pnl_modif(2) = modif_con.hndl;
pnl_modif(3) = modif_int.hndl;
pnl_modif(4) = modif_drawfill.hndl;
set(pnl_modif(1),'Visible','on');
bttn_hdl = panel_choice_bttns(pnl_main,pnl_modif,[0 240 200 24].*rsz_fc...
    ,[{'Color'} {'Contrast'} {'Intensity'} {'Draw/Fill'}]);
    function refresh()
        drawing_mode = glb_fcts.drawing_mode('get','preview');
        set(chkbx,'Value',0);
        for i=1:4
            if strcmp(drawing_mode,get(chkbx(i),'Tag'))
                set(chkbx(i),'Value',1);
                break;
            end
        end
        modif_drawfill.refresh();
    end
    function default_settings()
        modif_col.default_settings();
        modif_con.default_settings(); 
        modif_int.default_settings();
    end
    function chkbx_Callback(source,eventdata)
        Tag = get(source,'Tag');
        if length(Tag)>=5
            if strcmp(Tag(1:5),'probe')
                for i=1:length(chkbx)
                    if strcmp(get(chkbx(i),'Tag'),'drawline')...
                            &&get(chkbx(i),'Value')
                        set(source,'Tag','probedrawline');
                    elseif strcmp(get(chkbx(i),'Tag'),'imfill')...
                            &&get(chkbx(i),'Value')
                        set(source,'Tag','probeimfill');
                    end
                end
            end
        end
        set(chkbx,'Value',0);
        set(source,'Value',1);
        glb_fcts.drawing_mode(get(source,'Tag'),'preview');
    end
    function varargout = color_action(action,drawingmode,varargin)
        varargout = {};
        if strcmp(action,'get')
            varargout{1} = modif_drawfill.color_action('get');
        elseif strcmp(action,'set')
            modif_drawfill.color_action('set',varargin{1});
        end
    end
end
