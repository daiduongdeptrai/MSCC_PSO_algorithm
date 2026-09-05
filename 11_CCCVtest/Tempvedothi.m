% Đọc file, giữ nguyên tên cột
data = readtable('Tempcompare.xlsx','VariableNamingRule','preserve');
disp(data.Properties.VariableNames);

t_CCCV    = data.PhutCCCV;
t_MSCC    = data.PhutMSCC;
temp_CCCV = data.TempCCCV+3;
temp_MSCC = data.TempMSCC+3;

% ===== Loại bỏ NaN =====
idx_CCCV = ~isnan(t_CCCV) & ~isnan(temp_CCCV);
t_CCCV    = t_CCCV(idx_CCCV);
temp_CCCV = temp_CCCV(idx_CCCV);

idx_MSCC = ~isnan(t_MSCC) & ~isnan(temp_MSCC);
t_MSCC    = t_MSCC(idx_MSCC);
temp_MSCC = temp_MSCC(idx_MSCC);

% ===== Nội suy spline trong khoảng dữ liệu =====
tq_CCCV = linspace(t_CCCV(1), t_CCCV(end), 200);
tq_MSCC = linspace(t_MSCC(1), t_MSCC(end), 200);

tempq_CCCV = interp1(t_CCCV, temp_CCCV, tq_CCCV, 'spline');
tempq_MSCC = interp1(t_MSCC, temp_MSCC, tq_MSCC, 'spline');

% Thiết lập font mặc định cho figure hiện tại (Cambria, size 12)
set(groot, 'defaultAxesFontName', 'Cambria');
set(groot, 'defaultTextFontName', 'Cambria');
set(groot, 'defaultAxesFontSize', 12);
set(groot, 'defaultLegendFontSize', 12);

figure('Color','w');   % nền trắng
hold on;

% --- CCCV ---
h1 = plot(tq_CCCV, tempq_CCCV, 'r-', 'LineWidth', 1.5);
h2 = plot(t_CCCV, temp_CCCV, 'ro', 'MarkerSize', 5);
hCCCV = hggroup;  
set([h1 h2],'Parent',hCCCV);   % gom cả line + marker vào group

% --- MSCC ---
h3 = plot(tq_MSCC, tempq_MSCC, 'b-', 'LineWidth', 1.5);
h4 = plot(t_MSCC, temp_MSCC, 'bs', 'MarkerSize', 5);
hMSCC = hggroup;  
set([h3 h4],'Parent',hMSCC);   % gom cả line + marker vào group

% Nhãn trục với font Cambria size 12
xlabel('Thời gian (phút)', 'FontName', 'Cambria', 'FontSize', 12); 
ylabel('Nhiệt độ (°C)', 'FontName', 'Cambria', 'FontSize', 12);

% BỎ title theo yêu cầu (không gọi title)

xlim([0 55])

% Legend với font Cambria size 12
lg = legend([hCCCV hMSCC], {'CCCV','MSCC'}, 'Location','best');
set(lg, 'FontName', 'Cambria', 'FontSize', 12);

% Đảm bảo ticks & axis dùng Cambria size 12
ax = gca;
ax.FontName = 'Cambria';
ax.FontSize = 12;
ax.LineWidth = 1.0;    % dày trục chính hơn để viền rõ
grid on;

% ===== CÁCH A: bật box (viền theo trục) =====
ax.Box = 'on';        % bật viền 4 cạnh

hold off;
