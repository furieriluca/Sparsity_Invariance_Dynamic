%PLANT DEFINITION
% Example took from 
% "A Characterization of Convex Problems in Decentralized Control",

s     = sym('s');
G     = [1/(s+1) 0 0 0 0;                             
         1/(s+1) 1/(s-1) 0 0 0;
         1/(s+1) 1/(s-1) 1/(s+1) 0 0;                                              
         1/(s+1) 1/(s-1) 1/(s+1) 1/(s+1) 0;
         1/(s+1) 1/(s-1) 1/(s+1) 1/(s+1) 1/(s-1)];                               
Delta = [1 0 0 0 0;1 1 0 0 0;1 1 1 0 0;1 1 1 1 0;1 1 1 1 1];                   % plant binary structure
n     = size(G,1);
m     = size(G,2);
P11   = [G zeros(n,n);zeros(n,n) zeros(n,n)];                                   
P12   = [G;eye(n)];
P21   = [G eye(n)];

Knom = [0 0 0 0 0;0 -6/(s+3) 0 0 0;0 0 0 0 0;0 0 0 0 0;0 0 0 0 -6/(s+3)];       % nominal stabilizing controller from [1]



%%%These are other possible choices for Knom stable and stabilizing, which
%%%leades to different results

%Knom= [ 0,          0, 0, 0,          0;%%%% GOOD
 %0, -16/(s + 7), 0, 0,          0;
 %0,          0, 0, 0,          0;
 %0,          0, 0, 0,          0;
 %0,  16/(s + 7), 0, 0, -16/(s + 7)];

%Knom = [ 0,                                                0, 0, 0,           0;
%0,                                      -16/(s + 7), 0, 0,           0;
% 0,                                                0, 0, 0,           0;
% 0,                                        8/(s + 7), 0, 0,           0;
% 0, (16*(s^2 + 8*s + 15))/(s^3 + 15*s^2 + 63*s + 49), 0, 0, -16/(s + 7)]; %%BAD RESULT


%Knom= [ 0,          0, 0, 0,          0;     WEIRD RESULT ( lower cost...)
 %0, -(s+3)/(s + 2), 0, 0,          0;
 %0,          0, 0, 0,          0;
 %0,          0, 0, 0,          0;
% 0,  (s+3)/(s + 2)^2, 0, 0, -(s+3)/(s + 2)];

%Knom= [ 0,                            0,           0, 0,                    0;
 %0,         -(3*s + 1)/(2*s + 1),           0, 0,                    0;
 %0,                            0,           0, 0,                    0;
 %0,                            0,           0, 0,                    0;
 %0, -(3*s + 1)/(4*s^2 + 4*s + 1), 4/(2*s + 1), 0, -(3*s + 1)/(2*s + 1)];

 %Knom=[0 0 0 0 0; %%%BAD RESULT
 %     0 -27/(s^2 + 7*s + 19) 0 0 0;
 %      0 0 0 0 0;
 %      0 0 0 0 0;
 %      0 27/(s^2 + 7*s + 19) 0 0 -27/(s^2 + 7*s + 19)];

T3   = simplifyFraction((eye(n)-G*Knom)\P21);                                                     
T1   = simplifyFraction(P11 + P12*Knom*T3);                                   
T2   = simplifyFraction(-P12/(eye(m)-Knom*G));

 % minimal state space realizations for T1, T2, T3
SYS = ss(syms2tf(T1),'min');      
A1  = SYS.A; B1  = SYS.B; C1  = SYS.C; D1  = SYS.D;

SYS = ss(syms2tf(T2),'min');
A2  = SYS.A; B2  = SYS.B; C2  = SYS.C; D2  = SYS.D;

SYS = ss(syms2tf(T3),'min');
A3  = SYS.A; B3  = SYS.B; C3  = SYS.C; D3  = SYS.D;

%% Parameterization of Y(s)
% Decomposition matrices onto basis, so that Cij (sI-AiQ)^-1 BiQ + Dij = Y(i,j)
shift = 1;
AiQ   = -a*eye(N) + diag(ones(N-abs(shift),1),shift);        
AQ    = kron(eye(n),AiQ);
I     = eye(N);
BiQ   = I(:,N);
BQ    = kron(eye(n),BiQ);

%% State-space realization of the augmented LTI system
%  See (19) in [2] for the following matrices
A1_hat = blkdiag(A1, A2);
A2_hat = [A3 zeros(size(A3,1),size(AQ,2));BQ*C3 AQ];
A_hat  = zeros(size(A1_hat,1),size(A2_hat,2));
B1_hat = [B1;zeros(size(B2,1),size(B1,2))];
B_hat  = [zeros(size(B1,1),size(B2,2));B2];
B2_hat = [B3;BQ*D3];
C1_hat = [C1 -C2];
C_hat  = [zeros(n*N,size(C3,2)) eye(n*N);C3 zeros(size(C3,1),n*N)];
C2_hat = [zeros(size(C1_hat,1),size(C_hat,2))];
D_hat  = D1;
E_hat  = -D2;
F_hat  = [zeros(size(C_hat,1)-size(D3,1),size(D_hat,2));D3];

save plant_data