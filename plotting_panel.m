function pnhdl = plotting_panel(pr_hdl,pst,glb_fcts)
%panel functions
pnhdl.refresh = @refresh;

%panel creation and positioning
dflt_size = [1200 300];
unts = get(pr_hdl,'Unit');
rsz_fc = resize_factor(pst,unts,dflt_size);
panel_hdl = uipanel('Parent',pr_hdl,'Unit',unts,'Position',pst...
    ,'Tag','plotting_panel');
pnhdl.hndl = panel_hdl;

%subpanel for picture calibration and calculation of areas
pnl_calib = calibration_plotting_subpanel(panel_hdl,[0 0 600 300].*rsz_fc...
    ,glb_fcts);

%subpanes for picture modification preview
pnl_prev  = preview_plotting_subpanel(panel_hdl,[600 0 600 300].*rsz_fc...
    ,glb_fcts);
%functions passed from pnl_prev
pnhdl.modification_preview  = pnl_prev.modification_preview;
pnhdl.get_preview_data      = pnl_prev.get_preview_data;

    function refresh()
        pnl_calib.refresh();
        pnl_prev.refresh();
    end
end