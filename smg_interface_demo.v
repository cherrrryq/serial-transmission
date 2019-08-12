module smg_interface_demo
(
    input CLK,                      //输入全局时钟50MHz
	 input RSTn,                     //输入复位信号
	 input R1,
	 input key,
	 output [7:0]SMG_Data,           //输出段选信号（LEDA .. LEDH）
	 output [5:0]Scan_Sig,            //输出列扫描信号（SEL0_T~SEL5_T）
	 output [3:0] led,
	 output rx
);

wire flag_8s;
    /******************************/ 
	 //*数码管控制程序，产生0.1S的计数*/ 
	 /******************************/ 
 
    wire [23:0]Number_Sig;
	 wire [7:0] data;
    demo_control_module U1
	 (
	     .clk( CLK ),
		  .rst( RSTn^flag_8s ),     //
		  .confirm(R1),
		  .key(key),
		  .number_sig( Number_Sig ), // output - to U2
		  .led(led),
		  .data(data),
		  .flag_reg_8s(flag_8s)

	 );
	 
    /******************************/ 
	 //*数码管接口程序，产生段列扫描信号*/ 
	 /******************************/ 
	 
	 smg_interface U2
	 (
	     .CLK( CLK ),
		  .RSTn( RSTn^flag_8s),   //RSTn^flag_8s
		  .Number_Sig( Number_Sig ), // input - from U1
		  .SMG_Data( SMG_Data ),     // output - to top
		  .Scan_Sig( Scan_Sig )     // output - to top
		 
	 );
	 
    /******************************/ 

	 
	 
	 /*
	 
module uart(
            input          mclk,   // 25mhz
            input          rst_n,          //1'd0
            input  [ 3:0]  baud_set,     // 4'd1
            input  [11:0]  data_byte,   //  data[7:0]
            input          send_en,     //
            output  reg   rs232_tx,    //
            output  reg   tx_done      //
    
    );
	  */
	  
	  uart u_uart(
	  .mclk(CLK),
	  .rst_n(RSTn),
	  .baud_set(4'd1),
	  .data_byte(data),
	  .send_en(1'd1),
	  .rs232_tx(rx),
	  .tx_done()
	  );
endmodule
