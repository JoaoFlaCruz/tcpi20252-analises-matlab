% Plantas
G11 = tf(0.0537, [18.07 1]);
G22 = tf(0.1877, [68.4  1]);

% Especificações por alocação (zeta, wn = 1/lambda para casar Ts ~ 4*lambda)
zeta = 1.0;
lambda1 = 6;   wn1 = 1/lambda1;
lambda2 = 22;  wn2 = 1/lambda2;

% Parâmetros das plantas
K1 = 0.0537; tau1 = 18.07;
K2 = 0.1877; tau2 = 68.4;

% Fórmulas de alocação: Kp=(2*zeta*wn*tau - 1)/K ; Ki=(tau*wn^2)/K
Kp1 = (2*zeta*wn1*tau1 - 1)/K1;     % ≈ 93.544
Ki1 = (tau1*wn1^2)/K1;               % ≈ 9.3472

Kp2 = (2*zeta*wn2*tau2 - 1)/K2;     % ≈ 27.8006
Ki2 = (tau2*wn2^2)/K2;               % ≈ 0.7529

% ---------------- Controladores em forma de tf ----------------
% C(s) = (Kp*s + Ki) / s
C1 = tf([Kp1 Ki1], [1 0]);           % C1(s) = (93.544 s + 9.3472)/s
C2 = tf([Kp2 Ki2], [1 0]);           % C2(s) = (27.8006 s + 0.7529)/s

% ---------------- Filtros de referência (ganho unitário) ----------------
% Para amenizar o zero dominante do PI: FR(s) = Ki / (Kp*s + Ki)
FR1 = tf(Ki1, [Kp1 Ki1]);            % = 9.3472 / (93.544 s + 9.3472)
FR2 = tf(Ki2, [Kp2 Ki2]);            % = 0.7529 / (27.8006 s + 0.7529)
