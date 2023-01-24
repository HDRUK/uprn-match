POUR4 ; ; 1/23/23 4:38pm
 ; next version of PoR utility
 ;
 
EXT ;
 new a,b
 S f="/tmp/eltest.txt"
 o f:(newversion)
 use f
 s (a,b)=""
 f  s a=$o(^POUR("O",a)) q:a=""  do
 .f  s b=$o(^POUR("O",a,b)) q:b=""  do
 ..w ^(b),!
 close f
 quit
 
TST ;
 K ^X
 s (page,count)=""
 f  s page=$o(^POUR("O","eltest",page)) q:page=""  do
 .f  s count=$o(^POUR("O","eltest",page,count)) q:count=""  do
 ..s rec=$g(^(count,1))
 ..i rec'="" s ^X(rec)=$get(^X(rec))+1
 quit
 
SETUP ;
 set ^%W(17.6001,"B","GET","por4/stt","STT^POUR4",650387)=""
 set ^%W(17.6001,650387,"AUTH")=2
 
 set ^%W(17.6001,"B","POST","por4/run","RUN^POUR4",650388)=""
 set ^%W(17.6001,650388,"AUTH")=2
 
 set ^%W(17.6001,"B","GET","por4/status","STATUS^POUR4",650390)=""
 set ^%W(17.6001,650390,"AUTH")=2
 
 set ^%W(17.6001,"B","GET","por4/info","INFO^POUR4",650396)=""
 set ^%W(17.6001,650396,"AUTH")=2
 
 set ^%W(17.6001,"B","GET","por4/download","DOWNLOAD^POUR4",650399)=""
 set ^%W(17.6001,650399,"AUTH")=2
 
 set ^%W(17.6001,"B","GET","por4/webdownload","WEBDOWN^POUR4",650401)=""
 set ^%W(17.6001,650401,"AUTH")=2
 quit
 
