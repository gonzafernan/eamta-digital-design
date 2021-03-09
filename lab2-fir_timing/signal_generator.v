module signal_generator(
                 i_clock,
                 i_reset ,
                 o_signal                 
                 );

   // Parameters
   parameter NB_DATA    = 8;
   parameter NB_SEL     = 2;

   parameter NB_COUNT   = 10;
   parameter MEM_INIT_FILE = "D:\digital_design_course\eamta-digital-design\lab2-fir_timing\mem.hex";

   // Ports
   output [NB_DATA - 1 : 0] o_signal;
   input                    i_clock;
   input                    i_reset;

   // Vars
   integer i;
   reg [NB_COUNT  - 1 : 0] counter;
   reg [NB_DATA  - 1 : 0]  data[1023:0];

  initial begin
    if (MEM_INIT_FILE != "") begin
      $readmemh(MEM_INIT_FILE, data);
    end
  end

   always@(posedge i_clock or posedge i_reset) begin
      if(i_reset) begin
         counter  <= {NB_COUNT{1'b0}};
   end
      else begin
         counter  <= counter + {{NB_COUNT-1{1'b0}},{1'b1}};
      end
   end

   assign o_signal = data[counter];


endmodule
