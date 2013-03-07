function overlays_out = object_recognizer(labels_in, database_in)
%P4 database comparitor

numobjects = 0;
values = unique(labels_in);
numvals = length(values);
recognized_objects = [];
database_size = length(database_in);

figure, imagesc(labels_in), hold on

for i = 1:1:numvals
    
    label = values(i);
    if label ~= 0
        %y is i and x is j
        [y1 x1] = find(labels_in == label);
        c_x = mean(x1);
        c_y = mean(y1);
        
        %now calculate second moment to get theta (orientation)
        reposition_y = y1 - c_y;
        reposition_x = x1 - c_x;
        
        c = sum(reposition_y.^2);
        b = 2*sum(reposition_y.*reposition_x);
        a = sum(reposition_x.^2);
        
        theta_1 = atan2(b, a - c) / 2;
        
        %second derivative test to find min/max moment of inertia
        second_d = (a - c) * cos(2 * theta_1) + b * sin(2 * theta_1);
        theta_2 = 0;
        roundness = 1;
        Emin = 0;
        Emax = 0;
        if second_d > 0
            % then theta_1 is the minimum
            theta_2 = theta_1 + pi/2;
            Emin = a * (sin(theta_1))^2 - b * sin(theta_1) * cos(theta_1) + c * (cos(theta_1)^2); %use theta_1
            Emax = a * (sin(theta_2))^2 - b * sin(theta_2) * cos(theta_2) + c * (cos(theta_2)^2); %use theta_2
            roundness = Emin / Emax;
        else
            % theta_1 the maximum
            theta_2 = theta_1 + pi/2;
            Emin = a * (sin(theta_2))^2 - b * sin(theta_2) * cos(theta_2) + c * (cos(theta_2)^2); %use theta_2
            Emax = a * (sin(theta_1))^2 - b * sin(theta_1) * cos(theta_1) + c * (cos(theta_1)^2); %use theta_1
            roundness = Emin / Emax;
        end
        
        for j = 1:1:database_size
            
            %check roundness
            test_roundness = database_in(j).roundness;
            diff = abs(test_roundness - roundness);
            round_percent = 100 * (diff / test_roundness);
            if round_percent < 10
                %still good
            else
                continue;
            end
            
            %check min moment
            test_moment = database_in(j).min_moment;
            diff = abs(test_moment - Emin);
            moment_percent = 100 * (diff / test_moment);
            if moment_percent < 10
                %this is a match
                disp('WE HAVE A MATCH!');
                %plot the center (first moment)
                plot(c_x, c_y, 'w.');
                l = 20;
                x(1) = c_x;
                y(1) = c_y;
                x(2) = x(1) + l * cos(theta_1);
                y(2) = y(1) + l * sin(theta_1);
                x(3) = x(1) - l * cos(theta_1);
                y(3) = y(1) - l * sin(theta_1);
                plot(x,y);
            end
            
        end
        
    end
    
end

%then draw new image with only the recognized objects
overlays_out = labels_in;

end

