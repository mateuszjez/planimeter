function pnhdl = calibration_plotting_subpanel(pr_hdl,pst,glb_fcts)
dflt_size = [600 300];
unts = get(pr_hdl,'Unit');
rsz_fc = resize_factor(pst,unts,dflt_size);
panel_hdl = uipanel('Parent',pr_hdl,'Unit',unts,'Position',pst...
    ,'Tag','plotting_panel');
axes_img = axes('Parent',panel_hdl,'Unit',unts,'Tag','axes1','Position'...
    ,[25 25 550 250].*rsz_fc...
    ,'XTickLabel',[],'YTickLabel',[],'XTick',[],'YTick',[]);
sld(1) = uicontrol('Parent',panel_hdl,'Unit',unts,'Tag','top','Position'...
    ,[4 150 20 125].*rsz_fc,'Value',1,'Callback',{@sld_Callback});
sld(2) = uicontrol('Parent',panel_hdl,'Unit',unts,'Tag','bot','Position'...
    ,[4 25 20 125].*rsz_fc,'Value',0,'Callback',{@sld_Callback});
sld(3) = uicontrol('Parent',panel_hdl,'Unit',unts,'Tag','lft','Position'...
    ,[25 4 275 20].*rsz_fc,'Value',0,'Callback',{@sld_Callback});
sld(4) = uicontrol('Parent',panel_hdl,'Unit',unts,'Tag','rgt','Position'...
    ,[300 4 275 20].*rsz_fc,'Value',1,'Callback',{@sld_Callback});
sld(5) = uicontrol('Parent',panel_hdl,'Unit',unts,'Tag','mvr','Position'...
    ,[576 25 20 250].*rsz_fc,'Value',0.5,'Callback',{@sld_Callback});
sld(6) = uicontrol('Parent',panel_hdl,'Unit',unts,'Tag','mhr','Position'...
    ,[24 276 550 20].*rsz_fc,'Value',0.5);
