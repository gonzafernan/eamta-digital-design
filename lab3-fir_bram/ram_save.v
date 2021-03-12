module ram_save
    #(
	   parameter NB_ADDR       = 11,
	   parameter NB_DATA       = 16,
       parameter INIT_FILE     = ""
  	)
    (
        output reg [NB_DATA  - 1 : 0] out_data_from_ram     ,
        output reg                    out_full_from_ram     ,
        input                         in_log_ram_run        ,
        input [NB_DATA       - 1 : 0] in_data               ,
        input [NB_ADDR       - 1 : 0] in_ram_read_addr      ,
        input                         ctrl_valid            ,
        input                         clock                 , //System Clock
        input                         cpu_reset               //System Reset
     );

   ///////////////////////////////////////////
   // Parameters
   localparam                     NB_COUNTER = NB_ADDR;   
   ///////////////////////////////////////////
   // Registers
 
   wire                           counter_rst;
   wire                           counter_en;
   wire                           counter_full;
   reg [NB_COUNTER - 1 : 0]       counter;
   wire [NB_DATA   - 1 : 0]       data_from_ram;
   reg [NB_ADDR    - 1 : 0]       ram_addr_from;

   
   always@(posedge clock) begin
      out_data_from_ram     <= data_from_ram;
      ram_addr_from         <= in_ram_read_addr;
   end
   
  
   always @(posedge clock) begin:adccnt
	  if(counter_rst)
	    counter <=  {NB_COUNTER{1'b0}};
	  else if(counter_en && ctrl_valid) 
	    counter <= counter + {{NB_COUNTER-1{1'b0}},1'b1};	
   end
   
   assign counter_full = (counter == {NB_COUNTER{1'b1}})? 1'b1 : 1'b0;
   
   //----------
   always @ (posedge clock) begin
      if(cpu_reset  | !in_log_ram_run)
        out_full_from_ram<=1'b0;
      else begin
         if(counter_full)
	       out_full_from_ram<=1'b1;
      end 
   end
   //------------------
   
   ram_fsm
     u_ram_fsm 
       (//outputs
	    //.o_read_en      (                                           ),
	    .o_rst_cnt      (counter_rst                                ),
	    .o_en_cnt       (counter_en                                 ),
	    .i_run          (in_log_ram_run && !out_full_from_ram ),
	    .i_run_complete (counter_full                               ),
	    .clock          (clock                                      ),
	    .i_reset        (cpu_reset                                  )	       
	    );
   
   bram
     #(
       .NB_ADDR   (NB_ADDR   ),
       .NB_DATA   (NB_DATA   ),
       .INIT_FILE (INIT_FILE )
       ) 
       u_bram
         (
          .o_data         (data_from_ram       ),
          .i_data         (in_data             ),
          .i_write_addr   (counter             ),
          .i_read_addr    (ram_addr_from       ),
          .i_write_enable (counter_en          ),
          .i_read_enable  (1'b1                ),
          .clock          (clock               )
          );

   
endmodule 	     
