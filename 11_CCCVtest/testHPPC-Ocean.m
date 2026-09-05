clc; clear; close all;

% ====== Tạo vector SoC ======
SoC = linspace(0.2, 1, 200); % từ 0 đến 1, 200 điểm

% ======= OCV theo mô hình mới =======
OCVk =  85.3280036264711*SoCk^7 ...
       -377.652785291201*SoCk^6 ...
       +690.619107728521*SoCk^5 ...
       -673.258768068362*SoCk^4 ...
       +377.202565314349*SoCk^3 ...
       -121.395461640020*SoCk^2 ...
       +21.2213598876812*SoCk ...
       +2.11125864129355;

R0k  = -15.1669536832054*SoCk^7 + 62.6139150458337*SoCk^6 - 106.865246349401*SoCk^5 ...
      + 97.4927415928678*SoCk^4 - 51.2042423984942*SoCk^3 + 15.4346179902174*SoCk^2 ...
      - 2.47284712542430*SoCk + 0.176709181245320;

Rpk  = -87.9021415550243*SoCk^7 + 404.677664006282*SoCk^6 - 784.747432220392*SoCk^5 ...
      + 828.148950799065*SoCk^4 - 511.456947191732*SoCk^3 + 184.034119003167*SoCk^2 ...
      - 35.6025058183691*SoCk + 2.88009145967760;

Cpk  = 7804085.99103271*SoCk^7 - 34018371.2706896*SoCk^6 + 61378347.2808034*SoCk^5 ...
      - 59122673.8040170*SoCk^4 + 32669432.1344075*SoCk^3 - 10315776.9748510*SoCk^2 ...
      + 1722071.41280768*SoCk - 114993.092460705;

% ====== Vẽ 4 đồ thị độc lập ======
figure;

subplot(2,2,1);
plot(SoC, Cp, 'r', 'LineWidth', 1.5);
xlabel('SoC'); ylabel('C_p'); title('C_p theo SoC'); grid on;

subplot(2,2,2);
plot(SoC, Rp, 'b', 'LineWidth', 1.5);
xlabel('SoC'); ylabel('R_p'); title('R_p theo SoC'); grid on;

subplot(2,2,3);
plot(SoC, R0, 'g', 'LineWidth', 1.5);
xlabel('SoC'); ylabel('R_0'); title('R_0 theo SoC'); grid on;

subplot(2,2,4);
plot(SoC, OCV, 'm', 'LineWidth', 1.5);
xlabel('SoC'); ylabel('OCV (V)'); title('OCV theo SoC'); grid on;
