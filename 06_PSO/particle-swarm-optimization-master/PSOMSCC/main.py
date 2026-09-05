import random
import numpy as np
import pybamm 
import matplotlib.pyplot as plt


def objective(charge_rates):
    global CCCV_Time, CCCV_Capacity
    alpha = 0.9
    beta = 1 - alpha
    #charge_rates = np.append(charge_rates, 0.1)
    # Làm tròn các giá trị của charge_rates đến 4 chữ số sau dấu phẩy
    charge_rates_rounded = [round(rate, 4) for rate in charge_rates]
    # Kiểm tra điều kiện ràng buộc
    if not (1 >= charge_rates_rounded[0] > charge_rates_rounded[1] > charge_rates_rounded[2] > charge_rates_rounded[3] > charge_rates_rounded[4] > 0.05):
        return float("inf")  # Trả về float("inf") nếu điều kiện không được thỏa mãn

    #Tạo đối tượng sạc MSCC
    ecm_experiment = pybamm.Experiment(generate_charge_experiment(charge_rates_rounded, voltage_limit)) #Mô phỏng các bước sạc pin
    ecm_sim = pybamm.Simulation(ecm_model, experiment=ecm_experiment, parameter_values=ecm_parameter_values) #Khởi tạo mô phỏng ECM
    ecm_sim.solve()
    ecm_t = ecm_sim.solution["Time [s]"].data #Lấy thời gian từ mô phỏng
    ecm_capacity = ecm_sim.solution["Throughput capacity [A.h]"].data #Lấy dung lượng từ mô phỏng
    time = ecm_t[-1] #Thời gian cuối cùng trong mô phỏng MSCC
    cap = ecm_capacity[-1] #Dung lượng cuối cùng trong mô phỏng MSCC

    if cap < CCCV_Capacity:
        return float("inf")  # Trả về vô cùng nếu ràng buộc không được thỏa mãn

    func = alpha * (time - CCCV_Time) / CCCV_Time + beta * (CCCV_Capacity - cap)/CCCV_Capacity

    return func



# Các biến cho mô hình pybamm
ecm_options = {"operating mode": "Current", "number of rc elements": "1", "calculate discharge energy": "false"}
ecm_model = pybamm.lithium_ion.SPM()
ecm_parameter_values = pybamm.ParameterValues("Marquis2019")

# Cập nhật các hàm tính toán tham số mô hình
def my_ocv(sto):
    return 38.946323 * sto**7  -184.228 * sto**6  +347.502 * sto**5  -340.714 * sto**4  +188.186 * sto**3  -57.9195 * sto**2  +9.56253 * sto**1  +2.89585
def my_r0(T_cell, current, soc):
    return -0.331260 * soc ** 7  +1.15678 * soc ** 6  -1.76464 * soc ** 5  +1.6795 * soc ** 4  -1.12976 * soc ** 3  +0.507487 * soc ** 2  -0.130493 * soc ** 1  +0.0393675 #95%

def my_r1(T_cell, current, soc):
    return -5.780202 * soc**7  +21.7101 * soc**6  -31.9571 * soc**5  +23.4142 * soc**4  -9.17136 * soc**3  +2.07482 * soc**2  -0.318199 * soc**1  +0.0476203

def my_c1(T_cell, current, soc):
    return (
          108.577 * soc**0
        - 1530.06 * soc**1
        + 44855.0 * soc**2
        - 111442.0 * soc**3
        - 2435.39 * soc**4
        + 277933.0 * soc**5
        - 311338.0 * soc**6
        + 104890.0 * soc**7
    )

def my_dUdT(ocv, T_cell):
    return 0

ecm_parameter_values.update(
    {
        "Cell capacity [A.h]": 2,
        "Nominal cell capacity [A.h]": 2,
        "Current function [A]": 2,
        "Initial SoC": 0,
        "Lower voltage cut-off [V]": 2.5,
        "Upper voltage cut-off [V]": 4.2,
        "Open-circuit voltage [V]": my_ocv,
        "R0 [Ohm]": my_r0,
        "R1 [Ohm]": my_r1,
        "C1 [F]": my_c1,
        "Entropic change [V/K]": my_dUdT,
        "Maximum concentration in negative electrode [mol.m-3]": 3.0e4,  # Giá trị mẫu
        "Maximum concentration in positive electrode [mol.m-3]": 5.0e4,  # Giá trị mẫu
        "Negative electrode diffusivity [m2.s-1]": 1e-14,  # Giá trị mẫu
        "Positive electrode diffusivity [m2.s-1]": 1e-14,  # Giá trị mẫu
        "Number of electrodes connected in parallel to make a cell": 1,  # Example value
    },
    check_already_exists=False  # Bỏ qua kiểm tra tham số đã tồn tại
)







