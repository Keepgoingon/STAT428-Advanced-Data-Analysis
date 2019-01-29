data pottery;
	infile "/folders/myfolders/all/hw/hw5/pottery.dat" expandtabs;
	input id Kiln Al Fe Mg Ca Na K Ti Mn Ba;
	drop id;
run;


/*-------------*/
/* Problem 1  */
/*-------------*/
ods text = " ";
ods text = " ";
ods text="Problem 1a ";

* obtain principal components analysis;
proc princomp data = pottery;
var Al--Ba;
run;
/* We need to keep 3 components to retain at least 80% of 
the total variation from the original variables. 

2 components would be chosen based on the average eigenvalue; 
3 components would be chosen based onscree plot methods, since 3 is an elbow point( 
which means the curve after 3 tends to be flat which implys including these points will not result in big change).

Problem 1b
pc1 expresses the pottery contain high level of Fe, Mg, K, Mn oxide, 
but low level of Al and Ti oxid.

pc2 expresses the pottery contain rather high level of Fe, Ca, Na and Ba oxide.

pc3 expresses the pottery contain high level of Ba oxide, 
but low level of Ca oxid.
*/
ods text = " ";
ods text = " ";
ods text="Problem 1c ";
proc princomp data=pottery plots= score(ellipse ncomp=3);
var Al--Ba;
id kiln;
ods select ScorePlot;
run;


/* ????The pottery was found at kiln site 1 generally 
have 0 value of pc1 but positive value of pc2(????), 
and it pc3'value is 
randomly distributed between -2 and and 1.5, 
which means they usually contain high level of Fe, Ca, Na and Ba oxide/


/*-------------*/
/* Problem 2  */
/*-------------*/
ods text = " ";
ods text = " ";
ods text="Problem 2a ";
proc princomp data = pottery cov;
var Al--Ba;
run;


proc princomp data=pottery plots= score(ellipse ncomp=2) cov;
var Al--Ba;
id kiln;
ods select ScorePlot;
run;
/* We need to keep 2 components to retain at least 80% of 
the total variation from the original variables. 
3 components would be chosen based onscree plot methods, since 3 is an elbow point( 
which means the curve after 3 tends to be flat which implys including these points will not result in big change).
*/


/*-------------*/
/* Problem 3  */
/*-------------*/
ods text = " ";
ods text = " ";
ods text="Problem 3 ";

proc cluster data=pottery  method=average ccc pseudo print=15;
   var Al--Ba ;   
   copy kiln;
run;
/* try 3 clusters*/
proc tree ncl=3 out=out;
copy Al--Ba kiln;
run;
proc print data=out;
run;

proc sort data=out;
by cluster;
run;
proc means data=out;
var Al--Ba;
by cluster;
run;
* cross-tabulation to see how well clusters match up with species;
proc freq data=out;
  tables cluster*kiln/ nopercent norow nocol;
run;

/*-------------*/
/* Problem 4  */
/*-------------*/
ods text = " ";
ods text = " ";
ods text="Problem 4 ";
proc cluster data=pottery  method=average ccc pseudo std print=15;
   var Al--Ba ;   
   copy kiln;
run;
/* try 3 clusters*/
proc tree noprint ncl=3 out=out1;
copy Al--Ba kiln;
run;

proc sort data=out1;
by cluster;
run;
proc print data=out1;
run;
proc means data=out1;
var Al--Ba;
by cluster;
run;
proc freq data=out1;
  tables cluster*kiln/ nopercent norow nocol;
run;