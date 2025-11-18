run("modelagem_linear.m");

% Especificações por alocação (zeta, wn = 1/lambda para casar Ts ~ 4*lambda)
zeta = 1.0;
lambda1 = 22;   wn1 = 1/lambda1;
lambda2 = 22;  wn2 = 1/lambda2;

% Parâmetros das plantas
K1  = 0.0537; tau1 = 18.07;
K2  = 0.1877; tau2 = 68.4;

% Fórmulas de alocação: Kp=(2*zeta*wn*tau - 1)/K ; Ki=(tau*wn^2)/K
Kp1 = (2*zeta*wn1*tau1 - 1)/K1;     % ≈ 93.544
Ki1 = (tau1*wn1^2)/K1;              % ≈ 9.3472

Kp2 = (2*zeta*wn2*tau2 - 1)/K2;     % ≈ 27.8006
Ki2 = (tau2*wn2^2)/K2;              % ≈ 0.7529

% ---------------- Controladores em forma de tf ----------------
% C(s) = (Kp*s + Ki) / s
C1 = tf([Kp1 Ki1], [1 0]);          % C1(s) = (93.544 s + 9.3472)/s
C2 = tf([Kp2 Ki2], [1 0]);          % C2(s) = (27.8006 s + 0.7529)/s

% ---------------- Filtros de referência (ganho unitário) ----------------
% Para amenizar o zero dominante do PI: FR(s) = Ki / (Kp*s + Ki)
FR1 = tf(Ki1, [Kp1 Ki1]);           % = 9.3472 / (93.544 s + 9.3472)
FR2 = tf(Ki2, [Kp2 Ki2]);           % = 0.7529 / (27.8006 s + 0.7529)

% ---------------- Conversão para forma K(1 + 1/(Ti s)) ----------------
% C(s) = Kp + Ki/s = K * (1 + 1/(Ti s))
% => K = Kp ;  Ti = Kp/Ki

Kc1 = Kp1;
Ti1 = Kp1 / Ki1;

Kc2 = Kp2;
Ti2 = Kp2 / Ki2;

% Ti_atual = alpha_ti*Ti_antigo;
alpha_ti = 1;
alpha_p = 5;

% Dessintonizar o valor de Kc de acordo aos parametros de acoplamento

lambda = 1.4;

Kc1 = Kc1*(lambda - sqrt(lambda^2 - lambda));
Kc2 = Kc2*(lambda - sqrt(lambda^2 - lambda));

% Conversão de (K, Ti) -> (Kp, Ki)
Kp1 = Kc1;
Ki1 = Kc1 / Ti1;

Kp2 = Kc2;
Ki2 = Kc2 / Ti2;

s = tf('s');

% Controladores no formato (Kp*s + Ki)/s
C1 = (Kp1*s + Ki1)/s;   % malha 1
C2 = (Kp2*s + Ki2)/s;   % malha 2

% Mostrando os pares (K, Ti) e (Kp, Ki)
fprintf('Malha 1: K = %.4f, Ti = %.4f s  ->  Kp = %.4f, Ki = %.4f\n', ...
        Kc1, Ti1, Kp1, Ki1);
fprintf('Malha 2: K = %.4f, Ti = %.4f s  ->  Kp = %.4f, Ki = %.4f\n', ...
        Kc2, Ti2, Kp2, Ki2);
