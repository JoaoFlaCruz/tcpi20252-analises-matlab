function [xop,uop,ok,why] = calc_ponto_op(h1_op,h2_op,P)
% Pontos de operação no modo LOWER (h1,h2 dados nos tanques inferiores).
% P precisa ter: a1..a4, k1,k2, g, gamma1,gamma2 (0<gamma<1).

    why = "";
    ok = false;

    % --- checagens
    req = {'a1','a2','a3','a4','k1','k2','g','gamma1','gamma2'};
    for i = 1:numel(req)
        if ~isfield(P,req{i}), error("Parâmetro ausente: %s", req{i}); end
    end
    if ~(P.gamma1>0 && P.gamma1<1 && P.gamma2>0 && P.gamma2<1)
        error("gamma1,gamma2 devem estar em (0,1).");
    end
    if h1_op<0 || h2_op<0, error("Alturas devem ser >=0."); end

    % --- prepara termos
    s1 = sqrt(h1_op); s2 = sqrt(h2_op);
    Aeq = [ P.a3,                          (P.gamma1/(1-P.gamma1))*P.a4;
            (P.gamma2/(1-P.gamma2))*P.a3,  P.a4 ];
    beq = [ P.a1*s1; P.a2*s2 ];

    % --- condicionamento básico
    if rcond(Aeq) < 1e-10
        why = "Aeq mal-condicionado (determinante ~0). Ajuste gammas/parâmetros.";
        xop = [NaN;NaN;NaN;NaN]; uop=[NaN;NaN]; return;
    end

    % --- resolve s3,s4
    s = Aeq \ beq; s3 = s(1); s4 = s(2);

    % --- checagem física: s3,s4>=0
    if s3 < 0 || s4 < 0
        why = "Níveis superiores negativos (pedido de h1,h2 inviável para estes parâmetros).";
        xop = [NaN;NaN;NaN;NaN]; uop=[NaN;NaN]; return;
    end

    % --- calcula h3,h4 e v1,v2
    h3 = s3^2; h4 = s4^2;
    v2 = (P.a3 * sqrt(2*P.g) * s3) / ((1-P.gamma2)*P.k2);
    v1 = (P.a4 * sqrt(2*P.g) * s4) / ((1-P.gamma1)*P.k1);

    % --- checagem física: v1,v2>=0
    if v1 < 0 || v2 < 0
        why = "Entradas negativas (verifique unidades de k1,k2 e valores de gamma).";
        xop = [NaN;NaN;NaN;NaN]; uop=[NaN;NaN]; return;
    end

    xop = [h1_op; h2_op; h3; h4];
    uop = [v1; v2];
    ok  = true;
end
