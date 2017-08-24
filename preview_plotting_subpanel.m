function pnhdl = preview_plotting_subpanel(pr_hdl,pst,glb_fcts)
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
pnhdl.modification_preview = @modification_preview;
pnhdl.get_preview_data = @get_preview_data;
%drawing mode is taken from the glb_fcts
drawing_mode = glb_fcts.drawing_mode('get','preview');
XYLim = [];
curr_pic = 1;
cxmhdl = [];
drawfillcol = glb_fcts.color_action('get','');
    function refresh()
        drawing_mode = glb_fcts.drawing_mode('get','preview');
        set(cxmhdl,'Checked','off');
        for i=1:length(cxmhdl)
            if strcmp(drawing_mode,get(cxmhdl(i),'Tag'))
                set(cxmhdl(i),'Checked','on');
            end
            if strcmp(drawing_mode,'drawline')
                drawfillcol = glb_fcts.color_action('get','drawline');
            end
        end
        axchldrn = get(axes_img,'Children');
        for i=1:length(axchldrn)
            if strcmp(get(axchldrn(i),'Tag'),'drawline')
                plt = axchldrn(i);
                set(plt,'MarkerFace',drawfillcol,'Color',drawfillcol);
                break;
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
            XYLim = [XLim;YLim];
            set(axes_img,'XLim',XLim,'YLim',YLim);
        end
    end
    function show_image()
        data = glb_fcts.get_data();
        if~isempty(data)
            pic = glb_fcts.get_act_pict();
            is_other_pic = pic~=curr_pic;
            curr_pic = pic;
            md = glb_fcts.get_act_modif();
            chldrn = get(axes_img,'Children');
            if isempty(chldrn)
                imgcxm = uicontextmenu();
                    cxmhdl(1) = uimenu(imgcxm,'Label','Zoom','Tag','zoom_points'...
                        ,'Callback',{@uimenu_Callback},'Checked','on');
                    cxmhdl(2) = uimenu(imgcxm,'Label','Left zoom','Tag','leftzoom'...
                        ,'Callback',{@uimenu_Callback});
                    cxmhdl(3) = uimenu(imgcxm,'Label','Full size','Tag','fullsize'...
                        ,'Callback',{@uimenu_Callback});
                    cxmhdl(4) = uimenu(imgcxm,'Label','Draw line','Tag','drawline'...
                        ,'Callback',{@uimenu_Callback},'Separator','on');
                    cxmhdl(5) = uimenu(imgcxm,'Label','Fill','Tag','imfill'...
                        ,'Callback',{@uimenu_Callback});
                    cxmhdl(6) = uimenu(imgcxm,'Label','Probe','Tag','probe'...
                        ,'Callback',{@uimenu_Callback});
                img_hndl = image(data(pic).picture(md).data...
                    ,'Parent',axes_img,'Tag','img2'...
                    ,'ButtonDownFcn',{@img_ButtonDownFcn}...
                    ,'UIContextMenu',imgcxm);
                set(axes_img,'XTickLabel',[],'YTickLabel',[],'XTick',[]...
                    ,'YTick',[]);
            else
                drawline = [];
                zoompoints = [];
                for i=1:length(chldrn)
                    Tag = get(chldrn(i),'Tag');
                    if strcmp(Tag,'img2');
                        img_hndl = chldrn(i);
                    end
                    if strcmp(Tag,'drawline');
                        drawline = chldrn(i);
                    end
                    if strcmp(Tag,'zoompoint');
                        zoompoints = [zoompoints chldrn(i)]; %#ok<AGROW>
                    end
                end
                %removing undrawed line
                if ~isempty(drawline)&&is_other_pic
                    delete(drawline);
                end
                %removing zooming points
                if ~isempty(zoompoints)&&is_other_pic
                    delete(zoompoints);
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
                end
            else
                data(pic).XYLim = [0 Size(2);0 Size(1)];
            end
            if isempty(XYLim)||is_other_pic
                XYLim = data(pic).XYLim;
            end
            switch data(pic).modifvis(2)
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
        end
    end
    function uimenu_Callback(source,eventdata)
        SrcTag = get(source,'Tag');
        if strcmp(SrcTag,'fullsize')
            fullsize();
        elseif strcmp(SrcTag,'leftzoom')
            data = glb_fcts.get_data();
            if~isempty(data)
                pic = glb_fcts.get_act_pict();
                XYLim = data(pic).XYLim;
                show_image();
            end
        elseif strcmp(SrcTag,'delline')
            chldrn = get(axes_img,'Children');
            for i=1:length(chldrn)
                Tag = get(chldrn(i),'Tag');
                if strcmp(Tag,'drawline');
                    delete(chldrn(i));
                    break;
                end
            end
        elseif strcmp(SrcTag,'probe')
            drawing_mode = glb_fcts.drawing_mode('get','preview');
            if any(strcmp(drawing_mode,{'drawline','imfill'}))...
                    &&~strcmp(drawing_mode(1:5),'probe')
                drawing_mode = ['probe' drawing_mode];
                set(cxmhdl,'Checked','off');
                set(source,'Checked','on');
                %setting of the proper probing mode
                glb_fcts.drawing_mode(drawing_mode,'preview');
            end
        else
            set(cxmhdl,'Checked','off');
            set(source,'Checked','on');
            drawing_mode = SrcTag;
            %setting of the drawing mode for preview
            glb_fcts.drawing_mode(drawing_mode,'preview');
        end
    end
    function fill_in_preview(pntr)
        glb_fcts.fill_in_preview(pntr);
    end
    function img_ButtonDownFcn(source,eventdata)
        seltype = get(gcf,'SelectionType');
        if strcmp(seltype,'normal')
            pntr = get(axes_img,'CurrentPoint');
            switch drawing_mode
                case 'zoom_points'
                    zoom_points(pntr);
                case 'drawline'
                    drawline(pntr);
                case 'probedrawline'
                    drawfillcol = probe_color(pntr);
                    glb_fcts.color_action('set','',drawfillcol);
                    drawing_mode = 'drawline';
                    glb_fcts.drawing_mode(drawing_mode,'preview');
                    set(cxmhdl,'Checked','off');
                    for i=1:length(cxmhdl)
                        if strcmp(get(cxmhdl(i),'Tag'),'drawline')
                            set(cxmhdl(i),'Checked','on');
                            break;
                        end
                    end
                case 'imfill'
                    fill_in_preview(pntr);
                case 'probeimfill'
                    drawfillcol = probe_color(pntr);
                    glb_fcts.color_action('set','',drawfillcol);
                    drawing_mode = 'imfill';
                    glb_fcts.drawing_mode(drawing_mode,'preview');
                    set(cxmhdl,'Checked','off');
                    for i=1:length(cxmhdl)
                        if strcmp(get(cxmhdl(i),'Tag'),'imfill')
                            set(cxmhdl(i),'Checked','on');
                            break;
                        end
                    end
            end
        end
    end
    function prcolor = probe_color(pntr)
        preview_data = get_preview_data();
        pix = round(pntr(1,1:2));
        pix(pix==0) = 1;
        prcolor = preview_data(pix(2),pix(1),:);
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
            XYLim = [XLim;YLim];
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
                ,'Tag','zoompoint'...
                ,'ButtonDownFcn',{@del_ButtonDownFcn});
            set(axes_img,'NextPlot','replace');
            axchldrn = get(axes_img,'Children');
            XLim = [pntr(1,1) pntr(1,1)];
            YLim = [pntr(1,2) pntr(1,2)];
            for i=1:length(axchldrn)
                if strcmp(get(axchldrn(i),'Tag'),'zoompoint')
                    plt = [plt axchldrn(i)]; %#ok<AGROW>
                    XLim(1) = min(XLim(1),get(plt(end),'XData'));
                    XLim(2) = max(XLim(2),get(plt(end),'XData'));
                    YLim(1) = min(YLim(1),get(plt(end),'YData'));
                    YLim(2) = max(YLim(2),get(plt(end),'YData'));
                end
            end
            if length(plt)>4
                set(axes_img,'XLim',XLim,'YLim',YLim);
                XYLim = [XLim;YLim];
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
                delete(plt);
            end
        end
    end
    function del_ButtonDownFcn(source,eventdata)
        seltype = get(gcf,'SelectionType');
        if strcmp(seltype,'normal')
            delete(source);
        end
    end
    function drawline(pntr)
        axchldrn = get(axes_img,'Children');
        plt = [];
        if ~isempty(axchldrn)
            for i=1:length(axchldrn)
                if strcmp(get(axchldrn(i),'Tag'),'drawline')
                    plt = axchldrn(i);
                    break;
                end
            end
            if ~isempty(plt)
                XData = get(plt,'XData');
                YData = get(plt,'YData');
                XData(end+1) = pntr(1,1);
                YData(end+1) = pntr(1,2);
                set(plt,'XData',XData,'YData',YData);
            else
                drawlinecxm = uicontextmenu();
                    uimenu(drawlinecxm,'Label','Remove line','Tag','delline'...
                        ,'Callback',{@uimenu_Callback});
                set(axes_img,'NextPlot','Add');
                plot(axes_img,pntr(1,1),pntr(1,2)...
                    ,'Marker','o'...
                    ,'MarkerSize',5 ...
                    ,'MarkerEdgeColor','k'...
                    ,'MarkerFace',drawfillcol...
                    ,'Color',drawfillcol...
                    ,'Line','-'...
                    ,'Tag','drawline'...
                    ,'ButtonDownFcn',{@drawline_ButtonDownFcn}...
                    ,'UIContextMenu',drawlinecxm);
                set(axes_img,'NextPlot','replace');
            end
        end
    end
    function drawline_ButtonDownFcn(source,eventdata)
        seltype = get(gcf,'SelectionType');
        if strcmp(seltype,'normal')&&strcmp(drawing_mode,'drawline')
            XData = get(source,'XData');
            YData = get(source,'YData');
            pntr = get(axes_img,'CurrentPoint');
            imgSize = diff(XYLim'); %#ok<UDIM>
            absSize = absolute_size(axes_img);
            fc = absSize./imgSize;
            if sqrt((fc(1)*(pntr(1,1)-XData(end)))^2 ...
                    + (fc(2)*(pntr(1,2)-YData(end)))^2) < 2.5...%half of the marker diameter
                    && length(XData)>1 
                XData = XData(1:(end-1));
                YData = YData(1:(end-1));
            else
                XData(end+1) = pntr(1,1);
                YData(end+1) = pntr(1,2);
            end
            set(source,'XData',XData,'YData',YData);
        end
    end
    function modification_preview(CData)
        set(img_hndl,'CData',CData);
    end
    function preview_data = get_preview_data(varargin)
        preview_data = [];
        if ~isempty(varargin)
            chldrn = get(axes_img,'Children');
            for i=1:length(chldrn)
                Tag = get(chldrn(i),'Tag');
                if strcmp(Tag,varargin{1});
                    preview_data = [preview_data chldrn(i)]; %#ok<AGROW>
                end
            end
        else
            preview_data = get(img_hndl,'CData');
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
