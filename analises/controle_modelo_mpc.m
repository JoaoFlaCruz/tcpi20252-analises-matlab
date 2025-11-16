run("modelagem_linear.m");

%% Calculo da matriz de transferência discretizada

(pole(G_11)*-1).^-1;
(pole(G_12)*-1).^-1;
(pole(G_21)*-1).^-1;
(pole(G_22)*-1).^-1;

G = [G_11, G_12; G_21, G_22];
Ts = 0.1;
Gz = c2d(G, Ts, 'zoh')

%% Criação do controlador MPC
P = 10;         % Horizonte de predição
M = 3;          % Horizonte de controle

mpcobj = mpc(Gz, Ts, P, M);

mpcobj.Weights.OV      = [1 1];
mpcobj.Weights.MVRate  = [0.1 0.1];
mpcobj.Weights.MV      = [0 0];

% Limites das entradas (manipulated variables)
mpcobj.MV(1).Min = 0;    mpcobj.MV(1).Max = 10;
mpcobj.MV(2).Min = 0;    mpcobj.MV(2).Max = 10;

