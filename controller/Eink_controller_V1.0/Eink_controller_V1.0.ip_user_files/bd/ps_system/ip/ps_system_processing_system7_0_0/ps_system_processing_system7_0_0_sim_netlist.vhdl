-- Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2020.2 (win64) Build 3064766 Wed Nov 18 09:12:45 MST 2020
-- Date        : Mon Jan 24 18:21:25 2022
-- Host        : Duller running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode funcsim -rename_top ps_system_processing_system7_0_0 -prefix
--               ps_system_processing_system7_0_0_ ps_system_processing_system7_0_0_sim_netlist.vhdl
-- Design      : ps_system_processing_system7_0_0
-- Purpose     : This VHDL netlist is a functional simulation representation of the design and should not be modified or
--               synthesized. This netlist cannot be used for SDF annotated simulation.
-- Device      : xc7z010clg400-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity ps_system_processing_system7_0_0_processing_system7_v5_5_processing_system7 is
  port (
    CAN0_PHY_TX : out STD_LOGIC;
    CAN0_PHY_RX : in STD_LOGIC;
    CAN1_PHY_TX : out STD_LOGIC;
    CAN1_PHY_RX : in STD_LOGIC;
    ENET0_GMII_TX_EN : out STD_LOGIC;
    ENET0_GMII_TX_ER : out STD_LOGIC;
    ENET0_MDIO_MDC : out STD_LOGIC;
    ENET0_MDIO_O : out STD_LOGIC;
    ENET0_MDIO_T : out STD_LOGIC;
    ENET0_PTP_DELAY_REQ_RX : out STD_LOGIC;
    ENET0_PTP_DELAY_REQ_TX : out STD_LOGIC;
    ENET0_PTP_PDELAY_REQ_RX : out STD_LOGIC;
    ENET0_PTP_PDELAY_REQ_TX : out STD_LOGIC;
    ENET0_PTP_PDELAY_RESP_RX : out STD_LOGIC;
    ENET0_PTP_PDELAY_RESP_TX : out STD_LOGIC;
    ENET0_PTP_SYNC_FRAME_RX : out STD_LOGIC;
    ENET0_PTP_SYNC_FRAME_TX : out STD_LOGIC;
    ENET0_SOF_RX : out STD_LOGIC;
    ENET0_SOF_TX : out STD_LOGIC;
    ENET0_GMII_TXD : out STD_LOGIC_VECTOR ( 7 downto 0 );
    ENET0_GMII_COL : in STD_LOGIC;
    ENET0_GMII_CRS : in STD_LOGIC;
    ENET0_GMII_RX_CLK : in STD_LOGIC;
    ENET0_GMII_RX_DV : in STD_LOGIC;
    ENET0_GMII_RX_ER : in STD_LOGIC;
    ENET0_GMII_TX_CLK : in STD_LOGIC;
    ENET0_MDIO_I : in STD_LOGIC;
    ENET0_EXT_INTIN : in STD_LOGIC;
    ENET0_GMII_RXD : in STD_LOGIC_VECTOR ( 7 downto 0 );
    ENET1_GMII_TX_EN : out STD_LOGIC;
    ENET1_GMII_TX_ER : out STD_LOGIC;
    ENET1_MDIO_MDC : out STD_LOGIC;
    ENET1_MDIO_O : out STD_LOGIC;
    ENET1_MDIO_T : out STD_LOGIC;
    ENET1_PTP_DELAY_REQ_RX : out STD_LOGIC;
    ENET1_PTP_DELAY_REQ_TX : out STD_LOGIC;
    ENET1_PTP_PDELAY_REQ_RX : out STD_LOGIC;
    ENET1_PTP_PDELAY_REQ_TX : out STD_LOGIC;
    ENET1_PTP_PDELAY_RESP_RX : out STD_LOGIC;
    ENET1_PTP_PDELAY_RESP_TX : out STD_LOGIC;
    ENET1_PTP_SYNC_FRAME_RX : out STD_LOGIC;
    ENET1_PTP_SYNC_FRAME_TX : out STD_LOGIC;
    ENET1_SOF_RX : out STD_LOGIC;
    ENET1_SOF_TX : out STD_LOGIC;
    ENET1_GMII_TXD : out STD_LOGIC_VECTOR ( 7 downto 0 );
    ENET1_GMII_COL : in STD_LOGIC;
    ENET1_GMII_CRS : in STD_LOGIC;
    ENET1_GMII_RX_CLK : in STD_LOGIC;
    ENET1_GMII_RX_DV : in STD_LOGIC;
    ENET1_GMII_RX_ER : in STD_LOGIC;
    ENET1_GMII_TX_CLK : in STD_LOGIC;
    ENET1_MDIO_I : in STD_LOGIC;
    ENET1_EXT_INTIN : in STD_LOGIC;
    ENET1_GMII_RXD : in STD_LOGIC_VECTOR ( 7 downto 0 );
    GPIO_I : in STD_LOGIC_VECTOR ( 63 downto 0 );
    GPIO_O : out STD_LOGIC_VECTOR ( 63 downto 0 );
    GPIO_T : out STD_LOGIC_VECTOR ( 63 downto 0 );
    I2C0_SDA_I : in STD_LOGIC;
    I2C0_SDA_O : out STD_LOGIC;
    I2C0_SDA_T : out STD_LOGIC;
    I2C0_SCL_I : in STD_LOGIC;
    I2C0_SCL_O : out STD_LOGIC;
    I2C0_SCL_T : out STD_LOGIC;
    I2C1_SDA_I : in STD_LOGIC;
    I2C1_SDA_O : out STD_LOGIC;
    I2C1_SDA_T : out STD_LOGIC;
    I2C1_SCL_I : in STD_LOGIC;
    I2C1_SCL_O : out STD_LOGIC;
    I2C1_SCL_T : out STD_LOGIC;
    PJTAG_TCK : in STD_LOGIC;
    PJTAG_TMS : in STD_LOGIC;
    PJTAG_TDI : in STD_LOGIC;
    PJTAG_TDO : out STD_LOGIC;
    SDIO0_CLK : out STD_LOGIC;
    SDIO0_CLK_FB : in STD_LOGIC;
    SDIO0_CMD_O : out STD_LOGIC;
    SDIO0_CMD_I : in STD_LOGIC;
    SDIO0_CMD_T : out STD_LOGIC;
    SDIO0_DATA_I : in STD_LOGIC_VECTOR ( 3 downto 0 );
    SDIO0_DATA_O : out STD_LOGIC_VECTOR ( 3 downto 0 );
    SDIO0_DATA_T : out STD_LOGIC_VECTOR ( 3 downto 0 );
    SDIO0_LED : out STD_LOGIC;
    SDIO0_CDN : in STD_LOGIC;
    SDIO0_WP : in STD_LOGIC;
    SDIO0_BUSPOW : out STD_LOGIC;
    SDIO0_BUSVOLT : out STD_LOGIC_VECTOR ( 2 downto 0 );
    SDIO1_CLK : out STD_LOGIC;
    SDIO1_CLK_FB : in STD_LOGIC;
    SDIO1_CMD_O : out STD_LOGIC;
    SDIO1_CMD_I : in STD_LOGIC;
    SDIO1_CMD_T : out STD_LOGIC;
    SDIO1_DATA_I : in STD_LOGIC_VECTOR ( 3 downto 0 );
    SDIO1_DATA_O : out STD_LOGIC_VECTOR ( 3 downto 0 );
    SDIO1_DATA_T : out STD_LOGIC_VECTOR ( 3 downto 0 );
    SDIO1_LED : out STD_LOGIC;
    SDIO1_CDN : in STD_LOGIC;
    SDIO1_WP : in STD_LOGIC;
    SDIO1_BUSPOW : out STD_LOGIC;
    SDIO1_BUSVOLT : out STD_LOGIC_VECTOR ( 2 downto 0 );
    SPI0_SCLK_I : in STD_LOGIC;
    SPI0_SCLK_O : out STD_LOGIC;
    SPI0_SCLK_T : out STD_LOGIC;
    SPI0_MOSI_I : in STD_LOGIC;
    SPI0_MOSI_O : out STD_LOGIC;
    SPI0_MOSI_T : out STD_LOGIC;
    SPI0_MISO_I : in STD_LOGIC;
    SPI0_MISO_O : out STD_LOGIC;
    SPI0_MISO_T : out STD_LOGIC;
    SPI0_SS_I : in STD_LOGIC;
    SPI0_SS_O : out STD_LOGIC;
    SPI0_SS1_O : out STD_LOGIC;
    SPI0_SS2_O : out STD_LOGIC;
    SPI0_SS_T : out STD_LOGIC;
    SPI1_SCLK_I : in STD_LOGIC;
    SPI1_SCLK_O : out STD_LOGIC;
    SPI1_SCLK_T : out STD_LOGIC;
    SPI1_MOSI_I : in STD_LOGIC;
    SPI1_MOSI_O : out STD_LOGIC;
    SPI1_MOSI_T : out STD_LOGIC;
    SPI1_MISO_I : in STD_LOGIC;
    SPI1_MISO_O : out STD_LOGIC;
    SPI1_MISO_T : out STD_LOGIC;
    SPI1_SS_I : in STD_LOGIC;
    SPI1_SS_O : out STD_LOGIC;
    SPI1_SS1_O : out STD_LOGIC;
    SPI1_SS2_O : out STD_LOGIC;
    SPI1_SS_T : out STD_LOGIC;
    UART0_DTRN : out STD_LOGIC;
    UART0_RTSN : out STD_LOGIC;
    UART0_TX : out STD_LOGIC;
    UART0_CTSN : in STD_LOGIC;
    UART0_DCDN : in STD_LOGIC;
    UART0_DSRN : in STD_LOGIC;
    UART0_RIN : in STD_LOGIC;
    UART0_RX : in STD_LOGIC;
    UART1_DTRN : out STD_LOGIC;
    UART1_RTSN : out STD_LOGIC;
    UART1_TX : out STD_LOGIC;
    UART1_CTSN : in STD_LOGIC;
    UART1_DCDN : in STD_LOGIC;
    UART1_DSRN : in STD_LOGIC;
    UART1_RIN : in STD_LOGIC;
    UART1_RX : in STD_LOGIC;
    TTC0_WAVE0_OUT : out STD_LOGIC;
    TTC0_WAVE1_OUT : out STD_LOGIC;
    TTC0_WAVE2_OUT : out STD_LOGIC;
    TTC0_CLK0_IN : in STD_LOGIC;
    TTC0_CLK1_IN : in STD_LOGIC;
    TTC0_CLK2_IN : in STD_LOGIC;
    TTC1_WAVE0_OUT : out STD_LOGIC;
    TTC1_WAVE1_OUT : out STD_LOGIC;
    TTC1_WAVE2_OUT : out STD_LOGIC;
    TTC1_CLK0_IN : in STD_LOGIC;
    TTC1_CLK1_IN : in STD_LOGIC;
    TTC1_CLK2_IN : in STD_LOGIC;
    WDT_CLK_IN : in STD_LOGIC;
    WDT_RST_OUT : out STD_LOGIC;
    TRACE_CLK : in STD_LOGIC;
    TRACE_CTL : out STD_LOGIC;
    TRACE_DATA : out STD_LOGIC_VECTOR ( 1 downto 0 );
    TRACE_CLK_OUT : out STD_LOGIC;
    USB0_PORT_INDCTL : out STD_LOGIC_VECTOR ( 1 downto 0 );
    USB0_VBUS_PWRSELECT : out STD_LOGIC;
    USB0_VBUS_PWRFAULT : in STD_LOGIC;
    USB1_PORT_INDCTL : out STD_LOGIC_VECTOR ( 1 downto 0 );
    USB1_VBUS_PWRSELECT : out STD_LOGIC;
    USB1_VBUS_PWRFAULT : in STD_LOGIC;
    SRAM_INTIN : in STD_LOGIC;
    M_AXI_GP0_ARESETN : out STD_LOGIC;
    M_AXI_GP0_ARVALID : out STD_LOGIC;
    M_AXI_GP0_AWVALID : out STD_LOGIC;
    M_AXI_GP0_BREADY : out STD_LOGIC;
    M_AXI_GP0_RREADY : out STD_LOGIC;
    M_AXI_GP0_WLAST : out STD_LOGIC;
    M_AXI_GP0_WVALID : out STD_LOGIC;
    M_AXI_GP0_ARID : out STD_LOGIC_VECTOR ( 11 downto 0 );
    M_AXI_GP0_AWID : out STD_LOGIC_VECTOR ( 11 downto 0 );
    M_AXI_GP0_WID : out STD_LOGIC_VECTOR ( 11 downto 0 );
    M_AXI_GP0_ARBURST : out STD_LOGIC_VECTOR ( 1 downto 0 );
    M_AXI_GP0_ARLOCK : out STD_LOGIC_VECTOR ( 1 downto 0 );
    M_AXI_GP0_ARSIZE : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M_AXI_GP0_AWBURST : out STD_LOGIC_VECTOR ( 1 downto 0 );
    M_AXI_GP0_AWLOCK : out STD_LOGIC_VECTOR ( 1 downto 0 );
    M_AXI_GP0_AWSIZE : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M_AXI_GP0_ARPROT : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M_AXI_GP0_AWPROT : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M_AXI_GP0_ARADDR : out STD_LOGIC_VECTOR ( 31 downto 0 );
    M_AXI_GP0_AWADDR : out STD_LOGIC_VECTOR ( 31 downto 0 );
    M_AXI_GP0_WDATA : out STD_LOGIC_VECTOR ( 31 downto 0 );
    M_AXI_GP0_ARCACHE : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M_AXI_GP0_ARLEN : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M_AXI_GP0_ARQOS : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M_AXI_GP0_AWCACHE : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M_AXI_GP0_AWLEN : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M_AXI_GP0_AWQOS : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M_AXI_GP0_WSTRB : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M_AXI_GP0_ACLK : in STD_LOGIC;
    M_AXI_GP0_ARREADY : in STD_LOGIC;
    M_AXI_GP0_AWREADY : in STD_LOGIC;
    M_AXI_GP0_BVALID : in STD_LOGIC;
    M_AXI_GP0_RLAST : in STD_LOGIC;
    M_AXI_GP0_RVALID : in STD_LOGIC;
    M_AXI_GP0_WREADY : in STD_LOGIC;
    M_AXI_GP0_BID : in STD_LOGIC_VECTOR ( 11 downto 0 );
    M_AXI_GP0_RID : in STD_LOGIC_VECTOR ( 11 downto 0 );
    M_AXI_GP0_BRESP : in STD_LOGIC_VECTOR ( 1 downto 0 );
    M_AXI_GP0_RRESP : in STD_LOGIC_VECTOR ( 1 downto 0 );
    M_AXI_GP0_RDATA : in STD_LOGIC_VECTOR ( 31 downto 0 );
    M_AXI_GP1_ARESETN : out STD_LOGIC;
    M_AXI_GP1_ARVALID : out STD_LOGIC;
    M_AXI_GP1_AWVALID : out STD_LOGIC;
    M_AXI_GP1_BREADY : out STD_LOGIC;
    M_AXI_GP1_RREADY : out STD_LOGIC;
    M_AXI_GP1_WLAST : out STD_LOGIC;
    M_AXI_GP1_WVALID : out STD_LOGIC;
    M_AXI_GP1_ARID : out STD_LOGIC_VECTOR ( 11 downto 0 );
    M_AXI_GP1_AWID : out STD_LOGIC_VECTOR ( 11 downto 0 );
    M_AXI_GP1_WID : out STD_LOGIC_VECTOR ( 11 downto 0 );
    M_AXI_GP1_ARBURST : out STD_LOGIC_VECTOR ( 1 downto 0 );
    M_AXI_GP1_ARLOCK : out STD_LOGIC_VECTOR ( 1 downto 0 );
    M_AXI_GP1_ARSIZE : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M_AXI_GP1_AWBURST : out STD_LOGIC_VECTOR ( 1 downto 0 );
    M_AXI_GP1_AWLOCK : out STD_LOGIC_VECTOR ( 1 downto 0 );
    M_AXI_GP1_AWSIZE : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M_AXI_GP1_ARPROT : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M_AXI_GP1_AWPROT : out STD_LOGIC_VECTOR ( 2 downto 0 );
    M_AXI_GP1_ARADDR : out STD_LOGIC_VECTOR ( 31 downto 0 );
    M_AXI_GP1_AWADDR : out STD_LOGIC_VECTOR ( 31 downto 0 );
    M_AXI_GP1_WDATA : out STD_LOGIC_VECTOR ( 31 downto 0 );
    M_AXI_GP1_ARCACHE : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M_AXI_GP1_ARLEN : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M_AXI_GP1_ARQOS : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M_AXI_GP1_AWCACHE : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M_AXI_GP1_AWLEN : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M_AXI_GP1_AWQOS : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M_AXI_GP1_WSTRB : out STD_LOGIC_VECTOR ( 3 downto 0 );
    M_AXI_GP1_ACLK : in STD_LOGIC;
    M_AXI_GP1_ARREADY : in STD_LOGIC;
    M_AXI_GP1_AWREADY : in STD_LOGIC;
    M_AXI_GP1_BVALID : in STD_LOGIC;
    M_AXI_GP1_RLAST : in STD_LOGIC;
    M_AXI_GP1_RVALID : in STD_LOGIC;
    M_AXI_GP1_WREADY : in STD_LOGIC;
    M_AXI_GP1_BID : in STD_LOGIC_VECTOR ( 11 downto 0 );
    M_AXI_GP1_RID : in STD_LOGIC_VECTOR ( 11 downto 0 );
    M_AXI_GP1_BRESP : in STD_LOGIC_VECTOR ( 1 downto 0 );
    M_AXI_GP1_RRESP : in STD_LOGIC_VECTOR ( 1 downto 0 );
    M_AXI_GP1_RDATA : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S_AXI_GP0_ARESETN : out STD_LOGIC;
    S_AXI_GP0_ARREADY : out STD_LOGIC;
    S_AXI_GP0_AWREADY : out STD_LOGIC;
    S_AXI_GP0_BVALID : out STD_LOGIC;
    S_AXI_GP0_RLAST : out STD_LOGIC;
    S_AXI_GP0_RVALID : out STD_LOGIC;
    S_AXI_GP0_WREADY : out STD_LOGIC;
    S_AXI_GP0_BRESP : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S_AXI_GP0_RRESP : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S_AXI_GP0_RDATA : out STD_LOGIC_VECTOR ( 31 downto 0 );
    S_AXI_GP0_BID : out STD_LOGIC_VECTOR ( 5 downto 0 );
    S_AXI_GP0_RID : out STD_LOGIC_VECTOR ( 5 downto 0 );
    S_AXI_GP0_ACLK : in STD_LOGIC;
    S_AXI_GP0_ARVALID : in STD_LOGIC;
    S_AXI_GP0_AWVALID : in STD_LOGIC;
    S_AXI_GP0_BREADY : in STD_LOGIC;
    S_AXI_GP0_RREADY : in STD_LOGIC;
    S_AXI_GP0_WLAST : in STD_LOGIC;
    S_AXI_GP0_WVALID : in STD_LOGIC;
    S_AXI_GP0_ARBURST : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S_AXI_GP0_ARLOCK : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S_AXI_GP0_ARSIZE : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S_AXI_GP0_AWBURST : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S_AXI_GP0_AWLOCK : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S_AXI_GP0_AWSIZE : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S_AXI_GP0_ARPROT : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S_AXI_GP0_AWPROT : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S_AXI_GP0_ARADDR : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S_AXI_GP0_AWADDR : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S_AXI_GP0_WDATA : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S_AXI_GP0_ARCACHE : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AXI_GP0_ARLEN : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AXI_GP0_ARQOS : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AXI_GP0_AWCACHE : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AXI_GP0_AWLEN : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AXI_GP0_AWQOS : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AXI_GP0_WSTRB : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AXI_GP0_ARID : in STD_LOGIC_VECTOR ( 5 downto 0 );
    S_AXI_GP0_AWID : in STD_LOGIC_VECTOR ( 5 downto 0 );
    S_AXI_GP0_WID : in STD_LOGIC_VECTOR ( 5 downto 0 );
    S_AXI_GP1_ARESETN : out STD_LOGIC;
    S_AXI_GP1_ARREADY : out STD_LOGIC;
    S_AXI_GP1_AWREADY : out STD_LOGIC;
    S_AXI_GP1_BVALID : out STD_LOGIC;
    S_AXI_GP1_RLAST : out STD_LOGIC;
    S_AXI_GP1_RVALID : out STD_LOGIC;
    S_AXI_GP1_WREADY : out STD_LOGIC;
    S_AXI_GP1_BRESP : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S_AXI_GP1_RRESP : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S_AXI_GP1_RDATA : out STD_LOGIC_VECTOR ( 31 downto 0 );
    S_AXI_GP1_BID : out STD_LOGIC_VECTOR ( 5 downto 0 );
    S_AXI_GP1_RID : out STD_LOGIC_VECTOR ( 5 downto 0 );
    S_AXI_GP1_ACLK : in STD_LOGIC;
    S_AXI_GP1_ARVALID : in STD_LOGIC;
    S_AXI_GP1_AWVALID : in STD_LOGIC;
    S_AXI_GP1_BREADY : in STD_LOGIC;
    S_AXI_GP1_RREADY : in STD_LOGIC;
    S_AXI_GP1_WLAST : in STD_LOGIC;
    S_AXI_GP1_WVALID : in STD_LOGIC;
    S_AXI_GP1_ARBURST : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S_AXI_GP1_ARLOCK : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S_AXI_GP1_ARSIZE : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S_AXI_GP1_AWBURST : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S_AXI_GP1_AWLOCK : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S_AXI_GP1_AWSIZE : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S_AXI_GP1_ARPROT : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S_AXI_GP1_AWPROT : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S_AXI_GP1_ARADDR : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S_AXI_GP1_AWADDR : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S_AXI_GP1_WDATA : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S_AXI_GP1_ARCACHE : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AXI_GP1_ARLEN : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AXI_GP1_ARQOS : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AXI_GP1_AWCACHE : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AXI_GP1_AWLEN : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AXI_GP1_AWQOS : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AXI_GP1_WSTRB : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AXI_GP1_ARID : in STD_LOGIC_VECTOR ( 5 downto 0 );
    S_AXI_GP1_AWID : in STD_LOGIC_VECTOR ( 5 downto 0 );
    S_AXI_GP1_WID : in STD_LOGIC_VECTOR ( 5 downto 0 );
    S_AXI_ACP_ARESETN : out STD_LOGIC;
    S_AXI_ACP_ARREADY : out STD_LOGIC;
    S_AXI_ACP_AWREADY : out STD_LOGIC;
    S_AXI_ACP_BVALID : out STD_LOGIC;
    S_AXI_ACP_RLAST : out STD_LOGIC;
    S_AXI_ACP_RVALID : out STD_LOGIC;
    S_AXI_ACP_WREADY : out STD_LOGIC;
    S_AXI_ACP_BRESP : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S_AXI_ACP_RRESP : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S_AXI_ACP_BID : out STD_LOGIC_VECTOR ( 2 downto 0 );
    S_AXI_ACP_RID : out STD_LOGIC_VECTOR ( 2 downto 0 );
    S_AXI_ACP_RDATA : out STD_LOGIC_VECTOR ( 63 downto 0 );
    S_AXI_ACP_ACLK : in STD_LOGIC;
    S_AXI_ACP_ARVALID : in STD_LOGIC;
    S_AXI_ACP_AWVALID : in STD_LOGIC;
    S_AXI_ACP_BREADY : in STD_LOGIC;
    S_AXI_ACP_RREADY : in STD_LOGIC;
    S_AXI_ACP_WLAST : in STD_LOGIC;
    S_AXI_ACP_WVALID : in STD_LOGIC;
    S_AXI_ACP_ARID : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S_AXI_ACP_ARPROT : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S_AXI_ACP_AWID : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S_AXI_ACP_AWPROT : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S_AXI_ACP_WID : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S_AXI_ACP_ARADDR : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S_AXI_ACP_AWADDR : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S_AXI_ACP_ARCACHE : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AXI_ACP_ARLEN : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AXI_ACP_ARQOS : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AXI_ACP_AWCACHE : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AXI_ACP_AWLEN : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AXI_ACP_AWQOS : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AXI_ACP_ARBURST : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S_AXI_ACP_ARLOCK : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S_AXI_ACP_ARSIZE : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S_AXI_ACP_AWBURST : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S_AXI_ACP_AWLOCK : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S_AXI_ACP_AWSIZE : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S_AXI_ACP_ARUSER : in STD_LOGIC_VECTOR ( 4 downto 0 );
    S_AXI_ACP_AWUSER : in STD_LOGIC_VECTOR ( 4 downto 0 );
    S_AXI_ACP_WDATA : in STD_LOGIC_VECTOR ( 63 downto 0 );
    S_AXI_ACP_WSTRB : in STD_LOGIC_VECTOR ( 7 downto 0 );
    S_AXI_HP0_ARESETN : out STD_LOGIC;
    S_AXI_HP0_ARREADY : out STD_LOGIC;
    S_AXI_HP0_AWREADY : out STD_LOGIC;
    S_AXI_HP0_BVALID : out STD_LOGIC;
    S_AXI_HP0_RLAST : out STD_LOGIC;
    S_AXI_HP0_RVALID : out STD_LOGIC;
    S_AXI_HP0_WREADY : out STD_LOGIC;
    S_AXI_HP0_BRESP : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S_AXI_HP0_RRESP : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S_AXI_HP0_BID : out STD_LOGIC_VECTOR ( 5 downto 0 );
    S_AXI_HP0_RID : out STD_LOGIC_VECTOR ( 5 downto 0 );
    S_AXI_HP0_RDATA : out STD_LOGIC_VECTOR ( 63 downto 0 );
    S_AXI_HP0_RCOUNT : out STD_LOGIC_VECTOR ( 7 downto 0 );
    S_AXI_HP0_WCOUNT : out STD_LOGIC_VECTOR ( 7 downto 0 );
    S_AXI_HP0_RACOUNT : out STD_LOGIC_VECTOR ( 2 downto 0 );
    S_AXI_HP0_WACOUNT : out STD_LOGIC_VECTOR ( 5 downto 0 );
    S_AXI_HP0_ACLK : in STD_LOGIC;
    S_AXI_HP0_ARVALID : in STD_LOGIC;
    S_AXI_HP0_AWVALID : in STD_LOGIC;
    S_AXI_HP0_BREADY : in STD_LOGIC;
    S_AXI_HP0_RDISSUECAP1_EN : in STD_LOGIC;
    S_AXI_HP0_RREADY : in STD_LOGIC;
    S_AXI_HP0_WLAST : in STD_LOGIC;
    S_AXI_HP0_WRISSUECAP1_EN : in STD_LOGIC;
    S_AXI_HP0_WVALID : in STD_LOGIC;
    S_AXI_HP0_ARBURST : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S_AXI_HP0_ARLOCK : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S_AXI_HP0_ARSIZE : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S_AXI_HP0_AWBURST : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S_AXI_HP0_AWLOCK : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S_AXI_HP0_AWSIZE : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S_AXI_HP0_ARPROT : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S_AXI_HP0_AWPROT : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S_AXI_HP0_ARADDR : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S_AXI_HP0_AWADDR : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S_AXI_HP0_ARCACHE : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AXI_HP0_ARLEN : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AXI_HP0_ARQOS : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AXI_HP0_AWCACHE : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AXI_HP0_AWLEN : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AXI_HP0_AWQOS : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AXI_HP0_ARID : in STD_LOGIC_VECTOR ( 5 downto 0 );
    S_AXI_HP0_AWID : in STD_LOGIC_VECTOR ( 5 downto 0 );
    S_AXI_HP0_WID : in STD_LOGIC_VECTOR ( 5 downto 0 );
    S_AXI_HP0_WDATA : in STD_LOGIC_VECTOR ( 63 downto 0 );
    S_AXI_HP0_WSTRB : in STD_LOGIC_VECTOR ( 7 downto 0 );
    S_AXI_HP1_ARESETN : out STD_LOGIC;
    S_AXI_HP1_ARREADY : out STD_LOGIC;
    S_AXI_HP1_AWREADY : out STD_LOGIC;
    S_AXI_HP1_BVALID : out STD_LOGIC;
    S_AXI_HP1_RLAST : out STD_LOGIC;
    S_AXI_HP1_RVALID : out STD_LOGIC;
    S_AXI_HP1_WREADY : out STD_LOGIC;
    S_AXI_HP1_BRESP : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S_AXI_HP1_RRESP : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S_AXI_HP1_BID : out STD_LOGIC_VECTOR ( 5 downto 0 );
    S_AXI_HP1_RID : out STD_LOGIC_VECTOR ( 5 downto 0 );
    S_AXI_HP1_RDATA : out STD_LOGIC_VECTOR ( 63 downto 0 );
    S_AXI_HP1_RCOUNT : out STD_LOGIC_VECTOR ( 7 downto 0 );
    S_AXI_HP1_WCOUNT : out STD_LOGIC_VECTOR ( 7 downto 0 );
    S_AXI_HP1_RACOUNT : out STD_LOGIC_VECTOR ( 2 downto 0 );
    S_AXI_HP1_WACOUNT : out STD_LOGIC_VECTOR ( 5 downto 0 );
    S_AXI_HP1_ACLK : in STD_LOGIC;
    S_AXI_HP1_ARVALID : in STD_LOGIC;
    S_AXI_HP1_AWVALID : in STD_LOGIC;
    S_AXI_HP1_BREADY : in STD_LOGIC;
    S_AXI_HP1_RDISSUECAP1_EN : in STD_LOGIC;
    S_AXI_HP1_RREADY : in STD_LOGIC;
    S_AXI_HP1_WLAST : in STD_LOGIC;
    S_AXI_HP1_WRISSUECAP1_EN : in STD_LOGIC;
    S_AXI_HP1_WVALID : in STD_LOGIC;
    S_AXI_HP1_ARBURST : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S_AXI_HP1_ARLOCK : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S_AXI_HP1_ARSIZE : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S_AXI_HP1_AWBURST : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S_AXI_HP1_AWLOCK : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S_AXI_HP1_AWSIZE : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S_AXI_HP1_ARPROT : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S_AXI_HP1_AWPROT : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S_AXI_HP1_ARADDR : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S_AXI_HP1_AWADDR : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S_AXI_HP1_ARCACHE : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AXI_HP1_ARLEN : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AXI_HP1_ARQOS : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AXI_HP1_AWCACHE : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AXI_HP1_AWLEN : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AXI_HP1_AWQOS : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AXI_HP1_ARID : in STD_LOGIC_VECTOR ( 5 downto 0 );
    S_AXI_HP1_AWID : in STD_LOGIC_VECTOR ( 5 downto 0 );
    S_AXI_HP1_WID : in STD_LOGIC_VECTOR ( 5 downto 0 );
    S_AXI_HP1_WDATA : in STD_LOGIC_VECTOR ( 63 downto 0 );
    S_AXI_HP1_WSTRB : in STD_LOGIC_VECTOR ( 7 downto 0 );
    S_AXI_HP2_ARESETN : out STD_LOGIC;
    S_AXI_HP2_ARREADY : out STD_LOGIC;
    S_AXI_HP2_AWREADY : out STD_LOGIC;
    S_AXI_HP2_BVALID : out STD_LOGIC;
    S_AXI_HP2_RLAST : out STD_LOGIC;
    S_AXI_HP2_RVALID : out STD_LOGIC;
    S_AXI_HP2_WREADY : out STD_LOGIC;
    S_AXI_HP2_BRESP : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S_AXI_HP2_RRESP : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S_AXI_HP2_BID : out STD_LOGIC_VECTOR ( 5 downto 0 );
    S_AXI_HP2_RID : out STD_LOGIC_VECTOR ( 5 downto 0 );
    S_AXI_HP2_RDATA : out STD_LOGIC_VECTOR ( 63 downto 0 );
    S_AXI_HP2_RCOUNT : out STD_LOGIC_VECTOR ( 7 downto 0 );
    S_AXI_HP2_WCOUNT : out STD_LOGIC_VECTOR ( 7 downto 0 );
    S_AXI_HP2_RACOUNT : out STD_LOGIC_VECTOR ( 2 downto 0 );
    S_AXI_HP2_WACOUNT : out STD_LOGIC_VECTOR ( 5 downto 0 );
    S_AXI_HP2_ACLK : in STD_LOGIC;
    S_AXI_HP2_ARVALID : in STD_LOGIC;
    S_AXI_HP2_AWVALID : in STD_LOGIC;
    S_AXI_HP2_BREADY : in STD_LOGIC;
    S_AXI_HP2_RDISSUECAP1_EN : in STD_LOGIC;
    S_AXI_HP2_RREADY : in STD_LOGIC;
    S_AXI_HP2_WLAST : in STD_LOGIC;
    S_AXI_HP2_WRISSUECAP1_EN : in STD_LOGIC;
    S_AXI_HP2_WVALID : in STD_LOGIC;
    S_AXI_HP2_ARBURST : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S_AXI_HP2_ARLOCK : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S_AXI_HP2_ARSIZE : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S_AXI_HP2_AWBURST : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S_AXI_HP2_AWLOCK : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S_AXI_HP2_AWSIZE : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S_AXI_HP2_ARPROT : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S_AXI_HP2_AWPROT : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S_AXI_HP2_ARADDR : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S_AXI_HP2_AWADDR : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S_AXI_HP2_ARCACHE : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AXI_HP2_ARLEN : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AXI_HP2_ARQOS : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AXI_HP2_AWCACHE : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AXI_HP2_AWLEN : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AXI_HP2_AWQOS : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AXI_HP2_ARID : in STD_LOGIC_VECTOR ( 5 downto 0 );
    S_AXI_HP2_AWID : in STD_LOGIC_VECTOR ( 5 downto 0 );
    S_AXI_HP2_WID : in STD_LOGIC_VECTOR ( 5 downto 0 );
    S_AXI_HP2_WDATA : in STD_LOGIC_VECTOR ( 63 downto 0 );
    S_AXI_HP2_WSTRB : in STD_LOGIC_VECTOR ( 7 downto 0 );
    S_AXI_HP3_ARESETN : out STD_LOGIC;
    S_AXI_HP3_ARREADY : out STD_LOGIC;
    S_AXI_HP3_AWREADY : out STD_LOGIC;
    S_AXI_HP3_BVALID : out STD_LOGIC;
    S_AXI_HP3_RLAST : out STD_LOGIC;
    S_AXI_HP3_RVALID : out STD_LOGIC;
    S_AXI_HP3_WREADY : out STD_LOGIC;
    S_AXI_HP3_BRESP : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S_AXI_HP3_RRESP : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S_AXI_HP3_BID : out STD_LOGIC_VECTOR ( 5 downto 0 );
    S_AXI_HP3_RID : out STD_LOGIC_VECTOR ( 5 downto 0 );
    S_AXI_HP3_RDATA : out STD_LOGIC_VECTOR ( 63 downto 0 );
    S_AXI_HP3_RCOUNT : out STD_LOGIC_VECTOR ( 7 downto 0 );
    S_AXI_HP3_WCOUNT : out STD_LOGIC_VECTOR ( 7 downto 0 );
    S_AXI_HP3_RACOUNT : out STD_LOGIC_VECTOR ( 2 downto 0 );
    S_AXI_HP3_WACOUNT : out STD_LOGIC_VECTOR ( 5 downto 0 );
    S_AXI_HP3_ACLK : in STD_LOGIC;
    S_AXI_HP3_ARVALID : in STD_LOGIC;
    S_AXI_HP3_AWVALID : in STD_LOGIC;
    S_AXI_HP3_BREADY : in STD_LOGIC;
    S_AXI_HP3_RDISSUECAP1_EN : in STD_LOGIC;
    S_AXI_HP3_RREADY : in STD_LOGIC;
    S_AXI_HP3_WLAST : in STD_LOGIC;
    S_AXI_HP3_WRISSUECAP1_EN : in STD_LOGIC;
    S_AXI_HP3_WVALID : in STD_LOGIC;
    S_AXI_HP3_ARBURST : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S_AXI_HP3_ARLOCK : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S_AXI_HP3_ARSIZE : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S_AXI_HP3_AWBURST : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S_AXI_HP3_AWLOCK : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S_AXI_HP3_AWSIZE : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S_AXI_HP3_ARPROT : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S_AXI_HP3_AWPROT : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S_AXI_HP3_ARADDR : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S_AXI_HP3_AWADDR : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S_AXI_HP3_ARCACHE : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AXI_HP3_ARLEN : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AXI_HP3_ARQOS : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AXI_HP3_AWCACHE : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AXI_HP3_AWLEN : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AXI_HP3_AWQOS : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AXI_HP3_ARID : in STD_LOGIC_VECTOR ( 5 downto 0 );
    S_AXI_HP3_AWID : in STD_LOGIC_VECTOR ( 5 downto 0 );
    S_AXI_HP3_WID : in STD_LOGIC_VECTOR ( 5 downto 0 );
    S_AXI_HP3_WDATA : in STD_LOGIC_VECTOR ( 63 downto 0 );
    S_AXI_HP3_WSTRB : in STD_LOGIC_VECTOR ( 7 downto 0 );
    IRQ_P2F_DMAC_ABORT : out STD_LOGIC;
    IRQ_P2F_DMAC0 : out STD_LOGIC;
    IRQ_P2F_DMAC1 : out STD_LOGIC;
    IRQ_P2F_DMAC2 : out STD_LOGIC;
    IRQ_P2F_DMAC3 : out STD_LOGIC;
    IRQ_P2F_DMAC4 : out STD_LOGIC;
    IRQ_P2F_DMAC5 : out STD_LOGIC;
    IRQ_P2F_DMAC6 : out STD_LOGIC;
    IRQ_P2F_DMAC7 : out STD_LOGIC;
    IRQ_P2F_SMC : out STD_LOGIC;
    IRQ_P2F_QSPI : out STD_LOGIC;
    IRQ_P2F_CTI : out STD_LOGIC;
    IRQ_P2F_GPIO : out STD_LOGIC;
    IRQ_P2F_USB0 : out STD_LOGIC;
    IRQ_P2F_ENET0 : out STD_LOGIC;
    IRQ_P2F_ENET_WAKE0 : out STD_LOGIC;
    IRQ_P2F_SDIO0 : out STD_LOGIC;
    IRQ_P2F_I2C0 : out STD_LOGIC;
    IRQ_P2F_SPI0 : out STD_LOGIC;
    IRQ_P2F_UART0 : out STD_LOGIC;
    IRQ_P2F_CAN0 : out STD_LOGIC;
    IRQ_P2F_USB1 : out STD_LOGIC;
    IRQ_P2F_ENET1 : out STD_LOGIC;
    IRQ_P2F_ENET_WAKE1 : out STD_LOGIC;
    IRQ_P2F_SDIO1 : out STD_LOGIC;
    IRQ_P2F_I2C1 : out STD_LOGIC;
    IRQ_P2F_SPI1 : out STD_LOGIC;
    IRQ_P2F_UART1 : out STD_LOGIC;
    IRQ_P2F_CAN1 : out STD_LOGIC;
    IRQ_F2P : in STD_LOGIC_VECTOR ( 0 to 0 );
    Core0_nFIQ : in STD_LOGIC;
    Core0_nIRQ : in STD_LOGIC;
    Core1_nFIQ : in STD_LOGIC;
    Core1_nIRQ : in STD_LOGIC;
    DMA0_DATYPE : out STD_LOGIC_VECTOR ( 1 downto 0 );
    DMA0_DAVALID : out STD_LOGIC;
    DMA0_DRREADY : out STD_LOGIC;
    DMA0_RSTN : out STD_LOGIC;
    DMA1_DATYPE : out STD_LOGIC_VECTOR ( 1 downto 0 );
    DMA1_DAVALID : out STD_LOGIC;
    DMA1_DRREADY : out STD_LOGIC;
    DMA1_RSTN : out STD_LOGIC;
    DMA2_DATYPE : out STD_LOGIC_VECTOR ( 1 downto 0 );
    DMA2_DAVALID : out STD_LOGIC;
    DMA2_DRREADY : out STD_LOGIC;
    DMA2_RSTN : out STD_LOGIC;
    DMA3_DATYPE : out STD_LOGIC_VECTOR ( 1 downto 0 );
    DMA3_DAVALID : out STD_LOGIC;
    DMA3_DRREADY : out STD_LOGIC;
    DMA3_RSTN : out STD_LOGIC;
    DMA0_ACLK : in STD_LOGIC;
    DMA0_DAREADY : in STD_LOGIC;
    DMA0_DRLAST : in STD_LOGIC;
    DMA0_DRVALID : in STD_LOGIC;
    DMA1_ACLK : in STD_LOGIC;
    DMA1_DAREADY : in STD_LOGIC;
    DMA1_DRLAST : in STD_LOGIC;
    DMA1_DRVALID : in STD_LOGIC;
    DMA2_ACLK : in STD_LOGIC;
    DMA2_DAREADY : in STD_LOGIC;
    DMA2_DRLAST : in STD_LOGIC;
    DMA2_DRVALID : in STD_LOGIC;
    DMA3_ACLK : in STD_LOGIC;
    DMA3_DAREADY : in STD_LOGIC;
    DMA3_DRLAST : in STD_LOGIC;
    DMA3_DRVALID : in STD_LOGIC;
    DMA0_DRTYPE : in STD_LOGIC_VECTOR ( 1 downto 0 );
    DMA1_DRTYPE : in STD_LOGIC_VECTOR ( 1 downto 0 );
    DMA2_DRTYPE : in STD_LOGIC_VECTOR ( 1 downto 0 );
    DMA3_DRTYPE : in STD_LOGIC_VECTOR ( 1 downto 0 );
    FCLK_CLK3 : out STD_LOGIC;
    FCLK_CLK2 : out STD_LOGIC;
    FCLK_CLK1 : out STD_LOGIC;
    FCLK_CLK0 : out STD_LOGIC;
    FCLK_CLKTRIG3_N : in STD_LOGIC;
    FCLK_CLKTRIG2_N : in STD_LOGIC;
    FCLK_CLKTRIG1_N : in STD_LOGIC;
    FCLK_CLKTRIG0_N : in STD_LOGIC;
    FCLK_RESET3_N : out STD_LOGIC;
    FCLK_RESET2_N : out STD_LOGIC;
    FCLK_RESET1_N : out STD_LOGIC;
    FCLK_RESET0_N : out STD_LOGIC;
    FTMD_TRACEIN_DATA : in STD_LOGIC_VECTOR ( 31 downto 0 );
    FTMD_TRACEIN_VALID : in STD_LOGIC;
    FTMD_TRACEIN_CLK : in STD_LOGIC;
    FTMD_TRACEIN_ATID : in STD_LOGIC_VECTOR ( 3 downto 0 );
    FTMT_F2P_TRIG_0 : in STD_LOGIC;
    FTMT_F2P_TRIGACK_0 : out STD_LOGIC;
    FTMT_F2P_TRIG_1 : in STD_LOGIC;
    FTMT_F2P_TRIGACK_1 : out STD_LOGIC;
    FTMT_F2P_TRIG_2 : in STD_LOGIC;
    FTMT_F2P_TRIGACK_2 : out STD_LOGIC;
    FTMT_F2P_TRIG_3 : in STD_LOGIC;
    FTMT_F2P_TRIGACK_3 : out STD_LOGIC;
    FTMT_F2P_DEBUG : in STD_LOGIC_VECTOR ( 31 downto 0 );
    FTMT_P2F_TRIGACK_0 : in STD_LOGIC;
    FTMT_P2F_TRIG_0 : out STD_LOGIC;
    FTMT_P2F_TRIGACK_1 : in STD_LOGIC;
    FTMT_P2F_TRIG_1 : out STD_LOGIC;
    FTMT_P2F_TRIGACK_2 : in STD_LOGIC;
    FTMT_P2F_TRIG_2 : out STD_LOGIC;
    FTMT_P2F_TRIGACK_3 : in STD_LOGIC;
    FTMT_P2F_TRIG_3 : out STD_LOGIC;
    FTMT_P2F_DEBUG : out STD_LOGIC_VECTOR ( 31 downto 0 );
    FPGA_IDLE_N : in STD_LOGIC;
    EVENT_EVENTO : out STD_LOGIC;
    EVENT_STANDBYWFE : out STD_LOGIC_VECTOR ( 1 downto 0 );
    EVENT_STANDBYWFI : out STD_LOGIC_VECTOR ( 1 downto 0 );
    EVENT_EVENTI : in STD_LOGIC;
    DDR_ARB : in STD_LOGIC_VECTOR ( 3 downto 0 );
    MIO : inout STD_LOGIC_VECTOR ( 53 downto 0 );
    DDR_CAS_n : inout STD_LOGIC;
    DDR_CKE : inout STD_LOGIC;
    DDR_Clk_n : inout STD_LOGIC;
    DDR_Clk : inout STD_LOGIC;
    DDR_CS_n : inout STD_LOGIC;
    DDR_DRSTB : inout STD_LOGIC;
    DDR_ODT : inout STD_LOGIC;
    DDR_RAS_n : inout STD_LOGIC;
    DDR_WEB : inout STD_LOGIC;
    DDR_BankAddr : inout STD_LOGIC_VECTOR ( 2 downto 0 );
    DDR_Addr : inout STD_LOGIC_VECTOR ( 14 downto 0 );
    DDR_VRN : inout STD_LOGIC;
    DDR_VRP : inout STD_LOGIC;
    DDR_DM : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_DQ : inout STD_LOGIC_VECTOR ( 31 downto 0 );
    DDR_DQS_n : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_DQS : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    PS_SRSTB : inout STD_LOGIC;
    PS_CLK : inout STD_LOGIC;
    PS_PORB : inout STD_LOGIC
  );
  attribute C_DM_WIDTH : integer;
  attribute C_DM_WIDTH of ps_system_processing_system7_0_0_processing_system7_v5_5_processing_system7 : entity is 4;
  attribute C_DQS_WIDTH : integer;
  attribute C_DQS_WIDTH of ps_system_processing_system7_0_0_processing_system7_v5_5_processing_system7 : entity is 4;
  attribute C_DQ_WIDTH : integer;
  attribute C_DQ_WIDTH of ps_system_processing_system7_0_0_processing_system7_v5_5_processing_system7 : entity is 32;
  attribute C_EMIO_GPIO_WIDTH : integer;
  attribute C_EMIO_GPIO_WIDTH of ps_system_processing_system7_0_0_processing_system7_v5_5_processing_system7 : entity is 64;
  attribute C_EN_EMIO_ENET0 : integer;
  attribute C_EN_EMIO_ENET0 of ps_system_processing_system7_0_0_processing_system7_v5_5_processing_system7 : entity is 0;
  attribute C_EN_EMIO_ENET1 : integer;
  attribute C_EN_EMIO_ENET1 of ps_system_processing_system7_0_0_processing_system7_v5_5_processing_system7 : entity is 0;
  attribute C_EN_EMIO_PJTAG : integer;
  attribute C_EN_EMIO_PJTAG of ps_system_processing_system7_0_0_processing_system7_v5_5_processing_system7 : entity is 0;
  attribute C_EN_EMIO_TRACE : integer;
  attribute C_EN_EMIO_TRACE of ps_system_processing_system7_0_0_processing_system7_v5_5_processing_system7 : entity is 0;
  attribute C_FCLK_CLK0_BUF : string;
  attribute C_FCLK_CLK0_BUF of ps_system_processing_system7_0_0_processing_system7_v5_5_processing_system7 : entity is "FALSE";
  attribute C_FCLK_CLK1_BUF : string;
  attribute C_FCLK_CLK1_BUF of ps_system_processing_system7_0_0_processing_system7_v5_5_processing_system7 : entity is "FALSE";
  attribute C_FCLK_CLK2_BUF : string;
  attribute C_FCLK_CLK2_BUF of ps_system_processing_system7_0_0_processing_system7_v5_5_processing_system7 : entity is "FALSE";
  attribute C_FCLK_CLK3_BUF : string;
  attribute C_FCLK_CLK3_BUF of ps_system_processing_system7_0_0_processing_system7_v5_5_processing_system7 : entity is "FALSE";
  attribute C_GP0_EN_MODIFIABLE_TXN : integer;
  attribute C_GP0_EN_MODIFIABLE_TXN of ps_system_processing_system7_0_0_processing_system7_v5_5_processing_system7 : entity is 1;
  attribute C_GP1_EN_MODIFIABLE_TXN : integer;
  attribute C_GP1_EN_MODIFIABLE_TXN of ps_system_processing_system7_0_0_processing_system7_v5_5_processing_system7 : entity is 1;
  attribute C_INCLUDE_ACP_TRANS_CHECK : integer;
  attribute C_INCLUDE_ACP_TRANS_CHECK of ps_system_processing_system7_0_0_processing_system7_v5_5_processing_system7 : entity is 0;
  attribute C_INCLUDE_TRACE_BUFFER : integer;
  attribute C_INCLUDE_TRACE_BUFFER of ps_system_processing_system7_0_0_processing_system7_v5_5_processing_system7 : entity is 0;
  attribute C_IRQ_F2P_MODE : string;
  attribute C_IRQ_F2P_MODE of ps_system_processing_system7_0_0_processing_system7_v5_5_processing_system7 : entity is "DIRECT";
  attribute C_MIO_PRIMITIVE : integer;
  attribute C_MIO_PRIMITIVE of ps_system_processing_system7_0_0_processing_system7_v5_5_processing_system7 : entity is 54;
  attribute C_M_AXI_GP0_ENABLE_STATIC_REMAP : integer;
  attribute C_M_AXI_GP0_ENABLE_STATIC_REMAP of ps_system_processing_system7_0_0_processing_system7_v5_5_processing_system7 : entity is 0;
  attribute C_M_AXI_GP0_ID_WIDTH : integer;
  attribute C_M_AXI_GP0_ID_WIDTH of ps_system_processing_system7_0_0_processing_system7_v5_5_processing_system7 : entity is 12;
  attribute C_M_AXI_GP0_THREAD_ID_WIDTH : integer;
  attribute C_M_AXI_GP0_THREAD_ID_WIDTH of ps_system_processing_system7_0_0_processing_system7_v5_5_processing_system7 : entity is 12;
  attribute C_M_AXI_GP1_ENABLE_STATIC_REMAP : integer;
  attribute C_M_AXI_GP1_ENABLE_STATIC_REMAP of ps_system_processing_system7_0_0_processing_system7_v5_5_processing_system7 : entity is 0;
  attribute C_M_AXI_GP1_ID_WIDTH : integer;
  attribute C_M_AXI_GP1_ID_WIDTH of ps_system_processing_system7_0_0_processing_system7_v5_5_processing_system7 : entity is 12;
  attribute C_M_AXI_GP1_THREAD_ID_WIDTH : integer;
  attribute C_M_AXI_GP1_THREAD_ID_WIDTH of ps_system_processing_system7_0_0_processing_system7_v5_5_processing_system7 : entity is 12;
  attribute C_NUM_F2P_INTR_INPUTS : integer;
  attribute C_NUM_F2P_INTR_INPUTS of ps_system_processing_system7_0_0_processing_system7_v5_5_processing_system7 : entity is 1;
  attribute C_PACKAGE_NAME : string;
  attribute C_PACKAGE_NAME of ps_system_processing_system7_0_0_processing_system7_v5_5_processing_system7 : entity is "clg400";
  attribute C_PS7_SI_REV : string;
  attribute C_PS7_SI_REV of ps_system_processing_system7_0_0_processing_system7_v5_5_processing_system7 : entity is "PRODUCTION";
  attribute C_S_AXI_ACP_ARUSER_VAL : integer;
  attribute C_S_AXI_ACP_ARUSER_VAL of ps_system_processing_system7_0_0_processing_system7_v5_5_processing_system7 : entity is 31;
  attribute C_S_AXI_ACP_AWUSER_VAL : integer;
  attribute C_S_AXI_ACP_AWUSER_VAL of ps_system_processing_system7_0_0_processing_system7_v5_5_processing_system7 : entity is 31;
  attribute C_S_AXI_ACP_ID_WIDTH : integer;
  attribute C_S_AXI_ACP_ID_WIDTH of ps_system_processing_system7_0_0_processing_system7_v5_5_processing_system7 : entity is 3;
  attribute C_S_AXI_GP0_ID_WIDTH : integer;
  attribute C_S_AXI_GP0_ID_WIDTH of ps_system_processing_system7_0_0_processing_system7_v5_5_processing_system7 : entity is 6;
  attribute C_S_AXI_GP1_ID_WIDTH : integer;
  attribute C_S_AXI_GP1_ID_WIDTH of ps_system_processing_system7_0_0_processing_system7_v5_5_processing_system7 : entity is 6;
  attribute C_S_AXI_HP0_DATA_WIDTH : integer;
  attribute C_S_AXI_HP0_DATA_WIDTH of ps_system_processing_system7_0_0_processing_system7_v5_5_processing_system7 : entity is 64;
  attribute C_S_AXI_HP0_ID_WIDTH : integer;
  attribute C_S_AXI_HP0_ID_WIDTH of ps_system_processing_system7_0_0_processing_system7_v5_5_processing_system7 : entity is 6;
  attribute C_S_AXI_HP1_DATA_WIDTH : integer;
  attribute C_S_AXI_HP1_DATA_WIDTH of ps_system_processing_system7_0_0_processing_system7_v5_5_processing_system7 : entity is 64;
  attribute C_S_AXI_HP1_ID_WIDTH : integer;
  attribute C_S_AXI_HP1_ID_WIDTH of ps_system_processing_system7_0_0_processing_system7_v5_5_processing_system7 : entity is 6;
  attribute C_S_AXI_HP2_DATA_WIDTH : integer;
  attribute C_S_AXI_HP2_DATA_WIDTH of ps_system_processing_system7_0_0_processing_system7_v5_5_processing_system7 : entity is 64;
  attribute C_S_AXI_HP2_ID_WIDTH : integer;
  attribute C_S_AXI_HP2_ID_WIDTH of ps_system_processing_system7_0_0_processing_system7_v5_5_processing_system7 : entity is 6;
  attribute C_S_AXI_HP3_DATA_WIDTH : integer;
  attribute C_S_AXI_HP3_DATA_WIDTH of ps_system_processing_system7_0_0_processing_system7_v5_5_processing_system7 : entity is 64;
  attribute C_S_AXI_HP3_ID_WIDTH : integer;
  attribute C_S_AXI_HP3_ID_WIDTH of ps_system_processing_system7_0_0_processing_system7_v5_5_processing_system7 : entity is 6;
  attribute C_TRACE_BUFFER_CLOCK_DELAY : integer;
  attribute C_TRACE_BUFFER_CLOCK_DELAY of ps_system_processing_system7_0_0_processing_system7_v5_5_processing_system7 : entity is 12;
  attribute C_TRACE_BUFFER_FIFO_SIZE : integer;
  attribute C_TRACE_BUFFER_FIFO_SIZE of ps_system_processing_system7_0_0_processing_system7_v5_5_processing_system7 : entity is 128;
  attribute C_TRACE_INTERNAL_WIDTH : integer;
  attribute C_TRACE_INTERNAL_WIDTH of ps_system_processing_system7_0_0_processing_system7_v5_5_processing_system7 : entity is 2;
  attribute C_TRACE_PIPELINE_WIDTH : integer;
  attribute C_TRACE_PIPELINE_WIDTH of ps_system_processing_system7_0_0_processing_system7_v5_5_processing_system7 : entity is 8;
  attribute C_USE_AXI_NONSECURE : integer;
  attribute C_USE_AXI_NONSECURE of ps_system_processing_system7_0_0_processing_system7_v5_5_processing_system7 : entity is 0;
  attribute C_USE_DEFAULT_ACP_USER_VAL : integer;
  attribute C_USE_DEFAULT_ACP_USER_VAL of ps_system_processing_system7_0_0_processing_system7_v5_5_processing_system7 : entity is 0;
  attribute C_USE_M_AXI_GP0 : integer;
  attribute C_USE_M_AXI_GP0 of ps_system_processing_system7_0_0_processing_system7_v5_5_processing_system7 : entity is 0;
  attribute C_USE_M_AXI_GP1 : integer;
  attribute C_USE_M_AXI_GP1 of ps_system_processing_system7_0_0_processing_system7_v5_5_processing_system7 : entity is 0;
  attribute C_USE_S_AXI_ACP : integer;
  attribute C_USE_S_AXI_ACP of ps_system_processing_system7_0_0_processing_system7_v5_5_processing_system7 : entity is 0;
  attribute C_USE_S_AXI_GP0 : integer;
  attribute C_USE_S_AXI_GP0 of ps_system_processing_system7_0_0_processing_system7_v5_5_processing_system7 : entity is 0;
  attribute C_USE_S_AXI_GP1 : integer;
  attribute C_USE_S_AXI_GP1 of ps_system_processing_system7_0_0_processing_system7_v5_5_processing_system7 : entity is 0;
  attribute C_USE_S_AXI_HP0 : integer;
  attribute C_USE_S_AXI_HP0 of ps_system_processing_system7_0_0_processing_system7_v5_5_processing_system7 : entity is 1;
  attribute C_USE_S_AXI_HP1 : integer;
  attribute C_USE_S_AXI_HP1 of ps_system_processing_system7_0_0_processing_system7_v5_5_processing_system7 : entity is 0;
  attribute C_USE_S_AXI_HP2 : integer;
  attribute C_USE_S_AXI_HP2 of ps_system_processing_system7_0_0_processing_system7_v5_5_processing_system7 : entity is 0;
  attribute C_USE_S_AXI_HP3 : integer;
  attribute C_USE_S_AXI_HP3 of ps_system_processing_system7_0_0_processing_system7_v5_5_processing_system7 : entity is 0;
  attribute HW_HANDOFF : string;
  attribute HW_HANDOFF of ps_system_processing_system7_0_0_processing_system7_v5_5_processing_system7 : entity is "ps_system_processing_system7_0_0.hwdef";
  attribute POWER : string;
  attribute POWER of ps_system_processing_system7_0_0_processing_system7_v5_5_processing_system7 : entity is "<PROCESSOR name={system} numA9Cores={2} clockFreq={666.666666} load={0.5} /><MEMORY name={code} memType={DDR3} dataWidth={16} clockFreq={533.333333} readRate={0.5} writeRate={0.5} /><IO interface={UART} ioStandard={LVCMOS33} bidis={2} ioBank={Vcco_p0} clockFreq={100.000000} usageRate={0.5} /><IO interface={SD} ioStandard={LVCMOS33} bidis={6} ioBank={Vcco_p1} clockFreq={100.000000} usageRate={0.5} /><PLL domain={Processor} vco={1333.333} /><PLL domain={Memory} vco={1066.667} /><PLL domain={IO} vco={1600.000} /><AXI interface={S_AXI_HP0} dataWidth={64} clockFreq={100} usageRate={0.5} />/>";
  attribute USE_TRACE_DATA_EDGE_DETECTOR : integer;
  attribute USE_TRACE_DATA_EDGE_DETECTOR of ps_system_processing_system7_0_0_processing_system7_v5_5_processing_system7 : entity is 0;
end ps_system_processing_system7_0_0_processing_system7_v5_5_processing_system7;

architecture STRUCTURE of ps_system_processing_system7_0_0_processing_system7_v5_5_processing_system7 is
  signal \<const0>\ : STD_LOGIC;
  signal ENET0_MDIO_T_n : STD_LOGIC;
  signal ENET1_MDIO_T_n : STD_LOGIC;
  signal I2C0_SCL_T_n : STD_LOGIC;
  signal I2C0_SDA_T_n : STD_LOGIC;
  signal I2C1_SCL_T_n : STD_LOGIC;
  signal I2C1_SDA_T_n : STD_LOGIC;
  signal PS7_i_n_0 : STD_LOGIC;
  signal PS7_i_n_1 : STD_LOGIC;
  signal PS7_i_n_10 : STD_LOGIC;
  signal PS7_i_n_100 : STD_LOGIC;
  signal PS7_i_n_1001 : STD_LOGIC;
  signal PS7_i_n_1002 : STD_LOGIC;
  signal PS7_i_n_1003 : STD_LOGIC;
  signal PS7_i_n_1004 : STD_LOGIC;
  signal PS7_i_n_1005 : STD_LOGIC;
  signal PS7_i_n_1006 : STD_LOGIC;
  signal PS7_i_n_1007 : STD_LOGIC;
  signal PS7_i_n_1008 : STD_LOGIC;
  signal PS7_i_n_1009 : STD_LOGIC;
  signal PS7_i_n_101 : STD_LOGIC;
  signal PS7_i_n_1010 : STD_LOGIC;
  signal PS7_i_n_1011 : STD_LOGIC;
  signal PS7_i_n_1012 : STD_LOGIC;
  signal PS7_i_n_1013 : STD_LOGIC;
  signal PS7_i_n_1014 : STD_LOGIC;
  signal PS7_i_n_1015 : STD_LOGIC;
  signal PS7_i_n_1016 : STD_LOGIC;
  signal PS7_i_n_1017 : STD_LOGIC;
  signal PS7_i_n_1018 : STD_LOGIC;
  signal PS7_i_n_1019 : STD_LOGIC;
  signal PS7_i_n_102 : STD_LOGIC;
  signal PS7_i_n_1020 : STD_LOGIC;
  signal PS7_i_n_1021 : STD_LOGIC;
  signal PS7_i_n_1022 : STD_LOGIC;
  signal PS7_i_n_1023 : STD_LOGIC;
  signal PS7_i_n_1024 : STD_LOGIC;
  signal PS7_i_n_1025 : STD_LOGIC;
  signal PS7_i_n_1026 : STD_LOGIC;
  signal PS7_i_n_1027 : STD_LOGIC;
  signal PS7_i_n_1028 : STD_LOGIC;
  signal PS7_i_n_1029 : STD_LOGIC;
  signal PS7_i_n_103 : STD_LOGIC;
  signal PS7_i_n_1030 : STD_LOGIC;
  signal PS7_i_n_1031 : STD_LOGIC;
  signal PS7_i_n_1032 : STD_LOGIC;
  signal PS7_i_n_1033 : STD_LOGIC;
  signal PS7_i_n_1034 : STD_LOGIC;
  signal PS7_i_n_1035 : STD_LOGIC;
  signal PS7_i_n_1036 : STD_LOGIC;
  signal PS7_i_n_1037 : STD_LOGIC;
  signal PS7_i_n_1038 : STD_LOGIC;
  signal PS7_i_n_1039 : STD_LOGIC;
  signal PS7_i_n_104 : STD_LOGIC;
  signal PS7_i_n_1040 : STD_LOGIC;
  signal PS7_i_n_1041 : STD_LOGIC;
  signal PS7_i_n_1042 : STD_LOGIC;
  signal PS7_i_n_1043 : STD_LOGIC;
  signal PS7_i_n_1044 : STD_LOGIC;
  signal PS7_i_n_1045 : STD_LOGIC;
  signal PS7_i_n_1046 : STD_LOGIC;
  signal PS7_i_n_1047 : STD_LOGIC;
  signal PS7_i_n_1048 : STD_LOGIC;
  signal PS7_i_n_1049 : STD_LOGIC;
  signal PS7_i_n_105 : STD_LOGIC;
  signal PS7_i_n_1050 : STD_LOGIC;
  signal PS7_i_n_1051 : STD_LOGIC;
  signal PS7_i_n_1052 : STD_LOGIC;
  signal PS7_i_n_1053 : STD_LOGIC;
  signal PS7_i_n_1054 : STD_LOGIC;
  signal PS7_i_n_1055 : STD_LOGIC;
  signal PS7_i_n_1056 : STD_LOGIC;
  signal PS7_i_n_1057 : STD_LOGIC;
  signal PS7_i_n_1058 : STD_LOGIC;
  signal PS7_i_n_1059 : STD_LOGIC;
  signal PS7_i_n_106 : STD_LOGIC;
  signal PS7_i_n_1060 : STD_LOGIC;
  signal PS7_i_n_1061 : STD_LOGIC;
  signal PS7_i_n_1062 : STD_LOGIC;
  signal PS7_i_n_1063 : STD_LOGIC;
  signal PS7_i_n_1064 : STD_LOGIC;
  signal PS7_i_n_107 : STD_LOGIC;
  signal PS7_i_n_108 : STD_LOGIC;
  signal PS7_i_n_109 : STD_LOGIC;
  signal PS7_i_n_11 : STD_LOGIC;
  signal PS7_i_n_110 : STD_LOGIC;
  signal PS7_i_n_111 : STD_LOGIC;
  signal PS7_i_n_112 : STD_LOGIC;
  signal PS7_i_n_1129 : STD_LOGIC;
  signal PS7_i_n_113 : STD_LOGIC;
  signal PS7_i_n_1130 : STD_LOGIC;
  signal PS7_i_n_1131 : STD_LOGIC;
  signal PS7_i_n_1132 : STD_LOGIC;
  signal PS7_i_n_1133 : STD_LOGIC;
  signal PS7_i_n_1134 : STD_LOGIC;
  signal PS7_i_n_1135 : STD_LOGIC;
  signal PS7_i_n_1136 : STD_LOGIC;
  signal PS7_i_n_1137 : STD_LOGIC;
  signal PS7_i_n_1138 : STD_LOGIC;
  signal PS7_i_n_1139 : STD_LOGIC;
  signal PS7_i_n_114 : STD_LOGIC;
  signal PS7_i_n_1140 : STD_LOGIC;
  signal PS7_i_n_1141 : STD_LOGIC;
  signal PS7_i_n_1142 : STD_LOGIC;
  signal PS7_i_n_1143 : STD_LOGIC;
  signal PS7_i_n_1144 : STD_LOGIC;
  signal PS7_i_n_1145 : STD_LOGIC;
  signal PS7_i_n_1146 : STD_LOGIC;
  signal PS7_i_n_1147 : STD_LOGIC;
  signal PS7_i_n_1148 : STD_LOGIC;
  signal PS7_i_n_1149 : STD_LOGIC;
  signal PS7_i_n_115 : STD_LOGIC;
  signal PS7_i_n_1150 : STD_LOGIC;
  signal PS7_i_n_1151 : STD_LOGIC;
  signal PS7_i_n_1152 : STD_LOGIC;
  signal PS7_i_n_1153 : STD_LOGIC;
  signal PS7_i_n_1154 : STD_LOGIC;
  signal PS7_i_n_1155 : STD_LOGIC;
  signal PS7_i_n_1156 : STD_LOGIC;
  signal PS7_i_n_1157 : STD_LOGIC;
  signal PS7_i_n_1158 : STD_LOGIC;
  signal PS7_i_n_1159 : STD_LOGIC;
  signal PS7_i_n_116 : STD_LOGIC;
  signal PS7_i_n_1160 : STD_LOGIC;
  signal PS7_i_n_1161 : STD_LOGIC;
  signal PS7_i_n_1162 : STD_LOGIC;
  signal PS7_i_n_1163 : STD_LOGIC;
  signal PS7_i_n_1164 : STD_LOGIC;
  signal PS7_i_n_1165 : STD_LOGIC;
  signal PS7_i_n_1166 : STD_LOGIC;
  signal PS7_i_n_1167 : STD_LOGIC;
  signal PS7_i_n_1168 : STD_LOGIC;
  signal PS7_i_n_1169 : STD_LOGIC;
  signal PS7_i_n_117 : STD_LOGIC;
  signal PS7_i_n_1170 : STD_LOGIC;
  signal PS7_i_n_1171 : STD_LOGIC;
  signal PS7_i_n_1172 : STD_LOGIC;
  signal PS7_i_n_1173 : STD_LOGIC;
  signal PS7_i_n_1174 : STD_LOGIC;
  signal PS7_i_n_1175 : STD_LOGIC;
  signal PS7_i_n_1176 : STD_LOGIC;
  signal PS7_i_n_1177 : STD_LOGIC;
  signal PS7_i_n_1178 : STD_LOGIC;
  signal PS7_i_n_1179 : STD_LOGIC;
  signal PS7_i_n_118 : STD_LOGIC;
  signal PS7_i_n_1180 : STD_LOGIC;
  signal PS7_i_n_1181 : STD_LOGIC;
  signal PS7_i_n_1182 : STD_LOGIC;
  signal PS7_i_n_1183 : STD_LOGIC;
  signal PS7_i_n_1184 : STD_LOGIC;
  signal PS7_i_n_1185 : STD_LOGIC;
  signal PS7_i_n_1186 : STD_LOGIC;
  signal PS7_i_n_1187 : STD_LOGIC;
  signal PS7_i_n_1188 : STD_LOGIC;
  signal PS7_i_n_1189 : STD_LOGIC;
  signal PS7_i_n_119 : STD_LOGIC;
  signal PS7_i_n_1190 : STD_LOGIC;
  signal PS7_i_n_1191 : STD_LOGIC;
  signal PS7_i_n_1192 : STD_LOGIC;
  signal PS7_i_n_1193 : STD_LOGIC;
  signal PS7_i_n_1194 : STD_LOGIC;
  signal PS7_i_n_1195 : STD_LOGIC;
  signal PS7_i_n_1196 : STD_LOGIC;
  signal PS7_i_n_1197 : STD_LOGIC;
  signal PS7_i_n_1198 : STD_LOGIC;
  signal PS7_i_n_1199 : STD_LOGIC;
  signal PS7_i_n_12 : STD_LOGIC;
  signal PS7_i_n_120 : STD_LOGIC;
  signal PS7_i_n_1200 : STD_LOGIC;
  signal PS7_i_n_1201 : STD_LOGIC;
  signal PS7_i_n_1202 : STD_LOGIC;
  signal PS7_i_n_1203 : STD_LOGIC;
  signal PS7_i_n_1204 : STD_LOGIC;
  signal PS7_i_n_1205 : STD_LOGIC;
  signal PS7_i_n_1206 : STD_LOGIC;
  signal PS7_i_n_1207 : STD_LOGIC;
  signal PS7_i_n_1208 : STD_LOGIC;
  signal PS7_i_n_1209 : STD_LOGIC;
  signal PS7_i_n_121 : STD_LOGIC;
  signal PS7_i_n_1210 : STD_LOGIC;
  signal PS7_i_n_1211 : STD_LOGIC;
  signal PS7_i_n_1212 : STD_LOGIC;
  signal PS7_i_n_1213 : STD_LOGIC;
  signal PS7_i_n_1214 : STD_LOGIC;
  signal PS7_i_n_1215 : STD_LOGIC;
  signal PS7_i_n_1216 : STD_LOGIC;
  signal PS7_i_n_1217 : STD_LOGIC;
  signal PS7_i_n_1218 : STD_LOGIC;
  signal PS7_i_n_1219 : STD_LOGIC;
  signal PS7_i_n_122 : STD_LOGIC;
  signal PS7_i_n_1220 : STD_LOGIC;
  signal PS7_i_n_1221 : STD_LOGIC;
  signal PS7_i_n_1222 : STD_LOGIC;
  signal PS7_i_n_1223 : STD_LOGIC;
  signal PS7_i_n_1224 : STD_LOGIC;
  signal PS7_i_n_1225 : STD_LOGIC;
  signal PS7_i_n_1226 : STD_LOGIC;
  signal PS7_i_n_1227 : STD_LOGIC;
  signal PS7_i_n_1228 : STD_LOGIC;
  signal PS7_i_n_1229 : STD_LOGIC;
  signal PS7_i_n_123 : STD_LOGIC;
  signal PS7_i_n_1230 : STD_LOGIC;
  signal PS7_i_n_1231 : STD_LOGIC;
  signal PS7_i_n_1232 : STD_LOGIC;
  signal PS7_i_n_1233 : STD_LOGIC;
  signal PS7_i_n_1234 : STD_LOGIC;
  signal PS7_i_n_1235 : STD_LOGIC;
  signal PS7_i_n_1236 : STD_LOGIC;
  signal PS7_i_n_1237 : STD_LOGIC;
  signal PS7_i_n_1238 : STD_LOGIC;
  signal PS7_i_n_1239 : STD_LOGIC;
  signal PS7_i_n_124 : STD_LOGIC;
  signal PS7_i_n_1240 : STD_LOGIC;
  signal PS7_i_n_1241 : STD_LOGIC;
  signal PS7_i_n_1242 : STD_LOGIC;
  signal PS7_i_n_1243 : STD_LOGIC;
  signal PS7_i_n_1244 : STD_LOGIC;
  signal PS7_i_n_1245 : STD_LOGIC;
  signal PS7_i_n_1246 : STD_LOGIC;
  signal PS7_i_n_1247 : STD_LOGIC;
  signal PS7_i_n_1248 : STD_LOGIC;
  signal PS7_i_n_1249 : STD_LOGIC;
  signal PS7_i_n_1250 : STD_LOGIC;
  signal PS7_i_n_1251 : STD_LOGIC;
  signal PS7_i_n_1252 : STD_LOGIC;
  signal PS7_i_n_1253 : STD_LOGIC;
  signal PS7_i_n_1254 : STD_LOGIC;
  signal PS7_i_n_1255 : STD_LOGIC;
  signal PS7_i_n_1256 : STD_LOGIC;
  signal PS7_i_n_1257 : STD_LOGIC;
  signal PS7_i_n_1258 : STD_LOGIC;
  signal PS7_i_n_1259 : STD_LOGIC;
  signal PS7_i_n_1260 : STD_LOGIC;
  signal PS7_i_n_1261 : STD_LOGIC;
  signal PS7_i_n_1262 : STD_LOGIC;
  signal PS7_i_n_1263 : STD_LOGIC;
  signal PS7_i_n_1264 : STD_LOGIC;
  signal PS7_i_n_1265 : STD_LOGIC;
  signal PS7_i_n_1266 : STD_LOGIC;
  signal PS7_i_n_1267 : STD_LOGIC;
  signal PS7_i_n_1268 : STD_LOGIC;
  signal PS7_i_n_1269 : STD_LOGIC;
  signal PS7_i_n_1270 : STD_LOGIC;
  signal PS7_i_n_1271 : STD_LOGIC;
  signal PS7_i_n_1272 : STD_LOGIC;
  signal PS7_i_n_1273 : STD_LOGIC;
  signal PS7_i_n_1274 : STD_LOGIC;
  signal PS7_i_n_1275 : STD_LOGIC;
  signal PS7_i_n_1276 : STD_LOGIC;
  signal PS7_i_n_1277 : STD_LOGIC;
  signal PS7_i_n_1278 : STD_LOGIC;
  signal PS7_i_n_1279 : STD_LOGIC;
  signal PS7_i_n_1280 : STD_LOGIC;
  signal PS7_i_n_1281 : STD_LOGIC;
  signal PS7_i_n_1282 : STD_LOGIC;
  signal PS7_i_n_1283 : STD_LOGIC;
  signal PS7_i_n_1284 : STD_LOGIC;
  signal PS7_i_n_1285 : STD_LOGIC;
  signal PS7_i_n_1286 : STD_LOGIC;
  signal PS7_i_n_1287 : STD_LOGIC;
  signal PS7_i_n_1288 : STD_LOGIC;
  signal PS7_i_n_1289 : STD_LOGIC;
  signal PS7_i_n_1290 : STD_LOGIC;
  signal PS7_i_n_1291 : STD_LOGIC;
  signal PS7_i_n_1292 : STD_LOGIC;
  signal PS7_i_n_1293 : STD_LOGIC;
  signal PS7_i_n_1294 : STD_LOGIC;
  signal PS7_i_n_1295 : STD_LOGIC;
  signal PS7_i_n_1296 : STD_LOGIC;
  signal PS7_i_n_1297 : STD_LOGIC;
  signal PS7_i_n_1298 : STD_LOGIC;
  signal PS7_i_n_1299 : STD_LOGIC;
  signal PS7_i_n_13 : STD_LOGIC;
  signal PS7_i_n_1300 : STD_LOGIC;
  signal PS7_i_n_1301 : STD_LOGIC;
  signal PS7_i_n_1302 : STD_LOGIC;
  signal PS7_i_n_1303 : STD_LOGIC;
  signal PS7_i_n_1304 : STD_LOGIC;
  signal PS7_i_n_1305 : STD_LOGIC;
  signal PS7_i_n_1306 : STD_LOGIC;
  signal PS7_i_n_1307 : STD_LOGIC;
  signal PS7_i_n_1308 : STD_LOGIC;
  signal PS7_i_n_1309 : STD_LOGIC;
  signal PS7_i_n_131 : STD_LOGIC;
  signal PS7_i_n_1310 : STD_LOGIC;
  signal PS7_i_n_1311 : STD_LOGIC;
  signal PS7_i_n_1312 : STD_LOGIC;
  signal PS7_i_n_1313 : STD_LOGIC;
  signal PS7_i_n_1314 : STD_LOGIC;
  signal PS7_i_n_1315 : STD_LOGIC;
  signal PS7_i_n_1316 : STD_LOGIC;
  signal PS7_i_n_1317 : STD_LOGIC;
  signal PS7_i_n_1318 : STD_LOGIC;
  signal PS7_i_n_1319 : STD_LOGIC;
  signal PS7_i_n_132 : STD_LOGIC;
  signal PS7_i_n_1320 : STD_LOGIC;
  signal PS7_i_n_133 : STD_LOGIC;
  signal PS7_i_n_134 : STD_LOGIC;
  signal PS7_i_n_135 : STD_LOGIC;
  signal PS7_i_n_1353 : STD_LOGIC;
  signal PS7_i_n_1354 : STD_LOGIC;
  signal PS7_i_n_1355 : STD_LOGIC;
  signal PS7_i_n_1356 : STD_LOGIC;
  signal PS7_i_n_1357 : STD_LOGIC;
  signal PS7_i_n_1358 : STD_LOGIC;
  signal PS7_i_n_1359 : STD_LOGIC;
  signal PS7_i_n_136 : STD_LOGIC;
  signal PS7_i_n_1360 : STD_LOGIC;
  signal PS7_i_n_1361 : STD_LOGIC;
  signal PS7_i_n_1362 : STD_LOGIC;
  signal PS7_i_n_1363 : STD_LOGIC;
  signal PS7_i_n_1364 : STD_LOGIC;
  signal PS7_i_n_1365 : STD_LOGIC;
  signal PS7_i_n_1366 : STD_LOGIC;
  signal PS7_i_n_1367 : STD_LOGIC;
  signal PS7_i_n_1368 : STD_LOGIC;
  signal PS7_i_n_1369 : STD_LOGIC;
  signal PS7_i_n_137 : STD_LOGIC;
  signal PS7_i_n_1370 : STD_LOGIC;
  signal PS7_i_n_1371 : STD_LOGIC;
  signal PS7_i_n_1372 : STD_LOGIC;
  signal PS7_i_n_1373 : STD_LOGIC;
  signal PS7_i_n_1374 : STD_LOGIC;
  signal PS7_i_n_1375 : STD_LOGIC;
  signal PS7_i_n_1376 : STD_LOGIC;
  signal PS7_i_n_1377 : STD_LOGIC;
  signal PS7_i_n_1378 : STD_LOGIC;
  signal PS7_i_n_1379 : STD_LOGIC;
  signal PS7_i_n_138 : STD_LOGIC;
  signal PS7_i_n_1380 : STD_LOGIC;
  signal PS7_i_n_1381 : STD_LOGIC;
  signal PS7_i_n_1382 : STD_LOGIC;
  signal PS7_i_n_1383 : STD_LOGIC;
  signal PS7_i_n_1384 : STD_LOGIC;
  signal PS7_i_n_1385 : STD_LOGIC;
  signal PS7_i_n_1386 : STD_LOGIC;
  signal PS7_i_n_1387 : STD_LOGIC;
  signal PS7_i_n_1388 : STD_LOGIC;
  signal PS7_i_n_1389 : STD_LOGIC;
  signal PS7_i_n_139 : STD_LOGIC;
  signal PS7_i_n_1390 : STD_LOGIC;
  signal PS7_i_n_1391 : STD_LOGIC;
  signal PS7_i_n_1392 : STD_LOGIC;
  signal PS7_i_n_1393 : STD_LOGIC;
  signal PS7_i_n_1394 : STD_LOGIC;
  signal PS7_i_n_1395 : STD_LOGIC;
  signal PS7_i_n_1396 : STD_LOGIC;
  signal PS7_i_n_1397 : STD_LOGIC;
  signal PS7_i_n_1398 : STD_LOGIC;
  signal PS7_i_n_1399 : STD_LOGIC;
  signal PS7_i_n_140 : STD_LOGIC;
  signal PS7_i_n_1400 : STD_LOGIC;
  signal PS7_i_n_141 : STD_LOGIC;
  signal PS7_i_n_142 : STD_LOGIC;
  signal PS7_i_n_143 : STD_LOGIC;
  signal PS7_i_n_144 : STD_LOGIC;
  signal PS7_i_n_145 : STD_LOGIC;
  signal PS7_i_n_146 : STD_LOGIC;
  signal PS7_i_n_147 : STD_LOGIC;
  signal PS7_i_n_148 : STD_LOGIC;
  signal PS7_i_n_149 : STD_LOGIC;
  signal PS7_i_n_150 : STD_LOGIC;
  signal PS7_i_n_151 : STD_LOGIC;
  signal PS7_i_n_152 : STD_LOGIC;
  signal PS7_i_n_153 : STD_LOGIC;
  signal PS7_i_n_154 : STD_LOGIC;
  signal PS7_i_n_155 : STD_LOGIC;
  signal PS7_i_n_156 : STD_LOGIC;
  signal PS7_i_n_157 : STD_LOGIC;
  signal PS7_i_n_158 : STD_LOGIC;
  signal PS7_i_n_159 : STD_LOGIC;
  signal PS7_i_n_16 : STD_LOGIC;
  signal PS7_i_n_160 : STD_LOGIC;
  signal PS7_i_n_161 : STD_LOGIC;
  signal PS7_i_n_162 : STD_LOGIC;
  signal PS7_i_n_163 : STD_LOGIC;
  signal PS7_i_n_164 : STD_LOGIC;
  signal PS7_i_n_165 : STD_LOGIC;
  signal PS7_i_n_166 : STD_LOGIC;
  signal PS7_i_n_167 : STD_LOGIC;
  signal PS7_i_n_168 : STD_LOGIC;
  signal PS7_i_n_169 : STD_LOGIC;
  signal PS7_i_n_17 : STD_LOGIC;
  signal PS7_i_n_170 : STD_LOGIC;
  signal PS7_i_n_171 : STD_LOGIC;
  signal PS7_i_n_172 : STD_LOGIC;
  signal PS7_i_n_173 : STD_LOGIC;
  signal PS7_i_n_174 : STD_LOGIC;
  signal PS7_i_n_175 : STD_LOGIC;
  signal PS7_i_n_176 : STD_LOGIC;
  signal PS7_i_n_177 : STD_LOGIC;
  signal PS7_i_n_178 : STD_LOGIC;
  signal PS7_i_n_179 : STD_LOGIC;
  signal PS7_i_n_180 : STD_LOGIC;
  signal PS7_i_n_181 : STD_LOGIC;
  signal PS7_i_n_182 : STD_LOGIC;
  signal PS7_i_n_183 : STD_LOGIC;
  signal PS7_i_n_184 : STD_LOGIC;
  signal PS7_i_n_185 : STD_LOGIC;
  signal PS7_i_n_186 : STD_LOGIC;
  signal PS7_i_n_187 : STD_LOGIC;
  signal PS7_i_n_188 : STD_LOGIC;
  signal PS7_i_n_189 : STD_LOGIC;
  signal PS7_i_n_19 : STD_LOGIC;
  signal PS7_i_n_190 : STD_LOGIC;
  signal PS7_i_n_191 : STD_LOGIC;
  signal PS7_i_n_192 : STD_LOGIC;
  signal PS7_i_n_193 : STD_LOGIC;
  signal PS7_i_n_194 : STD_LOGIC;
  signal PS7_i_n_195 : STD_LOGIC;
  signal PS7_i_n_196 : STD_LOGIC;
  signal PS7_i_n_197 : STD_LOGIC;
  signal PS7_i_n_198 : STD_LOGIC;
  signal PS7_i_n_199 : STD_LOGIC;
  signal PS7_i_n_2 : STD_LOGIC;
  signal PS7_i_n_20 : STD_LOGIC;
  signal PS7_i_n_200 : STD_LOGIC;
  signal PS7_i_n_201 : STD_LOGIC;
  signal PS7_i_n_202 : STD_LOGIC;
  signal PS7_i_n_203 : STD_LOGIC;
  signal PS7_i_n_204 : STD_LOGIC;
  signal PS7_i_n_205 : STD_LOGIC;
  signal PS7_i_n_206 : STD_LOGIC;
  signal PS7_i_n_207 : STD_LOGIC;
  signal PS7_i_n_208 : STD_LOGIC;
  signal PS7_i_n_209 : STD_LOGIC;
  signal PS7_i_n_21 : STD_LOGIC;
  signal PS7_i_n_210 : STD_LOGIC;
  signal PS7_i_n_211 : STD_LOGIC;
  signal PS7_i_n_212 : STD_LOGIC;
  signal PS7_i_n_213 : STD_LOGIC;
  signal PS7_i_n_214 : STD_LOGIC;
  signal PS7_i_n_215 : STD_LOGIC;
  signal PS7_i_n_216 : STD_LOGIC;
  signal PS7_i_n_217 : STD_LOGIC;
  signal PS7_i_n_218 : STD_LOGIC;
  signal PS7_i_n_219 : STD_LOGIC;
  signal PS7_i_n_22 : STD_LOGIC;
  signal PS7_i_n_220 : STD_LOGIC;
  signal PS7_i_n_221 : STD_LOGIC;
  signal PS7_i_n_222 : STD_LOGIC;
  signal PS7_i_n_223 : STD_LOGIC;
  signal PS7_i_n_224 : STD_LOGIC;
  signal PS7_i_n_225 : STD_LOGIC;
  signal PS7_i_n_226 : STD_LOGIC;
  signal PS7_i_n_227 : STD_LOGIC;
  signal PS7_i_n_228 : STD_LOGIC;
  signal PS7_i_n_229 : STD_LOGIC;
  signal PS7_i_n_23 : STD_LOGIC;
  signal PS7_i_n_230 : STD_LOGIC;
  signal PS7_i_n_231 : STD_LOGIC;
  signal PS7_i_n_232 : STD_LOGIC;
  signal PS7_i_n_233 : STD_LOGIC;
  signal PS7_i_n_234 : STD_LOGIC;
  signal PS7_i_n_235 : STD_LOGIC;
  signal PS7_i_n_236 : STD_LOGIC;
  signal PS7_i_n_237 : STD_LOGIC;
  signal PS7_i_n_238 : STD_LOGIC;
  signal PS7_i_n_239 : STD_LOGIC;
  signal PS7_i_n_24 : STD_LOGIC;
  signal PS7_i_n_240 : STD_LOGIC;
  signal PS7_i_n_241 : STD_LOGIC;
  signal PS7_i_n_242 : STD_LOGIC;
  signal PS7_i_n_243 : STD_LOGIC;
  signal PS7_i_n_244 : STD_LOGIC;
  signal PS7_i_n_245 : STD_LOGIC;
  signal PS7_i_n_246 : STD_LOGIC;
  signal PS7_i_n_247 : STD_LOGIC;
  signal PS7_i_n_248 : STD_LOGIC;
  signal PS7_i_n_249 : STD_LOGIC;
  signal PS7_i_n_25 : STD_LOGIC;
  signal PS7_i_n_250 : STD_LOGIC;
  signal PS7_i_n_251 : STD_LOGIC;
  signal PS7_i_n_252 : STD_LOGIC;
  signal PS7_i_n_253 : STD_LOGIC;
  signal PS7_i_n_254 : STD_LOGIC;
  signal PS7_i_n_255 : STD_LOGIC;
  signal PS7_i_n_256 : STD_LOGIC;
  signal PS7_i_n_257 : STD_LOGIC;
  signal PS7_i_n_258 : STD_LOGIC;
  signal PS7_i_n_259 : STD_LOGIC;
  signal PS7_i_n_26 : STD_LOGIC;
  signal PS7_i_n_260 : STD_LOGIC;
  signal PS7_i_n_261 : STD_LOGIC;
  signal PS7_i_n_262 : STD_LOGIC;
  signal PS7_i_n_263 : STD_LOGIC;
  signal PS7_i_n_264 : STD_LOGIC;
  signal PS7_i_n_265 : STD_LOGIC;
  signal PS7_i_n_266 : STD_LOGIC;
  signal PS7_i_n_267 : STD_LOGIC;
  signal PS7_i_n_268 : STD_LOGIC;
  signal PS7_i_n_269 : STD_LOGIC;
  signal PS7_i_n_27 : STD_LOGIC;
  signal PS7_i_n_270 : STD_LOGIC;
  signal PS7_i_n_271 : STD_LOGIC;
  signal PS7_i_n_272 : STD_LOGIC;
  signal PS7_i_n_273 : STD_LOGIC;
  signal PS7_i_n_274 : STD_LOGIC;
  signal PS7_i_n_275 : STD_LOGIC;
  signal PS7_i_n_28 : STD_LOGIC;
  signal PS7_i_n_280 : STD_LOGIC;
  signal PS7_i_n_281 : STD_LOGIC;
  signal PS7_i_n_282 : STD_LOGIC;
  signal PS7_i_n_283 : STD_LOGIC;
  signal PS7_i_n_284 : STD_LOGIC;
  signal PS7_i_n_285 : STD_LOGIC;
  signal PS7_i_n_286 : STD_LOGIC;
  signal PS7_i_n_287 : STD_LOGIC;
  signal PS7_i_n_288 : STD_LOGIC;
  signal PS7_i_n_289 : STD_LOGIC;
  signal PS7_i_n_290 : STD_LOGIC;
  signal PS7_i_n_291 : STD_LOGIC;
  signal PS7_i_n_292 : STD_LOGIC;
  signal PS7_i_n_293 : STD_LOGIC;
  signal PS7_i_n_294 : STD_LOGIC;
  signal PS7_i_n_295 : STD_LOGIC;
  signal PS7_i_n_296 : STD_LOGIC;
  signal PS7_i_n_297 : STD_LOGIC;
  signal PS7_i_n_298 : STD_LOGIC;
  signal PS7_i_n_299 : STD_LOGIC;
  signal PS7_i_n_3 : STD_LOGIC;
  signal PS7_i_n_300 : STD_LOGIC;
  signal PS7_i_n_301 : STD_LOGIC;
  signal PS7_i_n_302 : STD_LOGIC;
  signal PS7_i_n_303 : STD_LOGIC;
  signal PS7_i_n_304 : STD_LOGIC;
  signal PS7_i_n_305 : STD_LOGIC;
  signal PS7_i_n_306 : STD_LOGIC;
  signal PS7_i_n_307 : STD_LOGIC;
  signal PS7_i_n_308 : STD_LOGIC;
  signal PS7_i_n_309 : STD_LOGIC;
  signal PS7_i_n_31 : STD_LOGIC;
  signal PS7_i_n_310 : STD_LOGIC;
  signal PS7_i_n_311 : STD_LOGIC;
  signal PS7_i_n_312 : STD_LOGIC;
  signal PS7_i_n_313 : STD_LOGIC;
  signal PS7_i_n_314 : STD_LOGIC;
  signal PS7_i_n_315 : STD_LOGIC;
  signal PS7_i_n_316 : STD_LOGIC;
  signal PS7_i_n_317 : STD_LOGIC;
  signal PS7_i_n_318 : STD_LOGIC;
  signal PS7_i_n_319 : STD_LOGIC;
  signal PS7_i_n_32 : STD_LOGIC;
  signal PS7_i_n_320 : STD_LOGIC;
  signal PS7_i_n_321 : STD_LOGIC;
  signal PS7_i_n_322 : STD_LOGIC;
  signal PS7_i_n_323 : STD_LOGIC;
  signal PS7_i_n_324 : STD_LOGIC;
  signal PS7_i_n_325 : STD_LOGIC;
  signal PS7_i_n_326 : STD_LOGIC;
  signal PS7_i_n_327 : STD_LOGIC;
  signal PS7_i_n_328 : STD_LOGIC;
  signal PS7_i_n_329 : STD_LOGIC;
  signal PS7_i_n_330 : STD_LOGIC;
  signal PS7_i_n_331 : STD_LOGIC;
  signal PS7_i_n_332 : STD_LOGIC;
  signal PS7_i_n_333 : STD_LOGIC;
  signal PS7_i_n_334 : STD_LOGIC;
  signal PS7_i_n_335 : STD_LOGIC;
  signal PS7_i_n_336 : STD_LOGIC;
  signal PS7_i_n_337 : STD_LOGIC;
  signal PS7_i_n_338 : STD_LOGIC;
  signal PS7_i_n_339 : STD_LOGIC;
  signal PS7_i_n_34 : STD_LOGIC;
  signal PS7_i_n_340 : STD_LOGIC;
  signal PS7_i_n_341 : STD_LOGIC;
  signal PS7_i_n_342 : STD_LOGIC;
  signal PS7_i_n_343 : STD_LOGIC;
  signal PS7_i_n_344 : STD_LOGIC;
  signal PS7_i_n_345 : STD_LOGIC;
  signal PS7_i_n_346 : STD_LOGIC;
  signal PS7_i_n_347 : STD_LOGIC;
  signal PS7_i_n_348 : STD_LOGIC;
  signal PS7_i_n_349 : STD_LOGIC;
  signal PS7_i_n_35 : STD_LOGIC;
  signal PS7_i_n_350 : STD_LOGIC;
  signal PS7_i_n_351 : STD_LOGIC;
  signal PS7_i_n_352 : STD_LOGIC;
  signal PS7_i_n_353 : STD_LOGIC;
  signal PS7_i_n_354 : STD_LOGIC;
  signal PS7_i_n_355 : STD_LOGIC;
  signal PS7_i_n_356 : STD_LOGIC;
  signal PS7_i_n_36 : STD_LOGIC;
  signal PS7_i_n_360 : STD_LOGIC;
  signal PS7_i_n_361 : STD_LOGIC;
  signal PS7_i_n_362 : STD_LOGIC;
  signal PS7_i_n_363 : STD_LOGIC;
  signal PS7_i_n_364 : STD_LOGIC;
  signal PS7_i_n_365 : STD_LOGIC;
  signal PS7_i_n_366 : STD_LOGIC;
  signal PS7_i_n_367 : STD_LOGIC;
  signal PS7_i_n_368 : STD_LOGIC;
  signal PS7_i_n_37 : STD_LOGIC;
  signal PS7_i_n_38 : STD_LOGIC;
  signal PS7_i_n_39 : STD_LOGIC;
  signal PS7_i_n_4 : STD_LOGIC;
  signal PS7_i_n_40 : STD_LOGIC;
  signal PS7_i_n_401 : STD_LOGIC;
  signal PS7_i_n_402 : STD_LOGIC;
  signal PS7_i_n_403 : STD_LOGIC;
  signal PS7_i_n_404 : STD_LOGIC;
  signal PS7_i_n_405 : STD_LOGIC;
  signal PS7_i_n_406 : STD_LOGIC;
  signal PS7_i_n_407 : STD_LOGIC;
  signal PS7_i_n_408 : STD_LOGIC;
  signal PS7_i_n_409 : STD_LOGIC;
  signal PS7_i_n_41 : STD_LOGIC;
  signal PS7_i_n_410 : STD_LOGIC;
  signal PS7_i_n_411 : STD_LOGIC;
  signal PS7_i_n_412 : STD_LOGIC;
  signal PS7_i_n_413 : STD_LOGIC;
  signal PS7_i_n_414 : STD_LOGIC;
  signal PS7_i_n_415 : STD_LOGIC;
  signal PS7_i_n_416 : STD_LOGIC;
  signal PS7_i_n_417 : STD_LOGIC;
  signal PS7_i_n_418 : STD_LOGIC;
  signal PS7_i_n_419 : STD_LOGIC;
  signal PS7_i_n_42 : STD_LOGIC;
  signal PS7_i_n_420 : STD_LOGIC;
  signal PS7_i_n_421 : STD_LOGIC;
  signal PS7_i_n_422 : STD_LOGIC;
  signal PS7_i_n_423 : STD_LOGIC;
  signal PS7_i_n_424 : STD_LOGIC;
  signal PS7_i_n_425 : STD_LOGIC;
  signal PS7_i_n_426 : STD_LOGIC;
  signal PS7_i_n_427 : STD_LOGIC;
  signal PS7_i_n_428 : STD_LOGIC;
  signal PS7_i_n_429 : STD_LOGIC;
  signal PS7_i_n_43 : STD_LOGIC;
  signal PS7_i_n_430 : STD_LOGIC;
  signal PS7_i_n_431 : STD_LOGIC;
  signal PS7_i_n_432 : STD_LOGIC;
  signal PS7_i_n_433 : STD_LOGIC;
  signal PS7_i_n_434 : STD_LOGIC;
  signal PS7_i_n_435 : STD_LOGIC;
  signal PS7_i_n_436 : STD_LOGIC;
  signal PS7_i_n_437 : STD_LOGIC;
  signal PS7_i_n_438 : STD_LOGIC;
  signal PS7_i_n_439 : STD_LOGIC;
  signal PS7_i_n_44 : STD_LOGIC;
  signal PS7_i_n_440 : STD_LOGIC;
  signal PS7_i_n_441 : STD_LOGIC;
  signal PS7_i_n_442 : STD_LOGIC;
  signal PS7_i_n_443 : STD_LOGIC;
  signal PS7_i_n_444 : STD_LOGIC;
  signal PS7_i_n_445 : STD_LOGIC;
  signal PS7_i_n_446 : STD_LOGIC;
  signal PS7_i_n_447 : STD_LOGIC;
  signal PS7_i_n_448 : STD_LOGIC;
  signal PS7_i_n_449 : STD_LOGIC;
  signal PS7_i_n_450 : STD_LOGIC;
  signal PS7_i_n_451 : STD_LOGIC;
  signal PS7_i_n_452 : STD_LOGIC;
  signal PS7_i_n_453 : STD_LOGIC;
  signal PS7_i_n_454 : STD_LOGIC;
  signal PS7_i_n_455 : STD_LOGIC;
  signal PS7_i_n_456 : STD_LOGIC;
  signal PS7_i_n_457 : STD_LOGIC;
  signal PS7_i_n_458 : STD_LOGIC;
  signal PS7_i_n_459 : STD_LOGIC;
  signal PS7_i_n_46 : STD_LOGIC;
  signal PS7_i_n_460 : STD_LOGIC;
  signal PS7_i_n_461 : STD_LOGIC;
  signal PS7_i_n_462 : STD_LOGIC;
  signal PS7_i_n_463 : STD_LOGIC;
  signal PS7_i_n_464 : STD_LOGIC;
  signal PS7_i_n_465 : STD_LOGIC;
  signal PS7_i_n_466 : STD_LOGIC;
  signal PS7_i_n_467 : STD_LOGIC;
  signal PS7_i_n_468 : STD_LOGIC;
  signal PS7_i_n_469 : STD_LOGIC;
  signal PS7_i_n_470 : STD_LOGIC;
  signal PS7_i_n_471 : STD_LOGIC;
  signal PS7_i_n_472 : STD_LOGIC;
  signal PS7_i_n_473 : STD_LOGIC;
  signal PS7_i_n_474 : STD_LOGIC;
  signal PS7_i_n_475 : STD_LOGIC;
  signal PS7_i_n_476 : STD_LOGIC;
  signal PS7_i_n_477 : STD_LOGIC;
  signal PS7_i_n_478 : STD_LOGIC;
  signal PS7_i_n_479 : STD_LOGIC;
  signal PS7_i_n_48 : STD_LOGIC;
  signal PS7_i_n_480 : STD_LOGIC;
  signal PS7_i_n_481 : STD_LOGIC;
  signal PS7_i_n_482 : STD_LOGIC;
  signal PS7_i_n_483 : STD_LOGIC;
  signal PS7_i_n_484 : STD_LOGIC;
  signal PS7_i_n_485 : STD_LOGIC;
  signal PS7_i_n_486 : STD_LOGIC;
  signal PS7_i_n_487 : STD_LOGIC;
  signal PS7_i_n_488 : STD_LOGIC;
  signal PS7_i_n_489 : STD_LOGIC;
  signal PS7_i_n_490 : STD_LOGIC;
  signal PS7_i_n_491 : STD_LOGIC;
  signal PS7_i_n_492 : STD_LOGIC;
  signal PS7_i_n_493 : STD_LOGIC;
  signal PS7_i_n_494 : STD_LOGIC;
  signal PS7_i_n_495 : STD_LOGIC;
  signal PS7_i_n_496 : STD_LOGIC;
  signal PS7_i_n_497 : STD_LOGIC;
  signal PS7_i_n_498 : STD_LOGIC;
  signal PS7_i_n_499 : STD_LOGIC;
  signal PS7_i_n_5 : STD_LOGIC;
  signal PS7_i_n_50 : STD_LOGIC;
  signal PS7_i_n_500 : STD_LOGIC;
  signal PS7_i_n_501 : STD_LOGIC;
  signal PS7_i_n_502 : STD_LOGIC;
  signal PS7_i_n_503 : STD_LOGIC;
  signal PS7_i_n_504 : STD_LOGIC;
  signal PS7_i_n_505 : STD_LOGIC;
  signal PS7_i_n_506 : STD_LOGIC;
  signal PS7_i_n_507 : STD_LOGIC;
  signal PS7_i_n_508 : STD_LOGIC;
  signal PS7_i_n_509 : STD_LOGIC;
  signal PS7_i_n_510 : STD_LOGIC;
  signal PS7_i_n_511 : STD_LOGIC;
  signal PS7_i_n_512 : STD_LOGIC;
  signal PS7_i_n_513 : STD_LOGIC;
  signal PS7_i_n_514 : STD_LOGIC;
  signal PS7_i_n_515 : STD_LOGIC;
  signal PS7_i_n_516 : STD_LOGIC;
  signal PS7_i_n_517 : STD_LOGIC;
  signal PS7_i_n_518 : STD_LOGIC;
  signal PS7_i_n_519 : STD_LOGIC;
  signal PS7_i_n_520 : STD_LOGIC;
  signal PS7_i_n_521 : STD_LOGIC;
  signal PS7_i_n_522 : STD_LOGIC;
  signal PS7_i_n_523 : STD_LOGIC;
  signal PS7_i_n_524 : STD_LOGIC;
  signal PS7_i_n_525 : STD_LOGIC;
  signal PS7_i_n_526 : STD_LOGIC;
  signal PS7_i_n_527 : STD_LOGIC;
  signal PS7_i_n_528 : STD_LOGIC;
  signal PS7_i_n_529 : STD_LOGIC;
  signal PS7_i_n_530 : STD_LOGIC;
  signal PS7_i_n_531 : STD_LOGIC;
  signal PS7_i_n_532 : STD_LOGIC;
  signal PS7_i_n_533 : STD_LOGIC;
  signal PS7_i_n_534 : STD_LOGIC;
  signal PS7_i_n_535 : STD_LOGIC;
  signal PS7_i_n_536 : STD_LOGIC;
  signal PS7_i_n_537 : STD_LOGIC;
  signal PS7_i_n_538 : STD_LOGIC;
  signal PS7_i_n_539 : STD_LOGIC;
  signal PS7_i_n_54 : STD_LOGIC;
  signal PS7_i_n_540 : STD_LOGIC;
  signal PS7_i_n_541 : STD_LOGIC;
  signal PS7_i_n_542 : STD_LOGIC;
  signal PS7_i_n_543 : STD_LOGIC;
  signal PS7_i_n_544 : STD_LOGIC;
  signal PS7_i_n_545 : STD_LOGIC;
  signal PS7_i_n_546 : STD_LOGIC;
  signal PS7_i_n_547 : STD_LOGIC;
  signal PS7_i_n_548 : STD_LOGIC;
  signal PS7_i_n_549 : STD_LOGIC;
  signal PS7_i_n_55 : STD_LOGIC;
  signal PS7_i_n_550 : STD_LOGIC;
  signal PS7_i_n_551 : STD_LOGIC;
  signal PS7_i_n_552 : STD_LOGIC;
  signal PS7_i_n_553 : STD_LOGIC;
  signal PS7_i_n_554 : STD_LOGIC;
  signal PS7_i_n_555 : STD_LOGIC;
  signal PS7_i_n_556 : STD_LOGIC;
  signal PS7_i_n_557 : STD_LOGIC;
  signal PS7_i_n_558 : STD_LOGIC;
  signal PS7_i_n_559 : STD_LOGIC;
  signal PS7_i_n_56 : STD_LOGIC;
  signal PS7_i_n_560 : STD_LOGIC;
  signal PS7_i_n_561 : STD_LOGIC;
  signal PS7_i_n_562 : STD_LOGIC;
  signal PS7_i_n_563 : STD_LOGIC;
  signal PS7_i_n_564 : STD_LOGIC;
  signal PS7_i_n_565 : STD_LOGIC;
  signal PS7_i_n_566 : STD_LOGIC;
  signal PS7_i_n_567 : STD_LOGIC;
  signal PS7_i_n_568 : STD_LOGIC;
  signal PS7_i_n_569 : STD_LOGIC;
  signal PS7_i_n_570 : STD_LOGIC;
  signal PS7_i_n_571 : STD_LOGIC;
  signal PS7_i_n_572 : STD_LOGIC;
  signal PS7_i_n_573 : STD_LOGIC;
  signal PS7_i_n_574 : STD_LOGIC;
  signal PS7_i_n_575 : STD_LOGIC;
  signal PS7_i_n_576 : STD_LOGIC;
  signal PS7_i_n_577 : STD_LOGIC;
  signal PS7_i_n_578 : STD_LOGIC;
  signal PS7_i_n_579 : STD_LOGIC;
  signal PS7_i_n_58 : STD_LOGIC;
  signal PS7_i_n_580 : STD_LOGIC;
  signal PS7_i_n_581 : STD_LOGIC;
  signal PS7_i_n_582 : STD_LOGIC;
  signal PS7_i_n_583 : STD_LOGIC;
  signal PS7_i_n_584 : STD_LOGIC;
  signal PS7_i_n_585 : STD_LOGIC;
  signal PS7_i_n_586 : STD_LOGIC;
  signal PS7_i_n_587 : STD_LOGIC;
  signal PS7_i_n_588 : STD_LOGIC;
  signal PS7_i_n_589 : STD_LOGIC;
  signal PS7_i_n_59 : STD_LOGIC;
  signal PS7_i_n_590 : STD_LOGIC;
  signal PS7_i_n_591 : STD_LOGIC;
  signal PS7_i_n_592 : STD_LOGIC;
  signal PS7_i_n_593 : STD_LOGIC;
  signal PS7_i_n_594 : STD_LOGIC;
  signal PS7_i_n_595 : STD_LOGIC;
  signal PS7_i_n_596 : STD_LOGIC;
  signal PS7_i_n_597 : STD_LOGIC;
  signal PS7_i_n_598 : STD_LOGIC;
  signal PS7_i_n_599 : STD_LOGIC;
  signal PS7_i_n_6 : STD_LOGIC;
  signal PS7_i_n_60 : STD_LOGIC;
  signal PS7_i_n_600 : STD_LOGIC;
  signal PS7_i_n_601 : STD_LOGIC;
  signal PS7_i_n_602 : STD_LOGIC;
  signal PS7_i_n_603 : STD_LOGIC;
  signal PS7_i_n_604 : STD_LOGIC;
  signal PS7_i_n_605 : STD_LOGIC;
  signal PS7_i_n_606 : STD_LOGIC;
  signal PS7_i_n_607 : STD_LOGIC;
  signal PS7_i_n_608 : STD_LOGIC;
  signal PS7_i_n_609 : STD_LOGIC;
  signal PS7_i_n_61 : STD_LOGIC;
  signal PS7_i_n_610 : STD_LOGIC;
  signal PS7_i_n_611 : STD_LOGIC;
  signal PS7_i_n_612 : STD_LOGIC;
  signal PS7_i_n_613 : STD_LOGIC;
  signal PS7_i_n_614 : STD_LOGIC;
  signal PS7_i_n_615 : STD_LOGIC;
  signal PS7_i_n_616 : STD_LOGIC;
  signal PS7_i_n_617 : STD_LOGIC;
  signal PS7_i_n_618 : STD_LOGIC;
  signal PS7_i_n_619 : STD_LOGIC;
  signal PS7_i_n_620 : STD_LOGIC;
  signal PS7_i_n_621 : STD_LOGIC;
  signal PS7_i_n_622 : STD_LOGIC;
  signal PS7_i_n_623 : STD_LOGIC;
  signal PS7_i_n_624 : STD_LOGIC;
  signal PS7_i_n_625 : STD_LOGIC;
  signal PS7_i_n_626 : STD_LOGIC;
  signal PS7_i_n_627 : STD_LOGIC;
  signal PS7_i_n_628 : STD_LOGIC;
  signal PS7_i_n_629 : STD_LOGIC;
  signal PS7_i_n_63 : STD_LOGIC;
  signal PS7_i_n_630 : STD_LOGIC;
  signal PS7_i_n_631 : STD_LOGIC;
  signal PS7_i_n_632 : STD_LOGIC;
  signal PS7_i_n_633 : STD_LOGIC;
  signal PS7_i_n_634 : STD_LOGIC;
  signal PS7_i_n_635 : STD_LOGIC;
  signal PS7_i_n_636 : STD_LOGIC;
  signal PS7_i_n_637 : STD_LOGIC;
  signal PS7_i_n_638 : STD_LOGIC;
  signal PS7_i_n_639 : STD_LOGIC;
  signal PS7_i_n_64 : STD_LOGIC;
  signal PS7_i_n_640 : STD_LOGIC;
  signal PS7_i_n_641 : STD_LOGIC;
  signal PS7_i_n_642 : STD_LOGIC;
  signal PS7_i_n_643 : STD_LOGIC;
  signal PS7_i_n_644 : STD_LOGIC;
  signal PS7_i_n_645 : STD_LOGIC;
  signal PS7_i_n_646 : STD_LOGIC;
  signal PS7_i_n_647 : STD_LOGIC;
  signal PS7_i_n_648 : STD_LOGIC;
  signal PS7_i_n_649 : STD_LOGIC;
  signal PS7_i_n_650 : STD_LOGIC;
  signal PS7_i_n_651 : STD_LOGIC;
  signal PS7_i_n_652 : STD_LOGIC;
  signal PS7_i_n_653 : STD_LOGIC;
  signal PS7_i_n_654 : STD_LOGIC;
  signal PS7_i_n_655 : STD_LOGIC;
  signal PS7_i_n_656 : STD_LOGIC;
  signal PS7_i_n_657 : STD_LOGIC;
  signal PS7_i_n_658 : STD_LOGIC;
  signal PS7_i_n_659 : STD_LOGIC;
  signal PS7_i_n_66 : STD_LOGIC;
  signal PS7_i_n_660 : STD_LOGIC;
  signal PS7_i_n_661 : STD_LOGIC;
  signal PS7_i_n_662 : STD_LOGIC;
  signal PS7_i_n_663 : STD_LOGIC;
  signal PS7_i_n_664 : STD_LOGIC;
  signal PS7_i_n_665 : STD_LOGIC;
  signal PS7_i_n_666 : STD_LOGIC;
  signal PS7_i_n_667 : STD_LOGIC;
  signal PS7_i_n_668 : STD_LOGIC;
  signal PS7_i_n_669 : STD_LOGIC;
  signal PS7_i_n_670 : STD_LOGIC;
  signal PS7_i_n_671 : STD_LOGIC;
  signal PS7_i_n_672 : STD_LOGIC;
  signal PS7_i_n_673 : STD_LOGIC;
  signal PS7_i_n_674 : STD_LOGIC;
  signal PS7_i_n_675 : STD_LOGIC;
  signal PS7_i_n_676 : STD_LOGIC;
  signal PS7_i_n_677 : STD_LOGIC;
  signal PS7_i_n_678 : STD_LOGIC;
  signal PS7_i_n_679 : STD_LOGIC;
  signal PS7_i_n_68 : STD_LOGIC;
  signal PS7_i_n_680 : STD_LOGIC;
  signal PS7_i_n_681 : STD_LOGIC;
  signal PS7_i_n_682 : STD_LOGIC;
  signal PS7_i_n_683 : STD_LOGIC;
  signal PS7_i_n_684 : STD_LOGIC;
  signal PS7_i_n_685 : STD_LOGIC;
  signal PS7_i_n_686 : STD_LOGIC;
  signal PS7_i_n_687 : STD_LOGIC;
  signal PS7_i_n_688 : STD_LOGIC;
  signal PS7_i_n_689 : STD_LOGIC;
  signal PS7_i_n_690 : STD_LOGIC;
  signal PS7_i_n_691 : STD_LOGIC;
  signal PS7_i_n_692 : STD_LOGIC;
  signal PS7_i_n_697 : STD_LOGIC;
  signal PS7_i_n_698 : STD_LOGIC;
  signal PS7_i_n_699 : STD_LOGIC;
  signal PS7_i_n_7 : STD_LOGIC;
  signal PS7_i_n_700 : STD_LOGIC;
  signal PS7_i_n_705 : STD_LOGIC;
  signal PS7_i_n_706 : STD_LOGIC;
  signal PS7_i_n_707 : STD_LOGIC;
  signal PS7_i_n_709 : STD_LOGIC;
  signal PS7_i_n_71 : STD_LOGIC;
  signal PS7_i_n_710 : STD_LOGIC;
  signal PS7_i_n_711 : STD_LOGIC;
  signal PS7_i_n_713 : STD_LOGIC;
  signal PS7_i_n_714 : STD_LOGIC;
  signal PS7_i_n_715 : STD_LOGIC;
  signal PS7_i_n_716 : STD_LOGIC;
  signal PS7_i_n_717 : STD_LOGIC;
  signal PS7_i_n_718 : STD_LOGIC;
  signal PS7_i_n_719 : STD_LOGIC;
  signal PS7_i_n_720 : STD_LOGIC;
  signal PS7_i_n_721 : STD_LOGIC;
  signal PS7_i_n_722 : STD_LOGIC;
  signal PS7_i_n_724 : STD_LOGIC;
  signal PS7_i_n_725 : STD_LOGIC;
  signal PS7_i_n_726 : STD_LOGIC;
  signal PS7_i_n_727 : STD_LOGIC;
  signal PS7_i_n_728 : STD_LOGIC;
  signal PS7_i_n_729 : STD_LOGIC;
  signal PS7_i_n_73 : STD_LOGIC;
  signal PS7_i_n_730 : STD_LOGIC;
  signal PS7_i_n_731 : STD_LOGIC;
  signal PS7_i_n_732 : STD_LOGIC;
  signal PS7_i_n_733 : STD_LOGIC;
  signal PS7_i_n_734 : STD_LOGIC;
  signal PS7_i_n_736 : STD_LOGIC;
  signal PS7_i_n_737 : STD_LOGIC;
  signal PS7_i_n_738 : STD_LOGIC;
  signal PS7_i_n_739 : STD_LOGIC;
  signal PS7_i_n_740 : STD_LOGIC;
  signal PS7_i_n_741 : STD_LOGIC;
  signal PS7_i_n_742 : STD_LOGIC;
  signal PS7_i_n_743 : STD_LOGIC;
  signal PS7_i_n_744 : STD_LOGIC;
  signal PS7_i_n_745 : STD_LOGIC;
  signal PS7_i_n_746 : STD_LOGIC;
  signal PS7_i_n_747 : STD_LOGIC;
  signal PS7_i_n_748 : STD_LOGIC;
  signal PS7_i_n_749 : STD_LOGIC;
  signal PS7_i_n_75 : STD_LOGIC;
  signal PS7_i_n_750 : STD_LOGIC;
  signal PS7_i_n_752 : STD_LOGIC;
  signal PS7_i_n_753 : STD_LOGIC;
  signal PS7_i_n_754 : STD_LOGIC;
  signal PS7_i_n_755 : STD_LOGIC;
  signal PS7_i_n_756 : STD_LOGIC;
  signal PS7_i_n_757 : STD_LOGIC;
  signal PS7_i_n_758 : STD_LOGIC;
  signal PS7_i_n_759 : STD_LOGIC;
  signal PS7_i_n_760 : STD_LOGIC;
  signal PS7_i_n_761 : STD_LOGIC;
  signal PS7_i_n_762 : STD_LOGIC;
  signal PS7_i_n_764 : STD_LOGIC;
  signal PS7_i_n_765 : STD_LOGIC;
  signal PS7_i_n_766 : STD_LOGIC;
  signal PS7_i_n_767 : STD_LOGIC;
  signal PS7_i_n_768 : STD_LOGIC;
  signal PS7_i_n_769 : STD_LOGIC;
  signal PS7_i_n_770 : STD_LOGIC;
  signal PS7_i_n_771 : STD_LOGIC;
  signal PS7_i_n_772 : STD_LOGIC;
  signal PS7_i_n_773 : STD_LOGIC;
  signal PS7_i_n_774 : STD_LOGIC;
  signal PS7_i_n_775 : STD_LOGIC;
  signal PS7_i_n_776 : STD_LOGIC;
  signal PS7_i_n_777 : STD_LOGIC;
  signal PS7_i_n_778 : STD_LOGIC;
  signal PS7_i_n_779 : STD_LOGIC;
  signal PS7_i_n_780 : STD_LOGIC;
  signal PS7_i_n_781 : STD_LOGIC;
  signal PS7_i_n_782 : STD_LOGIC;
  signal PS7_i_n_783 : STD_LOGIC;
  signal PS7_i_n_784 : STD_LOGIC;
  signal PS7_i_n_785 : STD_LOGIC;
  signal PS7_i_n_786 : STD_LOGIC;
  signal PS7_i_n_787 : STD_LOGIC;
  signal PS7_i_n_788 : STD_LOGIC;
  signal PS7_i_n_789 : STD_LOGIC;
  signal PS7_i_n_79 : STD_LOGIC;
  signal PS7_i_n_790 : STD_LOGIC;
  signal PS7_i_n_791 : STD_LOGIC;
  signal PS7_i_n_792 : STD_LOGIC;
  signal PS7_i_n_793 : STD_LOGIC;
  signal PS7_i_n_794 : STD_LOGIC;
  signal PS7_i_n_795 : STD_LOGIC;
  signal PS7_i_n_796 : STD_LOGIC;
  signal PS7_i_n_797 : STD_LOGIC;
  signal PS7_i_n_798 : STD_LOGIC;
  signal PS7_i_n_799 : STD_LOGIC;
  signal PS7_i_n_8 : STD_LOGIC;
  signal PS7_i_n_80 : STD_LOGIC;
  signal PS7_i_n_800 : STD_LOGIC;
  signal PS7_i_n_81 : STD_LOGIC;
  signal PS7_i_n_819 : STD_LOGIC;
  signal PS7_i_n_82 : STD_LOGIC;
  signal PS7_i_n_820 : STD_LOGIC;
  signal PS7_i_n_821 : STD_LOGIC;
  signal PS7_i_n_822 : STD_LOGIC;
  signal PS7_i_n_823 : STD_LOGIC;
  signal PS7_i_n_824 : STD_LOGIC;
  signal PS7_i_n_825 : STD_LOGIC;
  signal PS7_i_n_826 : STD_LOGIC;
  signal PS7_i_n_827 : STD_LOGIC;
  signal PS7_i_n_828 : STD_LOGIC;
  signal PS7_i_n_829 : STD_LOGIC;
  signal PS7_i_n_83 : STD_LOGIC;
  signal PS7_i_n_830 : STD_LOGIC;
  signal PS7_i_n_831 : STD_LOGIC;
  signal PS7_i_n_832 : STD_LOGIC;
  signal PS7_i_n_833 : STD_LOGIC;
  signal PS7_i_n_834 : STD_LOGIC;
  signal PS7_i_n_835 : STD_LOGIC;
  signal PS7_i_n_836 : STD_LOGIC;
  signal PS7_i_n_837 : STD_LOGIC;
  signal PS7_i_n_838 : STD_LOGIC;
  signal PS7_i_n_839 : STD_LOGIC;
  signal PS7_i_n_84 : STD_LOGIC;
  signal PS7_i_n_840 : STD_LOGIC;
  signal PS7_i_n_841 : STD_LOGIC;
  signal PS7_i_n_842 : STD_LOGIC;
  signal PS7_i_n_843 : STD_LOGIC;
  signal PS7_i_n_844 : STD_LOGIC;
  signal PS7_i_n_845 : STD_LOGIC;
  signal PS7_i_n_846 : STD_LOGIC;
  signal PS7_i_n_847 : STD_LOGIC;
  signal PS7_i_n_848 : STD_LOGIC;
  signal PS7_i_n_849 : STD_LOGIC;
  signal PS7_i_n_85 : STD_LOGIC;
  signal PS7_i_n_850 : STD_LOGIC;
  signal PS7_i_n_851 : STD_LOGIC;
  signal PS7_i_n_852 : STD_LOGIC;
  signal PS7_i_n_853 : STD_LOGIC;
  signal PS7_i_n_854 : STD_LOGIC;
  signal PS7_i_n_855 : STD_LOGIC;
  signal PS7_i_n_856 : STD_LOGIC;
  signal PS7_i_n_857 : STD_LOGIC;
  signal PS7_i_n_858 : STD_LOGIC;
  signal PS7_i_n_859 : STD_LOGIC;
  signal PS7_i_n_86 : STD_LOGIC;
  signal PS7_i_n_860 : STD_LOGIC;
  signal PS7_i_n_861 : STD_LOGIC;
  signal PS7_i_n_862 : STD_LOGIC;
  signal PS7_i_n_863 : STD_LOGIC;
  signal PS7_i_n_864 : STD_LOGIC;
  signal PS7_i_n_865 : STD_LOGIC;
  signal PS7_i_n_866 : STD_LOGIC;
  signal PS7_i_n_867 : STD_LOGIC;
  signal PS7_i_n_868 : STD_LOGIC;
  signal PS7_i_n_869 : STD_LOGIC;
  signal PS7_i_n_87 : STD_LOGIC;
  signal PS7_i_n_870 : STD_LOGIC;
  signal PS7_i_n_871 : STD_LOGIC;
  signal PS7_i_n_872 : STD_LOGIC;
  signal PS7_i_n_873 : STD_LOGIC;
  signal PS7_i_n_874 : STD_LOGIC;
  signal PS7_i_n_875 : STD_LOGIC;
  signal PS7_i_n_876 : STD_LOGIC;
  signal PS7_i_n_877 : STD_LOGIC;
  signal PS7_i_n_878 : STD_LOGIC;
  signal PS7_i_n_879 : STD_LOGIC;
  signal PS7_i_n_88 : STD_LOGIC;
  signal PS7_i_n_880 : STD_LOGIC;
  signal PS7_i_n_881 : STD_LOGIC;
  signal PS7_i_n_882 : STD_LOGIC;
  signal PS7_i_n_883 : STD_LOGIC;
  signal PS7_i_n_884 : STD_LOGIC;
  signal PS7_i_n_885 : STD_LOGIC;
  signal PS7_i_n_886 : STD_LOGIC;
  signal PS7_i_n_887 : STD_LOGIC;
  signal PS7_i_n_888 : STD_LOGIC;
  signal PS7_i_n_889 : STD_LOGIC;
  signal PS7_i_n_89 : STD_LOGIC;
  signal PS7_i_n_890 : STD_LOGIC;
  signal PS7_i_n_891 : STD_LOGIC;
  signal PS7_i_n_892 : STD_LOGIC;
  signal PS7_i_n_893 : STD_LOGIC;
  signal PS7_i_n_894 : STD_LOGIC;
  signal PS7_i_n_895 : STD_LOGIC;
  signal PS7_i_n_896 : STD_LOGIC;
  signal PS7_i_n_897 : STD_LOGIC;
  signal PS7_i_n_898 : STD_LOGIC;
  signal PS7_i_n_899 : STD_LOGIC;
  signal PS7_i_n_9 : STD_LOGIC;
  signal PS7_i_n_90 : STD_LOGIC;
  signal PS7_i_n_900 : STD_LOGIC;
  signal PS7_i_n_901 : STD_LOGIC;
  signal PS7_i_n_902 : STD_LOGIC;
  signal PS7_i_n_903 : STD_LOGIC;
  signal PS7_i_n_904 : STD_LOGIC;
  signal PS7_i_n_905 : STD_LOGIC;
  signal PS7_i_n_906 : STD_LOGIC;
  signal PS7_i_n_907 : STD_LOGIC;
  signal PS7_i_n_908 : STD_LOGIC;
  signal PS7_i_n_909 : STD_LOGIC;
  signal PS7_i_n_91 : STD_LOGIC;
  signal PS7_i_n_910 : STD_LOGIC;
  signal PS7_i_n_911 : STD_LOGIC;
  signal PS7_i_n_912 : STD_LOGIC;
  signal PS7_i_n_913 : STD_LOGIC;
  signal PS7_i_n_914 : STD_LOGIC;
  signal PS7_i_n_915 : STD_LOGIC;
  signal PS7_i_n_916 : STD_LOGIC;
  signal PS7_i_n_917 : STD_LOGIC;
  signal PS7_i_n_918 : STD_LOGIC;
  signal PS7_i_n_919 : STD_LOGIC;
  signal PS7_i_n_92 : STD_LOGIC;
  signal PS7_i_n_920 : STD_LOGIC;
  signal PS7_i_n_921 : STD_LOGIC;
  signal PS7_i_n_922 : STD_LOGIC;
  signal PS7_i_n_923 : STD_LOGIC;
  signal PS7_i_n_924 : STD_LOGIC;
  signal PS7_i_n_925 : STD_LOGIC;
  signal PS7_i_n_926 : STD_LOGIC;
  signal PS7_i_n_927 : STD_LOGIC;
  signal PS7_i_n_928 : STD_LOGIC;
  signal PS7_i_n_929 : STD_LOGIC;
  signal PS7_i_n_93 : STD_LOGIC;
  signal PS7_i_n_930 : STD_LOGIC;
  signal PS7_i_n_931 : STD_LOGIC;
  signal PS7_i_n_932 : STD_LOGIC;
  signal PS7_i_n_933 : STD_LOGIC;
  signal PS7_i_n_934 : STD_LOGIC;
  signal PS7_i_n_935 : STD_LOGIC;
  signal PS7_i_n_936 : STD_LOGIC;
  signal PS7_i_n_94 : STD_LOGIC;
  signal PS7_i_n_95 : STD_LOGIC;
  signal PS7_i_n_96 : STD_LOGIC;
  signal PS7_i_n_97 : STD_LOGIC;
  signal PS7_i_n_98 : STD_LOGIC;
  signal PS7_i_n_99 : STD_LOGIC;
  signal SDIO0_CMD_T_n : STD_LOGIC;
  signal SDIO0_DATA_T_n : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal SDIO1_CMD_T_n : STD_LOGIC;
  signal SDIO1_DATA_T_n : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal SPI0_MISO_T_n : STD_LOGIC;
  signal SPI0_MOSI_T_n : STD_LOGIC;
  signal SPI0_SCLK_T_n : STD_LOGIC;
  signal SPI0_SS_T_n : STD_LOGIC;
  signal SPI1_MISO_T_n : STD_LOGIC;
  signal SPI1_MOSI_T_n : STD_LOGIC;
  signal SPI1_SCLK_T_n : STD_LOGIC;
  signal SPI1_SS_T_n : STD_LOGIC;
  signal \TRACE_CTL_PIPE[0]\ : STD_LOGIC;
  attribute RTL_KEEP : string;
  attribute RTL_KEEP of \TRACE_CTL_PIPE[0]\ : signal is "true";
  signal \TRACE_CTL_PIPE[1]\ : STD_LOGIC;
  attribute RTL_KEEP of \TRACE_CTL_PIPE[1]\ : signal is "true";
  signal \TRACE_CTL_PIPE[2]\ : STD_LOGIC;
  attribute RTL_KEEP of \TRACE_CTL_PIPE[2]\ : signal is "true";
  signal \TRACE_CTL_PIPE[3]\ : STD_LOGIC;
  attribute RTL_KEEP of \TRACE_CTL_PIPE[3]\ : signal is "true";
  signal \TRACE_CTL_PIPE[4]\ : STD_LOGIC;
  attribute RTL_KEEP of \TRACE_CTL_PIPE[4]\ : signal is "true";
  signal \TRACE_CTL_PIPE[5]\ : STD_LOGIC;
  attribute RTL_KEEP of \TRACE_CTL_PIPE[5]\ : signal is "true";
  signal \TRACE_CTL_PIPE[6]\ : STD_LOGIC;
  attribute RTL_KEEP of \TRACE_CTL_PIPE[6]\ : signal is "true";
  signal \TRACE_CTL_PIPE[7]\ : STD_LOGIC;
  attribute RTL_KEEP of \TRACE_CTL_PIPE[7]\ : signal is "true";
  signal \TRACE_DATA_PIPE[0]\ : STD_LOGIC_VECTOR ( 1 downto 0 );
  attribute RTL_KEEP of \TRACE_DATA_PIPE[0]\ : signal is "true";
  signal \TRACE_DATA_PIPE[1]\ : STD_LOGIC_VECTOR ( 1 downto 0 );
  attribute RTL_KEEP of \TRACE_DATA_PIPE[1]\ : signal is "true";
  signal \TRACE_DATA_PIPE[2]\ : STD_LOGIC_VECTOR ( 1 downto 0 );
  attribute RTL_KEEP of \TRACE_DATA_PIPE[2]\ : signal is "true";
  signal \TRACE_DATA_PIPE[3]\ : STD_LOGIC_VECTOR ( 1 downto 0 );
  attribute RTL_KEEP of \TRACE_DATA_PIPE[3]\ : signal is "true";
  signal \TRACE_DATA_PIPE[4]\ : STD_LOGIC_VECTOR ( 1 downto 0 );
  attribute RTL_KEEP of \TRACE_DATA_PIPE[4]\ : signal is "true";
  signal \TRACE_DATA_PIPE[5]\ : STD_LOGIC_VECTOR ( 1 downto 0 );
  attribute RTL_KEEP of \TRACE_DATA_PIPE[5]\ : signal is "true";
  signal \TRACE_DATA_PIPE[6]\ : STD_LOGIC_VECTOR ( 1 downto 0 );
  attribute RTL_KEEP of \TRACE_DATA_PIPE[6]\ : signal is "true";
  signal \TRACE_DATA_PIPE[7]\ : STD_LOGIC_VECTOR ( 1 downto 0 );
  attribute RTL_KEEP of \TRACE_DATA_PIPE[7]\ : signal is "true";
  signal buffered_DDR_Addr : STD_LOGIC_VECTOR ( 14 downto 0 );
  signal buffered_DDR_BankAddr : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal buffered_DDR_CAS_n : STD_LOGIC;
  signal buffered_DDR_CKE : STD_LOGIC;
  signal buffered_DDR_CS_n : STD_LOGIC;
  signal buffered_DDR_Clk : STD_LOGIC;
  signal buffered_DDR_Clk_n : STD_LOGIC;
  signal buffered_DDR_DM : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal buffered_DDR_DQ : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal buffered_DDR_DQS : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal buffered_DDR_DQS_n : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal buffered_DDR_DRSTB : STD_LOGIC;
  signal buffered_DDR_ODT : STD_LOGIC;
  signal buffered_DDR_RAS_n : STD_LOGIC;
  signal buffered_DDR_VRN : STD_LOGIC;
  signal buffered_DDR_VRP : STD_LOGIC;
  signal buffered_DDR_WEB : STD_LOGIC;
  signal buffered_MIO : STD_LOGIC_VECTOR ( 53 downto 0 );
  signal buffered_PS_CLK : STD_LOGIC;
  signal buffered_PS_PORB : STD_LOGIC;
  signal buffered_PS_SRSTB : STD_LOGIC;
  signal gpio_out_t_n : STD_LOGIC_VECTOR ( 63 downto 0 );
  signal NLW_PS7_i_EMIOENET0GMIITXEN_UNCONNECTED : STD_LOGIC;
  signal NLW_PS7_i_EMIOENET0GMIITXER_UNCONNECTED : STD_LOGIC;
  signal NLW_PS7_i_EMIOENET1GMIITXEN_UNCONNECTED : STD_LOGIC;
  signal NLW_PS7_i_EMIOENET1GMIITXER_UNCONNECTED : STD_LOGIC;
  signal NLW_PS7_i_EMIOPJTAGTDO_UNCONNECTED : STD_LOGIC;
  signal NLW_PS7_i_EMIOPJTAGTDTN_UNCONNECTED : STD_LOGIC;
  signal NLW_PS7_i_EMIOTRACECTL_UNCONNECTED : STD_LOGIC;
  signal NLW_PS7_i_EMIOENET0GMIITXD_UNCONNECTED : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal NLW_PS7_i_EMIOENET1GMIITXD_UNCONNECTED : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal NLW_PS7_i_EMIOTRACEDATA_UNCONNECTED : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal NLW_PS7_i_MAXIGP0ARCACHE_UNCONNECTED : STD_LOGIC_VECTOR ( 1 to 1 );
  signal NLW_PS7_i_MAXIGP0AWCACHE_UNCONNECTED : STD_LOGIC_VECTOR ( 1 to 1 );
  signal NLW_PS7_i_MAXIGP1ARCACHE_UNCONNECTED : STD_LOGIC_VECTOR ( 1 to 1 );
  signal NLW_PS7_i_MAXIGP1AWCACHE_UNCONNECTED : STD_LOGIC_VECTOR ( 1 to 1 );
  attribute BOX_TYPE : string;
  attribute BOX_TYPE of DDR_CAS_n_BIBUF : label is "PRIMITIVE";
  attribute BOX_TYPE of DDR_CKE_BIBUF : label is "PRIMITIVE";
  attribute BOX_TYPE of DDR_CS_n_BIBUF : label is "PRIMITIVE";
  attribute BOX_TYPE of DDR_Clk_BIBUF : label is "PRIMITIVE";
  attribute BOX_TYPE of DDR_Clk_n_BIBUF : label is "PRIMITIVE";
  attribute BOX_TYPE of DDR_DRSTB_BIBUF : label is "PRIMITIVE";
  attribute BOX_TYPE of DDR_ODT_BIBUF : label is "PRIMITIVE";
  attribute BOX_TYPE of DDR_RAS_n_BIBUF : label is "PRIMITIVE";
  attribute BOX_TYPE of DDR_VRN_BIBUF : label is "PRIMITIVE";
  attribute BOX_TYPE of DDR_VRP_BIBUF : label is "PRIMITIVE";
  attribute BOX_TYPE of DDR_WEB_BIBUF : label is "PRIMITIVE";
  attribute BOX_TYPE of PS7_i : label is "PRIMITIVE";
  attribute BOX_TYPE of PS_CLK_BIBUF : label is "PRIMITIVE";
  attribute BOX_TYPE of PS_PORB_BIBUF : label is "PRIMITIVE";
  attribute BOX_TYPE of PS_SRSTB_BIBUF : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk13[0].MIO_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk13[10].MIO_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk13[11].MIO_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk13[12].MIO_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk13[13].MIO_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk13[14].MIO_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk13[15].MIO_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk13[16].MIO_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk13[17].MIO_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk13[18].MIO_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk13[19].MIO_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk13[1].MIO_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk13[20].MIO_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk13[21].MIO_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk13[22].MIO_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk13[23].MIO_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk13[24].MIO_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk13[25].MIO_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk13[26].MIO_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk13[27].MIO_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk13[28].MIO_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk13[29].MIO_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk13[2].MIO_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk13[30].MIO_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk13[31].MIO_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk13[32].MIO_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk13[33].MIO_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk13[34].MIO_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk13[35].MIO_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk13[36].MIO_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk13[37].MIO_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk13[38].MIO_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk13[39].MIO_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk13[3].MIO_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk13[40].MIO_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk13[41].MIO_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk13[42].MIO_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk13[43].MIO_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk13[44].MIO_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk13[45].MIO_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk13[46].MIO_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk13[47].MIO_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk13[48].MIO_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk13[49].MIO_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk13[4].MIO_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk13[50].MIO_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk13[51].MIO_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk13[52].MIO_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk13[53].MIO_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk13[5].MIO_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk13[6].MIO_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk13[7].MIO_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk13[8].MIO_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk13[9].MIO_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk14[0].DDR_BankAddr_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk14[1].DDR_BankAddr_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk14[2].DDR_BankAddr_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk15[0].DDR_Addr_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk15[10].DDR_Addr_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk15[11].DDR_Addr_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk15[12].DDR_Addr_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk15[13].DDR_Addr_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk15[14].DDR_Addr_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk15[1].DDR_Addr_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk15[2].DDR_Addr_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk15[3].DDR_Addr_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk15[4].DDR_Addr_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk15[5].DDR_Addr_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk15[6].DDR_Addr_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk15[7].DDR_Addr_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk15[8].DDR_Addr_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk15[9].DDR_Addr_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk16[0].DDR_DM_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk16[1].DDR_DM_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk16[2].DDR_DM_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk16[3].DDR_DM_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk17[0].DDR_DQ_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk17[10].DDR_DQ_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk17[11].DDR_DQ_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk17[12].DDR_DQ_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk17[13].DDR_DQ_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk17[14].DDR_DQ_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk17[15].DDR_DQ_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk17[16].DDR_DQ_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk17[17].DDR_DQ_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk17[18].DDR_DQ_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk17[19].DDR_DQ_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk17[1].DDR_DQ_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk17[20].DDR_DQ_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk17[21].DDR_DQ_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk17[22].DDR_DQ_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk17[23].DDR_DQ_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk17[24].DDR_DQ_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk17[25].DDR_DQ_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk17[26].DDR_DQ_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk17[27].DDR_DQ_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk17[28].DDR_DQ_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk17[29].DDR_DQ_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk17[2].DDR_DQ_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk17[30].DDR_DQ_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk17[31].DDR_DQ_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk17[3].DDR_DQ_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk17[4].DDR_DQ_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk17[5].DDR_DQ_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk17[6].DDR_DQ_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk17[7].DDR_DQ_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk17[8].DDR_DQ_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk17[9].DDR_DQ_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk18[0].DDR_DQS_n_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk18[1].DDR_DQS_n_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk18[2].DDR_DQS_n_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk18[3].DDR_DQS_n_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk19[0].DDR_DQS_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk19[1].DDR_DQS_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk19[2].DDR_DQS_BIBUF\ : label is "PRIMITIVE";
  attribute BOX_TYPE of \genblk19[3].DDR_DQS_BIBUF\ : label is "PRIMITIVE";
begin
  CAN0_PHY_TX <= \<const0>\;
  CAN1_PHY_TX <= \<const0>\;
  DMA0_DATYPE(1) <= \<const0>\;
  DMA0_DATYPE(0) <= \<const0>\;
  DMA0_DAVALID <= \<const0>\;
  DMA0_DRREADY <= \<const0>\;
  DMA0_RSTN <= \<const0>\;
  DMA1_DATYPE(1) <= \<const0>\;
  DMA1_DATYPE(0) <= \<const0>\;
  DMA1_DAVALID <= \<const0>\;
  DMA1_DRREADY <= \<const0>\;
  DMA1_RSTN <= \<const0>\;
  DMA2_DATYPE(1) <= \<const0>\;
  DMA2_DATYPE(0) <= \<const0>\;
  DMA2_DAVALID <= \<const0>\;
  DMA2_DRREADY <= \<const0>\;
  DMA2_RSTN <= \<const0>\;
  DMA3_DATYPE(1) <= \<const0>\;
  DMA3_DATYPE(0) <= \<const0>\;
  DMA3_DAVALID <= \<const0>\;
  DMA3_DRREADY <= \<const0>\;
  DMA3_RSTN <= \<const0>\;
  ENET0_GMII_TXD(7) <= \<const0>\;
  ENET0_GMII_TXD(6) <= \<const0>\;
  ENET0_GMII_TXD(5) <= \<const0>\;
  ENET0_GMII_TXD(4) <= \<const0>\;
  ENET0_GMII_TXD(3) <= \<const0>\;
  ENET0_GMII_TXD(2) <= \<const0>\;
  ENET0_GMII_TXD(1) <= \<const0>\;
  ENET0_GMII_TXD(0) <= \<const0>\;
  ENET0_GMII_TX_EN <= \<const0>\;
  ENET0_GMII_TX_ER <= \<const0>\;
  ENET0_MDIO_MDC <= \<const0>\;
  ENET0_MDIO_O <= \<const0>\;
  ENET0_MDIO_T <= \<const0>\;
  ENET0_PTP_DELAY_REQ_RX <= \<const0>\;
  ENET0_PTP_DELAY_REQ_TX <= \<const0>\;
  ENET0_PTP_PDELAY_REQ_RX <= \<const0>\;
  ENET0_PTP_PDELAY_REQ_TX <= \<const0>\;
  ENET0_PTP_PDELAY_RESP_RX <= \<const0>\;
  ENET0_PTP_PDELAY_RESP_TX <= \<const0>\;
  ENET0_PTP_SYNC_FRAME_RX <= \<const0>\;
  ENET0_PTP_SYNC_FRAME_TX <= \<const0>\;
  ENET0_SOF_RX <= \<const0>\;
  ENET0_SOF_TX <= \<const0>\;
  ENET1_GMII_TXD(7) <= \<const0>\;
  ENET1_GMII_TXD(6) <= \<const0>\;
  ENET1_GMII_TXD(5) <= \<const0>\;
  ENET1_GMII_TXD(4) <= \<const0>\;
  ENET1_GMII_TXD(3) <= \<const0>\;
  ENET1_GMII_TXD(2) <= \<const0>\;
  ENET1_GMII_TXD(1) <= \<const0>\;
  ENET1_GMII_TXD(0) <= \<const0>\;
  ENET1_GMII_TX_EN <= \<const0>\;
  ENET1_GMII_TX_ER <= \<const0>\;
  ENET1_MDIO_MDC <= \<const0>\;
  ENET1_MDIO_O <= \<const0>\;
  ENET1_MDIO_T <= \<const0>\;
  ENET1_PTP_DELAY_REQ_RX <= \<const0>\;
  ENET1_PTP_DELAY_REQ_TX <= \<const0>\;
  ENET1_PTP_PDELAY_REQ_RX <= \<const0>\;
  ENET1_PTP_PDELAY_REQ_TX <= \<const0>\;
  ENET1_PTP_PDELAY_RESP_RX <= \<const0>\;
  ENET1_PTP_PDELAY_RESP_TX <= \<const0>\;
  ENET1_PTP_SYNC_FRAME_RX <= \<const0>\;
  ENET1_PTP_SYNC_FRAME_TX <= \<const0>\;
  ENET1_SOF_RX <= \<const0>\;
  ENET1_SOF_TX <= \<const0>\;
  EVENT_EVENTO <= \<const0>\;
  EVENT_STANDBYWFE(1) <= \<const0>\;
  EVENT_STANDBYWFE(0) <= \<const0>\;
  EVENT_STANDBYWFI(1) <= \<const0>\;
  EVENT_STANDBYWFI(0) <= \<const0>\;
  FCLK_CLK1 <= \<const0>\;
  FCLK_CLK2 <= \<const0>\;
  FCLK_CLK3 <= \<const0>\;
  FCLK_RESET1_N <= \<const0>\;
  FCLK_RESET2_N <= \<const0>\;
  FCLK_RESET3_N <= \<const0>\;
  FTMT_F2P_TRIGACK_0 <= \<const0>\;
  FTMT_F2P_TRIGACK_1 <= \<const0>\;
  FTMT_F2P_TRIGACK_2 <= \<const0>\;
  FTMT_F2P_TRIGACK_3 <= \<const0>\;
  FTMT_P2F_DEBUG(31) <= \<const0>\;
  FTMT_P2F_DEBUG(30) <= \<const0>\;
  FTMT_P2F_DEBUG(29) <= \<const0>\;
  FTMT_P2F_DEBUG(28) <= \<const0>\;
  FTMT_P2F_DEBUG(27) <= \<const0>\;
  FTMT_P2F_DEBUG(26) <= \<const0>\;
  FTMT_P2F_DEBUG(25) <= \<const0>\;
  FTMT_P2F_DEBUG(24) <= \<const0>\;
  FTMT_P2F_DEBUG(23) <= \<const0>\;
  FTMT_P2F_DEBUG(22) <= \<const0>\;
  FTMT_P2F_DEBUG(21) <= \<const0>\;
  FTMT_P2F_DEBUG(20) <= \<const0>\;
  FTMT_P2F_DEBUG(19) <= \<const0>\;
  FTMT_P2F_DEBUG(18) <= \<const0>\;
  FTMT_P2F_DEBUG(17) <= \<const0>\;
  FTMT_P2F_DEBUG(16) <= \<const0>\;
  FTMT_P2F_DEBUG(15) <= \<const0>\;
  FTMT_P2F_DEBUG(14) <= \<const0>\;
  FTMT_P2F_DEBUG(13) <= \<const0>\;
  FTMT_P2F_DEBUG(12) <= \<const0>\;
  FTMT_P2F_DEBUG(11) <= \<const0>\;
  FTMT_P2F_DEBUG(10) <= \<const0>\;
  FTMT_P2F_DEBUG(9) <= \<const0>\;
  FTMT_P2F_DEBUG(8) <= \<const0>\;
  FTMT_P2F_DEBUG(7) <= \<const0>\;
  FTMT_P2F_DEBUG(6) <= \<const0>\;
  FTMT_P2F_DEBUG(5) <= \<const0>\;
  FTMT_P2F_DEBUG(4) <= \<const0>\;
  FTMT_P2F_DEBUG(3) <= \<const0>\;
  FTMT_P2F_DEBUG(2) <= \<const0>\;
  FTMT_P2F_DEBUG(1) <= \<const0>\;
  FTMT_P2F_DEBUG(0) <= \<const0>\;
  FTMT_P2F_TRIG_0 <= \<const0>\;
  FTMT_P2F_TRIG_1 <= \<const0>\;
  FTMT_P2F_TRIG_2 <= \<const0>\;
  FTMT_P2F_TRIG_3 <= \<const0>\;
  GPIO_O(63) <= \<const0>\;
  GPIO_O(62) <= \<const0>\;
  GPIO_O(61) <= \<const0>\;
  GPIO_O(60) <= \<const0>\;
  GPIO_O(59) <= \<const0>\;
  GPIO_O(58) <= \<const0>\;
  GPIO_O(57) <= \<const0>\;
  GPIO_O(56) <= \<const0>\;
  GPIO_O(55) <= \<const0>\;
  GPIO_O(54) <= \<const0>\;
  GPIO_O(53) <= \<const0>\;
  GPIO_O(52) <= \<const0>\;
  GPIO_O(51) <= \<const0>\;
  GPIO_O(50) <= \<const0>\;
  GPIO_O(49) <= \<const0>\;
  GPIO_O(48) <= \<const0>\;
  GPIO_O(47) <= \<const0>\;
  GPIO_O(46) <= \<const0>\;
  GPIO_O(45) <= \<const0>\;
  GPIO_O(44) <= \<const0>\;
  GPIO_O(43) <= \<const0>\;
  GPIO_O(42) <= \<const0>\;
  GPIO_O(41) <= \<const0>\;
  GPIO_O(40) <= \<const0>\;
  GPIO_O(39) <= \<const0>\;
  GPIO_O(38) <= \<const0>\;
  GPIO_O(37) <= \<const0>\;
  GPIO_O(36) <= \<const0>\;
  GPIO_O(35) <= \<const0>\;
  GPIO_O(34) <= \<const0>\;
  GPIO_O(33) <= \<const0>\;
  GPIO_O(32) <= \<const0>\;
  GPIO_O(31) <= \<const0>\;
  GPIO_O(30) <= \<const0>\;
  GPIO_O(29) <= \<const0>\;
  GPIO_O(28) <= \<const0>\;
  GPIO_O(27) <= \<const0>\;
  GPIO_O(26) <= \<const0>\;
  GPIO_O(25) <= \<const0>\;
  GPIO_O(24) <= \<const0>\;
  GPIO_O(23) <= \<const0>\;
  GPIO_O(22) <= \<const0>\;
  GPIO_O(21) <= \<const0>\;
  GPIO_O(20) <= \<const0>\;
  GPIO_O(19) <= \<const0>\;
  GPIO_O(18) <= \<const0>\;
  GPIO_O(17) <= \<const0>\;
  GPIO_O(16) <= \<const0>\;
  GPIO_O(15) <= \<const0>\;
  GPIO_O(14) <= \<const0>\;
  GPIO_O(13) <= \<const0>\;
  GPIO_O(12) <= \<const0>\;
  GPIO_O(11) <= \<const0>\;
  GPIO_O(10) <= \<const0>\;
  GPIO_O(9) <= \<const0>\;
  GPIO_O(8) <= \<const0>\;
  GPIO_O(7) <= \<const0>\;
  GPIO_O(6) <= \<const0>\;
  GPIO_O(5) <= \<const0>\;
  GPIO_O(4) <= \<const0>\;
  GPIO_O(3) <= \<const0>\;
  GPIO_O(2) <= \<const0>\;
  GPIO_O(1) <= \<const0>\;
  GPIO_O(0) <= \<const0>\;
  GPIO_T(63) <= \<const0>\;
  GPIO_T(62) <= \<const0>\;
  GPIO_T(61) <= \<const0>\;
  GPIO_T(60) <= \<const0>\;
  GPIO_T(59) <= \<const0>\;
  GPIO_T(58) <= \<const0>\;
  GPIO_T(57) <= \<const0>\;
  GPIO_T(56) <= \<const0>\;
  GPIO_T(55) <= \<const0>\;
  GPIO_T(54) <= \<const0>\;
  GPIO_T(53) <= \<const0>\;
  GPIO_T(52) <= \<const0>\;
  GPIO_T(51) <= \<const0>\;
  GPIO_T(50) <= \<const0>\;
  GPIO_T(49) <= \<const0>\;
  GPIO_T(48) <= \<const0>\;
  GPIO_T(47) <= \<const0>\;
  GPIO_T(46) <= \<const0>\;
  GPIO_T(45) <= \<const0>\;
  GPIO_T(44) <= \<const0>\;
  GPIO_T(43) <= \<const0>\;
  GPIO_T(42) <= \<const0>\;
  GPIO_T(41) <= \<const0>\;
  GPIO_T(40) <= \<const0>\;
  GPIO_T(39) <= \<const0>\;
  GPIO_T(38) <= \<const0>\;
  GPIO_T(37) <= \<const0>\;
  GPIO_T(36) <= \<const0>\;
  GPIO_T(35) <= \<const0>\;
  GPIO_T(34) <= \<const0>\;
  GPIO_T(33) <= \<const0>\;
  GPIO_T(32) <= \<const0>\;
  GPIO_T(31) <= \<const0>\;
  GPIO_T(30) <= \<const0>\;
  GPIO_T(29) <= \<const0>\;
  GPIO_T(28) <= \<const0>\;
  GPIO_T(27) <= \<const0>\;
  GPIO_T(26) <= \<const0>\;
  GPIO_T(25) <= \<const0>\;
  GPIO_T(24) <= \<const0>\;
  GPIO_T(23) <= \<const0>\;
  GPIO_T(22) <= \<const0>\;
  GPIO_T(21) <= \<const0>\;
  GPIO_T(20) <= \<const0>\;
  GPIO_T(19) <= \<const0>\;
  GPIO_T(18) <= \<const0>\;
  GPIO_T(17) <= \<const0>\;
  GPIO_T(16) <= \<const0>\;
  GPIO_T(15) <= \<const0>\;
  GPIO_T(14) <= \<const0>\;
  GPIO_T(13) <= \<const0>\;
  GPIO_T(12) <= \<const0>\;
  GPIO_T(11) <= \<const0>\;
  GPIO_T(10) <= \<const0>\;
  GPIO_T(9) <= \<const0>\;
  GPIO_T(8) <= \<const0>\;
  GPIO_T(7) <= \<const0>\;
  GPIO_T(6) <= \<const0>\;
  GPIO_T(5) <= \<const0>\;
  GPIO_T(4) <= \<const0>\;
  GPIO_T(3) <= \<const0>\;
  GPIO_T(2) <= \<const0>\;
  GPIO_T(1) <= \<const0>\;
  GPIO_T(0) <= \<const0>\;
  I2C0_SCL_O <= \<const0>\;
  I2C0_SCL_T <= \<const0>\;
  I2C0_SDA_O <= \<const0>\;
  I2C0_SDA_T <= \<const0>\;
  I2C1_SCL_O <= \<const0>\;
  I2C1_SCL_T <= \<const0>\;
  I2C1_SDA_O <= \<const0>\;
  I2C1_SDA_T <= \<const0>\;
  IRQ_P2F_CAN0 <= \<const0>\;
  IRQ_P2F_CAN1 <= \<const0>\;
  IRQ_P2F_CTI <= \<const0>\;
  IRQ_P2F_DMAC0 <= \<const0>\;
  IRQ_P2F_DMAC1 <= \<const0>\;
  IRQ_P2F_DMAC2 <= \<const0>\;
  IRQ_P2F_DMAC3 <= \<const0>\;
  IRQ_P2F_DMAC4 <= \<const0>\;
  IRQ_P2F_DMAC5 <= \<const0>\;
  IRQ_P2F_DMAC6 <= \<const0>\;
  IRQ_P2F_DMAC7 <= \<const0>\;
  IRQ_P2F_DMAC_ABORT <= \<const0>\;
  IRQ_P2F_ENET0 <= \<const0>\;
  IRQ_P2F_ENET1 <= \<const0>\;
  IRQ_P2F_ENET_WAKE0 <= \<const0>\;
  IRQ_P2F_ENET_WAKE1 <= \<const0>\;
  IRQ_P2F_GPIO <= \<const0>\;
  IRQ_P2F_I2C0 <= \<const0>\;
  IRQ_P2F_I2C1 <= \<const0>\;
  IRQ_P2F_QSPI <= \<const0>\;
  IRQ_P2F_SDIO0 <= \<const0>\;
  IRQ_P2F_SDIO1 <= \<const0>\;
  IRQ_P2F_SMC <= \<const0>\;
  IRQ_P2F_SPI0 <= \<const0>\;
  IRQ_P2F_SPI1 <= \<const0>\;
  IRQ_P2F_UART0 <= \<const0>\;
  IRQ_P2F_UART1 <= \<const0>\;
  IRQ_P2F_USB0 <= \<const0>\;
  IRQ_P2F_USB1 <= \<const0>\;
  M_AXI_GP0_ARADDR(31) <= \<const0>\;
  M_AXI_GP0_ARADDR(30) <= \<const0>\;
  M_AXI_GP0_ARADDR(29) <= \<const0>\;
  M_AXI_GP0_ARADDR(28) <= \<const0>\;
  M_AXI_GP0_ARADDR(27) <= \<const0>\;
  M_AXI_GP0_ARADDR(26) <= \<const0>\;
  M_AXI_GP0_ARADDR(25) <= \<const0>\;
  M_AXI_GP0_ARADDR(24) <= \<const0>\;
  M_AXI_GP0_ARADDR(23) <= \<const0>\;
  M_AXI_GP0_ARADDR(22) <= \<const0>\;
  M_AXI_GP0_ARADDR(21) <= \<const0>\;
  M_AXI_GP0_ARADDR(20) <= \<const0>\;
  M_AXI_GP0_ARADDR(19) <= \<const0>\;
  M_AXI_GP0_ARADDR(18) <= \<const0>\;
  M_AXI_GP0_ARADDR(17) <= \<const0>\;
  M_AXI_GP0_ARADDR(16) <= \<const0>\;
  M_AXI_GP0_ARADDR(15) <= \<const0>\;
  M_AXI_GP0_ARADDR(14) <= \<const0>\;
  M_AXI_GP0_ARADDR(13) <= \<const0>\;
  M_AXI_GP0_ARADDR(12) <= \<const0>\;
  M_AXI_GP0_ARADDR(11) <= \<const0>\;
  M_AXI_GP0_ARADDR(10) <= \<const0>\;
  M_AXI_GP0_ARADDR(9) <= \<const0>\;
  M_AXI_GP0_ARADDR(8) <= \<const0>\;
  M_AXI_GP0_ARADDR(7) <= \<const0>\;
  M_AXI_GP0_ARADDR(6) <= \<const0>\;
  M_AXI_GP0_ARADDR(5) <= \<const0>\;
  M_AXI_GP0_ARADDR(4) <= \<const0>\;
  M_AXI_GP0_ARADDR(3) <= \<const0>\;
  M_AXI_GP0_ARADDR(2) <= \<const0>\;
  M_AXI_GP0_ARADDR(1) <= \<const0>\;
  M_AXI_GP0_ARADDR(0) <= \<const0>\;
  M_AXI_GP0_ARBURST(1) <= \<const0>\;
  M_AXI_GP0_ARBURST(0) <= \<const0>\;
  M_AXI_GP0_ARCACHE(3) <= \<const0>\;
  M_AXI_GP0_ARCACHE(2) <= \<const0>\;
  M_AXI_GP0_ARCACHE(1) <= \<const0>\;
  M_AXI_GP0_ARCACHE(0) <= \<const0>\;
  M_AXI_GP0_ARESETN <= \<const0>\;
  M_AXI_GP0_ARID(11) <= \<const0>\;
  M_AXI_GP0_ARID(10) <= \<const0>\;
  M_AXI_GP0_ARID(9) <= \<const0>\;
  M_AXI_GP0_ARID(8) <= \<const0>\;
  M_AXI_GP0_ARID(7) <= \<const0>\;
  M_AXI_GP0_ARID(6) <= \<const0>\;
  M_AXI_GP0_ARID(5) <= \<const0>\;
  M_AXI_GP0_ARID(4) <= \<const0>\;
  M_AXI_GP0_ARID(3) <= \<const0>\;
  M_AXI_GP0_ARID(2) <= \<const0>\;
  M_AXI_GP0_ARID(1) <= \<const0>\;
  M_AXI_GP0_ARID(0) <= \<const0>\;
  M_AXI_GP0_ARLEN(3) <= \<const0>\;
  M_AXI_GP0_ARLEN(2) <= \<const0>\;
  M_AXI_GP0_ARLEN(1) <= \<const0>\;
  M_AXI_GP0_ARLEN(0) <= \<const0>\;
  M_AXI_GP0_ARLOCK(1) <= \<const0>\;
  M_AXI_GP0_ARLOCK(0) <= \<const0>\;
  M_AXI_GP0_ARPROT(2) <= \<const0>\;
  M_AXI_GP0_ARPROT(1) <= \<const0>\;
  M_AXI_GP0_ARPROT(0) <= \<const0>\;
  M_AXI_GP0_ARQOS(3) <= \<const0>\;
  M_AXI_GP0_ARQOS(2) <= \<const0>\;
  M_AXI_GP0_ARQOS(1) <= \<const0>\;
  M_AXI_GP0_ARQOS(0) <= \<const0>\;
  M_AXI_GP0_ARSIZE(2) <= \<const0>\;
  M_AXI_GP0_ARSIZE(1) <= \<const0>\;
  M_AXI_GP0_ARSIZE(0) <= \<const0>\;
  M_AXI_GP0_ARVALID <= \<const0>\;
  M_AXI_GP0_AWADDR(31) <= \<const0>\;
  M_AXI_GP0_AWADDR(30) <= \<const0>\;
  M_AXI_GP0_AWADDR(29) <= \<const0>\;
  M_AXI_GP0_AWADDR(28) <= \<const0>\;
  M_AXI_GP0_AWADDR(27) <= \<const0>\;
  M_AXI_GP0_AWADDR(26) <= \<const0>\;
  M_AXI_GP0_AWADDR(25) <= \<const0>\;
  M_AXI_GP0_AWADDR(24) <= \<const0>\;
  M_AXI_GP0_AWADDR(23) <= \<const0>\;
  M_AXI_GP0_AWADDR(22) <= \<const0>\;
  M_AXI_GP0_AWADDR(21) <= \<const0>\;
  M_AXI_GP0_AWADDR(20) <= \<const0>\;
  M_AXI_GP0_AWADDR(19) <= \<const0>\;
  M_AXI_GP0_AWADDR(18) <= \<const0>\;
  M_AXI_GP0_AWADDR(17) <= \<const0>\;
  M_AXI_GP0_AWADDR(16) <= \<const0>\;
  M_AXI_GP0_AWADDR(15) <= \<const0>\;
  M_AXI_GP0_AWADDR(14) <= \<const0>\;
  M_AXI_GP0_AWADDR(13) <= \<const0>\;
  M_AXI_GP0_AWADDR(12) <= \<const0>\;
  M_AXI_GP0_AWADDR(11) <= \<const0>\;
  M_AXI_GP0_AWADDR(10) <= \<const0>\;
  M_AXI_GP0_AWADDR(9) <= \<const0>\;
  M_AXI_GP0_AWADDR(8) <= \<const0>\;
  M_AXI_GP0_AWADDR(7) <= \<const0>\;
  M_AXI_GP0_AWADDR(6) <= \<const0>\;
  M_AXI_GP0_AWADDR(5) <= \<const0>\;
  M_AXI_GP0_AWADDR(4) <= \<const0>\;
  M_AXI_GP0_AWADDR(3) <= \<const0>\;
  M_AXI_GP0_AWADDR(2) <= \<const0>\;
  M_AXI_GP0_AWADDR(1) <= \<const0>\;
  M_AXI_GP0_AWADDR(0) <= \<const0>\;
  M_AXI_GP0_AWBURST(1) <= \<const0>\;
  M_AXI_GP0_AWBURST(0) <= \<const0>\;
  M_AXI_GP0_AWCACHE(3) <= \<const0>\;
  M_AXI_GP0_AWCACHE(2) <= \<const0>\;
  M_AXI_GP0_AWCACHE(1) <= \<const0>\;
  M_AXI_GP0_AWCACHE(0) <= \<const0>\;
  M_AXI_GP0_AWID(11) <= \<const0>\;
  M_AXI_GP0_AWID(10) <= \<const0>\;
  M_AXI_GP0_AWID(9) <= \<const0>\;
  M_AXI_GP0_AWID(8) <= \<const0>\;
  M_AXI_GP0_AWID(7) <= \<const0>\;
  M_AXI_GP0_AWID(6) <= \<const0>\;
  M_AXI_GP0_AWID(5) <= \<const0>\;
  M_AXI_GP0_AWID(4) <= \<const0>\;
  M_AXI_GP0_AWID(3) <= \<const0>\;
  M_AXI_GP0_AWID(2) <= \<const0>\;
  M_AXI_GP0_AWID(1) <= \<const0>\;
  M_AXI_GP0_AWID(0) <= \<const0>\;
  M_AXI_GP0_AWLEN(3) <= \<const0>\;
  M_AXI_GP0_AWLEN(2) <= \<const0>\;
  M_AXI_GP0_AWLEN(1) <= \<const0>\;
  M_AXI_GP0_AWLEN(0) <= \<const0>\;
  M_AXI_GP0_AWLOCK(1) <= \<const0>\;
  M_AXI_GP0_AWLOCK(0) <= \<const0>\;
  M_AXI_GP0_AWPROT(2) <= \<const0>\;
  M_AXI_GP0_AWPROT(1) <= \<const0>\;
  M_AXI_GP0_AWPROT(0) <= \<const0>\;
  M_AXI_GP0_AWQOS(3) <= \<const0>\;
  M_AXI_GP0_AWQOS(2) <= \<const0>\;
  M_AXI_GP0_AWQOS(1) <= \<const0>\;
  M_AXI_GP0_AWQOS(0) <= \<const0>\;
  M_AXI_GP0_AWSIZE(2) <= \<const0>\;
  M_AXI_GP0_AWSIZE(1) <= \<const0>\;
  M_AXI_GP0_AWSIZE(0) <= \<const0>\;
  M_AXI_GP0_AWVALID <= \<const0>\;
  M_AXI_GP0_BREADY <= \<const0>\;
  M_AXI_GP0_RREADY <= \<const0>\;
  M_AXI_GP0_WDATA(31) <= \<const0>\;
  M_AXI_GP0_WDATA(30) <= \<const0>\;
  M_AXI_GP0_WDATA(29) <= \<const0>\;
  M_AXI_GP0_WDATA(28) <= \<const0>\;
  M_AXI_GP0_WDATA(27) <= \<const0>\;
  M_AXI_GP0_WDATA(26) <= \<const0>\;
  M_AXI_GP0_WDATA(25) <= \<const0>\;
  M_AXI_GP0_WDATA(24) <= \<const0>\;
  M_AXI_GP0_WDATA(23) <= \<const0>\;
  M_AXI_GP0_WDATA(22) <= \<const0>\;
  M_AXI_GP0_WDATA(21) <= \<const0>\;
  M_AXI_GP0_WDATA(20) <= \<const0>\;
  M_AXI_GP0_WDATA(19) <= \<const0>\;
  M_AXI_GP0_WDATA(18) <= \<const0>\;
  M_AXI_GP0_WDATA(17) <= \<const0>\;
  M_AXI_GP0_WDATA(16) <= \<const0>\;
  M_AXI_GP0_WDATA(15) <= \<const0>\;
  M_AXI_GP0_WDATA(14) <= \<const0>\;
  M_AXI_GP0_WDATA(13) <= \<const0>\;
  M_AXI_GP0_WDATA(12) <= \<const0>\;
  M_AXI_GP0_WDATA(11) <= \<const0>\;
  M_AXI_GP0_WDATA(10) <= \<const0>\;
  M_AXI_GP0_WDATA(9) <= \<const0>\;
  M_AXI_GP0_WDATA(8) <= \<const0>\;
  M_AXI_GP0_WDATA(7) <= \<const0>\;
  M_AXI_GP0_WDATA(6) <= \<const0>\;
  M_AXI_GP0_WDATA(5) <= \<const0>\;
  M_AXI_GP0_WDATA(4) <= \<const0>\;
  M_AXI_GP0_WDATA(3) <= \<const0>\;
  M_AXI_GP0_WDATA(2) <= \<const0>\;
  M_AXI_GP0_WDATA(1) <= \<const0>\;
  M_AXI_GP0_WDATA(0) <= \<const0>\;
  M_AXI_GP0_WID(11) <= \<const0>\;
  M_AXI_GP0_WID(10) <= \<const0>\;
  M_AXI_GP0_WID(9) <= \<const0>\;
  M_AXI_GP0_WID(8) <= \<const0>\;
  M_AXI_GP0_WID(7) <= \<const0>\;
  M_AXI_GP0_WID(6) <= \<const0>\;
  M_AXI_GP0_WID(5) <= \<const0>\;
  M_AXI_GP0_WID(4) <= \<const0>\;
  M_AXI_GP0_WID(3) <= \<const0>\;
  M_AXI_GP0_WID(2) <= \<const0>\;
  M_AXI_GP0_WID(1) <= \<const0>\;
  M_AXI_GP0_WID(0) <= \<const0>\;
  M_AXI_GP0_WLAST <= \<const0>\;
  M_AXI_GP0_WSTRB(3) <= \<const0>\;
  M_AXI_GP0_WSTRB(2) <= \<const0>\;
  M_AXI_GP0_WSTRB(1) <= \<const0>\;
  M_AXI_GP0_WSTRB(0) <= \<const0>\;
  M_AXI_GP0_WVALID <= \<const0>\;
  M_AXI_GP1_ARADDR(31) <= \<const0>\;
  M_AXI_GP1_ARADDR(30) <= \<const0>\;
  M_AXI_GP1_ARADDR(29) <= \<const0>\;
  M_AXI_GP1_ARADDR(28) <= \<const0>\;
  M_AXI_GP1_ARADDR(27) <= \<const0>\;
  M_AXI_GP1_ARADDR(26) <= \<const0>\;
  M_AXI_GP1_ARADDR(25) <= \<const0>\;
  M_AXI_GP1_ARADDR(24) <= \<const0>\;
  M_AXI_GP1_ARADDR(23) <= \<const0>\;
  M_AXI_GP1_ARADDR(22) <= \<const0>\;
  M_AXI_GP1_ARADDR(21) <= \<const0>\;
  M_AXI_GP1_ARADDR(20) <= \<const0>\;
  M_AXI_GP1_ARADDR(19) <= \<const0>\;
  M_AXI_GP1_ARADDR(18) <= \<const0>\;
  M_AXI_GP1_ARADDR(17) <= \<const0>\;
  M_AXI_GP1_ARADDR(16) <= \<const0>\;
  M_AXI_GP1_ARADDR(15) <= \<const0>\;
  M_AXI_GP1_ARADDR(14) <= \<const0>\;
  M_AXI_GP1_ARADDR(13) <= \<const0>\;
  M_AXI_GP1_ARADDR(12) <= \<const0>\;
  M_AXI_GP1_ARADDR(11) <= \<const0>\;
  M_AXI_GP1_ARADDR(10) <= \<const0>\;
  M_AXI_GP1_ARADDR(9) <= \<const0>\;
  M_AXI_GP1_ARADDR(8) <= \<const0>\;
  M_AXI_GP1_ARADDR(7) <= \<const0>\;
  M_AXI_GP1_ARADDR(6) <= \<const0>\;
  M_AXI_GP1_ARADDR(5) <= \<const0>\;
  M_AXI_GP1_ARADDR(4) <= \<const0>\;
  M_AXI_GP1_ARADDR(3) <= \<const0>\;
  M_AXI_GP1_ARADDR(2) <= \<const0>\;
  M_AXI_GP1_ARADDR(1) <= \<const0>\;
  M_AXI_GP1_ARADDR(0) <= \<const0>\;
  M_AXI_GP1_ARBURST(1) <= \<const0>\;
  M_AXI_GP1_ARBURST(0) <= \<const0>\;
  M_AXI_GP1_ARCACHE(3) <= \<const0>\;
  M_AXI_GP1_ARCACHE(2) <= \<const0>\;
  M_AXI_GP1_ARCACHE(1) <= \<const0>\;
  M_AXI_GP1_ARCACHE(0) <= \<const0>\;
  M_AXI_GP1_ARESETN <= \<const0>\;
  M_AXI_GP1_ARID(11) <= \<const0>\;
  M_AXI_GP1_ARID(10) <= \<const0>\;
  M_AXI_GP1_ARID(9) <= \<const0>\;
  M_AXI_GP1_ARID(8) <= \<const0>\;
  M_AXI_GP1_ARID(7) <= \<const0>\;
  M_AXI_GP1_ARID(6) <= \<const0>\;
  M_AXI_GP1_ARID(5) <= \<const0>\;
  M_AXI_GP1_ARID(4) <= \<const0>\;
  M_AXI_GP1_ARID(3) <= \<const0>\;
  M_AXI_GP1_ARID(2) <= \<const0>\;
  M_AXI_GP1_ARID(1) <= \<const0>\;
  M_AXI_GP1_ARID(0) <= \<const0>\;
  M_AXI_GP1_ARLEN(3) <= \<const0>\;
  M_AXI_GP1_ARLEN(2) <= \<const0>\;
  M_AXI_GP1_ARLEN(1) <= \<const0>\;
  M_AXI_GP1_ARLEN(0) <= \<const0>\;
  M_AXI_GP1_ARLOCK(1) <= \<const0>\;
  M_AXI_GP1_ARLOCK(0) <= \<const0>\;
  M_AXI_GP1_ARPROT(2) <= \<const0>\;
  M_AXI_GP1_ARPROT(1) <= \<const0>\;
  M_AXI_GP1_ARPROT(0) <= \<const0>\;
  M_AXI_GP1_ARQOS(3) <= \<const0>\;
  M_AXI_GP1_ARQOS(2) <= \<const0>\;
  M_AXI_GP1_ARQOS(1) <= \<const0>\;
  M_AXI_GP1_ARQOS(0) <= \<const0>\;
  M_AXI_GP1_ARSIZE(2) <= \<const0>\;
  M_AXI_GP1_ARSIZE(1) <= \<const0>\;
  M_AXI_GP1_ARSIZE(0) <= \<const0>\;
  M_AXI_GP1_ARVALID <= \<const0>\;
  M_AXI_GP1_AWADDR(31) <= \<const0>\;
  M_AXI_GP1_AWADDR(30) <= \<const0>\;
  M_AXI_GP1_AWADDR(29) <= \<const0>\;
  M_AXI_GP1_AWADDR(28) <= \<const0>\;
  M_AXI_GP1_AWADDR(27) <= \<const0>\;
  M_AXI_GP1_AWADDR(26) <= \<const0>\;
  M_AXI_GP1_AWADDR(25) <= \<const0>\;
  M_AXI_GP1_AWADDR(24) <= \<const0>\;
  M_AXI_GP1_AWADDR(23) <= \<const0>\;
  M_AXI_GP1_AWADDR(22) <= \<const0>\;
  M_AXI_GP1_AWADDR(21) <= \<const0>\;
  M_AXI_GP1_AWADDR(20) <= \<const0>\;
  M_AXI_GP1_AWADDR(19) <= \<const0>\;
  M_AXI_GP1_AWADDR(18) <= \<const0>\;
  M_AXI_GP1_AWADDR(17) <= \<const0>\;
  M_AXI_GP1_AWADDR(16) <= \<const0>\;
  M_AXI_GP1_AWADDR(15) <= \<const0>\;
  M_AXI_GP1_AWADDR(14) <= \<const0>\;
  M_AXI_GP1_AWADDR(13) <= \<const0>\;
  M_AXI_GP1_AWADDR(12) <= \<const0>\;
  M_AXI_GP1_AWADDR(11) <= \<const0>\;
  M_AXI_GP1_AWADDR(10) <= \<const0>\;
  M_AXI_GP1_AWADDR(9) <= \<const0>\;
  M_AXI_GP1_AWADDR(8) <= \<const0>\;
  M_AXI_GP1_AWADDR(7) <= \<const0>\;
  M_AXI_GP1_AWADDR(6) <= \<const0>\;
  M_AXI_GP1_AWADDR(5) <= \<const0>\;
  M_AXI_GP1_AWADDR(4) <= \<const0>\;
  M_AXI_GP1_AWADDR(3) <= \<const0>\;
  M_AXI_GP1_AWADDR(2) <= \<const0>\;
  M_AXI_GP1_AWADDR(1) <= \<const0>\;
  M_AXI_GP1_AWADDR(0) <= \<const0>\;
  M_AXI_GP1_AWBURST(1) <= \<const0>\;
  M_AXI_GP1_AWBURST(0) <= \<const0>\;
  M_AXI_GP1_AWCACHE(3) <= \<const0>\;
  M_AXI_GP1_AWCACHE(2) <= \<const0>\;
  M_AXI_GP1_AWCACHE(1) <= \<const0>\;
  M_AXI_GP1_AWCACHE(0) <= \<const0>\;
  M_AXI_GP1_AWID(11) <= \<const0>\;
  M_AXI_GP1_AWID(10) <= \<const0>\;
  M_AXI_GP1_AWID(9) <= \<const0>\;
  M_AXI_GP1_AWID(8) <= \<const0>\;
  M_AXI_GP1_AWID(7) <= \<const0>\;
  M_AXI_GP1_AWID(6) <= \<const0>\;
  M_AXI_GP1_AWID(5) <= \<const0>\;
  M_AXI_GP1_AWID(4) <= \<const0>\;
  M_AXI_GP1_AWID(3) <= \<const0>\;
  M_AXI_GP1_AWID(2) <= \<const0>\;
  M_AXI_GP1_AWID(1) <= \<const0>\;
  M_AXI_GP1_AWID(0) <= \<const0>\;
  M_AXI_GP1_AWLEN(3) <= \<const0>\;
  M_AXI_GP1_AWLEN(2) <= \<const0>\;
  M_AXI_GP1_AWLEN(1) <= \<const0>\;
  M_AXI_GP1_AWLEN(0) <= \<const0>\;
  M_AXI_GP1_AWLOCK(1) <= \<const0>\;
  M_AXI_GP1_AWLOCK(0) <= \<const0>\;
  M_AXI_GP1_AWPROT(2) <= \<const0>\;
  M_AXI_GP1_AWPROT(1) <= \<const0>\;
  M_AXI_GP1_AWPROT(0) <= \<const0>\;
  M_AXI_GP1_AWQOS(3) <= \<const0>\;
  M_AXI_GP1_AWQOS(2) <= \<const0>\;
  M_AXI_GP1_AWQOS(1) <= \<const0>\;
  M_AXI_GP1_AWQOS(0) <= \<const0>\;
  M_AXI_GP1_AWSIZE(2) <= \<const0>\;
  M_AXI_GP1_AWSIZE(1) <= \<const0>\;
  M_AXI_GP1_AWSIZE(0) <= \<const0>\;
  M_AXI_GP1_AWVALID <= \<const0>\;
  M_AXI_GP1_BREADY <= \<const0>\;
  M_AXI_GP1_RREADY <= \<const0>\;
  M_AXI_GP1_WDATA(31) <= \<const0>\;
  M_AXI_GP1_WDATA(30) <= \<const0>\;
  M_AXI_GP1_WDATA(29) <= \<const0>\;
  M_AXI_GP1_WDATA(28) <= \<const0>\;
  M_AXI_GP1_WDATA(27) <= \<const0>\;
  M_AXI_GP1_WDATA(26) <= \<const0>\;
  M_AXI_GP1_WDATA(25) <= \<const0>\;
  M_AXI_GP1_WDATA(24) <= \<const0>\;
  M_AXI_GP1_WDATA(23) <= \<const0>\;
  M_AXI_GP1_WDATA(22) <= \<const0>\;
  M_AXI_GP1_WDATA(21) <= \<const0>\;
  M_AXI_GP1_WDATA(20) <= \<const0>\;
  M_AXI_GP1_WDATA(19) <= \<const0>\;
  M_AXI_GP1_WDATA(18) <= \<const0>\;
  M_AXI_GP1_WDATA(17) <= \<const0>\;
  M_AXI_GP1_WDATA(16) <= \<const0>\;
  M_AXI_GP1_WDATA(15) <= \<const0>\;
  M_AXI_GP1_WDATA(14) <= \<const0>\;
  M_AXI_GP1_WDATA(13) <= \<const0>\;
  M_AXI_GP1_WDATA(12) <= \<const0>\;
  M_AXI_GP1_WDATA(11) <= \<const0>\;
  M_AXI_GP1_WDATA(10) <= \<const0>\;
  M_AXI_GP1_WDATA(9) <= \<const0>\;
  M_AXI_GP1_WDATA(8) <= \<const0>\;
  M_AXI_GP1_WDATA(7) <= \<const0>\;
  M_AXI_GP1_WDATA(6) <= \<const0>\;
  M_AXI_GP1_WDATA(5) <= \<const0>\;
  M_AXI_GP1_WDATA(4) <= \<const0>\;
  M_AXI_GP1_WDATA(3) <= \<const0>\;
  M_AXI_GP1_WDATA(2) <= \<const0>\;
  M_AXI_GP1_WDATA(1) <= \<const0>\;
  M_AXI_GP1_WDATA(0) <= \<const0>\;
  M_AXI_GP1_WID(11) <= \<const0>\;
  M_AXI_GP1_WID(10) <= \<const0>\;
  M_AXI_GP1_WID(9) <= \<const0>\;
  M_AXI_GP1_WID(8) <= \<const0>\;
  M_AXI_GP1_WID(7) <= \<const0>\;
  M_AXI_GP1_WID(6) <= \<const0>\;
  M_AXI_GP1_WID(5) <= \<const0>\;
  M_AXI_GP1_WID(4) <= \<const0>\;
  M_AXI_GP1_WID(3) <= \<const0>\;
  M_AXI_GP1_WID(2) <= \<const0>\;
  M_AXI_GP1_WID(1) <= \<const0>\;
  M_AXI_GP1_WID(0) <= \<const0>\;
  M_AXI_GP1_WLAST <= \<const0>\;
  M_AXI_GP1_WSTRB(3) <= \<const0>\;
  M_AXI_GP1_WSTRB(2) <= \<const0>\;
  M_AXI_GP1_WSTRB(1) <= \<const0>\;
  M_AXI_GP1_WSTRB(0) <= \<const0>\;
  M_AXI_GP1_WVALID <= \<const0>\;
  PJTAG_TDO <= \<const0>\;
  SDIO0_BUSPOW <= \<const0>\;
  SDIO0_BUSVOLT(2) <= \<const0>\;
  SDIO0_BUSVOLT(1) <= \<const0>\;
  SDIO0_BUSVOLT(0) <= \<const0>\;
  SDIO0_CLK <= \<const0>\;
  SDIO0_CMD_O <= \<const0>\;
  SDIO0_CMD_T <= \<const0>\;
  SDIO0_DATA_O(3) <= \<const0>\;
  SDIO0_DATA_O(2) <= \<const0>\;
  SDIO0_DATA_O(1) <= \<const0>\;
  SDIO0_DATA_O(0) <= \<const0>\;
  SDIO0_DATA_T(3) <= \<const0>\;
  SDIO0_DATA_T(2) <= \<const0>\;
  SDIO0_DATA_T(1) <= \<const0>\;
  SDIO0_DATA_T(0) <= \<const0>\;
  SDIO0_LED <= \<const0>\;
  SDIO1_BUSPOW <= \<const0>\;
  SDIO1_BUSVOLT(2) <= \<const0>\;
  SDIO1_BUSVOLT(1) <= \<const0>\;
  SDIO1_BUSVOLT(0) <= \<const0>\;
  SDIO1_CLK <= \<const0>\;
  SDIO1_CMD_O <= \<const0>\;
  SDIO1_CMD_T <= \<const0>\;
  SDIO1_DATA_O(3) <= \<const0>\;
  SDIO1_DATA_O(2) <= \<const0>\;
  SDIO1_DATA_O(1) <= \<const0>\;
  SDIO1_DATA_O(0) <= \<const0>\;
  SDIO1_DATA_T(3) <= \<const0>\;
  SDIO1_DATA_T(2) <= \<const0>\;
  SDIO1_DATA_T(1) <= \<const0>\;
  SDIO1_DATA_T(0) <= \<const0>\;
  SDIO1_LED <= \<const0>\;
  SPI0_MISO_O <= \<const0>\;
  SPI0_MISO_T <= \<const0>\;
  SPI0_MOSI_O <= \<const0>\;
  SPI0_MOSI_T <= \<const0>\;
  SPI0_SCLK_O <= \<const0>\;
  SPI0_SCLK_T <= \<const0>\;
  SPI0_SS1_O <= \<const0>\;
  SPI0_SS2_O <= \<const0>\;
  SPI0_SS_O <= \<const0>\;
  SPI0_SS_T <= \<const0>\;
  SPI1_MISO_O <= \<const0>\;
  SPI1_MISO_T <= \<const0>\;
  SPI1_MOSI_O <= \<const0>\;
  SPI1_MOSI_T <= \<const0>\;
  SPI1_SCLK_O <= \<const0>\;
  SPI1_SCLK_T <= \<const0>\;
  SPI1_SS1_O <= \<const0>\;
  SPI1_SS2_O <= \<const0>\;
  SPI1_SS_O <= \<const0>\;
  SPI1_SS_T <= \<const0>\;
  S_AXI_ACP_ARESETN <= \<const0>\;
  S_AXI_ACP_ARREADY <= \<const0>\;
  S_AXI_ACP_AWREADY <= \<const0>\;
  S_AXI_ACP_BID(2) <= \<const0>\;
  S_AXI_ACP_BID(1) <= \<const0>\;
  S_AXI_ACP_BID(0) <= \<const0>\;
  S_AXI_ACP_BRESP(1) <= \<const0>\;
  S_AXI_ACP_BRESP(0) <= \<const0>\;
  S_AXI_ACP_BVALID <= \<const0>\;
  S_AXI_ACP_RDATA(63) <= \<const0>\;
  S_AXI_ACP_RDATA(62) <= \<const0>\;
  S_AXI_ACP_RDATA(61) <= \<const0>\;
  S_AXI_ACP_RDATA(60) <= \<const0>\;
  S_AXI_ACP_RDATA(59) <= \<const0>\;
  S_AXI_ACP_RDATA(58) <= \<const0>\;
  S_AXI_ACP_RDATA(57) <= \<const0>\;
  S_AXI_ACP_RDATA(56) <= \<const0>\;
  S_AXI_ACP_RDATA(55) <= \<const0>\;
  S_AXI_ACP_RDATA(54) <= \<const0>\;
  S_AXI_ACP_RDATA(53) <= \<const0>\;
  S_AXI_ACP_RDATA(52) <= \<const0>\;
  S_AXI_ACP_RDATA(51) <= \<const0>\;
  S_AXI_ACP_RDATA(50) <= \<const0>\;
  S_AXI_ACP_RDATA(49) <= \<const0>\;
  S_AXI_ACP_RDATA(48) <= \<const0>\;
  S_AXI_ACP_RDATA(47) <= \<const0>\;
  S_AXI_ACP_RDATA(46) <= \<const0>\;
  S_AXI_ACP_RDATA(45) <= \<const0>\;
  S_AXI_ACP_RDATA(44) <= \<const0>\;
  S_AXI_ACP_RDATA(43) <= \<const0>\;
  S_AXI_ACP_RDATA(42) <= \<const0>\;
  S_AXI_ACP_RDATA(41) <= \<const0>\;
  S_AXI_ACP_RDATA(40) <= \<const0>\;
  S_AXI_ACP_RDATA(39) <= \<const0>\;
  S_AXI_ACP_RDATA(38) <= \<const0>\;
  S_AXI_ACP_RDATA(37) <= \<const0>\;
  S_AXI_ACP_RDATA(36) <= \<const0>\;
  S_AXI_ACP_RDATA(35) <= \<const0>\;
  S_AXI_ACP_RDATA(34) <= \<const0>\;
  S_AXI_ACP_RDATA(33) <= \<const0>\;
  S_AXI_ACP_RDATA(32) <= \<const0>\;
  S_AXI_ACP_RDATA(31) <= \<const0>\;
  S_AXI_ACP_RDATA(30) <= \<const0>\;
  S_AXI_ACP_RDATA(29) <= \<const0>\;
  S_AXI_ACP_RDATA(28) <= \<const0>\;
  S_AXI_ACP_RDATA(27) <= \<const0>\;
  S_AXI_ACP_RDATA(26) <= \<const0>\;
  S_AXI_ACP_RDATA(25) <= \<const0>\;
  S_AXI_ACP_RDATA(24) <= \<const0>\;
  S_AXI_ACP_RDATA(23) <= \<const0>\;
  S_AXI_ACP_RDATA(22) <= \<const0>\;
  S_AXI_ACP_RDATA(21) <= \<const0>\;
  S_AXI_ACP_RDATA(20) <= \<const0>\;
  S_AXI_ACP_RDATA(19) <= \<const0>\;
  S_AXI_ACP_RDATA(18) <= \<const0>\;
  S_AXI_ACP_RDATA(17) <= \<const0>\;
  S_AXI_ACP_RDATA(16) <= \<const0>\;
  S_AXI_ACP_RDATA(15) <= \<const0>\;
  S_AXI_ACP_RDATA(14) <= \<const0>\;
  S_AXI_ACP_RDATA(13) <= \<const0>\;
  S_AXI_ACP_RDATA(12) <= \<const0>\;
  S_AXI_ACP_RDATA(11) <= \<const0>\;
  S_AXI_ACP_RDATA(10) <= \<const0>\;
  S_AXI_ACP_RDATA(9) <= \<const0>\;
  S_AXI_ACP_RDATA(8) <= \<const0>\;
  S_AXI_ACP_RDATA(7) <= \<const0>\;
  S_AXI_ACP_RDATA(6) <= \<const0>\;
  S_AXI_ACP_RDATA(5) <= \<const0>\;
  S_AXI_ACP_RDATA(4) <= \<const0>\;
  S_AXI_ACP_RDATA(3) <= \<const0>\;
  S_AXI_ACP_RDATA(2) <= \<const0>\;
  S_AXI_ACP_RDATA(1) <= \<const0>\;
  S_AXI_ACP_RDATA(0) <= \<const0>\;
  S_AXI_ACP_RID(2) <= \<const0>\;
  S_AXI_ACP_RID(1) <= \<const0>\;
  S_AXI_ACP_RID(0) <= \<const0>\;
  S_AXI_ACP_RLAST <= \<const0>\;
  S_AXI_ACP_RRESP(1) <= \<const0>\;
  S_AXI_ACP_RRESP(0) <= \<const0>\;
  S_AXI_ACP_RVALID <= \<const0>\;
  S_AXI_ACP_WREADY <= \<const0>\;
  S_AXI_GP0_ARESETN <= \<const0>\;
  S_AXI_GP0_ARREADY <= \<const0>\;
  S_AXI_GP0_AWREADY <= \<const0>\;
  S_AXI_GP0_BID(5) <= \<const0>\;
  S_AXI_GP0_BID(4) <= \<const0>\;
  S_AXI_GP0_BID(3) <= \<const0>\;
  S_AXI_GP0_BID(2) <= \<const0>\;
  S_AXI_GP0_BID(1) <= \<const0>\;
  S_AXI_GP0_BID(0) <= \<const0>\;
  S_AXI_GP0_BRESP(1) <= \<const0>\;
  S_AXI_GP0_BRESP(0) <= \<const0>\;
  S_AXI_GP0_BVALID <= \<const0>\;
  S_AXI_GP0_RDATA(31) <= \<const0>\;
  S_AXI_GP0_RDATA(30) <= \<const0>\;
  S_AXI_GP0_RDATA(29) <= \<const0>\;
  S_AXI_GP0_RDATA(28) <= \<const0>\;
  S_AXI_GP0_RDATA(27) <= \<const0>\;
  S_AXI_GP0_RDATA(26) <= \<const0>\;
  S_AXI_GP0_RDATA(25) <= \<const0>\;
  S_AXI_GP0_RDATA(24) <= \<const0>\;
  S_AXI_GP0_RDATA(23) <= \<const0>\;
  S_AXI_GP0_RDATA(22) <= \<const0>\;
  S_AXI_GP0_RDATA(21) <= \<const0>\;
  S_AXI_GP0_RDATA(20) <= \<const0>\;
  S_AXI_GP0_RDATA(19) <= \<const0>\;
  S_AXI_GP0_RDATA(18) <= \<const0>\;
  S_AXI_GP0_RDATA(17) <= \<const0>\;
  S_AXI_GP0_RDATA(16) <= \<const0>\;
  S_AXI_GP0_RDATA(15) <= \<const0>\;
  S_AXI_GP0_RDATA(14) <= \<const0>\;
  S_AXI_GP0_RDATA(13) <= \<const0>\;
  S_AXI_GP0_RDATA(12) <= \<const0>\;
  S_AXI_GP0_RDATA(11) <= \<const0>\;
  S_AXI_GP0_RDATA(10) <= \<const0>\;
  S_AXI_GP0_RDATA(9) <= \<const0>\;
  S_AXI_GP0_RDATA(8) <= \<const0>\;
  S_AXI_GP0_RDATA(7) <= \<const0>\;
  S_AXI_GP0_RDATA(6) <= \<const0>\;
  S_AXI_GP0_RDATA(5) <= \<const0>\;
  S_AXI_GP0_RDATA(4) <= \<const0>\;
  S_AXI_GP0_RDATA(3) <= \<const0>\;
  S_AXI_GP0_RDATA(2) <= \<const0>\;
  S_AXI_GP0_RDATA(1) <= \<const0>\;
  S_AXI_GP0_RDATA(0) <= \<const0>\;
  S_AXI_GP0_RID(5) <= \<const0>\;
  S_AXI_GP0_RID(4) <= \<const0>\;
  S_AXI_GP0_RID(3) <= \<const0>\;
  S_AXI_GP0_RID(2) <= \<const0>\;
  S_AXI_GP0_RID(1) <= \<const0>\;
  S_AXI_GP0_RID(0) <= \<const0>\;
  S_AXI_GP0_RLAST <= \<const0>\;
  S_AXI_GP0_RRESP(1) <= \<const0>\;
  S_AXI_GP0_RRESP(0) <= \<const0>\;
  S_AXI_GP0_RVALID <= \<const0>\;
  S_AXI_GP0_WREADY <= \<const0>\;
  S_AXI_GP1_ARESETN <= \<const0>\;
  S_AXI_GP1_ARREADY <= \<const0>\;
  S_AXI_GP1_AWREADY <= \<const0>\;
  S_AXI_GP1_BID(5) <= \<const0>\;
  S_AXI_GP1_BID(4) <= \<const0>\;
  S_AXI_GP1_BID(3) <= \<const0>\;
  S_AXI_GP1_BID(2) <= \<const0>\;
  S_AXI_GP1_BID(1) <= \<const0>\;
  S_AXI_GP1_BID(0) <= \<const0>\;
  S_AXI_GP1_BRESP(1) <= \<const0>\;
  S_AXI_GP1_BRESP(0) <= \<const0>\;
  S_AXI_GP1_BVALID <= \<const0>\;
  S_AXI_GP1_RDATA(31) <= \<const0>\;
  S_AXI_GP1_RDATA(30) <= \<const0>\;
  S_AXI_GP1_RDATA(29) <= \<const0>\;
  S_AXI_GP1_RDATA(28) <= \<const0>\;
  S_AXI_GP1_RDATA(27) <= \<const0>\;
  S_AXI_GP1_RDATA(26) <= \<const0>\;
  S_AXI_GP1_RDATA(25) <= \<const0>\;
  S_AXI_GP1_RDATA(24) <= \<const0>\;
  S_AXI_GP1_RDATA(23) <= \<const0>\;
  S_AXI_GP1_RDATA(22) <= \<const0>\;
  S_AXI_GP1_RDATA(21) <= \<const0>\;
  S_AXI_GP1_RDATA(20) <= \<const0>\;
  S_AXI_GP1_RDATA(19) <= \<const0>\;
  S_AXI_GP1_RDATA(18) <= \<const0>\;
  S_AXI_GP1_RDATA(17) <= \<const0>\;
  S_AXI_GP1_RDATA(16) <= \<const0>\;
  S_AXI_GP1_RDATA(15) <= \<const0>\;
  S_AXI_GP1_RDATA(14) <= \<const0>\;
  S_AXI_GP1_RDATA(13) <= \<const0>\;
  S_AXI_GP1_RDATA(12) <= \<const0>\;
  S_AXI_GP1_RDATA(11) <= \<const0>\;
  S_AXI_GP1_RDATA(10) <= \<const0>\;
  S_AXI_GP1_RDATA(9) <= \<const0>\;
  S_AXI_GP1_RDATA(8) <= \<const0>\;
  S_AXI_GP1_RDATA(7) <= \<const0>\;
  S_AXI_GP1_RDATA(6) <= \<const0>\;
  S_AXI_GP1_RDATA(5) <= \<const0>\;
  S_AXI_GP1_RDATA(4) <= \<const0>\;
  S_AXI_GP1_RDATA(3) <= \<const0>\;
  S_AXI_GP1_RDATA(2) <= \<const0>\;
  S_AXI_GP1_RDATA(1) <= \<const0>\;
  S_AXI_GP1_RDATA(0) <= \<const0>\;
  S_AXI_GP1_RID(5) <= \<const0>\;
  S_AXI_GP1_RID(4) <= \<const0>\;
  S_AXI_GP1_RID(3) <= \<const0>\;
  S_AXI_GP1_RID(2) <= \<const0>\;
  S_AXI_GP1_RID(1) <= \<const0>\;
  S_AXI_GP1_RID(0) <= \<const0>\;
  S_AXI_GP1_RLAST <= \<const0>\;
  S_AXI_GP1_RRESP(1) <= \<const0>\;
  S_AXI_GP1_RRESP(0) <= \<const0>\;
  S_AXI_GP1_RVALID <= \<const0>\;
  S_AXI_GP1_WREADY <= \<const0>\;
  S_AXI_HP0_ARESETN <= \<const0>\;
  S_AXI_HP1_ARESETN <= \<const0>\;
  S_AXI_HP1_ARREADY <= \<const0>\;
  S_AXI_HP1_AWREADY <= \<const0>\;
  S_AXI_HP1_BID(5) <= \<const0>\;
  S_AXI_HP1_BID(4) <= \<const0>\;
  S_AXI_HP1_BID(3) <= \<const0>\;
  S_AXI_HP1_BID(2) <= \<const0>\;
  S_AXI_HP1_BID(1) <= \<const0>\;
  S_AXI_HP1_BID(0) <= \<const0>\;
  S_AXI_HP1_BRESP(1) <= \<const0>\;
  S_AXI_HP1_BRESP(0) <= \<const0>\;
  S_AXI_HP1_BVALID <= \<const0>\;
  S_AXI_HP1_RACOUNT(2) <= \<const0>\;
  S_AXI_HP1_RACOUNT(1) <= \<const0>\;
  S_AXI_HP1_RACOUNT(0) <= \<const0>\;
  S_AXI_HP1_RCOUNT(7) <= \<const0>\;
  S_AXI_HP1_RCOUNT(6) <= \<const0>\;
  S_AXI_HP1_RCOUNT(5) <= \<const0>\;
  S_AXI_HP1_RCOUNT(4) <= \<const0>\;
  S_AXI_HP1_RCOUNT(3) <= \<const0>\;
  S_AXI_HP1_RCOUNT(2) <= \<const0>\;
  S_AXI_HP1_RCOUNT(1) <= \<const0>\;
  S_AXI_HP1_RCOUNT(0) <= \<const0>\;
  S_AXI_HP1_RDATA(63) <= \<const0>\;
  S_AXI_HP1_RDATA(62) <= \<const0>\;
  S_AXI_HP1_RDATA(61) <= \<const0>\;
  S_AXI_HP1_RDATA(60) <= \<const0>\;
  S_AXI_HP1_RDATA(59) <= \<const0>\;
  S_AXI_HP1_RDATA(58) <= \<const0>\;
  S_AXI_HP1_RDATA(57) <= \<const0>\;
  S_AXI_HP1_RDATA(56) <= \<const0>\;
  S_AXI_HP1_RDATA(55) <= \<const0>\;
  S_AXI_HP1_RDATA(54) <= \<const0>\;
  S_AXI_HP1_RDATA(53) <= \<const0>\;
  S_AXI_HP1_RDATA(52) <= \<const0>\;
  S_AXI_HP1_RDATA(51) <= \<const0>\;
  S_AXI_HP1_RDATA(50) <= \<const0>\;
  S_AXI_HP1_RDATA(49) <= \<const0>\;
  S_AXI_HP1_RDATA(48) <= \<const0>\;
  S_AXI_HP1_RDATA(47) <= \<const0>\;
  S_AXI_HP1_RDATA(46) <= \<const0>\;
  S_AXI_HP1_RDATA(45) <= \<const0>\;
  S_AXI_HP1_RDATA(44) <= \<const0>\;
  S_AXI_HP1_RDATA(43) <= \<const0>\;
  S_AXI_HP1_RDATA(42) <= \<const0>\;
  S_AXI_HP1_RDATA(41) <= \<const0>\;
  S_AXI_HP1_RDATA(40) <= \<const0>\;
  S_AXI_HP1_RDATA(39) <= \<const0>\;
  S_AXI_HP1_RDATA(38) <= \<const0>\;
  S_AXI_HP1_RDATA(37) <= \<const0>\;
  S_AXI_HP1_RDATA(36) <= \<const0>\;
  S_AXI_HP1_RDATA(35) <= \<const0>\;
  S_AXI_HP1_RDATA(34) <= \<const0>\;
  S_AXI_HP1_RDATA(33) <= \<const0>\;
  S_AXI_HP1_RDATA(32) <= \<const0>\;
  S_AXI_HP1_RDATA(31) <= \<const0>\;
  S_AXI_HP1_RDATA(30) <= \<const0>\;
  S_AXI_HP1_RDATA(29) <= \<const0>\;
  S_AXI_HP1_RDATA(28) <= \<const0>\;
  S_AXI_HP1_RDATA(27) <= \<const0>\;
  S_AXI_HP1_RDATA(26) <= \<const0>\;
  S_AXI_HP1_RDATA(25) <= \<const0>\;
  S_AXI_HP1_RDATA(24) <= \<const0>\;
  S_AXI_HP1_RDATA(23) <= \<const0>\;
  S_AXI_HP1_RDATA(22) <= \<const0>\;
  S_AXI_HP1_RDATA(21) <= \<const0>\;
  S_AXI_HP1_RDATA(20) <= \<const0>\;
  S_AXI_HP1_RDATA(19) <= \<const0>\;
  S_AXI_HP1_RDATA(18) <= \<const0>\;
  S_AXI_HP1_RDATA(17) <= \<const0>\;
  S_AXI_HP1_RDATA(16) <= \<const0>\;
  S_AXI_HP1_RDATA(15) <= \<const0>\;
  S_AXI_HP1_RDATA(14) <= \<const0>\;
  S_AXI_HP1_RDATA(13) <= \<const0>\;
  S_AXI_HP1_RDATA(12) <= \<const0>\;
  S_AXI_HP1_RDATA(11) <= \<const0>\;
  S_AXI_HP1_RDATA(10) <= \<const0>\;
  S_AXI_HP1_RDATA(9) <= \<const0>\;
  S_AXI_HP1_RDATA(8) <= \<const0>\;
  S_AXI_HP1_RDATA(7) <= \<const0>\;
  S_AXI_HP1_RDATA(6) <= \<const0>\;
  S_AXI_HP1_RDATA(5) <= \<const0>\;
  S_AXI_HP1_RDATA(4) <= \<const0>\;
  S_AXI_HP1_RDATA(3) <= \<const0>\;
  S_AXI_HP1_RDATA(2) <= \<const0>\;
  S_AXI_HP1_RDATA(1) <= \<const0>\;
  S_AXI_HP1_RDATA(0) <= \<const0>\;
  S_AXI_HP1_RID(5) <= \<const0>\;
  S_AXI_HP1_RID(4) <= \<const0>\;
  S_AXI_HP1_RID(3) <= \<const0>\;
  S_AXI_HP1_RID(2) <= \<const0>\;
  S_AXI_HP1_RID(1) <= \<const0>\;
  S_AXI_HP1_RID(0) <= \<const0>\;
  S_AXI_HP1_RLAST <= \<const0>\;
  S_AXI_HP1_RRESP(1) <= \<const0>\;
  S_AXI_HP1_RRESP(0) <= \<const0>\;
  S_AXI_HP1_RVALID <= \<const0>\;
  S_AXI_HP1_WACOUNT(5) <= \<const0>\;
  S_AXI_HP1_WACOUNT(4) <= \<const0>\;
  S_AXI_HP1_WACOUNT(3) <= \<const0>\;
  S_AXI_HP1_WACOUNT(2) <= \<const0>\;
  S_AXI_HP1_WACOUNT(1) <= \<const0>\;
  S_AXI_HP1_WACOUNT(0) <= \<const0>\;
  S_AXI_HP1_WCOUNT(7) <= \<const0>\;
  S_AXI_HP1_WCOUNT(6) <= \<const0>\;
  S_AXI_HP1_WCOUNT(5) <= \<const0>\;
  S_AXI_HP1_WCOUNT(4) <= \<const0>\;
  S_AXI_HP1_WCOUNT(3) <= \<const0>\;
  S_AXI_HP1_WCOUNT(2) <= \<const0>\;
  S_AXI_HP1_WCOUNT(1) <= \<const0>\;
  S_AXI_HP1_WCOUNT(0) <= \<const0>\;
  S_AXI_HP1_WREADY <= \<const0>\;
  S_AXI_HP2_ARESETN <= \<const0>\;
  S_AXI_HP2_ARREADY <= \<const0>\;
  S_AXI_HP2_AWREADY <= \<const0>\;
  S_AXI_HP2_BID(5) <= \<const0>\;
  S_AXI_HP2_BID(4) <= \<const0>\;
  S_AXI_HP2_BID(3) <= \<const0>\;
  S_AXI_HP2_BID(2) <= \<const0>\;
  S_AXI_HP2_BID(1) <= \<const0>\;
  S_AXI_HP2_BID(0) <= \<const0>\;
  S_AXI_HP2_BRESP(1) <= \<const0>\;
  S_AXI_HP2_BRESP(0) <= \<const0>\;
  S_AXI_HP2_BVALID <= \<const0>\;
  S_AXI_HP2_RACOUNT(2) <= \<const0>\;
  S_AXI_HP2_RACOUNT(1) <= \<const0>\;
  S_AXI_HP2_RACOUNT(0) <= \<const0>\;
  S_AXI_HP2_RCOUNT(7) <= \<const0>\;
  S_AXI_HP2_RCOUNT(6) <= \<const0>\;
  S_AXI_HP2_RCOUNT(5) <= \<const0>\;
  S_AXI_HP2_RCOUNT(4) <= \<const0>\;
  S_AXI_HP2_RCOUNT(3) <= \<const0>\;
  S_AXI_HP2_RCOUNT(2) <= \<const0>\;
  S_AXI_HP2_RCOUNT(1) <= \<const0>\;
  S_AXI_HP2_RCOUNT(0) <= \<const0>\;
  S_AXI_HP2_RDATA(63) <= \<const0>\;
  S_AXI_HP2_RDATA(62) <= \<const0>\;
  S_AXI_HP2_RDATA(61) <= \<const0>\;
  S_AXI_HP2_RDATA(60) <= \<const0>\;
  S_AXI_HP2_RDATA(59) <= \<const0>\;
  S_AXI_HP2_RDATA(58) <= \<const0>\;
  S_AXI_HP2_RDATA(57) <= \<const0>\;
  S_AXI_HP2_RDATA(56) <= \<const0>\;
  S_AXI_HP2_RDATA(55) <= \<const0>\;
  S_AXI_HP2_RDATA(54) <= \<const0>\;
  S_AXI_HP2_RDATA(53) <= \<const0>\;
  S_AXI_HP2_RDATA(52) <= \<const0>\;
  S_AXI_HP2_RDATA(51) <= \<const0>\;
  S_AXI_HP2_RDATA(50) <= \<const0>\;
  S_AXI_HP2_RDATA(49) <= \<const0>\;
  S_AXI_HP2_RDATA(48) <= \<const0>\;
  S_AXI_HP2_RDATA(47) <= \<const0>\;
  S_AXI_HP2_RDATA(46) <= \<const0>\;
  S_AXI_HP2_RDATA(45) <= \<const0>\;
  S_AXI_HP2_RDATA(44) <= \<const0>\;
  S_AXI_HP2_RDATA(43) <= \<const0>\;
  S_AXI_HP2_RDATA(42) <= \<const0>\;
  S_AXI_HP2_RDATA(41) <= \<const0>\;
  S_AXI_HP2_RDATA(40) <= \<const0>\;
  S_AXI_HP2_RDATA(39) <= \<const0>\;
  S_AXI_HP2_RDATA(38) <= \<const0>\;
  S_AXI_HP2_RDATA(37) <= \<const0>\;
  S_AXI_HP2_RDATA(36) <= \<const0>\;
  S_AXI_HP2_RDATA(35) <= \<const0>\;
  S_AXI_HP2_RDATA(34) <= \<const0>\;
  S_AXI_HP2_RDATA(33) <= \<const0>\;
  S_AXI_HP2_RDATA(32) <= \<const0>\;
  S_AXI_HP2_RDATA(31) <= \<const0>\;
  S_AXI_HP2_RDATA(30) <= \<const0>\;
  S_AXI_HP2_RDATA(29) <= \<const0>\;
  S_AXI_HP2_RDATA(28) <= \<const0>\;
  S_AXI_HP2_RDATA(27) <= \<const0>\;
  S_AXI_HP2_RDATA(26) <= \<const0>\;
  S_AXI_HP2_RDATA(25) <= \<const0>\;
  S_AXI_HP2_RDATA(24) <= \<const0>\;
  S_AXI_HP2_RDATA(23) <= \<const0>\;
  S_AXI_HP2_RDATA(22) <= \<const0>\;
  S_AXI_HP2_RDATA(21) <= \<const0>\;
  S_AXI_HP2_RDATA(20) <= \<const0>\;
  S_AXI_HP2_RDATA(19) <= \<const0>\;
  S_AXI_HP2_RDATA(18) <= \<const0>\;
  S_AXI_HP2_RDATA(17) <= \<const0>\;
  S_AXI_HP2_RDATA(16) <= \<const0>\;
  S_AXI_HP2_RDATA(15) <= \<const0>\;
  S_AXI_HP2_RDATA(14) <= \<const0>\;
  S_AXI_HP2_RDATA(13) <= \<const0>\;
  S_AXI_HP2_RDATA(12) <= \<const0>\;
  S_AXI_HP2_RDATA(11) <= \<const0>\;
  S_AXI_HP2_RDATA(10) <= \<const0>\;
  S_AXI_HP2_RDATA(9) <= \<const0>\;
  S_AXI_HP2_RDATA(8) <= \<const0>\;
  S_AXI_HP2_RDATA(7) <= \<const0>\;
  S_AXI_HP2_RDATA(6) <= \<const0>\;
  S_AXI_HP2_RDATA(5) <= \<const0>\;
  S_AXI_HP2_RDATA(4) <= \<const0>\;
  S_AXI_HP2_RDATA(3) <= \<const0>\;
  S_AXI_HP2_RDATA(2) <= \<const0>\;
  S_AXI_HP2_RDATA(1) <= \<const0>\;
  S_AXI_HP2_RDATA(0) <= \<const0>\;
  S_AXI_HP2_RID(5) <= \<const0>\;
  S_AXI_HP2_RID(4) <= \<const0>\;
  S_AXI_HP2_RID(3) <= \<const0>\;
  S_AXI_HP2_RID(2) <= \<const0>\;
  S_AXI_HP2_RID(1) <= \<const0>\;
  S_AXI_HP2_RID(0) <= \<const0>\;
  S_AXI_HP2_RLAST <= \<const0>\;
  S_AXI_HP2_RRESP(1) <= \<const0>\;
  S_AXI_HP2_RRESP(0) <= \<const0>\;
  S_AXI_HP2_RVALID <= \<const0>\;
  S_AXI_HP2_WACOUNT(5) <= \<const0>\;
  S_AXI_HP2_WACOUNT(4) <= \<const0>\;
  S_AXI_HP2_WACOUNT(3) <= \<const0>\;
  S_AXI_HP2_WACOUNT(2) <= \<const0>\;
  S_AXI_HP2_WACOUNT(1) <= \<const0>\;
  S_AXI_HP2_WACOUNT(0) <= \<const0>\;
  S_AXI_HP2_WCOUNT(7) <= \<const0>\;
  S_AXI_HP2_WCOUNT(6) <= \<const0>\;
  S_AXI_HP2_WCOUNT(5) <= \<const0>\;
  S_AXI_HP2_WCOUNT(4) <= \<const0>\;
  S_AXI_HP2_WCOUNT(3) <= \<const0>\;
  S_AXI_HP2_WCOUNT(2) <= \<const0>\;
  S_AXI_HP2_WCOUNT(1) <= \<const0>\;
  S_AXI_HP2_WCOUNT(0) <= \<const0>\;
  S_AXI_HP2_WREADY <= \<const0>\;
  S_AXI_HP3_ARESETN <= \<const0>\;
  S_AXI_HP3_ARREADY <= \<const0>\;
  S_AXI_HP3_AWREADY <= \<const0>\;
  S_AXI_HP3_BID(5) <= \<const0>\;
  S_AXI_HP3_BID(4) <= \<const0>\;
  S_AXI_HP3_BID(3) <= \<const0>\;
  S_AXI_HP3_BID(2) <= \<const0>\;
  S_AXI_HP3_BID(1) <= \<const0>\;
  S_AXI_HP3_BID(0) <= \<const0>\;
  S_AXI_HP3_BRESP(1) <= \<const0>\;
  S_AXI_HP3_BRESP(0) <= \<const0>\;
  S_AXI_HP3_BVALID <= \<const0>\;
  S_AXI_HP3_RACOUNT(2) <= \<const0>\;
  S_AXI_HP3_RACOUNT(1) <= \<const0>\;
  S_AXI_HP3_RACOUNT(0) <= \<const0>\;
  S_AXI_HP3_RCOUNT(7) <= \<const0>\;
  S_AXI_HP3_RCOUNT(6) <= \<const0>\;
  S_AXI_HP3_RCOUNT(5) <= \<const0>\;
  S_AXI_HP3_RCOUNT(4) <= \<const0>\;
  S_AXI_HP3_RCOUNT(3) <= \<const0>\;
  S_AXI_HP3_RCOUNT(2) <= \<const0>\;
  S_AXI_HP3_RCOUNT(1) <= \<const0>\;
  S_AXI_HP3_RCOUNT(0) <= \<const0>\;
  S_AXI_HP3_RDATA(63) <= \<const0>\;
  S_AXI_HP3_RDATA(62) <= \<const0>\;
  S_AXI_HP3_RDATA(61) <= \<const0>\;
  S_AXI_HP3_RDATA(60) <= \<const0>\;
  S_AXI_HP3_RDATA(59) <= \<const0>\;
  S_AXI_HP3_RDATA(58) <= \<const0>\;
  S_AXI_HP3_RDATA(57) <= \<const0>\;
  S_AXI_HP3_RDATA(56) <= \<const0>\;
  S_AXI_HP3_RDATA(55) <= \<const0>\;
  S_AXI_HP3_RDATA(54) <= \<const0>\;
  S_AXI_HP3_RDATA(53) <= \<const0>\;
  S_AXI_HP3_RDATA(52) <= \<const0>\;
  S_AXI_HP3_RDATA(51) <= \<const0>\;
  S_AXI_HP3_RDATA(50) <= \<const0>\;
  S_AXI_HP3_RDATA(49) <= \<const0>\;
  S_AXI_HP3_RDATA(48) <= \<const0>\;
  S_AXI_HP3_RDATA(47) <= \<const0>\;
  S_AXI_HP3_RDATA(46) <= \<const0>\;
  S_AXI_HP3_RDATA(45) <= \<const0>\;
  S_AXI_HP3_RDATA(44) <= \<const0>\;
  S_AXI_HP3_RDATA(43) <= \<const0>\;
  S_AXI_HP3_RDATA(42) <= \<const0>\;
  S_AXI_HP3_RDATA(41) <= \<const0>\;
  S_AXI_HP3_RDATA(40) <= \<const0>\;
  S_AXI_HP3_RDATA(39) <= \<const0>\;
  S_AXI_HP3_RDATA(38) <= \<const0>\;
  S_AXI_HP3_RDATA(37) <= \<const0>\;
  S_AXI_HP3_RDATA(36) <= \<const0>\;
  S_AXI_HP3_RDATA(35) <= \<const0>\;
  S_AXI_HP3_RDATA(34) <= \<const0>\;
  S_AXI_HP3_RDATA(33) <= \<const0>\;
  S_AXI_HP3_RDATA(32) <= \<const0>\;
  S_AXI_HP3_RDATA(31) <= \<const0>\;
  S_AXI_HP3_RDATA(30) <= \<const0>\;
  S_AXI_HP3_RDATA(29) <= \<const0>\;
  S_AXI_HP3_RDATA(28) <= \<const0>\;
  S_AXI_HP3_RDATA(27) <= \<const0>\;
  S_AXI_HP3_RDATA(26) <= \<const0>\;
  S_AXI_HP3_RDATA(25) <= \<const0>\;
  S_AXI_HP3_RDATA(24) <= \<const0>\;
  S_AXI_HP3_RDATA(23) <= \<const0>\;
  S_AXI_HP3_RDATA(22) <= \<const0>\;
  S_AXI_HP3_RDATA(21) <= \<const0>\;
  S_AXI_HP3_RDATA(20) <= \<const0>\;
  S_AXI_HP3_RDATA(19) <= \<const0>\;
  S_AXI_HP3_RDATA(18) <= \<const0>\;
  S_AXI_HP3_RDATA(17) <= \<const0>\;
  S_AXI_HP3_RDATA(16) <= \<const0>\;
  S_AXI_HP3_RDATA(15) <= \<const0>\;
  S_AXI_HP3_RDATA(14) <= \<const0>\;
  S_AXI_HP3_RDATA(13) <= \<const0>\;
  S_AXI_HP3_RDATA(12) <= \<const0>\;
  S_AXI_HP3_RDATA(11) <= \<const0>\;
  S_AXI_HP3_RDATA(10) <= \<const0>\;
  S_AXI_HP3_RDATA(9) <= \<const0>\;
  S_AXI_HP3_RDATA(8) <= \<const0>\;
  S_AXI_HP3_RDATA(7) <= \<const0>\;
  S_AXI_HP3_RDATA(6) <= \<const0>\;
  S_AXI_HP3_RDATA(5) <= \<const0>\;
  S_AXI_HP3_RDATA(4) <= \<const0>\;
  S_AXI_HP3_RDATA(3) <= \<const0>\;
  S_AXI_HP3_RDATA(2) <= \<const0>\;
  S_AXI_HP3_RDATA(1) <= \<const0>\;
  S_AXI_HP3_RDATA(0) <= \<const0>\;
  S_AXI_HP3_RID(5) <= \<const0>\;
  S_AXI_HP3_RID(4) <= \<const0>\;
  S_AXI_HP3_RID(3) <= \<const0>\;
  S_AXI_HP3_RID(2) <= \<const0>\;
  S_AXI_HP3_RID(1) <= \<const0>\;
  S_AXI_HP3_RID(0) <= \<const0>\;
  S_AXI_HP3_RLAST <= \<const0>\;
  S_AXI_HP3_RRESP(1) <= \<const0>\;
  S_AXI_HP3_RRESP(0) <= \<const0>\;
  S_AXI_HP3_RVALID <= \<const0>\;
  S_AXI_HP3_WACOUNT(5) <= \<const0>\;
  S_AXI_HP3_WACOUNT(4) <= \<const0>\;
  S_AXI_HP3_WACOUNT(3) <= \<const0>\;
  S_AXI_HP3_WACOUNT(2) <= \<const0>\;
  S_AXI_HP3_WACOUNT(1) <= \<const0>\;
  S_AXI_HP3_WACOUNT(0) <= \<const0>\;
  S_AXI_HP3_WCOUNT(7) <= \<const0>\;
  S_AXI_HP3_WCOUNT(6) <= \<const0>\;
  S_AXI_HP3_WCOUNT(5) <= \<const0>\;
  S_AXI_HP3_WCOUNT(4) <= \<const0>\;
  S_AXI_HP3_WCOUNT(3) <= \<const0>\;
  S_AXI_HP3_WCOUNT(2) <= \<const0>\;
  S_AXI_HP3_WCOUNT(1) <= \<const0>\;
  S_AXI_HP3_WCOUNT(0) <= \<const0>\;
  S_AXI_HP3_WREADY <= \<const0>\;
  TRACE_CLK_OUT <= \<const0>\;
  TRACE_CTL <= \TRACE_CTL_PIPE[0]\;
  TRACE_DATA(1 downto 0) <= \TRACE_DATA_PIPE[0]\(1 downto 0);
  TTC0_WAVE0_OUT <= \<const0>\;
  TTC0_WAVE1_OUT <= \<const0>\;
  TTC0_WAVE2_OUT <= \<const0>\;
  TTC1_WAVE0_OUT <= \<const0>\;
  TTC1_WAVE1_OUT <= \<const0>\;
  TTC1_WAVE2_OUT <= \<const0>\;
  UART0_DTRN <= \<const0>\;
  UART0_RTSN <= \<const0>\;
  UART0_TX <= \<const0>\;
  UART1_DTRN <= \<const0>\;
  UART1_RTSN <= \<const0>\;
  UART1_TX <= \<const0>\;
  USB0_PORT_INDCTL(1) <= \<const0>\;
  USB0_PORT_INDCTL(0) <= \<const0>\;
  USB0_VBUS_PWRSELECT <= \<const0>\;
  USB1_PORT_INDCTL(1) <= \<const0>\;
  USB1_PORT_INDCTL(0) <= \<const0>\;
  USB1_VBUS_PWRSELECT <= \<const0>\;
  WDT_RST_OUT <= \<const0>\;
DDR_CAS_n_BIBUF: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_DDR_CAS_n,
      PAD => DDR_CAS_n
    );
DDR_CKE_BIBUF: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_DDR_CKE,
      PAD => DDR_CKE
    );
DDR_CS_n_BIBUF: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_DDR_CS_n,
      PAD => DDR_CS_n
    );
DDR_Clk_BIBUF: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_DDR_Clk,
      PAD => DDR_Clk
    );
DDR_Clk_n_BIBUF: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_DDR_Clk_n,
      PAD => DDR_Clk_n
    );
DDR_DRSTB_BIBUF: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_DDR_DRSTB,
      PAD => DDR_DRSTB
    );
DDR_ODT_BIBUF: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_DDR_ODT,
      PAD => DDR_ODT
    );
DDR_RAS_n_BIBUF: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_DDR_RAS_n,
      PAD => DDR_RAS_n
    );
DDR_VRN_BIBUF: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_DDR_VRN,
      PAD => DDR_VRN
    );
DDR_VRP_BIBUF: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_DDR_VRP,
      PAD => DDR_VRP
    );
DDR_WEB_BIBUF: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_DDR_WEB,
      PAD => DDR_WEB
    );
GND: unisim.vcomponents.GND
     port map (
      G => \<const0>\
    );
PS7_i: unisim.vcomponents.PS7
     port map (
      DDRA(14 downto 0) => buffered_DDR_Addr(14 downto 0),
      DDRARB(3 downto 0) => B"0000",
      DDRBA(2 downto 0) => buffered_DDR_BankAddr(2 downto 0),
      DDRCASB => buffered_DDR_CAS_n,
      DDRCKE => buffered_DDR_CKE,
      DDRCKN => buffered_DDR_Clk_n,
      DDRCKP => buffered_DDR_Clk,
      DDRCSB => buffered_DDR_CS_n,
      DDRDM(3 downto 0) => buffered_DDR_DM(3 downto 0),
      DDRDQ(31 downto 0) => buffered_DDR_DQ(31 downto 0),
      DDRDQSN(3 downto 0) => buffered_DDR_DQS_n(3 downto 0),
      DDRDQSP(3 downto 0) => buffered_DDR_DQS(3 downto 0),
      DDRDRSTB => buffered_DDR_DRSTB,
      DDRODT => buffered_DDR_ODT,
      DDRRASB => buffered_DDR_RAS_n,
      DDRVRN => buffered_DDR_VRN,
      DDRVRP => buffered_DDR_VRP,
      DDRWEB => buffered_DDR_WEB,
      DMA0ACLK => '0',
      DMA0DAREADY => '0',
      DMA0DATYPE(1) => PS7_i_n_224,
      DMA0DATYPE(0) => PS7_i_n_225,
      DMA0DAVALID => PS7_i_n_0,
      DMA0DRLAST => '0',
      DMA0DRREADY => PS7_i_n_1,
      DMA0DRTYPE(1 downto 0) => B"00",
      DMA0DRVALID => '0',
      DMA0RSTN => PS7_i_n_2,
      DMA1ACLK => '0',
      DMA1DAREADY => '0',
      DMA1DATYPE(1) => PS7_i_n_226,
      DMA1DATYPE(0) => PS7_i_n_227,
      DMA1DAVALID => PS7_i_n_3,
      DMA1DRLAST => '0',
      DMA1DRREADY => PS7_i_n_4,
      DMA1DRTYPE(1 downto 0) => B"00",
      DMA1DRVALID => '0',
      DMA1RSTN => PS7_i_n_5,
      DMA2ACLK => '0',
      DMA2DAREADY => '0',
      DMA2DATYPE(1) => PS7_i_n_228,
      DMA2DATYPE(0) => PS7_i_n_229,
      DMA2DAVALID => PS7_i_n_6,
      DMA2DRLAST => '0',
      DMA2DRREADY => PS7_i_n_7,
      DMA2DRTYPE(1 downto 0) => B"00",
      DMA2DRVALID => '0',
      DMA2RSTN => PS7_i_n_8,
      DMA3ACLK => '0',
      DMA3DAREADY => '0',
      DMA3DATYPE(1) => PS7_i_n_230,
      DMA3DATYPE(0) => PS7_i_n_231,
      DMA3DAVALID => PS7_i_n_9,
      DMA3DRLAST => '0',
      DMA3DRREADY => PS7_i_n_10,
      DMA3DRTYPE(1 downto 0) => B"00",
      DMA3DRVALID => '0',
      DMA3RSTN => PS7_i_n_11,
      EMIOCAN0PHYRX => '0',
      EMIOCAN0PHYTX => PS7_i_n_12,
      EMIOCAN1PHYRX => '0',
      EMIOCAN1PHYTX => PS7_i_n_13,
      EMIOENET0EXTINTIN => '0',
      EMIOENET0GMIICOL => '0',
      EMIOENET0GMIICRS => '0',
      EMIOENET0GMIIRXCLK => '0',
      EMIOENET0GMIIRXD(7 downto 0) => B"00000000",
      EMIOENET0GMIIRXDV => '0',
      EMIOENET0GMIIRXER => '0',
      EMIOENET0GMIITXCLK => '0',
      EMIOENET0GMIITXD(7 downto 0) => NLW_PS7_i_EMIOENET0GMIITXD_UNCONNECTED(7 downto 0),
      EMIOENET0GMIITXEN => NLW_PS7_i_EMIOENET0GMIITXEN_UNCONNECTED,
      EMIOENET0GMIITXER => NLW_PS7_i_EMIOENET0GMIITXER_UNCONNECTED,
      EMIOENET0MDIOI => '0',
      EMIOENET0MDIOMDC => PS7_i_n_16,
      EMIOENET0MDIOO => PS7_i_n_17,
      EMIOENET0MDIOTN => ENET0_MDIO_T_n,
      EMIOENET0PTPDELAYREQRX => PS7_i_n_19,
      EMIOENET0PTPDELAYREQTX => PS7_i_n_20,
      EMIOENET0PTPPDELAYREQRX => PS7_i_n_21,
      EMIOENET0PTPPDELAYREQTX => PS7_i_n_22,
      EMIOENET0PTPPDELAYRESPRX => PS7_i_n_23,
      EMIOENET0PTPPDELAYRESPTX => PS7_i_n_24,
      EMIOENET0PTPSYNCFRAMERX => PS7_i_n_25,
      EMIOENET0PTPSYNCFRAMETX => PS7_i_n_26,
      EMIOENET0SOFRX => PS7_i_n_27,
      EMIOENET0SOFTX => PS7_i_n_28,
      EMIOENET1EXTINTIN => '0',
      EMIOENET1GMIICOL => '0',
      EMIOENET1GMIICRS => '0',
      EMIOENET1GMIIRXCLK => '0',
      EMIOENET1GMIIRXD(7 downto 0) => B"00000000",
      EMIOENET1GMIIRXDV => '0',
      EMIOENET1GMIIRXER => '0',
      EMIOENET1GMIITXCLK => '0',
      EMIOENET1GMIITXD(7 downto 0) => NLW_PS7_i_EMIOENET1GMIITXD_UNCONNECTED(7 downto 0),
      EMIOENET1GMIITXEN => NLW_PS7_i_EMIOENET1GMIITXEN_UNCONNECTED,
      EMIOENET1GMIITXER => NLW_PS7_i_EMIOENET1GMIITXER_UNCONNECTED,
      EMIOENET1MDIOI => '0',
      EMIOENET1MDIOMDC => PS7_i_n_31,
      EMIOENET1MDIOO => PS7_i_n_32,
      EMIOENET1MDIOTN => ENET1_MDIO_T_n,
      EMIOENET1PTPDELAYREQRX => PS7_i_n_34,
      EMIOENET1PTPDELAYREQTX => PS7_i_n_35,
      EMIOENET1PTPPDELAYREQRX => PS7_i_n_36,
      EMIOENET1PTPPDELAYREQTX => PS7_i_n_37,
      EMIOENET1PTPPDELAYRESPRX => PS7_i_n_38,
      EMIOENET1PTPPDELAYRESPTX => PS7_i_n_39,
      EMIOENET1PTPSYNCFRAMERX => PS7_i_n_40,
      EMIOENET1PTPSYNCFRAMETX => PS7_i_n_41,
      EMIOENET1SOFRX => PS7_i_n_42,
      EMIOENET1SOFTX => PS7_i_n_43,
      EMIOGPIOI(63 downto 0) => B"0000000000000000000000000000000000000000000000000000000000000000",
      EMIOGPIOO(63) => PS7_i_n_873,
      EMIOGPIOO(62) => PS7_i_n_874,
      EMIOGPIOO(61) => PS7_i_n_875,
      EMIOGPIOO(60) => PS7_i_n_876,
      EMIOGPIOO(59) => PS7_i_n_877,
      EMIOGPIOO(58) => PS7_i_n_878,
      EMIOGPIOO(57) => PS7_i_n_879,
      EMIOGPIOO(56) => PS7_i_n_880,
      EMIOGPIOO(55) => PS7_i_n_881,
      EMIOGPIOO(54) => PS7_i_n_882,
      EMIOGPIOO(53) => PS7_i_n_883,
      EMIOGPIOO(52) => PS7_i_n_884,
      EMIOGPIOO(51) => PS7_i_n_885,
      EMIOGPIOO(50) => PS7_i_n_886,
      EMIOGPIOO(49) => PS7_i_n_887,
      EMIOGPIOO(48) => PS7_i_n_888,
      EMIOGPIOO(47) => PS7_i_n_889,
      EMIOGPIOO(46) => PS7_i_n_890,
      EMIOGPIOO(45) => PS7_i_n_891,
      EMIOGPIOO(44) => PS7_i_n_892,
      EMIOGPIOO(43) => PS7_i_n_893,
      EMIOGPIOO(42) => PS7_i_n_894,
      EMIOGPIOO(41) => PS7_i_n_895,
      EMIOGPIOO(40) => PS7_i_n_896,
      EMIOGPIOO(39) => PS7_i_n_897,
      EMIOGPIOO(38) => PS7_i_n_898,
      EMIOGPIOO(37) => PS7_i_n_899,
      EMIOGPIOO(36) => PS7_i_n_900,
      EMIOGPIOO(35) => PS7_i_n_901,
      EMIOGPIOO(34) => PS7_i_n_902,
      EMIOGPIOO(33) => PS7_i_n_903,
      EMIOGPIOO(32) => PS7_i_n_904,
      EMIOGPIOO(31) => PS7_i_n_905,
      EMIOGPIOO(30) => PS7_i_n_906,
      EMIOGPIOO(29) => PS7_i_n_907,
      EMIOGPIOO(28) => PS7_i_n_908,
      EMIOGPIOO(27) => PS7_i_n_909,
      EMIOGPIOO(26) => PS7_i_n_910,
      EMIOGPIOO(25) => PS7_i_n_911,
      EMIOGPIOO(24) => PS7_i_n_912,
      EMIOGPIOO(23) => PS7_i_n_913,
      EMIOGPIOO(22) => PS7_i_n_914,
      EMIOGPIOO(21) => PS7_i_n_915,
      EMIOGPIOO(20) => PS7_i_n_916,
      EMIOGPIOO(19) => PS7_i_n_917,
      EMIOGPIOO(18) => PS7_i_n_918,
      EMIOGPIOO(17) => PS7_i_n_919,
      EMIOGPIOO(16) => PS7_i_n_920,
      EMIOGPIOO(15) => PS7_i_n_921,
      EMIOGPIOO(14) => PS7_i_n_922,
      EMIOGPIOO(13) => PS7_i_n_923,
      EMIOGPIOO(12) => PS7_i_n_924,
      EMIOGPIOO(11) => PS7_i_n_925,
      EMIOGPIOO(10) => PS7_i_n_926,
      EMIOGPIOO(9) => PS7_i_n_927,
      EMIOGPIOO(8) => PS7_i_n_928,
      EMIOGPIOO(7) => PS7_i_n_929,
      EMIOGPIOO(6) => PS7_i_n_930,
      EMIOGPIOO(5) => PS7_i_n_931,
      EMIOGPIOO(4) => PS7_i_n_932,
      EMIOGPIOO(3) => PS7_i_n_933,
      EMIOGPIOO(2) => PS7_i_n_934,
      EMIOGPIOO(1) => PS7_i_n_935,
      EMIOGPIOO(0) => PS7_i_n_936,
      EMIOGPIOTN(63 downto 0) => gpio_out_t_n(63 downto 0),
      EMIOI2C0SCLI => '0',
      EMIOI2C0SCLO => PS7_i_n_44,
      EMIOI2C0SCLTN => I2C0_SCL_T_n,
      EMIOI2C0SDAI => '0',
      EMIOI2C0SDAO => PS7_i_n_46,
      EMIOI2C0SDATN => I2C0_SDA_T_n,
      EMIOI2C1SCLI => '0',
      EMIOI2C1SCLO => PS7_i_n_48,
      EMIOI2C1SCLTN => I2C1_SCL_T_n,
      EMIOI2C1SDAI => '0',
      EMIOI2C1SDAO => PS7_i_n_50,
      EMIOI2C1SDATN => I2C1_SDA_T_n,
      EMIOPJTAGTCK => '0',
      EMIOPJTAGTDI => '0',
      EMIOPJTAGTDO => NLW_PS7_i_EMIOPJTAGTDO_UNCONNECTED,
      EMIOPJTAGTDTN => NLW_PS7_i_EMIOPJTAGTDTN_UNCONNECTED,
      EMIOPJTAGTMS => '0',
      EMIOSDIO0BUSPOW => PS7_i_n_54,
      EMIOSDIO0BUSVOLT(2) => PS7_i_n_321,
      EMIOSDIO0BUSVOLT(1) => PS7_i_n_322,
      EMIOSDIO0BUSVOLT(0) => PS7_i_n_323,
      EMIOSDIO0CDN => '0',
      EMIOSDIO0CLK => PS7_i_n_55,
      EMIOSDIO0CLKFB => '0',
      EMIOSDIO0CMDI => '0',
      EMIOSDIO0CMDO => PS7_i_n_56,
      EMIOSDIO0CMDTN => SDIO0_CMD_T_n,
      EMIOSDIO0DATAI(3 downto 0) => B"0000",
      EMIOSDIO0DATAO(3) => PS7_i_n_689,
      EMIOSDIO0DATAO(2) => PS7_i_n_690,
      EMIOSDIO0DATAO(1) => PS7_i_n_691,
      EMIOSDIO0DATAO(0) => PS7_i_n_692,
      EMIOSDIO0DATATN(3 downto 0) => SDIO0_DATA_T_n(3 downto 0),
      EMIOSDIO0LED => PS7_i_n_58,
      EMIOSDIO0WP => '0',
      EMIOSDIO1BUSPOW => PS7_i_n_59,
      EMIOSDIO1BUSVOLT(2) => PS7_i_n_324,
      EMIOSDIO1BUSVOLT(1) => PS7_i_n_325,
      EMIOSDIO1BUSVOLT(0) => PS7_i_n_326,
      EMIOSDIO1CDN => '0',
      EMIOSDIO1CLK => PS7_i_n_60,
      EMIOSDIO1CLKFB => '0',
      EMIOSDIO1CMDI => '0',
      EMIOSDIO1CMDO => PS7_i_n_61,
      EMIOSDIO1CMDTN => SDIO1_CMD_T_n,
      EMIOSDIO1DATAI(3 downto 0) => B"0000",
      EMIOSDIO1DATAO(3) => PS7_i_n_697,
      EMIOSDIO1DATAO(2) => PS7_i_n_698,
      EMIOSDIO1DATAO(1) => PS7_i_n_699,
      EMIOSDIO1DATAO(0) => PS7_i_n_700,
      EMIOSDIO1DATATN(3 downto 0) => SDIO1_DATA_T_n(3 downto 0),
      EMIOSDIO1LED => PS7_i_n_63,
      EMIOSDIO1WP => '0',
      EMIOSPI0MI => '0',
      EMIOSPI0MO => PS7_i_n_64,
      EMIOSPI0MOTN => SPI0_MOSI_T_n,
      EMIOSPI0SCLKI => '0',
      EMIOSPI0SCLKO => PS7_i_n_66,
      EMIOSPI0SCLKTN => SPI0_SCLK_T_n,
      EMIOSPI0SI => '0',
      EMIOSPI0SO => PS7_i_n_68,
      EMIOSPI0SSIN => '0',
      EMIOSPI0SSNTN => SPI0_SS_T_n,
      EMIOSPI0SSON(2) => PS7_i_n_327,
      EMIOSPI0SSON(1) => PS7_i_n_328,
      EMIOSPI0SSON(0) => PS7_i_n_329,
      EMIOSPI0STN => SPI0_MISO_T_n,
      EMIOSPI1MI => '0',
      EMIOSPI1MO => PS7_i_n_71,
      EMIOSPI1MOTN => SPI1_MOSI_T_n,
      EMIOSPI1SCLKI => '0',
      EMIOSPI1SCLKO => PS7_i_n_73,
      EMIOSPI1SCLKTN => SPI1_SCLK_T_n,
      EMIOSPI1SI => '0',
      EMIOSPI1SO => PS7_i_n_75,
      EMIOSPI1SSIN => '0',
      EMIOSPI1SSNTN => SPI1_SS_T_n,
      EMIOSPI1SSON(2) => PS7_i_n_330,
      EMIOSPI1SSON(1) => PS7_i_n_331,
      EMIOSPI1SSON(0) => PS7_i_n_332,
      EMIOSPI1STN => SPI1_MISO_T_n,
      EMIOSRAMINTIN => '0',
      EMIOTRACECLK => '0',
      EMIOTRACECTL => NLW_PS7_i_EMIOTRACECTL_UNCONNECTED,
      EMIOTRACEDATA(31 downto 0) => NLW_PS7_i_EMIOTRACEDATA_UNCONNECTED(31 downto 0),
      EMIOTTC0CLKI(2 downto 0) => B"000",
      EMIOTTC0WAVEO(2) => PS7_i_n_333,
      EMIOTTC0WAVEO(1) => PS7_i_n_334,
      EMIOTTC0WAVEO(0) => PS7_i_n_335,
      EMIOTTC1CLKI(2 downto 0) => B"000",
      EMIOTTC1WAVEO(2) => PS7_i_n_336,
      EMIOTTC1WAVEO(1) => PS7_i_n_337,
      EMIOTTC1WAVEO(0) => PS7_i_n_338,
      EMIOUART0CTSN => '0',
      EMIOUART0DCDN => '0',
      EMIOUART0DSRN => '0',
      EMIOUART0DTRN => PS7_i_n_79,
      EMIOUART0RIN => '0',
      EMIOUART0RTSN => PS7_i_n_80,
      EMIOUART0RX => '1',
      EMIOUART0TX => PS7_i_n_81,
      EMIOUART1CTSN => '0',
      EMIOUART1DCDN => '0',
      EMIOUART1DSRN => '0',
      EMIOUART1DTRN => PS7_i_n_82,
      EMIOUART1RIN => '0',
      EMIOUART1RTSN => PS7_i_n_83,
      EMIOUART1RX => '1',
      EMIOUART1TX => PS7_i_n_84,
      EMIOUSB0PORTINDCTL(1) => PS7_i_n_232,
      EMIOUSB0PORTINDCTL(0) => PS7_i_n_233,
      EMIOUSB0VBUSPWRFAULT => '0',
      EMIOUSB0VBUSPWRSELECT => PS7_i_n_85,
      EMIOUSB1PORTINDCTL(1) => PS7_i_n_234,
      EMIOUSB1PORTINDCTL(0) => PS7_i_n_235,
      EMIOUSB1VBUSPWRFAULT => '0',
      EMIOUSB1VBUSPWRSELECT => PS7_i_n_86,
      EMIOWDTCLKI => '0',
      EMIOWDTRSTO => PS7_i_n_87,
      EVENTEVENTI => '0',
      EVENTEVENTO => PS7_i_n_88,
      EVENTSTANDBYWFE(1) => PS7_i_n_236,
      EVENTSTANDBYWFE(0) => PS7_i_n_237,
      EVENTSTANDBYWFI(1) => PS7_i_n_238,
      EVENTSTANDBYWFI(0) => PS7_i_n_239,
      FCLKCLK(3) => PS7_i_n_705,
      FCLKCLK(2) => PS7_i_n_706,
      FCLKCLK(1) => PS7_i_n_707,
      FCLKCLK(0) => FCLK_CLK0,
      FCLKCLKTRIGN(3 downto 0) => B"0000",
      FCLKRESETN(3) => PS7_i_n_709,
      FCLKRESETN(2) => PS7_i_n_710,
      FCLKRESETN(1) => PS7_i_n_711,
      FCLKRESETN(0) => FCLK_RESET0_N,
      FPGAIDLEN => '0',
      FTMDTRACEINATID(3 downto 0) => B"0000",
      FTMDTRACEINCLOCK => '0',
      FTMDTRACEINDATA(31 downto 0) => B"00000000000000000000000000000000",
      FTMDTRACEINVALID => '0',
      FTMTF2PDEBUG(31 downto 0) => B"00000000000000000000000000000000",
      FTMTF2PTRIG(3 downto 0) => B"0000",
      FTMTF2PTRIGACK(3) => PS7_i_n_713,
      FTMTF2PTRIGACK(2) => PS7_i_n_714,
      FTMTF2PTRIGACK(1) => PS7_i_n_715,
      FTMTF2PTRIGACK(0) => PS7_i_n_716,
      FTMTP2FDEBUG(31) => PS7_i_n_401,
      FTMTP2FDEBUG(30) => PS7_i_n_402,
      FTMTP2FDEBUG(29) => PS7_i_n_403,
      FTMTP2FDEBUG(28) => PS7_i_n_404,
      FTMTP2FDEBUG(27) => PS7_i_n_405,
      FTMTP2FDEBUG(26) => PS7_i_n_406,
      FTMTP2FDEBUG(25) => PS7_i_n_407,
      FTMTP2FDEBUG(24) => PS7_i_n_408,
      FTMTP2FDEBUG(23) => PS7_i_n_409,
      FTMTP2FDEBUG(22) => PS7_i_n_410,
      FTMTP2FDEBUG(21) => PS7_i_n_411,
      FTMTP2FDEBUG(20) => PS7_i_n_412,
      FTMTP2FDEBUG(19) => PS7_i_n_413,
      FTMTP2FDEBUG(18) => PS7_i_n_414,
      FTMTP2FDEBUG(17) => PS7_i_n_415,
      FTMTP2FDEBUG(16) => PS7_i_n_416,
      FTMTP2FDEBUG(15) => PS7_i_n_417,
      FTMTP2FDEBUG(14) => PS7_i_n_418,
      FTMTP2FDEBUG(13) => PS7_i_n_419,
      FTMTP2FDEBUG(12) => PS7_i_n_420,
      FTMTP2FDEBUG(11) => PS7_i_n_421,
      FTMTP2FDEBUG(10) => PS7_i_n_422,
      FTMTP2FDEBUG(9) => PS7_i_n_423,
      FTMTP2FDEBUG(8) => PS7_i_n_424,
      FTMTP2FDEBUG(7) => PS7_i_n_425,
      FTMTP2FDEBUG(6) => PS7_i_n_426,
      FTMTP2FDEBUG(5) => PS7_i_n_427,
      FTMTP2FDEBUG(4) => PS7_i_n_428,
      FTMTP2FDEBUG(3) => PS7_i_n_429,
      FTMTP2FDEBUG(2) => PS7_i_n_430,
      FTMTP2FDEBUG(1) => PS7_i_n_431,
      FTMTP2FDEBUG(0) => PS7_i_n_432,
      FTMTP2FTRIG(3) => PS7_i_n_717,
      FTMTP2FTRIG(2) => PS7_i_n_718,
      FTMTP2FTRIG(1) => PS7_i_n_719,
      FTMTP2FTRIG(0) => PS7_i_n_720,
      FTMTP2FTRIGACK(3 downto 0) => B"0000",
      IRQF2P(19 downto 0) => B"00000000000000000000",
      IRQP2F(28) => PS7_i_n_292,
      IRQP2F(27) => PS7_i_n_293,
      IRQP2F(26) => PS7_i_n_294,
      IRQP2F(25) => PS7_i_n_295,
      IRQP2F(24) => PS7_i_n_296,
      IRQP2F(23) => PS7_i_n_297,
      IRQP2F(22) => PS7_i_n_298,
      IRQP2F(21) => PS7_i_n_299,
      IRQP2F(20) => PS7_i_n_300,
      IRQP2F(19) => PS7_i_n_301,
      IRQP2F(18) => PS7_i_n_302,
      IRQP2F(17) => PS7_i_n_303,
      IRQP2F(16) => PS7_i_n_304,
      IRQP2F(15) => PS7_i_n_305,
      IRQP2F(14) => PS7_i_n_306,
      IRQP2F(13) => PS7_i_n_307,
      IRQP2F(12) => PS7_i_n_308,
      IRQP2F(11) => PS7_i_n_309,
      IRQP2F(10) => PS7_i_n_310,
      IRQP2F(9) => PS7_i_n_311,
      IRQP2F(8) => PS7_i_n_312,
      IRQP2F(7) => PS7_i_n_313,
      IRQP2F(6) => PS7_i_n_314,
      IRQP2F(5) => PS7_i_n_315,
      IRQP2F(4) => PS7_i_n_316,
      IRQP2F(3) => PS7_i_n_317,
      IRQP2F(2) => PS7_i_n_318,
      IRQP2F(1) => PS7_i_n_319,
      IRQP2F(0) => PS7_i_n_320,
      MAXIGP0ACLK => '0',
      MAXIGP0ARADDR(31) => PS7_i_n_433,
      MAXIGP0ARADDR(30) => PS7_i_n_434,
      MAXIGP0ARADDR(29) => PS7_i_n_435,
      MAXIGP0ARADDR(28) => PS7_i_n_436,
      MAXIGP0ARADDR(27) => PS7_i_n_437,
      MAXIGP0ARADDR(26) => PS7_i_n_438,
      MAXIGP0ARADDR(25) => PS7_i_n_439,
      MAXIGP0ARADDR(24) => PS7_i_n_440,
      MAXIGP0ARADDR(23) => PS7_i_n_441,
      MAXIGP0ARADDR(22) => PS7_i_n_442,
      MAXIGP0ARADDR(21) => PS7_i_n_443,
      MAXIGP0ARADDR(20) => PS7_i_n_444,
      MAXIGP0ARADDR(19) => PS7_i_n_445,
      MAXIGP0ARADDR(18) => PS7_i_n_446,
      MAXIGP0ARADDR(17) => PS7_i_n_447,
      MAXIGP0ARADDR(16) => PS7_i_n_448,
      MAXIGP0ARADDR(15) => PS7_i_n_449,
      MAXIGP0ARADDR(14) => PS7_i_n_450,
      MAXIGP0ARADDR(13) => PS7_i_n_451,
      MAXIGP0ARADDR(12) => PS7_i_n_452,
      MAXIGP0ARADDR(11) => PS7_i_n_453,
      MAXIGP0ARADDR(10) => PS7_i_n_454,
      MAXIGP0ARADDR(9) => PS7_i_n_455,
      MAXIGP0ARADDR(8) => PS7_i_n_456,
      MAXIGP0ARADDR(7) => PS7_i_n_457,
      MAXIGP0ARADDR(6) => PS7_i_n_458,
      MAXIGP0ARADDR(5) => PS7_i_n_459,
      MAXIGP0ARADDR(4) => PS7_i_n_460,
      MAXIGP0ARADDR(3) => PS7_i_n_461,
      MAXIGP0ARADDR(2) => PS7_i_n_462,
      MAXIGP0ARADDR(1) => PS7_i_n_463,
      MAXIGP0ARADDR(0) => PS7_i_n_464,
      MAXIGP0ARBURST(1) => PS7_i_n_240,
      MAXIGP0ARBURST(0) => PS7_i_n_241,
      MAXIGP0ARCACHE(3) => PS7_i_n_721,
      MAXIGP0ARCACHE(2) => PS7_i_n_722,
      MAXIGP0ARCACHE(1) => NLW_PS7_i_MAXIGP0ARCACHE_UNCONNECTED(1),
      MAXIGP0ARCACHE(0) => PS7_i_n_724,
      MAXIGP0ARESETN => PS7_i_n_89,
      MAXIGP0ARID(11) => PS7_i_n_152,
      MAXIGP0ARID(10) => PS7_i_n_153,
      MAXIGP0ARID(9) => PS7_i_n_154,
      MAXIGP0ARID(8) => PS7_i_n_155,
      MAXIGP0ARID(7) => PS7_i_n_156,
      MAXIGP0ARID(6) => PS7_i_n_157,
      MAXIGP0ARID(5) => PS7_i_n_158,
      MAXIGP0ARID(4) => PS7_i_n_159,
      MAXIGP0ARID(3) => PS7_i_n_160,
      MAXIGP0ARID(2) => PS7_i_n_161,
      MAXIGP0ARID(1) => PS7_i_n_162,
      MAXIGP0ARID(0) => PS7_i_n_163,
      MAXIGP0ARLEN(3) => PS7_i_n_725,
      MAXIGP0ARLEN(2) => PS7_i_n_726,
      MAXIGP0ARLEN(1) => PS7_i_n_727,
      MAXIGP0ARLEN(0) => PS7_i_n_728,
      MAXIGP0ARLOCK(1) => PS7_i_n_242,
      MAXIGP0ARLOCK(0) => PS7_i_n_243,
      MAXIGP0ARPROT(2) => PS7_i_n_339,
      MAXIGP0ARPROT(1) => PS7_i_n_340,
      MAXIGP0ARPROT(0) => PS7_i_n_341,
      MAXIGP0ARQOS(3) => PS7_i_n_729,
      MAXIGP0ARQOS(2) => PS7_i_n_730,
      MAXIGP0ARQOS(1) => PS7_i_n_731,
      MAXIGP0ARQOS(0) => PS7_i_n_732,
      MAXIGP0ARREADY => '0',
      MAXIGP0ARSIZE(1) => PS7_i_n_244,
      MAXIGP0ARSIZE(0) => PS7_i_n_245,
      MAXIGP0ARVALID => PS7_i_n_90,
      MAXIGP0AWADDR(31) => PS7_i_n_465,
      MAXIGP0AWADDR(30) => PS7_i_n_466,
      MAXIGP0AWADDR(29) => PS7_i_n_467,
      MAXIGP0AWADDR(28) => PS7_i_n_468,
      MAXIGP0AWADDR(27) => PS7_i_n_469,
      MAXIGP0AWADDR(26) => PS7_i_n_470,
      MAXIGP0AWADDR(25) => PS7_i_n_471,
      MAXIGP0AWADDR(24) => PS7_i_n_472,
      MAXIGP0AWADDR(23) => PS7_i_n_473,
      MAXIGP0AWADDR(22) => PS7_i_n_474,
      MAXIGP0AWADDR(21) => PS7_i_n_475,
      MAXIGP0AWADDR(20) => PS7_i_n_476,
      MAXIGP0AWADDR(19) => PS7_i_n_477,
      MAXIGP0AWADDR(18) => PS7_i_n_478,
      MAXIGP0AWADDR(17) => PS7_i_n_479,
      MAXIGP0AWADDR(16) => PS7_i_n_480,
      MAXIGP0AWADDR(15) => PS7_i_n_481,
      MAXIGP0AWADDR(14) => PS7_i_n_482,
      MAXIGP0AWADDR(13) => PS7_i_n_483,
      MAXIGP0AWADDR(12) => PS7_i_n_484,
      MAXIGP0AWADDR(11) => PS7_i_n_485,
      MAXIGP0AWADDR(10) => PS7_i_n_486,
      MAXIGP0AWADDR(9) => PS7_i_n_487,
      MAXIGP0AWADDR(8) => PS7_i_n_488,
      MAXIGP0AWADDR(7) => PS7_i_n_489,
      MAXIGP0AWADDR(6) => PS7_i_n_490,
      MAXIGP0AWADDR(5) => PS7_i_n_491,
      MAXIGP0AWADDR(4) => PS7_i_n_492,
      MAXIGP0AWADDR(3) => PS7_i_n_493,
      MAXIGP0AWADDR(2) => PS7_i_n_494,
      MAXIGP0AWADDR(1) => PS7_i_n_495,
      MAXIGP0AWADDR(0) => PS7_i_n_496,
      MAXIGP0AWBURST(1) => PS7_i_n_246,
      MAXIGP0AWBURST(0) => PS7_i_n_247,
      MAXIGP0AWCACHE(3) => PS7_i_n_733,
      MAXIGP0AWCACHE(2) => PS7_i_n_734,
      MAXIGP0AWCACHE(1) => NLW_PS7_i_MAXIGP0AWCACHE_UNCONNECTED(1),
      MAXIGP0AWCACHE(0) => PS7_i_n_736,
      MAXIGP0AWID(11) => PS7_i_n_164,
      MAXIGP0AWID(10) => PS7_i_n_165,
      MAXIGP0AWID(9) => PS7_i_n_166,
      MAXIGP0AWID(8) => PS7_i_n_167,
      MAXIGP0AWID(7) => PS7_i_n_168,
      MAXIGP0AWID(6) => PS7_i_n_169,
      MAXIGP0AWID(5) => PS7_i_n_170,
      MAXIGP0AWID(4) => PS7_i_n_171,
      MAXIGP0AWID(3) => PS7_i_n_172,
      MAXIGP0AWID(2) => PS7_i_n_173,
      MAXIGP0AWID(1) => PS7_i_n_174,
      MAXIGP0AWID(0) => PS7_i_n_175,
      MAXIGP0AWLEN(3) => PS7_i_n_737,
      MAXIGP0AWLEN(2) => PS7_i_n_738,
      MAXIGP0AWLEN(1) => PS7_i_n_739,
      MAXIGP0AWLEN(0) => PS7_i_n_740,
      MAXIGP0AWLOCK(1) => PS7_i_n_248,
      MAXIGP0AWLOCK(0) => PS7_i_n_249,
      MAXIGP0AWPROT(2) => PS7_i_n_342,
      MAXIGP0AWPROT(1) => PS7_i_n_343,
      MAXIGP0AWPROT(0) => PS7_i_n_344,
      MAXIGP0AWQOS(3) => PS7_i_n_741,
      MAXIGP0AWQOS(2) => PS7_i_n_742,
      MAXIGP0AWQOS(1) => PS7_i_n_743,
      MAXIGP0AWQOS(0) => PS7_i_n_744,
      MAXIGP0AWREADY => '0',
      MAXIGP0AWSIZE(1) => PS7_i_n_250,
      MAXIGP0AWSIZE(0) => PS7_i_n_251,
      MAXIGP0AWVALID => PS7_i_n_91,
      MAXIGP0BID(11 downto 0) => B"000000000000",
      MAXIGP0BREADY => PS7_i_n_92,
      MAXIGP0BRESP(1 downto 0) => B"00",
      MAXIGP0BVALID => '0',
      MAXIGP0RDATA(31 downto 0) => B"00000000000000000000000000000000",
      MAXIGP0RID(11 downto 0) => B"000000000000",
      MAXIGP0RLAST => '0',
      MAXIGP0RREADY => PS7_i_n_93,
      MAXIGP0RRESP(1 downto 0) => B"00",
      MAXIGP0RVALID => '0',
      MAXIGP0WDATA(31) => PS7_i_n_497,
      MAXIGP0WDATA(30) => PS7_i_n_498,
      MAXIGP0WDATA(29) => PS7_i_n_499,
      MAXIGP0WDATA(28) => PS7_i_n_500,
      MAXIGP0WDATA(27) => PS7_i_n_501,
      MAXIGP0WDATA(26) => PS7_i_n_502,
      MAXIGP0WDATA(25) => PS7_i_n_503,
      MAXIGP0WDATA(24) => PS7_i_n_504,
      MAXIGP0WDATA(23) => PS7_i_n_505,
      MAXIGP0WDATA(22) => PS7_i_n_506,
      MAXIGP0WDATA(21) => PS7_i_n_507,
      MAXIGP0WDATA(20) => PS7_i_n_508,
      MAXIGP0WDATA(19) => PS7_i_n_509,
      MAXIGP0WDATA(18) => PS7_i_n_510,
      MAXIGP0WDATA(17) => PS7_i_n_511,
      MAXIGP0WDATA(16) => PS7_i_n_512,
      MAXIGP0WDATA(15) => PS7_i_n_513,
      MAXIGP0WDATA(14) => PS7_i_n_514,
      MAXIGP0WDATA(13) => PS7_i_n_515,
      MAXIGP0WDATA(12) => PS7_i_n_516,
      MAXIGP0WDATA(11) => PS7_i_n_517,
      MAXIGP0WDATA(10) => PS7_i_n_518,
      MAXIGP0WDATA(9) => PS7_i_n_519,
      MAXIGP0WDATA(8) => PS7_i_n_520,
      MAXIGP0WDATA(7) => PS7_i_n_521,
      MAXIGP0WDATA(6) => PS7_i_n_522,
      MAXIGP0WDATA(5) => PS7_i_n_523,
      MAXIGP0WDATA(4) => PS7_i_n_524,
      MAXIGP0WDATA(3) => PS7_i_n_525,
      MAXIGP0WDATA(2) => PS7_i_n_526,
      MAXIGP0WDATA(1) => PS7_i_n_527,
      MAXIGP0WDATA(0) => PS7_i_n_528,
      MAXIGP0WID(11) => PS7_i_n_176,
      MAXIGP0WID(10) => PS7_i_n_177,
      MAXIGP0WID(9) => PS7_i_n_178,
      MAXIGP0WID(8) => PS7_i_n_179,
      MAXIGP0WID(7) => PS7_i_n_180,
      MAXIGP0WID(6) => PS7_i_n_181,
      MAXIGP0WID(5) => PS7_i_n_182,
      MAXIGP0WID(4) => PS7_i_n_183,
      MAXIGP0WID(3) => PS7_i_n_184,
      MAXIGP0WID(2) => PS7_i_n_185,
      MAXIGP0WID(1) => PS7_i_n_186,
      MAXIGP0WID(0) => PS7_i_n_187,
      MAXIGP0WLAST => PS7_i_n_94,
      MAXIGP0WREADY => '0',
      MAXIGP0WSTRB(3) => PS7_i_n_745,
      MAXIGP0WSTRB(2) => PS7_i_n_746,
      MAXIGP0WSTRB(1) => PS7_i_n_747,
      MAXIGP0WSTRB(0) => PS7_i_n_748,
      MAXIGP0WVALID => PS7_i_n_95,
      MAXIGP1ACLK => '0',
      MAXIGP1ARADDR(31) => PS7_i_n_529,
      MAXIGP1ARADDR(30) => PS7_i_n_530,
      MAXIGP1ARADDR(29) => PS7_i_n_531,
      MAXIGP1ARADDR(28) => PS7_i_n_532,
      MAXIGP1ARADDR(27) => PS7_i_n_533,
      MAXIGP1ARADDR(26) => PS7_i_n_534,
      MAXIGP1ARADDR(25) => PS7_i_n_535,
      MAXIGP1ARADDR(24) => PS7_i_n_536,
      MAXIGP1ARADDR(23) => PS7_i_n_537,
      MAXIGP1ARADDR(22) => PS7_i_n_538,
      MAXIGP1ARADDR(21) => PS7_i_n_539,
      MAXIGP1ARADDR(20) => PS7_i_n_540,
      MAXIGP1ARADDR(19) => PS7_i_n_541,
      MAXIGP1ARADDR(18) => PS7_i_n_542,
      MAXIGP1ARADDR(17) => PS7_i_n_543,
      MAXIGP1ARADDR(16) => PS7_i_n_544,
      MAXIGP1ARADDR(15) => PS7_i_n_545,
      MAXIGP1ARADDR(14) => PS7_i_n_546,
      MAXIGP1ARADDR(13) => PS7_i_n_547,
      MAXIGP1ARADDR(12) => PS7_i_n_548,
      MAXIGP1ARADDR(11) => PS7_i_n_549,
      MAXIGP1ARADDR(10) => PS7_i_n_550,
      MAXIGP1ARADDR(9) => PS7_i_n_551,
      MAXIGP1ARADDR(8) => PS7_i_n_552,
      MAXIGP1ARADDR(7) => PS7_i_n_553,
      MAXIGP1ARADDR(6) => PS7_i_n_554,
      MAXIGP1ARADDR(5) => PS7_i_n_555,
      MAXIGP1ARADDR(4) => PS7_i_n_556,
      MAXIGP1ARADDR(3) => PS7_i_n_557,
      MAXIGP1ARADDR(2) => PS7_i_n_558,
      MAXIGP1ARADDR(1) => PS7_i_n_559,
      MAXIGP1ARADDR(0) => PS7_i_n_560,
      MAXIGP1ARBURST(1) => PS7_i_n_252,
      MAXIGP1ARBURST(0) => PS7_i_n_253,
      MAXIGP1ARCACHE(3) => PS7_i_n_749,
      MAXIGP1ARCACHE(2) => PS7_i_n_750,
      MAXIGP1ARCACHE(1) => NLW_PS7_i_MAXIGP1ARCACHE_UNCONNECTED(1),
      MAXIGP1ARCACHE(0) => PS7_i_n_752,
      MAXIGP1ARESETN => PS7_i_n_96,
      MAXIGP1ARID(11) => PS7_i_n_188,
      MAXIGP1ARID(10) => PS7_i_n_189,
      MAXIGP1ARID(9) => PS7_i_n_190,
      MAXIGP1ARID(8) => PS7_i_n_191,
      MAXIGP1ARID(7) => PS7_i_n_192,
      MAXIGP1ARID(6) => PS7_i_n_193,
      MAXIGP1ARID(5) => PS7_i_n_194,
      MAXIGP1ARID(4) => PS7_i_n_195,
      MAXIGP1ARID(3) => PS7_i_n_196,
      MAXIGP1ARID(2) => PS7_i_n_197,
      MAXIGP1ARID(1) => PS7_i_n_198,
      MAXIGP1ARID(0) => PS7_i_n_199,
      MAXIGP1ARLEN(3) => PS7_i_n_753,
      MAXIGP1ARLEN(2) => PS7_i_n_754,
      MAXIGP1ARLEN(1) => PS7_i_n_755,
      MAXIGP1ARLEN(0) => PS7_i_n_756,
      MAXIGP1ARLOCK(1) => PS7_i_n_254,
      MAXIGP1ARLOCK(0) => PS7_i_n_255,
      MAXIGP1ARPROT(2) => PS7_i_n_345,
      MAXIGP1ARPROT(1) => PS7_i_n_346,
      MAXIGP1ARPROT(0) => PS7_i_n_347,
      MAXIGP1ARQOS(3) => PS7_i_n_757,
      MAXIGP1ARQOS(2) => PS7_i_n_758,
      MAXIGP1ARQOS(1) => PS7_i_n_759,
      MAXIGP1ARQOS(0) => PS7_i_n_760,
      MAXIGP1ARREADY => '0',
      MAXIGP1ARSIZE(1) => PS7_i_n_256,
      MAXIGP1ARSIZE(0) => PS7_i_n_257,
      MAXIGP1ARVALID => PS7_i_n_97,
      MAXIGP1AWADDR(31) => PS7_i_n_561,
      MAXIGP1AWADDR(30) => PS7_i_n_562,
      MAXIGP1AWADDR(29) => PS7_i_n_563,
      MAXIGP1AWADDR(28) => PS7_i_n_564,
      MAXIGP1AWADDR(27) => PS7_i_n_565,
      MAXIGP1AWADDR(26) => PS7_i_n_566,
      MAXIGP1AWADDR(25) => PS7_i_n_567,
      MAXIGP1AWADDR(24) => PS7_i_n_568,
      MAXIGP1AWADDR(23) => PS7_i_n_569,
      MAXIGP1AWADDR(22) => PS7_i_n_570,
      MAXIGP1AWADDR(21) => PS7_i_n_571,
      MAXIGP1AWADDR(20) => PS7_i_n_572,
      MAXIGP1AWADDR(19) => PS7_i_n_573,
      MAXIGP1AWADDR(18) => PS7_i_n_574,
      MAXIGP1AWADDR(17) => PS7_i_n_575,
      MAXIGP1AWADDR(16) => PS7_i_n_576,
      MAXIGP1AWADDR(15) => PS7_i_n_577,
      MAXIGP1AWADDR(14) => PS7_i_n_578,
      MAXIGP1AWADDR(13) => PS7_i_n_579,
      MAXIGP1AWADDR(12) => PS7_i_n_580,
      MAXIGP1AWADDR(11) => PS7_i_n_581,
      MAXIGP1AWADDR(10) => PS7_i_n_582,
      MAXIGP1AWADDR(9) => PS7_i_n_583,
      MAXIGP1AWADDR(8) => PS7_i_n_584,
      MAXIGP1AWADDR(7) => PS7_i_n_585,
      MAXIGP1AWADDR(6) => PS7_i_n_586,
      MAXIGP1AWADDR(5) => PS7_i_n_587,
      MAXIGP1AWADDR(4) => PS7_i_n_588,
      MAXIGP1AWADDR(3) => PS7_i_n_589,
      MAXIGP1AWADDR(2) => PS7_i_n_590,
      MAXIGP1AWADDR(1) => PS7_i_n_591,
      MAXIGP1AWADDR(0) => PS7_i_n_592,
      MAXIGP1AWBURST(1) => PS7_i_n_258,
      MAXIGP1AWBURST(0) => PS7_i_n_259,
      MAXIGP1AWCACHE(3) => PS7_i_n_761,
      MAXIGP1AWCACHE(2) => PS7_i_n_762,
      MAXIGP1AWCACHE(1) => NLW_PS7_i_MAXIGP1AWCACHE_UNCONNECTED(1),
      MAXIGP1AWCACHE(0) => PS7_i_n_764,
      MAXIGP1AWID(11) => PS7_i_n_200,
      MAXIGP1AWID(10) => PS7_i_n_201,
      MAXIGP1AWID(9) => PS7_i_n_202,
      MAXIGP1AWID(8) => PS7_i_n_203,
      MAXIGP1AWID(7) => PS7_i_n_204,
      MAXIGP1AWID(6) => PS7_i_n_205,
      MAXIGP1AWID(5) => PS7_i_n_206,
      MAXIGP1AWID(4) => PS7_i_n_207,
      MAXIGP1AWID(3) => PS7_i_n_208,
      MAXIGP1AWID(2) => PS7_i_n_209,
      MAXIGP1AWID(1) => PS7_i_n_210,
      MAXIGP1AWID(0) => PS7_i_n_211,
      MAXIGP1AWLEN(3) => PS7_i_n_765,
      MAXIGP1AWLEN(2) => PS7_i_n_766,
      MAXIGP1AWLEN(1) => PS7_i_n_767,
      MAXIGP1AWLEN(0) => PS7_i_n_768,
      MAXIGP1AWLOCK(1) => PS7_i_n_260,
      MAXIGP1AWLOCK(0) => PS7_i_n_261,
      MAXIGP1AWPROT(2) => PS7_i_n_348,
      MAXIGP1AWPROT(1) => PS7_i_n_349,
      MAXIGP1AWPROT(0) => PS7_i_n_350,
      MAXIGP1AWQOS(3) => PS7_i_n_769,
      MAXIGP1AWQOS(2) => PS7_i_n_770,
      MAXIGP1AWQOS(1) => PS7_i_n_771,
      MAXIGP1AWQOS(0) => PS7_i_n_772,
      MAXIGP1AWREADY => '0',
      MAXIGP1AWSIZE(1) => PS7_i_n_262,
      MAXIGP1AWSIZE(0) => PS7_i_n_263,
      MAXIGP1AWVALID => PS7_i_n_98,
      MAXIGP1BID(11 downto 0) => B"000000000000",
      MAXIGP1BREADY => PS7_i_n_99,
      MAXIGP1BRESP(1 downto 0) => B"00",
      MAXIGP1BVALID => '0',
      MAXIGP1RDATA(31 downto 0) => B"00000000000000000000000000000000",
      MAXIGP1RID(11 downto 0) => B"000000000000",
      MAXIGP1RLAST => '0',
      MAXIGP1RREADY => PS7_i_n_100,
      MAXIGP1RRESP(1 downto 0) => B"00",
      MAXIGP1RVALID => '0',
      MAXIGP1WDATA(31) => PS7_i_n_593,
      MAXIGP1WDATA(30) => PS7_i_n_594,
      MAXIGP1WDATA(29) => PS7_i_n_595,
      MAXIGP1WDATA(28) => PS7_i_n_596,
      MAXIGP1WDATA(27) => PS7_i_n_597,
      MAXIGP1WDATA(26) => PS7_i_n_598,
      MAXIGP1WDATA(25) => PS7_i_n_599,
      MAXIGP1WDATA(24) => PS7_i_n_600,
      MAXIGP1WDATA(23) => PS7_i_n_601,
      MAXIGP1WDATA(22) => PS7_i_n_602,
      MAXIGP1WDATA(21) => PS7_i_n_603,
      MAXIGP1WDATA(20) => PS7_i_n_604,
      MAXIGP1WDATA(19) => PS7_i_n_605,
      MAXIGP1WDATA(18) => PS7_i_n_606,
      MAXIGP1WDATA(17) => PS7_i_n_607,
      MAXIGP1WDATA(16) => PS7_i_n_608,
      MAXIGP1WDATA(15) => PS7_i_n_609,
      MAXIGP1WDATA(14) => PS7_i_n_610,
      MAXIGP1WDATA(13) => PS7_i_n_611,
      MAXIGP1WDATA(12) => PS7_i_n_612,
      MAXIGP1WDATA(11) => PS7_i_n_613,
      MAXIGP1WDATA(10) => PS7_i_n_614,
      MAXIGP1WDATA(9) => PS7_i_n_615,
      MAXIGP1WDATA(8) => PS7_i_n_616,
      MAXIGP1WDATA(7) => PS7_i_n_617,
      MAXIGP1WDATA(6) => PS7_i_n_618,
      MAXIGP1WDATA(5) => PS7_i_n_619,
      MAXIGP1WDATA(4) => PS7_i_n_620,
      MAXIGP1WDATA(3) => PS7_i_n_621,
      MAXIGP1WDATA(2) => PS7_i_n_622,
      MAXIGP1WDATA(1) => PS7_i_n_623,
      MAXIGP1WDATA(0) => PS7_i_n_624,
      MAXIGP1WID(11) => PS7_i_n_212,
      MAXIGP1WID(10) => PS7_i_n_213,
      MAXIGP1WID(9) => PS7_i_n_214,
      MAXIGP1WID(8) => PS7_i_n_215,
      MAXIGP1WID(7) => PS7_i_n_216,
      MAXIGP1WID(6) => PS7_i_n_217,
      MAXIGP1WID(5) => PS7_i_n_218,
      MAXIGP1WID(4) => PS7_i_n_219,
      MAXIGP1WID(3) => PS7_i_n_220,
      MAXIGP1WID(2) => PS7_i_n_221,
      MAXIGP1WID(1) => PS7_i_n_222,
      MAXIGP1WID(0) => PS7_i_n_223,
      MAXIGP1WLAST => PS7_i_n_101,
      MAXIGP1WREADY => '0',
      MAXIGP1WSTRB(3) => PS7_i_n_773,
      MAXIGP1WSTRB(2) => PS7_i_n_774,
      MAXIGP1WSTRB(1) => PS7_i_n_775,
      MAXIGP1WSTRB(0) => PS7_i_n_776,
      MAXIGP1WVALID => PS7_i_n_102,
      MIO(53 downto 0) => buffered_MIO(53 downto 0),
      PSCLK => buffered_PS_CLK,
      PSPORB => buffered_PS_PORB,
      PSSRSTB => buffered_PS_SRSTB,
      SAXIACPACLK => '0',
      SAXIACPARADDR(31 downto 0) => B"00000000000000000000000000000000",
      SAXIACPARBURST(1 downto 0) => B"00",
      SAXIACPARCACHE(3 downto 0) => B"0000",
      SAXIACPARESETN => PS7_i_n_103,
      SAXIACPARID(2 downto 0) => B"000",
      SAXIACPARLEN(3 downto 0) => B"0000",
      SAXIACPARLOCK(1 downto 0) => B"00",
      SAXIACPARPROT(2 downto 0) => B"000",
      SAXIACPARQOS(3 downto 0) => B"0000",
      SAXIACPARREADY => PS7_i_n_104,
      SAXIACPARSIZE(1 downto 0) => B"00",
      SAXIACPARUSER(4 downto 0) => B"00000",
      SAXIACPARVALID => '0',
      SAXIACPAWADDR(31 downto 0) => B"00000000000000000000000000000000",
      SAXIACPAWBURST(1 downto 0) => B"00",
      SAXIACPAWCACHE(3 downto 0) => B"0000",
      SAXIACPAWID(2 downto 0) => B"000",
      SAXIACPAWLEN(3 downto 0) => B"0000",
      SAXIACPAWLOCK(1 downto 0) => B"00",
      SAXIACPAWPROT(2 downto 0) => B"000",
      SAXIACPAWQOS(3 downto 0) => B"0000",
      SAXIACPAWREADY => PS7_i_n_105,
      SAXIACPAWSIZE(1 downto 0) => B"00",
      SAXIACPAWUSER(4 downto 0) => B"00000",
      SAXIACPAWVALID => '0',
      SAXIACPBID(2) => PS7_i_n_351,
      SAXIACPBID(1) => PS7_i_n_352,
      SAXIACPBID(0) => PS7_i_n_353,
      SAXIACPBREADY => '0',
      SAXIACPBRESP(1) => PS7_i_n_264,
      SAXIACPBRESP(0) => PS7_i_n_265,
      SAXIACPBVALID => PS7_i_n_106,
      SAXIACPRDATA(63) => PS7_i_n_1001,
      SAXIACPRDATA(62) => PS7_i_n_1002,
      SAXIACPRDATA(61) => PS7_i_n_1003,
      SAXIACPRDATA(60) => PS7_i_n_1004,
      SAXIACPRDATA(59) => PS7_i_n_1005,
      SAXIACPRDATA(58) => PS7_i_n_1006,
      SAXIACPRDATA(57) => PS7_i_n_1007,
      SAXIACPRDATA(56) => PS7_i_n_1008,
      SAXIACPRDATA(55) => PS7_i_n_1009,
      SAXIACPRDATA(54) => PS7_i_n_1010,
      SAXIACPRDATA(53) => PS7_i_n_1011,
      SAXIACPRDATA(52) => PS7_i_n_1012,
      SAXIACPRDATA(51) => PS7_i_n_1013,
      SAXIACPRDATA(50) => PS7_i_n_1014,
      SAXIACPRDATA(49) => PS7_i_n_1015,
      SAXIACPRDATA(48) => PS7_i_n_1016,
      SAXIACPRDATA(47) => PS7_i_n_1017,
      SAXIACPRDATA(46) => PS7_i_n_1018,
      SAXIACPRDATA(45) => PS7_i_n_1019,
      SAXIACPRDATA(44) => PS7_i_n_1020,
      SAXIACPRDATA(43) => PS7_i_n_1021,
      SAXIACPRDATA(42) => PS7_i_n_1022,
      SAXIACPRDATA(41) => PS7_i_n_1023,
      SAXIACPRDATA(40) => PS7_i_n_1024,
      SAXIACPRDATA(39) => PS7_i_n_1025,
      SAXIACPRDATA(38) => PS7_i_n_1026,
      SAXIACPRDATA(37) => PS7_i_n_1027,
      SAXIACPRDATA(36) => PS7_i_n_1028,
      SAXIACPRDATA(35) => PS7_i_n_1029,
      SAXIACPRDATA(34) => PS7_i_n_1030,
      SAXIACPRDATA(33) => PS7_i_n_1031,
      SAXIACPRDATA(32) => PS7_i_n_1032,
      SAXIACPRDATA(31) => PS7_i_n_1033,
      SAXIACPRDATA(30) => PS7_i_n_1034,
      SAXIACPRDATA(29) => PS7_i_n_1035,
      SAXIACPRDATA(28) => PS7_i_n_1036,
      SAXIACPRDATA(27) => PS7_i_n_1037,
      SAXIACPRDATA(26) => PS7_i_n_1038,
      SAXIACPRDATA(25) => PS7_i_n_1039,
      SAXIACPRDATA(24) => PS7_i_n_1040,
      SAXIACPRDATA(23) => PS7_i_n_1041,
      SAXIACPRDATA(22) => PS7_i_n_1042,
      SAXIACPRDATA(21) => PS7_i_n_1043,
      SAXIACPRDATA(20) => PS7_i_n_1044,
      SAXIACPRDATA(19) => PS7_i_n_1045,
      SAXIACPRDATA(18) => PS7_i_n_1046,
      SAXIACPRDATA(17) => PS7_i_n_1047,
      SAXIACPRDATA(16) => PS7_i_n_1048,
      SAXIACPRDATA(15) => PS7_i_n_1049,
      SAXIACPRDATA(14) => PS7_i_n_1050,
      SAXIACPRDATA(13) => PS7_i_n_1051,
      SAXIACPRDATA(12) => PS7_i_n_1052,
      SAXIACPRDATA(11) => PS7_i_n_1053,
      SAXIACPRDATA(10) => PS7_i_n_1054,
      SAXIACPRDATA(9) => PS7_i_n_1055,
      SAXIACPRDATA(8) => PS7_i_n_1056,
      SAXIACPRDATA(7) => PS7_i_n_1057,
      SAXIACPRDATA(6) => PS7_i_n_1058,
      SAXIACPRDATA(5) => PS7_i_n_1059,
      SAXIACPRDATA(4) => PS7_i_n_1060,
      SAXIACPRDATA(3) => PS7_i_n_1061,
      SAXIACPRDATA(2) => PS7_i_n_1062,
      SAXIACPRDATA(1) => PS7_i_n_1063,
      SAXIACPRDATA(0) => PS7_i_n_1064,
      SAXIACPRID(2) => PS7_i_n_354,
      SAXIACPRID(1) => PS7_i_n_355,
      SAXIACPRID(0) => PS7_i_n_356,
      SAXIACPRLAST => PS7_i_n_107,
      SAXIACPRREADY => '0',
      SAXIACPRRESP(1) => PS7_i_n_266,
      SAXIACPRRESP(0) => PS7_i_n_267,
      SAXIACPRVALID => PS7_i_n_108,
      SAXIACPWDATA(63 downto 0) => B"0000000000000000000000000000000000000000000000000000000000000000",
      SAXIACPWID(2 downto 0) => B"000",
      SAXIACPWLAST => '0',
      SAXIACPWREADY => PS7_i_n_109,
      SAXIACPWSTRB(7 downto 0) => B"00000000",
      SAXIACPWVALID => '0',
      SAXIGP0ACLK => '0',
      SAXIGP0ARADDR(31 downto 0) => B"00000000000000000000000000000000",
      SAXIGP0ARBURST(1 downto 0) => B"00",
      SAXIGP0ARCACHE(3 downto 0) => B"0000",
      SAXIGP0ARESETN => PS7_i_n_110,
      SAXIGP0ARID(5 downto 0) => B"000000",
      SAXIGP0ARLEN(3 downto 0) => B"0000",
      SAXIGP0ARLOCK(1 downto 0) => B"00",
      SAXIGP0ARPROT(2 downto 0) => B"000",
      SAXIGP0ARQOS(3 downto 0) => B"0000",
      SAXIGP0ARREADY => PS7_i_n_111,
      SAXIGP0ARSIZE(1 downto 0) => B"00",
      SAXIGP0ARVALID => '0',
      SAXIGP0AWADDR(31 downto 0) => B"00000000000000000000000000000000",
      SAXIGP0AWBURST(1 downto 0) => B"00",
      SAXIGP0AWCACHE(3 downto 0) => B"0000",
      SAXIGP0AWID(5 downto 0) => B"000000",
      SAXIGP0AWLEN(3 downto 0) => B"0000",
      SAXIGP0AWLOCK(1 downto 0) => B"00",
      SAXIGP0AWPROT(2 downto 0) => B"000",
      SAXIGP0AWQOS(3 downto 0) => B"0000",
      SAXIGP0AWREADY => PS7_i_n_112,
      SAXIGP0AWSIZE(1 downto 0) => B"00",
      SAXIGP0AWVALID => '0',
      SAXIGP0BID(5) => PS7_i_n_777,
      SAXIGP0BID(4) => PS7_i_n_778,
      SAXIGP0BID(3) => PS7_i_n_779,
      SAXIGP0BID(2) => PS7_i_n_780,
      SAXIGP0BID(1) => PS7_i_n_781,
      SAXIGP0BID(0) => PS7_i_n_782,
      SAXIGP0BREADY => '0',
      SAXIGP0BRESP(1) => PS7_i_n_268,
      SAXIGP0BRESP(0) => PS7_i_n_269,
      SAXIGP0BVALID => PS7_i_n_113,
      SAXIGP0RDATA(31) => PS7_i_n_625,
      SAXIGP0RDATA(30) => PS7_i_n_626,
      SAXIGP0RDATA(29) => PS7_i_n_627,
      SAXIGP0RDATA(28) => PS7_i_n_628,
      SAXIGP0RDATA(27) => PS7_i_n_629,
      SAXIGP0RDATA(26) => PS7_i_n_630,
      SAXIGP0RDATA(25) => PS7_i_n_631,
      SAXIGP0RDATA(24) => PS7_i_n_632,
      SAXIGP0RDATA(23) => PS7_i_n_633,
      SAXIGP0RDATA(22) => PS7_i_n_634,
      SAXIGP0RDATA(21) => PS7_i_n_635,
      SAXIGP0RDATA(20) => PS7_i_n_636,
      SAXIGP0RDATA(19) => PS7_i_n_637,
      SAXIGP0RDATA(18) => PS7_i_n_638,
      SAXIGP0RDATA(17) => PS7_i_n_639,
      SAXIGP0RDATA(16) => PS7_i_n_640,
      SAXIGP0RDATA(15) => PS7_i_n_641,
      SAXIGP0RDATA(14) => PS7_i_n_642,
      SAXIGP0RDATA(13) => PS7_i_n_643,
      SAXIGP0RDATA(12) => PS7_i_n_644,
      SAXIGP0RDATA(11) => PS7_i_n_645,
      SAXIGP0RDATA(10) => PS7_i_n_646,
      SAXIGP0RDATA(9) => PS7_i_n_647,
      SAXIGP0RDATA(8) => PS7_i_n_648,
      SAXIGP0RDATA(7) => PS7_i_n_649,
      SAXIGP0RDATA(6) => PS7_i_n_650,
      SAXIGP0RDATA(5) => PS7_i_n_651,
      SAXIGP0RDATA(4) => PS7_i_n_652,
      SAXIGP0RDATA(3) => PS7_i_n_653,
      SAXIGP0RDATA(2) => PS7_i_n_654,
      SAXIGP0RDATA(1) => PS7_i_n_655,
      SAXIGP0RDATA(0) => PS7_i_n_656,
      SAXIGP0RID(5) => PS7_i_n_783,
      SAXIGP0RID(4) => PS7_i_n_784,
      SAXIGP0RID(3) => PS7_i_n_785,
      SAXIGP0RID(2) => PS7_i_n_786,
      SAXIGP0RID(1) => PS7_i_n_787,
      SAXIGP0RID(0) => PS7_i_n_788,
      SAXIGP0RLAST => PS7_i_n_114,
      SAXIGP0RREADY => '0',
      SAXIGP0RRESP(1) => PS7_i_n_270,
      SAXIGP0RRESP(0) => PS7_i_n_271,
      SAXIGP0RVALID => PS7_i_n_115,
      SAXIGP0WDATA(31 downto 0) => B"00000000000000000000000000000000",
      SAXIGP0WID(5 downto 0) => B"000000",
      SAXIGP0WLAST => '0',
      SAXIGP0WREADY => PS7_i_n_116,
      SAXIGP0WSTRB(3 downto 0) => B"0000",
      SAXIGP0WVALID => '0',
      SAXIGP1ACLK => '0',
      SAXIGP1ARADDR(31 downto 0) => B"00000000000000000000000000000000",
      SAXIGP1ARBURST(1 downto 0) => B"00",
      SAXIGP1ARCACHE(3 downto 0) => B"0000",
      SAXIGP1ARESETN => PS7_i_n_117,
      SAXIGP1ARID(5 downto 0) => B"000000",
      SAXIGP1ARLEN(3 downto 0) => B"0000",
      SAXIGP1ARLOCK(1 downto 0) => B"00",
      SAXIGP1ARPROT(2 downto 0) => B"000",
      SAXIGP1ARQOS(3 downto 0) => B"0000",
      SAXIGP1ARREADY => PS7_i_n_118,
      SAXIGP1ARSIZE(1 downto 0) => B"00",
      SAXIGP1ARVALID => '0',
      SAXIGP1AWADDR(31 downto 0) => B"00000000000000000000000000000000",
      SAXIGP1AWBURST(1 downto 0) => B"00",
      SAXIGP1AWCACHE(3 downto 0) => B"0000",
      SAXIGP1AWID(5 downto 0) => B"000000",
      SAXIGP1AWLEN(3 downto 0) => B"0000",
      SAXIGP1AWLOCK(1 downto 0) => B"00",
      SAXIGP1AWPROT(2 downto 0) => B"000",
      SAXIGP1AWQOS(3 downto 0) => B"0000",
      SAXIGP1AWREADY => PS7_i_n_119,
      SAXIGP1AWSIZE(1 downto 0) => B"00",
      SAXIGP1AWVALID => '0',
      SAXIGP1BID(5) => PS7_i_n_789,
      SAXIGP1BID(4) => PS7_i_n_790,
      SAXIGP1BID(3) => PS7_i_n_791,
      SAXIGP1BID(2) => PS7_i_n_792,
      SAXIGP1BID(1) => PS7_i_n_793,
      SAXIGP1BID(0) => PS7_i_n_794,
      SAXIGP1BREADY => '0',
      SAXIGP1BRESP(1) => PS7_i_n_272,
      SAXIGP1BRESP(0) => PS7_i_n_273,
      SAXIGP1BVALID => PS7_i_n_120,
      SAXIGP1RDATA(31) => PS7_i_n_657,
      SAXIGP1RDATA(30) => PS7_i_n_658,
      SAXIGP1RDATA(29) => PS7_i_n_659,
      SAXIGP1RDATA(28) => PS7_i_n_660,
      SAXIGP1RDATA(27) => PS7_i_n_661,
      SAXIGP1RDATA(26) => PS7_i_n_662,
      SAXIGP1RDATA(25) => PS7_i_n_663,
      SAXIGP1RDATA(24) => PS7_i_n_664,
      SAXIGP1RDATA(23) => PS7_i_n_665,
      SAXIGP1RDATA(22) => PS7_i_n_666,
      SAXIGP1RDATA(21) => PS7_i_n_667,
      SAXIGP1RDATA(20) => PS7_i_n_668,
      SAXIGP1RDATA(19) => PS7_i_n_669,
      SAXIGP1RDATA(18) => PS7_i_n_670,
      SAXIGP1RDATA(17) => PS7_i_n_671,
      SAXIGP1RDATA(16) => PS7_i_n_672,
      SAXIGP1RDATA(15) => PS7_i_n_673,
      SAXIGP1RDATA(14) => PS7_i_n_674,
      SAXIGP1RDATA(13) => PS7_i_n_675,
      SAXIGP1RDATA(12) => PS7_i_n_676,
      SAXIGP1RDATA(11) => PS7_i_n_677,
      SAXIGP1RDATA(10) => PS7_i_n_678,
      SAXIGP1RDATA(9) => PS7_i_n_679,
      SAXIGP1RDATA(8) => PS7_i_n_680,
      SAXIGP1RDATA(7) => PS7_i_n_681,
      SAXIGP1RDATA(6) => PS7_i_n_682,
      SAXIGP1RDATA(5) => PS7_i_n_683,
      SAXIGP1RDATA(4) => PS7_i_n_684,
      SAXIGP1RDATA(3) => PS7_i_n_685,
      SAXIGP1RDATA(2) => PS7_i_n_686,
      SAXIGP1RDATA(1) => PS7_i_n_687,
      SAXIGP1RDATA(0) => PS7_i_n_688,
      SAXIGP1RID(5) => PS7_i_n_795,
      SAXIGP1RID(4) => PS7_i_n_796,
      SAXIGP1RID(3) => PS7_i_n_797,
      SAXIGP1RID(2) => PS7_i_n_798,
      SAXIGP1RID(1) => PS7_i_n_799,
      SAXIGP1RID(0) => PS7_i_n_800,
      SAXIGP1RLAST => PS7_i_n_121,
      SAXIGP1RREADY => '0',
      SAXIGP1RRESP(1) => PS7_i_n_274,
      SAXIGP1RRESP(0) => PS7_i_n_275,
      SAXIGP1RVALID => PS7_i_n_122,
      SAXIGP1WDATA(31 downto 0) => B"00000000000000000000000000000000",
      SAXIGP1WID(5 downto 0) => B"000000",
      SAXIGP1WLAST => '0',
      SAXIGP1WREADY => PS7_i_n_123,
      SAXIGP1WSTRB(3 downto 0) => B"0000",
      SAXIGP1WVALID => '0',
      SAXIHP0ACLK => S_AXI_HP0_ACLK,
      SAXIHP0ARADDR(31 downto 0) => S_AXI_HP0_ARADDR(31 downto 0),
      SAXIHP0ARBURST(1 downto 0) => S_AXI_HP0_ARBURST(1 downto 0),
      SAXIHP0ARCACHE(3 downto 0) => S_AXI_HP0_ARCACHE(3 downto 0),
      SAXIHP0ARESETN => PS7_i_n_124,
      SAXIHP0ARID(5 downto 0) => S_AXI_HP0_ARID(5 downto 0),
      SAXIHP0ARLEN(3 downto 0) => S_AXI_HP0_ARLEN(3 downto 0),
      SAXIHP0ARLOCK(1 downto 0) => S_AXI_HP0_ARLOCK(1 downto 0),
      SAXIHP0ARPROT(2 downto 0) => S_AXI_HP0_ARPROT(2 downto 0),
      SAXIHP0ARQOS(3 downto 0) => S_AXI_HP0_ARQOS(3 downto 0),
      SAXIHP0ARREADY => S_AXI_HP0_ARREADY,
      SAXIHP0ARSIZE(1 downto 0) => S_AXI_HP0_ARSIZE(1 downto 0),
      SAXIHP0ARVALID => S_AXI_HP0_ARVALID,
      SAXIHP0AWADDR(31 downto 0) => S_AXI_HP0_AWADDR(31 downto 0),
      SAXIHP0AWBURST(1 downto 0) => S_AXI_HP0_AWBURST(1 downto 0),
      SAXIHP0AWCACHE(3 downto 0) => S_AXI_HP0_AWCACHE(3 downto 0),
      SAXIHP0AWID(5 downto 0) => S_AXI_HP0_AWID(5 downto 0),
      SAXIHP0AWLEN(3 downto 0) => S_AXI_HP0_AWLEN(3 downto 0),
      SAXIHP0AWLOCK(1 downto 0) => S_AXI_HP0_AWLOCK(1 downto 0),
      SAXIHP0AWPROT(2 downto 0) => S_AXI_HP0_AWPROT(2 downto 0),
      SAXIHP0AWQOS(3 downto 0) => S_AXI_HP0_AWQOS(3 downto 0),
      SAXIHP0AWREADY => S_AXI_HP0_AWREADY,
      SAXIHP0AWSIZE(1 downto 0) => S_AXI_HP0_AWSIZE(1 downto 0),
      SAXIHP0AWVALID => S_AXI_HP0_AWVALID,
      SAXIHP0BID(5 downto 0) => S_AXI_HP0_BID(5 downto 0),
      SAXIHP0BREADY => S_AXI_HP0_BREADY,
      SAXIHP0BRESP(1 downto 0) => S_AXI_HP0_BRESP(1 downto 0),
      SAXIHP0BVALID => S_AXI_HP0_BVALID,
      SAXIHP0RACOUNT(2 downto 0) => S_AXI_HP0_RACOUNT(2 downto 0),
      SAXIHP0RCOUNT(7 downto 0) => S_AXI_HP0_RCOUNT(7 downto 0),
      SAXIHP0RDATA(63 downto 0) => S_AXI_HP0_RDATA(63 downto 0),
      SAXIHP0RDISSUECAP1EN => S_AXI_HP0_RDISSUECAP1_EN,
      SAXIHP0RID(5 downto 0) => S_AXI_HP0_RID(5 downto 0),
      SAXIHP0RLAST => S_AXI_HP0_RLAST,
      SAXIHP0RREADY => S_AXI_HP0_RREADY,
      SAXIHP0RRESP(1 downto 0) => S_AXI_HP0_RRESP(1 downto 0),
      SAXIHP0RVALID => S_AXI_HP0_RVALID,
      SAXIHP0WACOUNT(5 downto 0) => S_AXI_HP0_WACOUNT(5 downto 0),
      SAXIHP0WCOUNT(7 downto 0) => S_AXI_HP0_WCOUNT(7 downto 0),
      SAXIHP0WDATA(63 downto 0) => S_AXI_HP0_WDATA(63 downto 0),
      SAXIHP0WID(5 downto 0) => S_AXI_HP0_WID(5 downto 0),
      SAXIHP0WLAST => S_AXI_HP0_WLAST,
      SAXIHP0WREADY => S_AXI_HP0_WREADY,
      SAXIHP0WRISSUECAP1EN => S_AXI_HP0_WRISSUECAP1_EN,
      SAXIHP0WSTRB(7 downto 0) => S_AXI_HP0_WSTRB(7 downto 0),
      SAXIHP0WVALID => S_AXI_HP0_WVALID,
      SAXIHP1ACLK => '0',
      SAXIHP1ARADDR(31 downto 0) => B"00000000000000000000000000000000",
      SAXIHP1ARBURST(1 downto 0) => B"00",
      SAXIHP1ARCACHE(3 downto 0) => B"0000",
      SAXIHP1ARESETN => PS7_i_n_131,
      SAXIHP1ARID(5 downto 0) => B"000000",
      SAXIHP1ARLEN(3 downto 0) => B"0000",
      SAXIHP1ARLOCK(1 downto 0) => B"00",
      SAXIHP1ARPROT(2 downto 0) => B"000",
      SAXIHP1ARQOS(3 downto 0) => B"0000",
      SAXIHP1ARREADY => PS7_i_n_132,
      SAXIHP1ARSIZE(1 downto 0) => B"00",
      SAXIHP1ARVALID => '0',
      SAXIHP1AWADDR(31 downto 0) => B"00000000000000000000000000000000",
      SAXIHP1AWBURST(1 downto 0) => B"00",
      SAXIHP1AWCACHE(3 downto 0) => B"0000",
      SAXIHP1AWID(5 downto 0) => B"000000",
      SAXIHP1AWLEN(3 downto 0) => B"0000",
      SAXIHP1AWLOCK(1 downto 0) => B"00",
      SAXIHP1AWPROT(2 downto 0) => B"000",
      SAXIHP1AWQOS(3 downto 0) => B"0000",
      SAXIHP1AWREADY => PS7_i_n_133,
      SAXIHP1AWSIZE(1 downto 0) => B"00",
      SAXIHP1AWVALID => '0',
      SAXIHP1BID(5) => PS7_i_n_819,
      SAXIHP1BID(4) => PS7_i_n_820,
      SAXIHP1BID(3) => PS7_i_n_821,
      SAXIHP1BID(2) => PS7_i_n_822,
      SAXIHP1BID(1) => PS7_i_n_823,
      SAXIHP1BID(0) => PS7_i_n_824,
      SAXIHP1BREADY => '0',
      SAXIHP1BRESP(1) => PS7_i_n_280,
      SAXIHP1BRESP(0) => PS7_i_n_281,
      SAXIHP1BVALID => PS7_i_n_134,
      SAXIHP1RACOUNT(2) => PS7_i_n_360,
      SAXIHP1RACOUNT(1) => PS7_i_n_361,
      SAXIHP1RACOUNT(0) => PS7_i_n_362,
      SAXIHP1RCOUNT(7) => PS7_i_n_1353,
      SAXIHP1RCOUNT(6) => PS7_i_n_1354,
      SAXIHP1RCOUNT(5) => PS7_i_n_1355,
      SAXIHP1RCOUNT(4) => PS7_i_n_1356,
      SAXIHP1RCOUNT(3) => PS7_i_n_1357,
      SAXIHP1RCOUNT(2) => PS7_i_n_1358,
      SAXIHP1RCOUNT(1) => PS7_i_n_1359,
      SAXIHP1RCOUNT(0) => PS7_i_n_1360,
      SAXIHP1RDATA(63) => PS7_i_n_1129,
      SAXIHP1RDATA(62) => PS7_i_n_1130,
      SAXIHP1RDATA(61) => PS7_i_n_1131,
      SAXIHP1RDATA(60) => PS7_i_n_1132,
      SAXIHP1RDATA(59) => PS7_i_n_1133,
      SAXIHP1RDATA(58) => PS7_i_n_1134,
      SAXIHP1RDATA(57) => PS7_i_n_1135,
      SAXIHP1RDATA(56) => PS7_i_n_1136,
      SAXIHP1RDATA(55) => PS7_i_n_1137,
      SAXIHP1RDATA(54) => PS7_i_n_1138,
      SAXIHP1RDATA(53) => PS7_i_n_1139,
      SAXIHP1RDATA(52) => PS7_i_n_1140,
      SAXIHP1RDATA(51) => PS7_i_n_1141,
      SAXIHP1RDATA(50) => PS7_i_n_1142,
      SAXIHP1RDATA(49) => PS7_i_n_1143,
      SAXIHP1RDATA(48) => PS7_i_n_1144,
      SAXIHP1RDATA(47) => PS7_i_n_1145,
      SAXIHP1RDATA(46) => PS7_i_n_1146,
      SAXIHP1RDATA(45) => PS7_i_n_1147,
      SAXIHP1RDATA(44) => PS7_i_n_1148,
      SAXIHP1RDATA(43) => PS7_i_n_1149,
      SAXIHP1RDATA(42) => PS7_i_n_1150,
      SAXIHP1RDATA(41) => PS7_i_n_1151,
      SAXIHP1RDATA(40) => PS7_i_n_1152,
      SAXIHP1RDATA(39) => PS7_i_n_1153,
      SAXIHP1RDATA(38) => PS7_i_n_1154,
      SAXIHP1RDATA(37) => PS7_i_n_1155,
      SAXIHP1RDATA(36) => PS7_i_n_1156,
      SAXIHP1RDATA(35) => PS7_i_n_1157,
      SAXIHP1RDATA(34) => PS7_i_n_1158,
      SAXIHP1RDATA(33) => PS7_i_n_1159,
      SAXIHP1RDATA(32) => PS7_i_n_1160,
      SAXIHP1RDATA(31) => PS7_i_n_1161,
      SAXIHP1RDATA(30) => PS7_i_n_1162,
      SAXIHP1RDATA(29) => PS7_i_n_1163,
      SAXIHP1RDATA(28) => PS7_i_n_1164,
      SAXIHP1RDATA(27) => PS7_i_n_1165,
      SAXIHP1RDATA(26) => PS7_i_n_1166,
      SAXIHP1RDATA(25) => PS7_i_n_1167,
      SAXIHP1RDATA(24) => PS7_i_n_1168,
      SAXIHP1RDATA(23) => PS7_i_n_1169,
      SAXIHP1RDATA(22) => PS7_i_n_1170,
      SAXIHP1RDATA(21) => PS7_i_n_1171,
      SAXIHP1RDATA(20) => PS7_i_n_1172,
      SAXIHP1RDATA(19) => PS7_i_n_1173,
      SAXIHP1RDATA(18) => PS7_i_n_1174,
      SAXIHP1RDATA(17) => PS7_i_n_1175,
      SAXIHP1RDATA(16) => PS7_i_n_1176,
      SAXIHP1RDATA(15) => PS7_i_n_1177,
      SAXIHP1RDATA(14) => PS7_i_n_1178,
      SAXIHP1RDATA(13) => PS7_i_n_1179,
      SAXIHP1RDATA(12) => PS7_i_n_1180,
      SAXIHP1RDATA(11) => PS7_i_n_1181,
      SAXIHP1RDATA(10) => PS7_i_n_1182,
      SAXIHP1RDATA(9) => PS7_i_n_1183,
      SAXIHP1RDATA(8) => PS7_i_n_1184,
      SAXIHP1RDATA(7) => PS7_i_n_1185,
      SAXIHP1RDATA(6) => PS7_i_n_1186,
      SAXIHP1RDATA(5) => PS7_i_n_1187,
      SAXIHP1RDATA(4) => PS7_i_n_1188,
      SAXIHP1RDATA(3) => PS7_i_n_1189,
      SAXIHP1RDATA(2) => PS7_i_n_1190,
      SAXIHP1RDATA(1) => PS7_i_n_1191,
      SAXIHP1RDATA(0) => PS7_i_n_1192,
      SAXIHP1RDISSUECAP1EN => '0',
      SAXIHP1RID(5) => PS7_i_n_825,
      SAXIHP1RID(4) => PS7_i_n_826,
      SAXIHP1RID(3) => PS7_i_n_827,
      SAXIHP1RID(2) => PS7_i_n_828,
      SAXIHP1RID(1) => PS7_i_n_829,
      SAXIHP1RID(0) => PS7_i_n_830,
      SAXIHP1RLAST => PS7_i_n_135,
      SAXIHP1RREADY => '0',
      SAXIHP1RRESP(1) => PS7_i_n_282,
      SAXIHP1RRESP(0) => PS7_i_n_283,
      SAXIHP1RVALID => PS7_i_n_136,
      SAXIHP1WACOUNT(5) => PS7_i_n_831,
      SAXIHP1WACOUNT(4) => PS7_i_n_832,
      SAXIHP1WACOUNT(3) => PS7_i_n_833,
      SAXIHP1WACOUNT(2) => PS7_i_n_834,
      SAXIHP1WACOUNT(1) => PS7_i_n_835,
      SAXIHP1WACOUNT(0) => PS7_i_n_836,
      SAXIHP1WCOUNT(7) => PS7_i_n_1361,
      SAXIHP1WCOUNT(6) => PS7_i_n_1362,
      SAXIHP1WCOUNT(5) => PS7_i_n_1363,
      SAXIHP1WCOUNT(4) => PS7_i_n_1364,
      SAXIHP1WCOUNT(3) => PS7_i_n_1365,
      SAXIHP1WCOUNT(2) => PS7_i_n_1366,
      SAXIHP1WCOUNT(1) => PS7_i_n_1367,
      SAXIHP1WCOUNT(0) => PS7_i_n_1368,
      SAXIHP1WDATA(63 downto 0) => B"0000000000000000000000000000000000000000000000000000000000000000",
      SAXIHP1WID(5 downto 0) => B"000000",
      SAXIHP1WLAST => '0',
      SAXIHP1WREADY => PS7_i_n_137,
      SAXIHP1WRISSUECAP1EN => '0',
      SAXIHP1WSTRB(7 downto 0) => B"00000000",
      SAXIHP1WVALID => '0',
      SAXIHP2ACLK => '0',
      SAXIHP2ARADDR(31 downto 0) => B"00000000000000000000000000000000",
      SAXIHP2ARBURST(1 downto 0) => B"00",
      SAXIHP2ARCACHE(3 downto 0) => B"0000",
      SAXIHP2ARESETN => PS7_i_n_138,
      SAXIHP2ARID(5 downto 0) => B"000000",
      SAXIHP2ARLEN(3 downto 0) => B"0000",
      SAXIHP2ARLOCK(1 downto 0) => B"00",
      SAXIHP2ARPROT(2 downto 0) => B"000",
      SAXIHP2ARQOS(3 downto 0) => B"0000",
      SAXIHP2ARREADY => PS7_i_n_139,
      SAXIHP2ARSIZE(1 downto 0) => B"00",
      SAXIHP2ARVALID => '0',
      SAXIHP2AWADDR(31 downto 0) => B"00000000000000000000000000000000",
      SAXIHP2AWBURST(1 downto 0) => B"00",
      SAXIHP2AWCACHE(3 downto 0) => B"0000",
      SAXIHP2AWID(5 downto 0) => B"000000",
      SAXIHP2AWLEN(3 downto 0) => B"0000",
      SAXIHP2AWLOCK(1 downto 0) => B"00",
      SAXIHP2AWPROT(2 downto 0) => B"000",
      SAXIHP2AWQOS(3 downto 0) => B"0000",
      SAXIHP2AWREADY => PS7_i_n_140,
      SAXIHP2AWSIZE(1 downto 0) => B"00",
      SAXIHP2AWVALID => '0',
      SAXIHP2BID(5) => PS7_i_n_837,
      SAXIHP2BID(4) => PS7_i_n_838,
      SAXIHP2BID(3) => PS7_i_n_839,
      SAXIHP2BID(2) => PS7_i_n_840,
      SAXIHP2BID(1) => PS7_i_n_841,
      SAXIHP2BID(0) => PS7_i_n_842,
      SAXIHP2BREADY => '0',
      SAXIHP2BRESP(1) => PS7_i_n_284,
      SAXIHP2BRESP(0) => PS7_i_n_285,
      SAXIHP2BVALID => PS7_i_n_141,
      SAXIHP2RACOUNT(2) => PS7_i_n_363,
      SAXIHP2RACOUNT(1) => PS7_i_n_364,
      SAXIHP2RACOUNT(0) => PS7_i_n_365,
      SAXIHP2RCOUNT(7) => PS7_i_n_1369,
      SAXIHP2RCOUNT(6) => PS7_i_n_1370,
      SAXIHP2RCOUNT(5) => PS7_i_n_1371,
      SAXIHP2RCOUNT(4) => PS7_i_n_1372,
      SAXIHP2RCOUNT(3) => PS7_i_n_1373,
      SAXIHP2RCOUNT(2) => PS7_i_n_1374,
      SAXIHP2RCOUNT(1) => PS7_i_n_1375,
      SAXIHP2RCOUNT(0) => PS7_i_n_1376,
      SAXIHP2RDATA(63) => PS7_i_n_1193,
      SAXIHP2RDATA(62) => PS7_i_n_1194,
      SAXIHP2RDATA(61) => PS7_i_n_1195,
      SAXIHP2RDATA(60) => PS7_i_n_1196,
      SAXIHP2RDATA(59) => PS7_i_n_1197,
      SAXIHP2RDATA(58) => PS7_i_n_1198,
      SAXIHP2RDATA(57) => PS7_i_n_1199,
      SAXIHP2RDATA(56) => PS7_i_n_1200,
      SAXIHP2RDATA(55) => PS7_i_n_1201,
      SAXIHP2RDATA(54) => PS7_i_n_1202,
      SAXIHP2RDATA(53) => PS7_i_n_1203,
      SAXIHP2RDATA(52) => PS7_i_n_1204,
      SAXIHP2RDATA(51) => PS7_i_n_1205,
      SAXIHP2RDATA(50) => PS7_i_n_1206,
      SAXIHP2RDATA(49) => PS7_i_n_1207,
      SAXIHP2RDATA(48) => PS7_i_n_1208,
      SAXIHP2RDATA(47) => PS7_i_n_1209,
      SAXIHP2RDATA(46) => PS7_i_n_1210,
      SAXIHP2RDATA(45) => PS7_i_n_1211,
      SAXIHP2RDATA(44) => PS7_i_n_1212,
      SAXIHP2RDATA(43) => PS7_i_n_1213,
      SAXIHP2RDATA(42) => PS7_i_n_1214,
      SAXIHP2RDATA(41) => PS7_i_n_1215,
      SAXIHP2RDATA(40) => PS7_i_n_1216,
      SAXIHP2RDATA(39) => PS7_i_n_1217,
      SAXIHP2RDATA(38) => PS7_i_n_1218,
      SAXIHP2RDATA(37) => PS7_i_n_1219,
      SAXIHP2RDATA(36) => PS7_i_n_1220,
      SAXIHP2RDATA(35) => PS7_i_n_1221,
      SAXIHP2RDATA(34) => PS7_i_n_1222,
      SAXIHP2RDATA(33) => PS7_i_n_1223,
      SAXIHP2RDATA(32) => PS7_i_n_1224,
      SAXIHP2RDATA(31) => PS7_i_n_1225,
      SAXIHP2RDATA(30) => PS7_i_n_1226,
      SAXIHP2RDATA(29) => PS7_i_n_1227,
      SAXIHP2RDATA(28) => PS7_i_n_1228,
      SAXIHP2RDATA(27) => PS7_i_n_1229,
      SAXIHP2RDATA(26) => PS7_i_n_1230,
      SAXIHP2RDATA(25) => PS7_i_n_1231,
      SAXIHP2RDATA(24) => PS7_i_n_1232,
      SAXIHP2RDATA(23) => PS7_i_n_1233,
      SAXIHP2RDATA(22) => PS7_i_n_1234,
      SAXIHP2RDATA(21) => PS7_i_n_1235,
      SAXIHP2RDATA(20) => PS7_i_n_1236,
      SAXIHP2RDATA(19) => PS7_i_n_1237,
      SAXIHP2RDATA(18) => PS7_i_n_1238,
      SAXIHP2RDATA(17) => PS7_i_n_1239,
      SAXIHP2RDATA(16) => PS7_i_n_1240,
      SAXIHP2RDATA(15) => PS7_i_n_1241,
      SAXIHP2RDATA(14) => PS7_i_n_1242,
      SAXIHP2RDATA(13) => PS7_i_n_1243,
      SAXIHP2RDATA(12) => PS7_i_n_1244,
      SAXIHP2RDATA(11) => PS7_i_n_1245,
      SAXIHP2RDATA(10) => PS7_i_n_1246,
      SAXIHP2RDATA(9) => PS7_i_n_1247,
      SAXIHP2RDATA(8) => PS7_i_n_1248,
      SAXIHP2RDATA(7) => PS7_i_n_1249,
      SAXIHP2RDATA(6) => PS7_i_n_1250,
      SAXIHP2RDATA(5) => PS7_i_n_1251,
      SAXIHP2RDATA(4) => PS7_i_n_1252,
      SAXIHP2RDATA(3) => PS7_i_n_1253,
      SAXIHP2RDATA(2) => PS7_i_n_1254,
      SAXIHP2RDATA(1) => PS7_i_n_1255,
      SAXIHP2RDATA(0) => PS7_i_n_1256,
      SAXIHP2RDISSUECAP1EN => '0',
      SAXIHP2RID(5) => PS7_i_n_843,
      SAXIHP2RID(4) => PS7_i_n_844,
      SAXIHP2RID(3) => PS7_i_n_845,
      SAXIHP2RID(2) => PS7_i_n_846,
      SAXIHP2RID(1) => PS7_i_n_847,
      SAXIHP2RID(0) => PS7_i_n_848,
      SAXIHP2RLAST => PS7_i_n_142,
      SAXIHP2RREADY => '0',
      SAXIHP2RRESP(1) => PS7_i_n_286,
      SAXIHP2RRESP(0) => PS7_i_n_287,
      SAXIHP2RVALID => PS7_i_n_143,
      SAXIHP2WACOUNT(5) => PS7_i_n_849,
      SAXIHP2WACOUNT(4) => PS7_i_n_850,
      SAXIHP2WACOUNT(3) => PS7_i_n_851,
      SAXIHP2WACOUNT(2) => PS7_i_n_852,
      SAXIHP2WACOUNT(1) => PS7_i_n_853,
      SAXIHP2WACOUNT(0) => PS7_i_n_854,
      SAXIHP2WCOUNT(7) => PS7_i_n_1377,
      SAXIHP2WCOUNT(6) => PS7_i_n_1378,
      SAXIHP2WCOUNT(5) => PS7_i_n_1379,
      SAXIHP2WCOUNT(4) => PS7_i_n_1380,
      SAXIHP2WCOUNT(3) => PS7_i_n_1381,
      SAXIHP2WCOUNT(2) => PS7_i_n_1382,
      SAXIHP2WCOUNT(1) => PS7_i_n_1383,
      SAXIHP2WCOUNT(0) => PS7_i_n_1384,
      SAXIHP2WDATA(63 downto 0) => B"0000000000000000000000000000000000000000000000000000000000000000",
      SAXIHP2WID(5 downto 0) => B"000000",
      SAXIHP2WLAST => '0',
      SAXIHP2WREADY => PS7_i_n_144,
      SAXIHP2WRISSUECAP1EN => '0',
      SAXIHP2WSTRB(7 downto 0) => B"00000000",
      SAXIHP2WVALID => '0',
      SAXIHP3ACLK => '0',
      SAXIHP3ARADDR(31 downto 0) => B"00000000000000000000000000000000",
      SAXIHP3ARBURST(1 downto 0) => B"00",
      SAXIHP3ARCACHE(3 downto 0) => B"0000",
      SAXIHP3ARESETN => PS7_i_n_145,
      SAXIHP3ARID(5 downto 0) => B"000000",
      SAXIHP3ARLEN(3 downto 0) => B"0000",
      SAXIHP3ARLOCK(1 downto 0) => B"00",
      SAXIHP3ARPROT(2 downto 0) => B"000",
      SAXIHP3ARQOS(3 downto 0) => B"0000",
      SAXIHP3ARREADY => PS7_i_n_146,
      SAXIHP3ARSIZE(1 downto 0) => B"00",
      SAXIHP3ARVALID => '0',
      SAXIHP3AWADDR(31 downto 0) => B"00000000000000000000000000000000",
      SAXIHP3AWBURST(1 downto 0) => B"00",
      SAXIHP3AWCACHE(3 downto 0) => B"0000",
      SAXIHP3AWID(5 downto 0) => B"000000",
      SAXIHP3AWLEN(3 downto 0) => B"0000",
      SAXIHP3AWLOCK(1 downto 0) => B"00",
      SAXIHP3AWPROT(2 downto 0) => B"000",
      SAXIHP3AWQOS(3 downto 0) => B"0000",
      SAXIHP3AWREADY => PS7_i_n_147,
      SAXIHP3AWSIZE(1 downto 0) => B"00",
      SAXIHP3AWVALID => '0',
      SAXIHP3BID(5) => PS7_i_n_855,
      SAXIHP3BID(4) => PS7_i_n_856,
      SAXIHP3BID(3) => PS7_i_n_857,
      SAXIHP3BID(2) => PS7_i_n_858,
      SAXIHP3BID(1) => PS7_i_n_859,
      SAXIHP3BID(0) => PS7_i_n_860,
      SAXIHP3BREADY => '0',
      SAXIHP3BRESP(1) => PS7_i_n_288,
      SAXIHP3BRESP(0) => PS7_i_n_289,
      SAXIHP3BVALID => PS7_i_n_148,
      SAXIHP3RACOUNT(2) => PS7_i_n_366,
      SAXIHP3RACOUNT(1) => PS7_i_n_367,
      SAXIHP3RACOUNT(0) => PS7_i_n_368,
      SAXIHP3RCOUNT(7) => PS7_i_n_1385,
      SAXIHP3RCOUNT(6) => PS7_i_n_1386,
      SAXIHP3RCOUNT(5) => PS7_i_n_1387,
      SAXIHP3RCOUNT(4) => PS7_i_n_1388,
      SAXIHP3RCOUNT(3) => PS7_i_n_1389,
      SAXIHP3RCOUNT(2) => PS7_i_n_1390,
      SAXIHP3RCOUNT(1) => PS7_i_n_1391,
      SAXIHP3RCOUNT(0) => PS7_i_n_1392,
      SAXIHP3RDATA(63) => PS7_i_n_1257,
      SAXIHP3RDATA(62) => PS7_i_n_1258,
      SAXIHP3RDATA(61) => PS7_i_n_1259,
      SAXIHP3RDATA(60) => PS7_i_n_1260,
      SAXIHP3RDATA(59) => PS7_i_n_1261,
      SAXIHP3RDATA(58) => PS7_i_n_1262,
      SAXIHP3RDATA(57) => PS7_i_n_1263,
      SAXIHP3RDATA(56) => PS7_i_n_1264,
      SAXIHP3RDATA(55) => PS7_i_n_1265,
      SAXIHP3RDATA(54) => PS7_i_n_1266,
      SAXIHP3RDATA(53) => PS7_i_n_1267,
      SAXIHP3RDATA(52) => PS7_i_n_1268,
      SAXIHP3RDATA(51) => PS7_i_n_1269,
      SAXIHP3RDATA(50) => PS7_i_n_1270,
      SAXIHP3RDATA(49) => PS7_i_n_1271,
      SAXIHP3RDATA(48) => PS7_i_n_1272,
      SAXIHP3RDATA(47) => PS7_i_n_1273,
      SAXIHP3RDATA(46) => PS7_i_n_1274,
      SAXIHP3RDATA(45) => PS7_i_n_1275,
      SAXIHP3RDATA(44) => PS7_i_n_1276,
      SAXIHP3RDATA(43) => PS7_i_n_1277,
      SAXIHP3RDATA(42) => PS7_i_n_1278,
      SAXIHP3RDATA(41) => PS7_i_n_1279,
      SAXIHP3RDATA(40) => PS7_i_n_1280,
      SAXIHP3RDATA(39) => PS7_i_n_1281,
      SAXIHP3RDATA(38) => PS7_i_n_1282,
      SAXIHP3RDATA(37) => PS7_i_n_1283,
      SAXIHP3RDATA(36) => PS7_i_n_1284,
      SAXIHP3RDATA(35) => PS7_i_n_1285,
      SAXIHP3RDATA(34) => PS7_i_n_1286,
      SAXIHP3RDATA(33) => PS7_i_n_1287,
      SAXIHP3RDATA(32) => PS7_i_n_1288,
      SAXIHP3RDATA(31) => PS7_i_n_1289,
      SAXIHP3RDATA(30) => PS7_i_n_1290,
      SAXIHP3RDATA(29) => PS7_i_n_1291,
      SAXIHP3RDATA(28) => PS7_i_n_1292,
      SAXIHP3RDATA(27) => PS7_i_n_1293,
      SAXIHP3RDATA(26) => PS7_i_n_1294,
      SAXIHP3RDATA(25) => PS7_i_n_1295,
      SAXIHP3RDATA(24) => PS7_i_n_1296,
      SAXIHP3RDATA(23) => PS7_i_n_1297,
      SAXIHP3RDATA(22) => PS7_i_n_1298,
      SAXIHP3RDATA(21) => PS7_i_n_1299,
      SAXIHP3RDATA(20) => PS7_i_n_1300,
      SAXIHP3RDATA(19) => PS7_i_n_1301,
      SAXIHP3RDATA(18) => PS7_i_n_1302,
      SAXIHP3RDATA(17) => PS7_i_n_1303,
      SAXIHP3RDATA(16) => PS7_i_n_1304,
      SAXIHP3RDATA(15) => PS7_i_n_1305,
      SAXIHP3RDATA(14) => PS7_i_n_1306,
      SAXIHP3RDATA(13) => PS7_i_n_1307,
      SAXIHP3RDATA(12) => PS7_i_n_1308,
      SAXIHP3RDATA(11) => PS7_i_n_1309,
      SAXIHP3RDATA(10) => PS7_i_n_1310,
      SAXIHP3RDATA(9) => PS7_i_n_1311,
      SAXIHP3RDATA(8) => PS7_i_n_1312,
      SAXIHP3RDATA(7) => PS7_i_n_1313,
      SAXIHP3RDATA(6) => PS7_i_n_1314,
      SAXIHP3RDATA(5) => PS7_i_n_1315,
      SAXIHP3RDATA(4) => PS7_i_n_1316,
      SAXIHP3RDATA(3) => PS7_i_n_1317,
      SAXIHP3RDATA(2) => PS7_i_n_1318,
      SAXIHP3RDATA(1) => PS7_i_n_1319,
      SAXIHP3RDATA(0) => PS7_i_n_1320,
      SAXIHP3RDISSUECAP1EN => '0',
      SAXIHP3RID(5) => PS7_i_n_861,
      SAXIHP3RID(4) => PS7_i_n_862,
      SAXIHP3RID(3) => PS7_i_n_863,
      SAXIHP3RID(2) => PS7_i_n_864,
      SAXIHP3RID(1) => PS7_i_n_865,
      SAXIHP3RID(0) => PS7_i_n_866,
      SAXIHP3RLAST => PS7_i_n_149,
      SAXIHP3RREADY => '0',
      SAXIHP3RRESP(1) => PS7_i_n_290,
      SAXIHP3RRESP(0) => PS7_i_n_291,
      SAXIHP3RVALID => PS7_i_n_150,
      SAXIHP3WACOUNT(5) => PS7_i_n_867,
      SAXIHP3WACOUNT(4) => PS7_i_n_868,
      SAXIHP3WACOUNT(3) => PS7_i_n_869,
      SAXIHP3WACOUNT(2) => PS7_i_n_870,
      SAXIHP3WACOUNT(1) => PS7_i_n_871,
      SAXIHP3WACOUNT(0) => PS7_i_n_872,
      SAXIHP3WCOUNT(7) => PS7_i_n_1393,
      SAXIHP3WCOUNT(6) => PS7_i_n_1394,
      SAXIHP3WCOUNT(5) => PS7_i_n_1395,
      SAXIHP3WCOUNT(4) => PS7_i_n_1396,
      SAXIHP3WCOUNT(3) => PS7_i_n_1397,
      SAXIHP3WCOUNT(2) => PS7_i_n_1398,
      SAXIHP3WCOUNT(1) => PS7_i_n_1399,
      SAXIHP3WCOUNT(0) => PS7_i_n_1400,
      SAXIHP3WDATA(63 downto 0) => B"0000000000000000000000000000000000000000000000000000000000000000",
      SAXIHP3WID(5 downto 0) => B"000000",
      SAXIHP3WLAST => '0',
      SAXIHP3WREADY => PS7_i_n_151,
      SAXIHP3WRISSUECAP1EN => '0',
      SAXIHP3WSTRB(7 downto 0) => B"00000000",
      SAXIHP3WVALID => '0'
    );
PS_CLK_BIBUF: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_PS_CLK,
      PAD => PS_CLK
    );
PS_PORB_BIBUF: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_PS_PORB,
      PAD => PS_PORB
    );
PS_SRSTB_BIBUF: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_PS_SRSTB,
      PAD => PS_SRSTB
    );
\genblk13[0].MIO_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_MIO(0),
      PAD => MIO(0)
    );
\genblk13[10].MIO_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_MIO(10),
      PAD => MIO(10)
    );
\genblk13[11].MIO_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_MIO(11),
      PAD => MIO(11)
    );
\genblk13[12].MIO_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_MIO(12),
      PAD => MIO(12)
    );
\genblk13[13].MIO_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_MIO(13),
      PAD => MIO(13)
    );
\genblk13[14].MIO_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_MIO(14),
      PAD => MIO(14)
    );
\genblk13[15].MIO_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_MIO(15),
      PAD => MIO(15)
    );
\genblk13[16].MIO_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_MIO(16),
      PAD => MIO(16)
    );
\genblk13[17].MIO_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_MIO(17),
      PAD => MIO(17)
    );
\genblk13[18].MIO_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_MIO(18),
      PAD => MIO(18)
    );
\genblk13[19].MIO_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_MIO(19),
      PAD => MIO(19)
    );
\genblk13[1].MIO_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_MIO(1),
      PAD => MIO(1)
    );
\genblk13[20].MIO_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_MIO(20),
      PAD => MIO(20)
    );
\genblk13[21].MIO_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_MIO(21),
      PAD => MIO(21)
    );
\genblk13[22].MIO_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_MIO(22),
      PAD => MIO(22)
    );
\genblk13[23].MIO_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_MIO(23),
      PAD => MIO(23)
    );
\genblk13[24].MIO_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_MIO(24),
      PAD => MIO(24)
    );
\genblk13[25].MIO_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_MIO(25),
      PAD => MIO(25)
    );
\genblk13[26].MIO_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_MIO(26),
      PAD => MIO(26)
    );
\genblk13[27].MIO_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_MIO(27),
      PAD => MIO(27)
    );
\genblk13[28].MIO_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_MIO(28),
      PAD => MIO(28)
    );
\genblk13[29].MIO_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_MIO(29),
      PAD => MIO(29)
    );
\genblk13[2].MIO_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_MIO(2),
      PAD => MIO(2)
    );
\genblk13[30].MIO_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_MIO(30),
      PAD => MIO(30)
    );
\genblk13[31].MIO_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_MIO(31),
      PAD => MIO(31)
    );
\genblk13[32].MIO_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_MIO(32),
      PAD => MIO(32)
    );
\genblk13[33].MIO_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_MIO(33),
      PAD => MIO(33)
    );
\genblk13[34].MIO_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_MIO(34),
      PAD => MIO(34)
    );
\genblk13[35].MIO_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_MIO(35),
      PAD => MIO(35)
    );
\genblk13[36].MIO_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_MIO(36),
      PAD => MIO(36)
    );
\genblk13[37].MIO_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_MIO(37),
      PAD => MIO(37)
    );
\genblk13[38].MIO_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_MIO(38),
      PAD => MIO(38)
    );
\genblk13[39].MIO_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_MIO(39),
      PAD => MIO(39)
    );
\genblk13[3].MIO_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_MIO(3),
      PAD => MIO(3)
    );
\genblk13[40].MIO_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_MIO(40),
      PAD => MIO(40)
    );
\genblk13[41].MIO_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_MIO(41),
      PAD => MIO(41)
    );
\genblk13[42].MIO_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_MIO(42),
      PAD => MIO(42)
    );
\genblk13[43].MIO_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_MIO(43),
      PAD => MIO(43)
    );
\genblk13[44].MIO_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_MIO(44),
      PAD => MIO(44)
    );
\genblk13[45].MIO_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_MIO(45),
      PAD => MIO(45)
    );
\genblk13[46].MIO_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_MIO(46),
      PAD => MIO(46)
    );
\genblk13[47].MIO_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_MIO(47),
      PAD => MIO(47)
    );
\genblk13[48].MIO_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_MIO(48),
      PAD => MIO(48)
    );
\genblk13[49].MIO_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_MIO(49),
      PAD => MIO(49)
    );
\genblk13[4].MIO_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_MIO(4),
      PAD => MIO(4)
    );
\genblk13[50].MIO_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_MIO(50),
      PAD => MIO(50)
    );
\genblk13[51].MIO_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_MIO(51),
      PAD => MIO(51)
    );
\genblk13[52].MIO_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_MIO(52),
      PAD => MIO(52)
    );
\genblk13[53].MIO_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_MIO(53),
      PAD => MIO(53)
    );
\genblk13[5].MIO_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_MIO(5),
      PAD => MIO(5)
    );
\genblk13[6].MIO_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_MIO(6),
      PAD => MIO(6)
    );
\genblk13[7].MIO_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_MIO(7),
      PAD => MIO(7)
    );
\genblk13[8].MIO_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_MIO(8),
      PAD => MIO(8)
    );
\genblk13[9].MIO_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_MIO(9),
      PAD => MIO(9)
    );
\genblk14[0].DDR_BankAddr_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_DDR_BankAddr(0),
      PAD => DDR_BankAddr(0)
    );
\genblk14[1].DDR_BankAddr_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_DDR_BankAddr(1),
      PAD => DDR_BankAddr(1)
    );
\genblk14[2].DDR_BankAddr_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_DDR_BankAddr(2),
      PAD => DDR_BankAddr(2)
    );
\genblk15[0].DDR_Addr_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_DDR_Addr(0),
      PAD => DDR_Addr(0)
    );
\genblk15[10].DDR_Addr_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_DDR_Addr(10),
      PAD => DDR_Addr(10)
    );
\genblk15[11].DDR_Addr_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_DDR_Addr(11),
      PAD => DDR_Addr(11)
    );
\genblk15[12].DDR_Addr_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_DDR_Addr(12),
      PAD => DDR_Addr(12)
    );
\genblk15[13].DDR_Addr_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_DDR_Addr(13),
      PAD => DDR_Addr(13)
    );
\genblk15[14].DDR_Addr_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_DDR_Addr(14),
      PAD => DDR_Addr(14)
    );
\genblk15[1].DDR_Addr_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_DDR_Addr(1),
      PAD => DDR_Addr(1)
    );
\genblk15[2].DDR_Addr_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_DDR_Addr(2),
      PAD => DDR_Addr(2)
    );
\genblk15[3].DDR_Addr_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_DDR_Addr(3),
      PAD => DDR_Addr(3)
    );
\genblk15[4].DDR_Addr_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_DDR_Addr(4),
      PAD => DDR_Addr(4)
    );
\genblk15[5].DDR_Addr_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_DDR_Addr(5),
      PAD => DDR_Addr(5)
    );
\genblk15[6].DDR_Addr_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_DDR_Addr(6),
      PAD => DDR_Addr(6)
    );
\genblk15[7].DDR_Addr_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_DDR_Addr(7),
      PAD => DDR_Addr(7)
    );
\genblk15[8].DDR_Addr_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_DDR_Addr(8),
      PAD => DDR_Addr(8)
    );
\genblk15[9].DDR_Addr_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_DDR_Addr(9),
      PAD => DDR_Addr(9)
    );
\genblk16[0].DDR_DM_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_DDR_DM(0),
      PAD => DDR_DM(0)
    );
\genblk16[1].DDR_DM_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_DDR_DM(1),
      PAD => DDR_DM(1)
    );
\genblk16[2].DDR_DM_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_DDR_DM(2),
      PAD => DDR_DM(2)
    );
\genblk16[3].DDR_DM_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_DDR_DM(3),
      PAD => DDR_DM(3)
    );
\genblk17[0].DDR_DQ_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_DDR_DQ(0),
      PAD => DDR_DQ(0)
    );
\genblk17[10].DDR_DQ_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_DDR_DQ(10),
      PAD => DDR_DQ(10)
    );
\genblk17[11].DDR_DQ_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_DDR_DQ(11),
      PAD => DDR_DQ(11)
    );
\genblk17[12].DDR_DQ_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_DDR_DQ(12),
      PAD => DDR_DQ(12)
    );
\genblk17[13].DDR_DQ_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_DDR_DQ(13),
      PAD => DDR_DQ(13)
    );
\genblk17[14].DDR_DQ_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_DDR_DQ(14),
      PAD => DDR_DQ(14)
    );
\genblk17[15].DDR_DQ_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_DDR_DQ(15),
      PAD => DDR_DQ(15)
    );
\genblk17[16].DDR_DQ_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_DDR_DQ(16),
      PAD => DDR_DQ(16)
    );
\genblk17[17].DDR_DQ_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_DDR_DQ(17),
      PAD => DDR_DQ(17)
    );
\genblk17[18].DDR_DQ_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_DDR_DQ(18),
      PAD => DDR_DQ(18)
    );
\genblk17[19].DDR_DQ_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_DDR_DQ(19),
      PAD => DDR_DQ(19)
    );
\genblk17[1].DDR_DQ_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_DDR_DQ(1),
      PAD => DDR_DQ(1)
    );
\genblk17[20].DDR_DQ_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_DDR_DQ(20),
      PAD => DDR_DQ(20)
    );
\genblk17[21].DDR_DQ_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_DDR_DQ(21),
      PAD => DDR_DQ(21)
    );
\genblk17[22].DDR_DQ_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_DDR_DQ(22),
      PAD => DDR_DQ(22)
    );
\genblk17[23].DDR_DQ_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_DDR_DQ(23),
      PAD => DDR_DQ(23)
    );
\genblk17[24].DDR_DQ_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_DDR_DQ(24),
      PAD => DDR_DQ(24)
    );
\genblk17[25].DDR_DQ_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_DDR_DQ(25),
      PAD => DDR_DQ(25)
    );
\genblk17[26].DDR_DQ_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_DDR_DQ(26),
      PAD => DDR_DQ(26)
    );
\genblk17[27].DDR_DQ_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_DDR_DQ(27),
      PAD => DDR_DQ(27)
    );
\genblk17[28].DDR_DQ_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_DDR_DQ(28),
      PAD => DDR_DQ(28)
    );
\genblk17[29].DDR_DQ_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_DDR_DQ(29),
      PAD => DDR_DQ(29)
    );
\genblk17[2].DDR_DQ_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_DDR_DQ(2),
      PAD => DDR_DQ(2)
    );
\genblk17[30].DDR_DQ_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_DDR_DQ(30),
      PAD => DDR_DQ(30)
    );
\genblk17[31].DDR_DQ_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_DDR_DQ(31),
      PAD => DDR_DQ(31)
    );
\genblk17[3].DDR_DQ_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_DDR_DQ(3),
      PAD => DDR_DQ(3)
    );
\genblk17[4].DDR_DQ_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_DDR_DQ(4),
      PAD => DDR_DQ(4)
    );
\genblk17[5].DDR_DQ_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_DDR_DQ(5),
      PAD => DDR_DQ(5)
    );
\genblk17[6].DDR_DQ_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_DDR_DQ(6),
      PAD => DDR_DQ(6)
    );
\genblk17[7].DDR_DQ_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_DDR_DQ(7),
      PAD => DDR_DQ(7)
    );
\genblk17[8].DDR_DQ_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_DDR_DQ(8),
      PAD => DDR_DQ(8)
    );
\genblk17[9].DDR_DQ_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_DDR_DQ(9),
      PAD => DDR_DQ(9)
    );
\genblk18[0].DDR_DQS_n_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_DDR_DQS_n(0),
      PAD => DDR_DQS_n(0)
    );
\genblk18[1].DDR_DQS_n_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_DDR_DQS_n(1),
      PAD => DDR_DQS_n(1)
    );
\genblk18[2].DDR_DQS_n_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_DDR_DQS_n(2),
      PAD => DDR_DQS_n(2)
    );
\genblk18[3].DDR_DQS_n_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_DDR_DQS_n(3),
      PAD => DDR_DQS_n(3)
    );
\genblk19[0].DDR_DQS_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_DDR_DQS(0),
      PAD => DDR_DQS(0)
    );
\genblk19[1].DDR_DQS_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_DDR_DQS(1),
      PAD => DDR_DQS(1)
    );
\genblk19[2].DDR_DQS_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_DDR_DQS(2),
      PAD => DDR_DQS(2)
    );
\genblk19[3].DDR_DQS_BIBUF\: unisim.vcomponents.BIBUF
     port map (
      IO => buffered_DDR_DQS(3),
      PAD => DDR_DQS(3)
    );
i_0: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \TRACE_CTL_PIPE[0]\
    );
i_1: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \TRACE_DATA_PIPE[0]\(1)
    );
i_10: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \TRACE_DATA_PIPE[7]\(1)
    );
i_11: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \TRACE_DATA_PIPE[7]\(0)
    );
i_12: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \TRACE_DATA_PIPE[6]\(1)
    );
i_13: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \TRACE_DATA_PIPE[6]\(0)
    );
i_14: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \TRACE_DATA_PIPE[5]\(1)
    );
i_15: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \TRACE_DATA_PIPE[5]\(0)
    );
i_16: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \TRACE_DATA_PIPE[4]\(1)
    );
i_17: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \TRACE_DATA_PIPE[4]\(0)
    );
i_18: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \TRACE_DATA_PIPE[3]\(1)
    );
i_19: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \TRACE_DATA_PIPE[3]\(0)
    );
i_2: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \TRACE_DATA_PIPE[0]\(0)
    );
i_20: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \TRACE_DATA_PIPE[2]\(1)
    );
i_21: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \TRACE_DATA_PIPE[2]\(0)
    );
i_22: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \TRACE_DATA_PIPE[1]\(1)
    );
i_23: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \TRACE_DATA_PIPE[1]\(0)
    );
i_3: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \TRACE_CTL_PIPE[7]\
    );
i_4: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \TRACE_CTL_PIPE[6]\
    );
i_5: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \TRACE_CTL_PIPE[5]\
    );
i_6: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \TRACE_CTL_PIPE[4]\
    );
i_7: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \TRACE_CTL_PIPE[3]\
    );
i_8: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \TRACE_CTL_PIPE[2]\
    );
i_9: unisim.vcomponents.LUT1
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => '0',
      O => \TRACE_CTL_PIPE[1]\
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity ps_system_processing_system7_0_0 is
  port (
    S_AXI_HP0_ARREADY : out STD_LOGIC;
    S_AXI_HP0_AWREADY : out STD_LOGIC;
    S_AXI_HP0_BVALID : out STD_LOGIC;
    S_AXI_HP0_RLAST : out STD_LOGIC;
    S_AXI_HP0_RVALID : out STD_LOGIC;
    S_AXI_HP0_WREADY : out STD_LOGIC;
    S_AXI_HP0_BRESP : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S_AXI_HP0_RRESP : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S_AXI_HP0_BID : out STD_LOGIC_VECTOR ( 5 downto 0 );
    S_AXI_HP0_RID : out STD_LOGIC_VECTOR ( 5 downto 0 );
    S_AXI_HP0_RDATA : out STD_LOGIC_VECTOR ( 63 downto 0 );
    S_AXI_HP0_RCOUNT : out STD_LOGIC_VECTOR ( 7 downto 0 );
    S_AXI_HP0_WCOUNT : out STD_LOGIC_VECTOR ( 7 downto 0 );
    S_AXI_HP0_RACOUNT : out STD_LOGIC_VECTOR ( 2 downto 0 );
    S_AXI_HP0_WACOUNT : out STD_LOGIC_VECTOR ( 5 downto 0 );
    S_AXI_HP0_ACLK : in STD_LOGIC;
    S_AXI_HP0_ARVALID : in STD_LOGIC;
    S_AXI_HP0_AWVALID : in STD_LOGIC;
    S_AXI_HP0_BREADY : in STD_LOGIC;
    S_AXI_HP0_RDISSUECAP1_EN : in STD_LOGIC;
    S_AXI_HP0_RREADY : in STD_LOGIC;
    S_AXI_HP0_WLAST : in STD_LOGIC;
    S_AXI_HP0_WRISSUECAP1_EN : in STD_LOGIC;
    S_AXI_HP0_WVALID : in STD_LOGIC;
    S_AXI_HP0_ARBURST : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S_AXI_HP0_ARLOCK : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S_AXI_HP0_ARSIZE : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S_AXI_HP0_AWBURST : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S_AXI_HP0_AWLOCK : in STD_LOGIC_VECTOR ( 1 downto 0 );
    S_AXI_HP0_AWSIZE : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S_AXI_HP0_ARPROT : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S_AXI_HP0_AWPROT : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S_AXI_HP0_ARADDR : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S_AXI_HP0_AWADDR : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S_AXI_HP0_ARCACHE : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AXI_HP0_ARLEN : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AXI_HP0_ARQOS : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AXI_HP0_AWCACHE : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AXI_HP0_AWLEN : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AXI_HP0_AWQOS : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AXI_HP0_ARID : in STD_LOGIC_VECTOR ( 5 downto 0 );
    S_AXI_HP0_AWID : in STD_LOGIC_VECTOR ( 5 downto 0 );
    S_AXI_HP0_WID : in STD_LOGIC_VECTOR ( 5 downto 0 );
    S_AXI_HP0_WDATA : in STD_LOGIC_VECTOR ( 63 downto 0 );
    S_AXI_HP0_WSTRB : in STD_LOGIC_VECTOR ( 7 downto 0 );
    FCLK_CLK0 : out STD_LOGIC;
    FCLK_RESET0_N : out STD_LOGIC;
    MIO : inout STD_LOGIC_VECTOR ( 53 downto 0 );
    DDR_CAS_n : inout STD_LOGIC;
    DDR_CKE : inout STD_LOGIC;
    DDR_Clk_n : inout STD_LOGIC;
    DDR_Clk : inout STD_LOGIC;
    DDR_CS_n : inout STD_LOGIC;
    DDR_DRSTB : inout STD_LOGIC;
    DDR_ODT : inout STD_LOGIC;
    DDR_RAS_n : inout STD_LOGIC;
    DDR_WEB : inout STD_LOGIC;
    DDR_BankAddr : inout STD_LOGIC_VECTOR ( 2 downto 0 );
    DDR_Addr : inout STD_LOGIC_VECTOR ( 14 downto 0 );
    DDR_VRN : inout STD_LOGIC;
    DDR_VRP : inout STD_LOGIC;
    DDR_DM : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_DQ : inout STD_LOGIC_VECTOR ( 31 downto 0 );
    DDR_DQS_n : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    DDR_DQS : inout STD_LOGIC_VECTOR ( 3 downto 0 );
    PS_SRSTB : inout STD_LOGIC;
    PS_CLK : inout STD_LOGIC;
    PS_PORB : inout STD_LOGIC
  );
  attribute NotValidForBitStream : boolean;
  attribute NotValidForBitStream of ps_system_processing_system7_0_0 : entity is true;
  attribute CHECK_LICENSE_TYPE : string;
  attribute CHECK_LICENSE_TYPE of ps_system_processing_system7_0_0 : entity is "ps_system_processing_system7_0_0,processing_system7_v5_5_processing_system7,{}";
  attribute DowngradeIPIdentifiedWarnings : string;
  attribute DowngradeIPIdentifiedWarnings of ps_system_processing_system7_0_0 : entity is "yes";
  attribute X_CORE_INFO : string;
  attribute X_CORE_INFO of ps_system_processing_system7_0_0 : entity is "processing_system7_v5_5_processing_system7,Vivado 2020.2";
end ps_system_processing_system7_0_0;

architecture STRUCTURE of ps_system_processing_system7_0_0 is
  signal NLW_inst_CAN0_PHY_TX_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_CAN1_PHY_TX_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_DMA0_DAVALID_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_DMA0_DRREADY_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_DMA0_RSTN_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_DMA1_DAVALID_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_DMA1_DRREADY_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_DMA1_RSTN_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_DMA2_DAVALID_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_DMA2_DRREADY_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_DMA2_RSTN_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_DMA3_DAVALID_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_DMA3_DRREADY_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_DMA3_RSTN_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ENET0_GMII_TX_EN_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ENET0_GMII_TX_ER_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ENET0_MDIO_MDC_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ENET0_MDIO_O_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ENET0_MDIO_T_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ENET0_PTP_DELAY_REQ_RX_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ENET0_PTP_DELAY_REQ_TX_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ENET0_PTP_PDELAY_REQ_RX_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ENET0_PTP_PDELAY_REQ_TX_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ENET0_PTP_PDELAY_RESP_RX_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ENET0_PTP_PDELAY_RESP_TX_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ENET0_PTP_SYNC_FRAME_RX_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ENET0_PTP_SYNC_FRAME_TX_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ENET0_SOF_RX_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ENET0_SOF_TX_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ENET1_GMII_TX_EN_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ENET1_GMII_TX_ER_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ENET1_MDIO_MDC_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ENET1_MDIO_O_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ENET1_MDIO_T_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ENET1_PTP_DELAY_REQ_RX_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ENET1_PTP_DELAY_REQ_TX_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ENET1_PTP_PDELAY_REQ_RX_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ENET1_PTP_PDELAY_REQ_TX_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ENET1_PTP_PDELAY_RESP_RX_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ENET1_PTP_PDELAY_RESP_TX_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ENET1_PTP_SYNC_FRAME_RX_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ENET1_PTP_SYNC_FRAME_TX_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ENET1_SOF_RX_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_ENET1_SOF_TX_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_EVENT_EVENTO_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_FCLK_CLK1_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_FCLK_CLK2_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_FCLK_CLK3_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_FCLK_RESET1_N_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_FCLK_RESET2_N_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_FCLK_RESET3_N_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_FTMT_F2P_TRIGACK_0_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_FTMT_F2P_TRIGACK_1_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_FTMT_F2P_TRIGACK_2_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_FTMT_F2P_TRIGACK_3_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_FTMT_P2F_TRIG_0_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_FTMT_P2F_TRIG_1_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_FTMT_P2F_TRIG_2_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_FTMT_P2F_TRIG_3_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_I2C0_SCL_O_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_I2C0_SCL_T_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_I2C0_SDA_O_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_I2C0_SDA_T_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_I2C1_SCL_O_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_I2C1_SCL_T_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_I2C1_SDA_O_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_I2C1_SDA_T_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_IRQ_P2F_CAN0_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_IRQ_P2F_CAN1_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_IRQ_P2F_CTI_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_IRQ_P2F_DMAC0_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_IRQ_P2F_DMAC1_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_IRQ_P2F_DMAC2_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_IRQ_P2F_DMAC3_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_IRQ_P2F_DMAC4_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_IRQ_P2F_DMAC5_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_IRQ_P2F_DMAC6_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_IRQ_P2F_DMAC7_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_IRQ_P2F_DMAC_ABORT_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_IRQ_P2F_ENET0_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_IRQ_P2F_ENET1_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_IRQ_P2F_ENET_WAKE0_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_IRQ_P2F_ENET_WAKE1_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_IRQ_P2F_GPIO_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_IRQ_P2F_I2C0_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_IRQ_P2F_I2C1_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_IRQ_P2F_QSPI_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_IRQ_P2F_SDIO0_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_IRQ_P2F_SDIO1_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_IRQ_P2F_SMC_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_IRQ_P2F_SPI0_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_IRQ_P2F_SPI1_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_IRQ_P2F_UART0_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_IRQ_P2F_UART1_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_IRQ_P2F_USB0_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_IRQ_P2F_USB1_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_M_AXI_GP0_ARESETN_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_M_AXI_GP0_ARVALID_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_M_AXI_GP0_AWVALID_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_M_AXI_GP0_BREADY_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_M_AXI_GP0_RREADY_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_M_AXI_GP0_WLAST_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_M_AXI_GP0_WVALID_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_M_AXI_GP1_ARESETN_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_M_AXI_GP1_ARVALID_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_M_AXI_GP1_AWVALID_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_M_AXI_GP1_BREADY_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_M_AXI_GP1_RREADY_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_M_AXI_GP1_WLAST_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_M_AXI_GP1_WVALID_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_PJTAG_TDO_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_SDIO0_BUSPOW_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_SDIO0_CLK_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_SDIO0_CMD_O_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_SDIO0_CMD_T_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_SDIO0_LED_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_SDIO1_BUSPOW_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_SDIO1_CLK_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_SDIO1_CMD_O_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_SDIO1_CMD_T_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_SDIO1_LED_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_SPI0_MISO_O_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_SPI0_MISO_T_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_SPI0_MOSI_O_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_SPI0_MOSI_T_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_SPI0_SCLK_O_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_SPI0_SCLK_T_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_SPI0_SS1_O_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_SPI0_SS2_O_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_SPI0_SS_O_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_SPI0_SS_T_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_SPI1_MISO_O_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_SPI1_MISO_T_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_SPI1_MOSI_O_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_SPI1_MOSI_T_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_SPI1_SCLK_O_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_SPI1_SCLK_T_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_SPI1_SS1_O_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_SPI1_SS2_O_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_SPI1_SS_O_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_SPI1_SS_T_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_S_AXI_ACP_ARESETN_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_S_AXI_ACP_ARREADY_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_S_AXI_ACP_AWREADY_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_S_AXI_ACP_BVALID_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_S_AXI_ACP_RLAST_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_S_AXI_ACP_RVALID_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_S_AXI_ACP_WREADY_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_S_AXI_GP0_ARESETN_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_S_AXI_GP0_ARREADY_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_S_AXI_GP0_AWREADY_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_S_AXI_GP0_BVALID_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_S_AXI_GP0_RLAST_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_S_AXI_GP0_RVALID_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_S_AXI_GP0_WREADY_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_S_AXI_GP1_ARESETN_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_S_AXI_GP1_ARREADY_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_S_AXI_GP1_AWREADY_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_S_AXI_GP1_BVALID_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_S_AXI_GP1_RLAST_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_S_AXI_GP1_RVALID_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_S_AXI_GP1_WREADY_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_S_AXI_HP0_ARESETN_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_S_AXI_HP1_ARESETN_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_S_AXI_HP1_ARREADY_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_S_AXI_HP1_AWREADY_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_S_AXI_HP1_BVALID_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_S_AXI_HP1_RLAST_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_S_AXI_HP1_RVALID_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_S_AXI_HP1_WREADY_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_S_AXI_HP2_ARESETN_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_S_AXI_HP2_ARREADY_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_S_AXI_HP2_AWREADY_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_S_AXI_HP2_BVALID_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_S_AXI_HP2_RLAST_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_S_AXI_HP2_RVALID_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_S_AXI_HP2_WREADY_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_S_AXI_HP3_ARESETN_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_S_AXI_HP3_ARREADY_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_S_AXI_HP3_AWREADY_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_S_AXI_HP3_BVALID_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_S_AXI_HP3_RLAST_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_S_AXI_HP3_RVALID_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_S_AXI_HP3_WREADY_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_TRACE_CLK_OUT_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_TRACE_CTL_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_TTC0_WAVE0_OUT_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_TTC0_WAVE1_OUT_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_TTC0_WAVE2_OUT_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_TTC1_WAVE0_OUT_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_TTC1_WAVE1_OUT_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_TTC1_WAVE2_OUT_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_UART0_DTRN_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_UART0_RTSN_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_UART0_TX_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_UART1_DTRN_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_UART1_RTSN_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_UART1_TX_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_USB0_VBUS_PWRSELECT_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_USB1_VBUS_PWRSELECT_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_WDT_RST_OUT_UNCONNECTED : STD_LOGIC;
  signal NLW_inst_DMA0_DATYPE_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_DMA1_DATYPE_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_DMA2_DATYPE_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_DMA3_DATYPE_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_ENET0_GMII_TXD_UNCONNECTED : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal NLW_inst_ENET1_GMII_TXD_UNCONNECTED : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal NLW_inst_EVENT_STANDBYWFE_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_EVENT_STANDBYWFI_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_FTMT_P2F_DEBUG_UNCONNECTED : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal NLW_inst_GPIO_O_UNCONNECTED : STD_LOGIC_VECTOR ( 63 downto 0 );
  signal NLW_inst_GPIO_T_UNCONNECTED : STD_LOGIC_VECTOR ( 63 downto 0 );
  signal NLW_inst_M_AXI_GP0_ARADDR_UNCONNECTED : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal NLW_inst_M_AXI_GP0_ARBURST_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_M_AXI_GP0_ARCACHE_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal NLW_inst_M_AXI_GP0_ARID_UNCONNECTED : STD_LOGIC_VECTOR ( 11 downto 0 );
  signal NLW_inst_M_AXI_GP0_ARLEN_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal NLW_inst_M_AXI_GP0_ARLOCK_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_M_AXI_GP0_ARPROT_UNCONNECTED : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal NLW_inst_M_AXI_GP0_ARQOS_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal NLW_inst_M_AXI_GP0_ARSIZE_UNCONNECTED : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal NLW_inst_M_AXI_GP0_AWADDR_UNCONNECTED : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal NLW_inst_M_AXI_GP0_AWBURST_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_M_AXI_GP0_AWCACHE_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal NLW_inst_M_AXI_GP0_AWID_UNCONNECTED : STD_LOGIC_VECTOR ( 11 downto 0 );
  signal NLW_inst_M_AXI_GP0_AWLEN_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal NLW_inst_M_AXI_GP0_AWLOCK_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_M_AXI_GP0_AWPROT_UNCONNECTED : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal NLW_inst_M_AXI_GP0_AWQOS_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal NLW_inst_M_AXI_GP0_AWSIZE_UNCONNECTED : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal NLW_inst_M_AXI_GP0_WDATA_UNCONNECTED : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal NLW_inst_M_AXI_GP0_WID_UNCONNECTED : STD_LOGIC_VECTOR ( 11 downto 0 );
  signal NLW_inst_M_AXI_GP0_WSTRB_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal NLW_inst_M_AXI_GP1_ARADDR_UNCONNECTED : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal NLW_inst_M_AXI_GP1_ARBURST_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_M_AXI_GP1_ARCACHE_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal NLW_inst_M_AXI_GP1_ARID_UNCONNECTED : STD_LOGIC_VECTOR ( 11 downto 0 );
  signal NLW_inst_M_AXI_GP1_ARLEN_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal NLW_inst_M_AXI_GP1_ARLOCK_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_M_AXI_GP1_ARPROT_UNCONNECTED : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal NLW_inst_M_AXI_GP1_ARQOS_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal NLW_inst_M_AXI_GP1_ARSIZE_UNCONNECTED : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal NLW_inst_M_AXI_GP1_AWADDR_UNCONNECTED : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal NLW_inst_M_AXI_GP1_AWBURST_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_M_AXI_GP1_AWCACHE_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal NLW_inst_M_AXI_GP1_AWID_UNCONNECTED : STD_LOGIC_VECTOR ( 11 downto 0 );
  signal NLW_inst_M_AXI_GP1_AWLEN_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal NLW_inst_M_AXI_GP1_AWLOCK_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_M_AXI_GP1_AWPROT_UNCONNECTED : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal NLW_inst_M_AXI_GP1_AWQOS_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal NLW_inst_M_AXI_GP1_AWSIZE_UNCONNECTED : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal NLW_inst_M_AXI_GP1_WDATA_UNCONNECTED : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal NLW_inst_M_AXI_GP1_WID_UNCONNECTED : STD_LOGIC_VECTOR ( 11 downto 0 );
  signal NLW_inst_M_AXI_GP1_WSTRB_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal NLW_inst_SDIO0_BUSVOLT_UNCONNECTED : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal NLW_inst_SDIO0_DATA_O_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal NLW_inst_SDIO0_DATA_T_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal NLW_inst_SDIO1_BUSVOLT_UNCONNECTED : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal NLW_inst_SDIO1_DATA_O_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal NLW_inst_SDIO1_DATA_T_UNCONNECTED : STD_LOGIC_VECTOR ( 3 downto 0 );
  signal NLW_inst_S_AXI_ACP_BID_UNCONNECTED : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal NLW_inst_S_AXI_ACP_BRESP_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_S_AXI_ACP_RDATA_UNCONNECTED : STD_LOGIC_VECTOR ( 63 downto 0 );
  signal NLW_inst_S_AXI_ACP_RID_UNCONNECTED : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal NLW_inst_S_AXI_ACP_RRESP_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_S_AXI_GP0_BID_UNCONNECTED : STD_LOGIC_VECTOR ( 5 downto 0 );
  signal NLW_inst_S_AXI_GP0_BRESP_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_S_AXI_GP0_RDATA_UNCONNECTED : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal NLW_inst_S_AXI_GP0_RID_UNCONNECTED : STD_LOGIC_VECTOR ( 5 downto 0 );
  signal NLW_inst_S_AXI_GP0_RRESP_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_S_AXI_GP1_BID_UNCONNECTED : STD_LOGIC_VECTOR ( 5 downto 0 );
  signal NLW_inst_S_AXI_GP1_BRESP_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_S_AXI_GP1_RDATA_UNCONNECTED : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal NLW_inst_S_AXI_GP1_RID_UNCONNECTED : STD_LOGIC_VECTOR ( 5 downto 0 );
  signal NLW_inst_S_AXI_GP1_RRESP_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_S_AXI_HP1_BID_UNCONNECTED : STD_LOGIC_VECTOR ( 5 downto 0 );
  signal NLW_inst_S_AXI_HP1_BRESP_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_S_AXI_HP1_RACOUNT_UNCONNECTED : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal NLW_inst_S_AXI_HP1_RCOUNT_UNCONNECTED : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal NLW_inst_S_AXI_HP1_RDATA_UNCONNECTED : STD_LOGIC_VECTOR ( 63 downto 0 );
  signal NLW_inst_S_AXI_HP1_RID_UNCONNECTED : STD_LOGIC_VECTOR ( 5 downto 0 );
  signal NLW_inst_S_AXI_HP1_RRESP_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_S_AXI_HP1_WACOUNT_UNCONNECTED : STD_LOGIC_VECTOR ( 5 downto 0 );
  signal NLW_inst_S_AXI_HP1_WCOUNT_UNCONNECTED : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal NLW_inst_S_AXI_HP2_BID_UNCONNECTED : STD_LOGIC_VECTOR ( 5 downto 0 );
  signal NLW_inst_S_AXI_HP2_BRESP_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_S_AXI_HP2_RACOUNT_UNCONNECTED : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal NLW_inst_S_AXI_HP2_RCOUNT_UNCONNECTED : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal NLW_inst_S_AXI_HP2_RDATA_UNCONNECTED : STD_LOGIC_VECTOR ( 63 downto 0 );
  signal NLW_inst_S_AXI_HP2_RID_UNCONNECTED : STD_LOGIC_VECTOR ( 5 downto 0 );
  signal NLW_inst_S_AXI_HP2_RRESP_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_S_AXI_HP2_WACOUNT_UNCONNECTED : STD_LOGIC_VECTOR ( 5 downto 0 );
  signal NLW_inst_S_AXI_HP2_WCOUNT_UNCONNECTED : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal NLW_inst_S_AXI_HP3_BID_UNCONNECTED : STD_LOGIC_VECTOR ( 5 downto 0 );
  signal NLW_inst_S_AXI_HP3_BRESP_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_S_AXI_HP3_RACOUNT_UNCONNECTED : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal NLW_inst_S_AXI_HP3_RCOUNT_UNCONNECTED : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal NLW_inst_S_AXI_HP3_RDATA_UNCONNECTED : STD_LOGIC_VECTOR ( 63 downto 0 );
  signal NLW_inst_S_AXI_HP3_RID_UNCONNECTED : STD_LOGIC_VECTOR ( 5 downto 0 );
  signal NLW_inst_S_AXI_HP3_RRESP_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_S_AXI_HP3_WACOUNT_UNCONNECTED : STD_LOGIC_VECTOR ( 5 downto 0 );
  signal NLW_inst_S_AXI_HP3_WCOUNT_UNCONNECTED : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal NLW_inst_TRACE_DATA_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_USB0_PORT_INDCTL_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal NLW_inst_USB1_PORT_INDCTL_UNCONNECTED : STD_LOGIC_VECTOR ( 1 downto 0 );
  attribute C_DM_WIDTH : integer;
  attribute C_DM_WIDTH of inst : label is 4;
  attribute C_DQS_WIDTH : integer;
  attribute C_DQS_WIDTH of inst : label is 4;
  attribute C_DQ_WIDTH : integer;
  attribute C_DQ_WIDTH of inst : label is 32;
  attribute C_EMIO_GPIO_WIDTH : integer;
  attribute C_EMIO_GPIO_WIDTH of inst : label is 64;
  attribute C_EN_EMIO_ENET0 : integer;
  attribute C_EN_EMIO_ENET0 of inst : label is 0;
  attribute C_EN_EMIO_ENET1 : integer;
  attribute C_EN_EMIO_ENET1 of inst : label is 0;
  attribute C_EN_EMIO_PJTAG : integer;
  attribute C_EN_EMIO_PJTAG of inst : label is 0;
  attribute C_EN_EMIO_TRACE : integer;
  attribute C_EN_EMIO_TRACE of inst : label is 0;
  attribute C_FCLK_CLK0_BUF : string;
  attribute C_FCLK_CLK0_BUF of inst : label is "FALSE";
  attribute C_FCLK_CLK1_BUF : string;
  attribute C_FCLK_CLK1_BUF of inst : label is "FALSE";
  attribute C_FCLK_CLK2_BUF : string;
  attribute C_FCLK_CLK2_BUF of inst : label is "FALSE";
  attribute C_FCLK_CLK3_BUF : string;
  attribute C_FCLK_CLK3_BUF of inst : label is "FALSE";
  attribute C_GP0_EN_MODIFIABLE_TXN : integer;
  attribute C_GP0_EN_MODIFIABLE_TXN of inst : label is 1;
  attribute C_GP1_EN_MODIFIABLE_TXN : integer;
  attribute C_GP1_EN_MODIFIABLE_TXN of inst : label is 1;
  attribute C_INCLUDE_ACP_TRANS_CHECK : integer;
  attribute C_INCLUDE_ACP_TRANS_CHECK of inst : label is 0;
  attribute C_INCLUDE_TRACE_BUFFER : integer;
  attribute C_INCLUDE_TRACE_BUFFER of inst : label is 0;
  attribute C_IRQ_F2P_MODE : string;
  attribute C_IRQ_F2P_MODE of inst : label is "DIRECT";
  attribute C_MIO_PRIMITIVE : integer;
  attribute C_MIO_PRIMITIVE of inst : label is 54;
  attribute C_M_AXI_GP0_ENABLE_STATIC_REMAP : integer;
  attribute C_M_AXI_GP0_ENABLE_STATIC_REMAP of inst : label is 0;
  attribute C_M_AXI_GP0_ID_WIDTH : integer;
  attribute C_M_AXI_GP0_ID_WIDTH of inst : label is 12;
  attribute C_M_AXI_GP0_THREAD_ID_WIDTH : integer;
  attribute C_M_AXI_GP0_THREAD_ID_WIDTH of inst : label is 12;
  attribute C_M_AXI_GP1_ENABLE_STATIC_REMAP : integer;
  attribute C_M_AXI_GP1_ENABLE_STATIC_REMAP of inst : label is 0;
  attribute C_M_AXI_GP1_ID_WIDTH : integer;
  attribute C_M_AXI_GP1_ID_WIDTH of inst : label is 12;
  attribute C_M_AXI_GP1_THREAD_ID_WIDTH : integer;
  attribute C_M_AXI_GP1_THREAD_ID_WIDTH of inst : label is 12;
  attribute C_NUM_F2P_INTR_INPUTS : integer;
  attribute C_NUM_F2P_INTR_INPUTS of inst : label is 1;
  attribute C_PACKAGE_NAME : string;
  attribute C_PACKAGE_NAME of inst : label is "clg400";
  attribute C_PS7_SI_REV : string;
  attribute C_PS7_SI_REV of inst : label is "PRODUCTION";
  attribute C_S_AXI_ACP_ARUSER_VAL : integer;
  attribute C_S_AXI_ACP_ARUSER_VAL of inst : label is 31;
  attribute C_S_AXI_ACP_AWUSER_VAL : integer;
  attribute C_S_AXI_ACP_AWUSER_VAL of inst : label is 31;
  attribute C_S_AXI_ACP_ID_WIDTH : integer;
  attribute C_S_AXI_ACP_ID_WIDTH of inst : label is 3;
  attribute C_S_AXI_GP0_ID_WIDTH : integer;
  attribute C_S_AXI_GP0_ID_WIDTH of inst : label is 6;
  attribute C_S_AXI_GP1_ID_WIDTH : integer;
  attribute C_S_AXI_GP1_ID_WIDTH of inst : label is 6;
  attribute C_S_AXI_HP0_DATA_WIDTH : integer;
  attribute C_S_AXI_HP0_DATA_WIDTH of inst : label is 64;
  attribute C_S_AXI_HP0_ID_WIDTH : integer;
  attribute C_S_AXI_HP0_ID_WIDTH of inst : label is 6;
  attribute C_S_AXI_HP1_DATA_WIDTH : integer;
  attribute C_S_AXI_HP1_DATA_WIDTH of inst : label is 64;
  attribute C_S_AXI_HP1_ID_WIDTH : integer;
  attribute C_S_AXI_HP1_ID_WIDTH of inst : label is 6;
  attribute C_S_AXI_HP2_DATA_WIDTH : integer;
  attribute C_S_AXI_HP2_DATA_WIDTH of inst : label is 64;
  attribute C_S_AXI_HP2_ID_WIDTH : integer;
  attribute C_S_AXI_HP2_ID_WIDTH of inst : label is 6;
  attribute C_S_AXI_HP3_DATA_WIDTH : integer;
  attribute C_S_AXI_HP3_DATA_WIDTH of inst : label is 64;
  attribute C_S_AXI_HP3_ID_WIDTH : integer;
  attribute C_S_AXI_HP3_ID_WIDTH of inst : label is 6;
  attribute C_TRACE_BUFFER_CLOCK_DELAY : integer;
  attribute C_TRACE_BUFFER_CLOCK_DELAY of inst : label is 12;
  attribute C_TRACE_BUFFER_FIFO_SIZE : integer;
  attribute C_TRACE_BUFFER_FIFO_SIZE of inst : label is 128;
  attribute C_TRACE_INTERNAL_WIDTH : integer;
  attribute C_TRACE_INTERNAL_WIDTH of inst : label is 2;
  attribute C_TRACE_PIPELINE_WIDTH : integer;
  attribute C_TRACE_PIPELINE_WIDTH of inst : label is 8;
  attribute C_USE_AXI_NONSECURE : integer;
  attribute C_USE_AXI_NONSECURE of inst : label is 0;
  attribute C_USE_DEFAULT_ACP_USER_VAL : integer;
  attribute C_USE_DEFAULT_ACP_USER_VAL of inst : label is 0;
  attribute C_USE_M_AXI_GP0 : integer;
  attribute C_USE_M_AXI_GP0 of inst : label is 0;
  attribute C_USE_M_AXI_GP1 : integer;
  attribute C_USE_M_AXI_GP1 of inst : label is 0;
  attribute C_USE_S_AXI_ACP : integer;
  attribute C_USE_S_AXI_ACP of inst : label is 0;
  attribute C_USE_S_AXI_GP0 : integer;
  attribute C_USE_S_AXI_GP0 of inst : label is 0;
  attribute C_USE_S_AXI_GP1 : integer;
  attribute C_USE_S_AXI_GP1 of inst : label is 0;
  attribute C_USE_S_AXI_HP0 : integer;
  attribute C_USE_S_AXI_HP0 of inst : label is 1;
  attribute C_USE_S_AXI_HP1 : integer;
  attribute C_USE_S_AXI_HP1 of inst : label is 0;
  attribute C_USE_S_AXI_HP2 : integer;
  attribute C_USE_S_AXI_HP2 of inst : label is 0;
  attribute C_USE_S_AXI_HP3 : integer;
  attribute C_USE_S_AXI_HP3 of inst : label is 0;
  attribute HW_HANDOFF : string;
  attribute HW_HANDOFF of inst : label is "ps_system_processing_system7_0_0.hwdef";
  attribute POWER : string;
  attribute POWER of inst : label is "<PROCESSOR name={system} numA9Cores={2} clockFreq={666.666666} load={0.5} /><MEMORY name={code} memType={DDR3} dataWidth={16} clockFreq={533.333333} readRate={0.5} writeRate={0.5} /><IO interface={UART} ioStandard={LVCMOS33} bidis={2} ioBank={Vcco_p0} clockFreq={100.000000} usageRate={0.5} /><IO interface={SD} ioStandard={LVCMOS33} bidis={6} ioBank={Vcco_p1} clockFreq={100.000000} usageRate={0.5} /><PLL domain={Processor} vco={1333.333} /><PLL domain={Memory} vco={1066.667} /><PLL domain={IO} vco={1600.000} /><AXI interface={S_AXI_HP0} dataWidth={64} clockFreq={100} usageRate={0.5} />/>";
  attribute USE_TRACE_DATA_EDGE_DETECTOR : integer;
  attribute USE_TRACE_DATA_EDGE_DETECTOR of inst : label is 0;
  attribute X_INTERFACE_INFO : string;
  attribute X_INTERFACE_INFO of DDR_CAS_n : signal is "xilinx.com:interface:ddrx:1.0 DDR CAS_N";
  attribute X_INTERFACE_INFO of DDR_CKE : signal is "xilinx.com:interface:ddrx:1.0 DDR CKE";
  attribute X_INTERFACE_INFO of DDR_CS_n : signal is "xilinx.com:interface:ddrx:1.0 DDR CS_N";
  attribute X_INTERFACE_INFO of DDR_Clk : signal is "xilinx.com:interface:ddrx:1.0 DDR CK_P";
  attribute X_INTERFACE_INFO of DDR_Clk_n : signal is "xilinx.com:interface:ddrx:1.0 DDR CK_N";
  attribute X_INTERFACE_INFO of DDR_DRSTB : signal is "xilinx.com:interface:ddrx:1.0 DDR RESET_N";
  attribute X_INTERFACE_INFO of DDR_ODT : signal is "xilinx.com:interface:ddrx:1.0 DDR ODT";
  attribute X_INTERFACE_INFO of DDR_RAS_n : signal is "xilinx.com:interface:ddrx:1.0 DDR RAS_N";
  attribute X_INTERFACE_INFO of DDR_VRN : signal is "xilinx.com:display_processing_system7:fixedio:1.0 FIXED_IO DDR_VRN";
  attribute X_INTERFACE_INFO of DDR_VRP : signal is "xilinx.com:display_processing_system7:fixedio:1.0 FIXED_IO DDR_VRP";
  attribute X_INTERFACE_INFO of DDR_WEB : signal is "xilinx.com:interface:ddrx:1.0 DDR WE_N";
  attribute X_INTERFACE_INFO of FCLK_CLK0 : signal is "xilinx.com:signal:clock:1.0 FCLK_CLK0 CLK";
  attribute X_INTERFACE_PARAMETER : string;
  attribute X_INTERFACE_PARAMETER of FCLK_CLK0 : signal is "XIL_INTERFACENAME FCLK_CLK0, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.000, CLK_DOMAIN ps_system_processing_system7_0_0_FCLK_CLK0, INSERT_VIP 0";
  attribute X_INTERFACE_INFO of FCLK_RESET0_N : signal is "xilinx.com:signal:reset:1.0 FCLK_RESET0_N RST";
  attribute X_INTERFACE_PARAMETER of FCLK_RESET0_N : signal is "XIL_INTERFACENAME FCLK_RESET0_N, POLARITY ACTIVE_LOW, INSERT_VIP 0";
  attribute X_INTERFACE_INFO of PS_CLK : signal is "xilinx.com:display_processing_system7:fixedio:1.0 FIXED_IO PS_CLK";
  attribute X_INTERFACE_INFO of PS_PORB : signal is "xilinx.com:display_processing_system7:fixedio:1.0 FIXED_IO PS_PORB";
  attribute X_INTERFACE_PARAMETER of PS_PORB : signal is "XIL_INTERFACENAME FIXED_IO, CAN_DEBUG false";
  attribute X_INTERFACE_INFO of PS_SRSTB : signal is "xilinx.com:display_processing_system7:fixedio:1.0 FIXED_IO PS_SRSTB";
  attribute X_INTERFACE_INFO of S_AXI_HP0_ACLK : signal is "xilinx.com:signal:clock:1.0 S_AXI_HP0_ACLK CLK";
  attribute X_INTERFACE_PARAMETER of S_AXI_HP0_ACLK : signal is "XIL_INTERFACENAME S_AXI_HP0_ACLK, ASSOCIATED_BUSIF S_AXI_HP0, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.000, CLK_DOMAIN ps_system_processing_system7_0_0_FCLK_CLK0, INSERT_VIP 0";
  attribute X_INTERFACE_INFO of S_AXI_HP0_ARREADY : signal is "xilinx.com:interface:aximm:1.0 S_AXI_HP0 ARREADY";
  attribute X_INTERFACE_INFO of S_AXI_HP0_ARVALID : signal is "xilinx.com:interface:aximm:1.0 S_AXI_HP0 ARVALID";
  attribute X_INTERFACE_INFO of S_AXI_HP0_AWREADY : signal is "xilinx.com:interface:aximm:1.0 S_AXI_HP0 AWREADY";
  attribute X_INTERFACE_INFO of S_AXI_HP0_AWVALID : signal is "xilinx.com:interface:aximm:1.0 S_AXI_HP0 AWVALID";
  attribute X_INTERFACE_INFO of S_AXI_HP0_BREADY : signal is "xilinx.com:interface:aximm:1.0 S_AXI_HP0 BREADY";
  attribute X_INTERFACE_INFO of S_AXI_HP0_BVALID : signal is "xilinx.com:interface:aximm:1.0 S_AXI_HP0 BVALID";
  attribute X_INTERFACE_INFO of S_AXI_HP0_RDISSUECAP1_EN : signal is "xilinx.com:display_processing_system7:hpstatusctrl:1.0 S_AXI_HP0_FIFO_CTRL RDISSUECAPEN";
  attribute X_INTERFACE_INFO of S_AXI_HP0_RLAST : signal is "xilinx.com:interface:aximm:1.0 S_AXI_HP0 RLAST";
  attribute X_INTERFACE_INFO of S_AXI_HP0_RREADY : signal is "xilinx.com:interface:aximm:1.0 S_AXI_HP0 RREADY";
  attribute X_INTERFACE_INFO of S_AXI_HP0_RVALID : signal is "xilinx.com:interface:aximm:1.0 S_AXI_HP0 RVALID";
  attribute X_INTERFACE_INFO of S_AXI_HP0_WLAST : signal is "xilinx.com:interface:aximm:1.0 S_AXI_HP0 WLAST";
  attribute X_INTERFACE_INFO of S_AXI_HP0_WREADY : signal is "xilinx.com:interface:aximm:1.0 S_AXI_HP0 WREADY";
  attribute X_INTERFACE_INFO of S_AXI_HP0_WRISSUECAP1_EN : signal is "xilinx.com:display_processing_system7:hpstatusctrl:1.0 S_AXI_HP0_FIFO_CTRL WRISSUECAPEN";
  attribute X_INTERFACE_INFO of S_AXI_HP0_WVALID : signal is "xilinx.com:interface:aximm:1.0 S_AXI_HP0 WVALID";
  attribute X_INTERFACE_INFO of DDR_Addr : signal is "xilinx.com:interface:ddrx:1.0 DDR ADDR";
  attribute X_INTERFACE_INFO of DDR_BankAddr : signal is "xilinx.com:interface:ddrx:1.0 DDR BA";
  attribute X_INTERFACE_INFO of DDR_DM : signal is "xilinx.com:interface:ddrx:1.0 DDR DM";
  attribute X_INTERFACE_INFO of DDR_DQ : signal is "xilinx.com:interface:ddrx:1.0 DDR DQ";
  attribute X_INTERFACE_INFO of DDR_DQS : signal is "xilinx.com:interface:ddrx:1.0 DDR DQS_P";
  attribute X_INTERFACE_PARAMETER of DDR_DQS : signal is "XIL_INTERFACENAME DDR, CAN_DEBUG false, TIMEPERIOD_PS 1250, MEMORY_TYPE COMPONENTS, DATA_WIDTH 8, CS_ENABLED true, DATA_MASK_ENABLED true, SLOT Single, MEM_ADDR_MAP ROW_COLUMN_BANK, BURST_LENGTH 8, AXI_ARBITRATION_SCHEME TDM, CAS_LATENCY 11, CAS_WRITE_LATENCY 11";
  attribute X_INTERFACE_INFO of DDR_DQS_n : signal is "xilinx.com:interface:ddrx:1.0 DDR DQS_N";
  attribute X_INTERFACE_INFO of MIO : signal is "xilinx.com:display_processing_system7:fixedio:1.0 FIXED_IO MIO";
  attribute X_INTERFACE_INFO of S_AXI_HP0_ARADDR : signal is "xilinx.com:interface:aximm:1.0 S_AXI_HP0 ARADDR";
  attribute X_INTERFACE_INFO of S_AXI_HP0_ARBURST : signal is "xilinx.com:interface:aximm:1.0 S_AXI_HP0 ARBURST";
  attribute X_INTERFACE_INFO of S_AXI_HP0_ARCACHE : signal is "xilinx.com:interface:aximm:1.0 S_AXI_HP0 ARCACHE";
  attribute X_INTERFACE_INFO of S_AXI_HP0_ARID : signal is "xilinx.com:interface:aximm:1.0 S_AXI_HP0 ARID";
  attribute X_INTERFACE_INFO of S_AXI_HP0_ARLEN : signal is "xilinx.com:interface:aximm:1.0 S_AXI_HP0 ARLEN";
  attribute X_INTERFACE_INFO of S_AXI_HP0_ARLOCK : signal is "xilinx.com:interface:aximm:1.0 S_AXI_HP0 ARLOCK";
  attribute X_INTERFACE_INFO of S_AXI_HP0_ARPROT : signal is "xilinx.com:interface:aximm:1.0 S_AXI_HP0 ARPROT";
  attribute X_INTERFACE_INFO of S_AXI_HP0_ARQOS : signal is "xilinx.com:interface:aximm:1.0 S_AXI_HP0 ARQOS";
  attribute X_INTERFACE_INFO of S_AXI_HP0_ARSIZE : signal is "xilinx.com:interface:aximm:1.0 S_AXI_HP0 ARSIZE";
  attribute X_INTERFACE_INFO of S_AXI_HP0_AWADDR : signal is "xilinx.com:interface:aximm:1.0 S_AXI_HP0 AWADDR";
  attribute X_INTERFACE_INFO of S_AXI_HP0_AWBURST : signal is "xilinx.com:interface:aximm:1.0 S_AXI_HP0 AWBURST";
  attribute X_INTERFACE_INFO of S_AXI_HP0_AWCACHE : signal is "xilinx.com:interface:aximm:1.0 S_AXI_HP0 AWCACHE";
  attribute X_INTERFACE_INFO of S_AXI_HP0_AWID : signal is "xilinx.com:interface:aximm:1.0 S_AXI_HP0 AWID";
  attribute X_INTERFACE_INFO of S_AXI_HP0_AWLEN : signal is "xilinx.com:interface:aximm:1.0 S_AXI_HP0 AWLEN";
  attribute X_INTERFACE_INFO of S_AXI_HP0_AWLOCK : signal is "xilinx.com:interface:aximm:1.0 S_AXI_HP0 AWLOCK";
  attribute X_INTERFACE_INFO of S_AXI_HP0_AWPROT : signal is "xilinx.com:interface:aximm:1.0 S_AXI_HP0 AWPROT";
  attribute X_INTERFACE_INFO of S_AXI_HP0_AWQOS : signal is "xilinx.com:interface:aximm:1.0 S_AXI_HP0 AWQOS";
  attribute X_INTERFACE_INFO of S_AXI_HP0_AWSIZE : signal is "xilinx.com:interface:aximm:1.0 S_AXI_HP0 AWSIZE";
  attribute X_INTERFACE_INFO of S_AXI_HP0_BID : signal is "xilinx.com:interface:aximm:1.0 S_AXI_HP0 BID";
  attribute X_INTERFACE_INFO of S_AXI_HP0_BRESP : signal is "xilinx.com:interface:aximm:1.0 S_AXI_HP0 BRESP";
  attribute X_INTERFACE_INFO of S_AXI_HP0_RACOUNT : signal is "xilinx.com:display_processing_system7:hpstatusctrl:1.0 S_AXI_HP0_FIFO_CTRL RACOUNT";
  attribute X_INTERFACE_INFO of S_AXI_HP0_RCOUNT : signal is "xilinx.com:display_processing_system7:hpstatusctrl:1.0 S_AXI_HP0_FIFO_CTRL RCOUNT";
  attribute X_INTERFACE_INFO of S_AXI_HP0_RDATA : signal is "xilinx.com:interface:aximm:1.0 S_AXI_HP0 RDATA";
  attribute X_INTERFACE_INFO of S_AXI_HP0_RID : signal is "xilinx.com:interface:aximm:1.0 S_AXI_HP0 RID";
  attribute X_INTERFACE_INFO of S_AXI_HP0_RRESP : signal is "xilinx.com:interface:aximm:1.0 S_AXI_HP0 RRESP";
  attribute X_INTERFACE_INFO of S_AXI_HP0_WACOUNT : signal is "xilinx.com:display_processing_system7:hpstatusctrl:1.0 S_AXI_HP0_FIFO_CTRL WACOUNT";
  attribute X_INTERFACE_INFO of S_AXI_HP0_WCOUNT : signal is "xilinx.com:display_processing_system7:hpstatusctrl:1.0 S_AXI_HP0_FIFO_CTRL WCOUNT";
  attribute X_INTERFACE_INFO of S_AXI_HP0_WDATA : signal is "xilinx.com:interface:aximm:1.0 S_AXI_HP0 WDATA";
  attribute X_INTERFACE_INFO of S_AXI_HP0_WID : signal is "xilinx.com:interface:aximm:1.0 S_AXI_HP0 WID";
  attribute X_INTERFACE_INFO of S_AXI_HP0_WSTRB : signal is "xilinx.com:interface:aximm:1.0 S_AXI_HP0 WSTRB";
  attribute X_INTERFACE_PARAMETER of S_AXI_HP0_WSTRB : signal is "XIL_INTERFACENAME S_AXI_HP0, NUM_WRITE_OUTSTANDING 8, NUM_READ_OUTSTANDING 8, DATA_WIDTH 64, PROTOCOL AXI3, FREQ_HZ 100000000, ID_WIDTH 6, ADDR_WIDTH 32, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 1, HAS_LOCK 1, HAS_PROT 1, HAS_CACHE 1, HAS_QOS 1, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, SUPPORTS_NARROW_BURST 1, MAX_BURST_LENGTH 16, PHASE 0.000, CLK_DOMAIN ps_system_processing_system7_0_0_FCLK_CLK0, NUM_READ_THREADS 1, NUM_WRITE_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0";
begin
inst: entity work.ps_system_processing_system7_0_0_processing_system7_v5_5_processing_system7
     port map (
      CAN0_PHY_RX => '0',
      CAN0_PHY_TX => NLW_inst_CAN0_PHY_TX_UNCONNECTED,
      CAN1_PHY_RX => '0',
      CAN1_PHY_TX => NLW_inst_CAN1_PHY_TX_UNCONNECTED,
      Core0_nFIQ => '0',
      Core0_nIRQ => '0',
      Core1_nFIQ => '0',
      Core1_nIRQ => '0',
      DDR_ARB(3 downto 0) => B"0000",
      DDR_Addr(14 downto 0) => DDR_Addr(14 downto 0),
      DDR_BankAddr(2 downto 0) => DDR_BankAddr(2 downto 0),
      DDR_CAS_n => DDR_CAS_n,
      DDR_CKE => DDR_CKE,
      DDR_CS_n => DDR_CS_n,
      DDR_Clk => DDR_Clk,
      DDR_Clk_n => DDR_Clk_n,
      DDR_DM(3 downto 0) => DDR_DM(3 downto 0),
      DDR_DQ(31 downto 0) => DDR_DQ(31 downto 0),
      DDR_DQS(3 downto 0) => DDR_DQS(3 downto 0),
      DDR_DQS_n(3 downto 0) => DDR_DQS_n(3 downto 0),
      DDR_DRSTB => DDR_DRSTB,
      DDR_ODT => DDR_ODT,
      DDR_RAS_n => DDR_RAS_n,
      DDR_VRN => DDR_VRN,
      DDR_VRP => DDR_VRP,
      DDR_WEB => DDR_WEB,
      DMA0_ACLK => '0',
      DMA0_DAREADY => '0',
      DMA0_DATYPE(1 downto 0) => NLW_inst_DMA0_DATYPE_UNCONNECTED(1 downto 0),
      DMA0_DAVALID => NLW_inst_DMA0_DAVALID_UNCONNECTED,
      DMA0_DRLAST => '0',
      DMA0_DRREADY => NLW_inst_DMA0_DRREADY_UNCONNECTED,
      DMA0_DRTYPE(1 downto 0) => B"00",
      DMA0_DRVALID => '0',
      DMA0_RSTN => NLW_inst_DMA0_RSTN_UNCONNECTED,
      DMA1_ACLK => '0',
      DMA1_DAREADY => '0',
      DMA1_DATYPE(1 downto 0) => NLW_inst_DMA1_DATYPE_UNCONNECTED(1 downto 0),
      DMA1_DAVALID => NLW_inst_DMA1_DAVALID_UNCONNECTED,
      DMA1_DRLAST => '0',
      DMA1_DRREADY => NLW_inst_DMA1_DRREADY_UNCONNECTED,
      DMA1_DRTYPE(1 downto 0) => B"00",
      DMA1_DRVALID => '0',
      DMA1_RSTN => NLW_inst_DMA1_RSTN_UNCONNECTED,
      DMA2_ACLK => '0',
      DMA2_DAREADY => '0',
      DMA2_DATYPE(1 downto 0) => NLW_inst_DMA2_DATYPE_UNCONNECTED(1 downto 0),
      DMA2_DAVALID => NLW_inst_DMA2_DAVALID_UNCONNECTED,
      DMA2_DRLAST => '0',
      DMA2_DRREADY => NLW_inst_DMA2_DRREADY_UNCONNECTED,
      DMA2_DRTYPE(1 downto 0) => B"00",
      DMA2_DRVALID => '0',
      DMA2_RSTN => NLW_inst_DMA2_RSTN_UNCONNECTED,
      DMA3_ACLK => '0',
      DMA3_DAREADY => '0',
      DMA3_DATYPE(1 downto 0) => NLW_inst_DMA3_DATYPE_UNCONNECTED(1 downto 0),
      DMA3_DAVALID => NLW_inst_DMA3_DAVALID_UNCONNECTED,
      DMA3_DRLAST => '0',
      DMA3_DRREADY => NLW_inst_DMA3_DRREADY_UNCONNECTED,
      DMA3_DRTYPE(1 downto 0) => B"00",
      DMA3_DRVALID => '0',
      DMA3_RSTN => NLW_inst_DMA3_RSTN_UNCONNECTED,
      ENET0_EXT_INTIN => '0',
      ENET0_GMII_COL => '0',
      ENET0_GMII_CRS => '0',
      ENET0_GMII_RXD(7 downto 0) => B"00000000",
      ENET0_GMII_RX_CLK => '0',
      ENET0_GMII_RX_DV => '0',
      ENET0_GMII_RX_ER => '0',
      ENET0_GMII_TXD(7 downto 0) => NLW_inst_ENET0_GMII_TXD_UNCONNECTED(7 downto 0),
      ENET0_GMII_TX_CLK => '0',
      ENET0_GMII_TX_EN => NLW_inst_ENET0_GMII_TX_EN_UNCONNECTED,
      ENET0_GMII_TX_ER => NLW_inst_ENET0_GMII_TX_ER_UNCONNECTED,
      ENET0_MDIO_I => '0',
      ENET0_MDIO_MDC => NLW_inst_ENET0_MDIO_MDC_UNCONNECTED,
      ENET0_MDIO_O => NLW_inst_ENET0_MDIO_O_UNCONNECTED,
      ENET0_MDIO_T => NLW_inst_ENET0_MDIO_T_UNCONNECTED,
      ENET0_PTP_DELAY_REQ_RX => NLW_inst_ENET0_PTP_DELAY_REQ_RX_UNCONNECTED,
      ENET0_PTP_DELAY_REQ_TX => NLW_inst_ENET0_PTP_DELAY_REQ_TX_UNCONNECTED,
      ENET0_PTP_PDELAY_REQ_RX => NLW_inst_ENET0_PTP_PDELAY_REQ_RX_UNCONNECTED,
      ENET0_PTP_PDELAY_REQ_TX => NLW_inst_ENET0_PTP_PDELAY_REQ_TX_UNCONNECTED,
      ENET0_PTP_PDELAY_RESP_RX => NLW_inst_ENET0_PTP_PDELAY_RESP_RX_UNCONNECTED,
      ENET0_PTP_PDELAY_RESP_TX => NLW_inst_ENET0_PTP_PDELAY_RESP_TX_UNCONNECTED,
      ENET0_PTP_SYNC_FRAME_RX => NLW_inst_ENET0_PTP_SYNC_FRAME_RX_UNCONNECTED,
      ENET0_PTP_SYNC_FRAME_TX => NLW_inst_ENET0_PTP_SYNC_FRAME_TX_UNCONNECTED,
      ENET0_SOF_RX => NLW_inst_ENET0_SOF_RX_UNCONNECTED,
      ENET0_SOF_TX => NLW_inst_ENET0_SOF_TX_UNCONNECTED,
      ENET1_EXT_INTIN => '0',
      ENET1_GMII_COL => '0',
      ENET1_GMII_CRS => '0',
      ENET1_GMII_RXD(7 downto 0) => B"00000000",
      ENET1_GMII_RX_CLK => '0',
      ENET1_GMII_RX_DV => '0',
      ENET1_GMII_RX_ER => '0',
      ENET1_GMII_TXD(7 downto 0) => NLW_inst_ENET1_GMII_TXD_UNCONNECTED(7 downto 0),
      ENET1_GMII_TX_CLK => '0',
      ENET1_GMII_TX_EN => NLW_inst_ENET1_GMII_TX_EN_UNCONNECTED,
      ENET1_GMII_TX_ER => NLW_inst_ENET1_GMII_TX_ER_UNCONNECTED,
      ENET1_MDIO_I => '0',
      ENET1_MDIO_MDC => NLW_inst_ENET1_MDIO_MDC_UNCONNECTED,
      ENET1_MDIO_O => NLW_inst_ENET1_MDIO_O_UNCONNECTED,
      ENET1_MDIO_T => NLW_inst_ENET1_MDIO_T_UNCONNECTED,
      ENET1_PTP_DELAY_REQ_RX => NLW_inst_ENET1_PTP_DELAY_REQ_RX_UNCONNECTED,
      ENET1_PTP_DELAY_REQ_TX => NLW_inst_ENET1_PTP_DELAY_REQ_TX_UNCONNECTED,
      ENET1_PTP_PDELAY_REQ_RX => NLW_inst_ENET1_PTP_PDELAY_REQ_RX_UNCONNECTED,
      ENET1_PTP_PDELAY_REQ_TX => NLW_inst_ENET1_PTP_PDELAY_REQ_TX_UNCONNECTED,
      ENET1_PTP_PDELAY_RESP_RX => NLW_inst_ENET1_PTP_PDELAY_RESP_RX_UNCONNECTED,
      ENET1_PTP_PDELAY_RESP_TX => NLW_inst_ENET1_PTP_PDELAY_RESP_TX_UNCONNECTED,
      ENET1_PTP_SYNC_FRAME_RX => NLW_inst_ENET1_PTP_SYNC_FRAME_RX_UNCONNECTED,
      ENET1_PTP_SYNC_FRAME_TX => NLW_inst_ENET1_PTP_SYNC_FRAME_TX_UNCONNECTED,
      ENET1_SOF_RX => NLW_inst_ENET1_SOF_RX_UNCONNECTED,
      ENET1_SOF_TX => NLW_inst_ENET1_SOF_TX_UNCONNECTED,
      EVENT_EVENTI => '0',
      EVENT_EVENTO => NLW_inst_EVENT_EVENTO_UNCONNECTED,
      EVENT_STANDBYWFE(1 downto 0) => NLW_inst_EVENT_STANDBYWFE_UNCONNECTED(1 downto 0),
      EVENT_STANDBYWFI(1 downto 0) => NLW_inst_EVENT_STANDBYWFI_UNCONNECTED(1 downto 0),
      FCLK_CLK0 => FCLK_CLK0,
      FCLK_CLK1 => NLW_inst_FCLK_CLK1_UNCONNECTED,
      FCLK_CLK2 => NLW_inst_FCLK_CLK2_UNCONNECTED,
      FCLK_CLK3 => NLW_inst_FCLK_CLK3_UNCONNECTED,
      FCLK_CLKTRIG0_N => '0',
      FCLK_CLKTRIG1_N => '0',
      FCLK_CLKTRIG2_N => '0',
      FCLK_CLKTRIG3_N => '0',
      FCLK_RESET0_N => FCLK_RESET0_N,
      FCLK_RESET1_N => NLW_inst_FCLK_RESET1_N_UNCONNECTED,
      FCLK_RESET2_N => NLW_inst_FCLK_RESET2_N_UNCONNECTED,
      FCLK_RESET3_N => NLW_inst_FCLK_RESET3_N_UNCONNECTED,
      FPGA_IDLE_N => '0',
      FTMD_TRACEIN_ATID(3 downto 0) => B"0000",
      FTMD_TRACEIN_CLK => '0',
      FTMD_TRACEIN_DATA(31 downto 0) => B"00000000000000000000000000000000",
      FTMD_TRACEIN_VALID => '0',
      FTMT_F2P_DEBUG(31 downto 0) => B"00000000000000000000000000000000",
      FTMT_F2P_TRIGACK_0 => NLW_inst_FTMT_F2P_TRIGACK_0_UNCONNECTED,
      FTMT_F2P_TRIGACK_1 => NLW_inst_FTMT_F2P_TRIGACK_1_UNCONNECTED,
      FTMT_F2P_TRIGACK_2 => NLW_inst_FTMT_F2P_TRIGACK_2_UNCONNECTED,
      FTMT_F2P_TRIGACK_3 => NLW_inst_FTMT_F2P_TRIGACK_3_UNCONNECTED,
      FTMT_F2P_TRIG_0 => '0',
      FTMT_F2P_TRIG_1 => '0',
      FTMT_F2P_TRIG_2 => '0',
      FTMT_F2P_TRIG_3 => '0',
      FTMT_P2F_DEBUG(31 downto 0) => NLW_inst_FTMT_P2F_DEBUG_UNCONNECTED(31 downto 0),
      FTMT_P2F_TRIGACK_0 => '0',
      FTMT_P2F_TRIGACK_1 => '0',
      FTMT_P2F_TRIGACK_2 => '0',
      FTMT_P2F_TRIGACK_3 => '0',
      FTMT_P2F_TRIG_0 => NLW_inst_FTMT_P2F_TRIG_0_UNCONNECTED,
      FTMT_P2F_TRIG_1 => NLW_inst_FTMT_P2F_TRIG_1_UNCONNECTED,
      FTMT_P2F_TRIG_2 => NLW_inst_FTMT_P2F_TRIG_2_UNCONNECTED,
      FTMT_P2F_TRIG_3 => NLW_inst_FTMT_P2F_TRIG_3_UNCONNECTED,
      GPIO_I(63 downto 0) => B"0000000000000000000000000000000000000000000000000000000000000000",
      GPIO_O(63 downto 0) => NLW_inst_GPIO_O_UNCONNECTED(63 downto 0),
      GPIO_T(63 downto 0) => NLW_inst_GPIO_T_UNCONNECTED(63 downto 0),
      I2C0_SCL_I => '0',
      I2C0_SCL_O => NLW_inst_I2C0_SCL_O_UNCONNECTED,
      I2C0_SCL_T => NLW_inst_I2C0_SCL_T_UNCONNECTED,
      I2C0_SDA_I => '0',
      I2C0_SDA_O => NLW_inst_I2C0_SDA_O_UNCONNECTED,
      I2C0_SDA_T => NLW_inst_I2C0_SDA_T_UNCONNECTED,
      I2C1_SCL_I => '0',
      I2C1_SCL_O => NLW_inst_I2C1_SCL_O_UNCONNECTED,
      I2C1_SCL_T => NLW_inst_I2C1_SCL_T_UNCONNECTED,
      I2C1_SDA_I => '0',
      I2C1_SDA_O => NLW_inst_I2C1_SDA_O_UNCONNECTED,
      I2C1_SDA_T => NLW_inst_I2C1_SDA_T_UNCONNECTED,
      IRQ_F2P(0) => '0',
      IRQ_P2F_CAN0 => NLW_inst_IRQ_P2F_CAN0_UNCONNECTED,
      IRQ_P2F_CAN1 => NLW_inst_IRQ_P2F_CAN1_UNCONNECTED,
      IRQ_P2F_CTI => NLW_inst_IRQ_P2F_CTI_UNCONNECTED,
      IRQ_P2F_DMAC0 => NLW_inst_IRQ_P2F_DMAC0_UNCONNECTED,
      IRQ_P2F_DMAC1 => NLW_inst_IRQ_P2F_DMAC1_UNCONNECTED,
      IRQ_P2F_DMAC2 => NLW_inst_IRQ_P2F_DMAC2_UNCONNECTED,
      IRQ_P2F_DMAC3 => NLW_inst_IRQ_P2F_DMAC3_UNCONNECTED,
      IRQ_P2F_DMAC4 => NLW_inst_IRQ_P2F_DMAC4_UNCONNECTED,
      IRQ_P2F_DMAC5 => NLW_inst_IRQ_P2F_DMAC5_UNCONNECTED,
      IRQ_P2F_DMAC6 => NLW_inst_IRQ_P2F_DMAC6_UNCONNECTED,
      IRQ_P2F_DMAC7 => NLW_inst_IRQ_P2F_DMAC7_UNCONNECTED,
      IRQ_P2F_DMAC_ABORT => NLW_inst_IRQ_P2F_DMAC_ABORT_UNCONNECTED,
      IRQ_P2F_ENET0 => NLW_inst_IRQ_P2F_ENET0_UNCONNECTED,
      IRQ_P2F_ENET1 => NLW_inst_IRQ_P2F_ENET1_UNCONNECTED,
      IRQ_P2F_ENET_WAKE0 => NLW_inst_IRQ_P2F_ENET_WAKE0_UNCONNECTED,
      IRQ_P2F_ENET_WAKE1 => NLW_inst_IRQ_P2F_ENET_WAKE1_UNCONNECTED,
      IRQ_P2F_GPIO => NLW_inst_IRQ_P2F_GPIO_UNCONNECTED,
      IRQ_P2F_I2C0 => NLW_inst_IRQ_P2F_I2C0_UNCONNECTED,
      IRQ_P2F_I2C1 => NLW_inst_IRQ_P2F_I2C1_UNCONNECTED,
      IRQ_P2F_QSPI => NLW_inst_IRQ_P2F_QSPI_UNCONNECTED,
      IRQ_P2F_SDIO0 => NLW_inst_IRQ_P2F_SDIO0_UNCONNECTED,
      IRQ_P2F_SDIO1 => NLW_inst_IRQ_P2F_SDIO1_UNCONNECTED,
      IRQ_P2F_SMC => NLW_inst_IRQ_P2F_SMC_UNCONNECTED,
      IRQ_P2F_SPI0 => NLW_inst_IRQ_P2F_SPI0_UNCONNECTED,
      IRQ_P2F_SPI1 => NLW_inst_IRQ_P2F_SPI1_UNCONNECTED,
      IRQ_P2F_UART0 => NLW_inst_IRQ_P2F_UART0_UNCONNECTED,
      IRQ_P2F_UART1 => NLW_inst_IRQ_P2F_UART1_UNCONNECTED,
      IRQ_P2F_USB0 => NLW_inst_IRQ_P2F_USB0_UNCONNECTED,
      IRQ_P2F_USB1 => NLW_inst_IRQ_P2F_USB1_UNCONNECTED,
      MIO(53 downto 0) => MIO(53 downto 0),
      M_AXI_GP0_ACLK => '0',
      M_AXI_GP0_ARADDR(31 downto 0) => NLW_inst_M_AXI_GP0_ARADDR_UNCONNECTED(31 downto 0),
      M_AXI_GP0_ARBURST(1 downto 0) => NLW_inst_M_AXI_GP0_ARBURST_UNCONNECTED(1 downto 0),
      M_AXI_GP0_ARCACHE(3 downto 0) => NLW_inst_M_AXI_GP0_ARCACHE_UNCONNECTED(3 downto 0),
      M_AXI_GP0_ARESETN => NLW_inst_M_AXI_GP0_ARESETN_UNCONNECTED,
      M_AXI_GP0_ARID(11 downto 0) => NLW_inst_M_AXI_GP0_ARID_UNCONNECTED(11 downto 0),
      M_AXI_GP0_ARLEN(3 downto 0) => NLW_inst_M_AXI_GP0_ARLEN_UNCONNECTED(3 downto 0),
      M_AXI_GP0_ARLOCK(1 downto 0) => NLW_inst_M_AXI_GP0_ARLOCK_UNCONNECTED(1 downto 0),
      M_AXI_GP0_ARPROT(2 downto 0) => NLW_inst_M_AXI_GP0_ARPROT_UNCONNECTED(2 downto 0),
      M_AXI_GP0_ARQOS(3 downto 0) => NLW_inst_M_AXI_GP0_ARQOS_UNCONNECTED(3 downto 0),
      M_AXI_GP0_ARREADY => '0',
      M_AXI_GP0_ARSIZE(2 downto 0) => NLW_inst_M_AXI_GP0_ARSIZE_UNCONNECTED(2 downto 0),
      M_AXI_GP0_ARVALID => NLW_inst_M_AXI_GP0_ARVALID_UNCONNECTED,
      M_AXI_GP0_AWADDR(31 downto 0) => NLW_inst_M_AXI_GP0_AWADDR_UNCONNECTED(31 downto 0),
      M_AXI_GP0_AWBURST(1 downto 0) => NLW_inst_M_AXI_GP0_AWBURST_UNCONNECTED(1 downto 0),
      M_AXI_GP0_AWCACHE(3 downto 0) => NLW_inst_M_AXI_GP0_AWCACHE_UNCONNECTED(3 downto 0),
      M_AXI_GP0_AWID(11 downto 0) => NLW_inst_M_AXI_GP0_AWID_UNCONNECTED(11 downto 0),
      M_AXI_GP0_AWLEN(3 downto 0) => NLW_inst_M_AXI_GP0_AWLEN_UNCONNECTED(3 downto 0),
      M_AXI_GP0_AWLOCK(1 downto 0) => NLW_inst_M_AXI_GP0_AWLOCK_UNCONNECTED(1 downto 0),
      M_AXI_GP0_AWPROT(2 downto 0) => NLW_inst_M_AXI_GP0_AWPROT_UNCONNECTED(2 downto 0),
      M_AXI_GP0_AWQOS(3 downto 0) => NLW_inst_M_AXI_GP0_AWQOS_UNCONNECTED(3 downto 0),
      M_AXI_GP0_AWREADY => '0',
      M_AXI_GP0_AWSIZE(2 downto 0) => NLW_inst_M_AXI_GP0_AWSIZE_UNCONNECTED(2 downto 0),
      M_AXI_GP0_AWVALID => NLW_inst_M_AXI_GP0_AWVALID_UNCONNECTED,
      M_AXI_GP0_BID(11 downto 0) => B"000000000000",
      M_AXI_GP0_BREADY => NLW_inst_M_AXI_GP0_BREADY_UNCONNECTED,
      M_AXI_GP0_BRESP(1 downto 0) => B"00",
      M_AXI_GP0_BVALID => '0',
      M_AXI_GP0_RDATA(31 downto 0) => B"00000000000000000000000000000000",
      M_AXI_GP0_RID(11 downto 0) => B"000000000000",
      M_AXI_GP0_RLAST => '0',
      M_AXI_GP0_RREADY => NLW_inst_M_AXI_GP0_RREADY_UNCONNECTED,
      M_AXI_GP0_RRESP(1 downto 0) => B"00",
      M_AXI_GP0_RVALID => '0',
      M_AXI_GP0_WDATA(31 downto 0) => NLW_inst_M_AXI_GP0_WDATA_UNCONNECTED(31 downto 0),
      M_AXI_GP0_WID(11 downto 0) => NLW_inst_M_AXI_GP0_WID_UNCONNECTED(11 downto 0),
      M_AXI_GP0_WLAST => NLW_inst_M_AXI_GP0_WLAST_UNCONNECTED,
      M_AXI_GP0_WREADY => '0',
      M_AXI_GP0_WSTRB(3 downto 0) => NLW_inst_M_AXI_GP0_WSTRB_UNCONNECTED(3 downto 0),
      M_AXI_GP0_WVALID => NLW_inst_M_AXI_GP0_WVALID_UNCONNECTED,
      M_AXI_GP1_ACLK => '0',
      M_AXI_GP1_ARADDR(31 downto 0) => NLW_inst_M_AXI_GP1_ARADDR_UNCONNECTED(31 downto 0),
      M_AXI_GP1_ARBURST(1 downto 0) => NLW_inst_M_AXI_GP1_ARBURST_UNCONNECTED(1 downto 0),
      M_AXI_GP1_ARCACHE(3 downto 0) => NLW_inst_M_AXI_GP1_ARCACHE_UNCONNECTED(3 downto 0),
      M_AXI_GP1_ARESETN => NLW_inst_M_AXI_GP1_ARESETN_UNCONNECTED,
      M_AXI_GP1_ARID(11 downto 0) => NLW_inst_M_AXI_GP1_ARID_UNCONNECTED(11 downto 0),
      M_AXI_GP1_ARLEN(3 downto 0) => NLW_inst_M_AXI_GP1_ARLEN_UNCONNECTED(3 downto 0),
      M_AXI_GP1_ARLOCK(1 downto 0) => NLW_inst_M_AXI_GP1_ARLOCK_UNCONNECTED(1 downto 0),
      M_AXI_GP1_ARPROT(2 downto 0) => NLW_inst_M_AXI_GP1_ARPROT_UNCONNECTED(2 downto 0),
      M_AXI_GP1_ARQOS(3 downto 0) => NLW_inst_M_AXI_GP1_ARQOS_UNCONNECTED(3 downto 0),
      M_AXI_GP1_ARREADY => '0',
      M_AXI_GP1_ARSIZE(2 downto 0) => NLW_inst_M_AXI_GP1_ARSIZE_UNCONNECTED(2 downto 0),
      M_AXI_GP1_ARVALID => NLW_inst_M_AXI_GP1_ARVALID_UNCONNECTED,
      M_AXI_GP1_AWADDR(31 downto 0) => NLW_inst_M_AXI_GP1_AWADDR_UNCONNECTED(31 downto 0),
      M_AXI_GP1_AWBURST(1 downto 0) => NLW_inst_M_AXI_GP1_AWBURST_UNCONNECTED(1 downto 0),
      M_AXI_GP1_AWCACHE(3 downto 0) => NLW_inst_M_AXI_GP1_AWCACHE_UNCONNECTED(3 downto 0),
      M_AXI_GP1_AWID(11 downto 0) => NLW_inst_M_AXI_GP1_AWID_UNCONNECTED(11 downto 0),
      M_AXI_GP1_AWLEN(3 downto 0) => NLW_inst_M_AXI_GP1_AWLEN_UNCONNECTED(3 downto 0),
      M_AXI_GP1_AWLOCK(1 downto 0) => NLW_inst_M_AXI_GP1_AWLOCK_UNCONNECTED(1 downto 0),
      M_AXI_GP1_AWPROT(2 downto 0) => NLW_inst_M_AXI_GP1_AWPROT_UNCONNECTED(2 downto 0),
      M_AXI_GP1_AWQOS(3 downto 0) => NLW_inst_M_AXI_GP1_AWQOS_UNCONNECTED(3 downto 0),
      M_AXI_GP1_AWREADY => '0',
      M_AXI_GP1_AWSIZE(2 downto 0) => NLW_inst_M_AXI_GP1_AWSIZE_UNCONNECTED(2 downto 0),
      M_AXI_GP1_AWVALID => NLW_inst_M_AXI_GP1_AWVALID_UNCONNECTED,
      M_AXI_GP1_BID(11 downto 0) => B"000000000000",
      M_AXI_GP1_BREADY => NLW_inst_M_AXI_GP1_BREADY_UNCONNECTED,
      M_AXI_GP1_BRESP(1 downto 0) => B"00",
      M_AXI_GP1_BVALID => '0',
      M_AXI_GP1_RDATA(31 downto 0) => B"00000000000000000000000000000000",
      M_AXI_GP1_RID(11 downto 0) => B"000000000000",
      M_AXI_GP1_RLAST => '0',
      M_AXI_GP1_RREADY => NLW_inst_M_AXI_GP1_RREADY_UNCONNECTED,
      M_AXI_GP1_RRESP(1 downto 0) => B"00",
      M_AXI_GP1_RVALID => '0',
      M_AXI_GP1_WDATA(31 downto 0) => NLW_inst_M_AXI_GP1_WDATA_UNCONNECTED(31 downto 0),
      M_AXI_GP1_WID(11 downto 0) => NLW_inst_M_AXI_GP1_WID_UNCONNECTED(11 downto 0),
      M_AXI_GP1_WLAST => NLW_inst_M_AXI_GP1_WLAST_UNCONNECTED,
      M_AXI_GP1_WREADY => '0',
      M_AXI_GP1_WSTRB(3 downto 0) => NLW_inst_M_AXI_GP1_WSTRB_UNCONNECTED(3 downto 0),
      M_AXI_GP1_WVALID => NLW_inst_M_AXI_GP1_WVALID_UNCONNECTED,
      PJTAG_TCK => '0',
      PJTAG_TDI => '0',
      PJTAG_TDO => NLW_inst_PJTAG_TDO_UNCONNECTED,
      PJTAG_TMS => '0',
      PS_CLK => PS_CLK,
      PS_PORB => PS_PORB,
      PS_SRSTB => PS_SRSTB,
      SDIO0_BUSPOW => NLW_inst_SDIO0_BUSPOW_UNCONNECTED,
      SDIO0_BUSVOLT(2 downto 0) => NLW_inst_SDIO0_BUSVOLT_UNCONNECTED(2 downto 0),
      SDIO0_CDN => '0',
      SDIO0_CLK => NLW_inst_SDIO0_CLK_UNCONNECTED,
      SDIO0_CLK_FB => '0',
      SDIO0_CMD_I => '0',
      SDIO0_CMD_O => NLW_inst_SDIO0_CMD_O_UNCONNECTED,
      SDIO0_CMD_T => NLW_inst_SDIO0_CMD_T_UNCONNECTED,
      SDIO0_DATA_I(3 downto 0) => B"0000",
      SDIO0_DATA_O(3 downto 0) => NLW_inst_SDIO0_DATA_O_UNCONNECTED(3 downto 0),
      SDIO0_DATA_T(3 downto 0) => NLW_inst_SDIO0_DATA_T_UNCONNECTED(3 downto 0),
      SDIO0_LED => NLW_inst_SDIO0_LED_UNCONNECTED,
      SDIO0_WP => '0',
      SDIO1_BUSPOW => NLW_inst_SDIO1_BUSPOW_UNCONNECTED,
      SDIO1_BUSVOLT(2 downto 0) => NLW_inst_SDIO1_BUSVOLT_UNCONNECTED(2 downto 0),
      SDIO1_CDN => '0',
      SDIO1_CLK => NLW_inst_SDIO1_CLK_UNCONNECTED,
      SDIO1_CLK_FB => '0',
      SDIO1_CMD_I => '0',
      SDIO1_CMD_O => NLW_inst_SDIO1_CMD_O_UNCONNECTED,
      SDIO1_CMD_T => NLW_inst_SDIO1_CMD_T_UNCONNECTED,
      SDIO1_DATA_I(3 downto 0) => B"0000",
      SDIO1_DATA_O(3 downto 0) => NLW_inst_SDIO1_DATA_O_UNCONNECTED(3 downto 0),
      SDIO1_DATA_T(3 downto 0) => NLW_inst_SDIO1_DATA_T_UNCONNECTED(3 downto 0),
      SDIO1_LED => NLW_inst_SDIO1_LED_UNCONNECTED,
      SDIO1_WP => '0',
      SPI0_MISO_I => '0',
      SPI0_MISO_O => NLW_inst_SPI0_MISO_O_UNCONNECTED,
      SPI0_MISO_T => NLW_inst_SPI0_MISO_T_UNCONNECTED,
      SPI0_MOSI_I => '0',
      SPI0_MOSI_O => NLW_inst_SPI0_MOSI_O_UNCONNECTED,
      SPI0_MOSI_T => NLW_inst_SPI0_MOSI_T_UNCONNECTED,
      SPI0_SCLK_I => '0',
      SPI0_SCLK_O => NLW_inst_SPI0_SCLK_O_UNCONNECTED,
      SPI0_SCLK_T => NLW_inst_SPI0_SCLK_T_UNCONNECTED,
      SPI0_SS1_O => NLW_inst_SPI0_SS1_O_UNCONNECTED,
      SPI0_SS2_O => NLW_inst_SPI0_SS2_O_UNCONNECTED,
      SPI0_SS_I => '0',
      SPI0_SS_O => NLW_inst_SPI0_SS_O_UNCONNECTED,
      SPI0_SS_T => NLW_inst_SPI0_SS_T_UNCONNECTED,
      SPI1_MISO_I => '0',
      SPI1_MISO_O => NLW_inst_SPI1_MISO_O_UNCONNECTED,
      SPI1_MISO_T => NLW_inst_SPI1_MISO_T_UNCONNECTED,
      SPI1_MOSI_I => '0',
      SPI1_MOSI_O => NLW_inst_SPI1_MOSI_O_UNCONNECTED,
      SPI1_MOSI_T => NLW_inst_SPI1_MOSI_T_UNCONNECTED,
      SPI1_SCLK_I => '0',
      SPI1_SCLK_O => NLW_inst_SPI1_SCLK_O_UNCONNECTED,
      SPI1_SCLK_T => NLW_inst_SPI1_SCLK_T_UNCONNECTED,
      SPI1_SS1_O => NLW_inst_SPI1_SS1_O_UNCONNECTED,
      SPI1_SS2_O => NLW_inst_SPI1_SS2_O_UNCONNECTED,
      SPI1_SS_I => '0',
      SPI1_SS_O => NLW_inst_SPI1_SS_O_UNCONNECTED,
      SPI1_SS_T => NLW_inst_SPI1_SS_T_UNCONNECTED,
      SRAM_INTIN => '0',
      S_AXI_ACP_ACLK => '0',
      S_AXI_ACP_ARADDR(31 downto 0) => B"00000000000000000000000000000000",
      S_AXI_ACP_ARBURST(1 downto 0) => B"00",
      S_AXI_ACP_ARCACHE(3 downto 0) => B"0000",
      S_AXI_ACP_ARESETN => NLW_inst_S_AXI_ACP_ARESETN_UNCONNECTED,
      S_AXI_ACP_ARID(2 downto 0) => B"000",
      S_AXI_ACP_ARLEN(3 downto 0) => B"0000",
      S_AXI_ACP_ARLOCK(1 downto 0) => B"00",
      S_AXI_ACP_ARPROT(2 downto 0) => B"000",
      S_AXI_ACP_ARQOS(3 downto 0) => B"0000",
      S_AXI_ACP_ARREADY => NLW_inst_S_AXI_ACP_ARREADY_UNCONNECTED,
      S_AXI_ACP_ARSIZE(2 downto 0) => B"000",
      S_AXI_ACP_ARUSER(4 downto 0) => B"00000",
      S_AXI_ACP_ARVALID => '0',
      S_AXI_ACP_AWADDR(31 downto 0) => B"00000000000000000000000000000000",
      S_AXI_ACP_AWBURST(1 downto 0) => B"00",
      S_AXI_ACP_AWCACHE(3 downto 0) => B"0000",
      S_AXI_ACP_AWID(2 downto 0) => B"000",
      S_AXI_ACP_AWLEN(3 downto 0) => B"0000",
      S_AXI_ACP_AWLOCK(1 downto 0) => B"00",
      S_AXI_ACP_AWPROT(2 downto 0) => B"000",
      S_AXI_ACP_AWQOS(3 downto 0) => B"0000",
      S_AXI_ACP_AWREADY => NLW_inst_S_AXI_ACP_AWREADY_UNCONNECTED,
      S_AXI_ACP_AWSIZE(2 downto 0) => B"000",
      S_AXI_ACP_AWUSER(4 downto 0) => B"00000",
      S_AXI_ACP_AWVALID => '0',
      S_AXI_ACP_BID(2 downto 0) => NLW_inst_S_AXI_ACP_BID_UNCONNECTED(2 downto 0),
      S_AXI_ACP_BREADY => '0',
      S_AXI_ACP_BRESP(1 downto 0) => NLW_inst_S_AXI_ACP_BRESP_UNCONNECTED(1 downto 0),
      S_AXI_ACP_BVALID => NLW_inst_S_AXI_ACP_BVALID_UNCONNECTED,
      S_AXI_ACP_RDATA(63 downto 0) => NLW_inst_S_AXI_ACP_RDATA_UNCONNECTED(63 downto 0),
      S_AXI_ACP_RID(2 downto 0) => NLW_inst_S_AXI_ACP_RID_UNCONNECTED(2 downto 0),
      S_AXI_ACP_RLAST => NLW_inst_S_AXI_ACP_RLAST_UNCONNECTED,
      S_AXI_ACP_RREADY => '0',
      S_AXI_ACP_RRESP(1 downto 0) => NLW_inst_S_AXI_ACP_RRESP_UNCONNECTED(1 downto 0),
      S_AXI_ACP_RVALID => NLW_inst_S_AXI_ACP_RVALID_UNCONNECTED,
      S_AXI_ACP_WDATA(63 downto 0) => B"0000000000000000000000000000000000000000000000000000000000000000",
      S_AXI_ACP_WID(2 downto 0) => B"000",
      S_AXI_ACP_WLAST => '0',
      S_AXI_ACP_WREADY => NLW_inst_S_AXI_ACP_WREADY_UNCONNECTED,
      S_AXI_ACP_WSTRB(7 downto 0) => B"00000000",
      S_AXI_ACP_WVALID => '0',
      S_AXI_GP0_ACLK => '0',
      S_AXI_GP0_ARADDR(31 downto 0) => B"00000000000000000000000000000000",
      S_AXI_GP0_ARBURST(1 downto 0) => B"00",
      S_AXI_GP0_ARCACHE(3 downto 0) => B"0000",
      S_AXI_GP0_ARESETN => NLW_inst_S_AXI_GP0_ARESETN_UNCONNECTED,
      S_AXI_GP0_ARID(5 downto 0) => B"000000",
      S_AXI_GP0_ARLEN(3 downto 0) => B"0000",
      S_AXI_GP0_ARLOCK(1 downto 0) => B"00",
      S_AXI_GP0_ARPROT(2 downto 0) => B"000",
      S_AXI_GP0_ARQOS(3 downto 0) => B"0000",
      S_AXI_GP0_ARREADY => NLW_inst_S_AXI_GP0_ARREADY_UNCONNECTED,
      S_AXI_GP0_ARSIZE(2 downto 0) => B"000",
      S_AXI_GP0_ARVALID => '0',
      S_AXI_GP0_AWADDR(31 downto 0) => B"00000000000000000000000000000000",
      S_AXI_GP0_AWBURST(1 downto 0) => B"00",
      S_AXI_GP0_AWCACHE(3 downto 0) => B"0000",
      S_AXI_GP0_AWID(5 downto 0) => B"000000",
      S_AXI_GP0_AWLEN(3 downto 0) => B"0000",
      S_AXI_GP0_AWLOCK(1 downto 0) => B"00",
      S_AXI_GP0_AWPROT(2 downto 0) => B"000",
      S_AXI_GP0_AWQOS(3 downto 0) => B"0000",
      S_AXI_GP0_AWREADY => NLW_inst_S_AXI_GP0_AWREADY_UNCONNECTED,
      S_AXI_GP0_AWSIZE(2 downto 0) => B"000",
      S_AXI_GP0_AWVALID => '0',
      S_AXI_GP0_BID(5 downto 0) => NLW_inst_S_AXI_GP0_BID_UNCONNECTED(5 downto 0),
      S_AXI_GP0_BREADY => '0',
      S_AXI_GP0_BRESP(1 downto 0) => NLW_inst_S_AXI_GP0_BRESP_UNCONNECTED(1 downto 0),
      S_AXI_GP0_BVALID => NLW_inst_S_AXI_GP0_BVALID_UNCONNECTED,
      S_AXI_GP0_RDATA(31 downto 0) => NLW_inst_S_AXI_GP0_RDATA_UNCONNECTED(31 downto 0),
      S_AXI_GP0_RID(5 downto 0) => NLW_inst_S_AXI_GP0_RID_UNCONNECTED(5 downto 0),
      S_AXI_GP0_RLAST => NLW_inst_S_AXI_GP0_RLAST_UNCONNECTED,
      S_AXI_GP0_RREADY => '0',
      S_AXI_GP0_RRESP(1 downto 0) => NLW_inst_S_AXI_GP0_RRESP_UNCONNECTED(1 downto 0),
      S_AXI_GP0_RVALID => NLW_inst_S_AXI_GP0_RVALID_UNCONNECTED,
      S_AXI_GP0_WDATA(31 downto 0) => B"00000000000000000000000000000000",
      S_AXI_GP0_WID(5 downto 0) => B"000000",
      S_AXI_GP0_WLAST => '0',
      S_AXI_GP0_WREADY => NLW_inst_S_AXI_GP0_WREADY_UNCONNECTED,
      S_AXI_GP0_WSTRB(3 downto 0) => B"0000",
      S_AXI_GP0_WVALID => '0',
      S_AXI_GP1_ACLK => '0',
      S_AXI_GP1_ARADDR(31 downto 0) => B"00000000000000000000000000000000",
      S_AXI_GP1_ARBURST(1 downto 0) => B"00",
      S_AXI_GP1_ARCACHE(3 downto 0) => B"0000",
      S_AXI_GP1_ARESETN => NLW_inst_S_AXI_GP1_ARESETN_UNCONNECTED,
      S_AXI_GP1_ARID(5 downto 0) => B"000000",
      S_AXI_GP1_ARLEN(3 downto 0) => B"0000",
      S_AXI_GP1_ARLOCK(1 downto 0) => B"00",
      S_AXI_GP1_ARPROT(2 downto 0) => B"000",
      S_AXI_GP1_ARQOS(3 downto 0) => B"0000",
      S_AXI_GP1_ARREADY => NLW_inst_S_AXI_GP1_ARREADY_UNCONNECTED,
      S_AXI_GP1_ARSIZE(2 downto 0) => B"000",
      S_AXI_GP1_ARVALID => '0',
      S_AXI_GP1_AWADDR(31 downto 0) => B"00000000000000000000000000000000",
      S_AXI_GP1_AWBURST(1 downto 0) => B"00",
      S_AXI_GP1_AWCACHE(3 downto 0) => B"0000",
      S_AXI_GP1_AWID(5 downto 0) => B"000000",
      S_AXI_GP1_AWLEN(3 downto 0) => B"0000",
      S_AXI_GP1_AWLOCK(1 downto 0) => B"00",
      S_AXI_GP1_AWPROT(2 downto 0) => B"000",
      S_AXI_GP1_AWQOS(3 downto 0) => B"0000",
      S_AXI_GP1_AWREADY => NLW_inst_S_AXI_GP1_AWREADY_UNCONNECTED,
      S_AXI_GP1_AWSIZE(2 downto 0) => B"000",
      S_AXI_GP1_AWVALID => '0',
      S_AXI_GP1_BID(5 downto 0) => NLW_inst_S_AXI_GP1_BID_UNCONNECTED(5 downto 0),
      S_AXI_GP1_BREADY => '0',
      S_AXI_GP1_BRESP(1 downto 0) => NLW_inst_S_AXI_GP1_BRESP_UNCONNECTED(1 downto 0),
      S_AXI_GP1_BVALID => NLW_inst_S_AXI_GP1_BVALID_UNCONNECTED,
      S_AXI_GP1_RDATA(31 downto 0) => NLW_inst_S_AXI_GP1_RDATA_UNCONNECTED(31 downto 0),
      S_AXI_GP1_RID(5 downto 0) => NLW_inst_S_AXI_GP1_RID_UNCONNECTED(5 downto 0),
      S_AXI_GP1_RLAST => NLW_inst_S_AXI_GP1_RLAST_UNCONNECTED,
      S_AXI_GP1_RREADY => '0',
      S_AXI_GP1_RRESP(1 downto 0) => NLW_inst_S_AXI_GP1_RRESP_UNCONNECTED(1 downto 0),
      S_AXI_GP1_RVALID => NLW_inst_S_AXI_GP1_RVALID_UNCONNECTED,
      S_AXI_GP1_WDATA(31 downto 0) => B"00000000000000000000000000000000",
      S_AXI_GP1_WID(5 downto 0) => B"000000",
      S_AXI_GP1_WLAST => '0',
      S_AXI_GP1_WREADY => NLW_inst_S_AXI_GP1_WREADY_UNCONNECTED,
      S_AXI_GP1_WSTRB(3 downto 0) => B"0000",
      S_AXI_GP1_WVALID => '0',
      S_AXI_HP0_ACLK => S_AXI_HP0_ACLK,
      S_AXI_HP0_ARADDR(31 downto 0) => S_AXI_HP0_ARADDR(31 downto 0),
      S_AXI_HP0_ARBURST(1 downto 0) => S_AXI_HP0_ARBURST(1 downto 0),
      S_AXI_HP0_ARCACHE(3 downto 0) => S_AXI_HP0_ARCACHE(3 downto 0),
      S_AXI_HP0_ARESETN => NLW_inst_S_AXI_HP0_ARESETN_UNCONNECTED,
      S_AXI_HP0_ARID(5 downto 0) => S_AXI_HP0_ARID(5 downto 0),
      S_AXI_HP0_ARLEN(3 downto 0) => S_AXI_HP0_ARLEN(3 downto 0),
      S_AXI_HP0_ARLOCK(1 downto 0) => S_AXI_HP0_ARLOCK(1 downto 0),
      S_AXI_HP0_ARPROT(2 downto 0) => S_AXI_HP0_ARPROT(2 downto 0),
      S_AXI_HP0_ARQOS(3 downto 0) => S_AXI_HP0_ARQOS(3 downto 0),
      S_AXI_HP0_ARREADY => S_AXI_HP0_ARREADY,
      S_AXI_HP0_ARSIZE(2) => '0',
      S_AXI_HP0_ARSIZE(1 downto 0) => S_AXI_HP0_ARSIZE(1 downto 0),
      S_AXI_HP0_ARVALID => S_AXI_HP0_ARVALID,
      S_AXI_HP0_AWADDR(31 downto 0) => S_AXI_HP0_AWADDR(31 downto 0),
      S_AXI_HP0_AWBURST(1 downto 0) => S_AXI_HP0_AWBURST(1 downto 0),
      S_AXI_HP0_AWCACHE(3 downto 0) => S_AXI_HP0_AWCACHE(3 downto 0),
      S_AXI_HP0_AWID(5 downto 0) => S_AXI_HP0_AWID(5 downto 0),
      S_AXI_HP0_AWLEN(3 downto 0) => S_AXI_HP0_AWLEN(3 downto 0),
      S_AXI_HP0_AWLOCK(1 downto 0) => S_AXI_HP0_AWLOCK(1 downto 0),
      S_AXI_HP0_AWPROT(2 downto 0) => S_AXI_HP0_AWPROT(2 downto 0),
      S_AXI_HP0_AWQOS(3 downto 0) => S_AXI_HP0_AWQOS(3 downto 0),
      S_AXI_HP0_AWREADY => S_AXI_HP0_AWREADY,
      S_AXI_HP0_AWSIZE(2) => '0',
      S_AXI_HP0_AWSIZE(1 downto 0) => S_AXI_HP0_AWSIZE(1 downto 0),
      S_AXI_HP0_AWVALID => S_AXI_HP0_AWVALID,
      S_AXI_HP0_BID(5 downto 0) => S_AXI_HP0_BID(5 downto 0),
      S_AXI_HP0_BREADY => S_AXI_HP0_BREADY,
      S_AXI_HP0_BRESP(1 downto 0) => S_AXI_HP0_BRESP(1 downto 0),
      S_AXI_HP0_BVALID => S_AXI_HP0_BVALID,
      S_AXI_HP0_RACOUNT(2 downto 0) => S_AXI_HP0_RACOUNT(2 downto 0),
      S_AXI_HP0_RCOUNT(7 downto 0) => S_AXI_HP0_RCOUNT(7 downto 0),
      S_AXI_HP0_RDATA(63 downto 0) => S_AXI_HP0_RDATA(63 downto 0),
      S_AXI_HP0_RDISSUECAP1_EN => S_AXI_HP0_RDISSUECAP1_EN,
      S_AXI_HP0_RID(5 downto 0) => S_AXI_HP0_RID(5 downto 0),
      S_AXI_HP0_RLAST => S_AXI_HP0_RLAST,
      S_AXI_HP0_RREADY => S_AXI_HP0_RREADY,
      S_AXI_HP0_RRESP(1 downto 0) => S_AXI_HP0_RRESP(1 downto 0),
      S_AXI_HP0_RVALID => S_AXI_HP0_RVALID,
      S_AXI_HP0_WACOUNT(5 downto 0) => S_AXI_HP0_WACOUNT(5 downto 0),
      S_AXI_HP0_WCOUNT(7 downto 0) => S_AXI_HP0_WCOUNT(7 downto 0),
      S_AXI_HP0_WDATA(63 downto 0) => S_AXI_HP0_WDATA(63 downto 0),
      S_AXI_HP0_WID(5 downto 0) => S_AXI_HP0_WID(5 downto 0),
      S_AXI_HP0_WLAST => S_AXI_HP0_WLAST,
      S_AXI_HP0_WREADY => S_AXI_HP0_WREADY,
      S_AXI_HP0_WRISSUECAP1_EN => S_AXI_HP0_WRISSUECAP1_EN,
      S_AXI_HP0_WSTRB(7 downto 0) => S_AXI_HP0_WSTRB(7 downto 0),
      S_AXI_HP0_WVALID => S_AXI_HP0_WVALID,
      S_AXI_HP1_ACLK => '0',
      S_AXI_HP1_ARADDR(31 downto 0) => B"00000000000000000000000000000000",
      S_AXI_HP1_ARBURST(1 downto 0) => B"00",
      S_AXI_HP1_ARCACHE(3 downto 0) => B"0000",
      S_AXI_HP1_ARESETN => NLW_inst_S_AXI_HP1_ARESETN_UNCONNECTED,
      S_AXI_HP1_ARID(5 downto 0) => B"000000",
      S_AXI_HP1_ARLEN(3 downto 0) => B"0000",
      S_AXI_HP1_ARLOCK(1 downto 0) => B"00",
      S_AXI_HP1_ARPROT(2 downto 0) => B"000",
      S_AXI_HP1_ARQOS(3 downto 0) => B"0000",
      S_AXI_HP1_ARREADY => NLW_inst_S_AXI_HP1_ARREADY_UNCONNECTED,
      S_AXI_HP1_ARSIZE(2 downto 0) => B"000",
      S_AXI_HP1_ARVALID => '0',
      S_AXI_HP1_AWADDR(31 downto 0) => B"00000000000000000000000000000000",
      S_AXI_HP1_AWBURST(1 downto 0) => B"00",
      S_AXI_HP1_AWCACHE(3 downto 0) => B"0000",
      S_AXI_HP1_AWID(5 downto 0) => B"000000",
      S_AXI_HP1_AWLEN(3 downto 0) => B"0000",
      S_AXI_HP1_AWLOCK(1 downto 0) => B"00",
      S_AXI_HP1_AWPROT(2 downto 0) => B"000",
      S_AXI_HP1_AWQOS(3 downto 0) => B"0000",
      S_AXI_HP1_AWREADY => NLW_inst_S_AXI_HP1_AWREADY_UNCONNECTED,
      S_AXI_HP1_AWSIZE(2 downto 0) => B"000",
      S_AXI_HP1_AWVALID => '0',
      S_AXI_HP1_BID(5 downto 0) => NLW_inst_S_AXI_HP1_BID_UNCONNECTED(5 downto 0),
      S_AXI_HP1_BREADY => '0',
      S_AXI_HP1_BRESP(1 downto 0) => NLW_inst_S_AXI_HP1_BRESP_UNCONNECTED(1 downto 0),
      S_AXI_HP1_BVALID => NLW_inst_S_AXI_HP1_BVALID_UNCONNECTED,
      S_AXI_HP1_RACOUNT(2 downto 0) => NLW_inst_S_AXI_HP1_RACOUNT_UNCONNECTED(2 downto 0),
      S_AXI_HP1_RCOUNT(7 downto 0) => NLW_inst_S_AXI_HP1_RCOUNT_UNCONNECTED(7 downto 0),
      S_AXI_HP1_RDATA(63 downto 0) => NLW_inst_S_AXI_HP1_RDATA_UNCONNECTED(63 downto 0),
      S_AXI_HP1_RDISSUECAP1_EN => '0',
      S_AXI_HP1_RID(5 downto 0) => NLW_inst_S_AXI_HP1_RID_UNCONNECTED(5 downto 0),
      S_AXI_HP1_RLAST => NLW_inst_S_AXI_HP1_RLAST_UNCONNECTED,
      S_AXI_HP1_RREADY => '0',
      S_AXI_HP1_RRESP(1 downto 0) => NLW_inst_S_AXI_HP1_RRESP_UNCONNECTED(1 downto 0),
      S_AXI_HP1_RVALID => NLW_inst_S_AXI_HP1_RVALID_UNCONNECTED,
      S_AXI_HP1_WACOUNT(5 downto 0) => NLW_inst_S_AXI_HP1_WACOUNT_UNCONNECTED(5 downto 0),
      S_AXI_HP1_WCOUNT(7 downto 0) => NLW_inst_S_AXI_HP1_WCOUNT_UNCONNECTED(7 downto 0),
      S_AXI_HP1_WDATA(63 downto 0) => B"0000000000000000000000000000000000000000000000000000000000000000",
      S_AXI_HP1_WID(5 downto 0) => B"000000",
      S_AXI_HP1_WLAST => '0',
      S_AXI_HP1_WREADY => NLW_inst_S_AXI_HP1_WREADY_UNCONNECTED,
      S_AXI_HP1_WRISSUECAP1_EN => '0',
      S_AXI_HP1_WSTRB(7 downto 0) => B"00000000",
      S_AXI_HP1_WVALID => '0',
      S_AXI_HP2_ACLK => '0',
      S_AXI_HP2_ARADDR(31 downto 0) => B"00000000000000000000000000000000",
      S_AXI_HP2_ARBURST(1 downto 0) => B"00",
      S_AXI_HP2_ARCACHE(3 downto 0) => B"0000",
      S_AXI_HP2_ARESETN => NLW_inst_S_AXI_HP2_ARESETN_UNCONNECTED,
      S_AXI_HP2_ARID(5 downto 0) => B"000000",
      S_AXI_HP2_ARLEN(3 downto 0) => B"0000",
      S_AXI_HP2_ARLOCK(1 downto 0) => B"00",
      S_AXI_HP2_ARPROT(2 downto 0) => B"000",
      S_AXI_HP2_ARQOS(3 downto 0) => B"0000",
      S_AXI_HP2_ARREADY => NLW_inst_S_AXI_HP2_ARREADY_UNCONNECTED,
      S_AXI_HP2_ARSIZE(2 downto 0) => B"000",
      S_AXI_HP2_ARVALID => '0',
      S_AXI_HP2_AWADDR(31 downto 0) => B"00000000000000000000000000000000",
      S_AXI_HP2_AWBURST(1 downto 0) => B"00",
      S_AXI_HP2_AWCACHE(3 downto 0) => B"0000",
      S_AXI_HP2_AWID(5 downto 0) => B"000000",
      S_AXI_HP2_AWLEN(3 downto 0) => B"0000",
      S_AXI_HP2_AWLOCK(1 downto 0) => B"00",
      S_AXI_HP2_AWPROT(2 downto 0) => B"000",
      S_AXI_HP2_AWQOS(3 downto 0) => B"0000",
      S_AXI_HP2_AWREADY => NLW_inst_S_AXI_HP2_AWREADY_UNCONNECTED,
      S_AXI_HP2_AWSIZE(2 downto 0) => B"000",
      S_AXI_HP2_AWVALID => '0',
      S_AXI_HP2_BID(5 downto 0) => NLW_inst_S_AXI_HP2_BID_UNCONNECTED(5 downto 0),
      S_AXI_HP2_BREADY => '0',
      S_AXI_HP2_BRESP(1 downto 0) => NLW_inst_S_AXI_HP2_BRESP_UNCONNECTED(1 downto 0),
      S_AXI_HP2_BVALID => NLW_inst_S_AXI_HP2_BVALID_UNCONNECTED,
      S_AXI_HP2_RACOUNT(2 downto 0) => NLW_inst_S_AXI_HP2_RACOUNT_UNCONNECTED(2 downto 0),
      S_AXI_HP2_RCOUNT(7 downto 0) => NLW_inst_S_AXI_HP2_RCOUNT_UNCONNECTED(7 downto 0),
      S_AXI_HP2_RDATA(63 downto 0) => NLW_inst_S_AXI_HP2_RDATA_UNCONNECTED(63 downto 0),
      S_AXI_HP2_RDISSUECAP1_EN => '0',
      S_AXI_HP2_RID(5 downto 0) => NLW_inst_S_AXI_HP2_RID_UNCONNECTED(5 downto 0),
      S_AXI_HP2_RLAST => NLW_inst_S_AXI_HP2_RLAST_UNCONNECTED,
      S_AXI_HP2_RREADY => '0',
      S_AXI_HP2_RRESP(1 downto 0) => NLW_inst_S_AXI_HP2_RRESP_UNCONNECTED(1 downto 0),
      S_AXI_HP2_RVALID => NLW_inst_S_AXI_HP2_RVALID_UNCONNECTED,
      S_AXI_HP2_WACOUNT(5 downto 0) => NLW_inst_S_AXI_HP2_WACOUNT_UNCONNECTED(5 downto 0),
      S_AXI_HP2_WCOUNT(7 downto 0) => NLW_inst_S_AXI_HP2_WCOUNT_UNCONNECTED(7 downto 0),
      S_AXI_HP2_WDATA(63 downto 0) => B"0000000000000000000000000000000000000000000000000000000000000000",
      S_AXI_HP2_WID(5 downto 0) => B"000000",
      S_AXI_HP2_WLAST => '0',
      S_AXI_HP2_WREADY => NLW_inst_S_AXI_HP2_WREADY_UNCONNECTED,
      S_AXI_HP2_WRISSUECAP1_EN => '0',
      S_AXI_HP2_WSTRB(7 downto 0) => B"00000000",
      S_AXI_HP2_WVALID => '0',
      S_AXI_HP3_ACLK => '0',
      S_AXI_HP3_ARADDR(31 downto 0) => B"00000000000000000000000000000000",
      S_AXI_HP3_ARBURST(1 downto 0) => B"00",
      S_AXI_HP3_ARCACHE(3 downto 0) => B"0000",
      S_AXI_HP3_ARESETN => NLW_inst_S_AXI_HP3_ARESETN_UNCONNECTED,
      S_AXI_HP3_ARID(5 downto 0) => B"000000",
      S_AXI_HP3_ARLEN(3 downto 0) => B"0000",
      S_AXI_HP3_ARLOCK(1 downto 0) => B"00",
      S_AXI_HP3_ARPROT(2 downto 0) => B"000",
      S_AXI_HP3_ARQOS(3 downto 0) => B"0000",
      S_AXI_HP3_ARREADY => NLW_inst_S_AXI_HP3_ARREADY_UNCONNECTED,
      S_AXI_HP3_ARSIZE(2 downto 0) => B"000",
      S_AXI_HP3_ARVALID => '0',
      S_AXI_HP3_AWADDR(31 downto 0) => B"00000000000000000000000000000000",
      S_AXI_HP3_AWBURST(1 downto 0) => B"00",
      S_AXI_HP3_AWCACHE(3 downto 0) => B"0000",
      S_AXI_HP3_AWID(5 downto 0) => B"000000",
      S_AXI_HP3_AWLEN(3 downto 0) => B"0000",
      S_AXI_HP3_AWLOCK(1 downto 0) => B"00",
      S_AXI_HP3_AWPROT(2 downto 0) => B"000",
      S_AXI_HP3_AWQOS(3 downto 0) => B"0000",
      S_AXI_HP3_AWREADY => NLW_inst_S_AXI_HP3_AWREADY_UNCONNECTED,
      S_AXI_HP3_AWSIZE(2 downto 0) => B"000",
      S_AXI_HP3_AWVALID => '0',
      S_AXI_HP3_BID(5 downto 0) => NLW_inst_S_AXI_HP3_BID_UNCONNECTED(5 downto 0),
      S_AXI_HP3_BREADY => '0',
      S_AXI_HP3_BRESP(1 downto 0) => NLW_inst_S_AXI_HP3_BRESP_UNCONNECTED(1 downto 0),
      S_AXI_HP3_BVALID => NLW_inst_S_AXI_HP3_BVALID_UNCONNECTED,
      S_AXI_HP3_RACOUNT(2 downto 0) => NLW_inst_S_AXI_HP3_RACOUNT_UNCONNECTED(2 downto 0),
      S_AXI_HP3_RCOUNT(7 downto 0) => NLW_inst_S_AXI_HP3_RCOUNT_UNCONNECTED(7 downto 0),
      S_AXI_HP3_RDATA(63 downto 0) => NLW_inst_S_AXI_HP3_RDATA_UNCONNECTED(63 downto 0),
      S_AXI_HP3_RDISSUECAP1_EN => '0',
      S_AXI_HP3_RID(5 downto 0) => NLW_inst_S_AXI_HP3_RID_UNCONNECTED(5 downto 0),
      S_AXI_HP3_RLAST => NLW_inst_S_AXI_HP3_RLAST_UNCONNECTED,
      S_AXI_HP3_RREADY => '0',
      S_AXI_HP3_RRESP(1 downto 0) => NLW_inst_S_AXI_HP3_RRESP_UNCONNECTED(1 downto 0),
      S_AXI_HP3_RVALID => NLW_inst_S_AXI_HP3_RVALID_UNCONNECTED,
      S_AXI_HP3_WACOUNT(5 downto 0) => NLW_inst_S_AXI_HP3_WACOUNT_UNCONNECTED(5 downto 0),
      S_AXI_HP3_WCOUNT(7 downto 0) => NLW_inst_S_AXI_HP3_WCOUNT_UNCONNECTED(7 downto 0),
      S_AXI_HP3_WDATA(63 downto 0) => B"0000000000000000000000000000000000000000000000000000000000000000",
      S_AXI_HP3_WID(5 downto 0) => B"000000",
      S_AXI_HP3_WLAST => '0',
      S_AXI_HP3_WREADY => NLW_inst_S_AXI_HP3_WREADY_UNCONNECTED,
      S_AXI_HP3_WRISSUECAP1_EN => '0',
      S_AXI_HP3_WSTRB(7 downto 0) => B"00000000",
      S_AXI_HP3_WVALID => '0',
      TRACE_CLK => '0',
      TRACE_CLK_OUT => NLW_inst_TRACE_CLK_OUT_UNCONNECTED,
      TRACE_CTL => NLW_inst_TRACE_CTL_UNCONNECTED,
      TRACE_DATA(1 downto 0) => NLW_inst_TRACE_DATA_UNCONNECTED(1 downto 0),
      TTC0_CLK0_IN => '0',
      TTC0_CLK1_IN => '0',
      TTC0_CLK2_IN => '0',
      TTC0_WAVE0_OUT => NLW_inst_TTC0_WAVE0_OUT_UNCONNECTED,
      TTC0_WAVE1_OUT => NLW_inst_TTC0_WAVE1_OUT_UNCONNECTED,
      TTC0_WAVE2_OUT => NLW_inst_TTC0_WAVE2_OUT_UNCONNECTED,
      TTC1_CLK0_IN => '0',
      TTC1_CLK1_IN => '0',
      TTC1_CLK2_IN => '0',
      TTC1_WAVE0_OUT => NLW_inst_TTC1_WAVE0_OUT_UNCONNECTED,
      TTC1_WAVE1_OUT => NLW_inst_TTC1_WAVE1_OUT_UNCONNECTED,
      TTC1_WAVE2_OUT => NLW_inst_TTC1_WAVE2_OUT_UNCONNECTED,
      UART0_CTSN => '0',
      UART0_DCDN => '0',
      UART0_DSRN => '0',
      UART0_DTRN => NLW_inst_UART0_DTRN_UNCONNECTED,
      UART0_RIN => '0',
      UART0_RTSN => NLW_inst_UART0_RTSN_UNCONNECTED,
      UART0_RX => '1',
      UART0_TX => NLW_inst_UART0_TX_UNCONNECTED,
      UART1_CTSN => '0',
      UART1_DCDN => '0',
      UART1_DSRN => '0',
      UART1_DTRN => NLW_inst_UART1_DTRN_UNCONNECTED,
      UART1_RIN => '0',
      UART1_RTSN => NLW_inst_UART1_RTSN_UNCONNECTED,
      UART1_RX => '1',
      UART1_TX => NLW_inst_UART1_TX_UNCONNECTED,
      USB0_PORT_INDCTL(1 downto 0) => NLW_inst_USB0_PORT_INDCTL_UNCONNECTED(1 downto 0),
      USB0_VBUS_PWRFAULT => '0',
      USB0_VBUS_PWRSELECT => NLW_inst_USB0_VBUS_PWRSELECT_UNCONNECTED,
      USB1_PORT_INDCTL(1 downto 0) => NLW_inst_USB1_PORT_INDCTL_UNCONNECTED(1 downto 0),
      USB1_VBUS_PWRFAULT => '0',
      USB1_VBUS_PWRSELECT => NLW_inst_USB1_VBUS_PWRSELECT_UNCONNECTED,
      WDT_CLK_IN => '0',
      WDT_RST_OUT => NLW_inst_WDT_RST_OUT_UNCONNECTED
    );
end STRUCTURE;
