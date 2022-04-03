%%%
%  Calculate the propellent properties of hybrid rocket
%  with different chamber pressure, OF ratio and expansion ratio 
%  only use for hydrogen peroxide and HTPB combination

%  creat a file name for NASA CEA inputdata
filename=('propellant_properties.inp')
filename2=('propellant_properties.plt')

% set up  OF ratio range

OF=[0.5:0.01:10];
datalength=length(OF);

% load input data

 load('inputdata')

 pc=inputdata.pc;                            % chamber pressure
 casename=inputdata.casename;
 AR=inputdata.AR ;                           % expansion ratio
 pe=inputdata.pe;
 HTPB=inputdata.HTPB;
 IPDI=inputdata.IPDI;
 
 pclength=length(pc);
 ARlength=length(AR);
 

for i=1:pclength
  for j=1:ARlength
    for k=1:datalength

   
    fw=fopen(filename,'w');
    fprintf(fw,'problem \r\\n');             %  write cea problem
    fprintf(fw,'case=%1.2f\r\',casename);    %  write case name
    fprintf(fw,'o/f=%1.2f\r\n',OF(k));        %  write o/f ratio variable
    fprintf(fw,'rocket equilibrium\r\n')     %  write equilibrium question
    fprintf(fw,'tcest, k=3800\r\n'); 
    fprintf(fw,'p,psia=%1.2f\r\n',(pc(i));          %  write chamber pressure variable
 %  fprintf(fw,'pi/p=%1.2f\r\n', (pc(i)/pe); %  write pressure ratio variable
    fprintf(fw,'supar=%1.2f\r\n', AR(j));       %  write expansion ratio variable
    fprintf(fw,'react\r\n');
    fprintf(fw,'oxid=O2 wt= 55.28 t,k=1144\r\n');
    fprintf(fw,'oxid=H2O wt= 44.72 t,k=1144\r\n');

    fprintf(fw,'fuel=HTPB wt=%1.2f t,k=300\r\n',HTPB.wt);
    fprintf(fw,'h, cal/mol=%1.2f\r\n',HTPB.enthalpy);
    fprintf(fw,'C %1.2f H %1.2f O %1.2f\r\n',HTPB.atom.C,HTPB.atom.H,HTPB.atom.O);
    fprintf(fw,'fuel=IPDI wt=%1.2f t,k=300\r\n',IPDI.wt);    
    fprintf(fw,'h, cal/mol=%1.2f\r\n',IPDI.enthalpy);
    fprintf(fw,'C %1.2f H %1.2f O %1.2f N %1.2f\r\n',IPDI.atom.C,IPDI.atom.H,IPDI.atom.O,IPDI.atom.N);

    fprintf(fw,'output\r\n');                           % write output result
    fprintf(fw,'siunits\r\n');                          % write siunits
    fprintf(fw,'plot p t gam mw pip isp son\r\n');      % write chamber pressure, temperature, gamma, molecular weight, pressure ratio, isp, sonic
    fprintf(fw,'end\r\n');                              % write end
    fclose(fw);

    system('FCEA2.exe<auto.inp'); % execute nasa cea    % filename should be write down in the auto.inp before cea execute

    [pressure, temp, gamma, mole_weight, pip,ispcea,sonic]=textread(filename2, '%f%f%f%f%f%f%f', 'commentstyle', 'shell');
 
    %  read data from .plt --> read 5 parameters at 3 position 
    %  --> position 1 = chamber, position 2 =nozzle throat, position 3 = nozzle exit
    % use 'commentstyle','shell' can skip # words

    ga=gamma(1);                         %chamber gamma
    velocity=sonic(1);                   %chamber sonic
    Ga=ga*(((2/(ga+1))^((ga+1)/(ga-1)))^0.5);   
    cstar(k)=velocity/Ga;
    isp(k)=(ispcea(3)/9.80665);

    end

cstar=cstar';
isp=isp';
result(:,:,j,i)=[pc(1:k),OF(1:k),cstar(1:k)];

  end 
end
save('cstar_cal.txt','result','-ascii')