def generate_charge_experiment(charge_rates, voltage_limit):
    charge_experiment = []
    for rate in charge_rates:
        charge_experiment.append(
            f"Charge at {rate:.4f}C until {voltage_limit}V"
        )
    return charge_experiment






# Thiết lập các tham số cho việc tối ưu hóa
charge_rates = [1, 0.8, 0.6, 0.5, 0.2]  # Giả sử các tốc độ sạc ban đầu
voltage_limit = 4.25  # Điện áp giới hạn
num_particles = 50  # Số lượng hạt trong PSO
max_iter = 100  # Số lần lặp tối đa
CCCV_experiment = pybamm.Experiment(  #Tạo đối tượng sạc CCCV
    [
        (
            "Charge at 2A until 4.2V",
            "Hold at 4.2V until 0.05A",
        )
    ]
)

CCCV_sim = pybamm.Simulation(ecm_model, experiment=CCCV_experiment, parameter_values=ecm_parameter_values)
CCCV_sim.solve()
CCCV_t = CCCV_sim.solution["Time [s]"].data #Lấy thời gian từ mô phỏng CCCV
CCCV_capacity = CCCV_sim.solution["Throughput capacity [A.h]"].data #Lấy dung lượng từ mô phỏng CCCV
#Lấy thời gian và dung lượng cuối cùng trong mô phỏng CCCV
CCCV_Time = CCCV_t[-1]
CCCV_Capacity = CCCV_capacity[-1]










# Thiết lập giới hạn cho các tốc độ sạc
lb = [0.05, 0.05, 0.05, 0.05, 0.05]
# lb = [0.25, 0.25, 0.25, 0.25, 0.25]
ub = [1, 1, 1, 1, 1]

# Tối ưu hóa bằng PSO
def pso(objective, lb, ub, maxiter, swarmsize):
    num_dimensions = len(lb)
    swarm = np.random.uniform(low=lb, high=ub, size=(swarmsize, num_dimensions))
    swarm_velocity = np.zeros_like(swarm)
    pbest = np.copy(swarm)
    pbest_cost = np.array([objective(p) for p in pbest])
    gbest = np.copy(pbest[np.argmin(pbest_cost)])
    gbest_cost = pbest_cost[np.argmin(pbest_cost)]
    gbest_costs = [gbest_cost]
    
    for _ in range(maxiter): #Kiểm tra từng hạt trong bầy
        print(f"Generation {_}: Best cost = {gbest_cost}, Best charge rates = {gbest}")
        for i in range(swarmsize):
            r1, r2 = np.random.rand(), np.random.rand()
            swarm_velocity[i] = ( #Cập nhật vận tốc của hạt
                swarm_velocity[i]
                + 2 * r1 * (pbest[i] - swarm[i]) #swarm[i] là vị trí hiện tại của hạt
                + 2 * r2 * (gbest - swarm[i])
            )
            swarm[i] = swarm[i] + swarm_velocity[i] #Cập nhật vị trí của hạt
            swarm[i] = np.clip(swarm[i], lb, ub) #Giới hạn vị trí của hạt trong khoảng [lb, ub]
            #Cập nhật vị trí tốt nhất cá nhân và toàn bầy
            if objective(swarm[i]) < pbest_cost[i]:
                pbest[i] = swarm[i]
                pbest_cost[i] = objective(swarm[i])
                if pbest_cost[i] < gbest_cost:
                    gbest = pbest[i]
                    gbest_cost = pbest_cost[i]
        gbest_costs.append(gbest_cost)
    return gbest, gbest_cost, gbest_costs

best_charge_rates, best_charge_time, gbest_costs = pso(objective, lb, ub, max_iter, num_particles)

# In kết quả tối ưu
print("Optimized charge rates:", best_charge_rates)
print("Total charge time:", best_charge_time)