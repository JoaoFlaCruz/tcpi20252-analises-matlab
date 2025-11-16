%% ===================== Quadruple-Tank: State-Space w/ Configurable Outputs =====================
clear; clc;

run("parametros.m");

% Pontos de operação
h1_op = 0.10;
h2_op = 0.35;

% Tipo de plot desejado
% which_outputs - 'lower', 'upper' ou 'all' (define C)
which_outputs = 'all';

% -------- 2) Calculo dos pontos de operaçao -----------------------

[xop, uop] = calc_ponto_op(h1_op, h2_op, P);

% -------- 3) Linearizar o modelo -------------------

[sys_lin, yop, eigA] = linearizar(xop, uop, P, which_outputs)

A = sys_lin.A;
B = sys_lin.B;
C = sys_lin.C;

%% ====== Perfil de degraus em variáveis de desvio (Δu) ======
Tf = 1800;              % horizonte (s) – ajuste como preferir
dt = 0.1;
t  = (0:dt:Tf)';
    
% Degrau (uop → uop+0.2 entre 600–1200 s → uop)
du_v1 = [ uop(1) + 0.2*((t>=600)&(t<1200)),  uop(2)*ones(size(t)) ];
du_v2 = [ uop(1)*ones(size(t)),              uop(2) + 0.2*((t>=600)&(t<1200)) ];

%% ====== Simulações (em Δ-variáveis) e reconversão para variáveis absolutas ======
Tf = 1800; dt = 0.1;
t  = (0:dt:Tf)';                      % vetor coluna de tempo

AMP   = 0.2;                           % amplitude do patamar (V)
t_on  = 600;                           % início (s)
t_off = 1200;                          % fim (s)
mask  = (t >= t_on) & (t < t_off);     % 0 até 600, 1 de 600–1200, 0 depois

% Δu(t): +0.2 V no intervalo [600,1200), 0 fora
du_v1 = [ AMP*mask, zeros(size(t)) ];  % excita v1, mantém v2 sem variação
du_v2 = [ zeros(size(t)), AMP*mask ];  % excita v2, mantém v1 sem variação

% Estado inicial Δx(0)=0 com dimensão correta (número de estados do sys_lin)
n   = size(sys_lin.A, 1);
dx0 = zeros(n,1);

% Simulações em Δ-variáveis
[dy_v1,~,dx_v1] = lsim(sys_lin, du_v1, t, dx0);
[dy_v2,~,dx_v2] = lsim(sys_lin, du_v2, t, dx0);

% Converter para valores absolutos (somar o ponto de operação)
y_v1 = dy_v1 + yop.';                  % cada linha: y(t)
y_v2 = dy_v2 + yop.';

%% ====== Plots: resposta absoluta (níveis em m) ======
figure; tiledlayout(2,1);
nexttile; plot(t, y_v1(:,1), 'LineWidth',1.6); grid on; ylabel('h_1 (m)');
title('Patamar +0,2 V em v_1 (v_2 = v_{2,op})');
nexttile; plot(t, y_v1(:,2), 'LineWidth',1.6); grid on; ylabel('h_2 (m)'); xlabel('Tempo (s)');

figure; tiledlayout(2,1);
nexttile; plot(t, y_v2(:,1), 'LineWidth',1.6); grid on; ylabel('h_1 (m)');
title('Patamar +0,2 V em v_2 (v_1 = v_{1,op})');
nexttile; plot(t, y_v2(:,2), 'LineWidth',1.6); grid on; ylabel('h_2 (m)'); xlabel('Tempo (s)');

%% Modelo não-linear sobre os pontos de operação

% --- Perfil de entrada (tensão das bombas) ---
% Edite estes degraus como quiser (0 a P.vb Volts)
v1_fun = @(t) (t < 600 || t>=1200).*uop(1) + (t >= 600 && t < 1200).*(uop(1) + 0.2);   % V
v2_fun = @(t) (t < 600 || t>=1200).*uop(2) + (t >= 600 && t<1200).*(uop(1) + 0.2);   % V

