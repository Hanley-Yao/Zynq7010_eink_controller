-------------------------------------------------------------------------------
--
-- File: HS_Negotiation.vhd
-- Author: Gherman Tudor
-- Original Project: USB Device IP on 7-series Xilinx FPGA
-- Date: 2 May 2016
--
-------------------------------------------------------------------------------
-- (c) 2016 Copyright Digilent Incorporated
-- All Rights Reserved
-- 
-- This program is free software; distributed under the terms of BSD 3-clause 
-- license ("Revised BSD License", "New BSD License", or "Modified BSD License")
--
-- Redistribution and use in source and binary forms, with or without modification,
-- are permitted provided that the following conditions are met:
--
-- 1. Redistributions of source code must retain the above copyright notice, this
--    list of conditions and the following disclaimer.
-- 2. Redistributions in binary form must reproduce the above copyright notice,
--    this list of conditions and the following disclaimer in the documentation
--    and/or other materials provided with the distribution.
-- 3. Neither the name(s) of the above-listed copyright holder(s) nor the names
--    of its contributors may be used to endorse or promote products derived
--    from this software without specific prior written permission.
--
-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
-- AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
-- IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
-- ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE 
-- FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
-- DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
-- SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
-- CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
-- OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
-- OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--
-------------------------------------------------------------------------------
--
-- Purpose:
-- This module handles the USB speed negociatian, reset and suspend protocols
--  
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;
USE IEEE.STD_LOGIC_ARITH.ALL;

entity HS_Negotiation is
    Port ( 
              u_Reset : in  STD_LOGIC;
              Ulpi_Clk : in  STD_LOGIC;
	          
	          --command signals used to initiate register read/write, 
	          --NOPID frameworks of the ULPI state machine
			  u_Send_NOPID_CMD : out STD_LOGIC;
			  u_Send_EXTW_CMD : out  STD_LOGIC;
			  u_Send_REGW_CMD : out  STD_LOGIC;
			  u_Send_EXTR_CMD : out  STD_LOGIC;
			  u_Send_REGR_CMD : out  STD_LOGIC;
			  u_Send_STP_CMD : out  STD_LOGIC;
			  u_Send_Last : out  STD_LOGIC;
			  u_Remote_Wake : in  STD_LOGIC;
			  
			  --NOPID data, register data, register address used for
			  --attachment signaling and for chirping
              u_Tx_Data : out STD_LOGIC_VECTOR (7 downto 0);
              u_Tx_Regw_Data : out  STD_LOGIC_VECTOR (7 downto 0);
              u_Tx_Reg_Addr : out  STD_LOGIC_VECTOR (7 downto 0);
			  
			  --inputs from ULPI state machine
			  u_Rx_Cmd_Received : in  STD_LOGIC;
			  u_Tx_Cmd_Done : in STD_LOGIC;
			  
			  --UTMI+ signals			  
			  u_LineState : in  STD_LOGIC_VECTOR (1 downto 0);
			  u_Vbus : in  STD_LOGIC_VECTOR (1 downto 0);			  			
			  
			  -- Negotiation outputs
			  u_USB_Mode : out  STD_LOGIC;
			  u_Not_Connected : OUT std_logic;
			  u_Set_Mode_HS : OUT std_logic;
              u_Set_Mode_FS : OUT std_logic;
              u_Wake : OUT std_logic;
              u_USBCMD_RS : in std_logic;
			  state_ind_hs : out STD_LOGIC_VECTOR(4 downto 0);
			  u_Negociation_Done : out  STD_LOGIC
			  );
end HS_Negotiation;

architecture Behavioral of HS_Negotiation is

