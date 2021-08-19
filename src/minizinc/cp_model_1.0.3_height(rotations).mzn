% VLSI
% 1.0.3 release: NO Global constraints, Rotations, Height version

include "globals.mzn";

% ****************************************  PARAMETERS  *****************************************************

int: width;    % width of the board
int: n_circuits;    % number of circuits to place

set of int: WIDTH = 0..width;
set of int: CIRCUITS = 1..n_circuits;

% array of values of the following form:
%    <w1, h1, ..., wn, hn>
% where wi, hi represent the dimensions of the edges of the rectangle.
array[CIRCUITS, 1..2] of int: dims;  

% maximum allowable height and minimum possible height
int: max_height = sum([max(dims[i,1], dims[i,2]) | i in CIRCUITS]);
int: min_height = min([dims[i, 2] | i in CIRCUITS]);

% ****************************************  Decision variables  *********************************************

% our decision variables are the corner's positions (expressed in coordinates) in the silicon plate (represented in a similar manner to the dimensions)
%    <x1,y1, ..., xn, yn>
array[CIRCUITS, 1..2] of var int: corner_coords;

% The additional Boolean variable rot is used to indicate the change of orientation of the block
% Since they are all rectangles, a simple swap between the two edges is enough to distinguish between
% the original rectangle and the rotated one
%    0 - the block is in its original orientation
%    1 - the block is rotated by 90 degrees
array[CIRCUITS] of var int: rot;

% the height of the silicon plate
var int: height = height();

% ****************************************  Functions  ******************************************************

function var int: height() = max([corner_coords[i, 2] + rot[i] * dims[i, 1] + (1 - rot[i]) * dims[i, 2] | i in CIRCUITS]); 

% ****************************************  Constraints  ****************************************************

% For now we will suppose that each piece cannot be rotated.
 
% No-overlap constraint
constraint forall(i,j in CIRCUITS where i != j)(
  corner_coords[i,1] + rot[i] * dims[i,2] + (1 - rot[i]) * dims[i,1] <= corner_coords[j,1] \/
  corner_coords[i,2] + rot[i] * dims[i,1] + (1 - rot[i]) * dims[i,2] <= corner_coords[j,2] \/
  corner_coords[i,1] - rot[j] * dims[j,2] - (1 - rot[j]) * dims[j,1] >= corner_coords[j,1] \/
  corner_coords[i,2] - rot[j] * dims[j,1] - (1 - rot[j]) * dims[j,2] >= corner_coords[j,2]
);

% x, y of each block should have as starting coordinate (0,0)
constraint forall(i in CIRCUITS)(corner_coords[i, 1] >= 0);
constraint forall(i in CIRCUITS)(corner_coords[i, 2] >= 0);

% Right Border constraint
constraint forall(i in CIRCUITS)(corner_coords[i, 1] + rot[i] * dims[i,2] + (1 - rot[i]) * dims[i,1] <= width);

% The values must stay in the range between 1 and the height of the relative silicon plate found
constraint forall(i in CIRCUITS)(corner_coords[i, 2] + rot[i] * dims[i,2] + (1 - rot[i]) * dims[i,1] <= height);

% min_height <= height <= max_height
% This is based on the fact that the height should be at least equal to the smallest height present in the list of circuits
constraint height >= min_height /\ height <= max_height;

constraint forall(i in CIRCUITS)(rot[i] >= 0 /\ rot[i] <= 1);

% ****************************************  Search  *********************************************************

solve 
minimize height()
:: int_search(corner_coords, first_fail, indomain_min)
:: int_search(rot,first_fail, indomain_min)
% :: int_search(corner_coords, input_order, indomain_random)
% :: restart_geometric(1.5,100)
      ;
      

output [show(width)++" "++show(height)++"\n"]++
       [show(n_circuits)++"\n"]++
       [show(dims[i,1]) ++" "++ show(dims[i,2]) ++" "++ show(corner_coords[i,1]) ++" "++show(corner_coords[i,2]) ++ " " ++ show(rot[i]) ++"\n" | i in 1..n_circuits]
      