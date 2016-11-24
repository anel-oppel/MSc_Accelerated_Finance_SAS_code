*For LATeX output;
ods _all_ close;
%let MyPath = C:\Users\Anel\Desktop\D_dissertation\chapters\chapter2\Round2;
ods graphics / outputfmt=png;

*Simulate data to be used in one-shot device test;
proc iml;

*import the parameters of the non-linear model;
use dissn.nlinout_log ;
read all into std;

std=std[1,ncol(std)-1:ncol(std)];
*print std;
*the percentile value at which a failure will be defined;
alpha=0.01;
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
create dissN.relia_99 from DATAM[colname={'markCapp' 'r' 'IT' 'M'}];
append from DATAM;

quit;

*For LATeX output;
ods html file="&MyPath.\Output\SIMM\data.htm" gpath="&MyPath.\Figures\SIMM";
ods tagsets.tablesonlylatex file="&MyPath.\SIMM\data.tex"(notop nobot) 
newfile=table stylesheet="sas.sty"(url="sas") gpath="&MyPath.\Figures\SIMM";

*Print the data matrix;
proc print data=dissN.relia_99;
run;
quit;

*For LATeX output;
ods graphics on/imagename="fails";
ods html file="&MyPath.\Output\SIMM\fails.htm" gpath="&MyPath.\Figures\SIMM";
ods tagsets.tablesonlylatex file="&MyPath.\SIMM\fails.tex"(notop nobot) 
newfile=table stylesheet="sas.sty"(url="sas") gpath="&MyPath.\Figures\SIMM";

data dissN.relia_99;
set dissN.relia_99;
markCapp=markCapp/1000000000;
run;
quit;

**************Graphing procedure to graph the number of failed companies under each test condition
**************Code exported form ODS Graphics designer;
proc template;
define statgraph sgdesign;
dynamic _MARKCAPP _R _IT;
begingraph / designwidth=1160 designheight=624;
   entrytitle halign=center 'The failures obsereved for different company sizes';
   layout lattice / rowdatarange=data columndatarange=data rowgutter=10 columngutter=10;
      layout overlay / xaxisopts=( reverse=false display=(TICKS LINE LABEL TICKVALUES ) label=('markCapp in Billions') discreteopts=( tickvaluelist=("0.1" "0.11" "0.12" "0.13" "0.14" "0.15" "0.16" "0.17" "0.18" "0.19" "0.2" "0.21" "0.22" "0.23" "0.24" "0.25" "0.26" "0.27" "0.28" "0.29" "0.3" "0.31" "0.32" "0.33" "0.34" "0.35" "0.36" "0.37" "0.38" "0.39" "0.4" "0.41" "0.42" "0.43" "0.44" "0.45" "0.46" "0.47" "0.48" "0.49" "0.5" "0.51" "0.52" "0.53" "0.54" "0.55" "0.56" "0.57" "0.58" "0.59" "0.6" "0.61" "0.62" "0.63" "0.64" "0.65" "0.66" "0.67" "0.68" "0.69" "0.7" "0.71" "0.72" "0.73" "0.74" "0.75" "0.76" "0.77" "0.78" "0.79" "0.8") tickdisplaylist=("0.1" "0.11" "0.12" "0.13" "0.14" "0.15" "0.16" "0.17" "0.18" "0.19" "0.2" "0.21" "0.22" "0.23" "0.24" "0.25" "0.26" "0.27" "0.28" "0.29" "0.3" "0.31" "0.32" "0.33" "0.34" "0.35" "0.36" "0.37" "0.38" "0.39" "0.4" "0.41" "0.42" "0.43" "0.44" "0.45" "0.46" "0.47" "0.48" "0.49" "0.5" "0.51" "0.52" "0.53" "0.54" "0.55" "0.56" "0.57" "0.58" "0.59" "0.6" "0.61" "0.62" "0.63" "0.64" "0.65" "0.66" "0.67" "0.68" "0.69" "0.7" "0.71" "0.72" "0.73" "0.74" "0.75" "0.76" "0.77" "0.78" "0.79" "0.8") tickvaluefitpolicy=rotatethin tickvaluerotation=vertical colorBandsAttrs=BlockHeader));
         barchart category=_MARKCAPP response=_R / group=_IT name='bar' stat=mean groupdisplay=Cluster clusterwidth=0.85;
         discretelegend 'bar' / opaque=false border=true halign=right valign=top displayclipped=true across=1 order=rowmajor location=inside;
      endlayout;
   endlayout;
endgraph;
end;
run;

proc sgrender data=DISSN.RELIA_99 template=sgdesign;
dynamic _MARKCAPP="MARKCAPP" _R="R" _IT="IT";
run;
*************End;


