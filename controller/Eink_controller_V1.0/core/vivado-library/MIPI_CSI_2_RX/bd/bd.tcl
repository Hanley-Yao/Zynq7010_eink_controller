
proc init { cellpath otherInfo } {                                                                   
                                                                                                             
	set cell_handle [get_bd_cells $cellpath]                                                                 
	set all_busif [get_bd_intf_pins $cellpath/*]		                                                     
	set axi_standard_param_list [list ID_WIDTH AWUSER_WIDTH ARUSER_WIDTH WUSER_WIDTH RUSER_WIDTH BUSER_WIDTH]
	set full_sbusif_list [list  ]
			                                                                                                 
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
}

# Do FREQ_HZ propagation here
proc post_propagate {cellpath otherInfo } {
   set ip [get_bd_cells $cellpath]
   
   set vlnv [get_property VLNV $ip]
   set ver [split [lindex [split $vlnv :] 3] .]
   set ver_major [lindex $ver 0]
   set ver_minor [lindex $ver 1]
   set_property CONFIG.kVersionMajor [expr int($ver_major)] $ip
   set_property CONFIG.kVersionMinor [expr int($ver_minor)] $ip
   
   set byte_clk [get_property CONFIG.FREQ_HZ [get_bd_pins $ip/RxByteClkHS]]
   set byte_clk_domain [get_property CONFIG.CLK_DOMAIN [get_bd_pins $ip/RxByteClkHS]]
   set byte_clk_phase [get_property CONFIG.PHASE [get_bd_pins $ip/RxByteClkHS]]
   
   set video_aclk [get_property CONFIG.FREQ_HZ [get_bd_pins $ip/video_aclk]]
   set video_aclk_domain [get_property CONFIG.CLK_DOMAIN [get_bd_pins $ip/video_aclk]]
   set video_aclk_phase [get_property CONFIG.PHASE [get_bd_pins $ip/video_aclk]]
   
   if { $byte_clk == "" } {
      set_property MSG.ERROR "Please connect a valid clock signal to RxByteClkHS" $ip
      return
   }
   if { $video_aclk == "" } {
      set_property MSG.ERROR "Please connect a valid clock signal to video_aclk" $ip
      return
   }
   
   set kLaneCount [get_property CONFIG.kLaneCount $ip]
   set kMaxSamplesPerClock [get_property CONFIG.C_M_MAX_SAMPLES_PER_CLOCK $ip]
   set kTargetDT [get_property CONFIG.kTargetDT $ip]
   set bytes_per_px [eval {switch -nocase $kTargetDT {
      RAW10 {expr {1.25}}
      default {expr {0}}
   }}]
   if { $bytes_per_px == 0 } then {
      set_property MSG.ERROR "Unknown data type: $kTargetDT" $ip
      return
   }
   set input_rate [expr int($byte_clk)*int($kLaneCount)/$bytes_per_px]
   set output_rate [expr int($video_aclk)*int($kMaxSamplesPerClock)]
   if { $input_rate > $output_rate } then {
      set_property MSG.ERROR [concat "video_aclk frequency is too small to handle RxByteClkHS frequency. Minimum frequency " [expr $input_rate/int($kMaxSamplesPerClock)] "Hz."] $ip
   } else {
      bd::send_msg -of $cellpath -type INFO -msg_id 17 -text "Verified that video_aclk frequency can handle RxByteClkHS frequency. AXI-Stream bandwidth $output_rate Pix/s >= PPI bandwidth $input_rate Pix/s"
   }   
   
}
