data = readtable('uart_logSOC=0.2.xlsx');
time = data.Col1;
Vcell2 = data.Col5;

% Lọc bằng Savitzky–Golay
frameSize = 151;   % kích thước cửa sổ (lẻ, càng lớn càng mượt)
polyOrder = 3;     % bậc đa thức
Vcell2_sgolay = sgolayfilt(Vcell2, polyOrder, frameSize);

% Vẽ
figure;
plot(time, Vcell2, 'b:', 'DisplayName','Gốc'); hold on;
plot(time, Vcell2_sgolay, 'r-', 'LineWidth',1.5, 'DisplayName','Mượt SG');
xlabel('Time (s)'); ylabel('Vcell2 (V)');
legend('show'); grid on;
title('Lọc mượt dữ liệu Vcell2 bằng Savitzky–Golay');
