# EAMTA 2021 - Digital Design

## Laboratorio 3
El objetivo es realzar la integración del filtro FIR con la memoria BRAM.

Se implementó un generador de señales con la capacidad de transmitir cuatro tipos de señales donde la frecuencia de muestreo es fs=48kHz:
- Señal 1: f1=1,5kHz y f2=17kHz (archivo [mem17khz.hex](./signals/mem17khz.hex))
- Señal 2: f1=1,5kHz y f2=8,5kHz (archivo [mem8p5khz.hex](./signals/mem8p5khz.hex))
- Señal 3: f1=1,5kHz y f2=5,66kHz (archivo [mem5p66khz.hex](./signals/mem5p66khz.hex))
- Señal 4: f1=1,5kHz y f2=4,25kHz (archivo [mem4p25khz.hex](./signals/mem4p25khz.hex))

Se integran los 4 generadores de señales de tal forma que pueden ser seleccionados en cualquier instante de tiempo a través de los botones *i_sel[1:0]*.

A la salida del generador de señales se encuentra un filtro FIR, configurado a una frecuencia de corte de fcut=6kHz. Tanto el bloque de generación de señales como el filtro se habilitan o deshabilitan mediante la señal *i_enable[0]*.

Además, se implementa una memoria BRAM con su correspondiente máquina de estados finitos (FSM) para almacenar la salida del filtro FIR (1024 muestras). Dicha memoria almacenará las muestras luego de detectar el flanco ascendente de la señal de enable de logueo (*i_enable[1]*), y su contenido podrá ser leído cuando la señal de enable de lectura se encuentr en alto (*i_enable[2]*).

Las señales de enable se implementan con switch y las señales SEL se implementan con pulsadores (por lo que fue necesario contemplar su vuelta al estado en reposo).

Lo anterior se resume en el siguiente diagrama:

![](./imgs/img_lab_scheme.png)

**NOTA: Se consideró que los archivos hex se encuentran en formato punto fijo S(8, 6). La salida del filtro FIR es de 16 bits, y se entrega la información en formato punto fijo S(16,14)**.

### Simulación
Se implementó un testbench para evaluar el correcto funcionamiento del bloque conformado por el generador de señales y el filtro FIR ([tb_signal_mux.v](./tb_signal_mux.v)). De allí se obtuvo el resultado de la siguiente imagen:

![](./imgs/img_sim_signal_mux.png)

Donde se obseva en verde la señal filtrada, en amarillo la señal salida del multiplexor (entrada del filtro), y el resto son las señales original obtenidas de sus correspondientes archivos .hex (carpeta [signals](./signals)).

Además se implementó un testbench para el testeo del bloque BRAM más FSM ([tb_ram_save.v](./tb_ram_save.v)), con pequeñas modificaciones al visto en clase.

Por último, se desarrolló un testbench para la evaluación de integración de todos los módulos (módulo top), archivo [tb_top.v](./tb_top.v). Se obtuvieron los siguientes resultados:

| i_sel[1:0] | Simulación                                |
|:----------:|:-----------------------------------------:|
| 00 | ![](./imgs/img_sim_top_signal1.png) |
| 01 | ![](./imgs/img_sim_top_signal2.png) |
| 10 | ![](./imgs/img_sim_top_signal3.png) |
| 11 | ![](./imgs/img_sim_top_signal4.png) |
