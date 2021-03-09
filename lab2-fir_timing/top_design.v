module top_design(
		  clock
		  );

   // Parameters
   parameter N_PROBE   = 8;

   // Ports
   input                   clock;

   // Vars
   wire                    reset;
   
   wire [8  - 1 : 0] w_signal;
   wire [8  - 1 : 0] w_filtered_signal;
   
   wire [N_PROBE - 1 : 0] w_probe0;
   wire [N_PROBE - 1 : 0] w_probe1;

signal_generator
    u_signal_generator
       (
	.i_clock(clock),
	.i_reset(~reset),
	.o_signal(w_signal)
	);

filtro_fir
    u_filtro_fir
    (
    .clk        (clock),
    .i_srst     (~reset),
    .i_en       (1'b1),
    .i_data     (w_signal),
    .o_data     (w_filtered_signal)
    );
        
ila_0
    u_ila
    (
    .clk        (clock),
    .probe0     (w_signal),         // Bits: 8
    .probe1     (w_filtered_signal) // Bits: 8
    );   

vio
    u_vio
    (
    .clk_0       (clock),
    .probe_in0_0 (w_filtered_signal), // Bits: 8
    .probe_out0_0(reset)              // Bits: 1
    );
    
endmodule

