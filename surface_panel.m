function pnhdl = surface_panel(pr_hdl,pst,glb_fcts)
%panel variables
cp_mod_sequence.modifstepsstr = [];
cp_mod_sequence.modifstepsval = [];

%panel functions
pnhdl.refresh               = @refresh;
pnhdl.get_act_modif         = @get_act_modif;
pnhdl.set_act_modif         = @set_act_modif;
pnhdl.get_cp_mod_sequence   = @get_cp_mod_sequence;

%panel creation and positioning
dflt_size   = [600 300];
unts        = get(pr_hdl,'Unit');
rsz_fc      = resize_factor(pst,unts,dflt_size);
panel_hdl   = uipanel('Parent',pr_hdl,'Unit',unts,'Position',pst...
    ,'Tag','surface_panel');
pnhdl.hndl  = panel_hdl;

%list of accepted modifications
uicontrol('Parent',panel_hdl,'Style','text','Unit',unts...
    ,'Position',[[5 280 100].*rsz_fc(1:3) 15]...
    ,'String','List of modifications','HorizontalAlignment','left');
lbx_modif = uicontrol('Parent',panel_hdl,'Style','listbox','Unit',unts...
    ,'Position',[5 30 180 250].*rsz_fc,'Tag','lbx_modif'...
    ,'String','No loaded file','Callback',{@lbx_modif_Callback});

%series of buttons for picture modifications managing 
bttn_updwn = updown_btts(panel_hdl,lbx_modif,@get_modif_entries...
    ,@set_modif_entries,[5 5 140 25].*rsz_fc,1:3,@glb_fcts.refresh);

%sequence of steps necessary to obtain chosen modification
uicontrol('Parent',panel_hdl,'Style','text','Unit',unts...
    ,'Position',[[190 240 180].*rsz_fc(1:3) 15]...
    ,'String','Sequence of modifications','HorizontalAlignment','left');
lbx_steps = uicontrol('Parent',panel_hdl,'Style','listbox','Unit',unts...
    ,'Position',[190 30 180 210].*rsz_fc,'Tag','lbx_steps');
  set(lbx_steps,'String','No loaded file');
  
%to copy sequence of modifications for further use with other pictures
bttn_cpsq = uicontrol('Parent',panel_hdl,'Style','pushbutton','Unit',unts...
    ,'Position',[190 5 70 25].*rsz_fc,'String','Copy sequence'...
    ,'Tag','bttn_cpsq','Callback',{@bttn_cpsq_Callback});
bttn_svp = uicontrol('Parent',panel_hdl,'Style','pushbutton','Unit',unts...
    ,'Position',[300 5 70 25].*rsz_fc,'String','Save picture'...
    ,'Tag','bttn_svp','Callback',{@bttn_svp_Callback});

%listbox to display calculated areas
uicontrol('Parent',panel_hdl,'Style','text','Unit',unts...
    ,'Position',[[375 240 180].*rsz_fc(1:3) 15]...
    ,'String','Determined areas','HorizontalAlignment','left');
lbx_area = uicontrol('Parent',panel_hdl,'Style','listbox','Unit',unts ...
    ,'Position',[375 140 220 100].*rsz_fc,'Tag','lbx_area'...
    ,'Callback',{@lbx_area_Callback},'String',{'Not any area calculated'});
uicontrol('Parent',panel_hdl,'Unit',unts,'Style','text'...
    ,'Position',[[375 125 60].*rsz_fc(1:3) 15],'String','Comment:'...
    ,'HorizontalAlignment','left');
edt_com = uicontrol('Parent',panel_hdl,'Unit',unts,'Style','edit'...
    ,'Position',[375 60 220 65].*rsz_fc,'Tag','comment'...
    ,'Callback',{@edt_com_Callback},'BackgroundColor','w'...
    ,'HorizontalAlignment','left','Max',2);
bttn_udsq = updown_btts(panel_hdl,lbx_area,@getAreaData,@setAreaData...
    ,[375 30 140 25].*rsz_fc,1:3,@show_areas,'hor');
    function AreaData = getAreaData()
        AreaData = glb_fcts.areadata('get');
    end
    function setAreaData(AreaData)
    	glb_fcts.areadata('set',AreaData);
    end

%Save calculated areas
bttn_svr = uicontrol('Parent',panel_hdl,'Style','pushbutton','Unit',unts...
    ,'Position',[525 30 70 25].*rsz_fc,'String','Save results','Tag','bttn_sv'...
    ,'Callback',{@bttn_svr_Callback});

uicontrol('Parent',panel_hdl,'Style','text','Unit',unts...
    ,'Position',[[190 280 180].*rsz_fc(1:3) 15],'String','Left picture'...
    ,'HorizontalAlignment','left');
pup_menu(1) = uicontrol('Parent',panel_hdl,'Style','popupmenu'...
    ,'Unit',unts,'Position',[190 260 180 20].*rsz_fc,'Tag','pup_menu1');
