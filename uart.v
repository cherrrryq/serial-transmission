`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/10/25 21:43:34
// Design Name: 
// Module Name: uart
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module uart(
            input          mclk,   // 25mhz
            input          rst_n,          //1'd0
            input  [ 3:0]  baud_set,     // 4'd1
            input  [7:0]  data_byte,   //  data[7:0]
            input          send_en,     //????????
            output  reg   rs232_tx,    //???????????
            output  reg   tx_done      //?????????????
    
    );
    
reg           uart_state;
reg   [15:0]  bps_DR;   //??????????
reg           bps_clk;   // bps???
reg    [15:0] div_cnt;   //?????????
reg    [ 3:0] bps_cnt;   //bps??????
reg    [7:0] r_data_byte;  // ????? ??????

parameter START_BIT = 0,
            STOP_BIT = 1;
            
 always @(posedge mclk or negedge rst_n)
 begin
     if(!rst_n)
          bps_DR <= 16'b0;    
      else 
      begin
      case(baud_set)
          //0: bps_DR <= 5207;//bps_9600
        0: bps_DR <= 31;//bps_9600 just test
        1: bps_DR <= 2603;//bps_19200
        2: bps_DR <= 1302;//bps_38400
        3: bps_DR <= 867;//bps_57600
       // 4: bps_DR <= 432;//bps_115200
        default: bps_DR <= 5207;//bps_9600
        endcase
        end
 end
 //
 always @(posedge mclk, negedge rst_n)
 begin
    if(!rst_n)
    begin
        bps_clk <= 1'b0;
        div_cnt <= 1'b0;
    end
    else if(uart_state)
    begin
        if(div_cnt == bps_DR) 
        begin
            bps_clk <= 1;
            div_cnt <= 0;
        end
        else
        begin
            bps_clk <= 0;
            div_cnt <= div_cnt + 1;
        end
    end
 end               
 //bps_cnt
	 always @(posedge mclk or negedge rst_n) 
 begin
    if(!rst_n)
        bps_cnt <= 0;
    else if(tx_done)
        bps_cnt <= 0;
    else 
    begin
        if (bps_cnt == 11)
            bps_cnt <= 0;
        else if(bps_clk)
            bps_cnt <= bps_cnt + 1;
        else 
            bps_cnt <= bps_cnt;
    end
 end
 //???????????????????????????
always @(posedge mclk or negedge rst_n)
      begin
         if(!rst_n)
             r_data_byte <= 8'b0;
         else if(send_en == 1)          // ??case
             r_data_byte <= data_byte;      //?????????? ???????? 9600 bps_set ? 4'd1????????
      end
        
 always @(posedge mclk or negedge rst_n)
      begin
         if(!rst_n)
             rs232_tx <= 0;
         else 
         begin
             case(bps_cnt)
             0:rs232_tx <= 1;//????????????????????????1??
             1:rs232_tx <= START_BIT;
             2:rs232_tx <= r_data_byte[0];
             3:rs232_tx <= r_data_byte[1];
             4:rs232_tx <= r_data_byte[2];
             5:rs232_tx <= r_data_byte[3];
             6:rs232_tx <= r_data_byte[4];
             7:rs232_tx <= r_data_byte[5];
             8:rs232_tx <= r_data_byte[6];
             9:rs232_tx <= r_data_byte[7];    
            /* 2:rs232_tx <=  1'b1;
             3:rs232_tx <=  1'b1;
             4:rs232_tx <=  1'b1;
             5:rs232_tx <=  1'b1;
             6:rs232_tx <=  1'b1;
             7:rs232_tx <=  1'b1;
             8:rs232_tx <=  1'b1;
             9:rs232_tx <=  1'b1;*/
              10:rs232_tx <= STOP_BIT;
             default:rs232_tx <= 1;
             endcase
         end
      end   
  always @(posedge mclk or negedge rst_n)
  begin
          if(!rst_n)
                  tx_done <= 0;
           else if(bps_cnt == 14)
                  tx_done <= 1;
                else
                  tx_done <= 0;
  end    
 
  always @(posedge mclk or negedge rst_n)
      begin
         if(!rst_n)
             uart_state <= 0;
         else if(send_en)
             uart_state <= 1;
         else if(tx_done)
             uart_state <= 0;
         else 
             uart_state <= uart_state;
     end
                  
endmodule
