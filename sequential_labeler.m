function [ labels_out ] = sequential_labeler( binary_in )

binary_in = double(binary_in);
num_rows = size(binary_in, 1);
num_cols = size(binary_in, 2);
label = 0;
map = containers.Map(0, [2 2 2 2]);
remove(map, 0);

for i = 1:1:num_rows
    for j = 1:1:num_cols
        
        pixel = binary_in(i,j);
        if pixel == 0
            %CASE 1
        elseif i == 1
            
        else
            if j == 1
                if binary_in(i-1,j) ~= 0
                    binary_in(i,j) = binary_in(i-1, j);
                else
                    label = label + 1;
                    binary_in(i,j) = label;
                end
                
            elseif binary_in(i-1, j-1) ~= 0
                %CASE 2
                binary_in(i,j) = binary_in(i-1, j-1);
                
                
            elseif binary_in(i, j-1) == 0 && binary_in(i-1, j) ~= 0
                %CASE 3
                binary_in(i,j) = binary_in(i-1, j);
                
                
            elseif binary_in(i-1, j) == 0 && binary_in(i, j-1) ~= 0
                %CASE 5
                binary_in(i,j) = binary_in(i, j-1);
                
            elseif binary_in(i, j-1) == 0 && binary_in(i-1, j) == 0
                %CASE 4
                label = label + 1;
                binary_in(i,j) = label;
                
            elseif binary_in(i, j-1) ~= 0 && binary_in(i-1, j) ~= 0
                %CASE 6
                if binary_in(i, j-1) == binary_in(i-1, j)
                    binary_in(i,j) = binary_in(i-1, j);
                else
                    binary_in(i,j) = binary_in(i-1, j);
                    %now add both things to the equivalence table
                    %3 subcases:
                    if isKey(map, binary_in(i, j-1)) && isKey(map, binary_in(i-1, j))
                        key1 = map(binary_in(i-1, j));
                        if length(key1) > 1
                            key1 = binary_in(i-1, j);
                        end
                        key2 = map(binary_in(i, j-1));
                        if length(key2) > 1
                            key2 = binary_in(i, j-1);
                        end
                        
                        if key1 ~= key2
                            map(key1) = union(map(key1), map(key2));
                            
                            remapkeys = map(key2);
                            numremap = length(remapkeys);
                            for k = 1:1:numremap
                                map(remapkeys(k)) = key1;
                            end
                            
                        end
                        
                    elseif isKey(map, binary_in(i, j-1))
                        %left pixel exists in map
                        key = map(binary_in(i, j-1));
                        if length(key) > 1
                            key = binary_in(i, j-1);
                        end
                        newval = binary_in(i-1, j);
                        map(key) = union(map(key), newval);
                        map(newval) = key;
                        
                    elseif isKey(map, binary_in(i-1, j))
                        %top pixel exists in map
                        key = map(binary_in(i-1, j));
                        if length(key) > 1
                            key = binary_in(i-1, j);
                        end
                        newval = binary_in(i, j-1);
                        map(key) = union(map(key), newval);
                        map(newval) = key;
                        
                    else
                        %neither pixels exist in map
                        map(binary_in(i-1, j)) = union(binary_in(i, j-1), binary_in(i-1, j));
                        map(binary_in(i, j-1)) = binary_in(i-1, j);
                        
                    end
                end
                
            else
                
            end
            
        end
        
    end
end

scalelabel = 0;
scalemap = containers.Map(0, [2 2 2 2]);
remove(scalemap, 0);

for i = 1:1:label
    if isKey(map, i) == 0
        %there are no equivalencies
        scalelabel = scalelabel + 1;
        scalemap(i) = scalelabel;
    else
        %there are equivalencies in map
        keys = map(i);
        if length(keys) > 1
            scalelabel = scalelabel + 1;
            numkeys = length(keys);
            
            for j = 1:1:numkeys
                scalemap(keys(j)) = scalelabel;
            end
        end
    end
end

%now go through pixels again with connected component labeling
for i = 1:1:num_rows
    for j = 1:1:num_cols
        if binary_in(i,j) ~= 0
            binary_in(i,j) = scalemap(binary_in(i,j));
        end
    end
end

labels_out = binary_in;

end

