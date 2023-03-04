//============================================================================
//  WonderSwan
//  Copyright (c) 2021 Robert Peip
//
//  MiSTer Framework
//  Copyright (C) 2021 Sorgelig
//
//  This program is free software; you can redistribute it and/or modify it
//  under the terms of the GNU General Public License as published by the Free
//  Software Foundation; either version 2 of the License, or (at your option)
//  any later version.
//
//  This program is distributed in the hope that it will be useful, but WITHOUT
//  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
//  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
//  more details.
//
//  You should have received a copy of the GNU General Public License along
//  with this program; if not, write to the Free Software Foundation, Inc.,
//  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
//============================================================================

module emu
(
	//Master input clock
	input         CLK_50M,

	//Async reset from top-level module.
	//Can be used as initial reset.
	input         RESET,

	//Must be passed to hps_io module
	inout  [48:0] HPS_BUS,

	//Base video clock. Usually equals to CLK_SYS.
	output        CLK_VIDEO,

	//Multiple resolutions are supported using different CE_PIXEL rates.
	//Must be based on CLK_VIDEO
	output        CE_PIXEL,

	//Video aspect ratio for HDMI. Most retro systems have ratio 4:3.
	//if VIDEO_ARX[12] or VIDEO_ARY[12] is set then [11:0] contains scaled size instead of aspect ratio.
	output [12:0] VIDEO_ARX,
	output [12:0] VIDEO_ARY,

	output  [7:0] VGA_R,
	output  [7:0] VGA_G,
	output  [7:0] VGA_B,
	output        VGA_HS,
	output        VGA_VS,
	output        VGA_DE,    // = ~(VBlank | HBlank)
	output        VGA_F1,
	output [1:0]  VGA_SL,
	output        VGA_SCALER, // Force VGA scaler
	output        VGA_DISABLE, // analog out is off

	input  [11:0] HDMI_WIDTH,
	input  [11:0] HDMI_HEIGHT,
	output        HDMI_FREEZE,

`ifdef MISTER_FB
	// Use framebuffer in DDRAM
	// FB_FORMAT:
	//    [2:0] : 011=8bpp(palette) 100=16bpp 101=24bpp 110=32bpp
	//    [3]   : 0=16bits 565 1=16bits 1555
	//    [4]   : 0=RGB  1=BGR (for 16/24/32 modes)
	//
	// FB_STRIDE either 0 (rounded to 256 bytes) or multiple of pixel size (in bytes)
	output        FB_EN,
	output  [4:0] FB_FORMAT,
	output [11:0] FB_WIDTH,
	output [11:0] FB_HEIGHT,
	output [31:0] FB_BASE,
	output [13:0] FB_STRIDE,
	input         FB_VBL,
	input         FB_LL,
	output        FB_FORCE_BLANK,

`ifdef MISTER_FB_PALETTE
	// Palette control for 8bit modes.
	// Ignored for other video modes.
	output        FB_PAL_CLK,
	output  [7:0] FB_PAL_ADDR,
	output [23:0] FB_PAL_DOUT,
	input  [23:0] FB_PAL_DIN,
	output        FB_PAL_WR,
`endif
`endif

	output        LED_USER,  // 1 - ON, 0 - OFF.

	// b[1]: 0 - LED status is system status OR'd with b[0]
	//       1 - LED status is controled solely by b[0]
	// hint: supply 2'b00 to let the system control the LED.
	output  [1:0] LED_POWER,
	output  [1:0] LED_DISK,

	// I/O board button press simulation (active high)
	// b[1]: user button
	// b[0]: osd button
	output  [1:0] BUTTONS,

	input         CLK_AUDIO, // 24.576 MHz
	output [15:0] AUDIO_L,
	output [15:0] AUDIO_R,
	output        AUDIO_S,   // 1 - signed audio samples, 0 - unsigned
	output  [1:0] AUDIO_MIX, // 0 - no mix, 1 - 25%, 2 - 50%, 3 - 100% (mono)

	//ADC
	inout   [3:0] ADC_BUS,

	//SD-SPI
	output        SD_SCK,
	output        SD_MOSI,
	input         SD_MISO,
	output        SD_CS,
	input         SD_CD,

	//High latency DDR3 RAM interface
	//Use for non-critical time purposes
	output        DDRAM_CLK,
	input         DDRAM_BUSY,
	output  [7:0] DDRAM_BURSTCNT,
	output [28:0] DDRAM_ADDR,
	input  [63:0] DDRAM_DOUT,
	input         DDRAM_DOUT_READY,
	output        DDRAM_RD,
	output [63:0] DDRAM_DIN,
	output  [7:0] DDRAM_BE,
	output        DDRAM_WE,

	//SDRAM interface with lower latency
	output        SDRAM_CLK,
	output        SDRAM_CKE,
	output [12:0] SDRAM_A,
	output  [1:0] SDRAM_BA,
	inout  [15:0] SDRAM_DQ,
	output        SDRAM_DQML,
	output        SDRAM_DQMH,
	output        SDRAM_nCS,
	output        SDRAM_nCAS,
	output        SDRAM_nRAS,
	output        SDRAM_nWE,

`ifdef MISTER_DUAL_SDRAM
	//Secondary SDRAM
	//Set all output SDRAM_* signals to Z ASAP if SDRAM2_EN is 0
	input         SDRAM2_EN,
	output        SDRAM2_CLK,
	output [12:0] SDRAM2_A,
	output  [1:0] SDRAM2_BA,
	inout  [15:0] SDRAM2_DQ,
	output        SDRAM2_nCS,
	output        SDRAM2_nCAS,
	output        SDRAM2_nRAS,
	output        SDRAM2_nWE,
`endif

	input         UART_CTS,
	output        UART_RTS,
	input         UART_RXD,
	output        UART_TXD,
	output        UART_DTR,
	input         UART_DSR,

	// Open-drain User port.
	// 0 - D+/RX
	// 1 - D-/TX
	// 2..6 - USR2..USR6
	// Set USER_OUT to 1 to read from USER_IN.
	input   [6:0] USER_IN,
	output  [6:0] USER_OUT,

	input         OSD_STATUS
);

