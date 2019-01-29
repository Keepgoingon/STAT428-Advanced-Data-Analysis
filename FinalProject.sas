/*data info
	infile '/folders/myfolders/all/final_project.txt' dlm=',';
	input FICE Collegename $ State $ Publicprivate AverMathSAT
AverVerbalSAT AverCombSAT AverACT FirstMath ThirdMath FirstVerbal ThirdVerbal FirstACT ThirdACT
 applreceived applaccepted new_enrolled
Pcttop10 Pcttop25 full_undergraduates part_undergraduates Instate_tuition Outofstate_tuition
 Roomboardcosts Roomcosts Boardcosts Additionalfees Estibookcosts Estipersonalspending
 PctPhD Pctoftermdegree Stufacratio Pctalumnidonate Instruexpendstu Graduationrate;
 acceptrate = applaccepted/applreceived;
 rollrate = applaccepted/new_enrolled;
 Overaltuition = (Instate_tuition + Outofstate_tuition)/2 ;
drop FICE Boardcosts AverMathSAT AverVerbalSAT AverCombSAT FirstMath ThirdMath FirstVerbal ThirdVerbal FirstACT ThirdACT Pctoftermdegree Instate_tuition Outofstate_tuition ;
run;*/

proc import out = colleges datafile= "/folders/myfolders/colleges_fixed.csv" dbms=csv replace;
getnames=yes;
run;

data colleges1;
	set colleges;
	if cmiss(of _all_) then delete;
run;

proc print data=colleges1;
run;

data  colleges2;
set colleges1;
 acceptrate = Num_app_acc/Num_app_rec;
 rollrate = Enroll/Num_app_acc;
 Overaltuition = (InTuition	+ OutTuition)/2 ;
drop InTuition OutTuition;
run;

proc print data=colleges2;
run;
/*location test(one-way anova) --Publicprivate*/
proc sort data=colleges2;
  by PPI;
run;

proc univariate data=colleges2 normal;
  var Overaltuition;
  histogram Overaltuition /normal;
  probplot Overaltuition ;
  by PPI ; 
  ods select BasicMeasures TestsForNormality;
run;
proc npar1way data=colleges2 wilcoxon;
  class PPI;
  var Overaltuition;
  ods exclude KruskalWallisTest;
run;

/*location test(one-way anova)--State*/


/*using anova*/

proc tabulate data=colleges2;
	class PPI;
	var  Overaltuition;
	table PPI,
		 Overaltuition*(mean n);
run;
/*From the analysis above, I know it is an unbalanced data so that I will use proc glm */
proc glmselect data=colleges2;
    class PPI;
	model Overaltuition = PPI--rollrate/selection=stepwise sls=.05 sle=.05;
run;

/*Using type III, because it will not be influenced by the sequence of predictors.*/
proc glm data=colleges2 plots=diagnostics;
	class PPI;
	model Overaltuition = PPI FQA PctTerminal InstExpend GradRate rollrate;
	lsmeans PPI /pdiff=all cl;
	ods select OverallANOVA ModelANOVA LSMeans LSMeanDiffCL DiagnosticsPanel;
run;


/*removing influential points*/
proc glm data=colleges2 ;
model Overaltuition = PPI FQA PctTerminal InstExpend GradRate rollrate/SS3;
output out=diagnostics cookd= cd;
run;

proc print data=diagnostics;
	where cd > 0.032;
run;

proc glm data=diagnostics plots=diagnostics;
	class PPI;
	model Overaltuition = PPI FQA PctTerminal InstExpend GradRate rollrate/ss3;
	lsmeans PPI /pdiff=all cl;
	where cd< 0.032;
run;


/*using regression*/
/*model and vifs with explanatory variable with largest vif removed*/


proc reg data=colleges2;
model Overaltuition = PPI--rollrate/selection=stepwise sls=.05 sle=.05;
ods select SelectionSummary;
run;
* selection based on adjusted R^2;
proc reg data=colleges2;
	model Overaltuition = PPI--rollrate / selection=stepwise sls=.05 sle=.05;
	ods select SelectionSummary;
run;
* The sesult of selection based on adjusted R^2 include all result of stepwise selection
so we just use the result of stepwiese selection which is more concise and efficient;
proc reg data = colleges2;
model Overaltuition = InstExpend PPI FQA RBCost PctTerminal PersonalEst rollrate GradRate AddFee/VIF;
RUN;

	
proc reg data = colleges2 noprint;
model Overaltuition = InstExpend PPI FQA RBCost PctTerminal PersonalEst rollrate GradRate AddFee/vif;
output out=diagnostics cookd= cd;
run;

proc print data=diagnostics;
run;
* look at points with Cook distance greater than 1;
proc print data=diagnostics;
	where cd > 0.032;
run;

proc reg data = diagnostics;
model Overaltuition = InstExpend PPI FQA RBCost PctTerminal PersonalEst rollrate GradRate AddFee/vif;
where cd<0.032;
run;




proc genmod data=colleges2 plots=(stdreschi stdresdev);
model Overaltuition = InstExpend PPI FQA RBCost PctTerminal PersonalEst rollrate GradRate AddFee/TYPE3;
output out=B cooksd= cd;
run;

proc print data=B;
WHERE cd > 0.032;
RUN;
data  B;
set B;
where cd<0.032;
run;

proc genmod data=B plots=(stdreschi stdresdev);
	model Overaltuition = InstExpend PPI FQA RBCost PctTerminal PersonalEst rollrate GradRate AddFee/ dist=gamma 
		link=log type1 type3;
output out=c cooksd= cd;
run;

proc print data=c;
WHERE cd > 0.032;
RUN;





proc genmod data=colleges2 plots=(stdreschi stdresdev);
model Overaltuition = InstExpend PPI FQA RBCost PctTerminal PersonalEst rollrate GradRate AddFee/TYPE3;
run;




/*PCA analysis*/
proc princomp data=colleges2;
   id PPI;
run;


proc princomp data=colleges2 plots= score(ellipse ncomp=3);
   id PPI;
   ods select ScorePlot;
run;

/*end*/
proc stepdisc data=colleges2 sle=.05 sls=.05;
   	class PPI;
   	var AMSS--Overaltuition;
	ods select Summary;
run;

proc discrim data=colleges2  pool=test crossvalidate;
  	class  PPI;
  	var Under Overaltuition PctPhD acceptrate PctTerminal AMSS PctPhD TopHS10 GradRate;
run;

ods select ChiSq ClassifiedCrossVal ErrorCrossVal;
