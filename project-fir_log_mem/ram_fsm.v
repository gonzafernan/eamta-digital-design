

module ram_fsm
  (
    //output reg o_read_en      ,
    output reg o_rst_cnt      ,
    output reg o_en_cnt       ,
   //inputs
    input      i_run          ,
    input      i_run_complete ,
   // clocks
    input      clock          ,
    input      i_reset	       
   );
   
   
   reg [1:0]   state;
   reg [1:0]   next_state;
   
   
   always@(posedge clock) begin:state_clock
	  if(i_reset)
        state<=2'b00;
	  else
	    state<=next_state;				 	
   end
   
   always@(*) begin
	  if(i_reset)
	    next_state=2'b00;
      else begin 
	     case(state) 
	       2'b00: begin:state00
		      if(i_run)
		        next_state=2'b01;	
		      else
		        next_state=2'b00;
	       end
	       
	       2'b01: begin:state01
		      if(i_run_complete)
		        next_state=2'b00;
		      else
		        next_state=2'b01;
	       end
	       
	       default: begin
		      if(i_run)
		        next_state=2'b01;	
		      else
		        next_state=2'b00;
	       end
	     endcase // case (state)
	  end // else: !if(i_reset)
   end // always @ begin
   
   always@(*) begin
	  case(state)	
	    2'b00: begin //STAND BY
	       //o_read_en = 1'b0;
	       o_rst_cnt = 1'b1;
	       o_en_cnt  = 1'b0;
	    end
	    
	    2'b01: begin //READ
	       //o_read_en = 1'b1;
	       o_rst_cnt = 1'b0;
	       o_en_cnt  = 1'b1;
	    end
	    default: begin //STAND BY
	       //o_read_en = 1'b0;
	       o_rst_cnt = 1'b1;
	       o_en_cnt  = 1'b0;
	    end
	    
	  endcase // case (state)
   end // always @ begin
   
endmodule // ram_fsm






