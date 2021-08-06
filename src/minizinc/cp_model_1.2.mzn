% VLSI
% 1.1 release: Global constraints, NO Rotations

include "globals.mzn";

% ****************************************  PARAMETERS  *****************************************************

int: width;    % width of the board
int: n_circuits;    % number of circuits to place

set of int: WIDTH = 0..width;
set of int: CIRCUITS = 1..n_circuits;

% array of values of the following form:
%    <x1, y1, x2, y2, ..., xn, yn>
% where xi, yi represent the dimensions of the edges of the rectangle.
array[CIRCUITS, 1..2] of int: dims;  

% ****************************************  Decision variables  *********************************************

% our decision variables are the corner's positions (expressed in coordinates) in the silicon plate (represented in a similar manner to the dimensions)
%    <c1,c2, ..., cn, cn>
array[CIRCUITS, 1..2] of var int: corner_coords;

% the height of the resulting silicon plate
var int: height = height();

% ****************************************  Functions  ******************************************************

function var int: height() = max([corner_coords[c, 2] + dims[c, 2] | c in CIRCUITS]);

function var int: max_height() = sum([dims[c,2] | c in CIRCUITS]);

function var int: tot_area() = width * height;

function int: not_free_area() = sum([dims[c, 1] * dims[c, 2] | c in CIRCUITS]);

int: not_free_area = not_free_area();

function var int: free_area() = tot_area() - not_free_area;

% ****************************************  Predicates  *****************************************************    

% ****************************************  Constraints  ****************************************************

% For now we will suppose that each piece cannot be rotated.

constraint diffn([corner_coords[i, 1] | i in CIRCUITS], [corner_coords[i, 2] | i in CIRCUITS], [dims[i, 1] | i in CIRCUITS], [dims[i, 2] | i in CIRCUITS])::domain;     

constraint cumulative([corner_coords[i, 1] | i in CIRCUITS], [dims[i, 1] | i in CIRCUITS], [dims[i, 2] | i in CIRCUITS], height)::domain;            

constraint forall(i in CIRCUITS)(corner_coords[i, 1] + dims[i, 1] <= width);

% 1 <= x <= width - 1 (a coordinate of a rectangle should not be placed on the extreme right, unless it has width equal to 0)
constraint forall(i in CIRCUITS)(corner_coords[i, 1] >= 0 /\ corner_coords[i, 1] <= width - 1);

% 1 <= y <= max_height
% The values must stay in the range between 1 and the height of the relative silicon plate found
constraint forall(i in CIRCUITS)(corner_coords[i, 2] >= 0 /\ corner_coords[i, 2] <= height);

constraint height >= 1 /\ height <= max_height();

% This was removed
% constraint forall(i in CIRCUITS)(corner_coords[i, 2] >= 0 /\ corner_coords[i, 2] <= height);

constraint free_area() >= 0;

% Each corner should be different from any other corner coordinates (implied constraint) - it increases all the time required for the computation
% constraint forall(i1 in CIRCUITS, i2 in CIRCUITS where i1 != i2)([corner_coords[i1, j] | j in 1..2] != [corner_coords[i2, j] | j in 1..2]);

% ****************************************  Search  *********************************************************

solve 
minimize free_area()
:: int_search(corner_coords,first_fail, indomain_min)
:: restart_geometric(3.14, 10000)
% satisfy
      ;
% alldifferent, global cardinality constraint, among

output [show(width)++" "++show(height)++"\n"]++
       [show(n_circuits)++"\n"]++
       [show(dims[i,1]) ++" "++ show(dims[i,2]) ++" "++ show(corner_coords[i,1]) ++" "++show(corner_coords[i,2])++"\n" | i in 1..n_circuits]