global key
control = 0;
yellow = 0;
blue = 0;
green = 0;

% Define the minimum distance threshold (in centimeters)
distanceRight = 3.1;


% Define the color sensor port
colorSensorPort = 3; % Updqate if your color sensor port is different

% Define the yellow color code (you will need to calibrate this based on your sensor and colors)
yellowColorCode = 4; % LEGO color sensors return 4 for yellow, but calibrate as needed
redColorCode = 5;
greenColorCode = 3;
blueColorCode = 2;

% Define the touch sensor port
touchSensorFrontPort = 4; % Update if your touch sensor port is different

while true  % Infinite loop until the kill switch is activated.
    % Kill switch check using the touch sensor.
    disp(brick.UltrasonicDist(2));
    touch = brick.TouchPressed(1);  % Read the touch sensor connected to port 1.
    if touch
        brick.beep();  % Beep if the sensor was touched.
        break;  % End the loop and stop the program.
    end

    if control
  
    InitKeyboard();
  
       while 1
           pause(0.1);
           switch key
               case 'uparrow'
                   disp('Up');
                   brick.MoveMotor('A', 20);
                   brick.MoveMotor('C', 20);
               case 'downarrow'
                   disp('Down');
                   brick.MoveMotor('A', -20);
                   brick.MoveMotor('C', -20);
               case 'leftarrow'
                   disp('Left');
                   brick.MoveMotor('A', 20);
                   brick.MoveMotor('C', -20);
               case 'rightarrow'
                   disp('Right');
                   brick.MoveMotor('A', -20);
                   brick.MoveMotor('C', 20);
               case 0
                   disp('No key')
                   brick.StopMotor('ACD', 'Brake');
               case 'u'
                   brick.MoveMotor('D', -5);
               case 'd'
                   brick.MoveMotor('D', 5);
               case 'q'
                   control = 0;
                   break;
           end
       end
       CloseKeyboard();
    end


    % Front collision detection using the front touch sensor.
    touchFront = brick.TouchPressed(touchSensorFrontPort);
    if touchFront
        % Reverse a bit if the front sensor is pressed.
        brick.MoveMotor('A', -50);
        brick.MoveMotor('C', -60);
        pause(0.9);

        % Check right side for walls.
        distanceRight = brick.UltrasonicDist(2);
        if distanceRight >= maximumDistanceThreshold
            % Turn left if there's a wall to the right.
            brick.MoveMotor('A', 40);
            brick.MoveMotor('C', -70);
            pause(1);
        else
            % If no wall to the right, adjust the course slightly right before moving forward again.
            brick.MoveMotor('A', -30);
            brick.MoveMotor('C', 30);
            pause(1);
        end
        continue;
    end

    

    % Short pause for better control over loop execution time.
    pause(0.1);  % Adjust as necessary for smoother operation.
    

    % Color detection using the color sensor.
    currentColor = brick.ColorCode(colorSensorPort); % Get the color code from the color sensor
    % Check if the car is on a yellow color
    if currentColor == redColorCode
        brick.StopMotor('AC', 'Brake');
        pause(1); % Stop the loop if you want to end the program here
    end
    
    if (currentColor == blueColorCode) && (yellow == 0)
        green = 1;
        control = 0;
    end

    if (currentColor == greenColorCode) && (blue == 0)
        yellow = 1;
        control = 1;
    end
   
    if (currentColor == yellowColorCode) && (green == 0)
        break; 
    end
    if brick.UltrasonicDist(2) == distanceRight
        brick.MoveMotor('A', 60);
        brick.MoveMotor('C', 55);
    end
    
    if brick.UltrasonicDist(2) > distanceRight
        brick.MoveMotor('A', 70);
        brick.MoveMotor('C', 55);
    end
    
    
    % Short pause for better control over loop execution time.
    pause(0.1);  % Pause for 0.1 seconds before the next iteration.
end

% Stop the motors immediately after exiting the loop.
brick.StopMotor('AC', 'Brake');
