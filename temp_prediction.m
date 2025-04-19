function temp_prediction(a)
% TEMP_PREDICTION Monitors temperature trends and predicts future values.
%   Inputs:
%     a - Arduino object with connected thermistor (analog pin A1) and LEDs.
%
%   Functionality:
%     1. Reads thermistor voltage and calculates temperature (inline).
%     2. Computes smoothed temperature rate of change (°C/s).
%     3. Predicts temperature in 5 minutes assuming constant rate.
%     4. Prints real-time data (current temp, rate, predicted temp).
%     5. Controls LEDs: Green (stable), Red (>+4°C/min), Yellow (<-4°C/min).
%
%   Requires:
%     - Thermistor parameters (V0C = 500 mV at 0°C, TC = 10 mV/°C).
%     - LEDs on digital pins D10 (green), D6 (red), D3 (yellow).

    % Configuration
    V0C = 500;          % Thermistor voltage at 0°C (mV)
    TC = 10;            % Temperature coefficient (mV/°C)
    analogPin = 'A1';   % Thermistor analog input pin
    bufferSize = 10;    % Data buffer for smoothing (10 samples)
    rateThreshold = 4/60;  % 4°C/min in °C/s (0.0667)
    greenPin =  'D10'; yellowPin = 'D3'; redPin ='D6';
    
    % Initialize Arduino pins
    configurePin(a, greenPin, 'DigitalOutput');
    configurePin(a, redPin, 'DigitalOutput');
    configurePin(a, yellowPin, 'DigitalOutput');
    
    % Initialize data buffers
    tempBuffer = [];
    timeBuffer = [];
    startTime = tic;     % Start timer for timestamps
    
    while true
        % Read thermistor voltage and compute temperature
        voltage = readVoltage(a, analogPin);         % Read voltage (0-5V)
        currentTemp = (voltage * 1000 - V0C) / TC;   % Convert to °C
        currentTime = toc(startTime);                % Get elapsed time
        
        % Update buffers
        tempBuffer = [tempBuffer, currentTemp];
        timeBuffer = [timeBuffer, currentTime];
        
        % Trim buffers to fixed size
        if length(tempBuffer) > bufferSize
            tempBuffer = tempBuffer(end-bufferSize+1:end);
            timeBuffer = timeBuffer(end-bufferSize+1:end);
        end
        
        % Calculate smoothed rate of change (°C/s)
        if length(tempBuffer) >= 2
            dt = diff(timeBuffer);       % Time differences
            dT = diff(tempBuffer);      % Temperature differences
            rate = mean(dT ./ dt);       % Average rate over buffer
        else
            rate = 0;                    % Insufficient data
        end
        
        % Predict temperature in 5 minutes (300 seconds)
        predictedTemp = currentTemp + rate * 300;
        
        % Print results
        fprintf('Current: %.2f°C | Rate: %.4f°C/s | Predicted (5min): %.2f°C\n', ...
                currentTemp, rate, predictedTemp);
        
        % Control LEDs
        writeDigitalPin(a, greenPin, 0);  % Reset all LEDs
        writeDigitalPin(a, redPin, 0);
        writeDigitalPin(a, yellowPin, 0);
        
        if rate > rateThreshold
            writeDigitalPin(a, redPin, 1);  % Heating too fast
        elseif rate < -rateThreshold
            writeDigitalPin(a, yellowPin, 1);  % Cooling too fast
        else
            writeDigitalPin(a, greenPin, 1);   % Stable
        end
        
        pause(1);  % Sampling interval (1 second)
    end
end