
data cars;
 set sashelp.cars;
 where type not eq "Hybrid";
 drop drivetrain msrp enginesize cylinders weight;
run;
*1(a);
data cars;
  set cars;
  MPG_Combo= 0.55 * MPG_City+ 0.45 * MPG_Highway;
run;

proc sgplot data=cars;
  vbox MPG_Combo;
run;
*1(b);
proc sort data = cars;
by Type;
run;

proc boxplot data =cars;
plot MPG_Combo*Type;
run;
*1(c);
proc univariate data=cars normal;
  var MPG_Combo Invoice;
  histogram MPG_Combo Invoice /normal;
  probplot MPG_Combo Invoice;
  ods select Histogram ProbPlot GoodnessOfFit TestsForNormality;
run;
*1(d);
proc sort data = cars;
by Origin;
run;
proc univariate data=cars normal;
  var MPG_Combo Invoice;
  histogram MPG_Combo Invoice /normal;
  probplot MPG_Combo Invoice;
  by Origin;
  ods select Histogram ProbPlot GoodnessOfFit TestsForNormality;
run;
*2(1);
proc univariate data=cars normal;
var Invoice;
histogram Invoice /normal;
ods select Histogram ProbPlot GoodnessOfFit TestsForNormality;
run;

proc univariate data=cars mu0=22000;
  var Invoice;
  ods select TestsForLocation;
run;

*2(2);
proc npar1way data=cars wilcoxon;
  class Origin;
  var Invoice;
  ods exclude KruskalWallisTest;
run;
*3(1);
proc corr data=cars pearson;
  var Invoice Horsepower Wheelbase Length MPG_Combo;
  ods select PearsonCorr;
run;
*3(2);
proc sort data = cars;
by Type;
run;
proc corr data=cars pearson ;
  var Invoice Horsepower Wheelbase Length MPG_Combo;
  by Type;
  ods select PearsonCorr;
run;