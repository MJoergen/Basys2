XILINX_DIR = /opt/Xilinx/14.7/ISE_DS
ENV = . $(XILINX_DIR)/settings64.sh

# The first target in the Makefile is default.
# It is a convention to use the target 'all'.
#
# The .PHONY tag instructs the make-command
# to not look for a file named 'all'.
#
# The variable $< refers to the first of the prerequisites
# The variable $@ refers to the generated output file
#
# The 'junk' variable is just a list of the generated output files.

.PHONY: all
all: comp.bit


#################################################
# Stage 1 : Synthesize (compile) the source files
#################################################
comp.ngc: comp.scr comp.vhd comp.prj
	$(ENV); xst -ifn $<

junk += comp.lso comp.ngc comp.ngc_xst.xrpt comp.srp xst


#################################################
# Stage 2 : Add pin locations and timing constraints
#################################################
comp.ngd: comp.ngc comp.ucf
	$(ENV); ngdbuild $<

junk += comp.bld comp.ngd comp_ngdbuild.xrpt netlist.lst xlnx_auto_0_xdb/


#################################################
# Stage 3 : Map to FPGA-specific features
#################################################
comp.ncd: comp.ngd
	$(ENV); map $<

junk += _xmsgs comp.map comp.mrp	comp.ncd comp.ngm comp.pcf comp_map.xrpt comp_usage.xml


#################################################
# Stage 4 : Place-And-Route
#################################################
comp_par.ncd: comp.ncd
	$(ENV); par -w $< $@

junk += comp_par.ncd comp_par.pad comp_par_pad.csv comp_par_pad.txt comp_par.par comp_par.ptwx comp_par.unroutes comp_par.xpi comp_par.xrpt comp_summary.xml


#################################################
# Stage 5 : Generate bit-file
#################################################
comp.bit: comp_par.ncd
	$(ENV); bitgen -w $< $@

junk += comp.bgn comp.bit comp_bitgen.xwbt comp.drc usage_statistics_webtalk.html webtalk.log

clean:
	rm -f -r $(junk)

