run("modelagem_linear.m");

%% Calculo dos controladores PI por sintese direta

G_11
G_22
T1 = tf([1], [6, 1]);
T2 = tf([1], [22, 1]);

C1 = (1/G_11)*(T1/(1 - T1));
C2 = (1/G_22)*(T2/(1 - T2));

FR1 = tf([1], [108.4, 24.07, 1]);
FR2 = tf([1], [1505, 90.4, 1]);

%% Calculo manual

C1 = tf([18.07, 1],[0.3222, 0]);
C2 = tf([68.4, 1], [4.1294, 0]);

FR1 = tf([1], [18.07, 1]);
FR2 = tf([1], [68.4, 1]);
