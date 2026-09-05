%data = readtable("HPPC.xlsx");
%disp(data.Properties.VariableNames); % In ra tên các cột

% Đọc dữ liệu
data = readtable("HPPC.xlsx");
time = data.Time;
current = data.Icell;
voltage = data.VCell;

% Vẽ đồ thị với hai trục tung
figure;

yyaxis left
plot(time, current, 'b-.', 'LineWidth', 1.5);
ylabel('Dòng điện (A)');
ylim([min(current)-1, max(current)+1]);  % Cài giới hạn dòng điện

yyaxis right
plot(time, voltage, 'r', 'LineWidth', 1.5);
ylabel('Điện áp (V)');
ylim([min(voltage)-0.1, max(voltage)+0.1]);  % Cài giới hạn điện áp

xlabel('Thời gian (s)');
title('Dòng điện và điện áp khi sạc xung');
grid on;
legend('Dòng điện', 'Điện áp');
