function pnhdl = calibration_panels(pr_hdl,pst,glb_fcts)
dflt_size = [200 265];
unts = get(pr_hdl,'Unit');
rsz_fc = resize_factor(pst,unts,dflt_size);
pnl_main = uipanel('Parent',pr_hdl,'Unit',unts,'Position',pst...
    ,'Tag','pnl_calib');
pnhdl.hndl = pnl_main;
pnhdl.refresh = @refresh;
cal_pst = [0 0 200 240].*rsz_fc;
pnl_calib1 = calib_panel(pnl_main,cal_pst,glb_fcts,@chkbx_Callback);
pnl_calib(1) = pnl_calib1.hndl;
pnl_area = area_panel(pnl_main,cal_pst,glb_fcts,@chkbx_Callback);
pnl_calib(2) = pnl_area.hndl;
pnhdl.calc_filled = pnl_area.calc_filled;
chkbx = [pnl_calib1.chkbx pnl_area.chkbx];
bttn_hdl = panel_choice_bttns(pnl_main,pnl_calib,[0 240 200 24].*rsz_fc...
    ,[{'Calibration'},{'Area'}],[2 1]);
    function refresh()
        drawing_mode = glb_fcts.drawing_mode('get');
        set(chkbx,'Value',0);
        for i=1:4
            if strcmp(drawing_mode,get(chkbx(i),'Tag'))
                set(chkbx(i),'Value',1);
                break;
            end
        end
        pnl_calib1.refresh();
        pnl_area.refresh();
    end
    function chkbx_Callback(source,eventdata)
        set(chkbx,'Value',0);
        set(source,'Value',1);
        glb_fcts.drawing_mode(get(source,'Tag'));%setting of the drawing mode
    end
end
function pnhdl = calib_panel(pr_hdl,pst,glb_fcts,chkbx_function)
dflt_size = [200 240];
unts = get(pr_hdl,'Unit');
rsz_fc = resize_factor(pst,unts,dflt_size);
panel_hdl = uipanel('Parent',pr_hdl,'Unit',unts,'Position',pst...
    ,'Tag','pnl_calibration','Visible','off');
pnhdl.hndl = panel_hdl;
pnhdl.refresh = @refresh;
chkbx(1) = uicontrol('Parent',panel_hdl,'Unit',unts,'Style','checkbox'...
    ,'Position',[10 220 150 15].*rsz_fc,'String','Zoom mode'...
    ,'Tag','zoom_points','Callback',{@chkbx_Callback},'Value',1);
uicontrol('Parent',panel_hdl,'Unit',unts,'Style','text'...
    ,'Position',[[25 200 40].*rsz_fc(1:3) 15],'String','Width:');
uicontrol('Parent',panel_hdl,'Unit',unts,'Style','text'...
    ,'Position',[[75 200 40].*rsz_fc(1:3) 15],'String','Height:');
uicontrol('Parent',panel_hdl,'Unit',unts,'Style','text'...
    ,'Position',[[125 200 50].*rsz_fc(1:3) 15],'String','Units:');
edt(1) = uicontrol('Parent',panel_hdl,'Unit',unts,'Style','edit'...
    ,'Position',[25 180 40 20].*rsz_fc,'Tag','width');
edt(2) = uicontrol('Parent',panel_hdl,'Unit',unts,'Style','edit'...
    ,'Position',[75 180 40 20].*rsz_fc,'Tag','height');
pupm_unt(1) = uicontrol('Parent',panel_hdl,'Unit',unts,'Style','popupmenu'...
    ,'Position',[125 180 50 20].*rsz_fc,'Tag','unt1','String'...
    ,{'mm','cm','m'});
uicontrol('Parent',panel_hdl,'Unit',unts,'Style','text'...
    ,'Position',[[5 160 45].*rsz_fc(1:3) 15],'String','Total area:');
uicontrol('Parent',panel_hdl,'Unit',unts,'Style','text'...
    ,'Position',[[60 160 40].*rsz_fc(1:3) 15],'String','T. width:');
uicontrol('Parent',panel_hdl,'Unit',unts,'Style','text'...
    ,'Position',[[105 160 40].*rsz_fc(1:3) 15],'String','T. height:');
edt_tarea(1) = uicontrol('Parent',panel_hdl,'Unit',unts,'Style','edit'...
    ,'Position',[5 140 45 20].*rsz_fc,'Tag','edt_tarea1');
edt_twidth(1) = uicontrol('Parent',panel_hdl,'Unit',unts,'Style','edit'...
    ,'Position',[60 140 40 20].*rsz_fc,'Tag','edt_twidtha1');