constant Const_10Ms	    :	STD_LOGIC_VECTOR (10 downto 0) := "00001100100"; --100
constant Const_20Ms	    :	STD_LOGIC_VECTOR (10 downto 0) := "00011001000"; --200
constant Const_50Ms	    :	STD_LOGIC_VECTOR (10 downto 0) := "00111110100"; --500
constant Const_1_2Ms	:	STD_LOGIC_VECTOR (10 downto 0) := "00000001100"; --12
constant Const_2_5Us	:	STD_LOGIC_VECTOR (12 downto 0) := "0000010010110"; --150 * Ulpi_Clk_period = 2.5Us
constant Const_2_5Ms	:	STD_LOGIC_VECTOR (10 downto 0) := "00000011001"; --25Const_3Ms
constant Const_3Ms	    :	STD_LOGIC_VECTOR (10 downto 0) := "00000011110"; --30
constant Const_200Us	:	STD_LOGIC_VECTOR (10 downto 0) := "00000000010"; --2

type state_type is (IDLE, REGR, EXTR_W, EXTR_R, DISCONNECTED, WAIT_ATTACH, WRITE_FCR, ATTACH, WAIT_RESET, PULL_UP_ID, NORMAL,RST_RES_SUSP, SUSPEND, HS_SUSPEND, FS_SUSPEND, SUSP_RES, RESET, ERROR, SEND_CHIRP_K, WAIT_CHIRP_J, WAIT_CHIRP_K, SEND_CHIRP_K_LAST, WAIT_CHIRP_SE0, SET_FS, SET_HS, SWITCH_FS, FS_WAIT_SE0, FS_WAIT_J, RESUME_REQ_WAIT, WAIT_HSEOP, CLEAR_SUSPEND, SIGNAL_WAKE); -- CLEAR_SUSPEND_COMPLETE
signal u_Negociation_State, u_Negociation_Next_State : state_type;

signal u_RX_J : STD_LOGIC;
signal u_RX_K : STD_LOGIC;
signal u_RX_SE0 : STD_LOGIC;
signal u_RX_Idle : STD_LOGIC;

signal u_Set_Mode_HS_Loc : STD_LOGIC;
signal u_Mode : STD_LOGIC; --1 when the device is in High Speed mode, 0 otherwise
signal u_Negociation_Done_Rst : STD_LOGIC;
signal u_Negociation_Done_Set : STD_LOGIC;
signal u_LineState_q : STD_LOGIC_VECTOR(1 downto 0);
signal u_LineState_Change : STD_LOGIC;

signal u_Cnt1_Us : STD_LOGIC_VECTOR(12 downto 0);
signal u_Cnt1_Ms : STD_LOGIC_VECTOR(10 downto 0);
signal u_Cnt2_Us : STD_LOGIC_VECTOR(12 downto 0);
signal u_Cnt1_Ms_Presc : STD_LOGIC;
signal u_Cnt1_Rst_Ms : STD_LOGIC;-- initial 100ms, chirp_k
signal u_Cnt2_Rst_Ms : STD_LOGIC;
signal u_Cnt_Chirp : STD_LOGIC_VECTOR(3 downto 0) := "0000";
signal u_Cnt_Chirp_CE : STD_LOGIC;
signal u_Cnt_Chirp_Rst : STD_LOGIC;

--degug
signal u_Cnt1_Ms_debug : STD_LOGIC_VECTOR(10 downto 0);

attribute mark_debug : string;
attribute keep : string;
--attribute mark_debug of state_ind_hs_r : signal is "true";
--attribute keep of state_ind_hs_r : signal is "true";
--attribute mark_debug of rst : signal is "true";
--attribute keep of rst : signal is "true";
--attribute mark_debug of u_LineState : signal is "true";
--attribute keep of u_LineState : signal is "true";
--attribute mark_debug of u_Cnt1_Us : signal is "true";
--attribute keep of u_Cnt1_Us : signal is "true";
--attribute mark_debug of u_Cnt1_Ms : signal is "true";
--attribute keep of u_Cnt1_Ms : signal is "true";
--attribute mark_debug of u_RX_Idle : signal is "true";
--attribute keep of u_RX_Idle : signal is "true";
--attribute mark_debug of u_Cnt1_Rst_Ms : signal is "true";
--attribute keep of u_Cnt1_Rst_Ms : signal is "true";
--attribute mark_debug of u_Mode : signal is "true";
--attribute keep of u_Mode : signal is "true";
--attribute mark_debug of u_Cnt1_Ms_debug : signal is "true";
--attribute keep of u_Cnt1_Ms_debug : signal is "true";

