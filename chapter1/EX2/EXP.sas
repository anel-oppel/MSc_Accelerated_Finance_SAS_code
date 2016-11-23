*For LaTeX output;
ods _all_ close;
%let MyPath = C:\Users\Anel\Desktop\D_dissertation\chapters\chapter1;
ods graphics / outputfmt=png;

proc iml;
*Set a seed value to make results comparable;
call randseed(2);

acc=0.001;*The desired level of accuracy;
n=15;*The number of items for which the life times are known;
eta=8; *The real value of eta;
m=20; *The number of items for which we don't know the lifetimes;
t=3; *The inspection time;
y=J(n,1,.);*The matrix that will contain the known lifetimes;
v=J(m,1,.);*The matrix that will contain the "unknown" lifetimes;

call randgen(y,'exponential',eta);*Generate the known lifetimes;
call randgen(v,'exponential',eta);*Generate the "unknown" lifetimes;
r=(v<=t)[+,];*The number of items that failed -  we don't know the exact lifetimes;
pr=r||(y[+,]/nrow(y)); *To be used in the E-step;

*For LaTeX output;
ods tagsets.tablesonlylatex file="&MyPath.\EX2\r.tex"(notop nobot) 
newfile=table stylesheet="sas.sty"(url="sas") gpath="&MyPath.\Figures\EX2";
print pr[label= "" colname={"The number of failures" "y-bar"}] ;

eta=2;*The initial guess for eta;
*Repeat until desired accuracy is achieved OR if convergence does not occur, avoid infinite loop;
do j=1 to 100 until(diff=1);
	k=j-1;*For PRINT matrix;
	v2=(m-r)#(t+eta)+r#eta+(-r#t#exp(-t/eta))/(1-exp(-t/eta));*The E-step;
	matrix=matrix//(v2||k||eta);*Update the PRINT matrix;
	eta_old=eta;
	eta=(n#(y[+,]/nrow(y))+v2)/(n+m);*The M-step;
	k=j; *For PRINT matrix;
	matrix=matrix//(v2||k||eta); *Update the PRINT matrix;
	diff=((abs(eta_old-eta))<acc); *Test if accuracy has been achieved;
end;

*For LaTeX output;
ods html file="&MyPath.\Output\EX2\Exp.htm" gpath="&MyPath.\Figures\EX2";
ods tagsets.tablesonlylatex file="&MyPath.\EX2\exp.tex"(notop nobot) 
newfile=table stylesheet="sas.sty"(url="sas") gpath="&MyPath.\Figures\EX2";

*PRINT matrix to show each convergence step;
print matrix[label="" colname={"v" "k" "theta"}];

quit;
