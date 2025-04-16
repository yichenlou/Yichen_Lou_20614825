% Yichen LOU
% ssyyl67@nottingham.edu.cn

%% PRELIMINARY TASK - ARDUINO AND GIT INSTALLATION [10 MARKS]

% Initialize Arduino
a = arduino('COM6', 'Uno'); % Replace 'COM6' with your port

% Blink LED on pin D3
for i = 1:10
    writeDigitalPin(a, 'D6', 1); % Turn LED on
    pause(0.5);                  % Wait 0.5 seconds
    writeDigitalPin(a, 'D6', 0); % Turn LED off
    pause(0.5);                  % Wait 0.5 seconds
end

%% TASK 1 - READ TEMPERATURE DATA, PLOT, AND WRITE TO A LOG FILE [20 MARKS]
% 数据采集
V0C = 500;
TC=10;
duration = 600;
time = 0:1:duration;
temperature = zeros(size(time));
for i = 1:length(time)
    voltage = readVoltage(a, 'A1'); % 假设连接到A1引脚，需根据实际修改
    temperature(i) = (voltage*1000 - V0C) / TC; % 根据传感器文档确定V0°C和TC
end
% 计算统计量
minTemp = min(temperature);
maxTemp = max(temperature);
avgTemp = mean(temperature);
% 绘图
figure;
plot(time, temperature);
xlabel('Time (s)');
ylabel('Temperature (°C)');
% 屏幕输出
dataLogStart = datestr(now, 'dd/mm/yyyy');
location = 'Nottingham';
fprintf('Data logging initiated - %s\n', dataLogStart);
fprintf('Location - %s\n\n', location);
for i = 0:10
    fprintf('Minute%d\n', i);
    fprintf('Temperature %.2f C\n\n', temperature(i + 1));
end
fprintf('Max temp%.2f C\n', maxTemp);
fprintf('Min temp%.2f C\n', minTemp);
fprintf('Average temp%.2f C\n', avgTemp);
fprintf('Data logging terminated\n');
% 文件写入
fileID = fopen('cabin_temperature.txt', 'w');
fprintf(fileID, 'Data logging initiated - %s\n', dataLogStart);
fprintf(fileID, 'Location - %s\n\n', location);
for i = 0:10
    fprintf(fileID, 'Minute%d\n', i);
    fprintf(fileID, 'Temperature %.2f C\n\n', temperature(i + 1));
end
fprintf(fileID, 'Max temp%.2f C\n', maxTemp);
fprintf(fileID, 'Min temp%.2f C\n', minTemp);
fprintf(fileID, 'Average temp%.2f C\n', avgTemp);
fprintf(fileID, 'Data logging terminated\n');
fclose(fileID);
%% TASK 2 - LED TEMPERATURE MONITORING DEVICE IMPLEMENTATION [25 MARKS]
V0C = 500;       % 传感器在0°C时的输出电压（mV）
TC = 10;         % 温度系数（mV/°C）
greenPin = 'D10';    % 绿灯引脚
yellowPin = 'D3';  % 黄灯引脚
redPin = 'D6';     % 红灯引脚

% 配置Arduino引脚
configurePin(a, greenPin, 'DigitalOutput');
configurePin(a, yellowPin, 'DigitalOutput');
configurePin(a, redPin, 'DigitalOutput');

% 初始化实时温度曲线
fig = figure;
h = plot(NaN, NaN);
xlabel('Time (s)'); 
ylabel('Temperature (°C)');
title('Task 2: Live Temperature Monitoring');
startTime = tic;
timeData = [];
tempData = [];
lastPlot = 0; 
lastYellow = 0; 
lastRed = 0;
yellowState = 0; 
redState = 0;

% 主循环（直接嵌入脚本）
while ishandle(fig)
    currentTime = toc(startTime);
    
    % 读取温度（复用 Task 1 的逻辑）
    voltage = readVoltage(a, 'A1');
    temp = (voltage * 1000 - V0C) / TC;
    
    % 每1秒更新温度曲线
    if currentTime - lastPlot >= 1
        timeData(end+1) = currentTime;
        tempData(end+1) = temp;
        set(h, 'XData', timeData, 'YData', tempData);
        xlim([max(0, currentTime-10), currentTime+1]);
        ylim([10 30]);
        drawnow;
        lastPlot = currentTime;
    end
    
    % 控制LED状态
    if temp >= 18 && temp <= 24
        writeDigitalPin(a, greenPin, 1);  % 绿灯常亮
        writeDigitalPin(a, yellowPin, 0);
        writeDigitalPin(a, redPin, 0);
        yellowState = 0; 
        redState = 0;
    elseif temp < 18
        % 黄灯0.5秒闪烁
        if currentTime - lastYellow >= 0.5
            yellowState = ~yellowState;
            writeDigitalPin(a, yellowPin, yellowState);
            lastYellow = currentTime;
        end
        writeDigitalPin(a, greenPin, 0);
        writeDigitalPin(a, redPin, 0);
    else
        % 红灯0.25秒闪烁
        if currentTime - lastRed >= 0.25
            redState = ~redState;
            writeDigitalPin(a, redPin, redState);
            lastRed = currentTime;
        end
        writeDigitalPin(a, greenPin, 0);
        writeDigitalPin(a, yellowPin, 0);
    end
    pause(0.05);
end


%% TASK 3 - ALGORITHMS – TEMPERATURE PREDICTION [25 MARKS]

% Insert answers here


%% TASK 4 - REFLECTIVE STATEMENT [5 MARKS]

% Insert answers here