function [sys_lin, yop, eigA] = linearizar(xop, uop, P, which_outputs)
%LINEARIZE_FOUR_TANKS Lineariza o sistema dos quatro tanques no ponto de operação
%
% Entradas:
%   xop           - Vetor de estados de operação [h1; h2; h3; h4]
%   uop           - Vetor de entradas de operação [v1; v2]
%   P             - Estrutura de parâmetros do sistema (a1-a4, A1-A4, gamma1-gamma4, k1, k2, g)
%   which_outputs - 'lower', 'upper' ou 'all' (define C)
%
% Saídas:
%   sys_lin - Sistema linearizado (objeto state-space)
%   yop     - Saída no ponto de operação (y = Cx + Du)
%   eigA    - Autovalores da matriz A (polos do sistema)

    % Extrai estados de operação
    h1_op = xop(1);
    h2_op = xop(2);
    h3_op = xop(3);
    h4_op = xop(4);

    % Derivadas parciais da dinâmica (df/dx)
    c11 = -(P.a1 / (2 * P.A1)) * sqrt(2 * P.g / max(h1_op, eps));
    c13 =  (P.a3 / (2 * P.A1)) * sqrt(2 * P.g / max(h3_op, eps));

    c22 = -(P.a2 / (2 * P.A2)) * sqrt(2 * P.g / max(h2_op, eps));
    c24 =  (P.a4 / (2 * P.A2)) * sqrt(2 * P.g / max(h4_op, eps));

    c33 = -(P.a3 / (2 * P.A3)) * sqrt(2 * P.g / max(h3_op, eps));
    c44 = -(P.a4 / (2 * P.A4)) * sqrt(2 * P.g / max(h4_op, eps));

    % Matriz A
    A = [ c11,   0,   c13,   0;
           0 ,  c22,   0 ,  c24;
           0 ,   0,   c33,   0;
           0 ,   0,    0,   c44 ];

    % Matriz B
    B = [ (P.gamma1 * P.k1) / P.A1,          0;
                      0,           (P.gamma2 * P.k2) / P.A2;
                      0,           (P.gamma3 * P.k2) / P.A3;
          (P.gamma4 * P.k1) / P.A4,          0 ];

    % Matriz C com base na saída desejada
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

    % Matriz D (zero)
    D = zeros(size(C, 1), 2);

    % Sistema linearizado
    sys_lin = ss(A, B, C, D);

    % Saída no ponto de operação
    yop = C * xop + D * uop;

    % Polos do sistema
    eigA = eig(A);
end
