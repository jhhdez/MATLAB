function ENF (Sx_in,FS_resample)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%1. Extraemos las muestras y la frecuencia de muestreo de la señal de audio
[y,FS] = audioread (Sx_in);

%2. Asegurarse de que sea un vector fila
y = y(:)';

%3. Calculamos la cantidad de segundos totales que dura la grabacion
cant_seg = length(y)/FS;

%4. Realizamos un diezmado a la frecuencia de re-muestreo
y = resample (y,FS_resample,FS);

%5. Creamos un filtro pasabanda de butterworth
[b,a] = butter(4,[(49/(FS_resample/2)) (51/(FS_resample/2))]); %% 4*8 dB = 24 dB/octava

%6. Filtramos la señal 
y =  filter(b,a,y);

%7. Calcular la cantidad de bloques %
numero_bloques = length(y)/(FS_resample);

%8. Creamos una variable auxiliar, para recorrer el vector "aux" 
k=1;mean_frecuency = [1,zeros (ceil (numero_bloques))];

%%%%%%%%%%% ENF por el metodo de la - Interpolacion Lineal - %%%%%%%%%%%%%%
for e = 1: ceil (numero_bloques)
    
%9. Definimos inicio de cada bloque 
    inicio_bloque = (e-1)*FS_resample + 1;
    
%10. Definimos final de cada bloque 
    fin_bloque = (inicio_bloque + FS_resample)-1;
    
%11. Para el caso del ultimo bloque, tomar hasta donde lleguen las muestras
    if e > numero_bloques 
        fin_bloque = length (y); % Definimos el final de este bloque
    end
    
%12. Se extrae del vector ¨y¨ la porcion de cada bloque en cuestion 
    bloque = y(1, inicio_bloque:fin_bloque);
    
%13. Recorremos el bloque buscando los cruces por cero
    for i = 1:length(bloque)-1
       if (bloque(i)*bloque(i+1) < 0)
           
        % Formula de la interpolacion lineal
        aux(k) = (((-bloque(i))*(i+1 - i)) / (bloque(i+1) - bloque(i))) + i;
        % Avanzamos k
        k = k + 1;
       end
    end

%14. Hallamos la distancia entre los ceros    
    for i = 2:length(aux)
        muestras_entre_ceros(i-1) = aux(i) - aux(i-1);
    end
    
%15. Convertimos del intervalo de muestras a intervalo de segundos
    t = muestras_entre_ceros./ FS_resample;
    
%16. Calculamos la frecuencia media del bloque
    mean_frecuency(e) = 1 / mean(t.*2);
    
    % Volvemos al valor inicial de k
    k = 1;
end

%17. Representamos ENF segun los cruces por cero
eje = linspace(0, cant_seg, length(mean_frecuency));
figure
plot(eje, mean_frecuency)
axis([0 cant_seg 48 52])
xlabel('Tiempo (s)');
ylabel('Frecuencia (Hz)');
title('Cruces por cero');
grid

%18. Representamos ENF con el espectrograma
figure
spectrogram(y, 512, 512/4, 2*512, FS_resample,'yaxis');

end