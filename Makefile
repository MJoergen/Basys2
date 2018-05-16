XILINX_DIR = /opt/Xilinx/14.7/ISE_DS
ENV = . $(XILINX_DIR)/settings64.sh

comp.ngc: comp.scr comp.vhd
	$(ENV); xst -ifn comp.scr

comp.ngd: comp.ngc
	$(ENV); ngdbuild $<

comp.ncd: comp.ngd
	$(ENV); map $<

comp_par.ncd: comp.ncd
	$(ENV); par -w $< $@

comp.bit: comp_par.ncd
	$(ENV); bitgen -w $< $@

clean:
	rm -f -r comp.bgn comp.bit comp_bitgen.xwbt comp.bld comp.drc comp.lso comp.map comp_map.xrpt comp.mrp comp.ncd comp.ngc comp.ngc_xst.xrpt comp.ngd comp_ngdbuild.xrpt comp.ngm comp_par.ncd comp_par.pad comp_par_pad.csv comp_par_pad.txt comp_par.par comp_par.ptwx comp_par.unroutes comp_par.xpi comp_par.xrpt comp.pcf comp.srp comp_summary.xml comp_usage.xml netlist.lst usage_statistics_webtalk.html webtalk.log xlnx_auto_0_xdb _xmsgs xst 