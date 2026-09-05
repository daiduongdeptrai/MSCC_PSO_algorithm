syms x y z h k

f = x^2 + y^2 + z^2 + h^2 + k^2 + x*y - h*k;

% Gán z, h, k = 0 để chỉ còn f(x, y)
f_xy = subs(f, [z h k], [0 0 0]);

% Tạo lưới dữ liệu
[X, Y] = meshgrid(-5:0.1:5, -5:0.1:5);
F = matlabFunction(f_xy);   % Chuyển về dạng hàm số để vẽ

Z = F(X, Y);

% Vẽ mặt hàm
figure;
surf(X, Y, Z);
xlabel('x'); ylabel('y'); zlabel('f(x,y)');
title('Đồ thị hàm f(x, y) với z=h=k=0');
shading interp; colormap jet; colorbar;


syms x y z h k

f = x^2 + y^2 + z^2 + h^2 + k^2 + x*y - h*k;

grad = gradient(f, [x y z h k]);      % Đạo hàm riêng
sol = solve(grad == 0, [x y z h k]);  % Giải hệ ∇f = 0

disp(sol);                            % Nghiệm cực trị
