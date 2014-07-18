
# PlanAhead Launch Script for Post PAR Floorplanning, created by Project Navigator

create_project -name FDA_FPGA_Verilog -dir "C:/Users/Schuyler/Documents/GitHub/FDA_FPGA_Verilog/planAhead_run_4" -part xc6slx9tqg144-3
set srcset [get_property srcset [current_run -impl]]
set_property design_mode GateLvl $srcset
set_property edif_top_file "C:/Users/Schuyler/Documents/GitHub/FDA_FPGA_Verilog/FDA_top.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {C:/Users/Schuyler/Documents/GitHub/FDA_FPGA_Verilog} {ipcore_dir} }
add_files [list {ipcore_dir/ADC_ROM.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {ipcore_dir/Counter24Bit_Up.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {ipcore_dir/CounterUp_4BitLoadable.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {ipcore_dir/Counter_4Bit.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {ipcore_dir/Counter_5Bit.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {ipcore_dir/Fifi_8_bit.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {ipcore_dir/FifoFast2Slow.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {ipcore_dir/FIFO_10bit.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {ipcore_dir/FIFO_11bit.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {ipcore_dir/FIFO_32to8.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {ipcore_dir/Fifo_adder.ncf}] -fileset [get_property constrset [current_run]]
add_files [list {ipcore_dir/UART_FIFO.ncf}] -fileset [get_property constrset [current_run]]
set_property target_constrs_file "FDA_top.ucf" [current_fileset -constrset]
add_files [list {FDA_top.ucf}] -fileset [get_property constrset [current_run]]
link_design
read_xdl -file "C:/Users/Schuyler/Documents/GitHub/FDA_FPGA_Verilog/FDA_top.ncd"
if {[catch {read_twx -name results_1 -file "C:/Users/Schuyler/Documents/GitHub/FDA_FPGA_Verilog/FDA_top.twx"} eInfo]} {
   puts "WARNING: there was a problem importing \"C:/Users/Schuyler/Documents/GitHub/FDA_FPGA_Verilog/FDA_top.twx\": $eInfo"
}
