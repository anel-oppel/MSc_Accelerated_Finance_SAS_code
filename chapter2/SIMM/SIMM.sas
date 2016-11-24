/*
*For LATeX output;
ods _all_ close;
%let MyPath = C:\Users\Anel\Desktop\D_dissertation\chapters\chapter2;
ods graphics / outputfmt=png;
*/
*Simulate data to be used in one-shot device test;
proc iml;

*import the parameters of the non-linear model;
use dissn.nlinout_log ;
read all into std;

std=std[1,ncol(std)-1:ncol(std)];
*print std;
*the percentile value at which a failure will be defined;
alpha=0.05;
N=400;*actually the time variable, let the process run from t=0 to t=400;
M=1000;*The number of companies each of market capitalization size S;
mu=0;
****************Select the failure threshold based on the percentile of a small market capitalization company;
smallCap=0.01*(10**9);
X=log(smallCap)//{1};
factor=std*X;
sigmaf=exp(-factor);*create the standard deviation of the return based on the output from the non-linear model;
*print sigmaf;
Tcll=(probit(alpha)*sigmaf)+mu;*The percentile which will be the failure threshold;
*print Tcll;
Tclu=(probit(1-alpha)*sigmaf)+mu;
*print Tclu;
****************End;

do s=0.1 to 1 by 0.01; 
	markCapp=s*(10**9);*The stress factor in Billions;
	X=log(markCapp)//{1};
	factor=std*X;
	sigma=exp(-factor);*create the standard deviation of the return based on the output from the non-linear model;
	*print sigma;
	call randseed(0);
	Rt=J(N,1,0);
	count=J(1,3,0);
	*************************************;
	do r=1 to 3; *The number of inspection times;
		do k=1 to M;* The number devices under current test condition;			
			call randgen(Rt, "Normal", Mu, Sigma);*Populate the return matrix;
			***Let's say we are interested in a loss and not a gain;
			Rt=-Rt;
			*count the number of failed companies under current test condition, a failure is a loss above threshold;
			if (((Rt[1:int(N-1/r),])>=Tclu)[+])>0 then count[,r]=count[,r]+1;
		end;
	*Create data matrix;
	DATAM=DataM//(markCapp||count[,r]||int(N/r));
	end;
end;

*Create the data matrix;
NMat=repeat(M,nrow(DATAM));
print Nmat;
DATAM=DATAM||NMat;
create dissN.relia from DATAM[colname={'markCapp' 'r' 'IT' 'M'}];
append from DATAM;

quit;
/*
*For LATeX output;
ods html file="&MyPath.\Output\SIMM\data.htm" gpath="&MyPath.\Figures\SIMM";
ods tagsets.tablesonlylatex file="&MyPath.\SIMM\data.tex"(notop nobot) 
newfile=table stylesheet="sas.sty"(url="sas") gpath="&MyPath.\Figures\SIMM";
*/
*Print the data matrix;
proc print data=dissN.relia;
run;
quit;
/*
*For LATeX output;
ods graphics on/imagename="fails";
ods html file="&MyPath.\Output\SIMM\fails.htm" gpath="&MyPath.\Figures\SIMM";
ods tagsets.tablesonlylatex file="&MyPath.\SIMM\fails.tex"(notop nobot) 
newfile=table stylesheet="sas.sty"(url="sas") gpath="&MyPath.\Figures\SIMM";
*/
**************Graphing procedure to graph the number of failed companies under each test condition
**************Code exported form ODS Graphics designer;
proc template;
define statgraph sgdesign;
dynamic _MARKCAPP _R _IT;
begingraph;
   entrytitle halign=center 'The failures observed for different size companies at 3 different inspection times';
   layout lattice / rowdatarange=data columndatarange=data rowgutter=10 columngutter=10;
      layout overlay / xaxisopts=( discreteopts=( tickvaluefitpolicy=splitrotate));
         barchart category=_MARKCAPP response=_R / group=_IT name='bar' stat=mean groupdisplay=Cluster clusterwidth=0.85;
         discretelegend 'bar' / opaque=false border=true halign=right valign=top displayclipped=true across=1 order=rowmajor location=inside;
      endlayout;
   endlayout;
endgraph;
end;
run;

proc sgrender data=DISSN.RELIA template=sgdesign;
dynamic _MARKCAPP="MARKCAPP" _R="R" _IT="IT";
run;
*************End;


