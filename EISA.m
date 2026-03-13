function [best_fitness, best_solution, convergence_curve] = EISA(pop_size, max_iter, lb, ub, dim, f, pop_init)
    CostFunction = f;
    nVar = dim;
    VarMin = lb;
    VarMax = ub;
    MaxIt = max_iter;
    
    os = 1;
    nos = 1;
    nGroup_Pop = 10;
    nGroup = pop_size / nGroup_Pop;
    
    c1 = 1; 
    c2 = 1;
    c3 = 0.75;  % 学习系数
    
    % Velocity Limits 
    VelMax = 0.1* (VarMax - VarMin); 
    VelMin = -VelMax;
    
    % Initialization
    GlobalBestCost = inf;
    Position = pop_init;
    Velocity = zeros(nGroup * nGroup_Pop, nVar);
    
    Cost = zeros(nGroup * nGroup_Pop, 1);
    for i = 1:nGroup * nGroup_Pop
        Cost(i) = CostFunction(Position(i, :));
        if Cost(i) < GlobalBestCost
            GlobalBestCost = Cost(i);
            GlobalBestPosition = Position(i, :);
            GlobalBestGroupNo = mod(i, nGroup_Pop) + 1;
        end
    end
    
    convergence_curve = zeros(1, max_iter + 1);
    convergence_curve(1) = GlobalBestCost;
    
    PersonalBestCost = Cost;
    PersonalBestPosition = Position;
    
    % Group Best Init
    GroupBestCost = zeros(nGroup, 1);
    GroupBestPosition = zeros(nGroup, nVar);
    
    for i = 1:nGroup
        idx_start = (i-1)*nGroup_Pop + 1;
        idx_end = i*nGroup_Pop;
        [M, I] = min(Cost(idx_start:idx_end));
        GroupBestCost(i) = M;
        GroupBestPosition(i, :) = Position(idx_start + I(1) - 1, :);
    end
    

    for it = 1:MaxIt
       
         w = 1 - 0.5 * (it / MaxIt); 
        progress = it / MaxIt;
        r1 = rand(nGroup*nGroup_Pop, nVar);
        r2 = rand(nGroup*nGroup_Pop, nVar);
        r3 = rand(nGroup*nGroup_Pop, nVar);
        r1 = log10(1+r1.*9);
        r2 = log10(1+r2.*9);
        r3 = log10(1+r3.*9);
         
       for i = 1:nGroup * nGroup_Pop
            GroupNum = floor((i-1) / nGroup_Pop) + 1;       
            % (Cooperation) ---
            if all(Position(i, :) == GroupBestPosition(GroupNum, :))            
                other_group = randi(nGroup);
                while other_group == GroupNum && nGroup > 1
                    other_group = randi(nGroup); 
                end
                Velocity(i, :) = w * Velocity(i, :) ...
                    + c1 * r1(i, :) .* (PersonalBestPosition(i, :) - Position(i, :)) ...
                    + c2 * r2(i, :) .* (mean(GroupBestPosition, 1) - Position(i, :));
            else
                Velocity(i, :) = w * Velocity(i, :) ...
                    + c1 * r1(i, :) .* (PersonalBestPosition(i, :) - Position(i, :)) ...
                    + c2 * r2(i, :) .* (GroupBestPosition(GroupNum, :) - Position(i, :));
            end
            
            % Competition) ---
            if mod(i, nGroup_Pop) == 1
                rival_group = randi([1, nGroup]);
                while rival_group == GroupNum % 避免选自己组
                    rival_group = randi([1, nGroup]);
                end
                rival_idx_in_group = randi([1, nGroup_Pop]);
                rival_idx = (rival_group-1) * nGroup_Pop + rival_idx_in_group;
            end
      
            % 如果我比对手差 (Cost(i) > Cost(rival))
            if Cost(i) > Cost(rival_idx)
                
                if rand() < exp(-2 * progress) % 早期阶段
                    
                         Velocity(i, :) = -Velocity(i, :);
%                        
                  
                else
                    % 后期阶段：精细搜索
                   
                        Velocity(i, :) = Velocity(i, :) + c3 * r3(i, :) .* (Position(rival_idx, :) - Position(i, :));
                    
                end
            end
            
            % 应用速度限制
            Velocity(i, :) = max(min(Velocity(i, :), VelMax), VelMin);
            
            % 更新位置
            Position(i, :) = Position(i, :) + Velocity(i, :);
             Position(i,:) = max(min(Position(i,:), VarMax), VarMin);
           
            
            % 评估
            NewCost = CostFunction(Position(i, :));
            Cost(i) = NewCost;
            
            % 更新 PBest
            if Cost(i) < PersonalBestCost(i)
                PersonalBestCost(i) = Cost(i);
                PersonalBestPosition(i, :) = Position(i, :);
                
                % 只有 PBest 更新了才尝试更新 GroupBest，节省计算
                if Cost(i) < GroupBestCost(GroupNum)
                    GroupBestCost(GroupNum) = Cost(i);
                    GroupBestPosition(GroupNum, :) = Position(i, :);
                    
                    if Cost(i) < GlobalBestCost
                        GlobalBestCost = Cost(i);
                        GlobalBestPosition = Position(i, :);
                    end
                end
            end
        end
        
        convergence_curve(it + 1) = GlobalBestCost;
    end
    
    best_solution = GlobalBestPosition;
    best_fitness = GlobalBestCost;
end