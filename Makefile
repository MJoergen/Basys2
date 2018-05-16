XILINX_DIR = /opt/Xilinx/14.7/ISE_DS
ENV = . $(XILINX_DIR)/settings64.sh

# The first target in the Makefile is default.
# It is a convention to use the target 'all'.
# The .PHONY tag instructs the make-command
# to not look for a file named 'all'.
.PHONY: all
all: comp.bit

# The first prerequisite must be comp.scr, because the tag $< refers to this.
comp.ngc: comp.scr comp.vhd comp.prj
	$(ENV); xst -ifn $<
# The 'junk' variable is just a list of the generated output files.
junk += comp.lso comp.ngc comp.ngc_xst.xrpt comp.srp xst

comp.ngd: comp.ngc comp.ucf
	$(ENV); ngdbuild $<
junk += comp.bld comp.ngd comp_ngdbuild.xrpt netlist.lst xlnx_auto_0_xdb/

comp.ncd: comp.ngd
	$(ENV); map $<
junk += _xmsgs comp.map comp.mrp	comp.ncd comp.ngm comp.pcf comp_map.xrpt comp_usage.xml

comp_par.ncd: comp.ncd
	$(ENV); par -w $< $@
junk += comp_par.ncd comp_par.pad comp_par_pad.csv comp_par_pad.txt comp_par.par comp_par.ptwx comp_par.unroutes comp_par.xpi comp_par.xrpt comp_summary.xml

comp.bit: comp_par.ncd
	$(ENV); bitgen -w $< $@
junk += comp.bgn comp.bit comp_bitgen.xwbt comp.drc usage_statistics_webtalk.html webtalk.log

clean:
	rm -f -r $(junk)
