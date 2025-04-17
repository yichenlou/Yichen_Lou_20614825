function temp_monitor(a)
% TEMP_MONITOR Real-time temperature monitoring and LED control system
%   Input:
%     a - Arduino object connected to temperature sensor and LEDs
%
%   Functionality:
%     1. Continuously monitors temperature and updates live plot 
%        (1-second refresh rate, displays 10-second rolling window)
%     2. Controls LEDs based on temperature ranges:
%        - 18-24°C: Green LED solid ON
%        - <18°C: Yellow LED blinks at 0.5s intervals
%        - >24°C: Red LED blinks at 0.25s intervals
%     3. Runs indefinitely until plot window is closed
%
%   Requires pre-configuration:
%     - Temperature sensor parameters (V0C/TC)
%     - LED digital pins (green/yellow/red)
%     - Arduino board connection

    V0C = 500;   % Output voltage (mV) of the sensor at 0°C
    TC = 10;     % Temperature coefficient (mV/°C)

    % Initialize the LED pins
    greenPin =  'D10'; yellowPin = 'D3'; redPin ='D6';
    configurePin(a, greenPin, 'DigitalOutput');
    configurePin(a, yellowPin, 'DigitalOutput');
    configurePin(a, redPin, 'DigitalOutput');

    % Initialize the real-time temperature curve
    fig = figure;
    h = plot(NaN, NaN);
    xlabel('Time (s)'); ylabel('Temperature (°C)');
    title('Task 2: Live Temperature Monitoring');
    startTime = tic;
    timeData = []; tempData = [];
    lastPlot = 0; lastYellow = 0; lastRed = 0;
    yellowState = 0; redState = 0;

    % Temperature reading function (reusing the logic of Task 1)
    function temp = readTemp()
        voltage = readVoltage(a, 'A1');      % Make sure to use the same pin as Task 1
        temp = (voltage * 1000 - V0C) / TC;
    end

    % major cycle
    while ishandle(fig)  % It keeps running when the window exists
        currentTime = toc(startTime);
        temp = readTemp();

        % Update the temperature curve every one second
        if currentTime - lastPlot >= 1
            timeData(end+1) = currentTime;
            tempData(end+1) = temp;
            set(h, 'XData', timeData, 'YData', tempData);
            xlim([max(0, currentTime-10), currentTime+1]);
            ylim([10 30]);
            drawnow;
            lastPlot = currentTime;
        end

        % Control the status of the LED
        if temp >= 18 && temp <= 24
            writeDigitalPin(a, greenPin, 1);  % steady green light
            writeDigitalPin(a, yellowPin, 0);
            writeDigitalPin(a, redPin, 0);
            yellowState = 0; redState = 0;
        elseif temp < 18
            if currentTime - lastYellow >= 0.5  % The yellow light flashes for 0.5 seconds
                yellowState = ~yellowState;
                writeDigitalPin(a, yellowPin, yellowState);
                lastYellow = currentTime;
            end
            writeDigitalPin(a, greenPin, 0);
            writeDigitalPin(a, redPin, 0);
        else
            if currentTime - lastRed >= 0.25  % The red light flashes for 0.25 seconds
                redState = ~redState;
                writeDigitalPin(a, redPin, redState);
                lastRed = currentTime;
            end
            writeDigitalPin(a, greenPin, 0);
            writeDigitalPin(a, yellowPin, 0);
        end
        pause(0.05);
    end
end