/*  	Module listen on JTAG_UART for the 0x01 comand								*/
/*	 	Then send request to for UART to receive 1024 bytes of data	in pairs	*/
/* 	Data size is 2048 where LSB and MSB is send 									*/
/* 	12 bit data is extracted from the incoming data								*/
/* 	Data received is send along with the address to the FIFO.				*/
/* 	After the FIFO is empty the next 1024 bytes are requested and the    */
/*    process repeats until file size has been completed							*/
//https://www.intel.co.jp/content/dam/altera-www/global/ja_JP/pdfs/literature/hb/nios2/n2cpu_nii5v3_01.pdf  (see chapter 5 JTAG UART core Register Map to access the data) 
//https://www.intel.com/content/dam/www/programmable/us/en/pdfs/literature/manual/mnl_avalon_spec.pdf  (see page 21 for timing diagram on when data is available)


module jtag_uart_comm(	
							input 				clk_10MHz, //
							input 				reset_n,//
							input					trigger,//tell jtag to send data
							input			[23:0]		jtag_wrdata_to_jtag,// [23:0] data
							output		    	vjtag_udr,//
							output		[31:0]       data,
							output toggle

								
);



//https://tomverbeure.github.io/2021/05/02/Intel-JTAG-UART.html
jtaguart u0 (
		.jtag_uart_0_clk_clk (clk_10MHz), // jtag_uart_0_clk.clk
		.n_reset_reset_n     ( reset_n),     //         n_reset.reset_n
		.slave_chipselect    (1'b1),    //           slave.chipselect
		.slave_address       (1'b0),     //        JTAG UART Core Register Map 0=data reg 1 = control reg
		.slave_read_n        (read_n),        //                .read_n
		.slave_readdata      (readdata),      //                .readdata
		.slave_write_n       (write_n),       //                .write_n
		.slave_writedata     (wrdata),     //                .writedata
		.slave_waitrequest   (waitrequest),   //                .waitrequest
		.irq_irq             (irq)              //             irq.irq
	);



reg reg_trigger=1'b0;
wire [15:0] RAVAIL;
wire RVALID;
reg[31:0] readdata;
assign  RAVAIL=readdata[31:16];
assign RVALID=readdata[15];
assign data = reg_data;

(*preserve = 1*) reg jtag_udr=0;
(*preserve = 1*) reg[7:0] LSB,MSB;
(*preserve = 1*) reg transaction_type =1'b0;  //set to 0 when writing to JTAG to transmit data
(*preserve = 1*) reg [2:0] state=3'b000;
(*preserve = 1*) reg lsb_msb_toggle=1'b0;
(*preserve = 1*)	reg read_n;//initial read_n=1'b1;
(*preserve = 1*)	reg write_n=1;
(*keep=1*) integer cnt=0;
(*keep = 1*) wire waitrequest;
(*preserve = 1*) reg [3:0] wr_state=4'b0000;
(*preserve = 1*) reg [7:0] wrdata=8'b0000_0000;
(*preserve = 1*) reg [3:0] state_ctrl=4'b0000;	
(*preserve = 1*) reg [3:0] state_write=4'b0000;

assign vjtag_udr = jtag_udr;//using legacy name
(*preserve = 1*) reg [31:0] reg_data;
initial reg_data=0;
(*preserve = 1*) reg [23:0] jtag_wrdata_to_jtag_save;

reg write_timer;
reg [1:0] byte_count;
initial byte_count=0;

//This process write 3 bytes to JTAG FIFO to send to PC
// byte order choosen: MSB to LSB or Big-endian
// write FIFO size must be bigger than 601*3
always @(posedge clk_10MHz ) begin
	//read_n=1'b0;
	case (state_write)
		4'b0000:	begin
				if(trigger) begin
					jtag_wrdata_to_jtag_save=jtag_wrdata_to_jtag;
					state_write=4'b0001;
				end
		end
		4'b0001:	begin
		
			case(byte_count)
				0:wrdata=jtag_wrdata_to_jtag_save[23:16];
				1:wrdata=jtag_wrdata_to_jtag_save[15:8];
				2:wrdata=jtag_wrdata_to_jtag_save[7:0];
				default : wrdata=jtag_wrdata_to_jtag_save[23:16];
			endcase
			state_write=4'b0010;
		
		
		end
		4'b0010:	begin
			if(waitrequest==1'b0) begin
				//write_timer = toggle;
				write_n=1'b0;
				state_write=4'b0011;
			end
		end
		4'b0011:	begin
			if(waitrequest==1'b0 ) begin
				write_n=1'b1;
				state_write=4'b0100;
			end
		end
		4'b0100:	begin
				if(byte_count==2) begin
					byte_count=0;
					state_write<=4'b0101;
				end
				else begin
					byte_count=byte_count+1;
					state_write<=4'b0001;
				end
			end
		4'b0101:	begin
				if(!trigger)
					state_write=4'b0000;	
   	end
		
	default : state_write=4'b0000;
	endcase
	
end


initial read_n=1'b0;

//This process reads valid bytes from PC to JTAG
always @(posedge clk_10MHz ) begin
	if(!waitrequest & readdata[15] )
		reg_data=readdata;
end


reg [23:0] delay_ctr;

// This was created with the idea to send out timed data to the JTAG.
//But now it is used to blink the LED "hello world!!" 
always @(posedge clk_10MHz ) begin
	if (delay_ctr<10000000) 
		delay_ctr=delay_ctr+1;
	else
		delay_ctr=0;
end

assign toggle=(delay_ctr<5000000)?1'b1:1'b0;
endmodule









