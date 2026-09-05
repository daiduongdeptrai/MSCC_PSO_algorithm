% Đọc file
data = readtable('SOC=0.85.xlsx');

t_M = data.Time_s;
t_P = data.Time;

% Font mặc định Cambria + size
set(groot, 'defaultAxesFontName', 'Cambria');
set(groot, 'defaultTextFontName', 'Cambria');
set(groot, 'defaultAxesFontSize', 12);

% Vẽ Voltage + Current chung 1 hình
figure;
yyaxis left
plot(t_M, data.Voltage_V, 'b-', 'LineWidth', 1.5); hold on;   % MATLAB Voltage (xanh, liền)
plot(t_P, data.Vbatt, 'r--', 'LineWidth', 1.5);               % PSIM Voltage (đỏ, đứt)
ylabel('Voltage (V)', 'FontSize', 14);

yyaxis right
plot(t_M, data.Current_A, 'b-', 'LineWidth', 1.5);            % MATLAB Current (xanh, liền)
plot(t_P, data.Ibatt, 'r--', 'LineWidth', 1.5);               % PSIM Current (đỏ, đứt)
ylabel('Current (A)', 'FontSize', 14);
ylim([0 2.2]);

xlabel('Time (s)', 'FontSize', 14);
grid on;
