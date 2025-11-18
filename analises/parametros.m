%% Parâmetros da planta
P = struct();

% Gravidade (m/s^2)
P.g = 9.81;

% Área da seção de cada tanque (m^2)
P.A1 = pi*(5e-2)^2;
P.A2 = pi*(5e-2)^2;
P.A3 = pi*(3e-2)^2;
P.A4 = pi*(3e-2)^2;

% Área do orifício de cada tanque (m^2)
P.a1 = pi*(2.82e-3)^2; 
P.a2 = pi*(3e-3)^2;
P.a3 = pi*(2.26e-3)^2;
P.a4 = pi*(2.1e-3)^2;

% Ganho de cada bomba (m^3/(s*V))
P.k1 = 2.7e-5;
P.k2 = 2.3e-5;

% Tensão máxima da bomba
P.vb = 10;

% Razao de distribuicao das válvulas
P.gamma1 = 0.65;    % Tanque 1
P.gamma2 = 0.60;    % Tanque 2
P.gamma3 = 0.40;    % Tanque 3
P.gamma4 = 0.35;    % Tanque 4

% Configuração de visualização dos dados
S = struct();
use_sensor_volts = false;        % true -> outputs em Volts; false -> em metros
S.h_span_m = 0.40;               % faixa do sensor (0–h_span_m m -> 0–v_span V)
S.v_span  = 10.0;                % Volts (span)
which_outputs = 'all';           % 'upper' (3,4) | 'lower' (1,2) | 'all' | [índices]

% Limite físico de altura (apenas para checagem)
tank_height_m = 0.50;