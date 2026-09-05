function build_FDFE_fis()
    % Tạo hệ mờ FDFE - Fuzzy Deduced Fitness Evaluator
    fis = mamfis('Name', 'FDFE', ...
        'AndMethod', 'min', ...
        'OrMethod', 'max', ...
        'ImplicationMethod', 'min', ...
        'AggregationMethod', 'max', ...
        'DefuzzificationMethod', 'centroid');

    %% ===== INPUT 1: Charging Time (CT) =====
    fis = addInput(fis, [30 90], 'Name', 'CT');
    fis = addMF(fis, 'CT', 'trimf', [30 30 45], 'Name', 'S');
    fis = addMF(fis, 'CT', 'trimf', [30 45 60], 'Name', 'MS');
    fis = addMF(fis, 'CT', 'trimf', [45 60 75], 'Name', 'M');
    fis = addMF(fis, 'CT', 'trimf', [60 75 90], 'Name', 'ML');
    fis = addMF(fis, 'CT', 'trimf', [75 90 90], 'Name', 'L');

    %% ===== INPUT 2: Normalized Discharged Capacity (NDC) =====
    fis = addInput(fis, [80 100], 'Name', 'NDC');
    fis = addMF(fis, 'NDC', 'trimf', [80 80 85], 'Name', 'S');
    fis = addMF(fis, 'NDC', 'trimf', [80 85 90], 'Name', 'MS');
    fis = addMF(fis, 'NDC', 'trimf', [85 90 95], 'Name', 'M');
    fis = addMF(fis, 'NDC', 'trimf', [90 95 100], 'Name', 'ML');
    fis = addMF(fis, 'NDC', 'trimf', [95 100 100], 'Name', 'L');

    %% ===== OUTPUT: Fitness [0–1] =====
    fis = addOutput(fis, [0 1], 'Name', 'Fitness');
    fis = addMF(fis, 'Fitness', 'trimf', [0.0 0.0 0.125], 'Name', 'VS');
    fis = addMF(fis, 'Fitness', 'trimf', [0.0 0.125 0.25], 'Name', 'SS');
    fis = addMF(fis, 'Fitness', 'trimf', [0.125 0.25 0.375], 'Name', 'S');
    fis = addMF(fis, 'Fitness', 'trimf', [0.25 0.375 0.5], 'Name', 'MS');
    fis = addMF(fis, 'Fitness', 'trimf', [0.375 0.5 0.625], 'Name', 'M');
    fis = addMF(fis, 'Fitness', 'trimf', [0.5 0.625 0.75], 'Name', 'ML');
    fis = addMF(fis, 'Fitness', 'trimf', [0.625 0.75 0.875], 'Name', 'L');
    fis = addMF(fis, 'Fitness', 'trimf', [0.75 0.875 1.0], 'Name', 'LL');
    fis = addMF(fis, 'Fitness', 'trimf', [0.875 1.0 1.0], 'Name', 'VL');

    %% ===== RULE BASE: 25 luật =====
    % Bảng luật tương ứng CT x NDC (5x5)
    % CT: S, MS, M, ML, L --> 1–5
    % NDC: S, MS, M, ML, L --> 1–5
    % Fitness: VS=1 → VL=9

    ruleList = [
        1 1 5 1 1;  % S, S  -> M
        2 1 6 1 1;  % MS, S -> ML
        3 1 7 1 1;  % M, S  -> L
        4 1 8 1 1;  % ML, S -> LL
        5 1 9 1 1;  % L, S  -> VL

        1 2 4 1 1;
        2 2 5 1 1;
        3 2 6 1 1;
        4 2 7 1 1;
        5 2 8 1 1;

        1 3 3 1 1;
        2 3 4 1 1;
        3 3 5 1 1;
        4 3 6 1 1;
        5 3 7 1 1;

        1 4 2 1 1;
        2 4 3 1 1;
        3 4 4 1 1;
        4 4 5 1 1;
        5 4 6 1 1;

        1 5 1 1 1;
        2 5 3 1 1;
        3 5 3 1 1;
        4 5 4 1 1;
        5 5 5 1 1;
    ];

    fis = addRule(fis, ruleList);

    %% ===== Ghi file .fis =====
    writeFIS(fis, 'FDFE.fis');
    fprintf('FIS FDFE đã được tạo và lưu thành công tại FDFE.fis\n');

    %% (Tuỳ chọn) mở GUI để kiểm tra
    % fuzzyLogicDesigner('FDFE.fis');
end
