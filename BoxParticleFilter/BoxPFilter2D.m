%*********************************************************************** 
%									 
%	-- 2D box particle filtering. 
%
%
%	- Usage = 
%		[w_boxes,x_med] = BoxPFilter2D(N,Boxes,ts,stateFunction,stateInput,pe,show,w_boxes0)
%
%	- inputs =
%		- N - INT, number of boxes (can be slightly different if the number
%		doesn't have an integer square root).
%		- Boxes - CELL ARRAY, defines all boxes
%       - ts - DOUBLE, sampling time
%       - stateFunction - LAMBDA FUNCTION, state evolution
%       - stateInput - CELL ARRAY, state function input
%       - pe - CELL ARRAY, landmark distribution functions in (x,y) and time
%       - [OPTIONAL] show - BOOL, if true, show the number of each time
%       step (default = false).
%       - [OPTIONAL] w_boxes0 - DOUBLE ARRAY, probability distribution at
%       initial time (default = ).
%
%	- outputs = 	
%       - w_boxes - CELL ARRAY, probability distribution at each step
%       - x_med - DOUBLE ARRAY, estimation using w_boxes
%									 
%	-> MATLAB version used:	
%		- 9.0.0.341360 (R2016a) 64-bit	
%				 
% 	-> Special toolboxes used: 
%		-- none	--
%
% 	-> Other dependencies: 
%		- Interval.m
%		- measurementUpdate.m
%		- stateUpdate.m
%									 
%	-> Created by Evandro Bernardes	 								 
%		- at IRI (Barcelona, Catalonia, Spain)							 								 
%									 
% 	Code version:	1.1
%   - optional variables processing corrected
%
%	last edited in:	01/06/2017 						 
%									 
%***********************************************************************
function [w_boxes,x_med] = BoxPFilter2D(N,Boxes,ts,stateFunction,stateInput,pe,varargin)
   
    w_boxes = cell(N,1);
    x_med=zeros(N,2); % prealocating for performance
    
    switch(nargin)
        case 7
            show = varargin{1};
            w_boxes{1}=1/numel(Boxes)*ones(size(Boxes));
        case 8
            show = varargin{1};
            w_boxes{1} = varargin{2};
        otherwise
            show = false;
            w_boxes{1}=1/numel(Boxes)*ones(size(Boxes));
    end

    %% Main loop
    % here the box particle filtering algorithm is implemented
    pek = cell(size(pe));
    for k=1:N,
        if(show)
            disp(k)
        end
        %% Measurement update
        for m = 1:length(pek)
            pek{m} = @(x,y) pe{m}(x,y,k);
        end  

        % measurement update
        [w_boxes{k},x_med(k,:)] = measurementUpdate(w_boxes{k},Boxes,pek);    

        %% State update Resampling    
        % Use input to calculate stateUpdate;
        w_boxes{k+1} = stateUpdate(w_boxes{k},Boxes,stateFunction,stateInput{k},ts);
    end
end
