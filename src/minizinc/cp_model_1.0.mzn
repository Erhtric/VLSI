%VLSI

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

% the height of the resulting silicon plate is the sum of something. AND IT SHOULD BE MINIMIZED
var int: height = height();

% ****************************************  Functions  ******************************************************

% Distance function
function var int: 
  distance(var int: x1, var int: y1, var int: x2, var int: y2) = max(abs(x1 - x2), abs(y1 - y2));

function var int: height() = max([corner_coords[c, 2] + dims[c, 2] | c in CIRCUITS]);

function var int: max_height() = sum([max([dims[c,d] | d in 1..2]) | c in CIRCUITS]);

% ****************************************  Predicates  *****************************************************    

% ****************************************  Constraints  ****************************************************


constraint forall(c1 in CIRCUITS, c2 in CIRCUITS where c1 != c2)( 
  if c1 < c2 then
    corner_coords[c2, 1] >= corner_coords[c1, 1] + dims[c1, 1] - 1
    \/ corner_coords[c2, 2] >= corner_coords[c1, 2] + dims[c1, 2] - 1
  else % c1 > c2
    true
  endif
 );


% table
% constraint forall(c in CIRCUITS)(corner_coords[c, 1] + dims[c, 1] <= width);
constraint among(n_circuits, [corner_coords[c, 1] + dims[c,1] | c in CIRCUITS], WIDTH);

% 1 <= x <= width
% table
constraint forall(i in CIRCUITS)(corner_coords[i, 1] >= 1 /\ corner_coords[i, 1] <= width);

% requires that exactly that each of the circuits final coordinates must have coordinates in the range 1..width
% constraint among(n_circuits, [corner_coords[c, 1] | c in CIRCUITS], WIDTH);


% 1 <= y <= height
constraint forall(i in CIRCUITS)(corner_coords[i, 2] >= 1 /\ corner_coords[i, 2] <= max_height());

% For now we will suppose that each piece cannot be rotated.

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
      