run("modelagem_linear.m");

%% Calculo da matriz de transferência discretizada

(pole(G11)*-1).^-1;
(pole(G12)*-1).^-1;
(pole(G21)*-1).^-1;
(pole(G22)*-1).^-1;

G = [G11, G12; G21, G22];
Ts = 0.1;
Gz = c2d(G, Ts, 'zoh')

%% Criação do controlador MPC
P = 20;         % Horizonte de predição
M = 6;          % Horizonte de controle

mpcobj = mpc(Gz, Ts, P, M);

mpcobj.Weights.OV      = [1 1];
mpcobj.Weights.MVRate  = [0.1 0.1];
mpcobj.Weights.MV      = [0 0];

% Limites das entradas (manipulated variables)
mpcobj.MV(1).Min = 0;    mpcobj.MV(1).Max = 10;
mpcobj.MV(2).Min = 0;    mpcobj.MV(2).Max = 10;

