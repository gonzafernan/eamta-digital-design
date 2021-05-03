# EAMTA 2021 - Digital Design

El curso tiene como objetivo enseñar los conceptos básicos del diseño digital y esta dirigido por los profesores Dr. Ing. Ariel Pola (CognitionBI-Fundación Fulgor) y Ing. Federico G. Zacchigna (FIUBA).

En la primer parte se revisan los conceptos del lenguaje HDL Verilog y se presentan los elementos básicos del diseño digital: Circuitos combinacionales y circuitos secuenciales.

Durante la segunda parte, se abordan los conceptos de timing y retardos de compuerta y señal para comprender cómo diseñar correctamente un circuito digital. La importancia de un diseño correcto queda demostrada, no solo desde el punto de vista lógico, sino también desde el dominio del tiempo, es decir, hacerlo funcionar de manera eficiente o, en nuestro caso, lo suficientemente rápido como para satisfacer los requerimientos de la aplicación.

En la tercera parte, se simula e implementa un circuito síncrono en una FPGA. Durante este proceso se verifica que se cumplan todas las restricciones y finalmente se valida su operación lógica.

Los contenidos del curso pueden resumirse en los siguientes items:

- Introducción a Verilog
- Circuitos combinacionales y secuenciales
- Representación de números binarios en punto fijo y punto flotante
- Diagramas de tiempo de circuitos combinacionales y secuenciales
- Ejemplos básicos de síntesis jerárquica
- Análisis temporal de circuitos
- Circuitos síncronos y retardos de compuerta
- Tiempos característicos de un FF
- Implementación de circuitos básicos en FPGA

## Contenido del repositorio
La práctica consistió en 3 laboratorios y un proyecto final para la aprobación del curso. Los trabajos pueden encontrarse en los siguientes links del repositorio:
- [Lab 1: Shift y flash de RGB LEDs](./lab1-shift_n_flash_leds)
- [Lab 2: Filtro FIR y análisis de reportes de timing](./lab2-fir_timing)
- [Lab 3: Integración del filtro FIR con la memoria BRAM](./lab3-fir_bram)
- [Proyecto: Memoria de logueo con filtros FIR y operaciones aritmeticas](./project-fir_log_mem)

La herramienta utilizada fue la **suite Vivado de Xilinx**. Para el curso se dispuso de un banco de FPGA remotas a las que se podía acceder, programarlas y observar resultados utilizando los IP cores de Vivado VIO e ILA.

## Certificación
Los laboratorios y el proyecto final fueron corregidos y aprobados, con lo que recibí no solo el certificado de asistencia sino también el de aprobación del curso. Ambos certificados pueden encontrarse en la carpeta [docs](./docs).

## Sobre EAMTA
La Escuela Argentina de Micro Nanoelectrónica, Tecnología y Aplicaciones es una escuela de una semana donde estudiantes de pre y posgrado asisten a cursos intensivos en temas relacionados con el área de micro-nanoelectrónica, con el objetivo de difundir esta área de conocimiento, profundizando el saber de profesionales y académicos, y promoviendo el desarrollo de esta clase de tecnología en el país y la región.
