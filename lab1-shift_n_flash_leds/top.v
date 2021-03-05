// EAMTA 2021 - Digital Design
// Laboratorio 1: Shift/Flash Leds
// Gonzalo G. Fernandez     04/03/2021

// TOP MODULE

`define N_LEDS 4
`define NB_SEL 2
`define NB_COUNT 32
`define NB_SW 4
`define NB_BTN 4

module top(clock);

   // Parameters
   parameter N_LEDS    = `N_LEDS               ;
   parameter NB_SEL    = `NB_SEL               ;
   parameter NB_COUNT  = `NB_COUNT             ;
   parameter NB_SW     = `NB_SW                ;
   parameter NB_BTN    = `NB_BTN               ;

   // Ports
   input clock;

   // Vars
   wire [N_LEDS - 1 : 0] o_led     ;
   wire [N_LEDS - 1 : 0] o_led_r   ;
   wire [N_LEDS - 1 : 0] o_led_b   ;
   wire [N_LEDS - 1 : 0] o_led_g   ;
   
   wire  [NB_SW  - 1 : 0] i_sw     ;
   wire  [NB_BTN - 1 : 0] i_btn    ;
   wire                   clock    ;
   wire                   i_reset  ;
   
   // Instancia modulo de aplicacion
   shiftleds
   u_shiftleds
   (
     .o_led  (o_led)  ,
     .o_led_r(o_led_r),
     .o_led_b(o_led_b),
     .o_led_g(o_led_g),
     
     .i_sw   (i_sw)   ,
     .i_btn  (i_btn)  ,
     .i_reset(i_reset),
     
     .clock(clock)    
    );

    // Instancia modulo VIO
    vio
    u_vio
    (   
    .clk_0(clock)         ,
    
    .probe_in0_0(o_led)   ,
    .probe_in1_0(o_led_r) ,
    .probe_in2_0(o_led_b) ,
    .probe_in3_0(o_led_g) ,
        
    .probe_out0_0(i_reset),
    .probe_out1_0(i_sw)   ,
    .probe_out2_0(i_btn)  
    );
    
    ila_0 
    u_ila
    (
    .clk(clock),
    .probe0({o_led, o_led_r, o_led_g, o_led_b})
    );

endmodule