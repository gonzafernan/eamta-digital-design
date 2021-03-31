# EAMTA 2021 - Digital Design

## Trabajo Final: Memoria de logueo con filtros FIR y operciones aritméticas

El objetivo es integrar bloques basicos y aplicar el análisis de complejidad y timing sobre el diseño.

Consiste en la implentación de dos memorias de logueo de 16 bits de entrada, dos filtros FIR de 8 bits de salida y un bloque que ejecuta operaciones de suma y producto de las muestras de entrada. Se incluye además, como en el resto de los laboratorios, los módulos VIO e ILA con el objetivo de facilitar el control de diseño.

![](./imgs/project_schematic.png)

Los módulos [gen_fir](./gen_fir.v) y [ram_save](./ram_save.png) se implementaron igual que en el [laboratorio 3](../lab3-fir_bram).

La entrada de cada filtro FIR se obtiene del multiplexado de señales generadas a partir de archivos '.hex'. En el primer bloque BRAM con FSM se loguea la concatenación de señales filtradas: {dato1[7:0], dato0[7:0]} (16 bits). En el segundo se memoriza el resultado de la operación aritmética.

*i_sel[3:0]* consiste en enttradas de pulsadores, por lo que se considera su vuelta a reposo (modificación de estado con flanco ascendente). Dicha lógica se encuentra en el módulo [button_logic](./button_logic.v). *i_sel[1:0]* permite la selección de señal generadda por el primer *gen_fir0*, e *i_sel[3:2]* permite la selección de la señal generada por el módulo *gen_fir1*.

*i_enable[3:0]* consiste en entrada de switch.

- *i_enable[0]* permite la habilitación y deshabilitación de los módulos *gen_fir* y el módulo de operaciones ariteméticas *adder_mult*.
- *i_enable[1]* permite comenzar la escritura en ambos bloques *ram_save* (no se controlan de forma independiente).
- *i_enable[2]* habilita o deshabilita el contador de dirección de lectura en ambas BRAM, con lo que permite la lectura de las memorias.
- *i_enable[3]* permite la selección de operación aritmética a realizar, ya sea adición (0) o producto (1).

Como en el laboratorio 3, se tienen las mismas salidas asociadas a las memorias: *o_log_ram_full* flag que indica la escritua de la memoria completa, y *o_log_data_from_ram* que es el dato leído de la memoria.
