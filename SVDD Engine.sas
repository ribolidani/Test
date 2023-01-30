cas;
caslib _all_ assign;

proc import datafile='/shared/home/Daniele.Riboli@sas.com/Anomaly/ENGINE_TRAINING.csv'
		dbms=csv out=casuser.engine_training replace;
run;

proc import datafile='/shared/home/Daniele.Riboli@sas.com/Anomaly/TEST_NUOVO.csv'
		dbms=csv out=casuser.engine_test replace;
run;



ods trace on;
proc svdd data=casuser.engine_training;
  input x1-x24 / level=interval;
  id _all_;
  solver actset;
  kernel rbf / bw=94;
  savestate rstore=casuser.state_s;
 ods output TrainingResults=results ;
run;

proc sql;
 select Value into :Rsqr
	from work.results
	where description='Threshold R Square Value';
quit;


proc astore;
    score data=casuser.test_anomalia out=casuser.all_out rstore=casuser.state_s;
run;

proc sgplot data=casuser.all_out;
    title H=14pt "Anomaly Detection using SVDD";
    footnote H=8pt j=l italic "Anomalies when SVDD distance exceed SVDD Radius Threshold.";
    series x=cycle y=SQ_SVD_DIST;
    refline &Rsqr / label="SVDD Radius Threshold" lineattrs=(color=red) labelpos=max;
    by engine;
    where engine=100;
run;


