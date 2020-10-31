function LTA (Sx_in,size_block,overlap,windows)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%*FUNCION PARA DETERMINAR LA LTA (RESPUESTA EN FRECUENCIA A LARGO PLAZO)* %
% Entradas:                              Salidas:                         %
%          Sx_in: Señal de entrada.              -El espectro LTA global  %
%          size_block: Tamaño de bloque.         -Una matriz que contenga %
%          overlap: Solapamiento.                 un espectro LTA por cada%
%          windows: Ventana a utilizar.           minuto de grabación.    %
%               1- blackman                                               %
%               2- hanning                                                % 
%               3- gausiana                                               %
%          -------------------------------------------------------------  %
% SOLAPAMIENTO: entre los bloques                                         %

% 1. Cargar fichero
[y,FS] = audioread (Sx_in);
y = y(:,1)';

% 2. Definir ventana %
size_ventana = 2.^nextpow2(size_block);

% 3. Averiguar numero de bloques o ventanas para el caso en cuestion %
numero_ventanas = length(y)/((1-overlap)*size_ventana);

% 4. Cantidad de ceros para completar el ultimo bloque (fft eficiente) %
cant_ceros = (numero_ventanas*size_ventana) - length (y);

% 5. Completamos con ceros el vector de la señal %
y = [y zeros(1,cant_ceros)];

% 6. Creamos matriz para guardar espectro (modulo) de cada bloque %
Nf = ceil((size_ventana+1)/2);             %Nos quedamos con el espectro real

% 7. Ciclo para recorrer bloque por bloque %
LTA_global=0;

% Definiendo un dominio en la frecuencia %
f = FS*(0:(size_ventana/2))/size_ventana;


for i =1:floor(numero_ventanas)
    
    % 8. Definimos inicio de cada bloque %
    inicio_bloque = (i-1)*size_ventana*overlap + 1;
    
    % 9. Definimos final de cada bloque %
    fin_bloque = (inicio_bloque + size_ventana)-1;
           
    % 10. Se extrae del vector ¨y¨ la porcion de cada bloque en cuestion %
    bloque = y(1, inicio_bloque:fin_bloque);
   switch windows
   case 1
      bloque_enventanado = bloque.*blackman(size_ventana)';
   case 2
      bloque_enventanado = bloque.*hann(size_ventana)';
   case 3
      bloque_enventanado = bloque.*gausswin(size_ventana)';
   end
   
    % 12. Espectro y modulo del bloque
    var = fft(bloque_enventanado,size_ventana);
    var = abs (var(1:ceil((size_ventana+1)/2)));          %Sólo nos quedamos con el espectro real     
    
    % 13. Pasamos a dB el Bloque
    var_1_dB = 20*log10(var);               
    plot (f,var_1_dB,'g');
    hold on
    
    % 14. Matriz utilizada como una memoria %
    LTA_global=LTA_global+var;   
end

% 15. Hacemos la media.
LTA_global=LTA_global/numero_ventanas;   

% 16. Pasammos a dB
LTA_dB = 20*log10(LTA_global);     

% 17. Dibujamos la media en dB
plot(f,LTA_dB, 'k','LineWidth', 7)          
hold off
title ('Espectro a largo plazo (LTA)')
xlabel('Frecuencia (Hz)')
ylabel('Amplitud (dB)')

end






