function [DC_global] = DC_offset (Sx_in,size_block,overlap,windows)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%*FUNCION PARA DETERMINAR LA LTA (RESPUESTA EN FRECUENCIA A LARGO PLAZO)* %
% Entradas:                              Salidas:                         %
%          Sx_in: Señal de entrada.              -Componente global de DC %
%          size_block: Tamaño de bloque.         -Evolucion temporal de la%
%          overlap: Solapamiento.                 componente de DC        %
%          windows: Ventana a utilizar.                                   %
%               1- blackman                                               %
%               2- hanning                                                % 
%               3- gausiana                                               %
%          -------------------------------------------------------------  %
% SOLAPAMIENTO: entre los bloques                                         %

% 1. Cargar fichero %
[y,FS] = audioread (Sx_in);
y = y(:)';

% 2. Cálulo del nivel de continua global
DC_global = mean(y);

% 3. Definir ventana %
size_ventana = 2.^nextpow2(size_block);    

% 4. Creamos un vector para guardar la evolcion temporal %
progress_DC = zeros(1,floor(length(y)/FS));

% 5. Iniciamos el proceso %
for i =1:floor(length(y)/FS)
    
    % 6. Definimos el inicio de cada bloque %
    in_block = (i-1)*size_ventana*overlap + 1;
    
    % 7. Definimos final de cada bloque %
    out_block = (in_block + size_ventana)-1;
    
    % 8. Se extrae del vector ¨y¨ la porcion de cada bloque en cuestion %
    block = y(1, in_block:out_block);
    
    % 9. Elegimos la ventana a utilizar %
   switch windows
   case 1
       % Blackman
      bloque_enventanado = block.*blackman(size_ventana)';
   case 2
       % Hanning
      bloque_enventanado = block.*hann(size_ventana)';
   case 3
       % Gausiana
      bloque_enventanado = block.*gausswin(size_ventana)';
   end
    
   % 10. Hallamos la media de cada bloque %
    mean_block = mean (bloque_enventanado);
    
   % 11. Guardamos el progreso en un vector % 
    progress_DC (i) = mean_block*size_ventana/2;
    
end 

% 12. Representamos el vector de progreso (evolucion) de DC
segundos = length(y)/FS;
eje = linspace(0, segundos, length(progress_DC));
figure
stairs(eje, progress_DC)
axis([0 segundos -250 250])
xlabel('Tiempo(s)');
ylabel('Niveles Q');
title('Análisis de la componente de continua (DC)');
grid on
end
