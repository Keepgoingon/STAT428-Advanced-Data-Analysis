options nodate nonumber;
title ;
ods noproctitle;

ods text = " ";
ods text = "HW 2 Spring 2018";

ods startpage=no ;

ods graphics / reset=all height=4in width=7in;



/* data for exercises 1 and 2 */
data haireyes;
	input eyecolor $ haircolor $ count;
	datalines;
	light fair 688
	light medium 584
	light dark 188
	medium fair 343
	medium medium 909
	medium dark 412
	dark fair 98
	dark medium 403
	dark dark 681
	;
proc print data=haireyes;
run;

/*-------------*/
/* Problem 1  */
/*-------------*/
ods text = " ";
ods text = " ";
ods text="Problem 1 a";
proc freq data=haireyes order=data;
title "A contingency table of eyecolor and haircolor";
  tables eyecolor*haircolor/ nopercent norow nocol;
  weight count;
run;

proc freq data=haireyes order=data;
title "A contingency table of eyecolor and haircolor";
  tables eyecolor*haircolor/ nopercent norow nocol expected chisq ;
  weight count;
run;


/*-------------*/
/* Problem 2 a */
/*-------------*/

data haireyes2;
	input eyecolor $ haircolor $ count;
	datalines;
	light fair 688
	light dark 188
	dark fair 98
	dark dark 681
	;
proc print data=haireyes2;
run;

/*-------------*/
/* Problem 2 a */
/*-------------*/
ods text = " ";
ods text = " ";
ods text="Problem 2 a";
proc freq data=haireyes2 order=data;
title "A contingency table of eyecolor and haircolor with the medium values omitted";
  tables eyecolor*haircolor/ nopercent norow nocol expected ;
  weight count;
run;

/*-------------*/
/* Problem 2 b */
/*-------------*/
ods text = " ";
ods text = " ";
ods text="Problem 2 b";
proc freq data=haireyes2 order=data;
title "A contingency table of eyecolor and haircolor";
  tables eyecolor*haircolor/ nopercent norow nocol expected chisq cellchi2;
  weight count;
run;

/*-------------*/
/* Problem 2 c */
/*-------------*/
ods text = " ";
ods text = " ";
ods text="Problem 2 c";

proc freq data=haireyes2 order=data;
title "A contingency table of eyecolor and haircolor";
  tables eyecolor*haircolor/ nopercent riskdiff expected norow nocol ;
  weight count;
run;



/* data for exercises 3 and 4 */
data heartbpchol;
	set sashelp.heart;
	where status='Alive' and AgeCHDdiag ne . and Chol_Status ne ' ';
	if BP_Status = 'Optimal' then index = 1;
	if BP_Status = 'Optimal' and Chol_Status = 'Borderline' then index = 2;
	if BP_Status = 'Optimal' and Chol_Status = 'High' then index = 3;
	if BP_Status = 'Normal' then index = 4;
	if BP_Status = 'Normal' and Chol_Status = 'Borderline' then index = 5;
	if BP_Status = 'Normal' and Chol_Status = 'High' then index = 6;
	if BP_Status = 'High' then index = 7;
	if BP_Status = 'High' and Chol_Status = 'Borderline' then index = 8;
	if BP_Status = 'High' and Chol_Status = 'High' then index = 9;	
	keep Cholesterol BP_Status Chol_Status index;
proc sort;
by index;
run;
/*-------------*/
/* Problem 3 a */
/*-------------*/
ods text = " ";
ods text = " ";
ods text="Problem 3 a";
proc freq data=heartbpchol order=data;
title "A contingency table of blood pressure status and cholesterol status";
tables BP_Status*Chol_Status/ nopercent expected norow nocol ;
run;


/*-------------*/
/* Problem 3 b */
/*-------------*/
ods text = " ";
ods text = " ";
ods text="Problem 3 b";
proc freq data=heartbpchol order=data;
title "A contingency table of blood pressure status and cholesterol status";
tables BP_Status*Chol_Status/ norow nocol cellchi2 chisq ;
run;

proc freq data=heartbpchol;
title "A contingency table of blood pressure status and cholesterol status";
tables Chol_Status*BP_Status/ nopercent norow nocol riskdiff expected ;
run;
/*-------------*/
/* Problem 4 */
/*-------------*/

ods text = " ";
ods text = " ";
ods text="Problem 4";
proc tabulate data=heartbpchol ;
class BP_Status;
  var Cholesterol ;
  table BP_Status,
        Cholesterol*(mean std n);
run;

proc anova data=heartbpchol ;
  class BP_Status;
  model Cholesterol = BP_Status;
  means BP_Status/hovtest tukey cldiff ;
run;


