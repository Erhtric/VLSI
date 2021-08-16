% VLSI
% 1.3.1 release: Global constraints (CUMULATIVE + DIFFN) + Decompositions, Rotations

include "cumulative.mzn";
include "diffn.mzn";

% ****************************************  PARAMETERS  *****************************************************

int: width;    % width of the board
int: n_circuits;    % number of circuits to place

set of int: WIDTH = 0..width;
set of int: CIRCUITS = 1..n_circuits;

% array of values of the following form:
%    <x1, y1, x2, y2, ..., xn, yn>
% where xi, yi represent the dimensions of the edges of the rectangle.
array[CIRCUITS, 1..2] of int: dims;  

% maximum allowable height and minimum possible height
int: max_height = sum([max([dims[c,d] | d in 1..2]) | c in CIRCUITS]);
int: min_height = min([dims[c, 2] | c in CIRCUITS]);

% ****************************************  Decision variables  *********************************************

% our decision variables are the corner's positions (expressed in coordinates) in the silicon plate (represented in a similar manner to the dimensions)
%    <c1,c2, ..., cn, cn>
array[CIRCUITS, 1..2] of var int: corner_coords;

% The additional Boolean variable rot is used to indicate the change of orientation of the block
% Since they are all rectangles, a simple swap between the two edges is enough to distinguish between
% the original rectangle and the rotated one
%    0 - the block is in its original orientation
%    1 - the block is rotated by 90 degrees
array[CIRCUITS] of var int: rot;

% the height of the resulting silicon plate
var int: height = height();

% ****************************************  Functions  ******************************************************

function var int: height() = max([corner_coords[i, 2] + rot[i] * dims[i, 1] + (1 - rot[i]) * dims[i, 2] | i in CIRCUITS]); 

% ****************************************  Predicates  *****************************************************    

% ****************************************  Constraints  ****************************************************

% For now we will suppose that each piece cannot be rotated.

constraint diffn([corner_coords[i, 1] | i in CIRCUITS], [corner_coords[i, 2] | i in CIRCUITS], [(1 - rot[i]) * dims[i, 1] | i in CIRCUITS], [rot[i] * dims[i, 2] | i in CIRCUITS]);

constraint cumulative([corner_coords[i, 1] | i in CIRCUITS], [dims[i, 1] | i in CIRCUITS], [dims[i, 2] | i in CIRCUITS], height);            
constraint cumulative([corner_coords[i, 2] | i in CIRCUITS], [dims[i, 2] | i in CIRCUITS], [dims[i, 1] | i in CIRCUITS], width);   

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
:: int_search(corner_coords,first_fail, indomain_min)
% :: restart_geometric(3.14, 10000)
% satisfy
      ;

output [show(width)++" "++show(height)++"\n"]++
       [show(n_circuits)++"\n"]++
       [show(dims[i,1]) ++" "++ show(dims[i,2]) ++" "++ show(corner_coords[i,1]) ++" "++show(corner_coords[i,2]) ++ " " ++ show(rot[i]) ++"\n" | i in 1..n_circuits]
      