function Power_Progress (Sx_in,size_block,overlap)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%*FUNCION PARA DETERMINAR LA EVOLUCION DE LA POTENCIA DE UNA SEÑAL %
% Entradas:                              Salidas:                         %
%          Sx_in: Señal de entrada.              -Evolucion temporal de   %
%          size_block: Tamaño de bloque.          la potencia de la señal %
%          overlap: Solapamiento.                                         %
%                                                                         %
%          -------------------------------------------------------------  %
% SOLAPAMIENTO: entre los bloques                                         %

% 1. Cargar fichero %
[y,FS] = audioread (Sx_in);
y = y(:)';

cant_segundos = length(y)/FS;

% 2. Definir ventana %
size_ventana = 2.^nextpow2(size_block);

% 3. Averiguar numero de bloques o ventanas para el caso en cuestion %
numero_ventanas = ceil(length(y)/((1-overlap)*size_ventana));

% 4. Cantidad de ceros para completar el ultimo bloque %
cant_ceros = (numero_ventanas*size_ventana) - length (y);

% 5. Completamos con ceros el vector de la señal %
y = [y zeros(1,cant_ceros)];

% 6. Crear vector para guardar la potencia %
power = zeros(1,numero_ventanas); 

% 7. Iniciamos el proceso
for i =1:numero_ventanas
    
    % 8. Definimos inicio de cada bloque %
    inicio_bloque = (i-1)*size_ventana*overlap + 1;
    
    % 9. Definimos final de cada bloque %
    fin_bloque = (inicio_bloque + size_ventana)-1;
    
    % 10. Se extrae del vector ¨y¨ la porcion de cada bloque en cuestion %
    bloque = y(1, inicio_bloque:fin_bloque);
   
    % 11. Calculamos la potencia a partir las muestras %
    var = ((sum ((bloque).^2))/size_ventana)^0.5;    
    
    % 12. Llevamos a dB la potencia %
    power(i) = 20*log10(var);
     
end

% 13. Representamos la evolución temporal %
eje_x = linspace(0, cant_segundos, length(power));
plot(eje_x,power) 
axis ([0 cant_segundos min(power) max(power)])
grid on
title ('Evolución de la potencia')
xlabel('Tiempo (s)')
ylabel('Potencia (dB)')

end