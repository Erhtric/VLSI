% VLSI
% 1.0 release: NO Global constraints, NO Rotations

include "globals.mzn";

% ****************************************  PARAMETERS  *****************************************************

int: width;    % width of the board
int: n_circuits;    % number of circuits to place

set of int: WIDTH = 1..width;
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

function var int: max_height() = sum([max([dims[c,d] | d in 1..2]) | c in CIRCUITS]);

% ****************************************  Predicates  *****************************************************    

% ****************************************  Constraints  ****************************************************

% For now we will suppose that each piece cannot be rotated.


constraint forall(c1 in CIRCUITS, c2 in CIRCUITS where c1 < c2)( 
    corner_coords[c2, 1] >= corner_coords[c1, 1] + dims[c1, 1] - 1
    \/ corner_coords[c2, 2] >= corner_coords[c1, 2] + dims[c1, 2] - 1
 );


% table
constraint forall(c in CIRCUITS)(corner_coords[c, 1] + dims[c, 1] <= width);
% constraint among(n_circuits, [corner_coords[c, 1] + dims[c,1] | c in CIRCUITS], WIDTH);

% 1 <= x <= width
constraint forall(i in CIRCUITS)(corner_coords[i, 1] >= 1 /\ corner_coords[i, 1] <= width);

% 1 <= y <= max_height
% The values must stay in the range between 1 and the maximum possible weight obtained by putting one on top of another
constraint forall(i in CIRCUITS)(corner_coords[i, 2] >= 1 /\ corner_coords[i, 2] <= max_height());

% ****************************************  Search  *********************************************************

solve 
minimize height() 
% :: int_search(corner_coords, first_fail, indomain_min)
% :: restart_geometric(1.5,100)
% satisfy
      ;
      
% alldifferent, global cardinality constraint, among

output [show(width)++" "++show(height)++"\n"]++
       [show(n_circuits)++"\n"]++
       [show(dims[i,1]) ++" "++ show(dims[i,2]) ++" "++ show(corner_coords[i,1]) ++" "++show(corner_coords[i,2])++"\n" | i in 1..n_circuits]
      