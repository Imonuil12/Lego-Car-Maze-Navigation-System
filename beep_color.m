global key

control = 0; % Flag for remote control
%yellow = 0; % Legacy flag, ensure it's needed or remove
%blue = 0; % Legacy flag, ensure it's needed or remove
%green = 0; % Legacy flag, ensure it's needed or remove

% Define the minimum distance threshold (in centimeters)
distanceRight = 10;

% Initial state
state = 'start_yellow';

% Initialize lastColor with a value that doesn't match any color code
lastColor = 0;

% Define the color sensor port
colorSensorPort = 3; % Update if your color sensor port is different

% Define the color codes
yellowColorCode = 4; % LEGO color sensors return 4 for yellow, but calibrate as needed
redColorCode = 5;
greenColorCode = 3;
blueColorCode = 2;

% Define the touch sensor port
touchSensorFrontPort = 4; % Update if your touch sensor port is different


while true  % Infinite loop until the kill switch is activated.
    % Kill switch check using the touch sensor.
    disp(brick.UltrasonicDist(2));
    disp(brick.ColorCode(3));
    touch = brick.TouchPressed(1);  % Read the touch sensor connected to port 1.
    if touch
        brick.beep();  % Beep if the sensor was touched.
        break;  % End the loop and stop the program.
    end
    


    %Moving
    if brick.UltrasonicDist(2) <= distanceRight
        brick.MoveMotor('A', 70);
        brick.MoveMotor('C', 65);
    end
    
    if brick.UltrasonicDist(2) > 20
        brick.MoveMotor('A', 60);
        brick.MoveMotor('C', 55);
        pause(0.3);
        brick.MoveMotor('A', 65);
        brick.MoveMotor('C', -55);
        pause(0.6);
        brick.MoveMotor('A', 60);
        brick.MoveMotor('C', 50);
        pause(0.9);
    end



    % Color detection
    currentColor = brick.ColorCode(colorSensorPort);

    % State-based logic
    switch state
        case 'start_yellow'
            if currentColor == redColorCode
                brick.StopMotor('AC', 'Brake');
                pause(1);
                brick.MoveMotor('A', 65);
                brick.MoveMotor('C', 55);
                pause(0.5);

            end
            if currentColor == blueColorCode
                state = 'remote_control';
                control = 1; % Enable remote control
            end

        case 'remote_control'
            
            if control == 0 % Check if remote control has been exited
                % Decide next state based on last significant color
                if lastColor == blueColorCode
                    state = 'seek_green';
                elseif lastColor == greenColorCode
                    state = 'return_yellow';
                end
            end

        case 'seek_green'

            if currentColor == redColorCode
                brick.StopMotor('AC', 'Brake');
                pause(1);
                brick.MoveMotor('A', 65);
                brick.MoveMotor('C', 55);
                pause(0.5);
            end

            if currentColor == greenColorCode
                state = 'remote_control';
                control = 1; % Enable remote control
            end

            

        case 'return_yellow'

            if currentColor == redColorCode
                brick.StopMotor('AC', 'Brake');
                pause(1);
                brick.MoveMotor('A', 65);
                brick.MoveMotor('C', 55);
                pause(0.5);
            end

            if currentColor == yellowColorCode
                % Reached the end, stop or do something else
                break; % Exit the main loop
            end
    end
    

    % Front collision detection using the front touch sensor.
    touchFront = brick.TouchPressed(touchSensorFrontPort);
    if touchFront
        % Reverse a bit if the front sensor is pressed.
        brick.MoveMotor('A', -50);
        brick.MoveMotor('C', -65);
        pause(0.6);
        brick.MoveMotor('A', -50);
        brick.MoveMotor('C', 80);
        pause(1.2);
        brick.MoveMotor('A', 60);
        brick.MoveMotor('C', 55);
        pause(2.3);
    
        
    end
 

    % Remember the last non-red color detected
    if currentColor ~= redColorCode
        lastColor = currentColor;
    end
    


    
    
    if control
  
    InitKeyboard();
  
       while 1
           pause(0.1);
           switch key
               case 'uparrow'
                   disp('Up');
                   brick.MoveMotor('A', 60);
                   brick.MoveMotor('C', 60);
               case 'downarrow'
                   disp('Down');
                   brick.MoveMotor('A', -60);
                   brick.MoveMotor('C', -60);
               case 'leftarrow'
                   disp('Left');
                   brick.MoveMotor('A', 30);
                   brick.MoveMotor('C', -30);
               case 'rightarrow'
                   disp('Right');
                   brick.MoveMotor('A', -30);
                   brick.MoveMotor('C', 30);
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
    
    % Short pause for better control over loop execution time.
    pause(0.1);  % Pause for 0.1 seconds before the next iteration.
end

% Stop the motors immediately after exiting the loop.
brick.StopMotor('AC', 'Brake');
