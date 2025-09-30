%% ===================== Função de dinâmica não linear =====================
function dx = four_tank_nl(t, x, P, v1_fun, v2_fun)
    % Estados
    h1 = max(x(1), 0);  % m
    h2 = max(x(2), 0);
    h3 = max(x(3), 0);
    h4 = max(x(4), 0);

    % Entradas (Volts) e saturação física 0–vb
    v1 = min(max(v1_fun(t), 0), P.vb);
    v2 = min(max(v2_fun(t), 0), P.vb);

    % Vazões das bombas (m^3/s)
    q1 = P.k1 * v1;
    q2 = P.k2 * v2;

    % Torricelli (m^3/s) – saídas pelos orifícios superiores/ inferiores
    qout1 = P.a1 * sqrt(2*P.g*h1);
    qout2 = P.a2 * sqrt(2*P.g*h2);
    qout3 = P.a3 * sqrt(2*P.g*h3);
    qout4 = P.a4 * sqrt(2*P.g*h4);

    % Dinâmica (dh/dt), convertendo dV/dt por A_i
    % Tanques inferiores (1 e 2) recebem dos superiores (3->1, 4->2)
    dh1 = (- qout1)/P.A1 + (qout3)/P.A1 + (P.gamma1*q1)/P.A1;
    dh2 = (- qout2)/P.A2 + (qout4)/P.A2 + (P.gamma2*q2)/P.A2;

    % Tanques superiores (3 e 4) recebem a parcela "superior" das bombas
    dh3 = (- qout3)/P.A3 + (P.gamma3*q2)/P.A3;
    dh4 = (- qout4)/P.A4 + (P.gamma4*q1)/P.A4;

    dx = [dh1; dh2; dh3; dh4];
end

