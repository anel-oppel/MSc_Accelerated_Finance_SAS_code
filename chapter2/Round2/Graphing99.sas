ods _all_ close;
%let MyPath = C:\Users\Anel\Desktop\D_dissertation\chapters\chapter2\round2;
ods graphics / outputfmt=png;

proc iml;
use dissn.Fin_relia_99_graphest;
read all into x[colname=names];
close dissn.Fin_relia_99_graphest;

use dissn.Fin_relia_99_graphMest;
read all into xy[colname=names];
close dissn.Fin_relia_99_graphMest;
B0=xy[1,1];
B1=xy[2,1];

use dissn.relia_99;
read all into mc;
close dissn.relia_99;
mc=mc[,1];

M=1000;
v=J(M,1,.);
u=J(M,1,.);
y=J(M,1,.);
eta=x[,2];
do j=1 to 11 by 2;*nrow(x) by 20;
	mmc=mmc//mc[j,];
	y[,1]=mc[j,];
	parm=eta[j+1,];
	call randgen(v,'exponential',parm);
	*if j<=3 then print v;
	u[,1]=(1/parm)*exp(-v/parm);
	DataM=dataM//(y||v||u);
end;

link=1/exp(b0+b1*log(dataM[,1]));
DataM=DataM||link;

create dissn.Fin_relia_99_graph from DataM[colname={'marketCapp','y','dist', 'link'}];
append from DataM;

quit;

ods graphics on/imagename="densities";
ods html file="&MyPath.\Output.htm" gpath="&MyPath.\Figures";
ods tagsets.tablesonlylatex file="&MyPath.densities.tex"(notop nobot) 
newfile=table stylesheet="sas.sty"(url="sas") gpath="&MyPath.\Figures";

proc template;
define statgraph sgdesign;
dynamic _Y _DIST _MARKETCAPP;
begingraph;
   entrytitle halign=center 'The life-time distributions for diffirent market cap values';
   layout lattice / rowdatarange=data columndatarange=data rowgutter=10 columngutter=10;
      layout overlay;
         seriesplot x=_Y y=_DIST / group=_MARKETCAPP name='series' connectorder=xaxis;
         discretelegend 'series' / opaque=false border=true halign=right valign=top displayclipped=true across=1 order=rowmajor location=inside;
      endlayout;
   endlayout;
endgraph;
end;
run;

proc sgrender data=DISSN.FIN_RELIA_99_GRAPH template=sgdesign;
dynamic _Y="Y" _DIST="DIST" _MARKETCAPP="MARKETCAPP";
run;




