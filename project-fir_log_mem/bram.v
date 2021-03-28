
(* ram_style="block" *)
			
module bram 
  #(
	parameter NB_ADDR   = 15, // number of bits of address
	parameter NB_DATA   = 14, // number of bits of data
    parameter INIT_FILE = ""
	) 
    (
    output reg [NB_DATA  - 1 : 0] o_data         , // RAM output data
    input [NB_DATA       - 1 : 0] i_data         , // RAM input data
    input [NB_ADDR       - 1 : 0] i_write_addr   ,
    input [NB_ADDR       - 1 : 0] i_read_addr    ,
    input                         i_write_enable ,
    input                         i_read_enable  ,
    input                         clock
     );
   
   reg [NB_DATA-1:0]         ram [2**NB_ADDR-1:0];
   
   always @(posedge clock) begin:writecycle
      if (i_write_enable)
	    ram[i_write_addr] <= i_data;       
   end
   
   always @(posedge clock) begin:readcycle
      if (i_read_enable)
        o_data <= ram[i_read_addr];
   end
   
   
   generate
      initial $readmemh(INIT_FILE, ram, 0, (2**NB_ADDR)-1);
   endgenerate
   
   
   
endmodule // afe_ram_dac

