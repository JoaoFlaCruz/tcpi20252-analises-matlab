%% C*(-A)^-1*B  (quatro tanques)
clear; clc;

% ---------- Parâmetros ----------
syms a1 a2 a3 a4 A1 A2 A3 A4 g h1s h2s h3s h4s real    
syms k1 k2 gam1 gam2 gam3 gam4 real                    

% ---------- Coeficientes de A ----------
c11 = -a1/(2*A1)*sqrt(2*g/h1s);
c13 =  a3/(2*A1)*sqrt(2*g/h3s);
c22 = -a2/(2*A2)*sqrt(2*g/h2s);
c24 =  a4/(2*A2)*sqrt(2*g/h4s);
c33 = -a3/(2*A3)*sqrt(2*g/h3s);
c44 = -a4/(2*A4)*sqrt(2*g/h4s);

% ---------- Matrizes do sistema ----------
A = [ c11  0    c13  0 ;
       0   c22   0   c24;
       0    0   c33  0 ;
       0    0    0   c44 ];

B = [ gam1*k1/A1   0          ;
        0         gam2*k2/A2  ;
        0         gam3*k2/A3  ;
      gam4*k1/A4   0          ];

C = [1 0 0 0;
     0 1 0 0];

D = sym(zeros(2,2)); % (não usado aqui)

% ---------- C*(-A)^-1*B ----------
G = simplify( C * ((-A)\B) );   
disp('C*(-A)^-1*B =');
pretty(G)   % exibe de forma legível no console

% ---- RGA ----
if exist('G','var')         % só passar de G -> K
    K = sym(G);
R = simplify( transpose(inv(K)) );
Lambda = simplify( K .* R );
end

disp('K = G(0) =');    pretty(simplify(K))
disp('R = (K^{-1})^T ='); pretty(R)
disp('Lambda = K .* R ='); pretty(Lambda)