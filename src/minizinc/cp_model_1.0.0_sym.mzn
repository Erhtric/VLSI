% VLSI
% 1.0.0_sym release: NO Global constraints, NO Rotations, Height version
% This is the 1.0.0 version with the symmetry breaking constraints

include "globals.mzn";

% ****************************************  PARAMETERS  *****************************************************

int: width;    % width of the board
int: n_circuits;    % number of circuits to place

set of int: WIDTH = 0..width;
set of int: CIRCUITS = 1..n_circuits;

% array of values of the following form:
%    <x1, y1, ..., xn, yn>
% where wi, hi represent the dimensions of the edges of the rectangle.
array[CIRCUITS, 1..2] of int: dims;  

% maximum allowable height and minimum possible height
int: max_height = sum([max([dims[c,d] | d in 1..2]) | c in CIRCUITS]);
int: min_height = min([dims[c, 2] | c in CIRCUITS]);

% ****************************************  Decision variables  *********************************************

% our decision variables are the corner's positions (expressed in coordinates) in the silicon plate (represented in a similar manner to the dimensions)
%    <w1,h1, ..., wn, hn>
array[CIRCUITS, 1..2] of var int: corner_coords;

% the height of the resulting silicon plate
var int: height = height();

% ****************************************  Functions  ******************************************************

function var int: height() = max([corner_coords[c, 2] + dims[c, 2] | c in CIRCUITS]);

% It returns the index of the block which has the largest area
function int: biggest() = arg_max([dims[c, 1] * dims[c,2] | c in CIRCUITS]);

% ****************************************  Constraints  ****************************************************

% For now we will suppose that each piece cannot be rotated.

% No-overlap constraint
constraint forall(i,j in CIRCUITS where i!=j)(
  corner_coords[i,1] + dims[i,1] <= corner_coords[j,1] \/
  corner_coords[i,1] - dims[j,1] >= corner_coords[j,1] \/
  corner_coords[i,2] + dims[i,2] <= corner_coords[j,2] \/
  corner_coords[i,2] - dims[j,2] >= corner_coords[j,2]
);

% x, y of each block should have as starting coordinate (0,0)
constraint forall(i in CIRCUITS)(corner_coords[i, 1] >= 0);
constraint forall(i in CIRCUITS)(corner_coords[i, 2] >= 0);

% Right Border constraint
constraint forall(i in CIRCUITS)(corner_coords[i, 1] + dims[i,1] <= width);

% The values must stay in the range between 1 and the height of the relative silicon plate found
constraint forall(i in CIRCUITS)(corner_coords[i, 2] + dims[i,2] <= height);

% min_height <= height <= max_height
% This is based on the fact that the height should be at least equal to the smallest height present in the list of circuits
constraint height >= min_height /\ height <= max_height;

constraint symmetry_breaking_constraint(
    % the biggest block should stay in the left half part of the plate, this breaks the symmetries on the vertical axis
    corner_coords[biggest(), 1] * 2 <= width
    % the biggest block should stay in the bottom half part of the plate, this breaks the symmetries on the horizontal axis
    /\ corner_coords[biggest(), 2] * 2 <= height
    );

constraint symmetry_breaking_constraint(
    % the biggest block should stay in the left corner of the plate
    corner_coords[biggest(), 1] = 0
    /\ corner_coords[biggest(), 1] = 0
    );

% ****************************************  Search  *********************************************************

solve 
minimize height()
:: int_search(corner_coords, first_fail, indomain_min)
% :: restart_geometric(1.5,100)
      ;
      

output [show(width)++" "++show(height)++"\n"]++
       [show(n_circuits)++"\n"]++
       [show(dims[i,1]) ++" "++ show(dims[i,2]) ++" "++ show(corner_coords[i,1]) ++" "++show(corner_coords[i,2])++"\n" | i in 1..n_circuits]++["\n"]
      