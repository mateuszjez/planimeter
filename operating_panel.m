function pnhdl = operating_panel(pr_hdl,pst,glb_fcts)
%panel variables
timetest = clock;   %variable to double click control
currdir  = pwd;      %current directory

%panel functions
pnhdl.refresh = @refresh;

%panel creation and positioning
dflt_size   = [600 300];
unts        = get(pr_hdl,'Unit');
rsz_fc      = resize_factor(pst,unts,dflt_size);
panel_hdl   = uipanel('Parent',pr_hdl,'Unit',unts,'Position',pst...
    ,'Tag','operating_panel');
pnhdl.hndl  = panel_hdl;

%context menu for listbox dasplaying loaded pictures
lbx_pict_cntxm = uicontextmenu();
    uimenu(lbx_pict_cntxm,'Label','Rename active sample name'...
        ,'Callback',{@uimenu_Callback});
%listbox dasplaying loaded pictures
lbx_pict = uicontrol('Parent',panel_hdl,'Style','listbox','Unit',unts...
    ,'Position',[5 30 180 265].*rsz_fc,'Tag','lbx_pict'...
    ,'String','No loaded file','Callback',{@lbx_pict_Callback}...
    ,'UIContextMenu',lbx_pict_cntxm);
%functions for gettin and setting the order number of chosen picture
pnhdl.get_act_pict = @()get(lbx_pict,'Value');
pnhdl.set_act_pict = @(val)set(lbx_pict,'Value',val);

%button loading new pictures
bttn_ld = uicontrol('Parent',panel_hdl,'Style','pushbutton','Unit',unts...
    ,'Position',[5 5 30 25].*rsz_fc,'String','Load','Tag','tbl_list'...
    ,'Callback',{@bttn_ld_Callback},'UserData',1);
%button to operates on loaded pictures
bttn_updwn = updown_btts(panel_hdl,lbx_pict,glb_fcts.get_data...
    ,glb_fcts.set_data,[40 5 145 25].*rsz_fc,1:3,@glb_fcts.refresh);

%panels used for calibration and polygon drawing
pnl_calib = calibration_panels(panel_hdl,[190 30 200 265].*rsz_fc,glb_fcts);
%functions passed from pnl_calib
pnhdl.calc_filled       = pnl_calib.calc_filled;

%panels used for modification of pictures
pnl_modif = modification_panels(panel_hdl,[395 30 200 265].*rsz_fc,glb_fcts);
%functions passed from pnl_modif
pnhdl.fill_in_preview   = pnl_modif.fill_in_preview;
pnhdl.color_action      = pnl_modif.color_action;

%modify picure by applying the copied sequence
bttn_cap = uicontrol('Parent',panel_hdl,'Style','pushbutton','Unit',unts...
    ,'Position',[190 5 50 25].*rsz_fc,'String','Capture'...
    ,'Tag','bttn_cap','Callback',{@bttn_cap_Callback});

%modify picure by applying the copied sequence
bttn_apsq = uicontrol('Parent',panel_hdl,'Style','pushbutton','Unit',unts...
    ,'Position',[395 5 90 25].*rsz_fc,'String','Apply copied sequence'...
    ,'Tag','bttn_apsq','Callback',{@bttn_apsq_Callback},'Enable','off');