edt_theight(1) = uicontrol('Parent',panel_hdl,'Unit',unts,'Style','edit'...
    ,'Position',[105 140 40 20].*rsz_fc,'Tag','edt_theighta1');
bttn(1) = uicontrol('Parent',panel_hdl,'Unit',unts,'Style','pushbutton'...
    ,'Position',[150 140 40 30].*rsz_fc,'String','Apply','Tag','apply1');

chkbx(2) = uicontrol('Parent',panel_hdl,'Unit',unts,'Style','checkbox'...
    ,'Position',[10 115 150 15].*rsz_fc,'String','Calibrate lengths'...
    ,'Tag','calib_points','Callback',{@chkbx_Callback});
uicontrol('Parent',panel_hdl,'Unit',unts,'Style','text'...
    ,'Position',[[10 95 55].*rsz_fc(1:3) 15],'String','L 1 (blue)');
uicontrol('Parent',panel_hdl,'Unit',unts,'Style','text'...
    ,'Position',[[70 95 55].*rsz_fc(1:3) 15],'String','L 2 (green)');
uicontrol('Parent',panel_hdl,'Unit',unts,'Style','text'...
    ,'Position',[[135 95 50].*rsz_fc(1:3) 15],'String','Units:');
edt(3) = uicontrol('Parent',panel_hdl,'Unit',unts,'Style','edit'...
    ,'Position',[10 75 55 20].*rsz_fc,'Tag','L1');
edt(4) = uicontrol('Parent',panel_hdl,'Unit',unts,'Style','edit'...
    ,'Position',[70 75 55 20].*rsz_fc,'Tag','L2');
    set(edt,'BackgroundColor','w');
pupm_unt(2) = uicontrol('Parent',panel_hdl,'Unit',unts,'Style','popupmenu'...
    ,'Position',[135 75 50 20].*rsz_fc,'Tag','unt2','String'...
    ,{'mm','cm','m'});
uicontrol('Parent',panel_hdl,'Unit',unts,'Style','text'...
    ,'Position',[[5 55 45].*rsz_fc(1:3) 15],'String','Total area:');
uicontrol('Parent',panel_hdl,'Unit',unts,'Style','text'...
    ,'Position',[[60 55 40].*rsz_fc(1:3) 15],'String','T. width:');
uicontrol('Parent',panel_hdl,'Unit',unts,'Style','text'...
    ,'Position',[[105 55 40].*rsz_fc(1:3) 15],'String','T. height:');
edt_tarea(2) = uicontrol('Parent',panel_hdl,'Unit',unts,'Style','edit'...
    ,'Position',[5 35 45 20].*rsz_fc,'Tag','edt_tarea2');
edt_twidth(2) = uicontrol('Parent',panel_hdl,'Unit',unts,'Style','edit'...
    ,'Position',[60 35 40 20].*rsz_fc,'Tag','edt_twidtha2');
edt_theight(2) = uicontrol('Parent',panel_hdl,'Unit',unts,'Style','edit'...
    ,'Position',[105 35 40 20].*rsz_fc,'Tag','edt_theighta2');
bttn(2) = uicontrol('Parent',panel_hdl,'Unit',unts,'Style','pushbutton'...
    ,'Position',[150 35 40 30].*rsz_fc,'String','Apply','Tag','apply2');
txt_area = uicontrol('Parent',panel_hdl,'Unit',unts,'Style','text'...
    ,'Position',[10 5 180 15].*rsz_fc,'String'...
    ,'Total area applied: 0 mm2','Tag','txt_area');
