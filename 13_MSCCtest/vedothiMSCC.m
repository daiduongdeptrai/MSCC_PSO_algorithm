% Đọc file
data = readtable('VEDOTHIMSCC.xlsx');
data2 = readtable("MSCC_results.xlsx");
disp(data.Properties.VariableNames)

t_P = data.Time_s;
t_M = data.Col1/1000;

% Thiết lập font Cambria, cỡ 14
set(groot,'defaultAxesFontName','Cambria');
set(groot,'defaultAxesFontSize',14);

% Figure chung
figure('Units','inches','Position',[1 1 10 8]);

%% Subplot 1: Điện áp
subplot(3,1,1);
plot(t_M, data.Col4/9000+0.05, 'b-', 'LineWidth', 1.5); hold on;    % Thực nghiệm (xanh, nét liền) - VẼ TRƯỚC
plot(t_P, data.Voltage_V, 'r--', 'LineWidth', 1.5);                 % Mô phỏng (đỏ, nét đứt) - VẼ SAU (HIỂN THỊ TRÊN)
xlabel('Thời gian (s)');
ylabel('Điện áp (V)');
ylim([3.68 4.25]);
legend({'Thực nghiệm','Mô phỏng'},'Location','best'); % ĐỔI THỨ TỰ LEGEND
grid on;

%% Subplot 2: Dòng điện
subplot(3,1,2);
plot(t_M, data.Col15/1000, 'b-', 'LineWidth', 1.5); hold on;        % Thực nghiệm (xanh, nét liền) - VẼ TRƯỚC
plot(t_M, data.Current_A, 'r--', 'LineWidth', 1.5);                 % Mô phỏng (đỏ, nét đứt) - VẼ SAU (HIỂN THỊ TRÊN)
xlabel('Thời gian (s)');
ylabel('Dòng điện (A)');
ylim([0 1.5]);
legend({'Thực nghiệm','Mô phỏng'},'Location','best'); % ĐỔI THỨ TỰ LEGEND
grid on;

%% Subplot 3: Dung lượng
subplot(3,1,3);
plot(t_M, data.Col2/3600 + 335, 'b-', 'LineWidth', 1.5); hold on;   % Thực nghiệm (xanh, nét liền) - VẼ TRƯỚC
plot(data.Time_s, data.Capacity_mAh, 'r--', 'LineWidth', 1.5);      % Mô phỏng (đỏ, nét đứt) - VẼ SAU (HIỂN THỊ TRÊN)
xlabel('Thời gian (s)');
ylabel('Dung lượng (mAh)');
ylim([300 1400]);
legend({'Thực nghiệm','Mô phỏng'},'Location','best'); % ĐỔI THỨ TỰ LEGEND
grid on;