uicontrol('Parent',panel_hdl,'Style','text','Unit',unts...
    ,'Position',[[375 280 180].*rsz_fc(1:3) 15],'String','Right picture'...
    ,'HorizontalAlignment','left')
pup_menu(2) = uicontrol('Parent',panel_hdl,'Style','popupmenu'...
    ,'Unit',unts,'Position',[375 260 180 20].*rsz_fc,'Tag','pup_menu2');
  set(pup_menu,'String',[{'Original picture'} {'Highlited modification'}...
      {'Last modification'}],'Callback',{@pup_menu_Callback});
  
    function refresh()
        data = glb_fcts.get_data();
        if isempty(data)
            strcell = {'No loaded file'};
            set(lbx_modif,'String',strcell);
            set(lbx_steps,'String',strcell);
        else
            pic = glb_fcts.get_act_pict();
            strcell = cell(length(data(pic).picture),1);
            for i = 1:length(strcell)
            %creates strcell to display available modifications in
            %lbx_modif and check if 'modifstepsstr' field already exists
                strcell(i) = {[data(pic).samplename ' - ' num2str(i-1)]};
                if ~isfield(data(pic).picture(i),'modifstepsstr')
                    data(pic).picture(i).modifstepsstr = [];
                    data(pic).picture(i).modifstepsval = [];
                end
            end
            if isfield(data(pic),'modifvis')
                if isempty(data(pic).modifvis)
                    data(pic).modifvis = [2 3];
                end
                set(pup_menu(1),'Value',data(pic).modifvis(1));
                set(pup_menu(2),'Value',data(pic).modifvis(2));
            else
                %modifvis indicates which modification of the picture
                %should be blotted on the 1st and 2nd axes, 1 indicates
                %original picture, 2 - chosen modification in lbx_modif
                %3 - last modification
                data(pic).modifvis = [2 3];
                set(pup_menu(1),'Value',2);
                set(pup_menu(2),'Value',3);
            end
            glb_fcts.set_data(data);
            md = get(lbx_modif,'Value');
            if md>length(strcell)
                md = length(strcell);
                set(lbx_modif,'Value',md);
            end
            set(lbx_modif,'String',strcell);
            if isempty(data(pic).picture(md).modifstepsstr)
            %empty "modifstepsstr" field indicates original picture
                set(lbx_steps,'Value',1,'String','Original picture');
            else
            %displays all steps necessary to obtain current
            %modification of the original picture
                if get(lbx_steps,'Value')...
                        >length(data(pic).picture(md).modifstepsstr)
                    set(lbx_steps,'Value',length(...
                        data(pic).picture(md).modifstepsstr));
                end
                set(lbx_steps,'String'...
                    ,data(pic).picture(md).modifstepsstr);
            end
        end
        show_areas();
    end
    function act_modif = get_act_modif()
        %returns no of active picture modification
        act_modif = get(lbx_modif,'Value');
    end
    function entries = get_modif_entries()
        data = glb_fcts.get_data();
        if ~isempty(data)
            pic = glb_fcts.get_act_pict();
            entries = data(pic).picture;
        else
            entries = [];
        end
    end
    function set_act_modif(modif_in)
        %sets no of active picture modification
        refresh();
        if modif_in>length(get(lbx_modif,'String'))
            modif_in = length(get(lbx_modif,'String'));
        end
        set(lbx_modif,'Value',modif_in);
    end
    function set_modif_entries(entries)
        data = glb_fcts.get_data();
        if ~isempty(entries)
            pic = glb_fcts.get_act_pict();
            data(pic).picture = entries;
            glb_fcts.set_data(data);
        end
    end
    function lbx_modif_Callback(source,eventdata)
        data = glb_fcts.get_data();
        if ~isempty(data)
            pic = glb_fcts.get_act_pict();
            md = get(lbx_modif,'Value');
            if isempty(data(pic).picture(md).modifstepsstr)
            %empty "modifstepsstr" field indicates original picture
                set(lbx_steps,'Value',1,'String','Original picture');
            else
            %displays all steps necessary to obtain current
            %modification of the original picture
                if get(lbx_steps,'Value')...
                        >length(data(pic).picture(md).modifstepsstr)
                    set(lbx_steps,'Value',length(...
                        data(pic).picture(md).modifstepsstr));
                end
                set(lbx_steps,'String'...
                    ,data(pic).picture(md).modifstepsstr);
            end
        else
            set(lbx_steps,'String','No loaded file');
        end
        glb_fcts.refresh();
    end
    function bttn_cpsq_Callback(source,eventdata)
        data = glb_fcts.get_data();
        if ~isempty(data)
            pic = glb_fcts.get_act_pict();
            md = get(lbx_modif,'Value');
            if ~isempty(data(pic).picture(md).modifstepsstr)
                cp_mod_sequence.modifstepsstr ...
                    = data(pic).picture(md).modifstepsstr;
                cp_mod_sequence.modifstepsval ...
                    = data(pic).picture(md).modifstepsval;
            end
        end
        glb_fcts.refresh();
    end
    function cp_mod_sequence_out = get_cp_mod_sequence()
        cp_mod_sequence_out = cp_mod_sequence;
    end
    function bttn_svp_Callback(source,eventdata)
        data = glb_fcts.get_data();
        if ~isempty(data)
            pic = glb_fcts.get_act_pict();
            md = glb_fcts.get_act_modif();
            fmtlist = {'*.png'; '*.tiff';   '*.jpg';    '*.bmp'};
            FMT     = {'PNG',   'TIFF',     'JPEG',     'BMP'};
            [filename, path, filterindex] ...
                = uiputfile(fmtlist,'Save modified picture as'...
                ,data(pic).pathname);
            if filterindex
                imwrite(data(pic).picture(md).data,[path filename]...
                    ,FMT{filterindex});
            end
        end
    end
    function bttn_svr_Callback(source,eventdata)
        AreaData = glb_fcts.areadata('get');
        data = glb_fcts.get_data();
        if ~isempty(AreaData)
            pic = glb_fcts.get_act_pict();
            [filename, path, filterindex] ...
                = uiputfile('*.csv','Save determined areas' ...
                ,data(pic).pathname);
            if filterindex
                svTable = prepare_svTable(AreaData);
                save_results_to_csv(svTable,[path filename]);
            end
        end
    end
    function pup_menu_Callback(source,eventdata)
        pic = glb_fcts.get_act_pict();
        data = glb_fcts.get_data();
        if ~isempty(data)
            data(pic).modifvis = [get(pup_menu(1),'Value')...
                get(pup_menu(2),'Value')];
            glb_fcts.set_data(data);
        end
        glb_fcts.refresh();
    end
    function lbx_area_Callback(source,eventdata)
        AreaData = glb_fcts.areadata('get');
        if ~isempty(AreaData)
            no = get(lbx_area,'Value');
            set(edt_com,'String',AreaData(no).Comment);
        end
    end
    function edt_com_Callback(source,eventdata)
        AreaData = glb_fcts.areadata('get');
        if ~isempty(AreaData)
            no = get(lbx_area,'Value');
            AreaData(no).Comment = get(edt_com,'String');
            glb_fcts.areadata('set',AreaData);
        end
        
    end
    function show_areas()
        %works as a refresh function for lbx_area
        AreaData = glb_fcts.areadata('get');
        if ~isempty(AreaData)
            cellstr = cell(1,length(AreaData));
            for i=1:length(AreaData)
                cellstr{i} = AreaData(i).Str;
            end
            no = get(lbx_area,'Value');
            if length(AreaData)<no
                no = length(AreaData);
            end
            set(edt_com,'String',AreaData(no).Comment);
            set(lbx_area,'String',cellstr,'Value',no);
        else
            set(lbx_area,'String',{'Not any area calculated'},'Value',1);
        end
    end
