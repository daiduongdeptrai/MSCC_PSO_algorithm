#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <float.h>
#include <time.h>

// Hằng số
#define NUM_PARTICLES 50       // Số lượng hạt
#define MAX_ITER 100           // Số lần lặp tối đa
#define NUM_STAGES 5           // Số bước sạc
#define VOLTAGE_LIMIT 4.25     // Điện áp giới hạn

// Biến toàn cục cho giá trị tham chiếu CCCV
double CCCV_Time;              // Thời gian sạc CCCV
double CCCV_Capacity;          // Dung lượng sạc CCCV

// Khai báo hàm
double objective(double charge_rates[]);
void pso(double (*objective)(double[]), double lb[], double ub[], int maxiter, int swarmsize);

// Các hàm mô hình - cần triển khai đầy đủ
double my_ocv(double sto) {
    return 38.946323 * pow(sto,7) - 184.228 * pow(sto,6) + 347.502 * pow(sto,5) 
           - 340.714 * pow(sto,4) + 188.186 * pow(sto,3) - 57.9195 * pow(sto,2) 
           + 9.56253 * sto + 2.89585;
}

double my_r0(double T_cell, double current, double soc) {
    return -0.331260 * pow(soc,7) + 1.15678 * pow(soc,6) - 1.76464 * pow(soc,5) 
           + 1.6795 * pow(soc,4) - 1.12976 * pow(soc,3) + 0.507487 * pow(soc,2) 
           - 0.130493 * soc + 0.0393675;
}

// Hàm PSO chính
void pso(double (*objective)(double[]), double lb[], double ub[], int maxiter, int swarmsize) {
    int num_dimensions = NUM_STAGES;
    double swarm[NUM_PARTICLES][NUM_STAGES];
    double swarm_velocity[NUM_PARTICLES][NUM_STAGES] = {0};
    double pbest[NUM_PARTICLES][NUM_STAGES];
    double pbest_cost[NUM_PARTICLES];
    double gbest[NUM_STAGES];
    double gbest_cost = DBL_MAX;
    
    // Khởi tạo đàn hạt
    srand(time(NULL));
    for (int i = 0; i < swarmsize; i++) {
        for (int j = 0; j < num_dimensions; j++) {
            swarm[i][j] = lb[j] + (ub[j] - lb[j]) * ((double)rand() / RAND_MAX);
            pbest[i][j] = swarm[i][j];
        }
        pbest_cost[i] = objective(pbest[i]);
        if (pbest_cost[i] < gbest_cost) {
            gbest_cost = pbest_cost[i];
            for (int j = 0; j < num_dimensions; j++) {
                gbest[j] = pbest[i][j];
            }
        }
    }
    
    // Vòng lặp chính PSO
    for (int iter = 0; iter < maxiter; iter++) {
        printf("Lần lặp %d: Chi phí tốt nhất = %f\n", iter, gbest_cost);
        
        for (int i = 0; i < swarmsize; i++) {
            for (int j = 0; j < num_dimensions; j++) {
                double r1 = (double)rand() / RAND_MAX;
                double r2 = (double)rand() / RAND_MAX;
                
                // Cập nhật vận tốc
                swarm_velocity[i][j] += 2 * r1 * (pbest[i][j] - swarm[i][j]) 
                                      + 2 * r2 * (gbest[j] - swarm[i][j]);
                
                // Cập nhật vị trí
                swarm[i][j] += swarm_velocity[i][j];
                
                // Giới hạn giá trị
                if (swarm[i][j] < lb[j]) swarm[i][j] = lb[j];
                if (swarm[i][j] > ub[j]) swarm[i][j] = ub[j];
            }
            
            double current_cost = objective(swarm[i]);
            if (current_cost < pbest_cost[i]) {
                pbest_cost[i] = current_cost;
                for (int j = 0; j < num_dimensions; j++) {
                    pbest[i][j] = swarm[i][j];
                }
                
                if (current_cost < gbest_cost) {
                    gbest_cost = current_cost;
                    for (int j = 0; j < num_dimensions; j++) {
                        gbest[j] = pbest[i][j];
                    }
                }
            }
        }
    }
    
    printf("Tốc độ sạc tối ưu:");
    for (int i = 0; i < NUM_STAGES; i++) {
        printf(" %.4f", gbest[i]);
    }
    printf("\nTổng thời gian sạc: %.2f\n", gbest_cost);
}

double objective(double charge_rates[]) {
    // Kiểm tra ràng buộc thứ tự tốc độ sạc
    for (int i = 0; i < NUM_STAGES-1; i++) {
        if (charge_rates[i] <= charge_rates[i+1]) {
            return DBL_MAX;
        }
    }
    
    // Kiểm tra giới hạn giá trị
    for (int i = 0; i < NUM_STAGES; i++) {
        if (charge_rates[i] < 0.05 || charge_rates[i] > 1.0) {
            return DBL_MAX;
        }
    }
    
    // Trong triển khai thực cần gọi mô phỏng pin ở đây
    // Tạm thời trả về giá trị mẫu
    return 0.0;
}

int main() {
    // Khởi tạo giá trị tham chiếu CCCV
    CCCV_Time = 3600.0;    // Giá trị ví dụ - từ mô phỏng thực tế
    CCCV_Capacity = 2.0;   // Giá trị ví dụ
    
    // Thiết lập giới hạn
    double lb[NUM_STAGES] = {0.05, 0.05, 0.05, 0.05, 0.05};  // Giới hạn dưới
    double ub[NUM_STAGES] = {1.0, 1.0, 1.0, 1.0, 1.0};       // Giới hạn trên
    
    // Chạy thuật toán PSO
    pso(objective, lb, ub, MAX_ITER, NUM_PARTICLES);
    
    return 0;
}