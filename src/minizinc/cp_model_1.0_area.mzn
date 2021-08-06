% VLSI
% 1.0 release: NO Global constraints, NO Rotations, Area version

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

% maximum allowable height and minimum possible height
int: max_height = sum([max([dims[c,d] | d in 1..2]) | c in CIRCUITS]);
int: min_height = min([dims[c, 2] | c in CIRCUITS]);

% ****************************************  Decision variables  *********************************************

% our decision variables are the corner's positions (expressed in coordinates) in the silicon plate (represented in a similar manner to the dimensions)
%    <c1,c2, ..., cn, cn>
array[CIRCUITS, 1..2] of var int: corner_coords;

% the height of the resulting silicon plate
var int: height = height();

var int: free_area = free_area();

% ****************************************  Functions  ******************************************************

function var int: height() = max([corner_coords[c, 2] + dims[c, 2] | c in CIRCUITS]);

function var int: tot_area() = width * height;

function var int: free_area() = 
  let {int: not_free_area = sum([dims[c, 1] * dims[c, 2] | c in CIRCUITS]) } in 
    tot_area() - not_free_area;

% ****************************************  Predicates  *****************************************************    

% ****************************************  Constraints  ****************************************************

% For now we will suppose that each piece cannot be rotated.

% No-overlap constraint
constraint forall(i in CIRCUITS, j in CIRCUITS where i!=j)( 
    if corner_coords[i,1] < corner_coords[j,1] then 
        % corner i is on the left of corner j 
        corner_coords[i,1] + dims[i,1] <= corner_coords[j,1]
    elseif corner_coords[i,2] < corner_coords[j,2] then
        % corner i is below corner j 
        corner_coords[i,2] + dims[i,2] <= corner_coords[j,2]  	
    elseif corner_coords[i,1] > corner_coords[j,1] then 
        % corner i is on the right of corner j 
        corner_coords[i,1] - dims[j,1] >= corner_coords[j,1]
    elseif corner_coords[i,2] > corner_coords[j,2] then
        % corner i is above corner j  
        corner_coords[i,2] - dims[j,2] >= corner_coords[j,2]
    else 
        % there is an overlap
        false
    endif       
 );

% Right Border constraint
constraint forall(i in CIRCUITS)(corner_coords[i, 1] + dims[i, 1] <= width);

% 1 <= x < width
% We assume that each circuit should not have horizontal dimensions equal to zero
constraint forall(i in CIRCUITS)(corner_coords[i, 1] >= 0 /\ corner_coords[i, 1] < width);

% 1 <= y <= height
% The values must stay in the range between 1 and the height of the relative silicon plate found
constraint forall(i in CIRCUITS)(corner_coords[i, 2] >= 0 /\ corner_coords[i, 2] < height);

% 1 <= height <= max_height
% constraint height >= 1 /\ height <= max_height();

% min_height <= height <= max_height
% This is based on the fact that the height should be at least equal to the smallest height present in the list of circuits
constraint height >= min_height /\ height <= max_height;

constraint free_area >= 0;

% ****************************************  Search  *********************************************************

solve 
minimize free_area() 
:: int_search(corner_coords, first_fail, indomain_random)
:: restart_geometric(1.5,100)
      ;
      

output [show(width)++" "++show(height)++" "++show(free_area)++"\n"]++
       [show(n_circuits)++"\n"]++
       [show(dims[i,1]) ++" "++ show(dims[i,2]) ++" "++ show(corner_coords[i,1]) ++" "++show(corner_coords[i,2])++"\n" | i in 1..n_circuits]
      