end
function svTable = prepare_svTable(AreaData)
    Na = length(AreaData);
    svTable = {'Sample','Area','Unit','Method','Comment','Position'};
    tempTable = cell(Na,6);
    for i=1:Na
        Size = size(AreaData(i).Pst);
        if Size(1)==1       %filled area case
            Pst = ['(' num2str(AreaData(i).Pst(1)) ',' ...
                num2str(AreaData(i).Pst(2)) ')'];
        elseif Size(1)==2   %polygon case
            Pst = ['(' num2str(AreaData(i).Pst(1,1)) ',' ...
                num2str(AreaData(i).Pst(2,1)) ')'];
            for j=2:Size(2)
                hPst = [';(' num2str(AreaData(i).Pst(1,j)) ',' ...
                    num2str(AreaData(i).Pst(2,j)) ')'];
                Pst = [Pst hPst]; %#ok<AGROW>
            end
        end
        tempTable(i,:) = {...
            AreaData(i).samplename...
            ,num2str(AreaData(i).Area)...
            ,AreaData(i).Units...
            ,AreaData(i).Type...
            ,AreaData(i).Comment...
            ,Pst};
    end
    svTable = [svTable;tempTable];
end
function save_results_to_csv(svTable,fullpath)
%funckja zapisuj¹ca wyniki obliczeñ (svTable) do pliku (fullpath)
    Size = size(svTable);
    fid = fopen(fullpath,'wt');
    try
        for i=1:Size(1)
            for j=1:Size(2)
                if ~isempty(svTable{i,j})
                    fprintf(fid, svTable{i,j});
                end
                fprintf(fid, '\t');
            end
            fprintf(fid, '\n');
        end
    catch xxx
        disp(xxx);
    end
    fclose(fid);
end