FN(file) ;
 new f
 s f=""
 c file
 o file:(readonly)
 f  u file r str q:$zeof  do  q:f'=""
 .i str["filename=" do
 ..s f=$p($p(str,"filename=""",2),"""")
 ..quit
 .quit
 close file
 quit f
 
WEBDOWN(result,arguments) ;
 new page
 
 K ^TMP($J)
 
 ;set ^TMP($J,1)="web download"
 
 do H("<h1 style=""background-color:DodgerBlue;"">PoR utility v0.4 (Downloads)</h1>")
 do H("<p>Your last run created the following files ...</p>")
 do H("<p>Click on a link to download a file</p>")
 do H("<p>Each file contains 300,000 records (apart from the last file)</p>")
 
 ;do H("<br>")
 do H("<table border=1>")
 s page=""
 f  s page=$o(^POUR("O",un,page)) q:page=""  do
 .do H("<td style=""width:25%"">file "_page_"</td><td style=""width:50%""><a href=""/por4/download?page="_page_""" download="""_un_"_"_page_".txt"">"_un_"-"_page_"</a><tr>")
 .quit
 do H("</table>")
 
 set result("mime")="text/html"
 set result=$na(^TMP($J))
 quit
 
DOWNLOAD(result,arguments) ;
 new c,crlf,d
 k ^TMP($j)
 
 ;set ^TMP($j,1)="test"
 S ^FRED="["_un_"]"
 
 s crlf=$c(13,10)
 s page=$get(arguments("page"))
 s all=$get(arguments("all"))
 
 set d=$char(9)
 set hdr="compass_skid"_d_"PoR"_d_"event_date"_d_"prop_class"_d_"prop_desc"_d_"lsoa"_d_"msoa"
 set hdr=hdr_d_"outside_adr_dates"_d_"invalid_class_prop"_d_"not_best"_d_"no_assign"_d_"not_registered"_$c(10)
 s ^TMP($job,1)=hdr
 
 if all="" do
 .set c=""
 .f  s c=$order(^POUR("O",un,page,c)) q:c=""  do
 ..set why=$get(^POUR("O",un,page,c,1))
 ..;set why=$$TR^LIB(why,"~",$c(9))
 ..s ^TMP($J,(c+1))=^POUR("O",un,page,c)
 ..f i=1:1:5 set $p(^TMP($J,(c+1)),$c(9),(i+7))=$piece(why,"~",i)
 ..s ^TMP($J,(c+1))=^TMP($J,(c+1))_$C(10)
 ..quit
 .quit
 
 if all'="" do
 .s z=$o(^POUR("O",un,""),-1)
 .f i=1:1:z do
 ..s c=""
 ..f  s c=$o(^POUR("O",un,z,c)) quit:c=""  do
 ...s ^TMP($j,c)=^(c)_$c(10)
 ...quit
 ..quit
 .quit
 
 ; test zip download
 ;s file="/tmp/uprnrtns/eltest.zip"
 
 ;s file="/tmp/uprnrtns/test1.zip"
 ;close file
 ;open file:(readonly:fixed:nowrap:recordsize=255:chset="M"):0
 
 ;use file
 ;s c=1
 ;f i=1:1 r str:0  q:$zeof  do
 ;.set ^TMP($J,c)=str,c=$i(c)
 ;.quit
 ;close file
 
 
 set result("mime")="text/html"
 
 ;set result("mime")="application/zip"
 set result=$na(^TMP($J))
 ;set result=$na(^POUR("O",un))
 quit
 
RUN(arguments,body,result) ;
 new c,qf,count
 
 ; test if already running?
 lock ^KRUNNING(un):0.5
 if '$t do  quit 1
 .s ^TMP($J,1)="{""upload"": { ""status"": ""you are already running a job""}}"
 .set result("mime")="text/html"
 .set result=$na(^TMP($J))
 .quit
 
 ; get rid of the fluff at the top of the file
 ;if $data(body(1)) set body(1)=$p(body(1),$c(10),5,9999999999)
 K ^BODY
 M ^BODY=body
 
 set file="/tmp/f"_$job_".txt"
 close file
 open file:(newversion:stream:nowrap:chset="M")
 set c=""
 for  set c=$order(body(c)) q:c=""  do
 .s rec=body(c)
 .use file write rec
 .quit
 close file
 
 ;
 ;
 ;
 ;
 ;
 ;
 ;
 ;
 ;
 ;
 ;
 ;
 
TEST ;set file="/tmp/f2516.txt"
 set count=1
 
 ; get fixed date, CompassSKID name, RALFSKID name 
 ; must be file in the request if date is null
 
 ; check filename extension
 set filename=$$FN(file)
 
 if filename'="",$p(filename,".",$l(filename,"."))'="txt" do  q 1
 .d DEL(file)
 .s ^TMP($J,1)="{""upload"": { ""status"": ""must be an ascii text file""}}"
 .set result("mime")="text/html"
 .set result=$na(^TMP($J))
 .quit
 
 ; nhs_number
 set pseudosalt=$$VAR^POUR(file,"pseudo_salts")
 set fixeddate=$$VAR^POUR(file,"date")
 ; ralf
 set ralfsalt=$$VAR^POUR(file,"ralf_salts")
 ;set filename=$$FN(file)
 
 kill ^U3(un)
 set ^U3(un)=pseudosalt_"~"_fixeddate_"~"_ralfsalt_"~"_filename_"~"_$Horolog
 
 if fixeddate="" do
 .; must have uploaded a file
 .;
 .;
 .;
 .close file
 .o file:(readonly)
 .s (qf,go)=0
 .f  use file r str q:$zeof  do  quit:qf
 ..if str[filename do  quit
 ...use file r str,str
 ...s go=1
 ...quit
 ..if 'go quit
 ..if str["----------------------" set qf=1 quit
 ..if str["WebKitForm" set qf=1 quit
 ..set str=$translate(str,$c(13),"")
 ..i str="" quit
 ..set ^U3(un,count)=str
 ..s count=$i(count)
 ..quit
 .close file
 .quit
 
 do DEL(file)
 lock -^KRUNNING(un)
 
 job JRUN(un):(out="/dev/null")
 
 s ^TMP($J,1)="{""upload"": { ""status"": ""OK""}}"
 set result("mime")="text/html"
 set result=$na(^TMP($J))
 quit 1
 
DEL(f) ;
 close f
 o f:(readonly)
 c f:delete
 quit
 
JRUN(user) ;
 new c,pour,nor,eventdate,nors,propclass,propdesc,ralf00
 new pseudosalt,fixeddate,ralfsalt,filename
 
 set $ET="G ERROR^POUR4"
 
 lock ^KRUNNING(user):0
 
 k ^POUR("O",user)
 set rec=^U3(user)
 set pseudosalt=$piece(rec,"~",1)
 set fixeddate=$piece(rec,"~",2)
 set ralfsalt=$p(rec,"~",3)
 set filename=$p(rec,"~",4)
 
 ;W !,"[",fixeddate,"]" r *y
 
 ;
 if fixeddate'="" D FIXED(pseudosalt,fixeddate,ralfsalt,user)
 if fixeddate="" D FILE(pseudosalt,ralfsalt,user)
 lock -^KRUNNING(user)
 quit
 
WRITEANDZIP(user) 
 new c
 s f="/tmp/uprnrtns/"_user_".txt"
 close f
 open f:(newversion)
 s c=""
 f  s c=$o(^POUR("O",user,c)) q:c=""  do
 .use f w ^(c),!
 .quit
 close f
 quit
 
FILE(pseudosalt,ralfsalt,user) ;
 new count,pseudo,date,nors,nor,c,total,page,zi
 
 set sralf=$p(ralfsalt,"_",3)
 set spseudo=$p(pseudosalt,"_",3)
 
 kill ^POUR("O",user)
 k ^T(user)
 set ^T(user,1)=$Horolog
 
 set total=$order(^U3(user,""),-1)
 
 ; set ^SPIT("P") from ^SPIT("N")
 D U3^SKID(user,spseudo)
 
 set count="",c=1,page=1
 f  set count=$o(^U3(user,count)) quit:count=""  do
 .s rec=^(count)
 .s pseudo=$piece(rec,$c(9),1)
 .s date=$p(rec,$c(9),2)
 .; get the patient ids
 .set nors=$get(^SPIT("P",spseudo,pseudo))
 .;W !,"[",nors,"]" ; R *Y
 .if nors="" quit
 .for zi=1:1:$l(nors,"~") q:$p(nors,"~",zi)=""  do
 ..set nor=$piece(nors,"~",zi)
 ..;w !,nor r *y
 ..S pour=$$PLACEATEVT^FX2(nor,date,1)
 ..;W !,pour r *y
 ..D SAVE(pour,c,page,nor)
 ..;set ^T(user)="processing "_count_" of "_total
 ..set ^T(user)=(total-count)_"~"_total
 ..;
 ..set c=$i(c)
 ..i c#300000=0 s page=page+1
 ..;
 ..quit
 .quit
 set ^T(user,2)=$Horolog
 quit
 
 ; pseudo_salts_3
 ; 2023-01-04
 ; ralf_salts_1
 ; d FIXED^POUR4("pseudo_salts_3","2023-01-04","ralf_salts_1","eltest")
 ;
FIXED(pseudosalt,fixeddate,ralfsalt,user) 
 new nor,r,why,c,total,page
 
 set nor="",c=1
 K ^POUR("O",user)
 
 K ^T(user)
 set ^T(user,1)=$Horolog
 
 set sralf=$p(ralfsalt,"_",3)
 set spseudo=$p(pseudosalt,"_",3)
 
 set total=$get(^ASUM)
 
 set page=1
 
 f  s nor=$order(^ASUM(nor)) quit:nor=""  do
 .S pour=$$PLACEATEVT^FX2(nor,fixeddate,1)
 .;W !,pour r *y
 .;S why=$$WHY^POPEXT()
 .;I why'="",why'=5 w !,nor,!,"[",why,"]" r *y
 .;;s propclass=$p(pour,"~",6)
 .;;s propdesc=$get(^RESCODE(propclass))
 .;;s rec=$p(pour,"|",3)
 .;;s lsoa=$p(rec,"~",1),msoa=$p(rec,"~",2)
 .;;set uprn=$p(pour,"~",3)
 .;W !,"[",pour,"]" r *y
 .;i $L(pour,"~")<4 quit ; ** ?
 .;;set pseudo=$get(^SPIT("N",spseudo,nor))
 .;;s ralf=$get(^RALF(sralf,uprn))
 .;S ^POUR("O",user,c)=pseudo_$c(9)_ralf_$c(9)_$c(9)_propclass_$c(9)_propdesc_$c(9)_lsoa_$c(9)_msoa
 .;;S ^POUR("O",user,c)=pseudo_"~"_ralf_"~"_propclass_"~"_lsoa_"~"_msoa
 .do SAVE(pour,c,page,nor)
 .s c=c+1
 .i c#1000=0 w !,c
 .I c#300000=0 s page=page+1
 .;s ^T(user)="processing "_c_" of "_total
 .set ^T(user)=(total-c)_"~"_total
 .;
 .quit
 set ^T(user,2)=$Horolog
 quit
 
SAVE(pour,c,page,nor) ;
 new propclass,propdesc,rec,lsoa,msoa,uprn,pseudo,ralf,d
 new reason
 
 ;I $L(pour,"~")=3 quit
 
 s propclass=$p(pour,"~",6)
 s propdesc=$get(^RESCODE(propclass))
 s rec=$p(pour,"|",3)
 s lsoa=$p(rec,"~",1),msoa=$p(rec,"~",2)
 set uprn=$p(pour,"~",3)
 ;if uprn="" quit
 set pseudo=$get(^SPIT("N",spseudo,nor))
 s ralf=$get(^RALF(sralf,uprn))
 set d=$c(9)
 S ^POUR("O",user,page,c)=pseudo_d_ralf_d_propclass_d_lsoa_d_msoa
 
 ; reason
 ; outside_adr_dates, invalid_class_prop, not_best, no_assign, not_registered
 if $L(pour,"~")=3!(pour="") do
 .S why=$$WHY^POPEXT()
 .;break
 .set reason=""
 .f i=1:1:$length(why,"~") s $p(reason,"~",$P(why,"~",i))="X"
 .s ^POUR("O",user,page,c,1)=reason
 .quit
 quit
 
H(h) ;
 new c
 s c=$order(^TMP($J,""),-1)+1
 s ^TMP($J,c)=h_$c(13,10)
 quit
 
WRITE ;
 new c,r,a
 D STT(.r,.a)
 s f="/tmp/pour4.html"
 close f
 o f:(newversion)
 s c=""
 f  s c=$o(^TMP($J,c)) q:c=""  do
 .use f w ^(c)
 .quit
 close f
 quit
 
OUTPUT ;
 do H("<font size=""3"" face=""Courier New""><u><b>Outputs</b></u></p></font>")
 do H("<table border=1 width=""50%"">")
 do H("<td>CompassSKID</td><td>pseudo anonymised nhs_number</td><tr>")
 do H("<td>PoR</td><td>RALFSKID (anonymised UPRN)</td><tr>")
 do H("<td>event_date</td><td>event date used to find PoR</td><tr>")
 do H("<td>prop_class</td><td>property classification code</td><tr>")
 do H("<td>prop_desc</td><td>property classification description</td><tr>")
 do H("<td>lsoa</td><td>lower layer super output area (2011)</td><tr>")
 do H("<td>msoa</td><td>middle layer super output area (2011)</td><tr>")
 do H("</table>")
 quit
 
TODAY() ;
 new today
 set today=$$HD^STDDATE(+$H)
 set today=$p(today,".",3)_"-"_$p(today,".",2)_"-"_$p(today,".",1)
 quit today
 
 ; pseudo_salts
 ; ralf_salts
COMBO1(id) ;
 new i,name
 set i=""
 set html="<select name="""_id_""" style=""width: 150px;"">"
 set html=html_"<option value=""?"">?</option>"_$char(10)
 f  s i=$o(^SALTS(id,i)) q:i=""  do
 .s name=^SALTS(id,i,"saltKeyName")
 .s n=+$e(name,$l(name)-1,$l(name))
 .set star=""
 .if id="pseudo_salts",$data(^SPIT("N",n)) set star="*"
 .if id="ralf_salts",$data(^RALF(n)) set star="*"
 .s html=html_"<option value="""_id_"_"_n_""">"_star_name_"</option>"_$c(10)
 .quit
 s html=html_"</select>"
 quit html
 
COMBO2() ;
 quit ""
 
 ; default to 1
 ; until I write a custom alert box
T(n) q $j("",1)
 
STT(result,arguments) 
 n c
 kill ^TMP($J)
 ; radio buttons (default to fixed date)
 do H("<html>")
 
 do H("<script src=""https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js""></script>")
 
 do H("<script>")
 do H("function validateForm() {")
 do H("  ajaxStatus(0);")
 do H("  var result = document.getElementById('result');")
 do H("  let z = result.innerHTML;")
 do H("  if (z.includes('CRASHED')) {alert('your last run crashed!  please contact support'); return false;}")
 do H("  if (z.includes('last click')) {alert('you have a job already running - click on Run Status for more information'); return false;}")
 do H("  var pseudo_salts = document.forms[""MyForm""][""pseudo_salts""].value;")
 do H("  var ralf_salts = document.forms[""MyForm""][""ralf_salts""].value;")
 do H("  var file = document.forms[""MyForm""][""fileToUpload""].value;")
 
 ;do H("  var fileInput =  document.getElementById('fileToUpload');")
 ;do H("  var file = fileInput.files[0].name;")
 
 do H("  var date = document.forms[""MyForm""][""date""].value;")
 
 ;do H("  alert(pseudo_salts);")
 ;do H("  alert(ralf_salts);")
 ;do H("  alert(file);")
 ;do H("  alert(date);")
 ;do H("  parent._alert = new parent.Function(""alert(arguments[0]);"");");
 ;do H("  parent._alert('Test!');")
 
 ; ** TO DO
 ;do H("  if (!file.match('/[^/]*\.txt')) {alert('invalid filename '+file); return false;}")
 
 do H("  if (file != '' && date != '') {alert('Please enter a fixed date or upload file (not both)'); return false;}")
 do H("  if (file == '' && date == '') {alert('Please select a file, or enter a fixed date before proceeding'); return false;}")
 do H("  if (pseudo_salts == '?' || ralf_salts == '?') {alert('Please select a CompassSKID and RALFSKID before continuing'); return false;}")
 ;do H("  alert('here we go!');")
 do H("  return true;")
 do H("}")
 
 do H("function ajaxSubmit() {")
 do H("  var val = validateForm();")
 
 ;do H("  // alert('ajax '+val);")
 ;do H("  // if (val == true) {alert('truey');}")
 
 do H("  if (val == false) {return false;}")
 ;do H("  alert('do the ajax request');")
 do H("  if (!confirm('Continue?')) {return false;}")
 do H("  var form = document.getElementById('MyForm');")
 do H("  var formData = new FormData(form);")
 do H("  var xhr = new XMLHttpRequest();")
 
 do H("  xhr.addEventListener('readystatechange', onreadystatechangeHandler, false);")
 do H("  xhr.upload.addEventListener('progress', onprogressHandler, false);")
 
 do H("  xhr.open('POST', '/por4/run', true);")
 do H("  xhr.send(formData);")
 do H("  return false;")
 do H("}")
 
 do H("function onreadystatechangeHandler(evt) {")
 do H("  var status, text, readyState;")
 do H("  try {")
 do H("    readyState = evt.target.readyState;")
 do H("    text = evt.target.responseText;")
 do H("    status = evt.target.status;")
 do H("  }")
 do H("  catch(e) {")
 do H("    return;")
 do H("  }")
 do H("  if (readyState == 3 && status == '201' && evt.target.responseText) {")
 do H("    var status = document.getElementById('upload-status');")
 do H("    //status.innerHTML += '<u>Success!';")
 do H("    var result = document.getElementById('result');")
 do H("    let obj = JSON.parse(event.target.responseText);")
 do H("    let json = JSON.stringify(obj);")
 do H("    console.log(json);")
 do H("    console.log(obj.upload.status);")
 do H("    var status = obj.upload.status;")
 
 ;do H("    result.innerHTML = '<p>The server saw it as:</p><pre>' + evt.target.responseText + '</pre>';")
 do H("    result.innerHTML = '<p>The servers response: ' + status + '</p>';")
 ;do H("    alert('test');")
 do H("    if (status != 'OK') {alert(status)};")
 ;do H("    ")
    
 do H("  }")
 do H("}")
 
 do H("function onprogressHandler(evt) {")
 do H("  var div = document.getElementById('progress');")
 do H("  var percent = evt.loaded/evt.total*100;")
 do H("  div.innerHTML = 'Progress: ' + percent + '%';")
 do H("}")
 
 do H("function resetFile() {")
 do H("  const file = document.querySelector('.fileToUpload');")
 do H("  file.value = '';")
 do H("}")
 
 do H("async function ajaxStatus(zalert) {")
 ;do H("  var url = '/por4/status';")
 ;do H("  let response = await fetch(url);")
 ;do H("  let response = await this.http.get(url).toPromise();")
 ;do H("  var str = '';")
 do H("  $.ajax({")
 do H("    url: '/por4/status',")
 do H("    async: false,")
 do H("    dataType: 'json',")
 do H("    success: function (response) {")
 do H("       //let obj  = JSON.parse(response);")
 do H("       //alert(response.text);")
 do H("       //console.log(response.json);")
 do H("       //console.log(response.text);")
 do H("       var str = response.upload.status;")
 do H("       str = str.replaceAll('~', String.fromCharCode(10));")
 do H("       if (zalert == 1) {alert(str);}")
 do H("       var result = document.getElementById('result');")
 do H("       result.innerHTML = '<p>The servers response: ' + str + '</p>';")
 do H("       //alert(str);")
 do H("       //alert('test');")
 do H("       //return str;")
 do H("    }")
 do H("  });")
 ;do H("  return str;")
 do H("}")
 
 ; ajaxInfo
 do H("async function ajaxInfo() {")
 do H("  //alert('quick exit');");
 do H("  //return;")
 do H("  ajaxStatus(0);")
 do H("  var result = document.getElementById('result');")
 do H("  let z = result.innerHTML;")
 do H("  if (z.includes('CRASHED')) {alert('your last run crashed!  please contact support'); return;}")
 do H("")
 do H("  $.ajax({")
 do H("    url: '/por4/info',")
 do H("    async: false,")
 do H("    dataType: 'json',")
 do H("    success: function (response) {")
 do H("       var file = response.Info.Filename;")
 do H("       var fixed = response.Info.FixedDate;")
 do H("       var dur = response.Info.Duration;")
 do H("       var durunits = response.Info.DurationUnits;")
 do H("       var skid1 = response.Info.NhsNumberSalt;")
 do H("       var ralf = response.Info.RalfSalt;")
 do H("       var processed = response.Info.PatientProcessed;")
 do H("       var status = response.Info.Status;")
 do H("       var start = response.Info.RunStart;")
 do H("       var end =  response.Info.RunEnd;")
 do H("")
 do H("       var info = '';")
 do H("       if (file != '') info = 'File:"_$$T(50-5)_"' + file + String.fromCharCode(10);")
 do H("       if (fixed != '') info = info + 'Fixed date:"_$$T(50-11)_"' + fixed + String.fromCharCode(10);")
 ;do H("       info = info + 'Time to process (' + durunits + '):"_$$T(50-11)_"' + dur + String.fromCharCode(10);")
 do H("       info = info + 'CompassSKID name:"_$$T(50-17)_"' + skid1 + String.fromCharCode(10);")
 do H("       info = info + 'RALFSKID name:"_$$T(50-13)_"' + ralf + String.fromCharCode(10);")
 do H("       info = info + 'Total number of patients in cohort:"_$$T(31-11)_"' + processed + String.fromCharCode(10);")
 do H("       info = info + 'Status:"_$$T(50-7)_"' + status + String.fromCharCode(10);")
 do H("       info = info + 'Start time:"_$$T(50-11)_"' + start + String.fromCharCode(10);")
 do H("       info = info + 'End time:"_$$T(50-9)_"' + end;")
 do H("       alert(info);")
 do H("    }")
 do H("  });")
 do H("}")
 
 do H("")
 do H("function webDownload() {")
 ;do H("  window.open ('/por4/webdownload', '', 'width=400, height=400');")
 do H("  ajaxStatus(0);")
 do H("  var result = document.getElementById('result');")
 do H("  let z = result.innerHTML;")
 do H("  if (z.includes('CRASHED')) {alert('your last run crashed!  please contact support'); return;}")
 do H("  window.open ('/por4/webdownload')")
 do H("}")
 
 do H("</script>")
 
 do H("<h1 style=""background-color:DodgerBlue;"">PoR utility v0.4</h1>")
 
 do H("<font size=""3"" face=""Courier New""><u><b>Fixed date</b></u><br></font>")
 
 ;do H("<p>Finds place of residence (PoR) for date entered (for all currently registed patients)</p>")
 do H("<p>For all currently registered patients return place of residence (PoR) and associated meta data for date entered</p>")
 
 do H("<font size=""3"" face=""Courier New""><u><b>File</b></u><br></font>")
 ;do H("<p>Finds place of residence (PoR) for each CompassSKID and event_date in uploaded file ")
 do H("<p>For each CompassSKID and event_date in uploaded file return PoR and associated meta data</p>")
 
 ;do H("(CompassSKID is a psuedo anonymised NHS number)</p>")
 
 ;do H("<font size=""3"" face=""Courier New""><b>Output</b></p></font>")
 ;do H("<table border=1 width=""50%"">")
 ;do H("<td>CompassSKID</td><td>pseudo anonymised nhs_number</td><tr>")
 ;do H("<td>PoR</td><td>RALFSKID (anonymised UPRN)</td><tr>")
 ;do H("<td>event_date</td><td>event date used to find PoR</td><tr>")
 ;do H("<td>prop_class</td><td>property classification code</td><tr>")
 ;do H("<td>prop_desc</td><td>property classification description</td><tr>")
 ;do H("<td>lsoa</td><td>lower layer super output area (2011)</td><tr>")
 ;do H("<td>msoa</td><td>middle layer super output area (2011)</td><tr>")
 ;do H("</table>")
 
 ;do H("<form action=""/por4/run"" method=""post"" enctype=""multipart/form-data"" onsubmit=""return validateForm()"" name=""MyForm"" id=""MyForm"">")
 
 ;do H("<form action=""/por4/run"" method=""post"" enctype=""multipart/form-data"" name=""MyForm"" id=""MyForm"">")
 
 do H("<font size=""3"" face=""Courier New""><u><b>Inputs</b></u><br></font>")
 do H("</p>")
 
 do H("<form enctype=""multipart /form-data"" name=""MyForm"" id=""MyForm"">")
 
 do H("<font size=""2"" face=""Courier New"">")
 do H("<table border=1 width=""50%"">")
 do H("<td>Fixed date</td>")
 
 ;do H("<td><input type=""radio"" id=""date"" name=""groupme"" value=""date"" checked></td><tr>")
 
 do H("<td><input type=""date"" id=""date"" name=""date"" min=""1991-01-01"" max="""_$$TODAY()_"""></td><tr>")
 
 ;do H("<td>File</td><td><input type=""radio"" id=""file"" name=""groupme"" value=""file""></td><tr>")
 ;do H("<td>File (click Choose file, then Cancel button to remove)</td><td><input type=""file"" id=""fileToUpload"" name=""fileToUpload""></td><tr>")
 
 do H("<td>File</td><td><input type=""file"" class=""fileToUpload"" id=""fileToUpload"" name=""fileToUpload""/><tr>")
 do H("<td>CompassSKID name</td><td>"_$$COMBO1("pseudo_salts")_"</td><tr>")
 do H("<td>RALFSKID name</td><td>"_$$COMBO1("ralf_salts")_"</td><tr>")
 do H("<td>reset all inputs</td><td><button onclick=""resetFile()"">reset</button></td><tr>")
 
 ;do H("<td>&nbsp;</td>&nbsp;<td></td><tr>")
 ;do H("<tr>")
 ;do H("<td></td><td><input type=""submit"" name=""submit"" value=""Next""></td><tr>")
 ;do H("<td></td><td><button onclick=""ajaxSubmit()"">Ajax</button></td><tr>")
 
 do H("</table>")
 do H("</font>")
 do H("</form>")
 
 do H("<table style=""width:20%"">")
 
 do H("<td><button onclick=""resetFile()"">reset file chosen</button></td>")
 
 do H("<td><button onclick=""ajaxSubmit()"">Run</button></td>")
 ;do H("<td><button onclick=""resetFile()"">reset file chosen</button></td>")
 
 do H("</table>")
 do H("</p>")
 
 do OUTPUT
 
 ;do H("<fieldset>")
 ;do H("<legend>Fixed date or file upload?</legend>")
 
 ;do H("<div>")
 ;do H("<input type=""radio"" id=""date"" name=""groupme"" value=""date"" checked>")
 ;do H("<label for=""date"">Fixed date</label>")
 ;do H("</div>")
 
 ;do H("<div>")
 ;do H("<input type=""radio"" id=""file"" name=""groupme"" value=""file"">")
 ;do H("<label for=""file"">File</label>")
 ;do H("</div>")
 
 ;do H("</fieldset>")
 
 do H("<br>")
 do H("<font size=""3"" face=""Courier New""><u><b>Download</b></u></p></font>")
 
 
 do H("<p>Click on the Download button to download a copy of the Output from your last run</p>")
 ;do H("<p>Your last run was done on blah@blah</p>")
 ;do H("<p>You entered the following information to produce your last output:</p>")
 
 ;do H("<button onclick=""Download()"">Download</button>")
 ;do H("<a href=""/por4/download/"_un_".txt"" download="""_un_".txt""><button>Download</button></a>")
 
 ;do H("<button><a href=""/por4/download"" a download="""_un_".txt"">Download</a></button>")
 
 do H("<button onclick=""webDownload()"">Download</button>")
 
 do H("<button onclick=""ajaxStatus(1)"">Run Status</button>")
 
 do H("<button onclick=""ajaxInfo()"">Info about last run</button>")
 
 do H("<p id=""upload-status""></p>")
 do H("<p id=""progress""></p>")
 do H("<pre id=""result"" hidden></pre>")
 
 do H("</html>")
 
 set result("mime")="text/html"
 set result=$na(^TMP($J))
 quit
 
INFO(result,arguments) ;
 new rec,b,nhssalt,fixeddate,ralfsalt,file,d,t,rundate,runtime
 new start,end,b,j,e,i,s1,e1,processed
 
 k ^TMP($J)
 set rec=$get(^U3(un))
 i rec="" do
 .s ^TMP($j,1)="{""Info"":{""status"":""never run""}}"
 .quit
 i rec'="" do
 .set nhssalt=$p(rec,"~",1)
 .set fixeddate=$p(rec,"~",2)
 .set ralfsalt=$p(rec,"~",3)
 .set file=$p(rec,"~",4)
 .set d=+$p(rec,"~",5)
 .set t=$p($p(rec,"~",5),",",2)
 .set rundate=$$HD^STDDATE(d)
 .set runtime=$$HT^STDDATE(t)
 .set start=$get(^T(un,1))
 .set end=$get(^T(un,2))
 .s s1=$$HD^STDDATE($p(start,","))_":"_$$HT^STDDATE($p(start,",",2))
 .s e1=$$HD^STDDATE($p(end,","))_":"_$$HT^STDDATE($p(end,",",2))
 .if file="" s processed=+$get(^ASUM)
 .else  s processed=$order(^U3(un,""),-1)
 .set duration=$justify($$MINDIFF(end,start)/60,0,2)
 .set b("Info","PatientProcessed")=$fn(processed,",")
 .set b("Info","Duration")=duration
 .set b("Info","RunStart")=s1
 .set b("Info","RunEnd")=e1
 .set b("Info","DurationUnits")="hours"
 .set b("Info","Filename")=file
 .set b("Info","FixedDate")=fixeddate
 .set b("Info","NhsNumberSalt")="CompassSKID"_$tr($j($p(nhssalt,"_",3),2)," ",0)
 .set b("Info","RalfSalt")="RALFSKID"_$tr($j($piece(ralfsalt,"_",3),2)," ",0)
 .;set b("Info","RunDate")=$$HD^STDDATE(d)_":"_$$HT^STDDATE(t)
 .;set b("Info","RunTime")=$$HT^STDDATE(t)
 .set b("Info","Status")=$$ST(un)
 .D ENCODE^VPRJSON($NA(b),$NA(j),$NA(e))
 .set (i,j)=""
 .F  S i=$o(j(i)) q:i=""  s j=j_j(i)
 .S ^TMP($job,1)=j
 .quit
 set result("mime")="text/html"
 set result=$na(^TMP($J))
 quit
 
ST(user) ;
 new status
 set status="?"
 lock ^KRUNNING(user):0.5
 if '$t set status="RUNNING" q status
 ;lock -^KRUNNING(user)
 i $d(^POUR("O",user)) s status="READY TO DOWNLOAD"
 ; unlock anyway
 lock -^KRUNNING(user)
 quit status 
 
IDERROR(user) ;
 new id,error
 set id="",error=0
 f  s id=$o(^POUR4(id)) q:id=""  do  q:error'=""
 .s zuser=$get(^POUR4(id,"error","symbols","user"))
 .i zuser=user s error=1
 .quit
 quit error
 
STATUS(result,arguments) ;
 new text,rec,r,t,lock
 
 k ^TMP($job)
 
 s error=$$IDERROR(un)
 if error s ^TMP($J,1)="{""upload"": { ""status"": ""!!!! YOUR LAST RUN CRASHED !!!! CONTACT SUPPORT""}}"
 s:'error ^TMP($J,1)="{""upload"": { ""status"": ""You have nothing running""}}"
 lock ^KRUNNING(un):0.5
 s ^lock=$t
 I '$T do
 .; ^T(un)=remaining~total
 .s rec=$get(^T(un))
 .s last=$get(^T(un,"l"))
 .s r=$p(rec,"~",1),t=$p(rec,"~",2)
 .s text="total patients: "_$fn(t,",")
 .s text=text_"~total patients left to process: "_$fn(r,",")
 .s text=text_"~total patients processed since last click: "_$s(last>0:$fn((last-r),","),1:0)
 .s ^TMP($J,1)="{""upload"": { ""status"": """_text_"""}}"
 .quit
 set ^fred=$get(un)
 set ^T(un,"l")=$p($get(^T(un))," ")
 set result("mime")="text/html"
 set result=$na(^TMP($J))
 quit
 
MINDIFF(dtm1,dtm2) ;
 N day,min,ret
 S day=$P(dtm1,",",1)-$P(dtm2,",",1)
 S min=$P(dtm1,",",2)-$P(dtm2,",",2)
 S ret=day*60*60*24  ; 60 secs in min, 60 mins in 1 hr, 24hrs in a day
 S ret=ret+min
 S ret=ret/60
 quit ret
 
ERROR ;
 new id
 s id=$o(^POUR4(""),-1)+1
 s ^POUR4(id)=$horolog
 s ^POUR4(id,"E")=$zstatus
 S %TOP=$STACK(-1),%N=0
 F %LVL=0:1:%TOP S %N=%N+1,^POUR4(id,"error","stack",%N)=$STACK(%LVL,"PLACE")_":"_$STACK(%LVL,"MCODE")
 N %X,%Y
 set %X="^POUR4(id,""error"",""symbols"","
 S %Y="%" F  M:$D(@%Y) @(%X_"%Y)="_%Y) S %Y=$O(@%Y) Q:%Y=""
 halt
