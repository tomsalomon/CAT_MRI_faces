while 1
    [avail, ~, keyCode] = KbCheck;
    if avail ~= 0 
       
        keyFinder           = find(keyCode);
        keyFinder           = keyFinder(1);
        
        disp(['keyFinder: ' num2str(keyFinder)]);
    end
end