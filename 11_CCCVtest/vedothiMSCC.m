% Đọc file
data = readtable('MSCC_data.xlsx');

% Giả sử có cột: 'Time', 'Voltage_MATLAB', 'Voltage_PSIM',
%                'Current_MATLAB', 'Current_PSIM',
%                'Capacity_MATLAB', 'Capacity_PSIM'

t_M = data.TimeM;
t_P = data.TimeP;

% Điện áp
figure;
plot(t_M, data.Voltage_MATLAB, 'b', 'LineWidth', 1.5); hold on;
plot(t_P, data.Voltage_PSIM, 'r--', 'LineWidth', 1.5);
xlabel('Time (s)');
ylabel('Voltage (V)');
title('Điện áp sạc');
legend('MATLAB', 'PSIM');
grid on;

% Dòng điện
figure;
plot(t_M, data.Current_MATLAB, 'b', 'LineWidth', 1.5); hold on;
plot(t_P, data.Current_PSIM, 'r--', 'LineWidth', 1.5);
xlabel('Time (s)');
ylabel('Current (A)');
title('Dòng điện sạc');
legend('MATLAB', 'PSIM');
grid on;
ylim([0 2.2]);

% Dung lượng
figure;
plot(t_M, data.Capacity_MATLAB, 'b', 'LineWidth', 1.5); hold on;
plot(t_P, data.Capacity_PSIM, 'r--', 'LineWidth', 1.5);
xlabel('Time (s)');
ylabel('Capacity (mAh)');
title('Dung lượng sạc');
legend('MATLAB', 'PSIM');
grid on;
