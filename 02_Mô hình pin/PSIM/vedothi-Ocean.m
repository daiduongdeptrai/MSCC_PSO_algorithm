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
ylim([min(current)-0.1, max(current)+0.1]);  
xlim([0 0.13]);

yyaxis right
plot(time, voltage, 'r', 'LineWidth', 1.5);
ylabel('Điện áp (V)');
ylim([min(voltage)-0.015, max(voltage)+0.015]);  
xlim([0 0.13]);

xlabel('Thời gian (s)');
grid on;
legend('Dòng điện', 'Điện áp');

% Ẩn toàn bộ nhãn số trên cả hai trục
set(gca,'XTickLabel',[]);  
yyaxis left;  set(gca,'YTickLabel',[]);
yyaxis right; set(gca,'YTickLabel',[]);
