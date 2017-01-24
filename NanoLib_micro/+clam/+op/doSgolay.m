function [outSG0, outSG1] = doSgolay(xOriginal,yOriginal,N,F,doPlot)
% DOSGOLAY - Savitzky-Golay filter design applied on the ROW of either 
% a row-vector or a matrix.
%
% INPUT
% xOriginal : of the original value of x
% yOriginal : either row-vector or Matrix of the original value of y (to be smoothed)
% N : Order of polynomial fit (e.g. 4)
% F : Window length (e.g.21)
%
% OUTPUT
% SG0 : y  smoothed by Savitzky-Golay filter design
% SG1 : dy smoothed by Savitzky-Golay filter design
%
% NOTE: the filter will smooth values starting from the first term plus
% half the window length to the last term minus half the window length.
% (e.g. for N = 100 number of element and F = 21 the length of the window,
% only values between 11 and 90 will be smoothed.

% Zanin and Vindigni - 22.03.2013



narginchk(4,5)
if nargin == 4
    doPlot = false;
end

%disp('Savitzky-Golay filter design on data');

xSize = size(xOriginal);
outSG0 = zeros(xSize);
outSG1 = zeros(xSize(1),xSize(2)-1);

[~,g] = sgolay(N,F);   % Calculate S-G coefficients

 for ii = 1:xSize(1);
    % definition of the variables to smooth
    x = xOriginal(ii,:); % H.fwd.matrix(ii,:)
    dx = diff(x);
    y = yOriginal(ii,:); % M.fwd.matrix(ii,:)
    SG0 = y;
    SG1 = diff(y);

    HalfWin  = ((F+1)/2) -1; % half windows
    for n = (F+1)/2:length(y)-(F+1)/2,
        % Zero-th derivative (smoothing only)
        SG0(n) =   dot(g(:,1), y(n - HalfWin: n + HalfWin));

        % 1st differential
        SG1(n) =   dot(g(:,2), y(n - HalfWin: n + HalfWin));

%         % 2nd differential
%         SG2(n) = 2*dot(g(:,3)', y(n - HalfWin: n + HalfWin))';
    end

    % dx = dx(1:length(y)-(F+1)/2);
    SG1 = SG1./dx;         % Turn differential into derivative
%     SG2 = SG2./(dx.*dx);    % and into 2nd derivative

    if doPlot
            % Scale the "diff" results
            DiffD1 = (diff(y(1:length(SG0))))./ dx; 
            % DiffD2 = (diff(diff(y(1:length(SG0)+2)))) ./ (dx.*dx);

            subplot(2,1,1);
            plot(x(1:length(SG0))',[y(1:length(SG0))', SG0'])
            legend('Noisy Sinusoid','S-G Smoothed sinusoid','Location','NorthOutside')

            subplot(2, 1, 2);
            plot(x(1:length(SG1))',[DiffD1',SG1'])
            legend('Diff-generated 1st-derivative','S-G Smoothed 1st-derivative','Location','NorthOutside')
            
            wd = helpdlg('check smoothing of the plots','Plot smoothing');
            waitfor(wd);
    end
    
    % define matrices
    outSG0(ii,:) = SG0;
    outSG1(ii,:) = SG1;
 end