set(sld,'Style','slider','Callback',{@sld_Callback});
img_hndl = [];
pnhdl.hndl = panel_hdl;
pnhdl.refresh = @refresh;
%drawing mode is taken from the glb_fcts
drawing_mode = glb_fcts.drawing_mode('get');
cxmhdl = [];
    function refresh()
        drawing_mode = glb_fcts.drawing_mode('get');
        set(cxmhdl,'Checked','off');
        for i=1:length(cxmhdl)
            if strcmp(drawing_mode,get(cxmhdl(i),'Tag'))
                set(cxmhdl(i),'Checked','on');
            end
        end
        show_image();
    end
    function sld_Callback(source,eventdata)
        sldval = get(source,'Value');
        Tag = get(source,'Tag');
        sld12 = [get(sld(1),'Value') get(sld(2),'Value')];
        sld34 = [get(sld(3),'Value') get(sld(4),'Value')];
        if strcmp(Tag,'mvr')
            sld_dif = sld12(1) - sld12(2);
            if (sldval - 0.5*sld_dif)<0
                sldval = 0.5*sld_dif;
            elseif (sldval + 0.5*sld_dif)>1
                sldval = 1 - 0.5*sld_dif;
            end
            mvsld = sldval - mean(sld12);
            sld12 = sld12 + mvsld;
            %for the round error case
            sld12(sld12<0) = 0;
            sld12(sld12>1) = 1;
            set(source,'Value',sldval);
            set(sld(1),'Value',sld12(1));
            set(sld(2),'Value',sld12(2));
        end
        if strcmp(Tag,'mhr')
            sld_dif = diff(sld34);
            if (sldval - 0.5*sld_dif)<0
                sldval = 0.5*sld_dif;
            elseif (sldval + 0.5*sld_dif)>1
                sldval = 1 - 0.5*sld_dif;
            end
            mvsld = sldval - mean(sld34);
            sld34 = sld34 + mvsld;
            %for the round error case
            sld34(sld34<0) = 0;
            sld34(sld34>1) = 1;
            set(source,'Value',sldval);
            set(sld(3),'Value',sld34(1));
            set(sld(4),'Value',sld34(2));
        end
        if any(strcmp(Tag,{'top','bot','lft','rgt'}))
            if diff(sld12)>0
                sld12 = sld12(2:-1:1);
            end
            set(sld(1),'Value',sld12(1));
            set(sld(2),'Value',sld12(2));
            set(sld(5),'Value',mean(sld12));
            if diff(sld34)<0
                sld34 = sld34(2:-1:1);
            end
            set(sld(3),'Value',sld34(1));
            set(sld(4),'Value',sld34(2));
            set(sld(6),'Value',mean(sld34));
        end
        %check possibility of function creation for setting visible area
        data = glb_fcts.get_data();
        if~isempty(data)
            pic = glb_fcts.get_act_pict();
            Size = size(data(pic).picture(1).data);
            XLim = Size(2)*sld34;
            YLim = Size(1)*(1-sld12);
            if diff(XLim)==0
                XLim(2) = XLim(1) + 1;
            end
            if diff(YLim)==0
                YLim(2) = YLim(1) + 1;
            end
            data(pic).XYLim = [XLim;YLim];
            glb_fcts.set_data(data);
            set(axes_img,'XLim',XLim,'YLim',YLim);
        end
    end
    function show_image()
        data = glb_fcts.get_data();
        calib1_hndl = [];
        calib2_hndl = [];
        polygon_hndl = [];
        if~isempty(data)
            pic = glb_fcts.get_act_pict();
            md = glb_fcts.get_act_modif();
            chldrn = get(axes_img,'Children');
            if isempty(chldrn)
                imgcxm = uicontextmenu();
                    cxmhdl(1) = uimenu(imgcxm,'Label','Zoom','Tag','zoom_points'...
                        ,'Callback',{@uimenu_Callback},'Checked','on');
                    cxmhdl(2) = uimenu(imgcxm,'Label','Full size','Tag','fullsize'...
                        ,'Callback',{@uimenu_Callback});
                    cxmhdl(3) = uimenu(imgcxm,'Label','Lengths calibration'...
                        ,'Tag','calib_points'...
                        ,'Callback',{@uimenu_Callback},'Separator','on');
                    cxmhdl(4) = uimenu(imgcxm,'Label','Polygon area'...
                        ,'Tag','polygon'...
                        ,'Callback',{@uimenu_Callback},'Separator','on');
                    cxmhdl(5) = uimenu(imgcxm,'Label','Filled area'...
                        ,'Tag','filled_area'...
                        ,'Callback',{@uimenu_Callback},'Separator','on');
                img_hndl = image(data(pic).picture(md).data...
                    ,'Parent',axes_img,'Tag','img1'...
                    ,'ButtonDownFcn',{@img_ButtonDownFcn}...
                    ,'UIContextMenu',imgcxm);
                set(axes_img,'XTickLabel',[],'YTickLabel',[],'XTick',[]...
                    ,'YTick',[]);
            else
                for i=1:length(chldrn)
                    Tag = get(chldrn(i),'Tag');
                    if strcmp(Tag,'img1');
                        img_hndl = chldrn(i);
                    end
                    if strcmp(Tag,'calib1');
                        calib1_hndl = chldrn(i);
                    end
                    if strcmp(Tag,'calib2');
                        calib2_hndl = chldrn(i);
                    end
                    if strcmp(Tag,'polygon');
                        polygon_hndl = chldrn(i);
                    end
                end
            end
            Size = size(data(pic).picture(1).data);
            set(sld([(1:2) 5]),'SliderStep',[1 10]/Size(1));
            set(sld([(3:4) 6]),'SliderStep',[1 10]/Size(2));
            XData = [1 Size(2)];
            YData = [1 Size(1)];
            if isfield(data(pic),'XYLim')
                if isempty(data(pic).XYLim)
                    data(pic).XYLim = [0 Size(2);0 Size(1)];
                    glb_fcts.set_data(data);
                end
            else
                data(pic).XYLim = [0 Size(2);0 Size(1)];
                glb_fcts.set_data(data);
            end
            XYLim = data(pic).XYLim;
            switch data(pic).modifvis(1)
                case 1
                set(img_hndl,'XData',XData,'YData',YData...
                    ,'CData',data(pic).picture(1).data);
                case 2
                set(img_hndl,'XData',XData,'YData',YData...
                    ,'CData',data(pic).picture(md).data);
                case 3
                set(img_hndl,'XData',XData,'YData',YData...
                    ,'CData',data(pic).picture(end).data);
            end
            
            set(axes_img,'XLim',XYLim(1,:),'YLim',XYLim(2,:));
            
            %sliders
            sld12 = XYLim(2,:)/Size(1);
            sld34 = XYLim(1,:)/Size(2);
            set(sld(1),'Value',1 - sld12(1));
            set(sld(2),'Value',1 - sld12(2));
            set(sld(3),'Value',sld34(1));
            set(sld(4),'Value',sld34(2));
            set(sld(5),'Value',1 - mean(sld12));
            set(sld(6),'Value',mean(sld34));
                
            %calibration lines
            if isfield(data(pic),'CalibData')
                if~isfield(data(pic).CalibData,'calib1')
                    data(pic).CalibData.calib1.XData = [];
                    data(pic).CalibData.calib1.YData = [];
                    glb_fcts.set_data(data);
                end
                if~isfield(data(pic).CalibData,'calib2')
                    data(pic).CalibData.calib2.XData = [];
                    data(pic).CalibData.calib2.YData = [];
                    glb_fcts.set_data(data);
                end
                if length(data(pic).CalibData.calib1.XData)==2
                    if~isempty(calib1_hndl)
                        set(calib1_hndl...
                            ,'XData',data(pic).CalibData.calib1.XData...
                            ,'YData',data(pic).CalibData.calib1.YData);
                    else
                        set(axes_img,'NextPlot','Add');
                        plot(axes_img...
                            ,data(pic).CalibData.calib1.XData...
                            ,data(pic).CalibData.calib1.YData...
                            ,'Marker','o'...
                            ,'MarkerSize',5 ...
                            ,'MarkerEdgeColor','k'...
                            ,'MarkerFace','b'...
                            ,'Color','b'...
                            ,'Line','-'...
                            ,'Tag','calib1'...
                            ,'ButtonDownFcn',{@del_ButtonDownFcn});
                        set(axes_img,'NextPlot','replace');
                    end
                elseif length(data(pic).CalibData.calib1.XData)~=1%wczesniej tylko else
                    if~isempty(calib1_hndl)
                        delete(calib1_hndl);
                    end
                    data(pic).CalibData.calib1.XData = [];
                    data(pic).CalibData.calib1.YData = [];
                    glb_fcts.set_data(data);
                end
                if length(data(pic).CalibData.calib2.XData)==2
                    if~isempty(calib2_hndl)
                        set(calib2_hndl...
                            ,'XData',data(pic).CalibData.calib2.XData...
                            ,'YData',data(pic).CalibData.calib2.YData);
                    else
                        set(axes_img,'NextPlot','Add');
                        plot(axes_img...
                            ,data(pic).CalibData.calib2.XData...
                            ,data(pic).CalibData.calib2.YData...
                            ,'Marker','o'...
                            ,'MarkerSize',5 ...
                            ,'MarkerEdgeColor','k'...
                            ,'MarkerFace','g'...
                            ,'Color','g'...
                            ,'Line','-'...
                            ,'Tag','calib2'...
                            ,'ButtonDownFcn',{@del_ButtonDownFcn});
                        set(axes_img,'NextPlot','replace');
                    end
                elseif length(data(pic).CalibData.calib2.XData)~=1%wczesniej tylko else
                    if~isempty(calib2_hndl)
                        delete(calib2_hndl);
                    end
                    data(pic).CalibData.calib2.XData = [];
                    data(pic).CalibData.calib2.YData = [];
                    glb_fcts.set_data(data);
                end
            end

            %polygon
            if isfield(data(pic),'PolygonData')
                if~isfield(data(pic).PolygonData,'XData')
                    data(pic).PolygonData.XData = [];
                    data(pic).PolygonData.YData = [];
                    data(pic).PolygonData.RelPolyArea = 0;
                    glb_fcts.set_data(data);
                end
                if ~isempty(data(pic).PolygonData.XData)
                    XData = data(pic).PolygonData.XData;
                    YData = data(pic).PolygonData.YData;
                    if~isempty(polygon_hndl)
                        set(polygon_hndl,'XData',XData,'YData',YData);
                    else
                        polycxm = uicontextmenu();
                            uimenu(polycxm,'Label','Delete polygon'...
                                ,'Tag','delpoly'...
                                ,'Callback',{@uimenu_Callback});
                        set(axes_img,'NextPlot','Add');
                        plot(axes_img,XData,YData...
                            ,'Marker','o'...
                            ,'MarkerSize',5 ...
                            ,'MarkerEdgeColor','k'...
                            ,'MarkerFace',[0.9 0.9 0.9]...
                            ,'Color',[0.9 0.9 0.9]...
                            ,'Line','-'...
                            ,'Tag','polygon'...
                            ,'ButtonDownFcn',{@polygon_ButtonDownFcn}...
                            ,'UIContextMenu',polycxm);
                        set(axes_img,'NextPlot','replace');
                    end
                else
                    if~isempty(polygon_hndl)
                        delete(polygon_hndl);
                    end
                end
            else
                if~isempty(polygon_hndl)
                    delete(polygon_hndl);
                end
            end
        end
    end
    function uimenu_Callback(source,eventdata)
        SrcTag = get(source,'Tag');
        if strcmp(SrcTag,'fullsize')
            fullsize();
        elseif strcmp(SrcTag,'delpoly')
            chldrn = get(axes_img,'Children');
            for i=1:length(chldrn)
                Tag = get(chldrn(i),'Tag');
                if strcmp(Tag,'polygon');
                    delete(chldrn(i));
                    data = glb_fcts.get_data();
                    pic = glb_fcts.get_act_pict();
                    data(pic).PolygonData.XData = [];
                    data(pic).PolygonData.YData = [];
                    data(pic).PolygonData.RelPolyArea = 0;
                    glb_fcts.set_data(data);
                    break;
                end
            end
        else
            set(cxmhdl,'Checked','off');
            set(source,'Checked','on');
            drawing_mode = SrcTag;
            %setting of the drawing mode for left picture
            glb_fcts.drawing_mode(drawing_mode);
        end
    end
    function img_ButtonDownFcn(source,eventdata)
        seltype = get(gcf,'SelectionType');
        if strcmp(seltype,'normal')
            pntr = get(axes_img,'CurrentPoint');
            switch drawing_mode
                case 'zoom_points'
                    zoom_points(pntr);
                case 'calib_points'
                    calib_points(pntr);
                case 'polygon'
                    polygon(pntr);
                case 'filled_area'
                    indticate_filled(pntr);
            end
        end
    end
    function fullsize()
        set(sld([1 4]),'Value',1);  sld12 = [1 0];
        set(sld(2:3),'Value',0);    sld34 = [0 1];
        set(sld(5:6),'Value',0.5);
        data = glb_fcts.get_data();
        if~isempty(data)
            pic = glb_fcts.get_act_pict();
            Size = size(data(pic).picture(1).data);
            XLim = Size(2)*sld34;
            YLim = Size(1)*(1-sld12);
            data(pic).XYLim = [XLim;YLim];
            glb_fcts.set_data(data);
            set(axes_img,'XLim',XLim,'YLim',YLim);
        end
    end
    function zoom_points(pntr)
        axchldrn = get(axes_img,'Children');
        plt = [];
        if ~isempty(axchldrn)
            set(axes_img,'NextPlot','Add');
            plot(axes_img,pntr(1,1),pntr(1,2)...
                ,'Marker','o'...
                ,'MarkerSize',5 ...
                ,'MarkerEdgeColor','k'...
                ,'MarkerFace','m'...
                ,'Line','none'...
                ,'Tag','zoom'...
                ,'ButtonDownFcn',{@del_ButtonDownFcn});
            set(axes_img,'NextPlot','replace');
            axchldrn = get(axes_img,'Children');
            XLim = [pntr(1,1) pntr(1,1)];
            YLim = [pntr(1,2) pntr(1,2)];
            for i=1:length(axchldrn)
                if strcmp(get(axchldrn(i),'Tag'),'zoom')
                    plt = [plt axchldrn(i)]; %#ok<AGROW>
                    XLim(1) = min(XLim(1),get(plt(end),'XData'));
                    XLim(2) = max(XLim(2),get(plt(end),'XData'));
                    YLim(1) = min(YLim(1),get(plt(end),'YData'));
                    YLim(2) = max(YLim(2),get(plt(end),'YData'));
                end
            end
            if length(plt)>4
                set(axes_img,'XLim',XLim,'YLim',YLim);
                %positioning of sliders
                data = glb_fcts.get_data();
                pic = glb_fcts.get_act_pict();
                Size = size(data(pic).picture(1).data);
                sld12 = YLim/Size(1);
                sld34 = XLim/Size(2);
                set(sld(1),'Value',1 - sld12(1));
                set(sld(2),'Value',1 - sld12(2));
                set(sld(3),'Value',sld34(1));
                set(sld(4),'Value',sld34(2));
                set(sld(5),'Value',1 - mean(sld12));
                set(sld(6),'Value',mean(sld34));
                data(pic).XYLim = [XLim;YLim];
                glb_fcts.set_data(data);
                delete(plt);
            end
        end
    end
    function indticate_filled(pntr)
        axchldrn = get(axes_img,'Children');
        plt = [];
        if ~isempty(axchldrn)
            for i=1:length(axchldrn)
                Tag = get(axchldrn(i),'Tag');
                if strcmp(Tag,'filled_area')
                    plt = axchldrn(i); %#ok<AGROW>
                    break;
                end
            end
            plt_col = glb_fcts.calc_filled(pntr);
            edg_col = ones(1,3)*(1 - round(mean(plt_col)));
            if isempty(plt)
                set(axes_img,'NextPlot','Add');
                plot(axes_img,pntr(1,1),pntr(1,2)...
                    ,'Marker','o'...
                    ,'MarkerSize',5 ...
                    ,'MarkerEdgeColor',edg_col...
                    ,'MarkerFace',plt_col...
                    ,'Line','none'...
                    ,'Tag','filled_area'...
                    ,'ButtonDownFcn',{@del_ButtonDownFcn});
                set(axes_img,'NextPlot','replace');
            else
                set(plt,'XData',pntr(1,1),'YData',pntr(1,2)...
                    ,'MarkerEdgeColor',edg_col...
                    ,'MarkerFace',plt_col);
            end
        end
    end
    function calib_points(pntr)
        axchldrn = get(axes_img,'Children');
        plt = [];
        if ~isempty(axchldrn)
            for i=1:length(axchldrn)
                if any(strcmp(get(axchldrn(i),'Tag'),{'calib1','calib2'}))
                    plt = [plt axchldrn(i)]; %#ok<AGROW>
                end
            end
            data = glb_fcts.get_data();
            pic = glb_fcts.get_act_pict();
            if ~isempty(plt)
                mrkr = 0;
                for i=1:length(plt)
                    XData = get(plt(i),'XData');
                    if length(XData)==1
                        YData = get(plt(i),'YData');
                        XData(2) = pntr(1,1);
                        YData(2) = pntr(1,2);
                        set(plt(i),'XData',XData,'YData',YData);
                        switch get(plt(i),'Tag')
                            case 'calib1'
                                data(pic).CalibData.calib1.XData = XData;
                                data(pic).CalibData.calib1.YData = YData;
                            case 'calib2'
                                data(pic).CalibData.calib2.XData = XData;
                                data(pic).CalibData.calib2.YData = YData;
                        end
                        glb_fcts.set_data(data);
                        mrkr = 1;
                    end
                end
                if ~mrkr && length(plt)==1
                    if strcmp(get(plt,'Tag'),'calib1')
                        col = 'g'; Tag = 'calib2';
                        data(pic).CalibData.calib2.XData = pntr(1,1);
                        data(pic).CalibData.calib2.YData = pntr(1,2);
                    else
                        col = 'b'; Tag = 'calib1';
                        data(pic).CalibData.calib1.XData = pntr(1,1);
                        data(pic).CalibData.calib1.YData = pntr(1,2);
                    end
                    set(axes_img,'NextPlot','Add');
                    plot(axes_img,pntr(1,1),pntr(1,2)...
                        ,'Marker','o'...
                        ,'MarkerSize',5 ...
                        ,'MarkerEdgeColor','k'...
                        ,'MarkerFace',col...
                        ,'Color',col...
                        ,'Line','-'...
                        ,'Tag',Tag...
                        ,'ButtonDownFcn',{@del_ButtonDownFcn});
                    set(axes_img,'NextPlot','replace');
                    glb_fcts.set_data(data);
                end
            else
                set(axes_img,'NextPlot','Add');
                plot(axes_img,pntr(1,1),pntr(1,2)...
                    ,'Marker','o'...
                    ,'MarkerSize',5 ...
                    ,'MarkerEdgeColor','k'...
                    ,'MarkerFace','b'...
                    ,'Color','b'...
                    ,'Line','-'...
                    ,'Tag','calib1'...
                    ,'ButtonDownFcn',{@del_ButtonDownFcn});
                set(axes_img,'NextPlot','replace');
            end
        end
    end
    function del_ButtonDownFcn(source,eventdata)
        seltype = get(gcf,'SelectionType');
        if strcmp(seltype,'normal')
            data = glb_fcts.get_data();
            pic = glb_fcts.get_act_pict();
            switch get(source,'Tag')
                case 'calib1'
                    data(pic).CalibData.calib1.XData = [];
                    data(pic).CalibData.calib1.YData = [];
                case 'calib2'
                    data(pic).CalibData.calib2.XData = [];
                    data(pic).CalibData.calib2.YData = [];
            end
            glb_fcts.set_data(data);
            delete(source);
        end
    end
    function polygon(pntr)
        axchldrn = get(axes_img,'Children');
        plt = [];
        if ~isempty(axchldrn)
            data = glb_fcts.get_data();
            pic = glb_fcts.get_act_pict();
            for i=1:length(axchldrn)
                if strcmp(get(axchldrn(i),'Tag'),'polygon')
                    plt = axchldrn(i);
                    break;
                end
            end
            if ~isempty(plt)
                if isfield(data(pic),'PolygonData')
                    if ~isempty(data(pic).PolygonData.XData)
                        XData = data(pic).PolygonData.XData;
                        YData = data(pic).PolygonData.YData;
                    end
                else
                    XData = get(plt,'XData');
                    YData = get(plt,'YData');
                end
                if XData(1)~=XData(end)||YData(1)~=YData(end)...
                        ||length(XData)==1
                    XData(end+1) = pntr(1,1);
                    YData(end+1) = pntr(1,2);
                    set(plt,'XData',XData,'YData',YData);
                    data(pic).PolygonData.XData = XData;
                    data(pic).PolygonData.YData = YData;
                    data(pic).PolygonData.RelPolyArea = 0;
                    glb_fcts.set_data(data);
                end
            else
                polycxm = uicontextmenu();
                    uimenu(polycxm,'Label','Delete polygon','Tag','delpoly'...
                        ,'Callback',{@uimenu_Callback});
                set(axes_img,'NextPlot','Add');
                plot(axes_img,pntr(1,1),pntr(1,2)...
                    ,'Marker','o'...
                    ,'MarkerSize',5 ...
                    ,'MarkerEdgeColor','k'...
                    ,'MarkerFace',[0.9 0.9 0.9]...
                    ,'Color',[0.9 0.9 0.9]...
                    ,'Line','-'...
                    ,'Tag','polygon'...
                    ,'ButtonDownFcn',{@polygon_ButtonDownFcn}...
                    ,'UIContextMenu',polycxm);
                set(axes_img,'NextPlot','replace');
                data(pic).PolygonData.XData = pntr(1,1);
                data(pic).PolygonData.YData = pntr(1,2);
                data(pic).PolygonData.RelPolyArea = 0;
                glb_fcts.set_data(data);
            end
        end
    end
    function polygon_ButtonDownFcn(source,eventdata)
        seltype = get(gcf,'SelectionType');
        if strcmp(seltype,'normal')
            XData = get(source,'XData');
            YData = get(source,'YData');
            pntr = get(axes_img,'CurrentPoint');
            data = glb_fcts.get_data();
            pic = glb_fcts.get_act_pict();
            imgSize = diff(data(pic).XYLim'); %#ok<UDIM>
            absSize = absolute_size(axes_img);
            fc = absSize./imgSize;
            if sqrt((fc(1)*(pntr(1,1)-XData(1)))^2 ...
                    + (fc(2)*(pntr(1,2)-YData(1)))^2) < 2.5...%half of the marker diameter
                    && length(XData)>2 ...
                    && (XData(1)~=XData(end)||YData(1)~=YData(end))
                XData(end+1) = XData(1);
                YData(end+1) = YData(1);
                set(source,'XData',XData,'YData',YData);
                Area = polyarea(XData,YData);
                Size = size(data(pic).picture(1).data);
                data(pic).PolygonData.XData = XData;
                data(pic).PolygonData.YData = YData;
                data(pic).PolygonData.RelPolyArea = Area/(Size(1)*Size(2));
                glb_fcts.set_data(data);
                glb_fcts.refresh();
            elseif sqrt((fc(1)*(pntr(1,1)-XData(end)))^2 ...
                    + (fc(2)*(pntr(1,2)-YData(end)))^2) < 2.5...%half of the marker diameter
                    && length(XData)>1 
                chkrefresh = XData(1)==XData(end) && YData(1)==YData(end);
                XData = XData(1:(end-1));
                YData = YData(1:(end-1));
                set(source,'XData',XData,'YData',YData);
                data(pic).PolygonData.XData = XData;
                data(pic).PolygonData.YData = YData;
                data(pic).PolygonData.RelPolyArea = 0;
                glb_fcts.set_data(data);
                if chkrefresh
                    glb_fcts.refresh();
                end
            end
        end
    end
end
function Size = absolute_size(hdl)
    if ~isprop(hdl,'Position')
        scrsize = get(hdl,'ScreenSize');
        Size = scrsize(3:4);
    elseif strcmp(get(hdl,'Units'),'pixels')
        pst = get(hdl,'Position');
        Size = pst(3:4);
    elseif strcmp(get(hdl,'Units'),'normalized')
        pst = get(hdl,'Position');
        Size = pst(3:4).*absolute_size(get(hdl,'Parent'));
    end
end
