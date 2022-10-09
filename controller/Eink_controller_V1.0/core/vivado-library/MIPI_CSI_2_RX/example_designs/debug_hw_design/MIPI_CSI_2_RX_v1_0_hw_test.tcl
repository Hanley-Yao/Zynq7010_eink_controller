# Runtime Tcl commands to interact with - MIPI_CSI_2_RX_v1_0

# Sourcing design address info tcl
set bd_path [get_property DIRECTORY [current_project]]/[current_project].srcs/[current_fileset]/bd
source ${bd_path}/MIPI_CSI_2_RX_v1_0_include.tcl

# jtag axi master interface hardware name, change as per your design.
set jtag_axi_master hw_axi_1
set ec 0

# hw test script
# Delete all previous axis transactions
if { [llength [get_hw_axi_txns -quiet]] } {
	delete_hw_axi_txn [get_hw_axi_txns -quiet]
}


# Test all lite slaves.
set wdata_1 abcd1234

# Test: S_AXI_LITE
# Create a write transaction at s_axi_lite_addr address
create_hw_axi_txn w_s_axi_lite_addr [get_hw_axis $jtag_axi_master] -type write -address $s_axi_lite_addr -data $wdata_1
# Create a read transaction at s_axi_lite_addr address
create_hw_axi_txn r_s_axi_lite_addr [get_hw_axis $jtag_axi_master] -type read -address $s_axi_lite_addr
# Initiate transactions
run_hw_axi r_s_axi_lite_addr
run_hw_axi w_s_axi_lite_addr
run_hw_axi r_s_axi_lite_addr
set rdata_tmp [get_property DATA [get_hw_axi_txn r_s_axi_lite_addr]]
# Compare read data
if { $rdata_tmp == $wdata_1 } {
	puts "Data comparison test pass for - S_AXI_LITE"
} else {
	puts "Data comparison test fail for - S_AXI_LITE, expected-$wdata_1 actual-$rdata_tmp"
	inc ec
}

# Test: S_AXI_INTR
set intr_test 0                                                                                             
# Global interrupt register address                                                                                
set glob_intr_reg $s_axi_intr_addr                                                                                 
# interrupt enable register address                                                                                
set intr_en_reg [format 0x%x [expr {$s_axi_intr_addr + 0x4}]]                                                     
# status register address                                                                                          
set sts_reg [format 0x%x [expr {$s_axi_intr_addr + 0x8}]]                                                         
# interrupt acknowledgement register address                                                                       
set intr_ack_reg [format 0x%x [expr {$s_axi_intr_addr + 0xC}]]                                                    
# pending register address                                                                                         
set pending_reg [format 0x%x [expr {$s_axi_intr_addr + 0x10}]]                                                     

# create a write transaction at global intr en reg                                                          
create_hw_axi_txn glob_intr_w [get_hw_axis $jtag_axi_master] -type write -address $glob_intr_reg  -data {00000001} 
# create a read transaction at global intr en reg                                                                  
create_hw_axi_txn glob_intr_r [get_hw_axis $jtag_axi_master] -type read -address $glob_intr_reg                    
# Enable global intr enable                                                                                        
run_hw_axi glob_intr_w                                                                                             
run_hw_axi glob_intr_r                                                                                             
set rdata_tmp [get_property DATA [get_hw_axi_txn glob_intr_r]]                                                     
if { $rdata_tmp != 00000001 } {                                                                                    
	puts "S_AXI_INTR - global intr enable register not set, expected-00000001 actual-$rdata_tmp"                 
	inc intr_test                                                                                                  
}                                                                                                                  

# create a write transaction at intr en reg                                                                 
create_hw_axi_txn intr_en_w [get_hw_axis $jtag_axi_master] -type write -address $intr_en_reg  -data {00000001}     
# create a read transaction at intr en reg                                                                         
create_hw_axi_txn intr_en_r [get_hw_axis $jtag_axi_master] -type read -address $intr_en_reg                        
# Enable intr by writing to bit 0 of intr reg [0]                                                                  
run_hw_axi intr_en_w                                                                                               
run_hw_axi intr_en_r                                                                                               
set rdata_tmp [get_property DATA [get_hw_axi_txn intr_en_r]]                                                       
if { $rdata_tmp != 00000001 } {                                                                                    
	puts "S_AXI_INTR - intr enable register not set, expected-00000001 actual-$rdata_tmp"                        
	inc intr_test                                                                                                  
}                                                                                                                  

