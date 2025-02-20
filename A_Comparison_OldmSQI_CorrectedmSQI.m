
% Esta función compara los valores de mSQI originales con los valores
% corregidos obtenidos de dos ubicaciones distintas (brazo y esternón).
% Se calculan las medias de cada conjunto de archivos, eliminando ceros
% para evitar distorsiones en los cálculos. Posteriormente, se determinan
% los valores máximos y mínimos de cada conjunto y se calcula la diferencia
% relativa entre ellos. Finalmente, se genera una tabla con los resultados
% y se guarda en un archivo CSV.
%
% Parámetros de entrada:
%   - mSQI_files_top: Celda con los archivos de mSQI originales.
%   - corrected_files_esternon: Celda con los archivos de mSQI corregidos
%     correspondientes al esternón.
%   - corrected_files_brazo: Celda con los archivos de mSQI corregidos
%     correspondientes al brazo.
%
% Salida:
%   - Se genera un archivo 'Comparison_mSQI_mSQIcorrected.csv' con los
%     resultados de la comparación, incluyendo valores máximos, mínimos,
%     y diferencias relativas entre los datos originales y corregidos.

function A_Comparison_OldmSQI_CorrectedmSQI(mSQI_files_top, corrected_files_esternon, corrected_files_brazo)

% Inicializar matrices para almacenar datos
num_archivos = length(mSQI_files_top);
medias_msqi_original = zeros(1, num_archivos);
medias_msqi_corregido_arm = zeros(1, num_archivos);
medias_msqi_corregido_sternum = zeros(1, num_archivos);

for i = 1:num_archivos
    % Extraer datos originales
    datos_original = mSQI_files_top(i).geometricMean_vector;
    datos_original = datos_original(:); % Transponer

    % Leer datos de los archivos CSV
    datos_corregido_arm = table2array(readtable(corrected_files_brazo{i}));
    datos_corregido_sternum = table2array(readtable(corrected_files_esternon{i}));

    % Filtrar valores diferentes de cero y calcular la media
    medias_msqi_original(i) = mean(datos_original(datos_original ~= 0));
    medias_msqi_corregido_arm(i) = mean(datos_corregido_arm(datos_corregido_arm ~= 0));
    medias_msqi_corregido_sternum(i) = mean(datos_corregido_sternum(datos_corregido_sternum ~= 0));
end

% Cálculo de métricas adicionales
max_original = max(medias_msqi_original);
max_corregido_arm = max(medias_msqi_corregido_arm);
max_corregido_sternum = max(medias_msqi_corregido_sternum);

min_original = min(medias_msqi_original);
min_corregido_arm = min(medias_msqi_corregido_arm);
min_corregido_sternum = min(medias_msqi_corregido_sternum);


% Calcular diferencias relativas asegurando que no se divida por cero
resultado_original = (max_original - min_original) / max(min_original, eps);
resultado_corregido_arm = (max_corregido_arm - min_corregido_arm) / max(min_corregido_arm, eps);
resultado_corregido_sternum = (max_corregido_sternum - min_corregido_sternum) / max(min_corregido_sternum, eps);

diferencia_arm = resultado_original - resultado_corregido_arm;
diferencia_sternum = resultado_original - resultado_corregido_sternum;

% Crear la primera tabla con File1 y File2
resultados_comparison = {
    mSQI_files_top(1).file_name, mSQI_files_top(2).file_name, 'mSQI Original', max_original, min_original, resultado_original, diferencia_arm;
    mSQI_files_top(1).file_name, mSQI_files_top(2).file_name, 'mSQI Corregido (Arm)', max_corregido_arm, min_corregido_arm, resultado_corregido_arm, diferencia_arm;
    mSQI_files_top(1).file_name, mSQI_files_top(2).file_name, 'mSQI Corregido (Sternum)', max_corregido_sternum, min_corregido_sternum, resultado_corregido_sternum, diferencia_sternum;
    };

nombres_columnas_comparison = {'File1', 'File2', 'Type', 'Max', 'Min', 'Result', 'Differences'};
tabla_comparison = cell2table(resultados_comparison, 'VariableNames', nombres_columnas_comparison);

% Guardar la primera tabla en un archivo CSV
writetable(tabla_comparison, 'Comparison_mSQI_mSQIcorrected.csv', 'WriteMode', 'append');

% Inicializa la celda para almacenar los resultados de la segunda tabla
resultados_metrics = {};

% Recorrer todos los archivos de mSQI
for i = 1:length(mSQI_files_top)
    % Obtener los valores correspondientes para cada tipo (Original, Corregido (Brazo), Corregido (Esternón))
    datos_original = mSQI_files_top(i).geometricMean_vector;
    datos_original = datos_original(:); % Transponer

    datos_corregido_arm = table2array(readtable(corrected_files_brazo{i}));
    datos_corregido_sternum = table2array(readtable(corrected_files_esternon{i}));

    % Calcular las métricas individuales
    promedio_original = mean(datos_original(datos_original ~= 0));% por si
    desviacion_original = std(datos_original(datos_original ~= 0));
    p10_original = prctile(datos_original, 10);
    p90_original = prctile(datos_original, 90);
    metric1_original = (p90_original - p10_original) / p10_original;
    metric2_original = (p90_original - p10_original);


    promedio_corregido_arm = mean(datos_corregido_arm(datos_corregido_arm ~= 0));
    desviacion_corregido_arm = std(datos_corregido_arm(datos_corregido_arm ~= 0));
    p10_corregido_arm = prctile(datos_corregido_arm, 10);
    p90_corregido_arm = prctile(datos_corregido_arm, 90);
    metric1_corregido_arm = (p90_corregido_arm - p10_corregido_arm) / p10_corregido_arm;
    metric2_corregido_arm = (p90_corregido_arm - p10_corregido_arm);

    promedio_corregido_sternum = mean(datos_corregido_sternum(datos_corregido_sternum ~= 0));
    desviacion_corregido_sternum = std(datos_corregido_sternum(datos_corregido_sternum ~= 0));
    p10_corregido_sternum = prctile(datos_corregido_sternum, 10);
    p90_corregido_sternum = prctile(datos_corregido_sternum, 90);
    metric1_corregido_sternum = (p90_corregido_sternum - p10_corregido_sternum) / p10_corregido_sternum;
    metric2_corregido_sternum = (p90_corregido_sternum - p10_corregido_sternum);



    % Añadir los resultados a la celda para la tabla
    resultados_metrics = [resultados_metrics;
        {mSQI_files_top(i).file_name, 'mSQI Original', promedio_original, desviacion_original, p10_original,p90_original,metric1_original, metric2_original};
        {mSQI_files_top(i).file_name, 'mSQI Corregido (Arm)', promedio_corregido_arm, desviacion_corregido_arm, p10_corregido_arm,p90_corregido_arm,metric1_corregido_arm,metric2_corregido_arm};
        {mSQI_files_top(i).file_name, 'mSQI Corregido (Sternum)', promedio_corregido_sternum, desviacion_corregido_sternum, p10_corregido_sternum, p90_corregido_sternum,metric1_corregido_sternum, metric2_corregido_sternum}];
end

% Crear la segunda tabla con los resultados
nombres_columnas_metrics = {'Files', 'Type', 'Mean', 'StdDev', 'p10', 'p90', 'Metric (90%-10%)/10%', 'Metric (90%-10%)'};
tabla_metrics = cell2table(resultados_metrics, 'VariableNames', nombres_columnas_metrics);

% Guardar la segunda tabla en un archivo CSV
writetable(tabla_metrics, 'OtherMetrics_mSQI_mSQIcorrected.csv', 'WriteMode', 'append');

end



