function output = ip_std(input_image)
%does average to the imput image, and this includes the mean 
%   compute the average of the image and add in the back ground intensity 
 im_reshape = reshape(input_image,[],1);
 output = std(im_reshape);

end
