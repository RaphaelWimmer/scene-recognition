%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% cluster_lib      Matlab library for cluster processing
%% Author: Lubomir Bourdev   lbourdev@eecs.berkeley.edu     Jan 30, 2010
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% An example of an operation to do on a single node.
% This is useful if you want to stay on the front node and do a
% processing-intensive operation

% Computes the powers of a set of numbers.
function output = example_single_op(usr_data)
    [pow,num_el] = strread(usr_data,'%d %d');
    for i=1:num_el
       output(i) = power(i,pow);
    end
end