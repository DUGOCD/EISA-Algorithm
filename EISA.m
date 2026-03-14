function [best_fitness, best_solution, convergence_curve] = EISA(pop_size, max_iter, lb, ub, dim, f, pop_init)
% EISA: Elite-Inspired Sociocultural Algorithm
% 
% Inputs:
%   pop_size  - Number of search agents (population size)
%   max_iter  - Maximum number of iterations
%   lb        - Lower bound of variables
%   ub        - Upper bound of variables
%   dim       - Number of dimensions
%   f         - Objective function handle
%   pop_init  - Initialized population matrix
%
% Outputs:
%   best_fitness      - The best objective function value found
%   best_solution     - The position vector of the best solution
%   convergence_curve - The best fitness value recorded at each iteration

    %% 1. Algorithmic Parameters Setup
    % Structural parameters
    nGroup_Pop = 10;                        % Subpopulation size
    nGroup = pop_size / nGroup_Pop;         % Number of hierarchical groups
    
    % Learning coefficients
    c1 = 1.0;                               % Cognitive learning factor
    c2 = 1.0;                               % Social learning factor
    c3 = 0.75;                              % Exploitation adjustment factor
    
    % Dynamic boundaries
    VarMin = lb;
    VarMax = ub;
    VelMax = 0.1 * (VarMax - VarMin);       % Maximum velocity boundary
    VelMin = -VelMax;                       % Minimum velocity boundary
    
    %% 2. Initialization Phase
    % Initialize historical tracking variables
    GlobalBestCost = inf;
    Position = pop_init;
    Velocity = zeros(pop_size, dim);
    Cost = zeros(pop_size, 1);
    
    % Initial evaluation
    for i = 1:pop_size
        Cost(i) = f(Position(i, :));
        
        % Update global best
        if Cost(i) < GlobalBestCost
            GlobalBestCost = Cost(i);
            GlobalBestPosition = Position(i, :);
        end
    end
    
    % Record convergence
    convergence_curve = zeros(1, max_iter + 1);
    convergence_curve(1) = GlobalBestCost;
    
    % Initialize personal best (PBest)
    PersonalBestCost = Cost;
    PersonalBestPosition = Position;
    
    % Initialize group best (GBest)
    GroupBestCost = zeros(nGroup, 1);
    GroupBestPosition = zeros(nGroup, dim);
    
    for i = 1:nGroup
        idx_start = (i - 1) * nGroup_Pop + 1;
        idx_end = i * nGroup_Pop;
        [M, I] = min(Cost(idx_start:idx_end));
        GroupBestCost(i) = M;
        GroupBestPosition(i, :) = Position(idx_start + I(1) - 1, :);
    end
    
    %% 3. Sociocultural Evolution Loop
    for it = 1:max_iter
        
        % Adaptive parameters
        w = 1 - 0.5 * (it / max_iter);      % Linearly decreasing inertia weight
        progress = it / max_iter;           % Current optimization progress
        
        % Non-linear Sociocultural Cohesion Mapping (Right-skewed distribution)
        r1 = log10(1 + rand(pop_size, dim) .* 9);
        r2 = log10(1 + rand(pop_size, dim) .* 9);
        r3 = log10(1 + rand(pop_size, dim) .* 9);
         
        for i = 1:pop_size
            GroupNum = floor((i - 1) / nGroup_Pop) + 1;       
            
            %% Phase A: Collaboration Strategy (Elite Guidance)
            % Check if current particle is the elite of its group
            if all(Position(i, :) == GroupBestPosition(GroupNum, :))            
                % Inter-group Collaboration: Elite learns from the global average
                other_group = randi(nGroup);
                while other_group == GroupNum && nGroup > 1
                    other_group = randi(nGroup); 
                end
                Velocity(i, :) = w * Velocity(i, :) ...
                    + c1 * r1(i, :) .* (PersonalBestPosition(i, :) - Position(i, :)) ...
                    + c2 * r2(i, :) .* (mean(GroupBestPosition, 1) - Position(i, :));
            else
                % Intra-group Collaboration: Ordinary member learns from its group elite
                Velocity(i, :) = w * Velocity(i, :) ...
                    + c1 * r1(i, :) .* (PersonalBestPosition(i, :) - Position(i, :)) ...
                    + c2 * r2(i, :) .* (GroupBestPosition(GroupNum, :) - Position(i, :));
            end
            
            %% Phase B: Dual-Phase Inter-group Competition
            % Assign a shared rival for the current subgroup
            if mod(i, nGroup_Pop) == 1
                rival_group = randi([1, nGroup]);
                while rival_group == GroupNum % Prevent self-competition
                    rival_group = randi([1, nGroup]);
                end
                rival_idx_in_group = randi([1, nGroup_Pop]);
                rival_idx = (rival_group - 1) * nGroup_Pop + rival_idx_in_group;
            end
      
            % If the current individual is outcompeted by the rival
            if Cost(i) > Cost(rival_idx)
                % Time-adaptive exponential threshold for exploration/exploitation balance
                if rand() < exp(-2 * progress) 
                    % Early stage: Velocity Reversal (Shatter stagnation)
                    Velocity(i, :) = -Velocity(i, :);
                else
                    % Late stage: Compromise and Refinement (Deep exploitation)
                    Velocity(i, :) = Velocity(i, :) + c3 * r3(i, :) .* (Position(rival_idx, :) - Position(i, :));
                end
            end
            
            %% Phase C: Kinematic Update and Boundary Control
            % Apply velocity clamping
            Velocity(i, :) = max(min(Velocity(i, :), VelMax), VelMin);
            
            % Update spatial position
            Position(i, :) = Position(i, :) + Velocity(i, :);
            Position(i, :) = max(min(Position(i, :), VarMax), VarMin);
           
            %% Phase D: Fitness Evaluation and Hierarchy Update
            NewCost = f(Position(i, :));
            Cost(i) = NewCost;
            
            % Update Personal Best
            if Cost(i) < PersonalBestCost(i)
                PersonalBestCost(i) = Cost(i);
                PersonalBestPosition(i, :) = Position(i, :);
                
                % Update Group Best (Only triggered if PBest improves)
                if Cost(i) < GroupBestCost(GroupNum)
                    GroupBestCost(GroupNum) = Cost(i);
                    GroupBestPosition(GroupNum, :) = Position(i, :);
                    
                    % Update Global Best
                    if Cost(i) < GlobalBestCost
                        GlobalBestCost = Cost(i);
                        GlobalBestPosition = Position(i, :);
                    end
                end
            end
        end
        
        % Record the historical best for the convergence curve
        convergence_curve(it + 1) = GlobalBestCost;
    end
    
    % Final output assignment
    best_solution = GlobalBestPosition;
    best_fitness = GlobalBestCost;
    
end