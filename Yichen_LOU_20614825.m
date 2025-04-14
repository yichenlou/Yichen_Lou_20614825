% Yichen LOU
% ssyyl67@nottingham.edu.cn

%% PRELIMINARY TASK - ARDUINO AND GIT INSTALLATION [10 MARKS]

% Initialize Arduino
%a = arduino('COM6', 'Uno'); % Replace 'COM6' with your port

% Blink LED on pin D3
for i = 1:10
    writeDigitalPin(a, 'D6', 1); % Turn LED on
    pause(0.5);                  % Wait 0.5 seconds
    writeDigitalPin(a, 'D6', 0); % Turn LED off
    pause(0.5);                  % Wait 0.5 seconds
end

%% TASK 1 - READ TEMPERATURE DATA, PLOT, AND WRITE TO A LOG FILE [20 MARKS]

%% TASK 2 - LED TEMPERATURE MONITORING DEVICE IMPLEMENTATION [25 MARKS]

% Insert answers here


%% TASK 3 - ALGORITHMS – TEMPERATURE PREDICTION [25 MARKS]

% Insert answers here


%% TASK 4 - REFLECTIVE STATEMENT [5 MARKS]

% Insert answers here