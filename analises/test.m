%% Características de modelagem
% Altura de linearização (m)
h_pop = 0.2;

% Altura (m)
htn = 0.3;

% Gravidade (m/s^2)
G = 9.81; 

% Raio do orifício de vazão (m)
Rvtn = 3e-3;

% Raio de cada tanque
Rt1 = 3e-2;
Rt2 = 4e-2;
Rt3 = 2e-2;
Rt4 = 3e-2;


%% Calculo das constantes do modelo

% Área transversal de cada tanque (m^2)
At1 = pi*Rt1^2;
At2 = pi*Rt2^2;
At3 = pi*Rt3^2;
At4 = pi*Rt4^2;

% Vazão das bombas m^3/V

Kb1 = 2.5e-5;

% Pontos de operação 