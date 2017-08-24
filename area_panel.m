function pnhdl = area_panel(pr_hdl,pst,glb_fcts,chkbx_function)
dflt_size = [200 240];
unts = get(pr_hdl,'Unit');
rsz_fc = resize_factor(pst,unts,dflt_size);
panel_hdl = uipanel('Parent',pr_hdl,'Unit',unts,'Position',pst...
    ,'Tag','pnl_area','Visible','on');
pnhdl.hndl = panel_hdl;
pnhdl.refresh = @refresh;
pnhdl.calc_filled = @calc_filled;
chkbx(1) = uicontrol('Parent',panel_hdl,'Unit',unts,'Style','checkbox'...
    ,'Position',[10 220 150 15].*rsz_fc,'String','Polygon'...
    ,'Tag','polygon','Callback',{@chkbx_Callback},'Value',0);
txt_area(1) = uicontrol('Parent',panel_hdl,'Unit',unts,'Style','text'...
    ,'Position',[10 195 180 20].*rsz_fc,'Tag','area'...
    ,'String','Polygon area: 0 mm2');
chkbx(2) = uicontrol('Parent',panel_hdl,'Unit',unts,'Style','checkbox'...
    ,'Position',[10 180 150 15].*rsz_fc,'String','Filled'...
    ,'Tag','filled_area','Callback',{@chkbx_Callback},'Value',0);
txt_area(2) = uicontrol('Parent',panel_hdl,'Unit',unts,'Style','text'...
    ,'Position',[10 155 180 20].*rsz_fc,'Tag','area'...
    ,'String','Filled area: 0 mm2');
pnhdl.chkbx = chkbx;
uicontrol('Parent',panel_hdl,'Unit',unts,'Style','text'...
    ,'Position',[[10 140 50].*rsz_fc(1:3) 15],'String','Comment:'...
    ,'HorizontalAlignment','left');
edt_com = uicontrol('Parent',panel_hdl,'Unit',unts,'Style','edit'...
    ,'Position',[10 80 180 60].*rsz_fc,'Tag','comment'...
    ,'BackgroundColor','w'...
    ,'HorizontalAlignment','left','Max',2);
bttn = uicontrol('Parent',panel_hdl,'Unit',unts,'Style','pushbutton'...
    ,'Position',[10 10 70 60].*rsz_fc,'Tag','add','String','Add area'...
    ,'Callback',{@bttn_Callback});
fill_prop = [];
filled_fraction = 0;
filled_area = 0;
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
                    set(txt_area(1),'String'...
                        ,['Polygon area: '...
                        num2str(data(pic).PolygonData.PolyArea)...
                        ' ' data(pic).Units]);
                    glb_fcts.set_data(data);
                end
            end
            if isfield(data(pic),'Units')
                if ~isempty(data(pic).Units)
                    set(txt_area(2),'String',['Filled area: ' filled_area...
                        ' ' data(pic).Units]);
                else
                    set(txt_area(2),'String','Filled area: 0 mm2');
                end
            else
                set(txt_area(2),'String','Filled area: 0 mm2');
            end
        end
    end
    function bttn_Callback(source,eventdata)
        data = glb_fcts.get_data();
        if ~isempty(data)
            pic = glb_fcts.get_act_pict();
            if isfield(data(pic),'PolygonData')...
                    && isfield(data(pic),'TotalArea')&&get(chkbx(1),'Value')
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
            if ~isempty(fill_prop)&& isfield(data(pic),'TotalArea')...
                    &&get(chkbx(2),'Value')
                FilledData.samplename = data(pic).samplename;
                FilledData.Area = filled_area;
                FilledData.Units = data(pic).Units;
                FilledData.Type = 'filled_area';
                FilledData.Comment = get(edt_com,'String');
                FilledData.Pst = fill_prop.pixpst;
                FilledData.Str ...
                    = ['Filled area: '...
                    num2str(filled_area) ' ' data(pic).Units ', ' ...
                    data(pic).samplename '/' data(pic).filename];
                AreaData = glb_fcts.areadata('get');
                AreaData = [AreaData FilledData];
                glb_fcts.areadata('set',AreaData);
                glb_fcts.refresh();
            end
        end
    end
    function pntr_col = calc_filled(pntr)
        pixpst = pntr(1,2:-1:1);
        data = glb_fcts.get_data();
        if~isempty(data)
            pic = glb_fcts.get_act_pict();
            switch data(pic).modifvis(1)    %modifvis(1) - left popupmenu
                case 1
                    img_data = data(pic).picture(1).data;
                case 2
                    md = glb_fcts.get_act_modif();
                    img_data = data(pic).picture(md).data;
                case 3
                    img_data = data(pic).picture(end).data;
            end
            filled_fraction = calc_filled_fraction(img_data,pixpst);
            if isfield(data(pic),'TotalArea')
                filled_area = data(pic).TotalArea*filled_fraction;
                set(txt_area(2),'String',['Filled area: ' num2str(filled_area)...
                    ' ' data(pic).Units]);
            end
            pixpst = round(pixpst);
            pixpst(pixpst==0) = 1;
            fill_prop.pixpst = pixpst;
            pntr_col = img_data(pixpst(1),pixpst(2),:);
            fill_prop.col_fill = pntr_col;
        end
    end
end
function filled_fraction = calc_filled_fraction(imgin,pix)
    pix = round(pix);
    pix(pix==0) = 1;
    pixcol = imgin(pix(1),pix(2),:);
    Size = size(imgin);
    temptable = boolean(ones(Size(1:2)));
    rch = imgin(:,:,1);
    gch = imgin(:,:,2);
    bch = imgin(:,:,3);
    temptable = and(temptable,rch==pixcol(1));
    temptable = and(temptable,gch==pixcol(2));
    temptable = and(temptable,bch==pixcol(3));
    temptable = and(temptable,imfill(~temptable,pix,4));
    filled_fraction = sum(sum(double(temptable)))/prod(Size(1:2));
end
