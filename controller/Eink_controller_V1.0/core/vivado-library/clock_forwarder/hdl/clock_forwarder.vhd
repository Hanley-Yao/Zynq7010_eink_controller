library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

Library UNISIM;
use UNISIM.vcomponents.all;

entity clock_forwarder is
    generic (
        kArch : string := "artix7"
    );
	port (
	  aRst : in std_logic;
	  InClk : in std_logic;
	  iCE : in std_logic;
	  OutClk : out std_logic
	);
end clock_forwarder;

architecture arch_imp of clock_forwarder is
begin

zynquplus: if kArch = "zynquplus" or kArch = "kintexuplus" or kArch = "virtexuplus" generate
begin
    ODDRE1_inst : ODDRE1
    generic map (
       IS_C_INVERTED => '0',  -- Optional inversion for C
       IS_D1_INVERTED => '0', -- Unsupported, do not use
       IS_D2_INVERTED => '0', -- Unsupported, do not use
       SRVAL => '0'           -- Initializes the ODDRE1 Flip-Flops to the specified value ('0', '1')
    )
    port map (
       Q => OutClk,   -- 1-bit output: Data output to IOB
       C => InClk,   -- 1-bit input: High-speed clock input
       D1 => '1', -- 1-bit input: Parallel data input 1
       D2 => '0', -- 1-bit input: Parallel data input 2
       SR => aRst  -- 1-bit input: Active High Async Reset
    );
end generate zynquplus;

nonzynquplus: if not (kArch = "zynquplus" or kArch = "kintexuplus" or kArch = "virtexuplus") generate
begin
    ODDR_inst : ODDR
    generic map(
       DDR_CLK_EDGE => "SAME_EDGE",
       INIT => '0',   -- Initial value for Q port ('1' or '0')
       SRTYPE => "ASYNC") -- Reset Type ("ASYNC" or "SYNC")
    port map (
       Q => OutClk,   -- 1-bit DDR output
       C => InClk,    -- 1-bit clock input
       CE => iCE,  -- 1-bit clock enable input
       D1 => '1',  -- 1-bit data input (positive edge)
       D2 => '0',  -- 1-bit data input (negative edge)
       R => aRst,    -- 1-bit reset input
       S => '0'     -- 1-bit set input
    );
end generate nonzynquplus;

end arch_imp;
