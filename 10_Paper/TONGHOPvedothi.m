% Đọc file
data = readtable('TONGHOP.xlsx');

SoC_initial = data.SoC_initial;
TimeMSCCfirst = data.Time_first;
TimeMSCC = data.ChargeTime_s_MSCC;
TimeCCCV = data.ChargeTime_s_CCCV;

CapacityMSCCfirst = data.Capacity_first;
CapacityMSCC = data.Capacity_mAh_MSCC;
CapacityCCCV = data.Capacity_mAh_CCCV;

% Font mặc định Cambria + size
set(groot, 'defaultAxesFontName', 'Cambria');
set(groot, 'defaultTextFontName', 'Cambria');
set(groot, 'defaultAxesFontSize', 12);
set(groot, 'defaultLegendFontSize', 12);

% ================== ĐỒ THỊ THỜI GIAN SẠC ==================
figure(1);
plot(SoC_initial, TimeMSCC, 'k-o', 'LineWidth', 1.5, 'MarkerSize', 6); hold on;   % MSCC optimal
plot(SoC_initial, TimeCCCV, 'k--s', 'LineWidth', 1.5, 'MarkerSize', 6);          % CCCV
plot(SoC_initial, TimeMSCCfirst, 'k:*', 'LineWidth', 1.5, 'MarkerSize', 6);      % MSCC first
xlabel('Initial SoC', 'FontSize', 14);
ylabel('Charge Time (s)', 'FontSize', 14);
grid on;

% ================== ĐỒ THỊ DUNG LƯỢNG SẠC ==================
figure(2);
plot(SoC_initial, CapacityMSCC, 'k-o', 'LineWidth', 1.5, 'MarkerSize', 6); hold on;   % MSCC optimal
plot(SoC_initial, CapacityCCCV, 'k--s', 'LineWidth', 1.5, 'MarkerSize', 6);          % CCCV
plot(SoC_initial, CapacityMSCCfirst, 'k:*', 'LineWidth', 1.5, 'MarkerSize', 6);      % MSCC first
xlabel('Initial SoC', 'FontSize', 14);
ylabel('Charge Capacity (mAh)', 'FontSize', 14);
ylim([1785 1817]);
grid on;
