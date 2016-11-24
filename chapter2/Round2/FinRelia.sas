*For LATeX output;
ods _all_ close;
%let MyPath = C:\Users\Anel\Desktop\D_dissertation\chapters\chapter2\Round2;
ods graphics / outputfmt=png;
*************************************Prepare the data for the reliability procedure;
data dissn.relia_99;
set dissn.relia_99;
obs=_n_;
run;
quit;

proc iml;
use dissn.relia_99;
read all into x[colname=names];
x=repeat(x,2);
call sort(x,ncol(x));
*print x;
create dissn.relia1_99 from x[colname=names];
append from x;
quit;
data dissn.fin_relia_99;
set dissn.relia1_99(drop=obs);
obs=_n_;
*If T1 is missing (.), then T2 represents a left-censoring time;
if mod(obs,2)=0 then do;
t1=.;
t2=IT;
fail=r;
Mc=markCapp;
end;
*If T2 is missing, T1 represents a right-censoring time;
if mod(obs,2)^=0 then do;
t1=IT;
t2=.;
fail=M-r;
Mc=markCapp;
end;
run;

data dissn.fin_relia_99;
set dissn.fin_relia_99(drop= IT r markCapp M);
run;
quit;
*******************************************End data preparation;
*For LATeX output;
ods graphics on/imagename="relia";
ods html file="&MyPath.\Output\SIMM\relia\relia.htm" gpath="&MyPath.\Figures\SIMM\Relia";
ods tagsets.tablesonlylatex file="&MyPath.\SIMM\Relia\relia.tex"(notop nobot) 
newfile=table stylesheet="sas.sty"(url="sas") gpath="&MyPath.\Figures\SIMM\Relia";

*Run the reliability procedure with a linear-link function;
ods trace on;
ods select modprmest;
proc reliability data=dissn.fin_relia_99;
distribution exponential;
freq fail;
*logscale mc;
model (t1 t2)= Mc;
rplot (t1 t2)= Mc/
      pplot
      fit = model
      noconf
      plotdata
      plotfit 10 50 90
;
run;
ods trace off;
quit;

*Run the reliability procedure with a power-link function;
ods trace on;
ods select modprmest parmest;
proc reliability data=dissn.fin_relia_99;
distribution exponential;
freq fail;
*logscale mc;
model (t1 t2)= Mc/ relation=pow ;
make 'modprmest' out=dissn.fin_relia_99_graphMEst;
make 'parmest' out=dissn.fin_relia_99_graphest;
rplot (t1 t2)= Mc/
      pplot
      fit = model
	  relation=pow
      noconf
      plotdata
      plotfit 10 50 90
;
run;
ods trace off;
quit;
