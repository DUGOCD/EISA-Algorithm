function [lb,ub,dim,fobj] = caseStudy(F)

switch F
    case 'Hi'
        fobj = @Himmelblau;
        bias = 50;
        lb=[78, 33, 27, 27, 27]-bias;
        ub=[102, 45, 45, 45, 45]-bias;
        dim=5;
        
    case 'S'
        fobj = @Speed;
        bias = 50;
        lb = [2.6, 0.7, 17, 7.3, 7.8, 2.9, 2.9]-bias;
        ub = [3.6, 0.8, 28, 8.3, 8.3, 3.9, 3.9]-bias;
        dim=7;
    
    case 'WB'  % New Problem
        fobj = @WeldedBeam;
%         bias = 50;
        lb = [0.1, 0.1, 0.1, 0.1];
        ub = [2, 10, 10, 2];
        dim = 4;

    case 'PV'
        fobj = @Pressure;
        bias = 50;
        lb = [0.1, 0.1, 10, 10]-bias;   % Lower bounds for [Ts, Th, R, L]
        ub = [99, 99, 200, 200]-bias;
        dim = 4;

    case 'Ro'
        fobj = @Rolling;
        bias = 50;
        lb = [125, 10.5, 4, 0.515, 0.515, 0.4, 0.6, 0.3, 0.02, 0.6]-bias; % Lower bounds
        ub = [150, 31.5, 50, 0.6, 0.6, 0.5, 0.7, 0.4, 0.1, 0.85]-bias;   % Upper bounds
        dim = 10;
end
end



function fval = Himmelblau(x)
    x = x+50;
    % Original objective function
    f_original = 5.3578547 * x(3)^2 + 0.8356891 * x(1) * x(5) + 37.293239 * x(1) - 40792.141;
    
    % Penalty for constraints
    penalty = 0;
    penalty_weight = 1e6;  % A large number to penalize constraint violations

    % Constraints
    g1 = 85.334407 + 0.0056858 * x(2) * x(5) + 0.0006262 * x(1) * x(4) - 0.0022053 * x(3) * x(5);
    g2 = 80.51249 + 0.0071317 * x(2) * x(5) + 0.0029955 * x(1) * x(2) + 0.0021813 * x(3)^2;
    g3 = 9.300961 + 0.0047026 * x(3) * x(5) + 0.0012547 * x(1) * x(3) + 0.0019085 * x(3) * x(4);

    % Constraint bounds
    if g1 < 0 || g1 > 92
        penalty = penalty + penalty_weight * abs(g1);
    end
    if g2 < 90 || g2 > 110
        penalty = penalty + penalty_weight * abs(g2);
    end
    if g3 < 20 || g3 > 25
        penalty = penalty + penalty_weight * abs(g3);
    end
    
    % Variable bounds
    bounds = [
        78, 102;  % x1
        33, 45;   % x2
        27, 45;   % x3
        27, 45;   % x4
        27, 45    % x5
    ];
    
    for i = 1:length(x)
        if x(i) < bounds(i, 1) || x(i) > bounds(i, 2)
            penalty = penalty + penalty_weight * abs(x(i));
        end
    end

    % Penalized objective function
    fval = f_original + penalty;
end


