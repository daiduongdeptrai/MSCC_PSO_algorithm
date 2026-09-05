fis = readfis('FDFE.fis');
inputs = [89 85];   
outputs = evalfis(fis , inputs);
disp(outputs)