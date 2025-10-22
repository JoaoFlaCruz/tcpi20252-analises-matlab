%% Cálculo do Índice de Niederlinskii (N) para um Sistema 2x2

% --- Parte 1: Cálculo Simbólico ---

% Limpa a área de trabalho e a janela de comandos
clear; clc;

% Define as variáveis simbólicas para a matriz de ganho estático K
syms k11 k12 k21 k22

% Define a matriz de ganho estático K
K_sym = [k11, k12;
         k21, k22];

% Calcula o determinante da matriz K
det_K_sym = det(K_sym);

% Calcula o produto dos elementos da diagonal principal
prod_diag_K_sym = k11 * k22;

% Calcula o Índice de Niederlinskii (N)
N_sym = det_K_sym / prod_diag_K_sym;

% Mostra a fórmula simbólica de forma legível
fprintf('A fórmula simbólica para o Índice de Niederlinskii (N) é:\n');
pretty(N_sym);


% --- Parte 2: Cálculo Numérico com os Dados do Relatório ---

% Valores numéricos da matriz de ganho estático K, calculados anteriormente
K_num = [0.0537, 0.0261;
         0.1102, 0.1878];

% Substitui os valores numéricos na fórmula simbólica
% A função subs(expressão, [variáveis], [valores]) substitui os valores
% nas variáveis da expressão.
N_num = subs(N_sym, [k11, k12, k21, k22], [K_num(1,1), K_num(1,2), K_num(2,1), K_num(2,2)]);

% Exibe o resultado numérico final
fprintf('\n--------------------------------------------------\n');
fprintf('Para a matriz de ganho estático do processo:\n');
disp(K_num);
fprintf('O valor do Índice de Niederlinskii é:\n');
fprintf('N = %.4f\n', N_num);

% --- Interpretação do Resultado ---
if N_num > 0
    fprintf('\nInterpretação: Como N > 0, o emparelhamento direto (v1->h1, v2->h2) é aceitável e não deve levar à instabilidade com controladores PI/PID.\n');
else
    fprintf('\nInterpretação: Como N <= 0, o emparelhamento direto (v1->h1, v2->h2) é inaceitável e levará a um sistema instável em malha fechada.\n');
end