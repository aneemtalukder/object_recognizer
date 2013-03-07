function binary_out = p1( gray_in, thresh_val )

I = imread(gray_in);
binary_out = I > thresh_val; 

end