function [fval] = Speed(x)
    % Extract variables
    x = x+50;
    b = x(1);
    m = x(2);
    z = x(3);
    l1 = x(4);
    l2 = x(5);
    d1 = x(6);
    d2 = x(7);

    % Original objective function
    f_original = 0.7854 * b * m^2 * (3.3333 * z^2 + 14.9334 * z - 43.0934) - 1.508 * b * (d1^2 + d2^2) + 7.4777 * (d1^3 + d2^3) + 0.7854 * (l1 * d1^2 + l2 * d2^2);
    
    % Penalty for constraints
    penalty = 0;
    penalty_weight = 1e6;  % A large number to penalize constraint violations

    % Constraints
    M = 745 * l1 / (m * z);
    H = 745 * l2 / (m * z);
    
    g1 = 27 / (b * m^2 * z) - 1;
    g2 = 397.5 / (b * m^2 * z^2) - 1;
    g3 = 1.93 * l1^3 / (m * z * d1^4) - 1;
    g4 = 1.93 * l2^3 / (m * z * d2^4) - 1;
    g5 = sqrt(M^2 + 16.9e6) / (110 * d1^3) - 1;
    g6 = sqrt(H^2 + 15.75e6) / (85 * d2^3) - 1;
    g7 = m * z / 40 - 1;
    g8 = 5 * m / b - 1;
    g9 = b / (12 * m) - 1;
    g10 = (1.5 * d1 + 1.9) / l1 - 1;
    g11 = (1.1 * d2 + 1.9) / l2 - 1;

    % Aggregate constraints
    constraints = [g1, g2, g3, g4, g5, g6, g7, g8, g9, g10, g11];
    
    % Calculate penalty
    for i = 1:length(constraints)
        if constraints(i) > 0
            penalty = penalty + penalty_weight *abs( constraints(i));
        end
    end
    
    % Variable bounds
    bounds = [
        2.6, 3.6;  % b
        0.7, 0.8;  % m
        17, 28;    % z
        7.3, 8.3;  % l1
        7.8, 8.3;  % l2
        2.9, 3.9;  % d1
        2.9, 3.9   % d2
    ];
    
    for i = 1:length(x)
        if x(i) < bounds(i, 1)
            penalty = penalty + penalty_weight * abs(x(i));
        elseif x(i) > bounds(i, 2)
            penalty = penalty + penalty_weight * abs(x(i));
        end
    end

    % Penalized objective function
    fval = f_original + penalty;
end

function fval = WeldedBeam(x)
%     x = x+50;
    % Constants for NewProblem
    P = 6000;  % lb
    L = 14;    % in
    delta_max = 0.25;  % in
    E = 30e6;  % psi
    G = 12e6;  % psi
    tau_max = 13600;  % psi
    sigma_max = 30000;  % psi
    
    % Helper variables for NewProblem
    p = P / (x(3) * x(4));
    R = sqrt((x(2)^2 / 4) + ((x(1) + x(3)) / 2)^2);
    J = 2 * (sqrt(2 * x(1) * x(2)) * ((x(2)^2 / 4) + ((x(1) + x(3)) / 2)^2));
    MR = P * (L + x(2) / 2);
    % Original objective function
    f_original = 1.10471 * x(1)^2 * x(2) + 0.04811 * x(3) * x(4) * (14.0 + x(2));
    
    % Penalty for constraints
    penalty = 0;
    penalty_weight = 1e6;  % A large number to penalize constraint violations

    % Constraints
    tau = sqrt((p / sqrt(2 * x(1) * x(2)))^2 + 2 * (p / sqrt(2 * x(1) * x(2))) * (MR / J) * (x(2) / 2 / R) + (MR / J)^2);
    sigma = (6 * P * L) / (x(4) * x(3)^2);
    delta = (6 * P * L^3) / (E * x(3)^2 * x(4));
    g1 = tau - tau_max;
    g2 = sigma - sigma_max;
    g3 = delta - delta_max;
    g4 = x(1) - x(4);
    g5 = P - (4.013 * E * sqrt(x(3)^2 * x(4)^6 / 36) / L^2 * (1 - (x(3) / 2 / L) * sqrt(E / 4 / G)));
    g6 = 0.125 - x(1);
    g7 = 1.10471 * x(1)^2 + 0.04811 * x(3) * x(4) * (14.0 + x(2)) - 5.0;
    
    constraints = [g1, g2, g3, g4, g5, g6, g7];
    % Penalty functions
    for i = 1:length(constraints)
        if constraints(i) > 0
            penalty = penalty + penalty_weight *abs( constraints(i));
        end
    end

    % Variable bounds
    bounds = [
        0.1, 2;    % x1
        0.1, 10;   % x2
        0.1, 10;   % x3
        0.1, 2     % x4
    ];
    
    for i = 1:length(x)
        if x(i) < bounds(i, 1) || x(i) > bounds(i, 2)
            penalty = penalty + penalty_weight * abs(x(i));
        end
    end

    % Penalized objective function
    fval = f_original + penalty;
