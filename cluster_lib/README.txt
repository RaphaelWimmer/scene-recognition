%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% cluster_lib 1.0     Matlab library for cluster processing
%% Author: Lubomir Bourdev   lbourdev@eecs.berkeley.edu     Jan 30, 2010
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

A set of Matlab functions that allows a parallelizable task to be distributed on the clusters.
The task consists of performing the same operation to each of N elements.

EXAMPLE CODE

The library comes with a Hello World example which computes the squares of the numbers 1 to 100.
To run the example, cd cluster_lib/example and run hello_cluster_world

DESCRIPTION

The library splits the task into M jobs, each of which processes a range of elements. It then collects their 
results into the result file. All you need to do is implement two functions:

   A. Given a range of elements, perform the task and save the results in a given file
   B. Given the results from all calls of A, collect them and save them in the result file

The library also supports spawning a single job. Use this to perform processing intensive jobs while on the front node.

Features of cluster_lib:
  - Groups fast operations into fewer jobs
  - Can run everything on a single node (for debugging)
  - Allows you to interrupt jobs at any time and continue
  - Does not submit more than N pbs jobs, so it doesn't flood the server with queued jobs. 
      Waits until some are done before spawning new ones
  - Special-cases jobs that require the image toolbox: Makes sure there are no more than N of them. 
      Each of them checks out the toolbox before executing

