/*
 *  Module `tb_button_logic`
 *
 *  Testbench del modulo de logica de pulsadores.
 *
 *  EAMTA 2021 - Digital Design
 *  Trabajo final.
 *  Gonzalo G. Fernandez     26/03/2021
 *  File: tb_button_logic.v
 */

`timescale 1ns/100ps

module tb_button_logic();

// Localparam
localparam N_BUTTON = 4;

// Vars
reg                         clock;  // Señal de clock
reg                         reset;  // Señal de reset
reg     [N_BUTTON-1 : 0]    button; // Señal de pulsadores
wire    [N_BUTTON-1 : 0]    state;  // Estado asociado a pulsadores

integer i = 0;
integer j = 0;

// Simulacion
initial begin
    // Condiciones iniciales
    reset = 1'b0;
    clock = 1'b1;
    button = {N_BUTTON{1'b0}};
    
    #100 reset = 1'b1; // abandonar estado de reset
    
    for (j=0; j<3; j=j+1) begin
        for (i=0; i<N_BUTTON; i=i+1) begin
            #50 button[i] = 1'b1;
            #10 button[i] = 1'b0;
        end
    end
    
    #50 reset = 1'b0;
    #100 $finish;
end

// Generacion de onda de clock (100MHz)
always
    #5 clock = ~clock;

// Instancia modulo de logica pulsadores
button_logic #
    (
    .N_BUTTON(N_BUTTON)
    )
u_button_logic
    (
        .i_clock(clock),
        .i_reset(~reset),
        .i_signal(button),
        .o_state(state)
    );

endmodule
