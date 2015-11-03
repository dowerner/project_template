function run(dt,printFlag)
if nargin == 0
    dt = 1;
    printFlag = false;
end

nestLocation = [0;0];
foodSourceLocation = [3;6];

ground = Ground;
ground.nestLocation = nestLocation;
nestPh = PheromoneParticle();
nestPh.location = nestLocation;
nestPh.intensity = 0;
nestPh = nestPh.setPrev(nestPh);
ground.pheromoneParticles = nestPh;
ground.foodSourceLocation = foodSourceLocation;
ant = Ant;
ground.ants = ant;
ant = ant.setUp(ground);
eps = 1e-4;

plot_title = 'looking for food';

currentPrint = 1;
while(currentPrint ==1 || ant.location(1) >= 0)
    ant.velocityVector(1:2) = ant.velocityVector(1:2)./norm(ant.velocityVector(1:2));
    ant.pathDirection = ant.velocityVector(1:2);
    %ground = ant.releasePheromone(ground);
    
    % pickup food and set nest as target
    if strcmp(ant.lookingFor, 'food') && norm(ant.location-foodSourceLocation) < eps
        plot_title = 'returning to nest.';
        ant.carryingFood = true;
        ant.lookingFor = 'nest';
    end
    
    % pickup food and set nest as target
    if strcmp(ant.lookingFor, 'nest') && norm(ant.location-nestLocation) < eps
        plot_title = 'looking for food.';
        ant.carryingFood = false;
        ant.lookingFor = 'food';
    end
    
    vtest = [0;1];
    
    if strcmp(ant.lookingFor, 'food')
        ant = ant.lookForSomething(ground,dt);
        %ant = ant.stepStraightTo(ant.location+[ant.velocityVector(1);ant.velocityVector(2)],dt);
        %ant = ant.stepStraightTo(ant.location+vtest,dt);
    elseif strcmp(ant.lookingFor, 'nest')
        ant = ant.returnHomeUsingPathIntegrator(ground, dt);
    end
    
    ground.ants(1) = ant;
    cla;
    hold on;
    minv = min([nestLocation foodSourceLocation]');
    maxv = max([nestLocation foodSourceLocation]');
    axis([minv(1)-2 maxv(1)+2 minv(2)-2 maxv(2)+2]);
    title(plot_title);
    xlabel('length [m]');
    ylabel('length [m]');
    %plot(nodeLocation(1),nodeLocation(2),'bo');
    ground = updateGround(ground,currentPrint,dt,printFlag);
    drawnow;
    plot(ant.globalVector(1),ant.globalVector(2),'bo');
    ant.globalVector
    ant.l
    ant.phi
    %currentPrint = currentPrint+1;
    ant = ant.updateGlobalVector(ground);
    if currentPrint > 1000
        break
    end
end
end