% --- Condições iniciais (m) ---
x0 = [0.1000; 0.3500; 0.0152; 0.0620];   % [h1; h2; h3; h4] (começando vazios)
tspan = [0 1800];                 % janela de simulação (s)

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

%% Comparacao entre modelo não-linear e modelo linearizado
Tf   = 1800; 
dt   = 0.1;
tgrid = (0:dt:Tf)';     % <-- use este SEMPRE no lsim e na geração de entradas

% Perfil absoluto u(t): uop -> uop+0.2 entre 600–1200 -> uop
AMP  = 0.2;
mask = (tgrid >= 600) & (tgrid < 1200);
u1_abs = uop(1) + AMP*mask;
u2_abs = uop(2) + AMP*mask;

% NÃO linear: force saída no mesmo tgrid (evita desuniformidade)
x0 = xop;
ode = @(tt,xx) four_tank_nl(tt, xx, P, ...
    @(tau) interp1(tgrid, u1_abs, tau, 'previous','extrap'), ...
    @(tau) interp1(tgrid, u2_abs, tau, 'previous','extrap'));

opts = odeset('RelTol',1e-6,'AbsTol',1e-8);
[tnl, xnl] = ode45(ode, tgrid, x0, opts);   % <-- nota: usa tgrid como malha

% Saídas não lineares
y_nl = xnl;

% Linearizado com as MESMAS entradas (em Δu)
du = [u1_abs - uop(1), u2_abs - uop(2)];    % N x 2
n  = size(sys_lin.A,1);
dx0 = zeros(n,1);

% Sanidade (evita o erro do lsim)
assert(isvector(tgrid) && all(isfinite(tgrid)) && issorted(tgrid));
d = diff(tgrid); 
assert(max(d)-min(d) < 1e-12, 'tgrid não é uniformemente espaçado.');

[dy_lin,~,~] = lsim(sys_lin, du, tgrid, dx0);
y_lin = dy_lin + yop.';                      % absolutos

% ---- Plot conjunto (cores por tanque; NL sólido, LIN tracejado) ----
figure; hold on; grid on; box on;
C1 = 'b'; C2 = 'r'; C3 = [0.929 0.694 0.125]; C4 = 'm';

plot(tnl, y_nl(:,1), '-',  'Color',C1, 'LineWidth',1.6);
plot(tgrid, y_lin(:,1), ':','Color',C1, 'LineWidth',1.6);

plot(tnl, y_nl(:,2), '-',  'Color',C2, 'LineWidth',1.6);
plot(tgrid, y_lin(:,2), ':','Color',C2, 'LineWidth',1.6);

plot(tnl, y_nl(:,3), '-',  'Color',C3, 'LineWidth',1.6);
plot(tgrid, y_lin(:,3), ':','Color',C3, 'LineWidth',1.6);

plot(tnl, y_nl(:,4), '-',  'Color',C4, 'LineWidth',1.6);
plot(tgrid, y_lin(:,4), ':','Color',C4, 'LineWidth',1.6);

yline(0.5, 'r:', '0.5 m', 'LabelHorizontalAlignment','left', 'LineWidth',1);
xlabel('Tempo (s)'); ylabel('Altura (m)');
title('Quadruple-Tank — Não linear (sólido) vs Linearizado (tracejado)');
legend({'Tanque 1 (NL)','Tanque 1 (LIN)', ...
        'Tanque 2 (NL)','Tanque 2 (LIN)', ...
        'Tanque 3 (NL)','Tanque 3 (LIN)', ...
        'Tanque 4 (NL)','Tanque 4 (LIN)'}, 'Location','best');

%% Matriz de transferência
G = tf(sys_lin)

G_11 = tf([0.0537], [18.07, 1]);
G_12 = tf([0.1102], [1107.54, 84.583, 1]);
G_21 = tf([0.0261], [78.4314, 22.4157, 1]);
G_22 = tf([0.1877], [68.3994, 1]);

((pole(G_11).^-1).*-1)
((pole(G_12).^-1).*-1)
((pole(G_21).^-1).*-1)
((pole(G_22).^-1).*-1)