%check the copied sequence in a dialog box
bttn_chsq = uicontrol('Parent',panel_hdl,'Style','pushbutton','Unit',unts...
    ,'Position',[490 5 60 25].*rsz_fc,'String','Check sequence'...
    ,'Tag','bttn_chsq','Callback',{@bttn_chsq_Callback});

    function refresh()
        data = glb_fcts.get_data();
        if isempty(data)
            set(lbx_pict,'String','No loaded file');
        else
            strcell = cell(length(data),1);
            for i = 1:length(data)
                strcell(i) = {[data(i).filename ' | ' data(i).samplename]};
            end
            set(lbx_pict,'String',strcell);
        end
        mod_sequence = glb_fcts.get_cp_mod_sequence();
        if ~isempty(mod_sequence.modifstepsval)
            set(bttn_apsq,'Enable','on');
        end
        pnl_calib.refresh();
        pnl_modif.refresh();
    end
    function lbx_pict_Callback(source,eventdata)
        if etime(clock,timetest)>0.25 ...
                || get(source,'UserData')~=get(source,'Value')
            glb_fcts.refresh();
            set(source,'UserData',get(source,'Value'));
            timetest = clock;
        else %two hits on the same entry in time < 0.25s is double click
            rename_sample();
        end
    end
    function rename_sample()
    %dialog box for renaming the sample name
        data = glb_fcts.get_data();
        if ~isempty(data)
            pic = glb_fcts.get_act_pict();
            prompt = {'Change the name of the sample:'};
            name = data(pic).samplename; 
            numlines = 1;
            defaultanswer = {data(pic).samplename};
            options.Resize='on';
            options.WindowStyle='normal';
            options.Interpreter='none';
            glb_fcts.dis_or_enable('disable');
            answer...
                = inputdlg(prompt,name,numlines,defaultanswer,options);
            glb_fcts.dis_or_enable('enable');
            if ~isempty(answer)
                data(pic).samplename = answer{1};
                glb_fcts.set_data(data);
                glb_fcts.refresh();
            end
        end
    end
    function uimenu_Callback(source,eventdata)
        rename_sample();
    end
    function bttn_ld_Callback(source,eventdata)
    %loads new pictures in multiple choice mode
        [filenames,pathname] = uigetfile(...
            [{'*.png;*.jpg;*.tif'};{'*.png'};{'*.jpg'};{'*.mat'}]...
            ,'Pick Another File',currdir,'MultiSelect','on');
        if pathname~=0
            currdir = pathname;
        end
        if ischar(filenames)||iscell(filenames)
            if iscell(filenames)
                Nf = length(filenames);%no of files to be loaded
            else
                Nf = 1;
                filenames = {filenames};
            end
            for i=1:Nf
                filename = filenames{i};
                if strcmp(filename((end-3):(end)),'.png')
                    ui8png = importdata([pathname filename]);
                    if isstruct(ui8png)
                        if isfield(ui8png,'cdata')
                            ui8image = ui8png.cdata;
                        else
                            return;
                        end
                    elseif isnumeric(ui8png)
                        ui8image = ui8png;
                    end
                    clear('ui8png');
                elseif strcmp(filename((end-3):(end)),'.jpg')||...
                        strcmp(filename((end-3):(end)),'.JPG')
                    ui8image = importdata([pathname filename]);
                elseif strcmp(filename((end-3):(end)),'.tif')||...
                        strcmp(filename((end-4):(end)),'.tiff')
                    [ui8 map] = imread([pathname filename]);
                    if length(size(ui8))==2
                        ui8image = im2uint8(ind2rgb(ui8,map));
                    elseif length(size(ui8))==3
                        ui8image = ui8;
                    end
                end
                tempdata(i).filename     = filename; %#ok<AGROW>
                tempdata(i).samplename   = filename; %#ok<AGROW>
                tempdata(i).pathname     = pathname; %#ok<AGROW>
                tempdata(i).picture.data = im2double(ui8image);%#ok<AGROW>
            end
            data = glb_fcts.get_data();
            if isempty(data)
                data = tempdata;
            else
                %some fields in data structure may be added during the work
                %with this application, thus additional fields must be
                %taken into account and added in new data
                tempdata = adjustfields(data(1),tempdata);
                data     = [data tempdata];
            end
            glb_fcts.set_data(data);
            refresh();
            set(lbx_pict,'Value',length(data));
            glb_fcts.refresh();
        end
    end
    function bttn_cap_Callback(source,eventdata)
        capture_image(glb_fcts);
    end
    function bttn_apsq_Callback(source,eventdata)
        %applies sequence of preciously copied sequence of modification and
        %modifies active picture according to this sequence
        apply_sequence(glb_fcts);
    end
    function bttn_chsq_Callback(source,eventdata)
        %displays currently coppied sequence of modification
        show_sequence(glb_fcts.get_cp_mod_sequence());
    end
end
