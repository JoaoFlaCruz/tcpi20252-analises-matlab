%% ===================== Quadruple-Tank: State-Space w/ Configurable Outputs =====================
clear; clc;

run("parametros.m");

% Pontos de operação
h1_op = 0.25;
h2_op = 0.15;

% Tipo de plot desejado
which_outputs = 'all';

%% Linearização
% Lineariza o modelo não linear dos 4 tanques em torno de (h1*, h2*).
% Resolve h3*, h4* e v1*, v2* de equilíbrio e retorna o SS (A,B,C,D).
%
% Entradas:
%   P: struct com campos A1..A4, a1..a4, g, k1, k2, gamma1..gamma4
%   h1_op, h2_op: níveis (m) desejados para os tanques inferiores
%   which_outputs (opcional): 'lower' (default) -> y = [h1;h2]
%                             'upper'          -> y = [h3;h4]
%                             'all'            -> y = [h1;h2;h3;h4]
%
% Saídas:
%   A,B,C,D: matrizes linearizadas
%   xop = [h1*; h2*; h3*; h4*], uop = [v1*; v2*]

% -------- 1) Resolver h3*, h4* a partir de h1*, h2* (equilíbrio) ----------
% Equações de equilíbrio (dh/dt=0) levando às relações lineares em s = sqrt(h):
% a3*s3 + (gamma1/gamma4)*a4*s4 = a1*s1
% (gamma2/gamma3)*a3*s3 + a4*s4 = a2*s2
s1 = sqrt(max(h1_op,0));
s2 = sqrt(max(h2_op,0));

Aeq = [ P.a3,                   (P.gamma1/P.gamma4)*P.a4;
        (P.gamma2/P.gamma3)*P.a3,            P.a4              ];
beq = [ P.a1*s1; P.a2*s2 ];

s34 = Aeq \ beq;
s3 = s34(1);  s4 = s34(2);

h3_op = s3^2;
h4_op = s4^2;

% -------- 2) Entradas de equilíbrio v1*, v2* (pelos tanques superiores) ----
% 0 = -a3*sqrt(2gh3)/A3 + gamma3*k2*v2/A3  => v2* = a3*sqrt(2g)*s3/(gamma3*k2)
% 0 = -a4*sqrt(2gh4)/A4 + gamma4*k1*v1/A4  => v1* = a4*sqrt(2g)*s4/(gamma4*k1)
v2_op = (P.a3*sqrt(2*P.g)*s3) / (P.gamma3*P.k2);
v1_op = (P.a4*sqrt(2*P.g)*s4) / (P.gamma4*P.k1);

xop = [h1_op; h2_op; h3_op; h4_op];
uop = [v1_op; v2_op];

% -------- 3) Matrizes A = df/dx |op e B = df/du |op -----------------------
% Dinâmica:
% dh1 = (-a1*sqrt(2gh1) + a3*sqrt(2gh3) + gamma1*k1*v1)/A1
% dh2 = (-a2*sqrt(2gh2) + a4*sqrt(2gh4) + gamma2*k2*v2)/A2
% dh3 = (-a3*sqrt(2gh3) + gamma3*k2*v2)/A3
% dh4 = (-a4*sqrt(2gh4) + gamma4*k1*v1)/A4
%
% d/dh sqrt(h) = 1/(2*sqrt(h))

c11 = -(P.a1/(2*P.A1)) * sqrt(2*P.g / max(h1_op,eps));
c13 = +(P.a3/(2*P.A1)) * sqrt(2*P.g / max(h3_op,eps));

c22 = -(P.a2/(2*P.A2)) * sqrt(2*P.g / max(h2_op,eps));
c24 = +(P.a4/(2*P.A2)) * sqrt(2*P.g / max(h4_op,eps));

c33 = -(P.a3/(2*P.A3)) * sqrt(2*P.g / max(h3_op,eps));
c44 = -(P.a4/(2*P.A4)) * sqrt(2*P.g / max(h4_op,eps));

A = [ c11,   0,   c13,   0;
       0 ,  c22,   0 ,  c24;
       0 ,   0,   c33,   0;
       0 ,   0,    0,   c44 ]

