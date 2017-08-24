function planimeter()
%global variables
data = [];
AreaData = [];
DrawingMode = 'zoom_points';
DrawingModePreview = 'zoom_points';
ctrl_enablig = [];

%global functions declaration
glb_fcts.refresh                = @refresh;
glb_fcts.get_data               = @get_data;
glb_fcts.set_data               = @set_data;
glb_fcts.areadata               = @areadata;
glb_fcts.get_preview_data       = @get_preview_data;
glb_fcts.get_act_pict           = @get_act_pict;
glb_fcts.set_act_pict           = @set_act_pict;
glb_fcts.get_act_modif          = @get_act_modif;
glb_fcts.set_act_modif          = @set_act_modif;
glb_fcts.modification_preview   = @modification_preview;
glb_fcts.drawing_mode           = @drawing_mode;
glb_fcts.get_cp_mod_sequence    = @get_cp_mod_sequence;
glb_fcts.dis_or_enable          = @dis_or_enable;

%creating and positioning main window
ScrSiz = get(0,'ScreenSize');
figpst = [0.07*ScrSiz(3) 0.1*ScrSiz(4) 0.86*ScrSiz(3) 0.8*ScrSiz(4)];
main_window = figure('Position',figpst,'MenuBar','none');

%creating of particular panels
pnl_op = operating_panel(main_window,[figpst(3) 0 figpst(3:4)]/2,glb_fcts);

%passing of some pnl_op functions as global (necessary for initialization
%of subsequent panels)
glb_fcts.fill_in_preview        = pnl_op.fill_in_preview;
glb_fcts.calc_filled            = pnl_op.calc_filled;
glb_fcts.color_action           = pnl_op.color_action;

pnl_surf = surface_panel(main_window,[0 0 figpst(3:4)]/2,glb_fcts);
pnl_plot = plotting_panel(main_window,[0 figpst(4)/2 figpst(3)...
    figpst(4)/2],glb_fcts);

%normalization of units to make GUI resizable
normalization(main_window);

    function refresh()
        pnl_op.refresh();
        pnl_surf.refresh();
        pnl_plot.refresh();
    end
    function data_out = get_data()
        data_out = data;
    end
    function set_data(data_in)
        data = data_in;
    end
    function varargout = areadata(input,varargin)
        %get or set AreaData variable
        varargout = {};
        if strcmp(input,'get')
            varargout{1} = AreaData;
        elseif strcmp(input,'set')
            AreaData = varargin{1};
            pnl_op.refresh();
            pnl_plot.refresh();
        end
    end
    function preview_data = get_preview_data(varargin)
        %passes function feom plotting_panel / pnl_plot
        if isempty(varargin)
            preview_data = pnl_plot.get_preview_data();
        else
            preview_data = pnl_plot.get_preview_data(varargin{1});
        end
    end
    function act_pict_out = get_act_pict(varargin)
    %returns no of active picture if there is no argument or returns
    %active data entry if the passed argumet is string 'data'
        act_pict_no = pnl_op.get_act_pict();
        if isempty(varargin)
            act_pict_out = act_pict_no;
        elseif strcmp(varargin{1},'data')&&~isempty(data)
            if length(data)>=act_pict_no
                act_pict_out = data(act_pict_no);
            end
        elseif isempty(data)
            act_pict_out = [];
        end
    end
    function set_act_pict(act_pict_in)
        pnl_op.set_act_pict(act_pict_in);
    end
    function act_modif_out = get_act_modif()
    %returns no of active modification of the picture
        act_modif_out = pnl_surf.get_act_modif();
    end
    function set_act_modif(act_modif_in)
    %sets no of active modification of the picture
        pnl_surf.set_act_modif(act_modif_in);
    end
    function modification_preview(CData)
        pnl_plot.modification_preview(CData);
    end
    function varargout = drawing_mode(input,varargin)
        varargout = {};
        if isempty(varargin)
            if strcmp(input,'get')
                varargout{1} = DrawingMode;
            else
                DrawingMode = input;
                pnl_op.refresh();
                pnl_plot.refresh();
            end
        elseif strcmp(varargin{1},'preview')
            if strcmp(input,'get')
                varargout{1} = DrawingModePreview;
            else
                DrawingModePreview = input;
                pnl_op.refresh();
                pnl_plot.refresh();
            end
        end
    end
    function cp_mod_sequence = get_cp_mod_sequence()
        %passes function from pnl_surf as global
        cp_mod_sequence = pnl_surf.get_cp_mod_sequence();
    end
    function dis_or_enable(mode)
        switch mode
            case 'disable'
                ctrl_enablig = disabling(main_window,'disable');
            case 'enable'
                ctrl_enablig = disabling(main_window,'enable',ctrl_enablig);
        end
    end
end
function normalization(hdl)
%recursive function for units normalisation of all controls
    if ~isempty(hdl)
        chldrn = get(hdl,'Children');
        for i=1:length(chldrn)
            normalization(chldrn(i)); %recursive call
            if isfield(set(chldrn(i)),'Units')
                set(chldrn(i),'Unit','normalized');
            end
        end
    end
end
function varargout = disabling(hdl,mode,varargin)
%function for disabling and restoring all controls
handles = guihandles(hdl); 
names = fieldnames(handles);
varargout = {[]};
    if strcmp(mode,'disable')
        for i=1:length(names)
            for j=1:length(handles.(names{i}))
                prev_val.(names{i})(j).val = [];
                if isprop(handles.(names{i})(j),'Enable')
                    prev_val.(names{i})(j).val ...
                        = get(handles.(names{i})(j),'Enable');
                    set(handles.(names{i})(j),'Enable','off');
                end
            end
        end
        varargout{1} = prev_val;
    elseif strcmp(mode,'enable')&&~isempty(varargin{1})
        prev_val = varargin{1};
        if ~isempty(prev_val)
            for i=1:length(names)
                for j=1:length(handles.(names{i}))
                    if isprop(handles.(names{i})(j),'Enable')
                        set(handles.(names{i})(j),'Enable'...
                            ,prev_val.(names{i})(j).val);
                    end
                end
            end
        end
    end
end
