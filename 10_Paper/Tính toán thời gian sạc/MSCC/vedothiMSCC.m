% Đọc file
data = readtable('SOC=0.0.xlsx');

% Hiển thị tên các cột
disp(data.Properties.VariableNames)

% Font mặc định Cambria + size
set(groot, 'defaultAxesFontName', 'Cambria');
set(groot, 'defaultTextFontName', 'Cambria');
set(groot, 'defaultAxesFontSize', 14);
set(groot, 'defaultLegendFontSize', 14);

% Tạo figure với 3 subplot
figure('Position', [100, 100, 1000, 800]);

% Voltage - subplot 1
subplot(3,1,1);
plot(data.Time_s, data.Voltage_V, 'b', 'LineWidth', 1.5); hold on;
plot(data.Time, data.Vbatt, 'r--', 'LineWidth', 1.5);
ylabel('Voltage (V)', 'FontSize', 14);
legend('MATLAB', 'PSIM', 'Location', 'northwest');
grid on;
ylim([3.6 4.3]);

% Current - subplot 2
subplot(3,1,2);
plot(data.Time_s, data.Current_A, 'b', 'LineWidth', 1.5); hold on;
plot(data.Time, data.Ibatt, 'r--', 'LineWidth', 1.5);
ylabel('Current (A)', 'FontSize', 14);
legend('MATLAB', 'PSIM', 'Location', 'northwest');
grid on;
ylim([0 1.35]);

% Capacity - subplot 3
subplot(3,1,3);
plot(data.Time_s, data.Capacity_mAh, 'b', 'LineWidth', 1.5); hold on;
plot(data.Time, data.Q, 'r--', 'LineWidth', 1.5);
xlabel('Time (s)', 'FontSize', 14);
ylabel('Capacity (mAh)', 'FontSize', 14);
legend('MATLAB', 'PSIM', 'Location', 'northwest');
grid on;
ylim([0 1350]);

% Căn chỉnh layout
set(gcf, 'Color', 'w'); % Nền trắng