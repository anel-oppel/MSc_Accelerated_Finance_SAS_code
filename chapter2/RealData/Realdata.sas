*Import the stock data;
PROC IMPORT OUT= DISSN.MERGEDDATA 
            DATAFILE= "C:\Users\Anel\Desktop\D_dissertation\chapters\cha
pter2\RealData\merged1479114290141.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;

proc iml;
*Store the stock data in matrix X with column names equal to the stock names;
use dissN.mergedData;
read all into x[colname=names];
close dissN.mergedData;

*Create a column vector from the market capitalization values;
MC=x[1,]`;
call sort(MC);
MC=MC[1:250];
create dissN.MCcol from MC[colname={'MC'}];
append from MC;
quit;

*Import an excerpt of the stock data to be printed;
PROC IMPORT OUT= DISSN.DataMerged_e 
            DATAFILE= "C:\Users\Anel\Desktop\D_dissertation\chapters\cha
pter2\RealData\DataMerged_e.xlsx" 
            DBMS=EXCEL REPLACE;
     RANGE="Sheet1$"; 
     GETNAMES=YES;
     MIXED=NO;
     SCANTEXT=YES;
     USEDATE=YES;
     SCANTIME=YES;
RUN;

*For LATeX;
ods _all_ close;
%let MyPath = C:\Users\Anel\Desktop\D_dissertation\chapters\chapter2;
ods graphics / outputfmt=png;

ods html file="&MyPath.\Output\RealData\dataE.htm" gpath="&MyPath.\Figures\RealData\dataE";
ods tagsets.tablesonlylatex file="&MyPath.\RealData\dataE.tex"(notop nobot) 
newfile=table stylesheet="sas.sty"(url="sas") gpath="&MyPath.\Figures\RealData\dataE";
*Print and expert of stock data to show what data table looks like;
proc print data=DISSN.DataMerged_e ;
run;
quit;

proc iml;

*For LATeX;
ods html file="&MyPath.\Output\RealData\NumberOfCompanies.htm" gpath="&MyPath.\Figures\RealData\NumberOfCompanies";
ods tagsets.tablesonlylatex file="&MyPath.\RealData\NumberOfCompanies.tex"(notop nobot) 
newfile=table stylesheet="sas.sty"(url="sas") gpath="&MyPath.\Figures\RealData\NumberOfCompanies";

*Store the stock data in matrix x with column names equal to the stock names;
use dissN.mergedData;
read all into x[colname=names];
close dissN.mergedData;

MC=x[1,];
*Do not include the first row: Market capitalization;
x=x[2:nrow(x),];

mx=ncol(x);*The number of columns in the matrix i.e. the number of companies;
print mx[label='' colname={'Number of companies'}];
nx=nrow(x);*The number of rows in the matrix i.e. the number of prices for each company;
xt_1=x[1:nx-1,];*Create the lagged prices to be used in return calculation;
xt=x[2:nx,];

RtX=log(xt/xt_1);*Define a return by the log of the returns;
step=do(1,nx-1,1);*Create the time variable against which each return value wil be plotted;
step=step`;
RtXs=step||RtX;

