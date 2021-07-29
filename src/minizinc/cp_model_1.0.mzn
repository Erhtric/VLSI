%VLSI

% include "globals.mzn";

% ****************************************  PARAMETERS  *****************************************************

int: w;    % width of the board
int: n;    % number of circuits to place

% array of values of the following form:
%    <x1, y1, x2, y2, ..., xn, yn>
% where xi, yi represent the dimensions of the edges of the rectangle.
array[int] of int: dims;  

% ****************************************  Decision variables  *********************************************

% our decision variables are the corner's positions in the silicon plate (represented in a similar manner to the dimensions)
array[int] of int: corner_final;

% the height of the resulting silicon plate is the sum of something. 

% ****************************************  Functions  ******************************************************

% It returns the i-th horizontal dimension (one of the n possible ones).
function var int: get_x(array[int] of var int: coords, int: i) = coords[2*i - 1];

% It returns the i-th vertical dimension (one of the n possible ones).
function var int: get_y(array[int] of var int: coords, int: i) = coords[2*i];  

% ****************************************  Predicates  *****************************************************    

% ****************************************  Constraints  ****************************************************

% For now we will suppose that each piece cannot be rotated.

% ****************************************  Search  *********************************************************

       