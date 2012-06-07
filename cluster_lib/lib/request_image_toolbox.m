function request_image_toolbox

while 1
   if license('checkout','image_toolbox')
       break;
   end
   disp('Waiting for image toolbox license...');
   pause(30);
end
