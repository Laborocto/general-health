preventing code from running automatically

*set up for Swedish national patient register, appending öppenvård and slutenvård

**Be aware to change the file name to your own data source placement 

use "P:\xxx\datasets\patient_register\oppenvard.dta" 
append using "P:\xxx\datasets\patient_register\slutenvard.dta"
duplicates drop
save "P:\xxx\datasets\patient_register\patient_register_no_duplicates.dta"
use "P:\xxx\datasets\patient_register\patient_register_no_duplicates.dta", clear


rename *,lower

gen alc_index=0 
gen ekod=0
foreach var of varlist ekod1-ekod4 { 
  	 replace ekod=1 if inlist(substr(`var',1,3),"860","980") & substr(indatum,1,4) <= "2010"
  replace alc_index= 1 if inlist(substr(`var',1,3),"Y90","Y91") 
  } 
  
foreach var of varlist dia1-dia11 {
	 replace `var'=substr(`var',2,5) if substr(`var',1,1)=="-"
  replace alc_index= 1 ///
  if (((ekod==1 & substr(`var',1,3)=="980") | ///
   inlist(substr(`var',1,3),"291","303", "979")| inlist(substr(`var',1,4),"571,0")) ///
   & substr(`var',4,1)==",") | ///
  ((inlist(substr(`var',1,3),"291","303") | inlist(substr(`var',1,4),"305A","357F","425F","535D","571A","571B","571C","571D")) ///
  & substr(`var',4,1)>="A" & substr(`var',4,1)<="X") | ///
  ((inlist(substr(`var',1,3),"F10","K70","T51") | ///
  inlist(substr(`var',1,4),"E244","G312","G621","G721","I426","K292","K852","K860") | ///
  inlist(substr(`var',1,4),"O354","P043","Q860","R780","Z040","Z502","Z714","Z721")))
  }

  
  
  	*2A) IDENTIFY FIRST-TIME DIAGNOSIS
gen diagnosis_date = date(indatuma, "YMD") if alc_index == 1
	format diagnosis_date %td

		*Extract year from dates -- if needed
gen year = year(diagnosis_date)

by lopnr, sort: egen first_alcohol_event = min(diagnosis_date)
	format first_alcohol_event %td
keep if first_alcohol_event == diagnosis_date & year <= 2010  
*alc_index=2,274 when less than 2010 

duplicates report lopnr if alc_index==1
*2,205 alc index and 138 with duplicate diagnoses when greater than 2010
*2,214 alc index and 60 duplicates when less than 2010


sort lopnr diagnosis_date
quietly by lopnr diagnosis_date: gen dup=cond(_N==1,0,_n)
tab dup 

drop if dup>1

gen count=_n
count if count
*2244 lopnr total to merge with  (in this example) 

save "P:\xxx\datasets\patient_register\patient_register_no_duplicates.dta", replace
