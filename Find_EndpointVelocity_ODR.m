function [startpoint endpoint velocity] = Find_EndpointVelocity_ODR(AllData,ntr)
% for velocity, delete trials which has high velosity higher than
% velocity=maxdist(distance between two points)/2ms
% at the begining, use triangle smooth
% Downsample to 4 ms
% xzhou, modified at 18-may-2011
% for prosac
% used for final analysis,11-Dec-2012

velocity = nan;
try
    indexON =find((AllData.trials(ntr).EyeData(:,3)-AllData.trials(ntr).EyeData(1,3))>=AllData.trials(ntr).FixOff-AllData.trials(ntr).time-0.5);
    indexOFF =find((AllData.trials(ntr).EyeData(:,3)-AllData.trials(ntr).EyeData(1,3))>=AllData.trials(ntr).FixOff-AllData.trials(ntr).time);
    
    x = AllData.trials(ntr).EyeData(indexON:indexOFF,1) * 3.5;       %yeye
    y = AllData.trials(ntr).EyeData(indexON:indexOFF,2) * 3.5;       %xeye
    t = AllData.trials(ntr).EyeData(indexON:indexOFF,3);
    
    numpoints = length(x);
    newx(1)=x(1);
    newy(1)=y(1);
    i = 3;
    n=2;
catch
    lasterr
end

try
    %%%%%%%%%%%%%% 5 points smooth %%%%%%%%%%%%%%%%%
    while i < numpoints-2
        newx(n) = (x(i-2)+2*x(i-1)+3*x(i)+2*x(i+1)+x(i+2))/9;
        newy(n) = (y(i-2)+2*y(i-1)+3*y(i)+2*y(i+1)+y(i+2))/9;
        i=i+2;
        n=n+1;
    end
    
    numpoints = length(newx);
    % HIVELOCITY = min(10,(max(max(abs(diff(x))),max(abs(diff(y))))./0.002-100)* 0.002);
    % HIVELOCITY = (max(max(abs(diff(newx))),max(abs(diff(newy))))./0.002-100)* 0.002;
    % if HIVELOCITY >1
    %     HIVELOCITY=0.2;     % 120 degree/s
    % end
    %%%%%%%%%%%%%%%%%%%%%%% calculate the hivelocity %%%%%%%%%%%%%%%%%%%%%
    totaldist= [];
    for ii = 2:1:numpoints
        try
            twopoint_dist = sqrt((newx(ii)-newx(ii-1))*(newx(ii)-newx(ii-1))+(newy(ii)-newy(ii-1))*(newy(ii)-newy(ii-1)));
            totaldist=[totaldist twopoint_dist];
        catch
            lasterr
        end
    end
    totaldist = totaldist(find(totaldist<=0.8 & totaldist>=0.3));
    HIVELOCITY = sum(totaldist)/length(totaldist);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    startpoint=0;
    endpoint=numpoints-1;
    realsac=0;
    hiveltime=1;
    i=0;
catch
    lasterr
end


try
    while realsac==0
        if hiveltime>numpoints
            %         disp(['hivelocity error on trial ' num2str(ntr) ]);
            Velosity = nan;
            startpoint = nan;
            endpoint = nan;
            return
        end
        
        % Find distance between two successive eye position points
        i=hiveltime+1;
        while i<numpoints
            dist=sqrt((newx(i)-newx(i-1))*(newx(i)-newx(i-1))+(newy(i)-newy(i-1))*(newy(i)-newy(i-1)));
            if dist>HIVELOCITY
                hiveltime=i;
                i=numpoints;
            end
            i=i+1;
        end
        
        i=numpoints;
        hiveltime1 = hiveltime;
        while i >= hiveltime1
            dist=sqrt((newx(i)-newx(i-1))*(newx(i)-newx(i-1))+(newy(i)-newy(i-1))*(newy(i)-newy(i-1)));
            if dist>HIVELOCITY
                hiveltime2 =i;
                i= hiveltime1-1;
            end
            i=i-1;
        end
        
        % Find first point of monotonic eye position drift towards high-velocity point
        i=hiveltime-1;
        lastdist=0;
        if max(abs(newy)) > 7
            if max(abs(newx)) >7
                newxeffector =1;
                newyeffector =1;
            else
                newyeffector = 1;
                newxeffector =0;
            end
        else
            newxeffector = 1;
            newyeffector = 0;
        end
        while i>0
            dist=sqrt((newx(i)-newx(hiveltime))*(newx(i)-newx(hiveltime))*newxeffector+(newy(i)-newy(hiveltime))*(newy(i)-newy(hiveltime))*newyeffector);
            if dist<lastdist
                startpoint=i;
                i=0;
            end
            i=i-1;
            lastdist=dist;
        end
        startpoint=startpoint+1;
        
        % Find last point of monotonic eye position drift away from high-velocity point
        i=hiveltime2+1;
        lastdist=0;
        while i<=numpoints
            dist=sqrt((newx(i)-newx(hiveltime2))*(newx(i)-newx(hiveltime2))*newxeffector+(newy(i)-newy(hiveltime2))*(newy(i)-newy(hiveltime2))*newyeffector);
            if dist < lastdist % remove '='
                endpoint=i-1;  %i-2
                i=numpoints+1;
            end
            i=i+1;
            lastdist=dist;
        end
        
        if startpoint ==0;
            startpoint = 1;
        end
        
        i = startpoint ;
        w=1;
        totaldist=sqrt((newx(startpoint)-newx(endpoint))^2+(newy(startpoint)-newy(endpoint))^2);
        maxdist=0;
        dist=0;  %
        while i < endpoint-2
            dist(1,w)=sqrt((newx(i)-newx(i+1))^2+(newy(i)-newy(i+1))^2);
            if dist(1,w)>maxdist
                maxdist=dist(1,w);
            end
            i = i + 1;
            w=w+1;
        end
        
        if totaldist>2 && (endpoint-startpoint)>10 && maxdist<8
            realsac=1;
        else
            hiveltime=hiveltime+1;
        end
    end
catch
    lasterr
end
try
    velocity = maxdist./(2*(t(startpoint+1) - t(startpoint)));
catch
    velocity = nan;
end
% startpoint = startpoint*2 + indexON(1)-1;
startpoint = startpoint*2 + indexON(1)-1;
endpoint = endpoint*2 + indexON(1)-1;

%%%%%%%%%%%%%% tracking eye and endpoint %%%%%%%%%%%%%%%%%%%

% try
%     xeye = AllData.trials(ntr).EyeData(endpoint,2) * 3.5;
%     yeye = AllData.trials(ntr).EyeData(endpoint,1) * 3.5*(-1);
%     figure
%     plot(newy,newx*(-1),'*--')
%     hold on
%     xlim([-15 15])
%     ylim([-15 15])
%     plot(xeye,yeye,'s')
% catch
%     xeye = NaN;
%     yeye = NaN;
% end

