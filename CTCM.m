function [best_fitness, best_solution, convergence_curve] = CTCM (pop_size, max_iter,  lb, ub, dim, f, pop_init)
   CostFunction = f;
    nVar=dim;            % Number of Decision Variables
    VarMin=lb;         % Lower Bound of Variables
    VarMax= ub;         % Upper Bound of Variables
    MaxIt=max_iter;      % Maximum Number of Iterations
    
    nGroup_Pop=10;
    nGroup=pop_size/nGroup_Pop;

    c1=2.0;         
    c2=1.0;         
    c3=0.1;

    % Velocity Limits
    VelMax=0.1*(VarMax-VarMin);
    VelMin=-VelMax;
    % Initialization
    GlobalBestCost=inf;
    %Initial position
    Position=pop_init;
    % Initialize Velocity
    Velocity=zeros(nGroup*nGroup_Pop,nVar);
    % Evaluation
    Cost=zeros(nGroup*nGroup_Pop,1);
    for i=1:nGroup*nGroup_Pop
        Cost(i)=CostFunction(Position(i,:));
        if Cost(i)<GlobalBestCost
            GlobalBestCost=Cost(i);
            GlobalBestPosition=Position(i,:);
            GlobalBestGroupNo=mod(i,nGroup_Pop)+1;
        end

    end
    convergence_curve = zeros(1, max_iter + 1);
    convergence_curve(1) = GlobalBestCost;
    convergence_loc = zeros(max_iter + 1, dim);
    convergence_loc(1, :) = GlobalBestPosition;

    % Update Personal Best
    PersonalBestCost=Cost;
    PersonalBestPosition=Position;
    % Update Group Best

    for i=1:nGroup
        MemberCost=Cost((i-1)*nGroup_Pop+[1:nGroup_Pop]);
        [M,I]=min(MemberCost);
        GroupBestNum(i)=I(1);
        GroupBestCost(i)=M;
        GroupBestPosition(i,:)=Position((i-1)*nGroup_Pop+I(1),:);
    end


    BestCost=zeros(MaxIt,1);
    % CTCM Main Loop
    for it=1:MaxIt
        % Loyal and Retreat factor generation
        if mod(it, nGroup)==1
            r1 = rand(nGroup*nGroup_Pop, nVar);
            r2 = rand(nGroup*nGroup_Pop, nVar);
            r3 = rand(nGroup*nGroup_Pop, nVar);
        else
            r1 = sin(pi/2.*r1);
            r2 = sin(pi/2.*r2);
            r3 = sin(pi/2.*r3);
%             r1 = randn(nGroup*nGroup_Pop, nVar);
%             r2 = randn(nGroup*nGroup_Pop, nVar);
%             r3 = randn(nGroup*nGroup_Pop, nVar);
        end

        
        for i=1:nGroup*nGroup_Pop
            GroupNum=floor((i-1)/nGroup_Pop)+1;
            PersonalNum=i-(GroupNum-1)*nGroup_Pop;
            % Cooperation (Exploitation)
            if rand>0.5
%             if rand>0
            Velocity(i, :) = 0.5 * Velocity(i, :) ...
                         + c1 * r1(i, :) .* (PersonalBestPosition(i, :) - Position(i, :)) ...
                         + c2 * r2(i, :) .* (GroupBestPosition(GroupNum, :) - Position(i, :));
            else
                 Velocity(i, :) = 0.5 * Velocity(i, :) ...
                         + c1 * r1(i, :) .* (PersonalBestPosition(i, :) - Position(i, :)) ...
                         + c2 * r2(i, :) .* (GroupBestPosition(GroupNum, :) - Position(i, :));
            end
            % Competition (Exploration)
            if mod(i,nGroup_Pop)==1
                rival=randi([1 nGroup],1,1);
            end
            if GroupBestCost(GroupNum)>GroupBestCost(rival)
                Velocity(i,:)=0.8*Velocity(i,:)+c3*r3(i, :).*(Position(i,:)-GroupBestPosition(rival,:));
            end
            % Apply Velocity Limits
            Velocity(i,:)=max(Velocity(i,:),VelMin);
            Velocity(i,:)=min(Velocity(i,:),VelMax);
            % Update Position
            Position(i,:)=Position(i,:)+Velocity(i,:);
            % Velocity Mirror Effect
            if Position(i,:)<VarMin | Position(i,:)>VarMax
                Velocity(i,:)=-Velocity(i,:);
            end
            % Apply Position Limits
            Position(i,:)= max(Position(i,:),VarMin);
            Position(i,:)= min(Position(i,:),VarMax);
            % Evaluation
            Cost(i)=CostFunction(Position(i,:));
            if Cost(i)<PersonalBestCost(i)
                PersonalBestCost(i)=Cost(i);
                PersonalBestPosition(i,:)=Position(i,:);
            end
            % Update Group Best
            if Cost(i)<GroupBestCost(GroupNum)
                GroupBestNum(GroupNum)=i;
                GroupBestCost(GroupNum)=Cost(i);
                GroupBestPosition(GroupNum,:)=Position(i,:);
            end
            % Update Global Best
            if Cost(i)<GlobalBestCost
                GlobalBestCost=Cost(i);
                GlobalBestPosition=Position(i,:);
                GlobalBestGroupNo=GroupNum;
            end
        end
        BestCost(it)=GlobalBestCost;
        BestGroup(it)=GlobalBestGroupNo;

        convergence_curve(it + 1) = GlobalBestCost;
        convergence_loc(it +1, :) = GlobalBestPosition;
    end
    best_solution = GlobalBestPosition;
    best_fitness = GlobalBestCost;

end