assign ADC_BUS  = 'Z;
assign VGA_F1 = 0;
assign USER_OUT = '1;

assign {UART_RTS, UART_TXD, UART_DTR} = 0;

assign {SD_SCK, SD_MOSI, SD_CS} = 'Z;

reg  sav_pending     = 0;

assign LED_USER  = ioctl_download | sav_pending;
assign LED_DISK  = 0;
assign LED_POWER = 0;
assign BUTTONS   = 0;
assign VGA_SCALER= 0;
assign VGA_DISABLE = 0;
assign HDMI_FREEZE=0;

assign AUDIO_MIX = status[8:7];

// Status Bit Map: (0..31 => "O", 32..63 => "o")
// 0         1         2         3          4         5         6
// 01234567890123456789012345678901 23456789012345678901234567890123
// 0123456789ABCDEFGHIJKLMNOPQRSTUV 0123456789ABCDEFGHIJKLMNOPQRSTUV
// xxxxxxxxxxxxxxx xxxxxxxxxxxxxxxx   xxxxxxxxxxx

`include "build_id.v" 
localparam CONF_STR = {
	"WonderSwan;SS3E000000:100000;",
	"FS1,WSCWS PC2,Load ROM;",
	"-;",
	"o78,System,Auto,WonderSwan,SwanColor,PocketChallengeV2;",
	"-;",
	"d0r9,Reload Backup RAM;",
	"d0rA,Save Backup RAM;",
	"d0oB,Autosave,Off,On;",
	"-;",
	"o4,Savestates to SDCard,On,Off;",
	"o56,Savestate Slot,1,2,3,4;",
	"h0RS,Save state (Alt-F1);",
	"h0RT,Restore state (F1);",
	"-;",
	"OAB,Orientation,Horz,Vert,Vert180,Auto;",
	"OC,Flipped Horz,Off,On;",
	"-;",
	"P1,Audio & Video;",
	"P1-;",
	"P1OGJ,CRT H-Sync Adjust,0,1,2,3,4,5,6,7,-8,-7,-6,-5,-4,-3,-2,-1;",
	"P1OKN,CRT V-Sync Adjust,0,1,2,3,4,5,6,7,-8,-7,-6,-5,-4,-3,-2,-1;",
	"P1ODE,Aspect ratio,Original,Full Screen,[ARC1],[ARC2];",
	"P1O24,Scandoubler Fx,None,HQ2x,CRT 25%,CRT 50%,CRT 75%;",
	"P1o23,Scale,Normal,V-Integer,Narrower HV-Integer,Wider HV-Integer;",
	"P1-;",
	"P1oC,Refresh Rate,60Hz,75Hz;",
	"P1oD,Video Timing for YC,Off,On;",
	"P1OO,Sync core to Video,Off,On;",
	"P1O5,Buffer video,Off,On;",
	"P1OUV,Flickerblend,Off,2 Frames,3 Frames;",
	"P1-;",
	"P1O78,Stereo mix,none,25%,50%,100%;",
	"P1OP,FastForward Sound,On,Off;",
	"P2,Miscellaneous;",
	"P2-;",
	"P2O9,CPU Turbo,Off,On;",
	"P2OQ,Pause when OSD is open,Off,On;",
	"P2OR,Rewind Capture,Off,On;",
	"-;",
	"R0,Reset;",
	"J1,A,B,Start,Y2/Right,Y4/Left,Y3/DOWN,Y1/UP,FastForward,Savestates,Rewind;",
	"I,",
	"Slot=DPAD|Save/Load=Start+DPAD,",
	"Active Slot 1,",
	"Active Slot 2,",
	"Active Slot 3,",
	"Active Slot 4,",
	"Save to state 1,",
	"Restore state 1,",
	"Save to state 2,",
	"Restore state 2,",
	"Save to state 3,",
	"Restore state 3,",
	"Save to state 4,",
	"Restore state 4,",
	"Rewinding...;",
	"V,v",`BUILD_DATE
};

////////////////////   CLOCKS   ///////////////////

wire clk_sys;
wire clk_ram;
wire pll_locked;

assign CLK_VIDEO = clk_sys;

pll pll
(
	.refclk(CLK_50M),
	.rst(0),
	.outclk_0(clk_sys),// 36.864 Mhz
	.outclk_1(clk_ram),// 110.592 Mhz
	.locked(pll_locked)
);

///////////////////////////////////////////////////

wire [63:0] status;
wire  [1:0] buttons;
wire        forced_scandoubler;
wire        direct_video;
wire [21:0] gamma_bus;

wire        ioctl_download;
wire        ioctl_wr;
wire [24:0] ioctl_addr;
wire [15:0] ioctl_dout;
reg         ioctl_wait = 0;

