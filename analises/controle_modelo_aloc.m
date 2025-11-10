run("modelagem_linear.m");

%% Calculo dos controladores PI por alocação de polos e zeros

wn_1 = 3/6;
zeta_1 = 1;
tau_1 = 18.07;
k_1 = 0.0537;

kp_1 = (2 * zeta_1 * wn_1 * tau_1 - 1)/k_1;
ti_1 = (2 * zeta_1 * wn_1 * tau_1 - 1)/(tau_1 * wn_1^2);

wn_2 = 3/22;
zeta_2 = 1;
tau_2 = 68.3994;
k_2 = 0.1877;

kp_2 = (2 * zeta_2 * wn_2 * tau_2 - 1)/k_2;
ti_2 = (2 * zeta_2 * wn_2 * tau_2 - 1)/(tau_2 * wn_2^2);

C1 = tf([kp_1*ti_1, kp_1], [ti_1, 0])
C2 = tf([kp_2*ti_2, kp_2], [ti_2, 0])

FR1 = tf([kp_1], [kp_1*ti_1, kp_1])
FR2 = tf([kp_2], [kp_2*ti_2, kp_2])