set(edt,'Callback',{@edt_Callback},'String','1','UserData',1);
pnhdl.chkbx = chkbx;
set(pupm_unt,'Callback',{@pupm_unt_Callback});
set(edt_tarea,'Callback',{@edt_tarea_Callback},'String','1','UserData',1);
set(bttn,'Callback',{@bttn_Callback});
    function refresh()
    end
    function chkbx_Callback(source,eventdata)
        chkbx_function(source,eventdata);
    end
    function edt_Callback(source,eventdata)
        Tag = get(source,'Tag');
        if any(strcmp(Tag,{'width','height','L1','L2'}))
            val = str2double(get(source,'String'));
            if ~isnan(val) && val>0
                set(source,'String',num2str(val),'UserData',val);
            else
                set(source,'String',num2str(get(source,'UserData')));
            end
        end
        data = glb_fcts.get_data();
        if ~isempty(data)
            pic = glb_fcts.get_act_pict();
            Size = size(data(pic).picture(1).data);
            if any(strcmp(Tag,{'width','height','unt1'}))
                XYLimSize = diff(data(pic).XYLim'); %#ok<UDIM>
                val = get(edt(1),'UserData')*get(edt(2),'UserData');
                val = val*prod(Size(1:2))/prod(XYLimSize);
                set(edt_tarea(1),'String',num2str(val),'UserData',val);
                TSize = [get(edt(1),'UserData') get(edt(2),'UserData')];
                TSize = TSize.*(Size(2:-1:1)./XYLimSize);
                set(edt_twidth(1),'String',num2str(TSize(1)),'UserData',TSize(1));
                set(edt_theight(1),'String',num2str(TSize(2)),'UserData',TSize(2));
            elseif any(strcmp(Tag,{'L1','L2','unt2'}))
                dist1 = get(edt(3),'UserData');
                dist2 = get(edt(4),'UserData');
                X1Data = [];
                Y1Data = [];
                X2Data = [];
                Y2Data = [];
                if isfield(data(pic),'CalibData')
                    if isfield(data(pic).CalibData,'calib1')
                        X1Data = data(pic).CalibData.calib1.XData;
                        Y1Data = data(pic).CalibData.calib1.YData;
                    end
                    if isfield(data(pic).CalibData,'calib2')
                        X2Data = data(pic).CalibData.calib2.XData;
                        Y2Data = data(pic).CalibData.calib2.YData;
                    end
                end
                if length(X1Data)==2 && length(Y1Data)==2 ...
                        &&length(X2Data)==2 && length(Y2Data)==2
                    val = calib_tot_area(dist1,dist2,X1Data,Y1Data...
                        ,X2Data,Y2Data,Size);
                    set(edt_tarea(2),'String',num2str(val(1)),'UserData',val(1));
                    set(edt_twidth(2),'String',num2str(val(2)),'UserData',val(2));
                    set(edt_theight(2),'String',num2str(val(3)),'UserData',val(3));
                end
            end
        end
    end
    function pupm_unt_Callback(source,eventdata)%do implementacji
        edt_Callback(source,eventdata);
    end
    function edt_tarea_Callback(source,eventdata)
%         Tag = get(source,'Tag');
        val = str2double(get(source,'String'));
        if ~isnan(val) && val>0
            set(source,'String',num2str(val),'UserData',val);
        else
            set(source,'String',num2str(get(source,'UserData')));
        end
    end
    function bttn_Callback(source,eventdata)
        data = glb_fcts.get_data();
        if~isempty(data)
            pic = glb_fcts.get_act_pict();
            Tag = get(source,'Tag');
            if strcmp(Tag,'apply1')
                strcell = get(pupm_unt(1),'String');
                val = get(pupm_unt(1),'Value');
                set(txt_area,'String',['Total area applied: '...
                    get(edt_tarea(1),'String') ' ' strcell{val} '2']);
                data(pic).TotalArea = get(edt_tarea(1),'UserData');
                data(pic).TotXSize = get(edt_twidth(1),'UserData');
                data(pic).TotYSize = get(edt_theight(1),'UserData');
            elseif strcmp(Tag,'apply2')
                strcell = get(pupm_unt(2),'String');
                val = get(pupm_unt(2),'Value');
                set(txt_area,'String',['Total area applied: '...
                    get(edt_tarea(2),'String') ' ' strcell{val} '2']);
                data(pic).TotalArea = get(edt_tarea(2),'UserData');
                data(pic).TotXSize = get(edt_twidth(2),'UserData');
                data(pic).TotYSize = get(edt_theight(2),'UserData');
            end
            data(pic).Units = [strcell{val} '2'];
            glb_fcts.set_data(data);
        end
    end
end
function A=calib_tot_area(dist1,dist2,X1Data,Y1Data,X2Data,Y2Data,Size_img)
    val_dist1 = dist1^2;
    val_dist2 = dist2^2;
    vect1 = [diff(X1Data) diff(Y1Data)].^2;
    vect2 = [diff(X2Data) diff(Y2Data)].^2;
    M = [vect1;vect2];
    Mx = [[val_dist1;val_dist2] M(:,2)];
    My = [M(:,1) [val_dist1;val_dist2]];
    detM = det(M);
    detMx = det(Mx);
    detMy = det(My);
    x1_fact = sqrt(abs(detMx/detM));
    y2_fact = sqrt(abs(detMy/detM));
    A = [x1_fact*Size_img(2)*y2_fact*Size_img(1)...
        x1_fact*Size_img(2) y2_fact*Size_img(1)];
    
%     set(tot_area2,'String',num2str(f_tot_area));
end

function pnhdl = polygon_panel(pr_hdl,pst,glb_fcts,chkbx_function)
dflt_size = [200 240];
unts = get(pr_hdl,'Unit');
rsz_fc = resize_factor(pst,unts,dflt_size);
panel_hdl = uipanel('Parent',pr_hdl,'Unit',unts,'Position',pst...
    ,'Tag','pnl_polygon','Visible','on');
pnhdl.hndl = panel_hdl;
pnhdl.refresh = @refresh;
chkbx = uicontrol('Parent',panel_hdl,'Unit',unts,'Style','checkbox'...
    ,'Position',[10 220 150 15].*rsz_fc,'String','Polygon'...
    ,'Tag','polygon','Callback',{@chkbx_Callback},'Value',0);
pnhdl.chkbx = chkbx;
txt_area = uicontrol('Parent',panel_hdl,'Unit',unts,'Style','text'...
    ,'Position',[10 195 180 20].*rsz_fc,'Tag','area'...
    ,'String','Polygon area: 0 mm2');
uicontrol('Parent',panel_hdl,'Unit',unts,'Style','text'...
    ,'Position',[[10 180 50].*rsz_fc(1:3) 15],'String','Comment:'...
    ,'HorizontalAlignment','left');
edt_com = uicontrol('Parent',panel_hdl,'Unit',unts,'Style','edit'...
    ,'Position',[10 80 180 100].*rsz_fc,'Tag','comment'...
    ,'Callback',{@edt_com_Callback},'BackgroundColor','w'...
    ,'HorizontalAlignment','left','Max',2);
bttn = uicontrol('Parent',panel_hdl,'Unit',unts,'Style','pushbutton'...
    ,'Position',[10 10 70 60].*rsz_fc,'Tag','add','String','Add area'...
    ,'Callback',{@bttn_Callback});
    function chkbx_Callback(source,eventdata)
        chkbx_function(source,eventdata);
    end
    function refresh()
        data = glb_fcts.get_data();
        if~isempty(data)
            pic = glb_fcts.get_act_pict();
            if isfield(data(pic),'PolygonData')...
                    && isfield(data(pic),'TotalArea')
                if ~isempty(data(pic).TotalArea)
                    data(pic).PolygonData.PolyArea...
                        = data(pic).PolygonData.RelPolyArea...
                        *data(pic).TotalArea;
                    set(txt_area,'String'...
                        ,['Polygon area: '...
                        num2str(data(pic).PolygonData.PolyArea)...
                        ' ' data(pic).Units]);
                    glb_fcts.set_data(data);
                end
            end
        end
    end
    function bttn_Callback(source,eventdata)
        data = glb_fcts.get_data();
        if ~isempty(data)
            pic = glb_fcts.get_act_pict();
            if isfield(data(pic),'PolygonData')...
                    && isfield(data(pic),'TotalArea')
                if ~isempty(data(pic).TotalArea)
                    if data(pic).PolygonData.PolyArea>0
                        PolygonData.samplename = data(pic).samplename;
                        PolygonData.Area = data(pic).PolygonData.PolyArea;
                        PolygonData.Units = data(pic).Units;
                        PolygonData.Type = 'polygon';
                        PolygonData.Comment = get(edt_com,'String');
                        PolygonData.Pst = [data(pic).PolygonData.XData...
                            ;data(pic).PolygonData.YData];
                        PolygonData.Str ...
                            = ['Polygon area: '...
                            num2str(PolygonData.Area) ' '...
                            data(pic).Units ', '...
                            data(pic).samplename '/' data(pic).filename];
                        AreaData = glb_fcts.areadata('get');
                        AreaData = [AreaData PolygonData];
                        glb_fcts.areadata('set',AreaData);
                        %resetting of the buffer
                        data(pic).PolygonData.PolyArea = 0;
                        data(pic).PolygonData.XData = [];
                        data(pic).PolygonData.YData = [];
                        data(pic).PolygonData.RelPolyArea = 0;
                        glb_fcts.set_data(data);
                        glb_fcts.refresh();
                    end
                end
            end
        end
    end
end
% try in new version of Matlab
% pnl_clb_grp = uitabgroup('Parent',pr_hdl,'Position',pst.*rsz_fc);
% pnl_calib(1) = uitab('Parent',pnl_clb_grp,'Title','Zoom');
% pnl_calib(2) = uitab('Parent',pnl_clb_grp,'Title','Length');
% pnl_calib(3) = uitab('Parent',pnl_clb_grp,'Title','Polygon');