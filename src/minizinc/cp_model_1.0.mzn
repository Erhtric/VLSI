%VLSI

% include "globals.mzn";

% ****************************************  PARAMETERS  *****************************************************

int: width;    % width of the board
int: n_circuits;    % number of circuits to place

set of int: WIDTH = 1..width;
set of int: CIRCUITS = 1..n_circuits;

% array of values of the following form:
%    <x1, y1, x2, y2, ..., xn, yn>
% where xi, yi represent the dimensions of the edges of the rectangle.
int: m = 2 * n_circuits;
array[1..m] of int: dims;  

% ****************************************  Decision variables  *********************************************

% our decision variables are the corner's positions (expressed in coordinates) in the silicon plate (represented in a similar manner to the dimensions)
%    <c1,c2, ..., cn, cn>
array[1..m] of var int: corner_coords;

% the height of the resulting silicon plate is the sum of something. AND IT SHOULD BE MINIMIZED
var int: height = height();

% ****************************************  Functions  ******************************************************

% Distance function
function var int: 
  distance(var int: x1, var int: y1, var int: x2, var int: y2) = max(abs(x1 - x2), abs(y1 - y2));

% It returns the i-th horizontal dimension (one of the n possible ones).
function var int: get_x(array[int] of var int: coords, int: i) = coords[2*i - 1];

% It returns the i-th vertical dimension (one of the n possible ones).
function var int: get_y(array[int] of var int: coords, int: i) = coords[2*i];  

function var int: height() = max([get_y(corner_coords, c) + get_y(dims, c) | c in CIRCUITS]);

% ****************************************  Predicates  *****************************************************    

% ****************************************  Constraints  ****************************************************

% constraint forall(c1 in CIRCUITS, c2 in CIRCUITS where c1 != c2)( 
%   distance(get_x(corner_coords, c1), get_y(corner_coords, c1), get_x(corner_coords, c2), get_y(corner_coords, c2)) >= get_x(dims, c1)
%   \/ distance(get_x(corner_coords, c1), get_y(corner_coords, c1), get_x(corner_coords, c2), get_y(corner_coords, c2)) >= get_y(dims, c1)
% );


constraint forall(c1 in CIRCUITS, c2 in CIRCUITS where c1 != c2)( 
  get_x(corner_coords, c2) >= get_x(corner_coords, c1) + get_x(dims, c1)
  \/ get_y(corner_coords, c2) >= get_y(corner_coords, c1) + get_y(dims, c1)
 );


% table
constraint forall(c in CIRCUITS)(get_x(corner_coords, c) + get_x(dims, c) <= width);

% 1 <= x <= width
% table
constraint forall(i in CIRCUITS)(get_x(corner_coords, i) >= 1 /\ get_x(corner_coords, i) <= width);

% 1 <= y <= height
constraint forall(i in CIRCUITS)(get_y(corner_coords, i) >= 1 /\ get_y(corner_coords, i) <= height);

% For now we will suppose that each piece cannot be rotated.

% ****************************************  Search  *********************************************************

solve 
% minimize solutions_distance() 
:: int_search(corner_coords, first_fail, indomain_min)
:: restart_geometric(1.5,100)
satisfy
      ;
      