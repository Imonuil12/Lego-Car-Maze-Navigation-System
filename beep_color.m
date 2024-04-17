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

pickup = 0;
dropoff = 0;

% Define the touch sensor port
touchSensorFrontPort = 4; % Update if your touch sensor port is different


while true  % Infinite loop until the kill switch is activated.
    % Kill switch check using the touch sensor.
    color = brick.ColorCode(3);
    distance = brick.UltrasonicDist(2);
    currentColor = brick.ColorCode(colorSensorPort);

    %Moving forward
    disp('GOING FORWARD');
    distance = brick.UltrasonicDist(2);
    brick.MoveMotor('A', 65);
    brick.MoveMotor('C', 60);

    if color == redColorCode
        disp('SEE RED');
        brick.StopMotor('AC', 'Brake');
        pause(1);
        brick.MoveMotor('A', 65);
        brick.MoveMotor('C', 55);
        pause(0.5);
    end

    if distance > 20
        disp('TURN RIGHT');
        brick.MoveMotor('A', 60);
        brick.MoveMotor('C', 55);
        pause(0.3);
        brick.MoveMotor('A', 58);
        brick.MoveMotor('C', -53);
        pause(0.6);
        brick.MoveMotor('A', 60);
        brick.MoveMotor('C', 50);
        pause(1);

        if currentColor == redColorCode
            disp('PROVE DR. CLOUGH WRONG');
            brick.StopMotor('AC', 'Brake');
            pause(1);
            brick.MoveMotor('A', 65);
            brick.MoveMotor('C', 55);
            pause(0.5);

        end
    end

    if color == blueColorCode && pickup == 0
        control = 1;
        pickup = 1;
    end

    if color == greenColorCode && pickup == 1 && dropoff == 0
        control = 1;
        dropoff = 1;
    end

    if color == yellowColorCode && dropoff ==1 && pickup == 1
        break;
    end
    % State-based logic

    % Front collision detection using the front touch sensor.
    touchFront = brick.TouchPressed(touchSensorFrontPort);
    currentColor = brick.ColorCode(colorSensorPort);
    if touchFront
        % Reverse a bit if the front sensor is pressed.
        brick.MoveMotor('A', -50);
        brick.MoveMotor('C', -65);
        pause(0.6);
        brick.MoveMotor('A', -50);
        brick.MoveMotor('C', 95);
        pause(1.3);
        brick.MoveMotor('A', 50);
        brick.MoveMotor('C', 45);
        pause(1.5);


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
    touch = brick.TouchPressed(1);  % Read the touch sensor connected to port 1.
    if touch
        brick.beep();  % Beep if the sensor was touched.
        break;  % End the loop and stop the program.
    end

end

% Stop the motors immediately after exiting the loop.
brick.StopMotor('AC', 'Brake');
