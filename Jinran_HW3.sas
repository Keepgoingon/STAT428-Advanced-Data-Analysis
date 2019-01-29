
/* data for Exercise 1 */
data cardata;
	set sashelp.cars;
	keep cylinders origin type mpg_highway;
	where type not in('Hybrid','Truck','Wagon','SUV') and 
		cylinders in(4,6) and origin ne 'Europe';
run;

/*proc print data=cardata;
/run*/;


ods text = " ";
ods text = " ";
ods text="Problem 1 a";


/* cross-tabulation by drug, diet, and biofeedback */
proc tabulate data=cardata;
  class  cylinders origin type ;
  var MPG_Highway;
  table cylinders*origin*type,
        MPG_Highway*(mean std n);
run;

ods text = " ";
ods text = " ";
ods text="Problem 1 b";
proc glm data=cardata;
  class cylinders origin type;
  model MPG_Highway= cylinders origin type;
run;

proc glm data=cardata;
  class cylinders type;
  model MPG_Highway= cylinders type;
run;


ods text = " ";
ods text = " ";
ods text="Problem 1 c";
proc glm data=cardata;
  class cylinders type;
  model MPG_Highway= cylinders|type;
run;


proc glm data=cardata;
  class cylinders type;
  model MPG_Highway= type|cylinders;
	lsmeans type|cylinders/pdiff=all cl;
	ods select OverallANOVA ModelANOVA LSMeans LSMeanDiffCL DiagnosticsPanel;
run;



/* data for Exercise 2,3 and 4 */
/* The raw data in housing.data is from
   and described on https://archive.ics.uci.edu/ml/datasets/Housing
   Bache, K. & Lichman, M. (2013). UCI Machine Learning Repository 
   [http://archive.ics.uci.edu/ml]. Irvine, CA: University of California, 
   School of Information and Computer Science.
*/
data housing;
	infile '/folders/myfolders/hw/hw3data/housing.data';
	input crim zn indus chas nox rm age dis rad tax ptratio b lstat medv;
	logmedv = log(medv);
	over25kSqFt = 'none';
	if zn > 0 then over25kSqFt = 'some';
	taxlevel = 'higher';
	if tax < 500 then taxlevel = 'lower';
	ptlevel = 'medium';
	if ptratio < 15 then ptlevel = 'lower';
	if ptratio > 20 then ptlevel = 'higher';
	drop zn tax ptratio b lstat rad dis chas;
run;
data housing;
	set housing;
	where medv<50;
	drop medv;
run;


ods text="Problem 2 a";
data housing1;
set housing;
where crim <1 ;
run;

/* By looking at the cook's difference, we can find that there are some infuential point in this data set,
we should exclude them.*/

proc reg data=housing1;
	model logmedv = age;
	output out=diagnostics cookd=cd;
run;
* see the resulting data set;


* fit using output data set and removing influential point;
ods text="Problem 2 b";
proc reg data=diagnostics;
	model logmedv = age;
	where cd < 0.048;
run;
*/The cut-off cook's difference is 4/N, N is the number of observations in the data set.
So the cut-off line in this data set is 4/325= 0.012 approximately. According to the 
context we should remove the data with cd larger than 0.048.
According to the plot of residual, we can easily find that the error are normally distributed so that 
the model is reasonable.*/




ods text="Problem 3 a ";

proc tabulate data=housing1;
	class  age indus nox rm ;
	var logmedv ;
	table age* indus*nox*rm,
		logmedv*(mean n);
run;
/*balanced data*/


* see the resulting data set;
proc reg data=housing1;
	model logmedv = age indus nox rm;
	ods select ANOVA FitStatistics ParameterEstimates DiagnosticsPanel;
run;

ods text="Problem 3 b ";

proc corr data=housing1;
var age indus nox rm;
run;
/* not perfectly corraltived*/
proc reg data=housing1;
	model logmedv = age indus nox rm/vif;
	ods select ANOVA FitStatistics ParameterEstimates DiagnosticsPanel;
run;
/*vif small---not highly correative*/
proc reg data=housing1;
	model logmedv = age indus nox rm;
	ods select ANOVA FitStatistics ParameterEstimates DiagnosticsPanel;
run;
/* good, explain 78% variance. predictors not high or perfectly correlative to others.
residual normal distributed. No influential points.*/

ods text="Problem 4 a ";
/*proc print data = housing1;
run;*/


proc reg data=housing1 ;
	model logmedv = age indus nox rm;
	output out=diagnostics cookd=cd;
run;



data diagnostics1;
set diagnostics;
where cd < 0.048;
run;


proc reg data=diagnostics1;
	model logmedv = age indus nox rm;

run; 
/*proc print data=diagnostics1;
run;*/
* fit using output data set and removing influential point;
proc reg data=diagnostics;
	model logmedv = indus  age nox rm /selection=stepwise sle= .05 sls= .05 details=summary;
run;

proc reg data=diagnostics1;
	model logmedv = indus  age nox rm /selection=stepwise sle= .05 sls= .05 details=summary;
run;

proc reg data=diagnostics1;
	model logmedv = indus  age nox rm;
run;
