%微信公众号搜索：淘个代码，获取更多免费代码
%禁止倒卖转售，违者必究！！！！！
%唯一官方店铺：https://mbd.pub/o/author-amqYmHBs/work
%代码清单：https://docs.qq.com/sheet/DU3NjYkF5TWdFUnpu
%%
%_______________________________________________________________________________________
%  The Bermuda Triangle Optimizer (BTO) source codes demo (version  2.0)
% This code is created based on randomness and choas methods, So run it
% multible times to configure and train all the parameters of BTO 
%                                                                                                             
%                                                                                     
% Reference: Hisham A. Shehadeh, Bermuda Triangle
% Optimizer (BTO): A Novel Metaheuristic Method for Global Optimization, 
% Vol. 17, No. 2, July 2025. DOI: 10.15849/IJASCA.250730.01 
%
% email: sh7adeh1990@hotmail.com
%_______________________________________________________________________________________

function [Best_FF,Best_P,Conv_curve]=BTO(N,M_Iter,LB,UB,Dim,F_obj)
% display('BTO Working');
%the variables 

Best_P=zeros(1,Dim);
Best_FF=inf;
Conv_curve=zeros(1,M_Iter);

%Initialize the solutions (attracted objects)
X=initialization(N,Dim,UB,LB);
Xnew=X;
Ffun=zeros(1,size(X,1));% (fitness values)
Ffun_new=zeros(1,size(Xnew,1));% (fitness values)

PoF_Max=log(1510000); %Bermuda max area
PoF_Min=log(500000); % Bermuda min area 
C_Iter=1;
g= 6.67*10^-11;  %(constant of universal gravitation)
   G=(log10((1-g)*rand(1,1)+1));

   distance = rand();
   
force=(G*rand()*rand())/(distance^2);  %force lows Eq.(22)

triangle_area = 0.5*rand()*rand(); % Eq.(26)
Circle_area = (3.14*rand()*rand())-triangle_area; %Eq.(27)
            



for i=1:size(X,1)
    Ffun(1,i)=F_obj(X(i,:));  %Calculate the fitness values of attracted objects (solutions)
    if Ffun(1,i)<Best_FF
        Best_FF=Ffun(1,i);
        Best_P=X(i,:);
    end
end
    
    

while C_Iter<M_Iter+1  %Main loop
    %The p-value is the probability that the null hypothesis is true. (1 – the p-value) is the probability that the alternative hypothesis is true.
   PoF=1-((C_Iter)^(1/force)/(M_Iter)^(1/force));   % The probability ratio of Bermuda force Eq.(24)
   
    Zone_Bermuda=PoF_Min+C_Iter*(abs(PoF_Max-PoF_Min)/M_Iter); %The zone of Bermuda force Eq.(23)
   
    %Update the Position of attracted objects (Solutions)
    for i=1:size(X,1)   %  UB and LB has a just value 
        for j=1:size(X,2)
           
            
              m=chaos(5,1,1); %Choas equations 
            
             r1=rand();
            if (size(LB,2)==1 )
                if r1>0.5       %Eq.(28)
                    %The object inside bermuda, it already has massive attraction force. 
                    %PoF = (1 – the p-value) is the probability that the alternative hypothesis is true.
                    %If the probability of force is p, then the probability
                    %of no force is (1 – the p-value), that is why we use  subtraction operation in Eq.(28) section 1 
                    
                        Xnew(i,j)=m*triangle_area*(rand()*2.7^(-20*(C_Iter/M_Iter))*(Best_P(1,j)-PoF*((UB-LB)*Zone_Bermuda+LB)));
                else
                    % The object is outside Bermuda, so we need more
                    % attraction force to pull it inside Bermuda triangle 
                   
                         
                        Xnew(i,j)=m*Circle_area*(rand()*2.7^(-20*(C_Iter/M_Iter))*(Best_P(1,j)+PoF*((UB-LB)*Zone_Bermuda+LB)));
                    
                end                  
            end
            
           
           if (size(LB,2)~=1)   % if each of the UB and LB has more than one value 
                r1=rand();
                if r1>0.5   %Eq(28)
                    
                        Xnew(i,j)=m*triangle_area*(rand()*2.7^(-20*(C_Iter/M_Iter))*(Best_P(1,j)-PoF*((UB(j)-LB(j))*Zone_Bermuda+LB(j))));
                    else
                        Xnew(i,j)=m*Circle_area*(rand()*2.7^(-20*(C_Iter/M_Iter))*(Best_P(1,j)+PoF*((UB(j)-LB(j))*Zone_Bermuda+LB(j))));
                    
                end                
            end
            
        end
        
        Flag_UB=Xnew(i,:)>UB; % exceed (up) the boundaries
        Flag_LB=Xnew(i,:)<LB; % exceed (down) the boundaries
        Xnew(i,:)=(Xnew(i,:).*(~(Flag_UB+Flag_LB)))+UB.*Flag_UB+LB.*Flag_LB;
 
        Ffun_new(1,i)=F_obj(Xnew(i,:));  % calculate Fitness function 
        if Ffun_new(1,i)<Ffun(1,i)
            X(i,:)=Xnew(i,:);
            Ffun(1,i)=Ffun_new(1,i);
        end
        if Ffun(1,i)<Best_FF
        Best_FF=Ffun(1,i);
        Best_P=X(i,:);
        end
       
    end
    

    %Update the convergence curve
    Conv_curve(C_Iter)=Best_FF;
    
    %Print the best solution details after every 50 iterations
    if mod(C_Iter,50)==0
        display(['At iteration ', num2str(C_Iter), ' the best solution fitness is ', num2str(Best_FF)]);
    end
     
    C_Iter=C_Iter+1;  % incremental iteration
   
