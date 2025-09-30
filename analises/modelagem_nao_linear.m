%% ===================== Quadruple-Tank: State-Space w/ Configurable Outputs =====================
clear; clc;

run('parametros.m');

%% ===================== Simulação: Modelo NÃO LINEAR (4 tanques) =====================

% --- Perfil de entrada (tensão das bombas) ---
% Edite estes degraus como quiser (0 a P.vb Volts)
v1_fun = @(t) (t < 800).*1.5 + (t >= 800).*3.0;   % V
v2_fun = @(t) (t < 800).*1.5 + (t >= 800).*3.0;   % V

% --- Condições iniciais (m) ---
x0 = [0.00; 0.00; 0.00; 0.00];   % [h1; h2; h3; h4] (começando vazios)
tspan = [0 1600];                 % janela de simulação (s)

% --- Resolver EDO não linear ---
ode = @(t,x) four_tank_nl(t, x, P, v1_fun, v2_fun);
opts = odeset('RelTol',1e-6,'AbsTol',1e-8);
[t, x] = ode45(ode, tspan, x0, opts);

% --- Conversão opcional para Volts (sensores) ---
if use_sensor_volts
    y = (x / S.h_span_m) * S.v_span;           % 0–h_span_m m -> 0–v_span V
    y = max(0, min(S.v_span, y));               % saturação 0–v_span
    y_label = 'Tensão no sensor (V)';
else
    y = x;
    y_label = 'Altura (m)';
end

% --- Seleção de saídas para exibir ---
idx = 1:4;
if ischar(which_outputs)
    switch lower(which_outputs)
        case 'upper', idx = [3 4];
        case 'lower', idx = [1 2];
        case 'all',   idx = [1 2 3 4];
        otherwise,    idx = 1:4;
    end
elseif isnumeric(which_outputs)
    idx = which_outputs(:).';
end

% --- Plot das respostas ---
figure; hold on; grid on;
leg = {};
if any(idx==1), plot(t, y(:,1), 'b-', 'LineWidth',1.6); leg{end+1}='Tanque 1'; end
if any(idx==2), plot(t, y(:,2), 'r-', 'LineWidth',1.6); leg{end+1}='Tanque 2'; end
if any(idx==3), plot(t, y(:,3), 'y-', 'LineWidth',1.6); leg{end+1}='Tanque 3'; end
if any(idx==4), plot(t, y(:,4), 'm-', 'LineWidth',1.6); leg{end+1}='Tanque 4'; end
yline(0.5, 'r:', '0.5 m', 'LabelHorizontalAlignment','left', 'LineWidth',1);
xlabel('Tempo (s)'); ylabel(y_label);
title('Quadruple-Tank – Modelo não linear');
legend(leg, 'Location','best'); box on;

% --- (Opcional) Plots das entradas v1, v2 ---
%v1 = arrayfun(v1_fun, t);
%figure; hold on; grid on;
%plot(t, v1, 'LineWidth',1.6);  
%ylim([0 P.vb]); xlabel('Tempo (s)'); ylabel('Tensão das bombas (V)');
%title('Entradas v_1 e v_2'); legend('v_1 e v_2','Location','best');
    