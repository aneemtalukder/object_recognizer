function [ database_out ] = object_parser( labels_in )
%P3 generates object database

numobjects = 0;
values = unique(labels_in);
numvals = length(values);

figure, imagesc(labels_in), hold on

for i = 1:1:numvals
    
    label = values(i);
    if label ~= 0
        %y is i and x is j
        [y1 x1] = find(labels_in == label);
        c_x = mean(x1);
        c_y = mean(y1);
        
        %plot the center (first moment)
        plot(c_x, c_y, 'w.');

        %now calculate second moment to get theta (orientation)
        reposition_y = y1 - c_y;
        reposition_x = x1 - c_x;
        
        c = sum(reposition_y.^2);
        b = 2*sum(reposition_y.*reposition_x);
        a = sum(reposition_x.^2);
        
        theta_1 = atan2(b, a - c) / 2;
        obj_orientation = 90 - (theta_1 * 180 / pi);
        
        l = 20;
        x(1) = c_x;
        y(1) = c_y;
        x(2) = x(1) + l * cos(theta_1);
        y(2) = y(1) + l * sin(theta_1);
        x(3) = x(1) - l * cos(theta_1);
        y(3) = y(1) - l * sin(theta_1);
        plot(x,y);
        
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
        
        %add to objects database
        numobjects = numobjects + 1;
        database_out(numobjects).object_label = label;
        database_out(numobjects).x_position = c_x;
        database_out(numobjects).y_position = c_y;
        database_out(numobjects).orientation = obj_orientation; %angle in degrees, against y-axis (alternatively jsut use theta_1)
        database_out(numobjects).min_moment = Emin;
        database_out(numobjects).roundness = roundness;
        
    end
    
end

end

