//https://www.elektormagazine.com/magazine/elektor-201204/19851
// DDS implemented in C from link above.
// Now implemented in verilog

module DDS
(
	input	clk,
	input reset_n,
	input [31:0] in,
	output [11:0] out
);


	reg[31:0] DDSp /* synthesis noprune */; // DDS phase value
	reg[31:0] DDSd /* synthesis noprune */; // DDS phase delta
	reg [7:0] sample/* synthesis noprune */;
	reg [11:0] outReg/* synthesis noprune */;
	
	assign out=outReg;
	
	initial begin
		DDSd=42949673 ;    // 1kHz/100kHz*(2^32)=42949673
		DDSp=0;
		sample=0;
		outReg=0;
	end

	// Determine the next state synchronously, based on the
	// current state and the input
	always @ (posedge clk or negedge reset_n) begin
		if (!reset_n) begin
			DDSp=0;
			sample=0;
		end
		else begin
			sample=DDSp[31:24];//DDSp>>24;  // fetch and output sine-sample
			DDSp =DDSp+DDSd;
		end
			
	end
	
// sine lookup-table. given the phase it will provide the sample value
	always @ (sample) begin
		
		
		case(sample)
		
			8'd0: outReg<= 12'd2055;	
			8'd1: outReg<= 12'd2103;	
			8'd2: outReg<= 12'd2151;	
			8'd3: outReg<= 12'd2200;	
			8'd4: outReg<= 12'd2248;	
			8'd5: outReg<= 12'd2312;	
			8'd6: outReg<= 12'd2360;	
			8'd7: outReg<= 12'd2408;	
			8'd8: outReg<= 12'd2457;	
			8'd9: outReg<= 12'd2505;	
			8'd10: outReg<= 12'd2553;	
			8'd11: outReg<= 12'd2601;	
			8'd12: outReg<= 12'd2649;	
			8'd13: outReg<= 12'd2697;	
			8'd14: outReg<= 12'd2746;	
			8'd15: outReg<= 12'd2794;	
			8'd16: outReg<= 12'd2842;	
			8'd17: outReg<= 12'd2874;	
			8'd18: outReg<= 12'd2922;	
			8'd19: outReg<= 12'd2970;	
			8'd20: outReg<= 12'd3019;	
			8'd21: outReg<= 12'd3067;	
			8'd22: outReg<= 12'd3099;	
			8'd23: outReg<= 12'd3147;	
			8'd24: outReg<= 12'd3195;	
			8'd25: outReg<= 12'd3227;	
			8'd26: outReg<= 12'd3276;	
			8'd27: outReg<= 12'd3308;	
			8'd28: outReg<= 12'd3356;	
			8'd29: outReg<= 12'd3388;	
			8'd30: outReg<= 12'd3420;	
			8'd31: outReg<= 12'd3468;	
			8'd32: outReg<= 12'd3500;	
			8'd33: outReg<= 12'd3532;	
			8'd34: outReg<= 12'd3565;	
			8'd35: outReg<= 12'd3597;	
			8'd36: outReg<= 12'd3629;	
			8'd37: outReg<= 12'd3661;	
			8'd38: outReg<= 12'd3693;	
			8'd39: outReg<= 12'd3725;	
			8'd40: outReg<= 12'd3757;	
			8'd41: outReg<= 12'd3773;	
			8'd42: outReg<= 12'd3805;	
			8'd43: outReg<= 12'd3838;	
			8'd44: outReg<= 12'd3854;	
			8'd45: outReg<= 12'd3870;	
			8'd46: outReg<= 12'd3902;	
			8'd47: outReg<= 12'd3918;	
			8'd48: outReg<= 12'd3934;	
			8'd49: outReg<= 12'd3950;	
			8'd50: outReg<= 12'd3982;	
			8'd51: outReg<= 12'd3998;	
			8'd52: outReg<= 12'd4014;	
			8'd53: outReg<= 12'd4014;	
			8'd54: outReg<= 12'd4030;	
			8'd55: outReg<= 12'd4046;	
			8'd56: outReg<= 12'd4062;	
			8'd57: outReg<= 12'd4062;	
			8'd58: outReg<= 12'd4078;	
			8'd59: outReg<= 12'd4078;	
			8'd60: outReg<= 12'd4078;	
			8'd61: outReg<= 12'd4095;	
			8'd62: outReg<= 12'd4095;	
			8'd63: outReg<= 12'd4095;	
			8'd64: outReg<= 12'd4095;	
			8'd65: outReg<= 12'd4095;	
			8'd66: outReg<= 12'd4095;	
			8'd67: outReg<= 12'd4095;	
			8'd68: outReg<= 12'd4078;	
			8'd69: outReg<= 12'd4078;	
			8'd70: outReg<= 12'd4078;	
			8'd71: outReg<= 12'd4062;	
			8'd72: outReg<= 12'd4062;	
			8'd73: outReg<= 12'd4046;	
			8'd74: outReg<= 12'd4030;	
			8'd75: outReg<= 12'd4014;	
			8'd76: outReg<= 12'd4014;	
			8'd77: outReg<= 12'd3998;	
			8'd78: outReg<= 12'd3982;	
			8'd79: outReg<= 12'd3950;	
			8'd80: outReg<= 12'd3934;	
			8'd81: outReg<= 12'd3918;	
			8'd82: outReg<= 12'd3902;	
			8'd83: outReg<= 12'd3870;	
			8'd84: outReg<= 12'd3854;	
			8'd85: outReg<= 12'd3838;	
			8'd86: outReg<= 12'd3805;	
			8'd87: outReg<= 12'd3773;	
			8'd88: outReg<= 12'd3757;	
			8'd89: outReg<= 12'd3725;	
			8'd90: outReg<= 12'd3693;	
			8'd91: outReg<= 12'd3661;	
			8'd92: outReg<= 12'd3629;	
			8'd93: outReg<= 12'd3597;	
			8'd94: outReg<= 12'd3565;	
			8'd95: outReg<= 12'd3532;	
			8'd96: outReg<= 12'd3500;	
			8'd97: outReg<= 12'd3468;	
			8'd98: outReg<= 12'd3420;	
			8'd99: outReg<= 12'd3388;	
			8'd100: outReg<= 12'd3356;	
			8'd101: outReg<= 12'd3308;	
			8'd102: outReg<= 12'd3276;	
			8'd103: outReg<= 12'd3227;	
			8'd104: outReg<= 12'd3195;	
			8'd105: outReg<= 12'd3147;	
			8'd106: outReg<= 12'd3099;	
			8'd107: outReg<= 12'd3067;	
			8'd108: outReg<= 12'd3019;	
			8'd109: outReg<= 12'd2970;	
			8'd110: outReg<= 12'd2922;	
			8'd111: outReg<= 12'd2874;	
			8'd112: outReg<= 12'd2842;	
			8'd113: outReg<= 12'd2794;	
			8'd114: outReg<= 12'd2746;	
			8'd115: outReg<= 12'd2697;	
			8'd116: outReg<= 12'd2649;	
			8'd117: outReg<= 12'd2601;	
			8'd118: outReg<= 12'd2553;	
			8'd119: outReg<= 12'd2505;	
			8'd120: outReg<= 12'd2457;	
			8'd121: outReg<= 12'd2408;	
			8'd122: outReg<= 12'd2360;	
			8'd123: outReg<= 12'd2312;	
			8'd124: outReg<= 12'd2248;	
			8'd125: outReg<= 12'd2200;	
			8'd126: outReg<= 12'd2151;	
			8'd127: outReg<= 12'd2103;	
			8'd128: outReg<= 12'd2055;	
			8'd129: outReg<= 12'd2007;	
			8'd130: outReg<= 12'd1959;	
			8'd131: outReg<= 12'd1911;	
			8'd132: outReg<= 12'd1862;	
			8'd133: outReg<= 12'd1798;	
			8'd134: outReg<= 12'd1750;	
			8'd135: outReg<= 12'd1702;	
			8'd136: outReg<= 12'd1654;	
			8'd137: outReg<= 12'd1605;	
			8'd138: outReg<= 12'd1557;	
			8'd139: outReg<= 12'd1509;	
			8'd140: outReg<= 12'd1461;	
			8'd141: outReg<= 12'd1413;	
			8'd142: outReg<= 12'd1365;	
			8'd143: outReg<= 12'd1316;	
			8'd144: outReg<= 12'd1268;	
			8'd145: outReg<= 12'd1236;	
			8'd146: outReg<= 12'd1188;	
			8'd147: outReg<= 12'd1140;	
			8'd148: outReg<= 12'd1092;	
			8'd149: outReg<= 12'd1043;	
			8'd150: outReg<= 12'd1011;	
			8'd151: outReg<= 12'd963;	
			8'd152: outReg<= 12'd915;	
			8'd153: outReg<= 12'd883;	
			8'd154: outReg<= 12'd835;	
			8'd155: outReg<= 12'd802;	
			8'd156: outReg<= 12'd754;	
			8'd157: outReg<= 12'd722;	
			8'd158: outReg<= 12'd690;	
			8'd159: outReg<= 12'd642;	
			8'd160: outReg<= 12'd610;	
			8'd161: outReg<= 12'd578;	
			8'd162: outReg<= 12'd546;	
			8'd163: outReg<= 12'd513;	
			8'd164: outReg<= 12'd481;	
			8'd165: outReg<= 12'd449;	
			8'd166: outReg<= 12'd417;	
			8'd167: outReg<= 12'd385;	
			8'd168: outReg<= 12'd353;	
			8'd169: outReg<= 12'd337;	
			8'd170: outReg<= 12'd305;	
			8'd171: outReg<= 12'd273;	
			8'd172: outReg<= 12'd256;	
			8'd173: outReg<= 12'd240;	
			8'd174: outReg<= 12'd208;	
			8'd175: outReg<= 12'd192;	
			8'd176: outReg<= 12'd176;	
			8'd177: outReg<= 12'd160;	
			8'd178: outReg<= 12'd128;	
			8'd179: outReg<= 12'd112;	
			8'd180: outReg<= 12'd96;	
			8'd181: outReg<= 12'd96;	
			8'd182: outReg<= 12'd80;	
			8'd183: outReg<= 12'd64;	
			8'd184: outReg<= 12'd48;	
			8'd185: outReg<= 12'd48;	
			8'd186: outReg<= 12'd32;	
			8'd187: outReg<= 12'd32;	
			8'd188: outReg<= 12'd32;	
			8'd189: outReg<= 12'd16;	
			8'd190: outReg<= 12'd16;	
			8'd191: outReg<= 12'd16;	
			8'd192: outReg<= 12'd16;	
			8'd193: outReg<= 12'd16;	
			8'd194: outReg<= 12'd16;	
			8'd195: outReg<= 12'd16;	
			8'd196: outReg<= 12'd32;	
			8'd197: outReg<= 12'd32;	
			8'd198: outReg<= 12'd32;	
			8'd199: outReg<= 12'd48;	
			8'd200: outReg<= 12'd48;	
			8'd201: outReg<= 12'd64;	
			8'd202: outReg<= 12'd80;	
			8'd203: outReg<= 12'd96;	
			8'd204: outReg<= 12'd96;	
			8'd205: outReg<= 12'd112;	
			8'd206: outReg<= 12'd128;	
			8'd207: outReg<= 12'd160;	
			8'd208: outReg<= 12'd176;	
			8'd209: outReg<= 12'd192;	
			8'd210: outReg<= 12'd208;	
			8'd211: outReg<= 12'd240;	
			8'd212: outReg<= 12'd256;	
			8'd213: outReg<= 12'd273;	
			8'd214: outReg<= 12'd305;	
			8'd215: outReg<= 12'd337;	
			8'd216: outReg<= 12'd353;	
			8'd217: outReg<= 12'd385;	
			8'd218: outReg<= 12'd417;	
			8'd219: outReg<= 12'd449;	
			8'd220: outReg<= 12'd481;	
			8'd221: outReg<= 12'd513;	
			8'd222: outReg<= 12'd546;	
			8'd223: outReg<= 12'd578;	
			8'd224: outReg<= 12'd610;	
			8'd225: outReg<= 12'd642;	
			8'd226: outReg<= 12'd690;	
			8'd227: outReg<= 12'd722;	
			8'd228: outReg<= 12'd754;	
			8'd229: outReg<= 12'd802;	
			8'd230: outReg<= 12'd835;	
			8'd231: outReg<= 12'd883;	
			8'd232: outReg<= 12'd915;	
			8'd233: outReg<= 12'd963;	
			8'd234: outReg<= 12'd1011;	
			8'd235: outReg<= 12'd1043;	
			8'd236: outReg<= 12'd1092;	
			8'd237: outReg<= 12'd1140;	
			8'd238: outReg<= 12'd1188;	
			8'd239: outReg<= 12'd1236;	
			8'd240: outReg<= 12'd1268;	
			8'd241: outReg<= 12'd1316;	
			8'd242: outReg<= 12'd1365;	
			8'd243: outReg<= 12'd1413;	
			8'd244: outReg<= 12'd1461;	
			8'd245: outReg<= 12'd1509;	
			8'd246: outReg<= 12'd1557;	
			8'd247: outReg<= 12'd1605;	
			8'd248: outReg<= 12'd1654;	
			8'd249: outReg<= 12'd1702;	
			8'd250: outReg<= 12'd1750;	
			8'd251: outReg<= 12'd1798;	
			8'd252: outReg<= 12'd1862;	
			8'd253: outReg<= 12'd1911;	
			8'd254: outReg<= 12'd1959;	
			8'd255: outReg<= 12'd2007;	


			default outReg=12'd0;
		endcase
	
	end
	

endmodule
