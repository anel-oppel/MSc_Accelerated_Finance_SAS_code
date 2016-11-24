*For LATeX output;
ods _all_ close;
%let MyPath = C:\Users\Anel\Desktop\D_dissertation\chapters\chapter2\Round2;
ods graphics / outputfmt=png;

ods html file="&MyPath.\Output\SIMM\\Life\life.htm" gpath="&MyPath.\Figures\SIMM\Life";
ods tagsets.tablesonlylatex file="&MyPath.\SIMM\Life\life.tex"(notop nobot) 
newfile=table stylesheet="sas.sty"(url="sas") gpath="&MyPath.\Figures\SIMM\Life";

*Determine the life distribution by simulation;
proc iml;
*To make output comparable if needed;
call randseed(45);

*Import the parameters of the non-linear model;
use dissn.nlinout_log ;
read all into std;
std=std[1,ncol(std)-1:ncol(std)];
*print std;
*The percentile value at which a failure will be defined;
alpha=0.01;
N=500;*Actually the time variable;
mu=0;
****************Select the failure threshold based on the percentile of a small market capitalization company;
smallCap=0.01*(10**9);
X=log(smallCap)//{1};
factor=std*X;
sigmaf=exp(-factor);*Create the standard deviation of the return based on th eoutput from the non-linear model;
*print sigmaf;
Tcll=(probit(alpha)*sigmaf)+mu;*The percentile which will be the failure threshold;
*print Tcll;
Tclu=(probit(1-alpha)*sigmaf)+mu;
*print Tclu;

*The stress level at which the life distribution will be assessed. Assuming the distribution remains the same at all stress levels;
s=0.012;
markCapp=s*(10**9);*the stress factor in Billions;
X=log(markCapp)//{1};
factor=std*X;
sigma=exp(-factor);*create the standard deviation of the return based on the output from the non-linear model;
*print sigma;
*call randseed(0);
Rt=J(N,1,0);

do k=1 to 2000;
	call randgen(Rt, "Normal", Mu, Sigma);*Populate the return matrix;
	if ((Rt>Tclu)[+])>0 then do;
		idx=loc(Rt>=Tclu);
		min=min(idx); *Determine the first time at which the returns went above the loss threshold;
		t = t//min;
	end;
end;

create dissn.life_99 from t[colname={'t'}];
append from t;

quit;

*For LATeX output;
ods graphics on/imagename="lifeh";
ods html file="&MyPath.\Output\SIMM\Life\lifeh.htm" gpath="&MyPath.\Figures\SIMM\Life";
ods tagsets.tablesonlylatex file="&MyPath.\SIMM\Life\lifeh.tex"(notop nobot) 
newfile=table stylesheet="sas.sty"(url="sas") gpath="&MyPath.\Figures\SIMM\Life";

*Test if the life distribution is Weibull, Lognormal, Gamma or Exponential;
proc univariate data=dissn.life_99 normal ;
var t;
histogram/ weibull lognormal gamma exponential;
run;
quit;
