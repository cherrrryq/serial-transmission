 /******************************/
 /******6位BCD计数器产生程序******/
  
module demo_control_module(
	input clk,
	input rst,
	input confirm,
	input key,
	output [23:0]number_sig,
	output [3:0]led,
	output [7:0]data,
	output flag_reg_8s
);

     //20ms 扫描计数 
reg  key_confirm , key_key;
reg [19:0] count;
always@(posedge clk)
begin if(!rst)
		count <= 20'd0;
		else
begin if(count == 20'd999999)
     begin
       count <= 20'b0;
		 key_confirm <= confirm ;
		 key_key <= key;
     end
	    else  count <= count +20'b1;
		 end  end 

reg  led_guide;  initial led_guide = 1;
		 
reg [4:0]count_confirm; initial count_confirm = 0;
reg flag_confirm; initial flag_confirm = 1;
always@(posedge clk)
if(!rst) begin count_confirm <= 0;  led_guide<= 1; end
else begin case(key_confirm)
			  1'b0: begin if(flag_confirm)  begin
					 count_confirm <= count_confirm +1'b1; flag_confirm<=0; led_guide <= led_guide +1'b1; end
							  else count_confirm <= count_confirm ; end
			  1'b1: begin flag_confirm <= 1; end
            endcase  end
				
reg [7:0]count_key; initial count_key = 0;
reg flag_key; initial flag_key = 1;
always@(posedge clk)
if(!rst) begin count_key[7:0] <= 0; end
else begin case(key_key)
			  1'b0: begin if(flag_key) begin
					 count_key[count_confirm] <= 1'b1; flag_key <= 0; end
									else count_key<= count_key ; end
				1'b1:begin flag_key <= 1; end
				endcase end

reg flag_led1, flag_led2, flag_final;
always@(posedge clk) 
if(!rst) begin  flag_led1 <= 0; flag_led2 <= 0; flag_final <= 0; end
else  case(count_confirm)
		5'd4:     begin flag_led1 <= 1; flag_led2 <= 0; flag_final <= 0; end
		5'd8:     begin flag_led1 <= 0; flag_led2 <= 1; flag_final <= 1; end
		default : begin flag_led1 <= 0; flag_led2 <= 0; flag_final <= 0; end
      endcase 

assign led={(flag_led1|led_reg1),(flag_led2^led_reg2)};    
		
reg [3:0]number1;
reg flag_record1; initial flag_record1 = 1;
always@(posedge clk)
	if(!rst) 
	begin number1 <= 0;   flag_record1 <= 1; end
	else if(flag_led1&flag_record1) 
	     begin number1 <= count_key[3:0]; flag_record1 <= 0; end
		
reg [3:0]number2;
reg flag_record2; initial flag_record2 = 1;
always@(posedge clk)
	if(!rst)
	begin number2 <= 0;   flag_record2 <= 1; end
	else if(flag_led2&flag_record2)
		  begin number2 <= count_key[7:4]; flag_record2 <= 0; end

reg [3:0]number_large;
reg flag_1,flag_2,flag_m;
always@(posedge clk)
	if((!rst)|(!flag_final)) begin number_large <= 0; flag_1 <=0; flag_2<=0; flag_m <=0; end
	else if(number1 > number2) begin number_large <= number1; flag_1 <=1; flag_m <=0; flag_2 <=0;end
			else if( number1 == number2) begin number_large <= number1 ; flag_m <= 1;flag_1 <=0; flag_2 <=0; end
					else begin number_large <= number2; flag_2 <= 1; flag_m <=0; flag_1 <=0;end
					
reg [23:0] lins;
always@(posedge clk)
begin
lins[3:0] <= number_large;
lins[19:16] <= number2;
lins[23:20] <= number1;
lins[11:8] <=number_large;
lins[15:12] <= 4'd10;
lins[7:4] <=4'd10;
end
		
reg flag; initial flag = 0;
always@(posedge clk) begin
if(!rst)
begin flag = 0; end
else if(count_confirm > 5'd7) begin flag = 1; end
end

reg flag_8s; initial flag_8s = 0;
reg [28:0] counter;
reg [25:0]count05;   //1.34秒
always@(posedge clk) begin
if(!flag) begin counter <= 0; flag_8s <= 0; count05 <= 0; end
else begin  count05 <= count05 + 1'b1; 
				if(counter == 29'd399999991) begin
				flag_8s <= 1;
				counter <=0;
				end
				else counter <= counter +1'b1; end
		end
		
reg led_reg1, led_reg2;
always@(posedge clk)  begin
if(!rst) begin led_reg1 <= 0; led_reg2 <= 0; end
else begin if(count05< 26'd34500000) begin  
		case({flag_1,flag_2,flag_m})
		3'd100: begin led_reg1 <= 1; led_reg2 <= 0; end
		3'd010: begin led_reg1 <= 0; led_reg2 <= 1; end
		3'd001: begin led_reg1 <= 1; led_reg2 <= 1; end
		default: ;
		endcase  end
		else begin led_reg1 <= 0; led_reg2 <= 0;  end end end

assign flag_reg_8s = flag_8s;
assign number_sig[23:0] = lins[23:0] ;
assign data = {4'd0,lins[11:8]};
endmodule 
