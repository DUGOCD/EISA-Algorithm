clear all
clc

% =========================================================================
% 1. 测试集选择 (Benchmark Suite Selection)
% 修改下方 Suite_Choice 的值来快速切换测试集:
% 1: 传统 23 个测试函数 (F1 - F23)
% 2: CEC2019 (10 个函数)
% 3: CEC2020 (10 个函数, dim=20)
% 4: CEC2022 (12 个函数, dim=20)
% =========================================================================
Suite_Choice = 1; 

switch Suite_Choice
    case 1
        num_funcs = 23;
        suite_name = 'Classical 23';
    case 2
        num_funcs = 10;
        suite_name = 'CEC2019';
    case 3
        num_funcs = 10;
        suite_name = 'CEC2020';
    case 4
        num_funcs = 12;
        suite_name = 'CEC2022';
end

SearchAgents_no = 30;  % 种群数量
Max_iteration = 1000;  % 最大迭代次数

% 统一算法名称
algo_names = {'ETO', 'AO', 'SSA', 'ALA', 'IVY', 'WMA', 'ESOA', 'BTO', 'CTCM', 'EISA(OWN)'};
num_algorithms = length(algo_names);

% 定义颜色和标记点样式
colors = lines(num_algorithms); 
markerStyles = {'o', 's', 'd', '^', 'v', 'p', 'h', '*', 'x', '>'};

for i = 1:num_funcs
    
    % =====================================================================
    % 2. 动态加载目标函数详情
    % =====================================================================
    switch Suite_Choice
        case 1
            Function_name = ['F', num2str(i)];
            [lb, ub, dim, fobj] = Get_Functions_details(Function_name);
            disp(['>>> Running ', suite_name, ' - ', Function_name, ' <<<']);
        case 2
            Function_name = i;
            [dim, fobj, ub, lb] = Get_Functions_detailsCEC(Function_name);
            disp(['>>> Running ', suite_name, ' - Function ', num2str(i), ' <<<']);
        case 3
            Function_name = i;
            dim = 20; % CEC2020 指定20维
            [lb, ub, dim, fobj] = Get_Functions_cec2020(Function_name, dim);
            disp(['>>> Running ', suite_name, ' - Function ', num2str(i), ' <<<']);
        case 4
            Function_name = i;
            dim = 20; % CEC2022 指定20维
            [lb, ub, dim, fobj] = Get_Functions_cec2022(Function_name, dim);
            disp(['>>> Running ', suite_name, ' - Function ', num2str(i), ' <<<']);
    end

    % 边界矩阵维度处理
    if size(lb, 2) == 1
        lb = lb * ones(1, dim);
        ub = ub * ones(1, dim);
    end
    
    % 初始化种群
    pop_init = repmat(lb, SearchAgents_no, 1) + repmat((ub - lb), SearchAgents_no, 1) .* rand(SearchAgents_no, dim);
    
    [ETOfMin, ~, ETO_curve]   = ETO(SearchAgents_no, Max_iteration+1, lb, ub, dim, fobj);
    [AOfMin, ~, AO_curve]     = AO(SearchAgents_no, Max_iteration+1, lb, ub, dim, fobj);
    [SSAfMin, ~, SSA_curve]   = SSA(SearchAgents_no, Max_iteration, lb, ub, dim, fobj, pop_init);
    [ALAfMin, ~, ALA_curve]   = ALA(SearchAgents_no, Max_iteration+1, lb, ub, dim, fobj);
    [IVYfMin, ~, IVY_curve]   = IVY(SearchAgents_no, Max_iteration+1, lb, ub, dim, fobj);
    [WMAfMin, ~, WMA_curve]   = WMA(SearchAgents_no, Max_iteration+1, lb, ub, dim, fobj);
    [ESOAfMin, ~, ESOA_curve] = ESOA(SearchAgents_no, Max_iteration, lb, ub, dim, fobj, pop_init);
    [BTOfMin, ~, BTO_curve]   = BTO(SearchAgents_no, Max_iteration+1, lb, ub, dim, fobj);
    [CTCMfMin, ~, CTCM_curve] = CTCM(SearchAgents_no, Max_iteration, lb, ub, dim, fobj, pop_init);
    [EISAfMin, ~, EISA_curve] = EISA(SearchAgents_no, Max_iteration, lb, ub, dim, fobj, pop_init);

    % 将结果存入数组/元胞，方便循环输出与画图
    fMins = [ETOfMin, AOfMin, SSAfMin, ALAfMin, IVYfMin, WMAfMin, ESOAfMin, BTOfMin, CTCMfMin, EISAfMin];
    curves = {ETO_curve, AO_curve, SSA_curve, ALA_curve, IVY_curve, WMA_curve, ESOA_curve, BTO_curve, CTCM_curve, EISA_curve};
    
    % =====================================================================
    % 4. 绘制收敛曲线
    % =====================================================================
    figure('Name', ['Objective space: ', num2str(Function_name)]);
    hold on;
    legend_handles = gobjects(num_algorithms, 1); % 预分配图例句柄

    for j = 1:num_algorithms
        current_curve = curves{j};
        current_iter = length(current_curve);
        axis_x = 1:current_iter;
        
        % 绘制曲线，每隔 80 代加一个 marker
        legend_handles(j) = semilogy(axis_x, current_curve, 'LineWidth', 2, ...
            'Color', colors(j, :), 'Marker', markerStyles{j}, ...
            'MarkerIndices', 1:80:current_iter);
    end
    
    hold off;
    set(gca, 'YScale', 'log');
    title(['Convergence Curve: ', num2str(Function_name)]);
    xlabel('Iteration');
    ylabel('Best score obtained so far');
    box on;
    grid on;
    legend(legend_handles, algo_names, 'Location', 'best');
    
    % =====================================================================
    % 5. 打印最优值
    % =====================================================================
    for j = 1:num_algorithms
        disp(['The best optimal value found by ', algo_names{j}, ' is : ', num2str(fMins(j))]);
    end
    disp('---------------------------------------------------------');
    
end