wire [15:0] joystick_0, joy0_unmod, joystick_1, joystick_2, joystick_3;
wire [10:0] ps2_key;

wire [7:0]  filetype;

reg  [31:0] sd_lba = 0;
reg         sd_rd = 0;
reg         sd_wr = 0;
wire        sd_ack;
wire  [7:0] sd_buff_addr;
wire [15:0] sd_buff_dout;
wire [15:0] sd_buff_din;
wire        sd_buff_wr;
wire        img_mounted;
wire        img_readonly;
wire [63:0] img_size;

wire [32:0] RTC_time;

hps_io #(.CONF_STR(CONF_STR), .WIDE(1)) hps_io
(
	.clk_sys(clk_sys),
	.HPS_BUS(HPS_BUS),
	.EXT_BUS(),

	.ioctl_download(ioctl_download),
	.ioctl_wr(ioctl_wr),
	.ioctl_addr(ioctl_addr),
	.ioctl_dout(ioctl_dout),
	.ioctl_wait(ioctl_wait),
	.ioctl_index(filetype),
	
	.status(status),
	.status_menumask(cart_ready),
	.status_in({status[63:39],ss_slot,status[36:0]}),
	.status_set(statusUpdate),
	
	.sd_lba('{sd_lba}),
	.sd_rd(sd_rd),
	.sd_wr(sd_wr),
	.sd_ack(sd_ack),
	.sd_buff_addr(sd_buff_addr),
	.sd_buff_dout(sd_buff_dout),
	.sd_buff_din('{sd_buff_din}),
	.sd_buff_wr(sd_buff_wr),
	.img_mounted(img_mounted),
	.img_readonly(img_readonly),
	.img_size(img_size),

	.buttons(buttons),
	.direct_video(direct_video),
	.gamma_bus(gamma_bus),
	.forced_scandoubler(forced_scandoubler),
    .new_vmode(new_vmode),

	.joystick_0(joy0_unmod),
	.joystick_1(joystick_1),
	.joystick_2(joystick_2),
	.joystick_3(joystick_3),
	
	.ps2_key(ps2_key),
	
	.info_req(ss_info_req),
	.info(ss_info),
	
	.TIMESTAMP(RTC_time)
);

assign joystick_0 = joy0_unmod[12] ? 16'b0 : joy0_unmod;

///////////////////////////////////////////////////

wire [15:0] cart_addr;
wire cart_rd;
wire cart_wr;
reg cart_ready = 0;
reg ioctl_wr_1 = 0;

wire cart_download = ioctl_download && (filetype[5:0] == 6'h01 || filetype == 8'h80);
wire colorcart_download = ioctl_download && (filetype == 8'h01);
wire bios_download = ioctl_download && (filetype == 8'h00 || filetype == 8'h40);

wire sdram_ack;

wire EXTRAM_doRefresh;     
wire EXTRAM_read;     
wire EXTRAM_write;    
wire [24:0] EXTRAM_addr;   
wire [15:0] EXTRAM_datawrite;
wire [15:0] EXTRAM_dataread; 
wire [ 1:0] EXTRAM_be; 

wire [15:0] sdr_bram_din;
wire        sdr_bram_ack;

sdram sdram
(
	.*,
	.init(~pll_locked),
	.clk(clk_ram),
	
	.doRefresh(EXTRAM_doRefresh),

	.ch1_addr(ioctl_addr[24:1]),
	.ch1_din(ioctl_dout),
	.ch1_req(ioctl_wr),
	.ch1_rnw(cart_download ? 1'b0 : 1'b1),
	.ch1_ready(sdram_ack),
   .ch1_dout(),

	.ch2_addr({4'b1000,sd_lba[11:0],bram_addr}),
	.ch2_din(bram_dout),
	.ch2_dout(sdr_bram_din),
	.ch2_req(bram_req && saveIsSRAM),
	.ch2_rnw(~bk_loading || extra_data_addr),
	.ch2_ready(sdr_bram_ack),

	.ch3_addr(EXTRAM_addr[24:1]),
	.ch3_din(EXTRAM_datawrite),
	.ch3_dout(EXTRAM_dataread),
	.ch3_be(EXTRAM_be),
	.ch3_req(~cart_download & (EXTRAM_read | EXTRAM_write)),
	.ch3_rnw(EXTRAM_read),
	.ch3_ready()
);

reg [15:0] lastdata [0:4];

reg colorcart_downloaded;

always @(posedge clk_ram) begin
	ioctl_wr_1 <= ioctl_wr;
	if(cart_download) begin
		colorcart_downloaded <= colorcart_download;
		if(ioctl_wr & ~ioctl_wr_1)  begin
			ioctl_wait <= 1;
			lastdata[0] <= ioctl_dout;
			lastdata[1] <= lastdata[0];
			lastdata[2] <= lastdata[1];
			lastdata[3] <= lastdata[2];
			lastdata[4] <= lastdata[3];
		end
		if(sdram_ack) ioctl_wait <= 0;
	end
	else ioctl_wait <= 0;
end

reg old_download;
reg [24:0] mask_addr;

always @(posedge clk_sys) begin
	old_download <= cart_download;
	if (old_download & ~cart_download) begin
		mask_addr   <= ioctl_addr[24:0] - 1'd1;
		cart_ready <= 1;
	end
end

wire [15:0] Swan_AUDIO_L;
wire [15:0] Swan_AUDIO_R;

wire reset = (RESET | status[0] | buttons[1] | cart_download);

reg paused;
always_ff @(posedge clk_sys) begin
	paused <= savepause || ((syncpaused || (status[26] && OSD_STATUS)) && ~status[27]); // no pause when rewind capture is on
end

reg [12:0]  bios_wraddr;
reg [15:0]  bios_wrdata;
reg         bios_wr;
reg         bios_wrcolor;
always @(posedge clk_sys) begin
	bios_wr      <= 0;
	bios_wrcolor <= 0;
	if(bios_download & ioctl_wr) begin
		bios_wrdata       <= ioctl_dout;
		bios_wraddr       <= ioctl_addr[12:0];
		if (filetype == 8'h40) bios_wrcolor <= 1'b1; else bios_wr <= 1'b1;
	end
end

wire isColor = (status[40:39] == 0) ? (lastdata[4][8] | colorcart_downloaded) : (status[40:39] == 2'b10);

reg [79:0] time_dout = 41'd0;
wire [79:0] time_din;
assign time_din[42 + 32 +: 80 - (42 + 32)] = '0;
reg RTC_load = 0;

wire [7:0] ramtype = lastdata[2][15:8];

wire [15:0] eeprom_din;
wire        eeprom_ack = 1'b1;

SwanTop SwanTop (
	.clk              ( clk_sys),
	.clk_ram          ( clk_ram),
	.reset_in	      ( reset  ),
	.pause_in	      ( paused ),
	
	// rom
	.EXTRAM_doRefresh ( EXTRAM_doRefresh ),
	.EXTRAM_read      ( EXTRAM_read      ),
	.EXTRAM_write     ( EXTRAM_write     ),
	.EXTRAM_be        ( EXTRAM_be        ),
	.EXTRAM_addr      ( EXTRAM_addr      ),
	.EXTRAM_datawrite ( EXTRAM_datawrite ),  
	.EXTRAM_dataread  ( EXTRAM_dataread  ), 
	 
	.maskAddr         (mask_addr[23:0]   ),
	.romtype          (lastdata[2][ 7:0] ),
	.ramtype          (ramtype           ),
	.hasRTC           (lastdata[1][8]    ), 
	
	// eeprom
	.eepromWrite      (eepromWrite),
	.eeprom_addr      ({sd_lba[1:0],bram_addr}),
	.eeprom_din       (bram_dout),
	.eeprom_dout      (eeprom_din),
	.eeprom_req       (bram_req && ~saveIsSRAM),
	.eeprom_rnw       (~bk_loading || extra_data_addr),
 
	// bios
	.bios_wraddr      (bios_wraddr ),
	.bios_wrdata      (bios_wrdata ),
	.bios_wr          (bios_wr     ),
	.bios_wrcolor     (bios_wrcolor),
	
	// Video 
	.vertical         (vertical),
	.pixel_out_addr   (pixel_addr),        // integer range 0 to 16319; -- address for framebuffer
	.pixel_out_data   (pixel_data),        // RGB data for framebuffer
	.pixel_out_we     (pixel_we),          // new pixel for framebuffer

	// audio 
	.audio_l 	      (Swan_AUDIO_L),
	.audio_r 	      (Swan_AUDIO_R),
	
	//settings
	.isColor          ( isColor      ),
	.fastforward      ( fast_forward ),
	.turbo            ( status[9]    ),
	
	// joystick
	.KeyY1            (joystick_0[10]),
	.KeyY2            (joystick_0[7]),
	.KeyY3            (joystick_0[9]),
	.KeyY4            (joystick_0[8]),
	.KeyX1            (joystick_0[3]),
	.KeyX2            (joystick_0[0]),
	.KeyX3            (joystick_0[2]),
	.KeyX4            (joystick_0[1]),
	.KeyStart         (joystick_0[6]),
	.KeyA             (joystick_0[4]),
	.KeyB             (joystick_0[5]),
	
	// RTC
	.RTC_timestampNew(RTC_time[32]),
	.RTC_timestampIn(RTC_time[31:0]),
	.RTC_timestampSaved(time_dout[42 +: 32]),
	.RTC_savedtimeIn(time_dout[0 +: 42]),
	.RTC_saveLoaded(RTC_load),
	.RTC_timestampOut(time_din[42 +: 32]),
	.RTC_savedtimeOut(time_din[0 +: 42]),
	
	// savestates
	.increaseSSHeaderCount(!status[36]),
	.save_state       (ss_save),
	.load_state       (ss_load),
	.savestate_number (ss_slot),
	
	.SAVE_out_Din     (ss_din),            // data read from savestate
	.SAVE_out_Dout    (ss_dout),           // data written to savestate
	.SAVE_out_Adr     (ss_addr),           // all addresses are DWORD addresses!
	.SAVE_out_rnw     (ss_rnw),            // read = 1, write = 0
	.SAVE_out_ena     (ss_req),            // one cycle high for each action
	.SAVE_out_be      (ss_be),            
	.SAVE_out_done    (ss_ack),            // should be one cycle high when write is done or read value is valid
	
	.rewind_on        (status[27]),
	.rewind_active    (status[27] & joystick_0[13])
);

assign AUDIO_L = (fast_forward && status[25]) ? 16'd0 : Swan_AUDIO_L;
assign AUDIO_R = (fast_forward && status[25]) ? 16'd0 : Swan_AUDIO_R;
assign AUDIO_S = 1;

////////////////////////////  VIDEO  ////////////////////////////////////

wire [14:0] pixel_addr;
wire [11:0] pixel_data;
wire        pixel_we;

wire buffervideo = status[5] | status[31]; // OSD option for buffer or flickerblend on

reg [11:0] vram1[32256];
reg [11:0] vram2[32256];
reg [11:0] vram3[32256];
reg [1:0] buffercnt_write    = 0;
reg [1:0] buffercnt_readnext = 0;
reg [1:0] buffercnt_read     = 0;
reg [1:0] buffercnt_last     = 0;
reg       syncpaused         = 0;


always @(posedge clk_sys) begin
   if (buffervideo) begin
      if(pixel_we && pixel_addr == 32255) begin
         buffercnt_readnext <= buffercnt_write;
         if (buffercnt_write < 2) begin
            buffercnt_write <= buffercnt_write + 1'd1;
         end else begin
            buffercnt_write <= 0;
         end
      end
   end else begin
      buffercnt_write    <= 0;
      buffercnt_readnext <= 0;
   end
   
   if(pixel_we) begin
      if (buffercnt_write == 0) vram1[pixel_addr] <= pixel_data;
      if (buffercnt_write == 1) vram2[pixel_addr] <= pixel_data;
      if (buffercnt_write == 2) vram3[pixel_addr] <= pixel_data;
   end
   
   if (y > 150) begin
      syncpaused <= 0;
   end else if (~fast_forward && status[24] && pixel_we && pixel_addr == 32255) begin
      syncpaused <= 1;
   end

end

reg  [11:0] rgb0;
reg  [11:0] rgb1;
reg  [11:0] rgb2;

always @(posedge CLK_VIDEO) begin
	rgb0 <= vram1[px_addr];
	rgb1 <= vram2[px_addr];
	rgb2 <= vram3[px_addr];
end 

wire [14:0] px_addr;

wire [11:0] rgb_last = (buffercnt_last == 0) ? rgb0 :
                       (buffercnt_last == 1) ? rgb1 :
                       rgb2;

wire [11:0] rgb_now = (buffercnt_read == 0) ? rgb0 :
                      (buffercnt_read == 1) ? rgb1 :
                      rgb2;
  
wire [4:0] r2_5 = rgb_now[11:8] + rgb_last[11:8];
wire [4:0] g2_5 = rgb_now[ 7:4] + rgb_last[ 7:4];
wire [4:0] b2_5 = rgb_now[ 3:0] + rgb_last[ 3:0];  
                                
wire [5:0] r3_6 = rgb0[11:8] + rgb1[11:8] + rgb2[11:8];
wire [5:0] g3_6 = rgb0[ 7:4] + rgb1[ 7:4] + rgb2[ 7:4];
wire [5:0] b3_6 = rgb0[ 3:0] + rgb1[ 3:0] + rgb2[ 3:0];

wire [7:0] r3_8 = {r3_6, r3_6[5:4]};
wire [7:0] g3_8 = {g3_6, g3_6[5:4]};
wire [7:0] b3_8 = {b3_6, b3_6[5:4]};

wire [23:0] r3_mul24 = r3_8 * 16'D21845; 
wire [23:0] g3_mul24 = g3_8 * 16'D21845; 
wire [23:0] b3_mul24 = b3_8 * 16'D21845; 

wire [23:0] r3_div24 = r3_mul24 / 16'D16384; 
wire [23:0] g3_div24 = g3_mul24 / 16'D16384; 
wire [23:0] b3_div24 = b3_mul24 / 16'D16384; 
                  
wire vertical;
reg hs, vs, hbl, vbl, ce_pix;
reg [7:0] r,g,b;
reg [1:0] videomode;
reg [8:0] x,y;
reg [2:0] div;
reg signed [3:0] HShift;
reg signed [3:0] VShift; 
reg [9:0] HDisplayHFreqMode; 
reg [8:0] VDisplayHFreqMode;
reg signed [3:0] HShiftHFreqMode;
reg signed [3:0] VShiftHFreqMode;  

// If video timing changes, force mode update
reg [1:0] video_status;
reg new_vmode = 0;
always @(posedge clk_sys) begin
    if (video_status != status[45]) begin
        video_status <= status[45];
        new_vmode <= ~new_vmode;
    end
end

always @(posedge CLK_VIDEO) begin

   if (status[44]) begin
      if (div < 4) div <= div + 1'd1; else div <= 0; // 36.864 mhz / 5
   end else begin
      if (div < 5) div <= div + 1'd1; else div <= 0; // 36.864 mhz / 6
   end

	ce_pix <= 0;
	if(!div) begin
		ce_pix <= 1;

      if (status[31:30] == 0) begin // flickerblend off
         r <= {rgb_now[11:8], rgb_now[11:8]};
         g <= {rgb_now[7:4] , rgb_now[7:4] };
         b <= {rgb_now[3:0] , rgb_now[3:0] };
      end else if (status[31:30] == 1) begin // flickerblend 2 frames
         r <= {r2_5, r2_5[4:2]};
         g <= {g2_5, g2_5[4:2]};
         b <= {b2_5, b2_5[4:2]};
      end else begin // flickerblend 3 frames
         r <= r3_div24[7:0];
         g <= g3_div24[7:0];
         b <= b3_div24[7:0];
      end

      if (videomode == 0) begin
         if(x == 224 + 31)                  hbl <= 1;
         if(y ==  66 + $signed(VShift))     vbl <= 0;
         if(y >=  66+144 + $signed(VShift)) vbl <= 1;
      end else if (videomode == 1 || videomode == 2) begin
         if(x == 144 + 72)                  hbl <= 1;
         if(y == 25 + $signed(VShift))      vbl <= 0;
         if(y >= 25+224 + $signed(VShift))  vbl <= 1;
      end
      
		if((videomode == 0 && x == 31) || (videomode > 0 && x == 72)) begin 
         hbl <= 0;
      end  
       
		if(x == 320 + $signed(HShift)) begin
			hs <= 1;
			if(y == 1)   vs <= 1;
			if(y == 4)   vs <= 0;
		end

		if(x == 320+32+$signed(HShift)) hs <= 0;

	end

	if(ce_pix) begin

      if (videomode == 0) begin
         if(vbl) begin
            if (status[12]) px_addr <= 32255;
            else            px_addr <= 0;
         end else begin 
            if(!hbl) begin
               if (status[12]) px_addr <= px_addr - 1'd1;
               else            px_addr <= px_addr + 1'd1;
            end
         end
      end else if (videomode == 1) begin
         if(!hbl) begin 
            px_addr <= px_addr - 8'd224;
         end else begin
            px_addr <= (8'd143 * 8'd224) + (y - 6'd25 - $signed(VShift));
         end
      end else if (videomode == 2) begin
         if(!hbl) begin 
            px_addr <= px_addr + 8'd224;
         end else begin
            px_addr <= 8'd248 - y + $signed(VShift);
         end
      end

		x <= x + 1'd1;
		if ((x >= HDisplayHFreqMode && ~status[44]) || (x >= 378 && status[44])) begin // (401x258 for standard video, 391x262 for improved Analog Timing for Composite)
			x <= 0;
			if (~&y) y <= y + 1'd1;
			if (y >= VDisplayHFreqMode) begin
            y              <= 0;
            buffercnt_read <= buffercnt_readnext;
            buffercnt_last <= buffercnt_read;
            
            HShift      <= status[19:16] + HShiftHFreqMode;
            VShift      <= status[23:20] - VShiftHFreqMode;
			HShiftHFreqMode <= (status[45] ? 4'd10 : 4'd0);
			VShiftHFreqMode <= (status[45] ? 4'd4 : 4'd0);
			HDisplayHFreqMode <= (status[45] ? 10'd390 : 10'd400); // Change Video Timing for for Y/C Composite Video
			VDisplayHFreqMode <= (status[45] ? 9'd261 : 9'd257); // Change Video Timing for for Y/C Composite Video

            if (status[11:10] == 0) videomode = 0;                      // 224*144
            if (status[11:10] == 1) videomode = 1;                      // 144*224
            if (status[11:10] == 2) videomode = 2;                      // 144*224, 180 degree rotated
            if (status[11:10] == 3) videomode = vertical ? 2'd2 : 2'd0; // autorotate
         end
		end

	end

end

assign VGA_F1 = 0;
assign VGA_SL = sl[1:0];

wire [2:0] scale = status[4:2];
wire [2:0] sl = scale ? scale - 1'd1 : 3'd0;
wire       scandoubler = (scale || forced_scandoubler);

wire [7:0] r_in = r;
wire [7:0] g_in = g;
wire [7:0] b_in = b;

video_mixer #(.LINE_LENGTH(520), .GAMMA(1)) video_mixer
(
	.*,
	.hq2x(scale==1),
	.freeze_sync(),
	.HSync(hs),
	.VSync(vs),
	.HBlank(hbl),
	.VBlank(vbl),
	.R(r_in),
	.G(g_in),
	.B(b_in)
);

wire [1:0] ar = status[14:13];
video_freak video_freak
(
	.*,
	.VGA_DE_IN(VGA_DE),
	.VGA_DE(),

	.ARX((!ar) ? (videomode > 0) ? 12'd144 : 12'd224 : (ar - 1'd1)),
	.ARY((!ar) ? (videomode > 0) ? 12'd224 : 12'd144 : 12'd0      ),
	.CROP_SIZE(0),
	.CROP_OFF(0),
	.SCALE(status[35:34])
);

///////////////////////////// Fast Forward Latch /////////////////////////////////

reg fast_forward;
reg ff_latch;

wire fastforward = joystick_0[11] && !ioctl_download && !OSD_STATUS;
wire ff_on;

always @(posedge clk_sys) begin : ffwd
	reg last_ffw;
	reg ff_was_held;
	longint ff_count;

	last_ffw <= fastforward;

	if (fastforward)
		ff_count <= ff_count + 1;

	if (~last_ffw & fastforward) begin
		ff_latch <= 0;
		ff_count <= 0;
	end

	if ((last_ffw & ~fastforward)) begin // 32mhz clock, 0.2 seconds
		ff_was_held <= 0;

		if (ff_count < 6400000 && ~ff_was_held) begin
			ff_was_held <= 1;
			ff_latch <= 1;
		end
	end

	fast_forward <= (fastforward | ff_latch);
end

///////////////////////////// savestates /////////////////////////////////

wire [63:0] SaveStateBus_Din; 
wire [9:0]  SaveStateBus_Adr; 
wire        SaveStateBus_wren;
wire        SaveStateBus_rst; 
wire [63:0] SaveStateBus_Dout;
wire        savestate_load;
	
wire [63:0] ss_dout, ss_din;
wire [27:2] ss_addr;
wire  [7:0] ss_be;
wire        ss_rnw, ss_req, ss_ack;

assign DDRAM_CLK = clk_sys;
ddram ddram
(
	.*,

	.ch1_addr({ss_addr, 1'b0}),
	.ch1_din(ss_din),
	.ch1_dout(ss_dout),
	.ch1_req(ss_req),
	.ch1_rnw(ss_rnw),
	.ch1_be(ss_be),
	.ch1_ready(ss_ack)
);

// saving with keyboard/OSD/gamepad
wire [1:0] ss_slot;
wire [7:0] ss_info;
wire ss_save, ss_load, ss_info_req;
wire statusUpdate;

savestate_ui savestate_ui
(
	.clk            (clk_sys       ),
	.ps2_key        (ps2_key[10:0] ),
	.allow_ss       (cart_ready    ),
	.joySS          (joy0_unmod[12]),
	.joyRight       (joy0_unmod[0] ),
	.joyLeft        (joy0_unmod[1] ),
	.joyDown        (joy0_unmod[2] ),
	.joyUp          (joy0_unmod[3] ),
	.joyStart       (joy0_unmod[6] ),
	.joyRewind      (joy0_unmod[13]),
	.rewindEnable   (status[27]    ), 
	.status_slot    (status[38:37] ),
	.OSD_saveload   (status[29:28] ),
	.ss_save        (ss_save       ),
	.ss_load        (ss_load       ),
	.ss_info_req    (ss_info_req   ),
	.ss_info        (ss_info       ),
	.statusUpdate   (statusUpdate  ),
	.selected_slot  (ss_slot       )
);
defparam savestate_ui.INFO_TIMEOUT_BITS = 27;

/////////////////////////  SRAM/EEPROM SAVE/LOAD  /////////////////////////////
wire bk_load     = status[41];
wire bk_save     = status[42];
wire bk_autosave = status[43];
wire bk_write    = (EXTRAM_addr[24] && EXTRAM_write) || eepromWrite;

wire eepromWrite;

reg  bk_ena      = 0;
reg  bk_pending  = 0;
reg  bk_loading  = 0;

reg bk_record_rtc = 0;

wire extra_data_addr = sd_lba[11:0] > save_sz;

wire savepause = bk_state;

wire has_rtc = 1'b1;

wire saveIsSRAM = (ramtype == 8'h01) || (ramtype == 8'h02) || (ramtype == 8'h03) || (ramtype == 8'h04) || (ramtype == 8'h05); 

always @(posedge clk_sys) begin
	if (bk_write)      bk_pending <= 1;
	else if (bk_state) bk_pending <= 0;
end
reg use_img;
reg [11:0] save_sz;

always @(posedge clk_sys) begin : size_block
	reg old_downloading;

	old_downloading <= cart_download;
	if(~old_downloading & cart_download) {use_img, save_sz} <= 0;

	if((~use_img && EXTRAM_write) || eepromWrite) begin
		if(ramtype == 8'h01) save_sz <= save_sz | 12'hF;
		if(ramtype == 8'h02) save_sz <= save_sz | 12'h3F;
		if(ramtype == 8'h03) save_sz <= save_sz | 12'hFF;
		if(ramtype == 8'h04) save_sz <= save_sz | 12'h1FF;
		if(ramtype == 8'h05) save_sz <= save_sz | 12'h3FF;
		if(ramtype == 8'h10) save_sz <= save_sz | 12'h003;
		if(ramtype == 8'h20) save_sz <= save_sz | 12'h003;
		if(ramtype == 8'h50) save_sz <= save_sz | 12'h003;
	end

	if(img_mounted && img_size && !img_readonly) begin
		use_img <= 1;
		if (!(img_size[20:9] & (img_size[20:9] - 12'd1))) // Power of two
			save_sz <= img_size[20:9] - 1'd1;
		else                                             // Assume one extra sector of RTC data
			save_sz <= img_size[20:9] - 2'd2;
	end

	bk_ena <= |save_sz;
end

reg  bk_state  = 0;
wire bk_save_a = OSD_STATUS & bk_autosave;

reg [1:0] bk_state_int;
reg [3:0] bk_wait; 

always @(posedge clk_sys) begin
	reg old_load = 0, old_save = 0, old_save_a = 0, old_ack;

	old_load   <= bk_load;
	old_save   <= bk_save;
	old_save_a <= bk_save_a;
	old_ack    <= sd_ack;

	if(~old_ack & sd_ack) {sd_rd, sd_wr} <= 0;

	if(!bk_state) begin
		bram_tx_start <= 0;
		bk_state_int  <= 0;
		sd_lba        <= 0;
      bk_wait       <= 15;
		time_dout     <= {5'd0, RTC_time, 42'd0};
		bk_loading    <= 0;
		if(bk_ena & ((~old_load & bk_load) | (~old_save & bk_save) | (~old_save_a & bk_save_a & bk_pending) | (cart_download & img_mounted))) begin
			bk_state <= 1;
			bk_loading <= bk_load | img_mounted;
		end
	end 
   else if (bk_wait > 0) begin 
      bk_wait <= bk_wait - 1'd1;
   end 
   else if(bk_loading) begin
		case(bk_state_int)
			0: begin
					sd_rd <= 1;
					bk_state_int <= 1;
				end
			1: if(old_ack & ~sd_ack) begin
					bram_tx_start <= 1;
					bk_state_int <= 2;
				end
			2: if(bram_tx_finish) begin
					bram_tx_start <= 0;
					bk_state_int <= 0;
					sd_lba <= sd_lba + 1'd1;

					// always read max possible size
					if(sd_lba[11:0] == 12'h400) begin
						bk_record_rtc <= 0;
						bk_state <= 0;
						RTC_load <= 0;
					end
				end
		endcase

		if (extra_data_addr) begin
			if (~|sd_buff_addr && sd_buff_wr && sd_buff_dout == "RT") begin
				bk_record_rtc <= 1;
				RTC_load <= 0;
			end
		end

		if (bk_record_rtc) begin
			if (sd_buff_addr < 6 && sd_buff_addr >= 1)
				time_dout[{sd_buff_addr[2:0] - 3'd1, 4'b0000} +: 16] <= sd_buff_dout;

			if (sd_buff_addr > 5)
				RTC_load <= 1;

			if (&sd_buff_addr)
				bk_record_rtc <= 0;
		end
	end
	else begin
		case(bk_state_int)
			0: begin
					bram_tx_start <= 1;
					bk_state_int <= 1;
				end
			1: if(bram_tx_finish) begin
					bram_tx_start <= 0;
					sd_wr <= 1;
					bk_state_int <= 2;
				end
			2: if(old_ack & ~sd_ack) begin
					bk_state_int <= 0;
					sd_lba <= sd_lba + 1'd1;

					if (sd_lba[11:0] == {1'b0, save_sz} + (has_rtc ? 12'd1 : 12'd0))
						bk_state <= 0;
				end
		endcase
	end
end

// transfer bram

wire [127:0] time_din_h = {32'd0, time_din, "RT"};
wire [15:0] bram_dout;
wire [15:0] bram_din = saveIsSRAM ? sdr_bram_din : eeprom_din;
wire        bram_ack = saveIsSRAM ? sdr_bram_ack : eeprom_ack;
assign sd_buff_din = extra_data_addr ? (time_din_h[{sd_buff_addr[2:0], 4'b0000} +: 16]) : bram_buff_out;
wire [15:0] bram_buff_out;

altsyncram	altsyncram_component
(
	.address_a (bram_addr),
	.address_b (sd_buff_addr),
	.clock0 (clk_ram),
	.clock1 (clk_sys),
	.data_a (bram_din),
	.data_b (sd_buff_dout),
	.wren_a (~bk_loading & bram_ack),
	.wren_b (sd_buff_wr && ~extra_data_addr),
	.q_a (bram_dout),
	.q_b (bram_buff_out),
	.byteena_a (1'b1),
	.byteena_b (1'b1),
	.clocken0 (1'b1),
	.clocken1 (1'b1),
	.rden_a (1'b1),
	.rden_b (1'b1)
);
defparam
	altsyncram_component.address_reg_b = "CLOCK1",
	altsyncram_component.clock_enable_input_a = "BYPASS",
	altsyncram_component.clock_enable_input_b = "BYPASS",
	altsyncram_component.clock_enable_output_a = "BYPASS",
	altsyncram_component.clock_enable_output_b = "BYPASS",
	altsyncram_component.indata_reg_b = "CLOCK1",
	altsyncram_component.intended_device_family = "Cyclone V",
	altsyncram_component.lpm_type = "altsyncram",
	altsyncram_component.numwords_a = 256,
	altsyncram_component.numwords_b = 256,
	altsyncram_component.operation_mode = "BIDIR_DUAL_PORT",
	altsyncram_component.outdata_aclr_a = "NONE",
	altsyncram_component.outdata_aclr_b = "NONE",
	altsyncram_component.outdata_reg_a = "UNREGISTERED",
	altsyncram_component.outdata_reg_b = "UNREGISTERED",
	altsyncram_component.power_up_uninitialized = "FALSE",
	altsyncram_component.read_during_write_mode_port_a = "NEW_DATA_NO_NBE_READ",
	altsyncram_component.read_during_write_mode_port_b = "NEW_DATA_NO_NBE_READ",
	altsyncram_component.widthad_a = 8,
	altsyncram_component.widthad_b = 8,
	altsyncram_component.width_a = 16,
	altsyncram_component.width_b = 16,
	altsyncram_component.width_byteena_a = 1,
	altsyncram_component.width_byteena_b = 1,
	altsyncram_component.wrcontrol_wraddress_reg_b = "CLOCK1";

reg [7:0] bram_addr;
reg bram_tx_start;
reg bram_tx_finish;
reg bram_req;
reg bram_state;

always @(posedge clk_ram) begin

	bram_req <= 0;

	if (extra_data_addr && bram_tx_start) begin
		if (~&bram_addr)
			bram_tx_finish <= 1;
	end else if(~bram_tx_start) {bram_addr, bram_state, bram_tx_finish} <= 0;
	else if(~bram_tx_finish) begin
		if(!bram_state) begin
			bram_req <= 1;
			bram_state <= 1;
		end
		else if(bram_ack) begin
			bram_state <= 0;
			if(~&bram_addr) bram_addr <= bram_addr + 1'd1;
			else bram_tx_finish <= 1;
		end
	end
end

endmodule
