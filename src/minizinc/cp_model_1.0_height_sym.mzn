% VLSI
% 1.0.0_sym release: NO Global constraints, NO Rotations, Height version

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
int: max_height = sum([max([dims[c,d] | d in 1..2]) | c in CIRCUITS]);
int: min_height = min([dims[c, 2] | c in CIRCUITS]);

% ****************************************  Decision variables  *********************************************

% our decision variables are the corner's positions (expressed in coordinates) in the silicon plate (represented in a similar manner to the dimensions)
%    <x1,y1, ..., xn, yn>
array[CIRCUITS, 1..2] of var int: corner_coords;

% the height of the resulting silicon plate
var int: height = height();

% ****************************************  Functions  ******************************************************

function var int: height() = max([corner_coords[c, 2] + dims[c, 2] | c in CIRCUITS]);

% ****************************************  Predicates  *****************************************************    

% ****************************************  Constraints  ****************************************************

% For now we will suppose that each piece cannot be rotated.

% No-overlap constraint
constraint forall(i in CIRCUITS, j in CIRCUITS where i != j)( 
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

% DOES NOT WORK 
constraint symmetry_breaking_constraint(
  let {
    % Alternative model: we express the plate as a matrix where each cell has a designated value 0 or i
    % 0 stands for the background, i for the fact that the circuit i occupy that space
    array[1..max_height, WIDTH] of var 0..n_circuits: plate} in
      % channeling constraint
      forall(i in CIRCUITS)(
        forall(vx in 0..dims[i, 1], vy in 0..dims[i, 2])(
          let {var int: x = corner_coords[i, 1], var int: y = corner_coords[i, 2]} in 
            plate[y + vy, x + vx] = i 
        ))
      % each coordinate should be greater than (not using the old model)
%       /\ lex_greater([corner_coords[c, d] | c in CIRCUITS, d in 1..2], [])
      % Rotation of 180
      % It does not make sense to add 1
      /\ lex_lesseq(array1d(plate), [plate[y,x] | y in reverse(1..max_height), x in reverse(WIDTH)])
      % Original flipped
      /\ lex_lesseq(array1d(plate), [plate[y,x] | y in reverse(1..max_height), x in WIDTH]) 
      % Rotation of 180 flipped
      /\ lex_lesseq(array1d(plate), [plate[y,x] | y in 1..max_height, x in reverse(WIDTH)])
 );

% ****************************************  Search  *********************************************************

solve 
minimize height()
:: int_search(corner_coords, first_fail, indomain_min)
:: restart_geometric(1.5,100)
      ;
      

output [show(width)++" "++show(height)++"\n"]++
       [show(n_circuits)++"\n"]++
       [show(dims[i,1]) ++" "++ show(dims[i,2]) ++" "++ show(corner_coords[i,1]) ++" "++show(corner_coords[i,2])++"\n" | i in 1..n_circuits]++["\n"]
      