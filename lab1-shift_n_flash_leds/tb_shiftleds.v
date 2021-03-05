// EAMTA 2021 - Digital Design
// Laboratorio 1: Shift/Flash Leds
// Gonzalo G. Fernandez     04/03/2021

// TB SHIFTLEDS MODULE

`define N_LEDS 4
`define NB_SEL 2
`define NB_COUNT 14
`define NB_SW 4
`define NB_BTN 4

`timescale 1ns/100ps

module tb_shiftleds();

   parameter N_LEDS   = `N_LEDS   ;
   parameter NB_SEL   = `NB_SEL   ;
   parameter NB_COUNT = `NB_COUNT ;
   parameter NB_SW    = `NB_SW    ;
   parameter NB_BTN   = `NB_BTN   ;

   wire [N_LEDS - 1 : 0] o_led    ;
   wire [N_LEDS - 1 : 0] o_led_r  ;
   wire [N_LEDS - 1 : 0] o_led_b  ;
   wire [N_LEDS - 1 : 0] o_led_g  ;
   reg [NB_SW   - 1 : 0] i_sw     ;
   reg [NB_BTN  - 1 : 0] i_btn    ;
   reg                   i_reset  ;
   reg                   clock    ;

   wire [NB_COUNT - 1 : 0] tb_count;

   assign tb_count = tb_shiftleds.u_shiftleds.counter;
     
      
   initial begin
      /* CONDICIONES INICIALES */
      i_sw[0]      = 1'b0  ;
      i_btn[0]     = 1'b0  ;
      clock        = 1'b0  ;
      i_reset      = 1'b0  ;
      i_sw[2:1]    = `NB_SEL'h0 ;
      i_sw[3]      = 1'b0  ;
      i_btn[3:1]   = 3'b0  ;
       
      #100 i_reset = 1'b1               ;       // abandonar de estado de reset
      #100 i_sw[0] = 1'b1               ;       // habilitacion de aplicacion
      
      #100      i_btn[1]    = 1'b1      ;       // presion de boton 1
      #50       i_btn[1]    = 1'b0      ;       // iniciar secuencia de leds (en rojo)
      
      /* TEST DE CAMBIOS EN FRECUENCIA */
      #1000     i_sw[2:1]   = `NB_SEL'h1;
      #1000     i_sw[2:1]   = `NB_SEL'h2;
      #1000     i_sw[2:1]   = `NB_SEL'h3;
      
      #1000     i_sw[2:1]   = `NB_SEL'h1;       // volver a frecuencia inicial
      
      /* TEST DE CAMBIO SHIFT <--> FLASH */
      #100      i_btn[0]    = 1'b1      ;       
      #50       i_btn[0]    = 1'b0      ;       // modo shift
      #10000    i_btn[0]    = 1'b1      ;
      #50       i_btn[0]    = 1'b0      ;       // modo flash
      #10000    i_btn[0]    = 1'b1      ;       
      #50       i_btn[0]    = 1'b0      ;       // modo shift
      
      /* TEST CAMBIO DE DIRECCION EN SHIFT */
      #5000     i_sw[3]     = 1'b1      ;
      
      /* TEST RGB FUNCIONAL EN AMBOS MODOS */
      #10000    i_btn[2]    = 1'b1      ;       
      #50       i_btn[2]    = 1'b0      ;       // color verde en shift
      #10000    i_btn[3]    = 1'b1      ;       
      #50       i_btn[3]    = 1'b0      ;       // color azul en shift
      #10000    i_btn[1]    = 1'b1      ;       
      #50       i_btn[1]    = 1'b0      ;       // color rojo en shift
      
      #10000    i_btn[0]    = 1'b1      ;
      #50       i_btn[0]    = 1'b0      ;       // modo flash
      
      #10000    i_btn[2]    = 1'b1      ;       
      #50       i_btn[2]    = 1'b0      ;       // color verde en flash
      #10000    i_btn[3]    = 1'b1      ;       
      #50       i_btn[3]    = 1'b0      ;       // color azul en flash
      #10000    i_btn[1]    = 1'b1      ;       
      #50       i_btn[1]    = 1'b0      ;       // color rojo en flash
      
      
      #10000 $finish;
   end

   always #5 clock = ~clock;

shiftleds
  #(
    .N_LEDS   (N_LEDS  ),
    .NB_SEL   (NB_SEL  ),
    .NB_COUNT (NB_COUNT),
    .NB_SW    (NB_SW   ),
    .NB_BTN   (NB_BTN  )
    )
  u_shiftleds
    (
     .o_led     (o_led  )  ,
     .o_led_r   (o_led_r)  ,
     .o_led_b   (o_led_b)  ,
     .o_led_g   (o_led_g)  ,
     .i_sw      (i_sw   )  ,
     .i_btn     (i_btn  )  ,
     .i_reset   (i_reset)  ,
     .clock     (clock  )
     );

endmodule // tb_shiftleds
