%**************************************************************************
%* Project: Desert ant navigational behaviour
%* Developers: Florian Hasler, Matthias Heinzmann, Andreas Urech,
%*             Dominik Werner
%* Description: This project simulates the foraging behaviour of Saharan
%*              desert ants.
%* Usage: To run this project execute run.m. The setup can also be changed
%*        in this file with the following parameters:
%*          - nestLocation
%*          - nAnts
%*          - nFoodSources
%*          - nLandmarks
%**************************************************************************

function run(dt,printFlag)
    if nargin == 0
        dt = 0.3; % time step
        printFlag = false;
    end

    nestLocation = [0;0]; % location of ant nest
    
    global add % global variable to check if new food sources were added
    global coords % coordinates to spawn source
    global exit % handling clean exit
    
    % help variables
    add = 0;
    exit = 0;
    coords = [0;0];
    
    ground = Ground;
    ground.timeLapseFactor = 10000; % simulaiton speed (eg. timePerStep = (1/TimeLapseFactor))
    ground.nestLocation = nestLocation;
    
    % place ants
    nAnts = 1; % number of ants to spawn
    ants = Ant(zeros(nAnts,1));
    for i = 1 : length(ants)
        ants(i) = Ant;
        ants(i) = ants(i).setUp(ground);
    end
    ground.ants = ants;

    % place food sources
    nFoodSources = 5; % number of food sources to spawn
    foodSourceDistance = 100;
    xCoord = foodSourceDistance*(2*rand(1,nFoodSources)-1);
    yCoord = foodSourceDistance*(2*rand(1,nFoodSources)-foodSourceDistance);
    for k = 1:nFoodSources
        ground.spawnFoodSource(xCoord(k),yCoord(k));    % WRONG: Has no effect
        ground = ground.spawnFoodSource(xCoord(k),yCoord(k));   % CORRECT: Update gets written
    end
    
    % place landmarks
    nLandmarks = 5; % number of landmarks to spawn
    landmarkDistance = 10;
    xCoord = landmarkDistance*(2*rand(1,nLandmarks)-1);
    yCoord = landmarkDistance*(2*rand(1,nLandmarks)-1);
    stepWidth = ants(1).velocityVector(3)*dt;
    landmarks = Landmark(zeros(1,nLandmarks));
    for k = 1:nLandmarks
        landmarks(k) = landmarks(k).setUp(xCoord(k),yCoord(k),stepWidth);
    end
    ground.landmarks = landmarks;

    hFigure = figure;  %# Create a figure window
    set(hFigure, 'Position', [0 0  1680 1260]);
    hfAxes = axes;      %# Create an axes in that figure
    %set(hFigure,'WindowButtonMotionFcn',...  %# Set the WindowButtonMotionFcn so
    %    {@axes_coord_motion_fcn,hAxes});     %#   that the given function is called
    %                                         %#   for every mouse movement
    
    setGlobalhAxes(hfAxes);
    vidObj=VideoWriter('testvideo1.avi');
    open(vidObj);
    set(hFigure, 'WindowButtonDownFcn', @axes_coord_click_fcn);
    set(hFigure, 'CloseRequestFcn', @onClosing);
    
    currentPrint = 1;
    while(currentPrint == 1)
        % set timestamt
        tic;
        
        if add == 1 % add food source
           disp('new food source at:');
           disp(coords);
           add = 0;
           ground = ground.spawnFoodSource(coords(1),coords(2));
        end
        if exit == 1
            close(vidObj);
           break; 
        end
        
        for j = 1 : length(ground.ants)
            [ants(j), ground] = ants(j).performStep(ground,dt);
            ground.ants(j) = ants(j);
        end
        cla;
        hold on;
        axis([-100 100 -100 100]);
        title('foraging ants');
        xlabel('length [m]');
        ylabel('length [m]');
        ground = updateGround(ground,length(ants),printFlag);
        plot(ants(1).globalVector(1),ants(1).globalVector(2),'*')
        drawnow;
        currFrame=getframe(hFigure);
        writeVideo(vidObj,currFrame);
        % a pause so that according to the timeLapseFactor a step in
        % realtime takes ONE second.
        timeToWait = 1-toc;

        if timeToWait < 0
            timeToWait = 1;
        end
        pause(timeToWait*(ground.timeLapseFactor)^(-1)-0.002);
    end
end

%**********************************************************************
% UI handling
%**********************************************************************
% The following section handles all UI interactions such as closing and
% spawing new foodsources

% set hAxes variables for callback
function setGlobalhAxes(val)
    global hAxes
    hAxes = val;
end

% get hAxes variables for callback
function r = getGlobalhAxes
    global hAxes
    r = hAxes;
end

% close callback used to terminate application
function onClosing(src, callbackdata)
    disp('end');
    delete(src);
    global exit
    exit = 1;
end

% Callback when plot is clicked
function axes_coord_click_fcn(src,event)
  global coords
  hAxes = getGlobalhAxes;
  coords = get_coords(hAxes);            %# Get the axes coordinates
  
  global add
  add = 1;
end

function value = get_in_units(hObject,propName,unitType)

  oldUnits = get(hObject,'Units');  %# Get the current units for hObject
  set(hObject,'Units',unitType);    %# Set the units to unitType
  value = get(hObject,propName);    %# Get the propName property of hObject
  set(hObject,'Units',oldUnits);    %# Restore the previous units

end

function coords = get_coords(hAxes)

  %# Get the screen coordinates:
  coords = get_in_units(0,'PointerLocation','pixels');

  %# Get the figure position, axes position, and axes limits:
  hFigure = get(hAxes,'Parent');
  figurePos = get_in_units(hFigure,'Position','pixels');
  axesPos = get_in_units(hAxes,'Position','pixels');
  axesLimits = [get(hAxes,'XLim').' get(hAxes,'YLim').'];

  %# Compute an offset and scaling for coords:
  offset = figurePos(1:2)+axesPos(1:2);
  axesScale = diff(axesLimits)./axesPos(3:4);

  %# Apply the offsets and scaling:
  coords = (coords-offset).*axesScale+axesLimits(1,:);

end



