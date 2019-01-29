data sleep;
	infile '/folders/myfolders/all/hw/SLEEP.csv' dlm=',';
	input species $ bodyweight brainweight nondreamingsleep dreamingsleep
		totalsleep maxlifespan gestationtime predationindex sleepexposureindex
		overalldangerindex;
	maxlife10=maxlifespan < 10;
	drop nondreamingsleep dreamingsleep;
run;
proc print data = sleep;
run;

ods text = "HW 4 Spring 2018";


/*-------------*/
/* Problem 1  */
/*-------------*/
ods text = " ";
ods text = " ";
ods text="Problem 1 ";
proc logistic data=sleep;
  class predationindex sleepexposureindex overalldangerindex/param=ref ref=first;
  model maxlife10=bodyweight brainweight totalsleep 
  gestationtime predationindex sleepexposureindex 
  overalldangerindex/selection=stepwise sls=.05 sle=.05;
run;

proc logistic data=sleep plots=influence;
  model maxlife10=gestationtime /lackfit;
run;

/*-------------*/
/* Problem 2  */
/*-------------*/
ods text = " ";
ods text = " ";
ods text="Problem 2";


proc logistic data=sleep;
  model maxlife10=bodyweight brainweight totalsleep 
  gestationtime predationindex sleepexposureindex 
  overalldangerindex/selection=stepwise sls=.05 sle=.05;

run;

proc logistic data=sleep plots=influence;
  model maxlife10=predationindex sleepexposureindex  /lackfit;
run;
/*remove influential point*/

proc logistic data=sleep noprint;
	model maxlife10=predationindex sleepexposureindex;
	output out=A cbar= cbar;
run;

data  A;
set A;
where cbar<1;
run;


proc logistic data=A plots=influence;
	model maxlife10=predationindex sleepexposureindex/lackfit  ;
	run;


/*-------------*/
/* Problem 3  */
/*-------------*/
ods text = " ";
ods text = " ";
ods text="Problem 3";

proc genmod data=sleep plots=cooksd;
class predationindex sleepexposureindex;
  model gestationtime= bodyweight brainweight predationindex sleepexposureindex/dist=p 
		link=log type1 type3 scale = d;
output out=B cooksd= cd;
run;


data  B;
set B;
where cd<1;
run;

proc genmod data=B plots=cooksd ;
class predationindex sleepexposureindex;
  model gestationtime= bodyweight brainweight predationindex sleepexposureindex/dist=p 
		link=log type1 type3 scale = d;
		output out=C cooksd= cd1;
RUN;

data  C;
set C;
where cd1<1;
run;

proc genmod data=C plots=cooksd ;
class predationindex sleepexposureindex;
  model gestationtime= bodyweight brainweight predationindex sleepexposureindex/dist=p 
		link=log type1 type3 scale = d;
		output out=D cooksd= cd2;
RUN;
data  D;
set D;
where cd2<1;
run;

proc genmod data=D plots=cooksd;
class predationindex sleepexposureindex;
  model gestationtime= bodyweight brainweight predationindex sleepexposureindex/dist=p 
		link=log type1 type3 scale = d;
run;
/*-------------*/
/* Problem 3b  */
/*-------------*/
ods text = " ";
ods text = " ";
ods text="Problem 3b";
proc genmod data=C plots=cooksd;
	class sleepexposureindex;
  model gestationtime= brainweight sleepexposureindex/dist=p 
		link=log type1 type3 scale = d;
	output out=D pred=pgest stdreschi=presids
		stdresdev= dresids;	
run;

proc sgscatter data=D;
	compare y= (presids dresids) x=pgest;
	where pgest<100;
run;