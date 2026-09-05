% Đọc file
data = readtable('SOC=0.0.xlsx');

t_M = data.Time_s;
t_P = data.Time;

% Font mặc định Cambria + size
set(groot, 'defaultAxesFontName', 'Cambria');
set(groot, 'defaultTextFontName', 'Cambria');
set(groot, 'defaultAxesFontSize', 12);
set(groot, 'defaultLegendFontSize', 12);

% Tạo figure khung chữ nhật ngang
figure('Position', [200 200 900 600]);

%% Subplot 1: Voltage
subplot(3,1,1);
plot(t_M, data.Voltage_V, 'b', 'LineWidth', 1.5); hold on;
plot(t_P, data.Vbatt, 'r--', 'LineWidth', 1.5);
xlabel('Time (s)', 'FontSize', 12);
ylabel('Voltage (V)', 'FontSize', 12);
legend('MATLAB', 'PSIM', 'Location', 'northwest');
grid on; box on;

% Tính sai số lớn nhất (Voltage)
[V_maxErr, V_tAtMax, V_idx] = compute_max_error(t_M, data.Voltage_V, t_P, data.Vbatt);
fprintf('Voltage: max abs error = %.4f V at t = %.2f s\n', V_maxErr, V_tAtMax);
% Đánh dấu trên đồ thị
plot(V_tAtMax, data.Voltage_V(V_idx), 'kp', 'MarkerFaceColor', 'y', 'MarkerSize', 9);
txt = sprintf('Max err = %.3f V', V_maxErr);
text(V_tAtMax, data.Voltage_V(V_idx) + 0.02*range(data.Voltage_V), txt, ...
    'FontName','Cambria','FontSize',10,'HorizontalAlignment','center');

%% Subplot 2: Current
subplot(3,1,2);
plot(t_M, data.Current_A, 'b', 'LineWidth', 1.5); hold on;
plot(t_P, data.Ibatt, 'r--', 'LineWidth', 1.5);
xlabel('Time (s)', 'FontSize', 12);
ylabel('Current (A)', 'FontSize', 12);
legend('MATLAB', 'PSIM', 'Location', 'northwest');
grid on; box on;
ylim([0 2.2]);

% Tính sai số lớn nhất (Current)
[I_maxErr, I_tAtMax, I_idx] = compute_max_error(t_M, data.Current_A, t_P, data.Ibatt);
fprintf('Current: max abs error = %.4f A at t = %.2f s\n', I_maxErr, I_tAtMax);
% Đánh dấu trên đồ thị
plot(I_tAtMax, data.Current_A(I_idx), 'kp', 'MarkerFaceColor', 'y', 'MarkerSize', 9);
txt = sprintf('Max err = %.3f A', I_maxErr);
text(I_tAtMax, data.Current_A(I_idx) + 0.02*range(data.Current_A), txt, ...
    'FontName','Cambria','FontSize',10,'HorizontalAlignment','center');

%% Subplot 3: Capacity
subplot(3,1,3);
plot(t_M, data.Capacity_mAh, 'b', 'LineWidth', 1.5); hold on;
plot(t_P, data.Q, 'r--', 'LineWidth', 1.5);
xlabel('Time (s)', 'FontSize', 12);
ylabel('Capacity (mAh)', 'FontSize', 12);
legend('MATLAB', 'PSIM', 'Location', 'northwest');
grid on; box on;

% Tính sai số lớn nhất (Capacity)
[Q_maxErr, Q_tAtMax, Q_idx] = compute_max_error(t_M, data.Capacity_mAh, t_P, data.Q);
fprintf('Capacity: max abs error = %.4f mAh at t = %.2f s\n', Q_maxErr, Q_tAtMax);
% Đánh dấu trên đồ thị
plot(Q_tAtMax, data.Capacity_mAh(Q_idx), 'kp', 'MarkerFaceColor', 'y', 'MarkerSize', 9);
txt = sprintf('Max err = %.3f mAh', Q_maxErr);
text(Q_tAtMax, data.Capacity_mAh(Q_idx) + 0.02*range(data.Capacity_mAh), txt, ...
    'FontName','Cambria','FontSize',10,'HorizontalAlignment','center');

%% Hàm phụ: compute_max_error (phiên bản robust)
function [maxErr, tAtMax, idxAtMax] = compute_max_error(t_ref, y_ref, t_other, y_other)
    % Chuyển về vector cột
    t_ref = t_ref(:);
    y_ref = y_ref(:);
    t_other = t_other(:);
    y_other = y_other(:);

    % Loại bỏ các điểm không hữu hạn
    valid_ref = isfinite(t_ref) & isfinite(y_ref);
    valid_other = isfinite(t_other) & isfinite(y_other);
    t_ref = t_ref(valid_ref);
    y_ref = y_ref(valid_ref);
    t_other = t_other(valid_other);
    y_other = y_other(valid_other);

    % Nếu không còn dữ liệu hợp lệ -> trả NaN
    if isempty(t_ref) || isempty(t_other)
        maxErr = NaN; tAtMax = NaN; idxAtMax = NaN;
        return;
    end

    % Đảm bảo t_other là độc nhất và tăng dần (required by interp1)
    [t_other_u, ia] = unique(t_other, 'stable');  % 'stable' giữ thứ tự gần nhất
    y_other_u = y_other(ia);

    % Nếu sau khi unique còn ít hơn 2 điểm thì không thể nội suy tuyến tính
    if numel(t_other_u) < 2
        % fallback: so sánh trung bình hoặc trả NaN
        % Ở đây trả NaN để bạn biết không đủ điểm để nội suy
        maxErr = NaN; tAtMax = NaN; idxAtMax = NaN;
        return;
    end

    % Xác định vùng giao nhau giữa t_ref và t_other_u
    t_min = max(min(t_ref), min(t_other_u));
    t_max = min(max(t_ref), max(t_other_u));
    if t_min > t_max
        % Không có vùng giao nhau: bạn có thể chọn extrapolate hoặc trả NaN.
        % Mặc định ở đây sẽ dùng extrapolation nhưng an toàn hơn là trả NaN.
        % Để bật extrapolation, uncomment dòng bên dưới:
        % y_other_interp = interp1(t_other_u, y_other_u, t_ref, 'linear', 'extrap');
        maxErr = NaN; tAtMax = NaN; idxAtMax = NaN;
        return;
    end

    % Chỉ tính cho các điểm t_ref trong vùng giao nhau
    idxOverlap = (t_ref >= t_min) & (t_ref <= t_max);
    if ~any(idxOverlap)
        maxErr = NaN; tAtMax = NaN; idxAtMax = NaN;
        return;
    end

    t_ref_sub = t_ref(idxOverlap);

    % Nội suy giá trị của y_other tại các thời điểm t_ref_sub
    y_other_interp_sub = interp1(t_other_u, y_other_u, t_ref_sub, 'linear');

    % Tính sai số tuyệt đối trên vùng giao nhau
    abs_err_sub = abs(y_ref(idxOverlap) - y_other_interp_sub);

    % Tìm max
    [maxErr, relIdx] = max(abs_err_sub);
    % Chuyển relIdx về index trong t_ref
    overlapIndices = find(idxOverlap);
    idxAtMax = overlapIndices(relIdx);
    tAtMax = t_ref(idxAtMax);
end