end

function fval = Pressure(x)
    x = x+50;
    % Variables
    z1 = x(1);
    z2 = x(2);
    z3 = x(3);
    z4 = x(4);
    
    fval = 0.6224 * z1 * z3 * z4 + 1.7781 * z2 * z3^2 + 3.1661 * z1^2 * z4 + 19.84 * z1^2 * z3;
    g1 = -z1 + 0.0193 * z3;
    g2 = -z3 + 0.00954 * z3;
    g3 = -pi * z3^2 * z4 - (4/3) * pi * z3^3 + 1296000;
    g4 = z4 - 240;


    % Combine constraints
    constraints = [g1, g2, g3, g4];
    penalty = 0;
    penalty_weight = 10e6;
    % Calculate penalty
    for i = 1:length(constraints)
        if constraints(i) > 0
            penalty = penalty + penalty_weight * abs(constraints(i));
        end
    end

    % Penalized objective function
    fval = fval + penalty;
end

function fval = Rolling(x)
    x = x+50;
    % Variables
    % Objective function to maximize Cd
    D = 160;
    d = 90;
    gamma = x(2) / x(1);
    t1 = 37.91 * (1 + (1.04 * ((1 - gamma) / (1 + gamma))^1.72 * ...
        (x(4) / x(5) * (2 * x(5) - 1) / (2 * x(4) - 1))^0.41)^(10 / 3))^(-0.3);
    fc = t1 * (gamma^0.3 * (1 - gamma)^1.39 / ((1 + gamma)^(1 / 3))) * ...
        (2 * x(4) / (2 * x(4) - 1))^0.41;
    
    if x(2) <= 25.4
        f = fc * x(3)^(2/3) * x(2)^1.8;
    else
        f = 3.647 * fc * x(3)^(2/3) * x(2)^1.4;
    end
    fval = -f; % Maximize -> Minimize by negating f

    % Penalty for constraints
    penalty = 0;
    penalty_weight = 1e6;  % A large number to penalize constraint violations

    % Constraints
    Bw = 30;
    ri = 11.033;
    ro = 11.033;
    T = D - d - 2 * x(2);
    
    % Constraint calculations
    xx = ((D - d) / 2 - 3 * (T / 4))^2 + (D / 2 - T / 4 - x(2))^2 - (d / 2 + T / 4)^2;
    yy = 2 * ((D - d) / 2 - 3 * (T / 4)) * (D / 2 - T / 4 - x(2));
    theta0 = 2 * pi - 1 / cos(xx / yy);

    g1 = theta0 / (2 / sin(x(2) / x(1))) - x(3) + 1;
    g2 = x(6) * (D - d) - 2 * x(2);
    g3 = 2 * x(2) - x(7) * (D - d);
    g4 = x(10) * Bw - x(2);
    g5 = 0.5 * (D + d) - x(1);
    g6 = x(1) - (0.5 + x(9)) * (D + d);
    g7 = x(8) * x(2) - 0.5 * (D - x(1) - x(2));
    g8 = 0.515 - x(4);
    g9 = 0.515 - x(5);

    % Aggregate constraints
    constraints = [g1, g2, g3, g4, g5, g6, g7, g8, g9];
    
    % Calculate penalty
    for i = 1:length(constraints)
        if constraints(i) > 0
            penalty = penalty + penalty_weight * abs(constraints(i));
        end
    end

    % Penalized objective function
    fval = -fval + penalty; % Maximize -> Minimize by negating fval
end

