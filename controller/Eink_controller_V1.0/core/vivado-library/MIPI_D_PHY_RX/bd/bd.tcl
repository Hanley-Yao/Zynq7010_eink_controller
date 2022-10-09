
proc init { cellpath otherInfo } {                                                                   
                                                                                                             
	set cell_handle [get_bd_cells $cellpath]                                                                 
	set all_busif [get_bd_intf_pins $cellpath/*]		                                                     
	set axi_standard_param_list [list ID_WIDTH AWUSER_WIDTH ARUSER_WIDTH WUSER_WIDTH RUSER_WIDTH BUSER_WIDTH]
	set full_sbusif_list [list ]
			                                                                                                 
	foreach busif $all_busif {                                                                               
		if { [string equal -nocase [get_property MODE $busif] "slave"] == 1 } {                            
			set busif_param_list [list]                                                                      
			set busif_name [get_property NAME $busif]					                                     
			if { [lsearch -exact -nocase $full_sbusif_list $busif_name ] == -1 } {					         
			    continue                                                                                     
			}                                                                                                
			foreach tparam $axi_standard_param_list {                                                        
				lappend busif_param_list "C_${busif_name}_${tparam}"                                       
			}                                                                        
			bd::mark_propagate_only $cell_handle $busif_param_list			                                 
		}		                                                                                             
	}
	bd::mark_propagate_only $cell_handle C_dphy_hs_clk_FREQ_HZ                                                                                                       
}


proc pre_propagate {cellpath otherInfo } {                                                           
                                                                                                             
	set cell_handle [get_bd_cells $cellpath]                                                                 
	set all_busif [get_bd_intf_pins $cellpath/*]		                                                     
	set axi_standard_param_list [list ID_WIDTH AWUSER_WIDTH ARUSER_WIDTH WUSER_WIDTH RUSER_WIDTH BUSER_WIDTH]
	                                                                                                         
	foreach busif $all_busif {	                                                                             
		if { [string equal -nocase [get_property CONFIG.PROTOCOL $busif] "AXI4"] != 1 } {                  
			continue                                                                                         
		}                                                                                                    
		if { [string equal -nocase [get_property MODE $busif] "master"] != 1 } {                           
			continue                                                                                         
		}			                                                                                         
		                                                                                                     
		set busif_name [get_property NAME $busif]			                                                 
		foreach tparam $axi_standard_param_list {		                                                     
			set busif_param_name "C_${busif_name}_${tparam}"			                                     
			                                                                                                 
			set val_on_cell_intf_pin [get_property CONFIG.${tparam} $busif]                                  
			set val_on_cell [get_property CONFIG.${busif_param_name} $cell_handle]                           
			                                                                                                 
			if { [string equal -nocase $val_on_cell_intf_pin $val_on_cell] != 1 } {                          
				if { $val_on_cell != "" } {                                                                  
					set_property CONFIG.${tparam} $val_on_cell $busif                                        
				}                                                                                            
			}			                                                                                     
		}		                                                                                             
	}                                                                                            
}


proc propagate {cellpath otherInfo } {                                                               
                                                                                                             
	set cell_handle [get_bd_cells $cellpath]                                                                 
	set all_busif [get_bd_intf_pins $cellpath/*]		                                                     
	set axi_standard_param_list [list ID_WIDTH AWUSER_WIDTH ARUSER_WIDTH WUSER_WIDTH RUSER_WIDTH BUSER_WIDTH]
	                                                                                                         
	foreach busif $all_busif {                                                                               
		if { [string equal -nocase [get_property CONFIG.PROTOCOL $busif] "AXI4"] != 1 } {                  
			continue                                                                                         
		}                                                                                                    
		if { [string equal -nocase [get_property MODE $busif] "slave"] != 1 } {                            
			continue                                                                                         
		}			                                                                                         
	                                                                                                         
		set busif_name [get_property NAME $busif]		                                                     
		foreach tparam $axi_standard_param_list {			                                                 
			set busif_param_name "C_${busif_name}_${tparam}"			                                     
                                                                                                             
			set val_on_cell_intf_pin [get_property CONFIG.${tparam} $busif]                                  
			set val_on_cell [get_property CONFIG.${busif_param_name} $cell_handle]                           
			                                                                                                 
			if { [string equal -nocase $val_on_cell_intf_pin $val_on_cell] != 1 } {                          
				#override property of bd_interface_net to bd_cell -- only for slaves.  May check for supported values..
				if { $val_on_cell_intf_pin != "" } {                                                         
					set_property CONFIG.${busif_param_name} $val_on_cell_intf_pin $cell_handle               
				}                                                                                            
			}                                                                                                
		}		                                                                                             
	}
 	# Propagate from one interface to the other
	set dphy_clk [get_property CONFIG.FREQ_HZ [get_bd_intf_pins $cellpath/dphy_hs_clock]]
	if { $dphy_clk != "" } {
      set byte_clk [expr int($dphy_clk) / 4]
      set_property CONFIG.FREQ_HZ $byte_clk [get_bd_pins $cellpath/RxByteClkHS]
   }                                                                                                         
}

# Do FREQ_HZ propagation here
proc post_propagate {cellpath otherInfo } {
   set ip [get_bd_cells $cellpath]
   set ref_clk_offset 10000000
   set ref_clk_expected 200000000
   
   set clk_lite [get_property CONFIG.FREQ_HZ [get_bd_pins $ip/s_axi_lite_aclk]]
   set clk_lite_domain [get_property CONFIG.CLK_DOMAIN [get_bd_pins $ip/s_axi_lite_aclk]]
   set clk_lite_phase [get_property CONFIG.PHASE [get_bd_pins $ip/s_axi_lite_aclk]]
   
   set ref_clk [get_property CONFIG.FREQ_HZ [get_bd_pins $ip/RefClk]]
   set ref_clk_domain [get_property CONFIG.CLK_DOMAIN [get_bd_pins $ip/RefClk]]
   set ref_clk_phase [get_property CONFIG.PHASE [get_bd_pins $ip/RefClk]]
   
   set byte_clk [get_property CONFIG.FREQ_HZ [get_bd_pins $ip/RxByteClkHS]]
      
   if { $clk_lite == "" } {
      set_property MSG.ERROR "Please connect a valid clock signal to s_axi_lite_aclk" $ip
   } else {
      set_property CONFIG.C_S_AXI_LITE_FREQ_HZ [expr int($clk_lite)] $ip
      bd::send_msg -of $cellpath -type INFO -msg_id 17 -text "FREQ_HZ of $clk_lite propagated into CONFIG.C_S_AXI_LITE_FREQ_HZ"
   }
   
   if { $ref_clk == "" } {
      set_property MSG.ERROR "Please connect a valid 200MHz clock signal to RefClk" $ip
   } elseif { [expr {abs($ref_clk - $ref_clk_expected)}] > $ref_clk_offset} {
      set_property MSG.ERROR "RefClk frequency must be in the range of 200MHz +-10MHz" $ip
   } else {
      set_property CONFIG.kRefClkFreqHz [expr int($ref_clk)] $ip
      bd::send_msg -of $cellpath -type INFO -msg_id 17 -text "FREQ_HZ of $ref_clk propagated into CONFIG.kRefClkFreqHz"
   }

   if { $byte_clk != "" } {
      bd::send_msg -of $cellpath -type INFO -msg_id 17 -text "FREQ_HZ of $byte_clk propagated onto RxByteClkHS"
   }
      
   set vlnv [get_property VLNV $ip]
   set ver [split [lindex [split $vlnv :] 3] .]
   set ver_major [lindex $ver 0]
   set ver_minor [lindex $ver 1]
   set_property CONFIG.kVersionMajor [expr int($ver_major)] $ip
   set_property CONFIG.kVersionMinor [expr int($ver_minor)] $ip
}
