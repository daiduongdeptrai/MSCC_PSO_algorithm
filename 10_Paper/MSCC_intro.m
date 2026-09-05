% ======= Vẽ nguyên lý sạc MSCC với 5 state (Cambria font, chuẩn hóa tuyến tính, nhãn to) =======
clear; clc; close all;

% Số state
n = 5;

% Các mức dòng (A)
I_pattern = [2.0 1.6 1.2 0.8 0.4];

% Thời gian mỗi state (s)
t_stage = 500;      

% Tổng thời gian
t_total = n * t_stage;

% Mảng thời gian
t = 0:1:t_total;

% Khởi tạo
I_array = zeros(size(t));
U_array = zeros(size(t));

% Điện áp cut-off
U_cutoff = 4.2;

% Điện áp khởi tạo (đầu)
U_start = 3.7;

% Thời hằng tăng (s)
tau_rise = 500;

% Cấu hình dip
max_dip_amplitude = 0.03;   
dip_duration = 1;           

for i = 1:n
    idx = (t >= (i-1)*t_stage) & (t < i*t_stage);
    t_local = t(idx) - (i-1)*t_stage;
    
    % Dòng điện bậc thang
    I_array(idx) = I_pattern(i);
    
    % Mức nền state i
    U_base = U_start + 0.05*(i-1);
    U_end  = U_cutoff;
    
    % Biên độ dip giảm dần
    dip_amplitude = max_dip_amplitude / (i*10);
    
    % Điện áp tăng mũ ban đầu
    U_temp = U_end - (U_end - U_base) * exp(-t_local / tau_rise);
    
    % ===== Chuẩn hóa tuyến tính để luôn chạm Ucutoff =====
    U_rising = U_base + (U_temp - U_temp(1)) * (U_end - U_base) / (U_temp(end) - U_temp(1));
    
    % Dip ngắn đầu state
    t_dip_idx = (t_local >= 0) & (t_local < dip_duration);
    tau_dip_decay = 1.0;
    dip_curve = zeros(size(t_local));
    dip_curve(t_dip_idx) = - dip_amplitude .* (1 - exp(-t_local(t_dip_idx)/tau_dip_decay));
    
    % Tổng điện áp
    U_array(idx) = U_rising + dip_curve;
    
    % Giảm tau_rise dần
    tau_rise = tau_rise - 50;
end


% ===== Vẽ đồ thị =====
figure;

% Thiết lập font Cambria cho toàn bộ figure
set(groot,'defaultAxesFontName','Cambria');
set(groot,'defaultTextFontName','Cambria');
set(groot,'defaultAxesFontSize',12);
set(groot,'defaultTextFontSize',12);

yyaxis left
stairs(t, I_array, 'k--', 'LineWidth', 2);   % dòng điện: đen, nét đứt
ylabel('Current (A)','Color','k');
ylim([0.3 max(I_pattern)+1]);

% ép màu trục tung bên trái thành đen
ax = gca;
ax.YColor = 'k';


% Thêm nhãn I1...I5 (màu đen)
for i = 1:n
    t_mid = (i-0.5) * t_stage;       % vị trí giữa state
    text(t_mid, I_pattern(i)+0.25, sprintf('$I_{%d}$', i), ...
         'Color','k','FontSize',14,'FontWeight','bold', ...
         'HorizontalAlignment','center','Interpreter','latex');
end

yyaxis right
plot(t, U_array, 'k-', 'LineWidth', 2);   % điện áp: đen, nét liền
ylabel('Voltage (V)','Color','k');
ylim([U_start-1 U_cutoff+0.05]);

% Thêm đường ngưỡng cutoff (đen)
yl = yline(U_cutoff, '--k', '$$U_{cutoff}$$', ...
      'FontSize',14,'FontWeight','bold','Color','k', ...
      'LabelHorizontalAlignment','left', ...
      'LabelVerticalAlignment','bottom', ...
      'Interpreter','latex');

xlabel('Time (s)','Color','k');

% Ép màu trục & nhãn số thành đen
set(gca,'YColor','k','XColor','k');

grid on;