# create a read transaction at intr sts reg                                                                 
create_hw_axi_txn sts_r [get_hw_axis $jtag_axi_master] -type read -address $sts_reg                                
# Read intr status reg. Bit 0 being 1 marks an intr condition has occurred. (should be 0x00000001)                 
run_hw_axi sts_r                                                                                                   
set rdata_tmp [get_property DATA [get_hw_axi_txn sts_r]]                                                           
if { $rdata_tmp != 00000001 } {                                                                                    
	puts "S_AXI_INTR - check status register, intr condition has not occurred, expected-00000001 actual-$rdata_tmp"
	inc intr_test                                                                                                  
}                                                                                                                  

# create a read transaction at pending reg                                                                  
create_hw_axi_txn pending_r [get_hw_axis $jtag_axi_master] -type read -address $pending_reg                        
# Read pending reg bit 0 (should be 0x00000001)                                                                    
run_hw_axi pending_r                                                                                               
set rdata_tmp [get_property DATA [get_hw_axi_txn pending_r]]                                                       
if { $rdata_tmp != 00000001 } {                                                                                    
	puts "S_AXI_INTR - Read pending reg bit 0, expected-00000001 actual-$rdata_tmp"                              
	inc intr_test                                                                                                  
}                                                                                                                  

# create a read transaction at gpio reg                                                                     
create_hw_axi_txn irq_r [get_hw_axis $jtag_axi_master] -type read -address $axi_gpio_irq_addr                      
# read gpio reg bit 0 to see if IRQ has been captured                                                              
run_hw_axi irq_r                                                                                                   
set rdata_tmp [get_property DATA [get_hw_axi_txn irq_r]]                                                           
if { $rdata_tmp != 00000001 } {                                                                                    
	puts "S_AXI_INTR - Read pending reg bit 0 to check if IRQ has been captured, expected-00000001 actual-$rdata_tmp"
	inc intr_test                                                                                                  
}                                                                                                                 

# Once intr has been detected, disable the intr enable reg bit 0 and acknowledge the interrupt by writing 1 to bit 0
set_property DATA 00000000 [get_hw_axi_txn intr_en_w]                                                              
run_hw_axi intr_en_w                                                                                               

# create a write transaction at intr ack reg                                                                
create_hw_axi_txn intr_ack_w [get_hw_axis $jtag_axi_master] -type write -address $intr_ack_reg  -data {00000001}   
#acknowledgement                                                                                                   
run_hw_axi intr_ack_w                                                                                              

# Read pending reg to see if there are no pending reg (should be 0x00000000)                                
run_hw_axi pending_r                                                                                               
set rdata_tmp [get_property DATA [get_hw_axi_txn pending_r]]                                                       
if { $rdata_tmp != 00000000 } {                                                                                    
	puts "S_AXI_INTR - Read pending reg, expected-00000000 actual-$rdata_tmp"                                    
	inc intr_test                                                                                                  
}                                                                                                                  

# Read gpio reg to see the IRQ has been cleared (should be 0x00000000)                                      
run_hw_axi irq_r                                                                                                   
set rdata_tmp [get_property DATA [get_hw_axi_txn irq_r]]                                                           
if { $rdata_tmp != 00000000 } {                                                                                    
	puts "S_AXI_INTR - Check if IRQ has been cleared, expected-00000000 actual-$rdata_tmp"                       
	inc intr_test                                                                                                  
}                                                                                                                  

# Compare read data                                                                                         
if { $intr_test == 0 } {                                                                                           
	puts "Test pass for - S_AXI_INTR"                                                                            
} else {                                                                                                           
	puts "Test fail for - S_AXI_INTR"                                                                            
	inc ec                                                                                                         
}

# Check error flag
if { $ec == 0 } {
	 puts "PTGEN_TEST: PASSED!" 
} else {
	 puts "PTGEN_TEST: FAILED!" 
}

