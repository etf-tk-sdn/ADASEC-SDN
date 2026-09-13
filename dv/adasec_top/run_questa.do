set project_dir [file normalize [pwd]]
set script_dir [file join $project_dir dv adasec_top]
set work_dir [file join /tmp adasec_top_questa_work]

if {![file exists [file join $project_dir rtl adasec_top.sv]]} {
    error "run_questa.do must be launched from the ADASEC-SDN project root"
}

if {![file isdirectory $work_dir]} {
    vlib $work_dir
}

vlog -sv -work $work_dir \
    [file join $project_dir rtl avalon_if.sv] \
    [file join $project_dir rtl dual_port_ram.sv] \
    [file join $project_dir rtl key_vector.sv] \
    [file join $project_dir rtl key_provider.sv] \
    [file join $project_dir rtl switch2x2.sv] \
    [file join $project_dir rtl stage.sv] \
    [file join $project_dir rtl axis_register.v] \
    [file join $project_dir rtl axis_pipeline_register.sv] \
    [file join $project_dir rtl avalon_pipeline_register.sv] \
    [file join $project_dir rtl key_scheduler.sv] \
    [file join $project_dir rtl encryption_block.sv] \
    [file join $project_dir rtl adasec_top.sv] \
    [file join $script_dir adasec_top_tb.sv]

vsim -lib $work_dir adasec_top_tb
run -all
quit -f
