//----------------------------------------------------------------
//EE2003      : Computer Organization
//Assignment  : Floating Point Adder
//Description : Behavioural design of 8-bit floating point adder
//Name        : Vivek Surwase (EE20B153)
//----------------------------------------------------------------

module fpadd(clk,reset,start,a,b,sum,done);
	//defining the input-output ports
	output reg[31:0]sum;
	output reg done;
	input[31:0]a,b;
	input start,clk,reset;
	
	//defining the registers to store extracted information
	reg a_sign, b_sign,s_sign;
	reg[7:0] a_exp, b_exp,s_exp;
	reg[23:0]a_man,b_man;
	reg[24:0]s_man_temp;          //two extra bits for normalization and overflow
	
	always @(posedge reset)
		begin
			assign done  = 0;
			assign sum[31:0] = {{32{1'b0}}}; 
		end

	always @(posedge start)
	begin	
		//extracting the relevant information and storing them in registers
		a_sign      <= a[31];
		b_sign      <= b[31];
		a_exp[7:0]  <= a[30:23];
		b_exp[7:0]  <= b[30:23];
		a_man[23:0] <= {{1'b1},a[22:0]}; 
		b_man[23:0] <= {{1'b1},b[22:0]};
		
		/* 2. Handle special cases: 0, inf, NaN
	if ((exp_a == 0) && (mant_a == 0)) return b;
	if ((exp_b == 0) && (mant_b == 0)) return a;
	if (exp_a == 0xff) return a; // NaN or inf same behaviour
	if (exp_b == 0xff) return b;*/
	
	        //Handling the special cases
	        if(a_exp == 0 && a_man == 0)
	                begin
	                        sum <= b;
	                        assign done = 1;
	                end
	        else if(b_exp == 0 && b_man == 0)
	                begin
	                        sum <= a;
	                        assign done = 1;
	                end 
	        else if(a_exp == 8'hff )
	                begin
	                        sum <= a;
	                        assign done = 1;
	                end 
	        else if(b_exp == 8'hff)
	                begin
	                        sum <= b;
	                        assign done = 1;
	                end 
	                            
		if(!done)
		begin
		        //converting mantissa to 2's complement if there is -ve sign
		        if(a_sign)
			        a_man <= (~a_man)+1;
		        if(b_sign)
			        b_man <= (~b_man)+1;
			        
		        //equalizing the exponents and correspondingly defining the output exponent
		        if(a_exp < b_exp)
			        begin
				        s_exp <= b_exp;
				        a_man <= a_man >>(b_exp - a_exp);
				        a_exp <= b_exp;
			        end
		        if(a_exp > b_exp)
			        begin
				        s_exp <= a_exp;
				        b_man <= b_man >>(a_exp - b_exp);
				        b_exp <= a_exp;
			        end
		        if(a_exp == b_exp)
			        begin
				        s_exp <= a_exp;
			        end	
		        
		        //calculating the sum_mantissa and deciding the sign of result
		        s_man_temp <= a_man + b_man;
		        if(s_man_temp < 0)
			        begin
				        s_sign <= 1;
				        s_man_temp <= (~s_man_temp) + 1;
			        end
		        else
			        s_sign <= 0;
			        
		        //normalizing the result
		        if(s_man_temp[24]==0 && s_man_temp[23]== 1)
			        begin
				        //
			        end

		        else if(s_man_temp[24])
			        begin
				        s_man_temp <= s_man_temp >> 1;
				        s_exp <= s_exp + 1;
			        end	

		        else
			        begin
				        while(s_man_temp[23]!= 1)
					        begin
						        s_man_temp <= s_man_temp <<1;
						        s_exp <= s_exp -1;
					        end
			        end	

		        sum[31:0] = {s_sign,s_exp[7:0],s_man_temp[22:0]};

		        done <= 1;
		end        
	end		 
endmodule

