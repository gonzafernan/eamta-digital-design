// EAMTA 2021 - Digital Design
// Laboratorio 1: Shift/Flash Leds
// Gonzalo G. Fernandez     04/03/2021

// SHIFTLEDS MODULE

`define N_LEDS 4
`define NB_SEL 2
`define NB_COUNT 32
`define NB_SW 4
`define NB_BTN 4

module shiftleds(
                 o_led  ,
                 o_led_r,
                 o_led_b,
                 o_led_g,
                 i_sw   ,
                 i_btn  ,
                 i_reset,
                 clock
                 );

   // Parameters
   parameter N_LEDS    = `N_LEDS               ;
   parameter NB_SEL    = `NB_SEL               ;
   parameter NB_COUNT  = `NB_COUNT             ;
   parameter NB_SW     = `NB_SW                ;
   parameter NB_BTN    = `NB_BTN               ;

   // Localparam
   localparam R0       = (2**(NB_COUNT-10))-1  ;
   localparam R1       = (2**(NB_COUNT-9)) -1  ;
   localparam R2       = (2**(NB_COUNT-8)) -1  ;
   localparam R3       = (2**(NB_COUNT-7)) -1  ;

   localparam SEL0     = `NB_SEL'h0            ;
   localparam SEL1     = `NB_SEL'h1            ;
   localparam SEL2     = `NB_SEL'h2            ;
   localparam SEL3     = `NB_SEL'h3            ;

   // Ports
   output [N_LEDS - 1 : 0] o_led    ;
   output [N_LEDS - 1 : 0] o_led_r  ;
   output [N_LEDS - 1 : 0] o_led_b  ;
   output [N_LEDS - 1 : 0] o_led_g  ;
   input  [NB_SW  - 1 : 0] i_sw     ;
   input  [NB_BTN - 1 : 0] i_btn    ;
   input                   clock    ;
   input                   i_reset  ;

   // Vars
   wire [NB_COUNT - 1 : 0] ref_limit      ;
   reg [NB_COUNT  - 1 : 0] counter        ;
   reg [N_LEDS    - 1 : 0] shiftreg       ;
   reg [N_LEDS    - 1 : 0] flash          ;
   reg [N_LEDS    - 1 : 0] output_fn      ;
   wire                    init           ;
   wire                    reset          ;
   reg    [NB_BTN - 1 : 0] btn_prev_state ;
   reg    [NB_BTN - 1 : 0] btn_state      ;
   
   assign reset     =  ~i_reset;
   assign init      =  i_sw[0];
   assign ref_limit = (i_sw[(NB_SW-1)-1 -: NB_SEL]==SEL0) ? R0 :
                      (i_sw[(NB_SW-1)-1 -: NB_SEL]==SEL1) ? R1 :
                      (i_sw[(NB_SW-1)-1 -: NB_SEL]==SEL2) ? R2 : R3;

   always@(posedge clock or posedge reset) begin
      // estado de reset
      if(reset) begin
         counter  <= {NB_COUNT{1'b0}};
         shiftreg <= {{N_LEDS-1{1'b0}},{1'b1}};
         flash <= {N_LEDS{1'b1}};
         btn_state <= {NB_BTN{1'b0}};
      end
      // estado habilitado (i_sw[0] en alto) aplicacion funcional
      else if(init) begin
         /* overflow de contador profuciendo shift o conmutacion de flash */
         if(counter>=ref_limit) begin
            counter  <= {NB_COUNT{1'b0}};
            shiftreg <= (i_sw[3]) ? {shiftreg[N_LEDS-2 -: N_LEDS-1],shiftreg[N_LEDS-1]} : {shiftreg[0], shiftreg[N_LEDS-1 -: N_LEDS-1]};
            flash <= ~flash;
         end
         /* actualizacion de contador */
         else begin
            counter  <= counter + {{NB_COUNT-1{1'b0}},{1'b1}};
            shiftreg <= shiftreg;
            flash <= flash;
            /* verifico funcion actual (shift o flash) y asigno la salida */
            if (btn_state[0]) begin
                output_fn <= shiftreg;
            end
            else begin
                output_fn <= flash;
            end
         end
         
         /* en estado habilitado tambien analizo flanco de botones para cambiar su estado asociado */
         btn_prev_state <= i_btn;               // registrar estado de todos los botones para comparacion en siguiente clock
         if(i_btn[0] && btn_prev_state[0]==1'b0) begin
            btn_state[0] <= ~btn_state[0];      // flanco de boton 0 cambia funcion (shift <--> flash)
         end
         /* flanco en el resto de los botones implica cambio en el estado asociado a RGB */
         else if (i_btn[1] && btn_prev_state[1]==1'b0) begin
            btn_state[NB_BTN-1:1] <= 3'b001;
         end
         else if (i_btn[2] && btn_prev_state[2]==1'b0) begin
            btn_state[NB_BTN-1:1] <= 3'b010;
         end
         else if (i_btn[3] && btn_prev_state[3]==1'b0) begin
            btn_state[NB_BTN-1:1] <= 3'b100;
         end
      end // if (init)
      else begin
         counter  <= counter;
         shiftreg <= shiftreg;
         flash <= flash;
      end
   end // always@ (posedge clock or posedge reset)

   assign o_led   = btn_state;  // estado de leds equivalentes al estado de funcion de cada boton
   assign o_led_r = (btn_state[1]==1'b1) ? output_fn : {N_LEDS{1'b0}};
   assign o_led_g = (btn_state[2]==1'b1) ? output_fn : {N_LEDS{1'b0}};
   assign o_led_b = (btn_state[3]==1'b1) ? output_fn : {N_LEDS{1'b0}};

endmodule // shiftleds