begin

u_USB_Mode <= u_Mode;
u_Set_Mode_HS <= u_Set_Mode_HS_Loc;

u_RX_SE0 <= '1' when u_LineState = "00"
				else '0';
u_RX_K <= '1' when u_LineState = "10"
				else '0';				
u_RX_J <= '1' when u_LineState = "01"
				else '0';			
u_RX_Idle <= u_RX_SE0 when u_Mode = '1'
				else u_RX_J;

--debug purposes
delay_cnt: process (Ulpi_Clk)
begin
	if (Ulpi_Clk' event and Ulpi_Clk = '1') then
        u_Cnt1_Ms_debug <= u_Cnt1_Ms;
	end if;
end process;

--detect state machine changes
STATE_CHANGE: process (Ulpi_Clk)
begin
	if (Ulpi_Clk' event and Ulpi_Clk = '1') then
        u_LineState_q <= u_LineState;
        if (u_LineState_q = u_LineState) then
            u_LineState_Change <= '0';
        else
            u_LineState_Change <= '1';
        end if;
	end if;
end process;
	
--u_Mode encodes the negotiated speed			
MODEHS : process (Ulpi_Clk)
begin
	if (Ulpi_Clk' event and Ulpi_Clk = '1') then
		if (u_Reset = '0') then
			u_Mode <= '0';
		else
			if (u_Set_Mode_HS_Loc = '1') then
				u_Mode <= '1';
			end if;
		end if;
	end if;
end process;


NEG_DONE_PROC : process (Ulpi_Clk)
begin
	if (Ulpi_Clk' event and Ulpi_Clk = '1') then
		if (u_Reset = '0' or u_Negociation_Done_Rst = '0') then
			u_Negociation_Done <= '0';
		else
			if (u_Negociation_Done_Set = '1') then
				u_Negociation_Done <= '1';
			end if;
		end if;
	end if;
end process;

--Counters/Timers used to monitor Reset, Suspend, Resume, High Speed Negotiation characteristic intervals
US_COUNTER1: process (Ulpi_Clk)  -- Ulpi_Clk = 60MHz => T = 0.01666666 Us
begin
	if (Ulpi_Clk' event and Ulpi_Clk = '1') then
		if ((u_Cnt1_Rst_Ms = '1') or (u_Reset = '0')) then
			u_Cnt1_Us <= (others => '0');
			u_Cnt1_Ms_Presc <= '0';
		else
			u_Cnt1_Us <= u_Cnt1_Us + '1';
			if (u_Cnt1_Us = 6000) then -- u_Cnt1_Ms_Presc = 100us
				u_Cnt1_Ms_Presc <= '1';
				u_Cnt1_Us <= (others => '0');
			else
				u_Cnt1_Ms_Presc <= '0';
			end if;
		end if;
	end if;
end process;

MS_COUNTER1: process (Ulpi_Clk)
begin
	if (Ulpi_Clk' event and Ulpi_Clk = '1') then
		if (u_Cnt1_Rst_Ms = '1' or (u_Reset = '0')) then
			u_Cnt1_Ms <= (others => '0');
		else
			if (u_Cnt1_Ms_Presc = '1') then
				u_Cnt1_Ms <= u_Cnt1_Ms + '1';
			end if;
		end if;
	end if;
end process;

US_COUNTER2: process (Ulpi_Clk)
begin
	if (Ulpi_Clk' event and Ulpi_Clk = '1') then
		if (u_Cnt2_Rst_Ms = '1' or (u_Reset = '0')) then
			u_Cnt2_Us <= (others => '0');
		else
			u_Cnt2_Us <= u_Cnt2_Us + '1';
			if (u_Cnt2_Us = 6000) then 
				u_Cnt2_Us <= (others => '0');
			end if;
		end if;
	end if;
end process;

CHIRP_COUNTER: process (u_Cnt_Chirp_CE, Ulpi_Clk)
begin
	if (Ulpi_Clk' event and Ulpi_Clk = '1') then
		if (u_Cnt_Chirp_Rst = '1' or (u_Reset = '0')) then
			u_Cnt_Chirp <= (others => '0');
		elsif (u_Cnt_Chirp_CE = '1') then
			u_Cnt_Chirp <= u_Cnt_Chirp + '1';
		end if;
	end if;
end process;

--High Speed Negotiation State Machine
SYNC_PROC: process (Ulpi_Clk)
   begin
      if (Ulpi_Clk' event and Ulpi_Clk = '1') then
         if (u_Reset = '0') then 
            u_Negociation_State <= IDLE;
         else
            u_Negociation_State <= u_Negociation_Next_State;
         end if;        
      end if;
end process;
 
 
NEXT_STATE_DECODE: process (u_Negociation_State, u_Vbus, u_Rx_Cmd_Received, u_USBCMD_RS, u_LineState, u_LineState_Change, u_Tx_Cmd_Done, u_RX_J, u_RX_K, u_RX_Idle, u_RX_SE0, u_Cnt_Chirp, u_Remote_Wake, u_Mode)
   begin
        u_Negociation_Next_State <= u_Negociation_State;  
        state_ind_hs <= "00000";
        u_Tx_Data <= (others => '0');
		u_Cnt1_Rst_Ms <= '1';
		u_Cnt2_Rst_Ms <= '1';
		u_Cnt_Chirp_CE <= '0';
		u_Cnt_Chirp_Rst <= '1';	
		u_Set_Mode_HS_Loc <= '0';
		u_Negociation_Done_Rst <= '1'; 
		u_Negociation_Done_Set <= '0';
		u_Send_REGW_CMD <= '0';
		u_Send_NOPID_CMD <= '0';
		u_Send_Last <= '0';
		u_Tx_Regw_Data <= (others => '0');
	    u_Tx_Reg_Addr <= (others => '0');
		u_Send_REGR_CMD <= '0';
		u_Send_EXTW_CMD <= '0';
		u_Send_EXTR_CMD <= '0';
		u_Send_STP_CMD <= '0';
		u_Not_Connected <= '0';
		u_Set_Mode_FS <= '0';
		u_Wake <= '0'; 
		
      case (u_Negociation_State) is
      
        when IDLE =>
            if (u_USBCMD_RS = '1') then  --Waits for user interaction (USBCMD-> RS bit : Run/Stop) to start negociation
                u_Negociation_Next_State <= DISCONNECTED;
            end if;  
      
         when DISCONNECTED =>
            state_ind_hs <= "00001";
            u_Negociation_Done_Rst <= '0';
            u_Not_Connected <= '1';
            if (u_Vbus = "11") then
                u_Negociation_Next_State <= WAIT_ATTACH;
            end if;
            
         when WAIT_ATTACH =>
            state_ind_hs <= "00010";
            u_Not_Connected <= '1';
         	u_Cnt1_Rst_Ms <= '0';
         	  if ( u_Cnt1_Ms  = Const_50Ms) then -- Debounce interval. Not required by specifications
         	      if (u_Vbus = "11") then
         	          u_Cnt1_Rst_Ms <= '1';
         	          u_Negociation_Next_State <= PULL_UP_ID;
         	      else
         	          u_Negociation_Next_State <= DISCONNECTED;
                  end if;
              end if;
                   
         when PULL_UP_ID =>
                    state_ind_hs <= "00011";
                    u_Send_REGW_CMD <= '1';
                    u_Tx_Reg_Addr(5 downto 0) <= "001010"; --u_Tx_Data (6 downto 0) = OTG control reg write addr
                    u_Tx_Regw_Data <= "00000001";   
                    if (u_Tx_Cmd_Done = '1') then
                        u_Negociation_Next_State <= WRITE_FCR; 
                    end if;
           
         when WRITE_FCR =>
                state_ind_hs <= "00100";
                u_Send_REGW_CMD <= '1';
                u_Tx_Reg_Addr(5 downto 0) <= "000100"; --u_Tx_Data (6 downto 0) = function control reg write addr
                u_Tx_Regw_Data <= "01000101"; --Select peripheral Full Speed driver: opmode = 00, xcvrselect = 01, termselect = 1; the pull-up resistor on D+ will be attached      
		        if (u_Tx_Cmd_Done = '1') then
                    u_Negociation_Next_State <= ATTACH;	
                end if;	
				  
         when ATTACH =>
               state_ind_hs <= "00101";
               if (u_LineState = "01") then
                   u_Negociation_Next_State <= WAIT_RESET;
               end if;
            
         when WAIT_RESET => --the host should detect the pull-up resistor and should place the bus in SE0 state
                state_ind_hs <= "00110";
                u_Cnt1_Rst_Ms <= '0';
                if (u_LineState = "00") then 
                      u_Negociation_Next_State <= NORMAL;
                end if;  
				
         when NORMAL => -- this is the state corresponding to normal operation. The state machine monitors SUSPEND(IDLE) and RESET conditions
                state_ind_hs <= "11111";
				if ( u_LineState_Change = '0') then
				    if (u_RX_Idle = '1') then -- if the device is in high speed mode it can not distinguish between IDLE and SE0 at this point
				        u_Cnt1_Rst_Ms <= '0';
				        if (u_Cnt1_Ms = Const_3Ms) then
				            u_Negociation_Next_State <= RST_RES_SUSP;
				        end if;
				    elsif ((u_RX_SE0 = '1') and (u_Mode = '0')) then --If the device is being reset from a non-suspended full-speed state, then the device begins a high-speed
                                                                    --detection handshake after the detection of SE0 for no less than 2.5 ?s and no more than 3.0 ms
				        u_Cnt1_Rst_Ms <= '0';  
				        if (u_Cnt1_Us  = Const_2_5Us) then
				            u_Send_REGW_CMD <= '1';
				            u_Negociation_Next_State <= RESET;
				        end if; 
				    else
				        u_Cnt1_Rst_Ms <= '1';
				    end if;
				else
				    u_Cnt1_Rst_Ms <= '1';   
				end if;
				
		when RST_RES_SUSP =>	
		        state_ind_hs <= "00111";
				if (u_Mode = '0') then
					u_Negociation_Next_State <= SUSPEND;
				elsif (u_Mode = '1') then
					u_Negociation_Next_State <= SWITCH_FS;
				end if;
--RESET sequence				
			when RESET => --Enter High-speed Detection Handshake. Select peripheral chirp by writing to the PHY FCR
			       state_ind_hs <= "01000";
				   u_Tx_Reg_Addr(5 downto 0) <= "000100"; --u_Tx_Data (6 downto 0) = function control reg write addr
				   u_Tx_Regw_Data <= "01010100"; --opmode = 10, xcvrselect = 00, termselect = 1
				   if (u_Tx_Cmd_Done = '1') then
					  u_Negociation_Next_State <= SEND_CHIRP_K;
				   end if;
				
			when SEND_CHIRP_K =>
			        state_ind_hs <= "01001";
				    u_Cnt1_Rst_Ms <= '0';
				    u_Send_NOPID_CMD <= '1'; --This will instruct the ULPI state machine to send NOPID_CMD with transmit data which is by default 00h (drive current into D-)
				    if (u_Cnt1_Ms  = Const_1_2Ms) then	--The device chirp must last no less than 1.0 ms (TUCH) and must end no more than 7.0 ms (TUCHEND) high-speed Reset time T0.
					   u_Cnt1_Rst_Ms <= '1';
					   u_Send_Last <= '1';
					   u_Negociation_Next_State <= SEND_CHIRP_K_LAST;
				    end if;	
			   
			when SEND_CHIRP_K_LAST =>
			        state_ind_hs <= "01010";
				    --u_Tx_Data <= (others => '0');
				    u_Cnt1_Rst_Ms <= '1';
				    if (u_Rx_Cmd_Received = '1') then
				        if (u_RX_SE0 = '1') then
					       u_Negociation_Next_State <= WAIT_CHIRP_SE0;
				        end if;
				    end if;

--------------------------------------------------------------
			when WAIT_CHIRP_SE0 =>
			        state_ind_hs <= "01011";
			        u_Cnt1_Rst_Ms <= '0'; -- monitor JK timeout
				    if (u_RX_K = '1') then
					   u_Cnt1_Rst_Ms <= '0';
					   u_Cnt2_Rst_Ms <= '0'; -- monitor chirp duration
					   u_Negociation_Next_State <= WAIT_CHIRP_K;
					elsif (u_Cnt1_Ms = Const_2_5Ms) then
					   u_Set_Mode_FS <= '1';
					   u_Negociation_Next_State <= SET_FS;
				    end if;
--------------------------------------------------------------
				
			when WAIT_CHIRP_K =>
			    state_ind_hs <= "01100";
			    u_Cnt_Chirp_Rst <= '0';
			    u_Cnt1_Rst_Ms <= '0'; -- monitor JK timeout
				if (u_RX_K = '1') then
					u_Cnt2_Rst_Ms <= '0'; -- monitor chirp duration
					if (u_Cnt2_Us = Const_2_5Us) then
						if(u_Cnt_Chirp > 5) then
							u_Cnt1_Rst_Ms <= '1';
							u_Send_REGW_CMD <= '1';
							u_Cnt_Chirp_Rst <= '1';
							u_Cnt_Chirp_CE <= '0';
							u_Negociation_Next_State <= SET_HS;					
						else
						    u_Cnt_Chirp_CE <= '1';
							u_Cnt2_Rst_Ms <= '1';
							u_Negociation_Next_State <= WAIT_CHIRP_J;
						end if;
					end if;
				elsif (u_Cnt1_Ms = Const_2_5Ms or u_RX_SE0 = '1') then
					u_Send_REGW_CMD <= '1';
					u_Cnt1_Rst_Ms <= '1';
					u_Cnt2_Rst_Ms <= '1';
					u_Set_Mode_FS <= '1';
					u_Negociation_Next_State <= SET_FS;	  				    					
				end if;
				
			when WAIT_CHIRP_J =>
			    state_ind_hs <= "01101";
			    u_Cnt1_Rst_Ms <= '0'; -- monitor JK timeout
			    u_Cnt_Chirp_Rst <= '0';
				if (u_RX_J = '1') then
					u_Cnt2_Rst_Ms <= '0';  -- monitor chirp duration
					if (u_Cnt2_Us = Const_2_5Us) then
						if(u_Cnt_Chirp > 5) then
							u_Cnt1_Rst_Ms <= '1';
							u_Send_REGW_CMD <= '1';
							u_Cnt_Chirp_Rst <= '1';
							u_Cnt_Chirp_CE <= '0';
							u_Negociation_Next_State <= SET_HS;
						else
							u_Cnt2_Rst_Ms <= '1';
							u_Cnt_Chirp_CE <= '1';
							u_Negociation_Next_State <= WAIT_CHIRP_K;
						end if;
					end if;
				elsif (u_Cnt1_Ms = Const_2_5Ms or u_RX_SE0 = '1') then
					u_Cnt1_Rst_Ms <= '1';
					u_Cnt2_Rst_Ms <= '1';
					u_Send_REGW_CMD <= '1';
					u_Tx_Reg_Addr(5 downto 0) <= "000100"; --u_Tx_Data (6 downto 0) = function control reg write addr
					u_Tx_Regw_Data <= "00000101"; --opmode = 00, xcvrselect = 00, termselect = 1
					u_Set_Mode_FS <= '1';
					u_Negociation_Next_State <= SET_FS;				
				end if;					
				
			when SET_FS =>	
			        state_ind_hs <= "01110";
				    u_Tx_Reg_Addr(5 downto 0) <= "000100"; --u_Tx_Data (6 downto 0) = function control reg write addr
				    u_Tx_Regw_Data <= "01000101"; --opmode = 00, xcvrselect = 01, termselect = 1
				    u_Send_REGW_CMD <= '1';
				    if (u_Tx_Cmd_Done = '1') then
				       u_Negociation_Done_Set <= '1';
					   u_Negociation_Next_State <= NORMAL;
				    end if;

			when SET_HS =>
			        state_ind_hs <= "01111";
				    u_Tx_Reg_Addr(5 downto 0) <= "000100"; --u_Tx_Data (6 downto 0) = function control reg write addr
				    u_Tx_Regw_Data <= "01000000"; --opmode = 00, xcvrselect = 00, termselect = 0
				    u_Set_Mode_HS_Loc <= '1';
				    u_Send_REGW_CMD <= '1';
				    if (u_Tx_Cmd_Done = '1') then
				       u_Negociation_Done_Set <= '1';
					   u_Negociation_Next_State <= NORMAL;
				    end if;		
			
---SUSPEND/RESUME  -- Not Tested!
			when SWITCH_FS =>	-- Select peripherla Full Speed by writing to FCR
                    u_Negociation_Done_Rst <= '0';
			        state_ind_hs <= "10000";
				    u_Cnt1_Rst_Ms <= '0';
				    u_Send_REGW_CMD <= '1';
				    u_Tx_Reg_Addr(5 downto 0) <= "000100"; --u_Tx_Data (6 downto 0) = function control reg write addr
				    u_Tx_Regw_Data <= "01000101"; --opmode = 00, xcvrselect = 01, termselect = 1
				    if (u_Tx_Cmd_Done = '1') then
					   u_Negociation_Next_State <= SUSP_RES;
				    end if;
				
			when SUSP_RES =>
			        state_ind_hs <= "10001";
				    u_Cnt1_Rst_Ms <= '0'; 
				    if (u_Cnt1_Ms = Const_200Us) then --The device samples the bus state, and checks for SE0 (reset as opposed to suspend), no less than 100 �s and no more than 875 �s (TWTRSTHS) after starting reversion to full-speed.
					   if( u_RX_SE0 = '1') then
						  u_Cnt1_Rst_Ms <= '1';
						  u_Send_REGW_CMD <= '1';
						  u_Negociation_Next_State <= RESET;
					   elsif (u_RX_J = '1') then
						  u_Cnt1_Rst_Ms <= '1';
						  u_Negociation_Next_State <= SUSPEND;
					   else	
					      u_Cnt1_Rst_Ms <= '1';
					      u_Negociation_Next_State <= DISCONNECTED;  
					   end if;
				    end if;
			
			when SUSPEND =>
			        state_ind_hs <= "10010";
					u_Send_REGW_CMD <= '1';
					u_Tx_Reg_Addr(5 downto 0) <= "000100"; --u_Tx_Data (6 downto 0) = function control reg set addr
					u_Tx_Regw_Data <= "00010101"; --set suspendM
					if (u_Tx_Cmd_Done = '1') then
					   if (u_Mode = '1') then
						  u_Negociation_Next_State <= HS_SUSPEND;
					   else
						  u_Negociation_Next_State <= FS_SUSPEND;
					   end if;
					end if;
					
			when FS_SUSPEND =>
			    state_ind_hs <= "10011";
				if (u_RX_K = '1') then
				    u_Cnt1_Rst_Ms <= '0';
					if (u_Cnt1_Ms = Const_20Ms) then
						u_Cnt1_Rst_Ms <= '1';
						u_Negociation_Next_State <= FS_WAIT_SE0;
					end if;
				elsif (u_RX_SE0 = '1')then
					u_Cnt1_Rst_Ms <= '0';
					if (u_Cnt1_Us = Const_2_5Us) then
						u_Send_REGW_CMD <= '1';
						u_Negociation_Next_State <= RESET;
					end if;
				elsif (u_Remote_Wake = '1') then -- 3ms to enter suspend + 2ms 
				    u_Send_STP_CMD <= '1';
					u_Negociation_Next_State <= CLEAR_SUSPEND;
				else
					u_Cnt1_Rst_Ms <= '1';			
				end if;
			
			when HS_SUSPEND =>
			    state_ind_hs <= "10100";
				if (u_RX_K = '1') then
				    u_Cnt1_Rst_Ms <= '0';
				    state_ind_hs <= "11110";
					if (u_Cnt1_Ms = Const_20Ms) then
						u_Cnt1_Rst_Ms <= '1';
						u_Negociation_Next_State <= WAIT_HSEOP;
					end if;
				elsif (u_RX_SE0 = '1')then
					u_Cnt1_Rst_Ms <= '0';
                    if (u_Cnt1_Us = Const_2_5Us) then
					    state_ind_hs <= "11101";
						u_Cnt1_Rst_Ms <= '1';
						u_Send_REGW_CMD <= '1';
						u_Negociation_Next_State <= RESET;
					end if;
				elsif (u_Remote_Wake = '1') then -- 3ms to enter suspend + 2ms 
					   u_Send_STP_CMD <= '1';
					   u_Negociation_Next_State <= CLEAR_SUSPEND;
				else
				    state_ind_hs <= "11100";
					u_Cnt1_Rst_Ms <= '1';			
				end if;
								
			when FS_WAIT_SE0 =>
			    state_ind_hs <= "10101";
				if (u_RX_SE0 = '1') then
					u_Negociation_Next_State <= FS_WAIT_J;
				end if;
				
			when FS_WAIT_J =>
			    state_ind_hs <= "10110";
				if (u_RX_J = '1') then
					u_Send_REGW_CMD <= '1';
					u_Set_Mode_FS <= '1';
					u_Wake <= '1';
					u_Negociation_Next_State <= SET_FS;
				else
					u_Negociation_Next_State <= ERROR;
				end if;
				
			when WAIT_HSEOP =>
			    state_ind_hs <= "10111";
				if (u_RX_SE0 = '1') then
					u_Send_REGW_CMD <= '1';
					u_Wake <= '1';
					u_Negociation_Next_State <= SET_HS;
				end if;

            when CLEAR_SUSPEND =>
                state_ind_hs <= "11001";
                u_Send_REGW_CMD <= '1'; 
                u_Tx_Reg_Addr(5 downto 0) <= "000100";
                u_Tx_Regw_Data <= "01010101";  
                if (u_Tx_Cmd_Done = '1') then
                    u_Negociation_Next_State <= SIGNAL_WAKE;
                end if;
             
            when SIGNAL_WAKE =>
                state_ind_hs <= "11010";
                u_Send_NOPID_CMD <= '1';
                u_Tx_Data <= "11111111";
                u_Cnt1_Rst_Ms <= '0';  
                if (u_Cnt1_Ms = Const_10Ms) then
                    u_Send_Last <= '1';
                    if (u_Tx_Cmd_Done = '1') then
                        u_Cnt1_Rst_Ms <= '1';
                        u_Negociation_Next_State <= RESUME_REQ_WAIT;
                    end if;
                end if;
            
			when RESUME_REQ_WAIT =>
			    state_ind_hs <= "11011";
			    u_Cnt1_Rst_Ms <= '0';
			    if (u_RX_K = '1') then
			         u_Negociation_Next_State <= WAIT_HSEOP;
			    end if;
			
         when others =>
            u_Negociation_Next_State <= DISCONNECTED;
      end case;      
end process;

end Behavioral;
