*For LaTex output;
ods _all_ close;
%let MyPath = C:\Users\Anel\Desktop\D_dissertation\chapters\chapter1;
ods graphics / outputfmt=png;

proc iml;
*Set a seed value to make results comparable;
call randseed(45);

*The 4 class multinomial;
x={125,18,20,34};
*The desired level of accuracy;
acc=0.0001;
*The initial guess for theta;
theta=0.1;

*Repeat until desired accuracy is achieved OR if convergence does not occur, avoid infinite loop;
do j=1 to 100 until(diff=1);
	k=j-1;*For PRINT matrix;
	v2=x[1,]#(0.25#theta)/(0.5+0.25#theta);*The E-step;
	matrix=matrix//(v2||k||theta);*Update the PRINT matrix;
	theta_old=theta;
	theta=(v2+x[4,])/(v2+x[2,]+x[3,]+x[4,]);*The M-step;
	k=j;*For PRINT matrix;
	matrix=matrix//(v2||k||theta);*Update the PRINT matrix;
	diff=((abs(theta_old-theta))<acc); *Test if accuracy has been achieved;
end;

*For LaTeX output;
ods html file="&MyPath.\Output\EX1\GeneticLinkage.htm" gpath="&MyPath.\Figures\EX1";
ods tagsets.tablesonlylatex file="&MyPath.\EX1\Genetic.tex"(notop nobot) 
newfile=table stylesheet="sas.sty"(url="sas") gpath="&MyPath.\Figures\EX1";

*PRINT matrix to show each convergence step;
print matrix[label="" colname={"v" "k" "theta"}];

quit;
