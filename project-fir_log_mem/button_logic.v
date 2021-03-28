/*
 *  Module `button_logic`
 *
 *  Logica de cambio de estado por flanco de subida de señal (pulsador).
 *  Ante cada flanco de subida de un pulsador, su estado asociado se
 *  conmuta.
 *  Ante un alto en la señal de reset, el estado de todos los pulsadores
 *  se coloca en bajo.
 *
 *  EAMTA 2021 - Digital Design
 *  Trabajo final.
 *  Gonzalo G. Fernandez     26/03/2021
 *  File: button_logic.v
 */

module button_logic(
        i_clock,
        i_reset,
        i_signal,
        o_state
    );

// Parameters
parameter N_BUTTON  = 1;                // Cantidad de pulsadores

// Ports
input                           i_clock;    // Señal de clock
input                           i_reset;    // Señal de reset asincrono
input       [N_BUTTON-1 : 0]    i_signal;   // Entrada pulsador
output  reg [N_BUTTON-1 : 0]    o_state;    // Salida estado asociado a pulsador

// Vars
reg     [N_BUTTON-1 : 0]    reg_prev_state;  // Registro estado previo asociado a pulsador

integer i = 0;

always @(posedge i_clock or posedge i_reset) begin
    if (i_reset == 1'b1) begin
        o_state <= {N_BUTTON{1'b0}};
    end
    else begin
        // Guardar estado previo de los pulsadores para comparar en siguiente clock
        reg_prev_state <= i_signal;
        // Comparacion con estado anterior
        for (i=0; i<N_BUTTON; i=i+1) begin
            if (i_signal[i] == 1'b1 && reg_prev_state[i] == 1'b0) begin
                o_state[i] <= ~o_state[i]; // Conmutacion de estado
            end
        end
    end
end

endmodule
