% VLSI
% 1.0.2 release: NO Global constraints, NO Rotations, Height version, Decomposition

% include "globals.mzn";

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
int: max_height = sum([dims[i, 2] | i in CIRCUITS]);
int: min_height = min([dims[i, 2] | i in CIRCUITS]);

% ****************************************  Decision variables  *********************************************

% our decision variables are the corner's positions (expressed in coordinates) in the silicon plate (represented in a similar manner to the dimensions)
%    <x1,y1, ..., xn, yn>
array[CIRCUITS, 1..2] of var int: corner_coords;

% the height of the silicon plate
var int: height = height();

% ****************************************  Functions  ******************************************************

function var int: height() = max([corner_coords[i, 2] + dims[i, 2] |i in CIRCUITS]); 

% Cumulative decomposition
predicate cumulative(array[int] of var int: coords, array[int] of int: dims1, array[int] of int: dims2, var int: border) = 
  let {set of int: circuits = 1..length(coords)} in
  forall(j in circuits)(
      border >= dims2[j] + 
        sum(i in circuits where i != j)(
          bool2int(coords[i] <= coords[j] /\ coords[j] < coords[i] + dims1[i]) * dims2[i])
  ); 
  
% Diffn/2 decomposition
predicate diffn(array[int] of var int: X, array[int] of var int: Y, array[int] of var int: W, array[int] of var int: H) =
  let {set of int: circuits = 1..length(X)} in
  forall(i, j in circuits where i != j)(
    exists([X[i] >= X[j] + W[j] \/ X[j] >= X[i] + W[i], Y[i] >= Y[j] + H[j] \/ Y[j] >= Y[i] + H[i]])
  );

% ****************************************  Constraints  ****************************************************

% For now we will suppose that each piece cannot be rotated.

constraint diffn([corner_coords[i, 1] | i in CIRCUITS], [corner_coords[i, 2] | i in CIRCUITS], [dims[i, 1] | i in CIRCUITS], [dims[i, 2] | i in CIRCUITS]);

constraint cumulative([corner_coords[i, 1] | i in CIRCUITS], [dims[i, 1] | i in CIRCUITS], [dims[i, 2] | i in CIRCUITS], height);            
constraint cumulative([corner_coords[i, 2] | i in CIRCUITS], [dims[i, 2] | i in CIRCUITS], [dims[i, 1] | i in CIRCUITS], width); 

% x, y of each block should have as starting coordinate (0,0)
constraint forall(i in CIRCUITS)(corner_coords[i, 1] >= 0);
constraint forall(i in CIRCUITS)(corner_coords[i, 2] >= 0);

% Right Border constraint
constraint forall(i in CIRCUITS)(corner_coords[i, 1] + dims[i,1] <= width);

% The values must stay in the range between 1 and the height of the relative silicon plate found
constraint forall(i in CIRCUITS)(corner_coords[i, 2] + dims[i,2] <= height);
constraint height <= max_height;

% min_height <= height <= max_height
% This is based on the fact that the height should be at least equal to the smallest height present in the list of circuits
constraint height >= min_height /\ height <= max_height;

% ****************************************  Search  *********************************************************

solve 
minimize height()
% :: int_search(corner_coords, input_order, indomain_random)
:: int_search(corner_coords, first_fail, indomain_min)
% :: restart_geometric(1.5,100)
      ;
      

output [show(width)++" "++show(height)++"\n"]++
       [show(n_circuits)++"\n"]++
       [show(dims[i,1]) ++" "++ show(dims[i,2]) ++" "++ show(corner_coords[i,1]) ++" "++show(corner_coords[i,2])++"\n" | i in 1..n_circuits]
      