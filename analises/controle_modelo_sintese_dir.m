run("modelagem_linear.m");

%% Calculo dos controladores PI por sintese direta

(pole(G_11)*-1).^-1;
(pole(G_12)*-1).^-1;
(pole(G_21)*-1).^-1;
(pole(G_22)*-1).^-1;

% Alvos
T1 = tf(1,[6 1]);
T2 = tf(1,[22 1]);

% Controladores por síntese direta (corretos)
C1 = tf([56.083, 3.1037],[1,0]);      % = 56.083 + 3.1037/s
C2 = tf([16.564, 0.24217],[1,0]);     % = 16.564 + 0.24217/s

% Filtros de referência que cancelam o zero do PI
FR1 = tf(3.1037,[56.083 3.1037]);     % = 1/(18.07 s + 1)
FR2 = tf(0.24217,[16.564 0.24217]);   % = 1/(68.4  s + 1)