B = [ (P.gamma1*P.k1)/P.A1,          0;
               0,           (P.gamma2*P.k2)/P.A2;
               0,           (P.gamma3*P.k2)/P.A3;
      (P.gamma4*P.k1)/P.A4,          0 ];

switch lower(which_outputs)
    case 'lower'
        C = [1 0 0 0;
             0 1 0 0];
    case 'upper'
        C = [0 0 1 0;
             0 0 0 1];
    case 'all'
        C = eye(4);
    otherwise
        error('which_outputs deve ser ''lower'', ''upper'' ou ''all''.');
end

D = zeros(size(C,1), 2);

% Verifique o ponto de operação e matrizes
disp(xop);    % [h1* h2* h3* h4*]^T
disp(uop);    % [v1* v2*]^T
eigA = eig(A) % polos do linearizado

sys_lin = ss(A, B, C, D)

% Saída de operação (para 'lower', y_op = [h1*; h2*])
yop = C*xop + D*uop;

%% ====== Perfil de degraus em variáveis de desvio (Δu) ======
Tf = 600;              % horizonte (s) – ajuste como preferir
dt = 0.1;
t  = (0:dt:Tf)';

% Degrau +0.3 V em v1 (mantendo v2 no v2_op)
du_v1 = [0.3*(t>=0), zeros(size(t))];

% Degrau +0.3 V em v2 (mantendo v1 no v1_op)
du_v2 = [zeros(size(t)), 0.3*(t>=0)];

% Degrau simultâneo +0.3 V em v1 e v2 (opcional)
du_both = 0.3*(t>=0)*[1 1];

%% ====== Simulações (em Δ-variáveis) e reconversão para variáveis absolutas ======
% Começando exatamente no ponto de operação: Δx(0)=0
dx0 = zeros(size(A,1),1);

[dy_v1,~,dx_v1]   = lsim(sys_lin, du_v1,   t, dx0);
[dy_v2,~,dx_v2]   = lsim(sys_lin, du_v2,   t, dx0);
[dy_both,~,dx_bo] = lsim(sys_lin, du_both, t, dx0);   % opcional

% Converter para valores absolutos (somar o ponto de operação)
y_v1   = dy_v1   + yop.';     % cada linha: y(t)
y_v2   = dy_v2   + yop.';
y_both = dy_both + yop.';

%% ====== Plots: resposta absoluta (níveis em m) ======
figure; tiledlayout(2,1); 
nexttile; plot(t, y_v1(:,1), 'LineWidth',1.6); grid on; ylabel('h_1 (m)');
title('Degrau +0.3 V em v_1 (v_2 = v_{2,op})');
nexttile; plot(t, y_v1(:,2), 'LineWidth',1.6); grid on; ylabel('h_2 (m)'); xlabel('Tempo (s)');

figure; tiledlayout(2,1);
nexttile; plot(t, y_v2(:,1), 'LineWidth',1.6); grid on; ylabel('h_1 (m)');
title('Degrau +0.3 V em v_2 (v_1 = v_{1,op})');
nexttile; plot(t, y_v2(:,2), 'LineWidth',1.6); grid on; ylabel('h_2 (m)'); xlabel('Tempo (s)');

% (Opcional) degrau simultâneo
figure; plot(t, y_both, 'LineWidth',1.6); grid on;
legend('h_1','h_2','Location','best'); xlabel('Tempo (s)'); ylabel('h (m)');
title('Degraus simultâneos: +0.3 V em v_1 e v_2');

%% ====== Checagem de saturação física (opcional, mas recomendada) ======
% Garanta que v_op ± 0.3 V permanecem dentro de [0, P.vb]
v1_ok = (uop(1)+0.3 >= 0) && (uop(1)+0.3 <= P.vb);
v2_ok = (uop(2)+0.3 >= 0) && (uop(2)+0.3 <= P.vb);
if ~(v1_ok && v2_ok)
    warning('O degrau de +0.3 V extrapola a faixa física de alguma bomba (0..vb).');
end