function request_statistics_toolbox

while 1
   if license('checkout','statistics_toolbox')
       break;
   end
   disp('Waiting for statistics toolbox license...');
   pause(30);
end
