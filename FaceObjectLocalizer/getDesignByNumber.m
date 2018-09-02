function displayOrder = getDesignByNumber(numOfDesign)

% Get the correct design.
switch numOfDesign
    case 1
        displayOrder = [ 0 1 2 1 2 0 1 1 2 2 0 2 2 1 1 0 2 1 2 1 0 ];
    case 2
        displayOrder = [ 0 2 2 1 1 0 2 1 2 1 0 1 2 1 2 0 1 1 2 2 0 ];
    case 3
%         displayOrder = [ 0 1 2 1 2 0 1 1 2 2 ];
        displayOrder = [ 0 1 2 ];
    otherwise
        error([ 'There is no design ' num2str(numOfDesign) '.' ]);
end