s2=(((RtX-(Rtx[+,]/(nx-1)))##2)[+,])/(nx-2);*Calculate the standard deviation of the returns for each company;
*print s2;
std=(Mc//sqrt(s2))`; *Create a matrix compromising of the Market capitalization and standard deviation of the returns, for each company;
call sort(std,1);

*Create a data table from the return values for each company;
create dissN.ALL_Rt from RtXS[colname=({'steps'}||names)];
append from RtXs;

*Create a data table from the market capitalization values for each company;
create dissN.MC from MC[colname=(names)];
append from MC;

*Create a data table from the market capitalization values and standard deviation of the returns, for each company;
create dissN.std from std[colname={'MC' 'std'}];
append from std;
quit;

*For LATeX output;
ods html file="&MyPath.\Output\RealData\Normality\Normality.htm" gpath="&MyPath.\Figures\RealData\Normality";
ods tagsets.tablesonlylatex file="&MyPath.\RealData\Normality\Normality.tex"(notop nobot) 
newfile=table stylesheet="sas.sty"(url="sas") gpath="&MyPath.\Figures\RealData\Normality";

*Test if it is reasonable to assume that the logged returns are normally distributed;
*Select companies JNJ AGRX MNOV NDRM TLGT log returns;
*Use ods trace to print only specific tables;
ods trace on;
ods select testsfornormality;
proc univariate data=dissN.ALL_Rt normal;
var JNJ AGRX MNOV NDRM TLGT;
output out=dissn.univar probn= JNJ AGRX MNOV NDRM TLGT;
run;
ods trace off;
quit;

*For LATeX output;
ods html file="&MyPath.\Output\RealData\Normality\Normalityp.htm" gpath="&MyPath.\Figures\RealData\Normality";
ods tagsets.tablesonlylatex file="&MyPath.\RealData\Normality\Normalityp.tex"(notop nobot) 
newfile=table stylesheet="sas.sty"(url="sas") gpath="&MyPath.\Figures\RealData\Normality";

*Print only the Shapiro-Wilk normality test p-values;
proc print data=dissN.univar;
run;
quit;

*For LATeX output;
ods graphics on/imagename="smallVSbig";
ods html file="&MyPath.\Output\RealData\smallVSbig.html" gpath="&MyPath.\Figures\RealData";
ods tagsets.tablesonlylatex file="&MyPath.\RealData\smallVSbig.tex"(notop nobot) 
newfile=table stylesheet="sas.sty"(url="sas") gpath="&MyPath.\Figures\RealData";

**************Graphing procedure to graph the log returns of a selected small-cap and large-cap company against time;
**************Code exported form ODS Graphics designer;
proc template;
define statgraph sgdesign;
dynamic _STEPS _JNJ _STEPS2 _ABEO;
begingraph;
   entrytitle halign=center 'The returns of a big cap and small cap company ';
   layout lattice / rowdatarange=data columndatarange=data rowgutter=10 columngutter=10;
      layout overlay;
         seriesplot x=_STEPS y=_JNJ / name='series' connectorder=xaxis lineattrs=(color=CX639A21 );
         seriesplot x=_STEPS2 y=_ABEO / name='series2' connectorder=xaxis lineattrs=(color=CX8CA6CE );
         discretelegend 'series' 'series2' / opaque=false border=true halign=left valign=bottom displayclipped=true across=1 order=rowmajor location=inside;
      endlayout;
   endlayout;
endgraph;
end;
run;

proc sgrender data=DISSN.ALL_RT template=sgdesign;
dynamic _STEPS="STEPS" _JNJ="JNJ" _STEPS2="STEPS" _ABEO="ABEO";
run;
************End of graphing procedure;

*For LATeX output;
ods graphics on/imagename="MC";
ods html file="&MyPath.\Output\RealData\MC.html" gpath="&MyPath.\Figures\RealData";
ods tagsets.tablesonlylatex file="&MyPath.\RealData\MC.tex"(notop nobot) 
newfile=table stylesheet="sas.sty"(url="sas") gpath="&MyPath.\Figures\RealData";
*Print the Market capitalization values for the companies for which the returns were graphed in above procedure;
proc print data=dissn.MC;
var JNJ ABEO;
run;
quit;

*For LATeX output;
ods graphics on/imagename="std.";
ods html file="&MyPath.\Output\RealData\std.html" gpath="&MyPath.\Figures\RealData";
ods tagsets.tablesonlylatex file="&MyPath.\RealData\std.tex"(notop nobot) 
newfile=table stylesheet="sas.sty"(url="sas") gpath="&MyPath.\Figures\RealData";

**************Graphing procedure to graph the standard deviation of the log-returns for each company against the market capitalization values for each company;
**************Code exported form ODS Graphics designer;
proc template;
define statgraph sgdesign;
dynamic _MC _STD;
begingraph;
   entrytitle halign=center 'Variability vs. market Capp';
   layout lattice / rowdatarange=data columndatarange=data rowgutter=10 columngutter=10;
      layout overlay;
         scatterplot x=_MC y=_STD / name='scatter';
      endlayout;
   endlayout;
endgraph;
end;
run;

proc sgrender data=DISSN.STD template=sgdesign;
dynamic _MC="MC" _STD="STD";
run;
************End of graphing procedure;

proc iml;
use dissn.std ;
read all into x;
*Transform the standard deviations by applying the negative log;
x[,2]=-log(x[,2]);

create dissN.std_Log from x[colname={'MC' 'Log_std'}];
append from x;
quit;

*For LATeX output;
ods graphics on/imagename="log_std";
ods html file="&MyPath.\Output\RealData\std_Log.html" gpath="&MyPath.\Figures\RealData\";
ods tagsets.tablesonlylatex file="&MyPath.\RealData\std_Log.tex"(notop nobot) 
newfile=table stylesheet="sas.sty"(url="sas") gpath="&MyPath.\Figures\RealData\";

**************Graphing procedure to graph the negative log standard deviation (transformed standard deviation) of the log-returns for each company against the market capitalization values for each company;
**************Code exported form ODS Graphics designer;
proc template;
define statgraph sgdesign;
dynamic _MC _LOG_STD;
begingraph;
   entrytitle halign=center 'Log(variability) vs. market Capp';
   layout lattice / rowdatarange=data columndatarange=data rowgutter=10 columngutter=10;
      layout overlay;
         scatterplot x=_MC y=_LOG_STD / name='scatter';
      endlayout;
   endlayout;
endgraph;
end;
run;

proc sgrender data=DISSN.STD_LOG template=sgdesign;
dynamic _MC="MC" _LOG_STD="'LOG_STD'n";
run;
************End of graphing procedure;

*For LATeX output;
ods graphics on/imagename="nlin_model";
ods html file="&MyPath.\Output\RealData\nlin_model.html" gpath="&MyPath.\Figures\RealData\";
ods tagsets.tablesonlylatex file="&MyPath.\RealData\nlin_model.tex"(notop nobot) 
newfile=table stylesheet="sas.sty"(url="sas") gpath="&MyPath.\Figures\RealData\";

*Perform a non-linear regression to understand how the transformed standard deviations move with market capitalization;
goptions reset=all;
proc nlin data=dissn.std_log ;
  parameters  beta=2 alpha=2.6;
  switch=log(mc);
  model log_std=alpha+beta*switch;
  output out=dissn.nlinout_log pred=p lcl=lcl ucl=ucl parms= beta_0 beta_1 ;
run;

*For LATeX output;
ods graphics on/imagename="nlin";
ods html file="&MyPath.\Output\RealData\std_Log.html" gpath="&MyPath.\Figures\RealData\";
ods tagsets.tablesonlylatex file="&MyPath.\RealData\nlin.tex"(notop nobot) 
newfile=table stylesheet="sas.sty"(url="sas") gpath="&MyPath.\Figures\RealData\";

**************Graphing procedure to graph the non-linear model which relates the transformed standard deviations to the market capitalization;
**************Code exported form ODS Graphics designer;
proc template;
define statgraph sgdesign;
dynamic _MC _LOG_STD _MC2 _P;
begingraph;
   entrytitle halign=center 'The predicted log variation as a function of Log(CAP)';
   layout lattice / rowdatarange=data columndatarange=data rowgutter=10 columngutter=10;
      layout overlay;
         scatterplot x=_MC y=_LOG_STD / name='scatter';
         seriesplot x=_MC2 y=_P / name='series' connectorder=xaxis lineattrs=(color=CX8CA6CE );
         discretelegend 'scatter' 'series' / opaque=false border=true halign=left valign=bottom displayclipped=true across=1 order=rowmajor location=inside;
      endlayout;
   endlayout;
endgraph;
end;
run;

proc sgrender data=DISSN.NLINOUT_LOG template=sgdesign;
dynamic _MC="MC" _LOG_STD="'LOG_STD'n" _MC2="MC" _P="P";
run;
