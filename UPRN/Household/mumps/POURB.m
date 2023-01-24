POURB ; ; 1/24/23 11:26am
 quit
 
 ; job SERVICE^POURB:(out="/dev/null")
 ; $ydb_dist/mupip intrpt 18790 (where 18790 is $job)
SERVICE ;
 new job,i,zi,qid
 
 S ^DSYSTEM("POURB")=$job
 set $ZINT="I $$JOBEXAM^POURB($ZPOS)"
 set job=+$get(^KRUNNING("START","POURB"))
 lock ^KRUNNING("START","POURB"):1
 if '$t S ^T($J)="POURB:locked" quit
 
 kill ^KRUNNING("STOP","POURB")
 set ^KRUNNING("START","POURB")=$job
 for i=1:1 quit:$data(^KRUNNING("ABORT","POURB"))  do
 .w !,"hanging 10"
 .hang 10
 .set (qid,zi)=""
 .for  set qid=$order(^ZQZ(qid)) q:qid=""  do
 ..for  set zi=$order(^ZQZ(qid,zi)) q:zi=""  do
 ...if $data(^ZQZ1(qid,zi)) quit
 ...D RUN(qid,zi)
 ...quit
 ..quit
 .quit
 
 set ^KRUNNING("STOP","POURB")=$job
 lock -^KRUNNING("START","POURB")
 quit
 
RUN(qid,i) ;
 new zskid,rec,t1
 
 set t1=^ZQZ(qid,i)
 if i>+$H quit
 if t1>$piece($horolog,",",2) quit
 
 W !,"ALL^REFRESH"
 do ALL^REFRESH
 
 W !,"test^REFRESH"
 do test^REFRESH
 
 W !,"WRITEMATCH"
 do WRITEMATCH^SKID
 
REENT ;set zskid=""
 ; nhs_numbers
 ;for  set zskid=$order(^SPIT("N",zskid)) quit:zskid=""  do
 ;.D AUDIT("SPIT",zskid)
 ;.W !,"DB^SKID: ",zskid
 ;.do DB^SKID(zskid)
 ;.;
 ;.quit
 
 do UPDATES^SKID
 do UPD2^SKID
 
 ; ralfs
 set zskid=""
 f  s zskid=$order(^RALF(zskid)) q:zskid=""  do
 .D AUDIT("RALF",zskid)
 .W !,"RUNRALF^SKID: ",zskid
 .D RUNRALF^SKID(zskid)
 .quit
 
 set ^ZQZ1(qid,i)=$Horolog
 quit
 
AUDIT(glob,zskid) 
 n a,b
 s a=+$h,b=$p($h,",",2)
 s ^audit(glob,a,b)=zskid
 quit
 
ZQZ ;
 new i
 ; run for the next 5 days
 kill ^ZQZ(1)
 set ^ZQZ(1)="update mumps cache"
 f i=(+$H+1):1:(+$Horolog+4) do
 .S ^ZQZ(1,i)=$$TH^STDDATE("00:05")
 .quit
 quit
 
JOBEXAM(%ZPOS) 
 s idx=$o(^interupt(""),-1)+1
 S ^interupt(idx)=$get(%ZPOS)
 D LOG
 quit
 
LOG ;
 K ^LOG
 S %D=$H,%I="exam"
 S %TOP=$STACK(-1),%N=0
 F %LVL=0:1:%TOP S %N=%N+1,^LOG("log",%D,$J,%I,"error","stack",%N)=$STACK(%LVL,"PLACE")_":"_$STACK(%LVL,"MCODE")
 N %X,%Y
 S %X="^LOG(""log"",%D,$J,%I,""error"",""symbols"","
 S %Y="%" F  M:$D(@%Y) @(%X_"%Y)="_%Y) S %Y=$O(@%Y) Q:%Y=""
 quit