end
end


function O=chaos(index,max_iter,Value)
O=zeros(1,max_iter);
x(1)=0.7;
switch index
%Chebyshev map
    case 1
for i=1:max_iter
    x(i+1)=cos(i*acos(x(i)));
    G(i)=((x(i)+1)*Value)/2;
end
    case 2
%Circle map
a=0.5;
b=0.2;
for i=1:max_iter
    x(i+1)=mod(x(i)+b-(a/(2*pi))*sin(2*pi*x(i)),1);
    G(i)=x(i)*Value;
end
    case 3
%Gauss/mouse map
for i=1:max_iter
    if x(i)==0
        x(i+1)=0;
    else
        x(i+1)=mod(1/x(i),1);
    end
    G(i)=x(i)*Value;
end
    case 4
%Iterative map
a=0.7;
for i=1:max_iter
    x(i+1)=sin((a*pi)/x(i));
    G(i)=((x(i)+1)*Value)/2;
end
    case 5
%Logistic map
a=4;
for i=1:max_iter
    x(i+1)=a*x(i)*(1-x(i));
    G(i)=x(i)*Value;
end
    case 6
%Piecewise map
P=0.4;
for i=1:max_iter
    if x(i)>=0 && x(i)<P
        x(i+1)=x(i)/P;
    end
    if x(i)>=P && x(i)<0.5
        x(i+1)=(x(i)-P)/(0.5-P);
    end
    if x(i)>=0.5 && x(i)<1-P
        x(i+1)=(1-P-x(i))/(0.5-P);
    end
    if x(i)>=1-P && x(i)<1
        x(i+1)=(1-x(i))/P;
    end    
    G(i)=x(i)*Value;
end
    case 7
%Sine map
for i=1:max_iter
     x(i+1) = sin(pi*x(i));
     G(i)=(x(i))*Value;
 end
    case 8
 %Singer map 
 u=1.07;
 for i=1:max_iter
     x(i+1) = u*(7.86*x(i)-23.31*(x(i)^2)+28.75*(x(i)^3)-13.302875*(x(i)^4));
     G(i)=(x(i))*Value;
 end
    case 9
%Sinusoidal map
 for i=1:max_iter
     x(i+1) = 2.3*x(i)^2*sin(pi*x(i));
     G(i)=(x(i))*Value;
 end
 
    case 10
 %Tent map
 x(1)=0.6;
 for i=1:max_iter
     if x(i)<0.7
         x(i+1)=x(i)/0.7;
     end
     if x(i)>=0.7
         x(i+1)=(10/3)*(1-x(i));
     end
     G(i)=(x(i))*Value;
 end
end
O=G;
end




%微信公众号搜索：淘个代码，获取更多免费代码
%禁止倒卖转售，违者必究！！！！！
%唯一官方店铺：https://mbd.pub/o/author-amqYmHBs/work
%代码清单：https://docs.qq.com/sheet/DU3NjYkF5TWdFUnpu
