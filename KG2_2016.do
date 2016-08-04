

/*KG 2016 EGRA for Kyrgz Grade 2
*************************************************************************************************************

This do file does the following:
	1) Clean the data
	2) Creates varaibles that will be used in the analysis 


 Created by Paul Sirma  on 07.05.2016
*************************************************************************************************************
*/


*Path to original data, working data, do files, and outreg tables
global data "H:\ECA Region Projects\QRP Central Asia-D3452\Technical\Data\2016 KG EGRA\Original_data"
global wdata "H:\ECA Region Projects\QRP Central Asia-D3452\Technical\Data\2016 KG EGRA\Working_data"
global outreg "H:\ECA Region Projects\QRP Central Asia-D3452\Technical\Data\2016 KG EGRA\Outreg"
global do "H:\ECA Region Projects\QRP Central Asia-D3452\Technical\Data\2016 KG EGRA\do"

*Opening the data
use "${data}\KG_2016_K2(Final).dta" , clear   // Russian Grade 4 

tab grade, m //clean, only 2th
tab lang, m // clean, only K


*1) Timed Variables
*******************

	*Familiar Word 
	**************
	br fw1-fwsto1
	tab fwsto1 , m // 17 students were stopped early 
	
	br fw* if fwsto1 ==1   //14 student got the first 10 question wrong; 3 students were incorrectly stopped early
	br fw* if fwsto1 ==1   & (fw1 ==0 | fw2 == 0 | fw3==0 | fw4==0 |fw5==0 |fw6==0 |fw7==0 |fw8==0 |fw9==0|fw10==0) 
	
	*Early Stop Rule
	*Flag students who were incorrectly stopped early for familiar word 
	cap drop I_stop_err_fw
	gen I_stop_err_fw = (fwsto1 ==1 & (fw1 ==0 | fw2 == 0 | fw3==0 | fw4==0 |fw5==0 |fw6==0 |fw7==0 |fw8==0 |fw9==0|fw10==0)) 
	lab var I_stop_err_fw "Incorrectly stopped early in Familiar Word Section" 
	tab I_stop_err_fw fwsto1 , m
	
	br fw* if  fwsto1 ==1   & I_stop_err_fw==0 // 14 students who were correctly stopped 
	br fw* if  fwsto1 ==1   & I_stop_err_fw==1 // 3 students who were incorrectly stopped. browsing data, these students were not stopped. reversing early stop variable and calculating ORF.
	
	*Creating total_time used variable in seconds 
	tab  fwtim1
	tab  fwtim2
	cap drop fwtim_m
	tostring  fwtim1 , replace 
	gen fwtim_m = substr(fwtim1,1,1) if length(fwtim1) ==2
	replace fwtim_m = "0" if fwtim_m ==""
	order fwtim_m , after(fwtim1) 
	cap drop fwtim_m2
	gen fwtim_m2 = substr(fwtim1,2,1) if length(fwtim1) ==2
	replace fwtim_m2 = fwtim1 if length(fwtim1) ==1
	order fwtim_m2 , after(fwtim_m)
	br fwtim1  fwtim_m fwtim_m2  fwtim2

	destring fwtim1 fwtim_m fwtim_m2   , replace

	*Recoding minutes to seconds
	replace fwtim_m= fwtim_m* 60 //replacing minutes to seconds 
	tab fwtim_m
	tab fwtim2
	*Combining fwtim2 and fwtim3 variable into one variable 
	cap drop fw_23
	egen fw_23 = concat(fwtim_m2 fwtim2) 
	order fw_23 , after(fwtim2) 
	destring fw_23 , replace 


	cap drop fw_time_used
	gen fw_time_used = fwtim_m+ fw_23
	order fw_time_used , after(fw_23) 

	sort fw_time_used
	br fwtim1 fwtim_m fwtim_m2 fwtim2 fw_23 fw_time_used 

	*Creating a familiar word score 
	cap drop fw_string 
	egen fw_string = concat(fw1 fw2 fw3 fw4 fw5 fw6 fw7 fw8 fw9 fw10 fw11 fw12 fw13 fw14 fw15 fw16 fw17 fw18 fw19 fw20 fw21 fw22 fw23 fw24 fw25 fw26 fw27 fw28 fw29 fw30 fw31 fw32 fw33 fw34 fw35 fw36 fw37 fw38 fw39 fw40)
	order  fw_string , after(fw_time_used) 

	cap drop fwt_string
	egen fwt_string = concat(tfw1 tfw2 tfw3 tfw4 tfw5 tfw6 tfw7 tfw8 tfw9 tfw10 tfw11 tfw12 tfw13 tfw14 tfw15 tfw16 tfw17 tfw18 tfw19 tfw20 tfw21 tfw22 tfw23 tfw24 tfw25 tfw26 tfw27 tfw28 tfw29 tfw30 tfw31 tfw32 tfw33 tfw34 ///
								tfw35 tfw36 tfw37 tfw38 tfw39 tfw40) //Paul, there are 2 obs that have more than 2 times marked in the time variable, which need to be cleaned. egen fw_timeerror = noccur(fwt_string) , string(1) tab fw_timeerror
	order  fwt_string , after(fw_string) 
	br fwt_string fw_string
	*Cleaning time string variable. There should only be 2 stops: one at minute 1 and another one at minute 2
	*********************************************************************************************************
	cap drop timeerror
	egen timeerror = noccur(fwt_string) , string(1) 
	tab timeerror
	br fw* if timeerror==3  //observations with more than 2 stops 
	*Creating an indicator for error in timed variable
	/*
	*Note: The following rules should always be followed 
		1) Students who used less than 60secods should NOT have a "1" on their time string 
		2) Students who fineshed the test between 60 seconds and 120 seconds shoul have ONE "1" 
		3) Students who finished the test in 120 seconds should have 2 "1" 
	*/
	
	cap drop fw_timeerror 
	gen fw_timeerror = ((fw_time_used < 60 & timeerror !=0) | (fw_time_used >=60  & fw_time_used <120 & timeerror !=1) | ( fw_time_used >= 120 & timeerror !=2)   ) 
	tab fw_timeerror	
	br fw* if fw_timeerror==1 
	
	*Amy, can you decide how you want to clean these variables?
	***********************************************************
	
	/*We then need to change the time time string variable here to have at most 2 "1"
		
	
	
	*/
		
	cap drop fw_correct 
	egen fw_correct = noccur(fw_string) , string(0)  //counting the number of correct words student got for familiar word subtask
	order fw_correct , after( fwt_string) 
	sort fw_correct

	*Estimating per minute score, Paul, we need to adjust for students who didn't finish reading the full set of words in 2 minutes. you need to cut their response string.
	*Formula: (Total Correct / Time Used)*60
	cap drop fw_permin
	gen fw_permin = (fw_correct / fw_time_used) *60
	lab var fw_permin "Familiar Words"	
	order fw_permin , after(fw_correct) 
	*For students who were stopped early, replacing their score to 0 
	replace fw_permin = 0 if fwsto1 ==1 & I_stop_err_fw==0
	replace fw_correct = 0 if fwsto1 ==1 & I_stop_err_fw==0
	
	br fw* fw_permin if fwsto1 ==1 & I_stop_err_fw==0  //familiar word score for students who were correctly stopped early 
	br fw* fw_permin if fwsto1 ==1 & I_stop_err_fw==1  //familiar word score for students who were incorrectly stoped early Paul, this also looks off. we need to cut the response string for students who didn't read every item.
	*Amy, I am fixing the issue with students who used the full 2 minutes to finish 
	*******************************************************************************
	br fw* if fw_time_used >=120
	*Recalculating the scores of students who were stopped (students who used all of the 120 seconds allocated for the test) 
	************************************************************************************************************************
	*First, from time string, let's find the possition at which the second minute was marked 
	
	/* Stata 14 only 
	cap drop minute2 
	gen minute2 =  strrpos(fwt_string , "1") if fw_time_used >=120  //getting the item number student last attempted 
	tab minute2
	*/
	
	*Stata 13 equivalent of the function strrpos 
	cap drop minute2 
	gen minute2 =  strlen(fwt_string)-strpos(strreverse(fwt_string),"1")+1  if fw_time_used >=120  //getting the item number student last attempted  
	replace minute2= 0 if strpos(fwt_string,"1") ==0 // students who do not have a check on their time string when 2 minutes elapsed 
	
	
	br fw* minute2 fw_time_used if fw_time_used >=120
	cap drop fw_string2
	gen fw_string2 = substr(fw_string, 1, minute2) if fw_time_used >=120  //creating a response string from the first question to the last question student attempted when time expired
	order fw_string2 , after(fw_string) 
	*Counting the number of correct items for students who used 2 minutes
	********************************************************************
	cap drop fw_correct2
	egen fw_correct2 = noccur(fw_string2) , string(0)  //counting the number of correct words student got for familiar word subtask
	order fw_correct2 , after(fw_correct) 
	br fw_string fw_string2 fw_correct fw_correct2 fw_permin if fw_time_used >=120
	replace fw_permin = (fw_correct2 / fw_time_used) *60  if fw_time_used >=120  //replacing the per minute score for those students who used 2 minutes 
	
	*Amy, I am replacing to 0 the scores of students who took a full 2 minutes to finish the test but only attempted 10 questions at most 
	br fw_string fw_string2 fw_correct fw_correct2 fw_permin  fw_time_used  if minute2 <=10  // these students look like they should have been stopped early 
	replace fw_permin = 0 if minute2 <=10  
	

	*Creating a nonesense word score
	*******************************
	rename tufwr30 tufw30
	rename ufsto1 ufwst1 
	br ufw1-ufwst1

	tab ufwst1  // 3 students were stopped early 
	br ufw* if ufwst1=="1"  // 1 studnet got the first 10 question wrong; 2 stundents were incorrectly stopped. We also do not have time used for 1 students who was stopped early. Paul, studnet who got items 2-10 wrong and all toher right should be considered a correct early stop. missing time doesn't matter as ORF is 0. the other incorrect early stop should be calculated for ORF.
	
	br ufw* if ufwst1=="1" & (ufw1==0| ufw2==0| ufw3==0 |ufw4==0 |ufw5==0 | ufw6==0 | ufw7==0 | ufw8==0 | ufw9 ==0 | ufw10 ==0 ) //2 stundets were incorrectly stopped early. We don't have time used for 1 student. Paul see note above.
	*Flag students who were incorrectly stopped early in nonsense word section 
	cap drop I_stop_err_ufw
	gen  I_stop_err_ufw = (ufwst1=="1" & (ufw1==0| ufw2==0| ufw3==0 |ufw4==0 |ufw5==0 | ufw6==0 | ufw7==0 | ufw8==0 | ufw9 ==0 | ufw10 ==0 )) 
	lab var I_stop_err_ufw "Incorrectly stopped early in Nonesense Word Section" 
	order I_stop_err_ufw , after(ufwst1)
	tab I_stop_err_ufw ufwst1 , m
	
	br ufw*  if ufwst1=="1"  &  I_stop_err_ufw==0  //1 student who was correctly stopped
	br ufw*  if ufwst1=="1"  &  I_stop_err_ufw==1 // 2 students who were incorrectly stopped 
	
	*Recoding minutes to seconds
	tab ufwti1  //4 observations have time = 0 Paul, we need to investigate cleaning all timed sections for responses that are not logically possible. 2 of these cases were an early stop but missed marking the early stop. those need to be corrected. we need to look for those that have 9-10 of the first ten wrong and the rest right in all timed sections, as those people may need to be early stop and ORF 0.
	br ufw* if  ufwti1==0
	*Paul, this recoding minutes to seconds needs to be completed. below you just use the variable without changing it to all seconds.
	***Amy, I have made the changes below to address the above problem 
	******************************************************************
	sort ufwti1
	br ufwti1
	cap drop _ufwti1
	gen _ufwti1 = ufwti1
	order _ufwti1 , after(ufwti1) 
	tostring _ufwti1 , replace
	cap drop x
	gen x = strlen(_ufwti1) 	
	cap drop y 
	gen y = substr(_ufwti1,1,1) if strlen(_ufwti1)==3
	destring y , replace
	replace y = y * 60 
	
	cap drop z
	gen z = substr(_ufwti1,2,.) if strlen(_ufwti1)==3
	destring z , replace
	cap drop ufw_time_used
	gen ufw_time_used = y+ z 
	replace ufw_time_used = ufwti1 if ufw_time_used==. 
	order ufw_time_used , after(ufwti1)
	
	drop x y z _ufwti1
	tab ufw_time_used
	*****************


	*Creating a nonsense word score 
	cap drop ufw_string 
	egen ufw_string = concat(ufw1 ufw2 ufw3 ufw4 ufw5 ufw6 ufw7 ufw8 ufw9 ufw10 ufw11 ufw12 ufw13 ufw14 ufw15 ufw16 ufw17 ufw18 ufw19 ufw20 ufw21 ufw22 ufw23 ufw24 ufw25 ufw26 ufw27 ufw28 ufw29 ufw30 ufw31 ufw32 ufw33 ufw34 ///
								ufw35 ufw36 ufw37 ufw38 ufw39 ufw40)
	order  ufw_string , after(ufwti1) 

	cap drop ufwt_string
	egen ufwt_string = concat(tufw1 tufw2 tufw3 tufw4 tufw5 tufw6 tufw7 tufw8 tufw9 tufw10 tufw11 tufw12 tufw13 tufw14 tufw15 tufw16 tufw17 tufw18 tufw19 tufw20 tufw21 tufw22 tufw23 tufw24 tufw25 tufw26 tufw27 tufw28 tufw29 tufw30 ///
								tufw31 tufw32 tufw33 tufw34 tufw35 tufw36 tufw37 tufw38 tufw39 tufw40)
	order  ufwt_string , after(ufw_string) 
	br ufwt_string ufw_string
	
	*Cleaning time string variable. There should only be 2 stops: one at minute 1 and another one at minute 2
	*********************************************************************************************************
	cap drop timeerror
	egen timeerror = noccur(ufwt_string) , string(1) 
	tab timeerror
	br ufw* if timeerror==3  //observations with more than 2 stops 

	*Creating an indicator for error in timed variable
	/*
	*Note: The following rules should always be followed 
		1) Students who used less than 60secods should NOT have a "1" on their time string 
		2) Students who fineshed the test between 60 seconds and 120 seconds shoul have ONE "1" 
		3) Students who finished the test in 120 seconds should have 2 "1" 
	*/

	cap drop ufw_timeerror 
	gen ufw_timeerror = ((ufw_time_used < 60 & timeerror !=0) | (ufw_time_used >=60  & ufw_time_used <120 & timeerror !=1) | ( ufw_time_used >= 120 & timeerror !=2)   ) 
	tab ufw_timeerror	
	br ufw* if ufw_timeerror==1 
	
	*Amy, can you decide how you want to clean these variables?
	***********************************************************
	
	/*We then need to change the time time string variable here to have at most 2 "1"
		
		
	*/
		
	*Counting number of correct 
	cap drop ufw_correct 
	egen ufw_correct = noccur(ufw_string) , string(0)  //counting the number of correct words student got for familiar word subtask
	order ufw_correct , after( ufwt_string) 
	sort ufw_correct

	*Estimating per minute score, 
	*Formula: (Total Correct / Time Used)*60
	cap drop ufw_permin
	gen ufw_permin = (ufw_correct / ufw_time_used) *60  //Amy, using the correct time used variable 
	lab var ufw_permin "Nonsense Words"
	order ufw_permin , after(ufw_correct) 
	*Students who were stopped early should have a score of zero 
	replace  ufw_permin = 0   if ufwst1=="1"  &  I_stop_err_ufw==0 
	replace  ufw_correct = 0   if ufwst1=="1"  &  I_stop_err_ufw==0 
	
	br ufw*  if ufwst1=="1"  &  I_stop_err_ufw==0  // nonesense word score for students who were correctly stopped
	br ufw*  if ufwst1=="1"  &  I_stop_err_ufw==1 // nonesense word score for students who were incorrectly stopped 
	
	*Amy, I am fixing the issue with students who used the full 2 minutes to finish 
	*******************************************************************************
	br ufw* if ufw_time_used >=120
	*Recalculating the scores of students who were stopped (students who used all of the 120 seconds allocated for the test) 
	************************************************************************************************************************
	*First, from time string, let's find the possition at which the second minute was marked 
	/* Stata 14 only 
	cap drop minute2 
	gen minute2 =  strrpos(ufwt_string , "1") if ufw_time_used >=120  //getting the number of questions the student last attempted
	tab minute2
	*/
	
	*Stata 13 equivalent of the function strrpos 
	cap drop minute2 
	gen minute2 =  strlen(ufwt_string)-strpos(strreverse(ufwt_string),"1")+1  if ufw_time_used >=120  //getting the item number student last attempted  
	replace minute2= 0 if strpos(ufwt_string,"1") ==0 // students who do not have a check on their time string when 2 minutes elapsed 
		
	br ufw* minute2 ufw_time_used if ufw_time_used >=120
	cap drop ufw_string2
	gen ufw_string2 = substr(ufw_string, 1, minute2) if ufw_time_used >=120
	order ufw_string2 , after(ufw_string) 
	*Counting the number of correct items for students who used 2 minutes
	********************************************************************
	cap drop ufw_correct2
	egen ufw_correct2 = noccur(ufw_string2) , string(0)  //counting the number of correct words student got for familiar word subtask
	order ufw_correct2 , after(ufw_correct) 
	br ufw_string ufw_string2 ufw_correct ufw_correct2 ufw_permin if ufw_time_used >=120
	replace ufw_permin = (ufw_correct2 / ufw_time_used) *60  if ufw_time_used >=120  //replacing the per minute score for those students who used 2 minutes 

	*Amy, I am replacing to 0 the scores of students who took a full 2 minutes to finish the test but only attempted 10 questions at most 
	br ufw_string ufw_string2 ufw_correct ufw_correct2 ufw_permin  ufw_time_used  if minute2 <=10 
	replace ufw_permin = 0 if minute2 <=10   //these students should have been stopped early. They only attempted 10 questions, the early stop rule applies to these students
	

	*Passage Reading Score
	**********************
	br rp1-rpsto1 

	*Creating total_time used variable in seconds 
	tab rptim1 
	tab rptim2
	
	*Early stop rule
	tab rpsto1
	
	br rp* if rpsto1==1 //12 students were stopped early 
	br rp* if rpsto1==1 & (rp1==0 |rp2== 0 | rp3==0 | rp4==0 | rp5==0 | rp6==0 | rp7 ==0 | rp8 ==0 | rp9==0 |rp10==0)   //4 students were incorrectly stopped early 
	*Flag mistakes in early stop rule 
	cap drop I_stop_err_rp
	gen I_stop_err_rp = (rpsto1==1 & (rp1==0 |rp2== 0 | rp3==0 | rp4==0 | rp5==0 | rp6==0 | rp7 ==0 | rp8 ==0 | rp9==0 |rp10==0))
	lab var I_stop_err_rp "Incorrectly stopped early in Passage Reading Section" 
	order I_stop_err_rp , after(rpsto1) 
	tab  I_stop_err_rp rpsto1
	
	br rp* if rpsto1==1 &  I_stop_err_rp==0  // 18 students who were correctly stopped early
	br rp* if rpsto1==1 &  I_stop_err_rp==1  // 4 students who were incorrectly stopped early
	
	
	cap drop rptim_m
	tostring   rptim1 rptim2  , replace 
	gen rptim_m = substr(rptim1,1,1) if length(rptim1) ==2
	replace rptim_m = "0" if rptim_m ==""
	order rptim_m , after(rptim1) 
	cap drop rptim_m2
	gen rptim_m2 = substr(rptim1,2,1) if length(rptim1) ==2
	replace rptim_m2 = rptim1 if length(rptim1) ==1
	order rptim_m2 , after(rptim_m)
	br rptim1 rptim2 rptim_m2  rptim_m   
	
	destring  rptim_m    , replace

	*Recoding minutes to seconds
	replace rptim_m= rptim_m* 60 //replacing minutes to seconds 
	tab rptim_m
	tab rptim_m2
	*Combining fwtim2 and fwtim3 variable into one variable 
	cap drop rp_23
	egen rp_23 = concat(rptim_m2 rptim2) 
	order rp_23 , after(rptim2) 
	destring rp_23 , replace 

	cap drop rp_time_used
	gen rp_time_used = rptim_m+ rp_23
	order rp_time_used , after(rp_23) 

	*Creating a reading passage score 
	cap drop rp_string 
	egen rp_string = concat(rp1 rp2 rp3 rp4 rp5 rp6 rp7 rp8 rp9 rp10 rp11 rp12 rp13 rp14 rp15 rp16 rp17 rp18 rp19 rp20 rp21 rp22 rp23 rp24 rp25 rp26 rp27 rp28 rp29 rp30 rp31 rp32 rp33 rp34 rp35 rp36 rp37 rp38 rp39 rp40  ///
								rp41 )
	order  rp_string , after(rptim1) 

	cap drop rpt_string
	egen rpt_string = concat(trp1 trp2 trp3 trp4 trp5 trp6 trp7 trp8 trp9 trp10 trp11 trp12 trp13 trp14 trp15 trp16 trp17 trp18 trp19 trp20 trp21 trp22 trp23 trp24 trp25 trp26 trp27 trp28 trp29 trp30 trp31 trp32 trp33 trp34 ///
								trp35 trp36 trp37 trp38 trp39 trp40 trp41 )
	order  rpt_string , after(rp_string) 
	br rpt_string rp_string
	

	*Cleaning time string variable. There should only be 2 stops: one at minute 1 and another one at minute 2
	*********************************************************************************************************
	cap drop timeerror
	egen timeerror = noccur(rpt_string) , string(1) 
	tab timeerror
	br ufw* if timeerror==3  //observations with more than 2 stops 

	*Creating an indicator for error in timed variable
	/*
	*Note: The following rules should always be followed 
		1) Students who used less than 60secods should NOT have a "1" on their time string 
		2) Students who fineshed the test between 60 seconds and 120 seconds shoul have ONE "1" 
		3) Students who finished the test in 120 seconds should have 2 "1" 
	*/

	cap drop rp_timeerror 
	gen rp_timeerror = ((rp_time_used < 60 & timeerror !=0) | (rp_time_used >=60  & rp_time_used <120 & timeerror !=1) | ( rp_time_used >= 120 & timeerror !=2)   ) 
	tab rp_timeerror	
	br rp* if rp_timeerror==1 
	
	*Amy, can you decide how you want to clean these variables?
	***********************************************************
	
	/*We then need to change the time time string variable here to have at most 2 "1"
		
	
	
	*/
	

	cap drop rp_correct 
	egen rp_correct = noccur(rp_string) , string(0)  //counting the number of correct words student got for reading passage word subtask
	order rp_correct , after( rpt_string) 
	sort rp_correct

	*Estimating per minute score, 
	*Formula: (Total Correct / Time Used)*60
	cap drop rp_permin
	gen rp_permin = (rp_correct / rp_time_used) *60
	lab var rp_permin "Reading Passage"
	order rp_permin , after(rp_correct) 
	
	*Replace to zero the scores of students who were stopped early 
	replace rp_permin = 0 if rpsto1==1 & I_stop_err_rp==0 
	replace rp_correct = 0 if rpsto1==1 & I_stop_err_rp==0 
	
	br rp* if rpsto1==1 &  I_stop_err_rp==0  // 18 students who were correctly stopped early
	br rp* if rpsto1==1 &  I_stop_err_rp==1  // 4 students who were incorrectly stopped early 
	
	*Amy, I am fixing the issue with students who used the full 2 minutes to finish 
	*******************************************************************************
	br rp* if rp_time_used >=120
	*Recalculating the scores of students who were stopped (students who used all of the 120 seconds allocated for the test) 
	************************************************************************************************************************
	*First, from time string, let's find the possition at which the second minute was marked 
	/* Stata 14 only
	cap drop minute2 
	gen minute2 =  strrpos(rpt_string , "1") if rp_time_used >=120  //getting the item number of the last item attempted
	tab minute2
	*/
	
	*Stata 13 equivalent of the function strrpos 
	cap drop minute2 
	gen minute2 =  strlen(rpt_string)-strpos(strreverse(rpt_string),"1")+1  if rp_time_used >=120  //getting the item number of the last item attempted  
	replace minute2= 0 if strpos(rpt_string,"1") ==0 // students who do not have a check on their time string when 2 minutes elapsed 
		
		
	br rp* minute2 rp_time_used if rp_time_used >=120
	cap drop rp_string2
	gen rp_string2 = substr(rp_string, 1, minute2) if rp_time_used >=120
	order rp_string2 , after(rp_string) 
	*Counting the number of correct items for students who used 2 minutes
	********************************************************************
	cap drop rp_correct2
	egen rp_correct2 = noccur(rp_string2) , string(0)  //counting the number of correct words student got for familiar word subtask
	order rp_correct2 , after(rp_correct) 
	br rp_string rp_string2 minute2 rp_correct rp_correct2 rp_permin if rp_time_used >=120
	replace rp_permin = (rp_correct2 / rp_time_used) *60  if rp_time_used >=120  //replacing the per minute score for those students who used 2 minutes 

	*Amy, I am replacing to 0 the scores of students who took a full 2 minutes to finish the test but only attempted 10 questions at most 
	br rp_string rp_string2 minute2 rp_correct rp_correct2 rp_permin  if minute2 <=10 
	replace rp_permin = 0 if minute2 <=10   //these students should have been stopped early. They only attempted 10 questions, the early stop rule applies to these students
	
	
	*Letter Name 
	************
	br ln1-lnsto1

	tab lnsto1  //3 students were stopped early 
	*Creating indicator for students who were incorrectly stopped early 
	cap drop I_stop_err_ln 
	gen I_stop_err_ln = (lnsto1==1 & (ln1==0 | ln2==0| ln3==0| ln4==0| ln5==0| ln6==0| ln7==0| ln8==0| ln9==0| ln10==0) )
	lab var I_stop_err_ln "Incorrectly stopped early in Letter Name Section" 
	order I_stop_err_ln , after(lnsto1) 
	
	tab I_stop_err_ln lnsto1 , m
	
	
	br ln* if lnsto1==1 & I_stop_err_ln==0  //2 students were correctly stopped early 
	br ln* if lnsto1==1 & I_stop_err_ln==1  //1 students was icorrectly stopped early 
	

	tab lntim1 
	***Amy, I have made the changes below to address the above problem 
	******************************************************************
	sort lntim1
	br lntim1
	cap drop _lntim1
	gen _lntim1 = lntim1
	order _lntim1 , after(lntim1) 
	tostring _lntim1 , replace
	cap drop x
	gen x = strlen(_lntim1) 	
	cap drop y 
	gen y = substr(_lntim1,1,1) if strlen(_lntim1)==3
	destring y , replace
	replace y = y * 60 
	
	cap drop z
	gen z = substr(_lntim1,2,.) if strlen(_lntim1)==3
	destring z , replace
	cap drop ln_time_used
	gen ln_time_used = y+ z 
	replace ln_time_used = lntim1 if ln_time_used==. 
	order ln_time_used , after(lntim1) 
	
	drop x y z _lntim1
	tab ln_time_used
	*****************
	
	*Creating a letter name score 
	cap drop ln_string 
	egen ln_string = concat(ln1 ln2 ln3 ln4 ln5 ln6 ln7 ln8 ln9 ln10 ln11 ln12 ln13 ln14 ln15 ln16 ln17 ln18 ln19 ln20 ln21 ln22 ln23 ln24 ln25 ln26 ln27 ln28 ln29 ln30 ln31 ln32 ln33 ln34 ///
								ln35 ln36 ln37 ln38 ln39 ln40 ln41 ln42 ln43 ln44 ln45 ln46 ln47 ln48 ln49 ln50 ln51 ln52 ln53 ln54 ln55 ln56 ln57 ln58 ln59 ln60 ln61 ln62 ln63 ln64 ln65 ln66 ln67 ln68 ln69)
	order  ln_string , after(lntim1) 

	cap drop lnt_string 
	egen lnt_string = concat(tln1 tln2 tln3 tln4 tln5 tln6 tln7 tln8 tln9 tln10 tln11 tln12 tln13 tln14 tln15 tln16 tln17 tln18 tln19 tln20 tln21 tln22 tln23 tln24 tln25 tln26 tln27 tln28 tln29 tln30 tln31 tln32 tln33 tln34 ///
								tln35 tln36 tln37 tln38 tln39 tln40 tln41 tln42 tln43 tln44 tln45 tln46 tln47 tln48 tln49 tln50 tln51 tln52 tln53 tln54 tln55 tln56 tln57 tln58 tln59 tln60 tln61 tln62 tln63 tln64 tln65 tln66 tln67 tln68 tln69)
	order  lnt_string , after(ln_string) 
	
	br ln_string lnt_string
	
	*Cleaning time string variable. There should only be 2 stops: one at minute 1 and another one at minute 2
	*********************************************************************************************************
	cap drop timeerror
	egen timeerror = noccur(lnt_string) , string(1) 
	tab timeerror
	br ln* if timeerror==3  //observations with more than 2 stops 
		
	*Creating an indicator for error in timed variable
	/*
	*Note: The following rules should always be followed 
		1) Students who used less than 60secods should NOT have a "1" on their time string 
		2) Students who fineshed the test between 60 seconds and 120 seconds shoul have ONE "1" 
		3) Students who finished the test in 120 seconds should have 2 "1" 
	*/

	cap drop ln_timeerror 
	gen ln_timeerror = ((ln_time_used < 60 & timeerror !=0) | (ln_time_used >=60  &  ln_time_used <120 & timeerror !=1) | ( ln_time_used >= 120 & timeerror !=2)   ) 
	tab ln_timeerror	
	br ln* if ln_timeerror==1 
	*Amy, can you decide how you want to clean these variables?
	***********************************************************
	
	/*We then need to change the time time string variable here to have at most 2 "1"
		
	
	
	*/
		
	
	cap drop ln_correct 
	egen ln_correct = noccur(ln_string) , string(0)  //counting the number of correct words student got for familiar word subtask
	order ln_correct , after( ln_string) 
	sort ln_correct
	
	*Estimating per minute score, 
	*Formula: (Total Correct / Time Used)*60
	cap drop ln_permin
	gen ln_permin = (ln_correct / ln_time_used) *60  //Amy, using the corrected time used variable 
	lab var ln_permin "Letter Name"
	order ln_permin , after(ln_correct) 
	*Replacing to zero leter name score for students who were stopped early 
	replace ln_permin = 0 if lnsto1==1 & I_stop_err_ln==0  
	replace ln_correct = 0 if lnsto1==1 & I_stop_err_ln==0  
	
	br ln* ln_permin if lnsto1==1 & I_stop_err_ln==0  //2 students who where correctly stopped early 
	br ln* ln_permin if lnsto1==1 & I_stop_err_ln==1  //1 students who where correctly stopped early 
	
		
	*Amy, I am fixing the issue with students who used the full 2 minutes to finish 
	*******************************************************************************
	br ln* if ln_time_used >=120
	*Recalculating the scores of students who were stopped (students who used all of the 120 seconds allocated for the test) 
	************************************************************************************************************************
	*First, from time string, let's find the possition at which the second minute was marked 
	/* Stata 14 only
	cap drop minute2 
	gen minute2 =  strrpos(lnt_string , "1") if ln_time_used >=120   //getting the item number of the last item attempted  
	tab minute2
	*/
	
	*Stata 13 equivalent of the function strrpos 
	cap drop minute2 
	gen minute2 =  strlen(lnt_string)-strpos(strreverse(lnt_string),"1")+1  if ln_time_used >=120  //getting the item number of the last item attempted  
	replace minute2= 0 if strpos(lnt_string,"1") ==0 // students who do not have a check on their time string when 2 minutes elapsed 
	
	
	br ln* minute2 ln_time_used if ln_time_used >=120
	cap drop ln_string2
	gen ln_string2 = substr(ln_string, 1, minute2) if ln_time_used >=120
	order ln_string2 , after(ln_string) 
	*Counting the number of correct items for students who used 2 minutes
	********************************************************************
	cap drop ln_correct2
	egen ln_correct2 = noccur(ln_string2) , string(0)  //counting the number of correct words student got for familiar word subtask
	order ln_correct2 , after(ln_correct) 
	br ln_string ln_string2 minute2 ln_correct ln_correct2 ln_permin if ln_time_used >=120
	replace ln_permin = (ln_correct2 / ln_time_used) *60  if ln_time_used >=120  //replacing the per minute score for those students who used 2 minutes 

	*Amy, I am replacing to 0 the scores of students who took a full 2 minutes to finish the test but only attempted 10 questions at most 
	br ln_string ln_string2 minute2 ln_correct ln_correct2 ln_permin   if minute2 <=10 
	replace ln_permin = 0 if minute2 <=10   //these students should have been stopped early. They only attempted 10 questions, the early stop rule applies to these students
	
	*Creating an overal time error variable
	***************************************
	cap drop Overall_Any_Error
	gen Overall_Any_Error = (fw_timeerror==1 | ufw_timeerror==1 | rp_timeerror==1 | ln_timeerror ==1 )
	tab Overall_Any_Error
	sort fw_timeerror ufw_timeerror rp_timeerror ln_timeerror
	br fw_timeerror ufw_timeerror rp_timeerror ln_timeerror if  Overall_Any_Error==1

	
	
*2) Percentage Score Variables
****************************** 
	*Oral Vocab 
	***********
	br ov1-ov10
	des ov1-ov10
	tab ov1
	lab define _ov 1 "Correct" 0 "Incorrect"
	foreach var of varlist  ov1-ov10 { 
	di "***`var'*****"
	replace `var' = upper(`var')
	tab `var' 
	replace `var' = "1" if `var' == "CORRECT" 
	replace `var' = "" if `var' ==" "
	replace `var' = "0"  if `var' == "INCORRECT"
	replace `var' = "0"  if `var' == "NO ANSWER"
	replace `var' = "0"  if `var' == "NON ANSWER"
	replace `var' = "0"  if `var' == ""
	destring `var' , replace 
	lab val `var' _ov
	tab `var' ,m 
	}
	*
	*Oroal vocal percentage correct 
	cap drop total_ov_correct
	egen total_ov_correct = rsum(ov1-ov10) , missing
	la var total_ov_correct "OV Score (0-10)"
	order total_ov_correct , after(ov10)
	sort total_ov_correct

	cap drop ov_score
	gen ov_score = (total_ov_correct/10)*100
	order ov_score , after(total_ov_correct) 
	la var ov_score "Oral Vocabulary"	

	
	*Reading Comprehension 
	**********************
	des rpc1-rpc4
	br rpc1-rpc4
	tab rpc1
	tab rpc1 , nola

	lab define _rpc 1 "Correct" 0 "Incorrect" , replace
	foreach var of varlist rpc1-rpc4 {
	di "***`var'*****"
	replace `var' = upper(`var')
	tab `var' 
	replace `var' = "1" if `var' == "CORRECT" 
	replace `var' = "" if `var' ==" "
	replace `var' = "0"  if `var' == "INCORRECT"
	replace `var' = "0"  if `var' == "INCORREC"
	replace `var' = "0"  if `var' == "NO ANSWER"
	replace `var' = "0"  if `var' == "NON ANSWER"
	replace `var' = "0"  if `var' == ""
	
	destring `var' , replace 
	lab val `var' _rpc
	tab `var' ,m 
}
	*

	*Reading comprehension socre 
	cap drop total_rpc_correct
	egen total_rpc_correct = rsum(rpc1-rpc4) , missing
	la var total_rpc_correct "RPC Score (0-4)"
	order total_rpc_correct , after(rpc4)
	sort total_rpc_correct

	cap drop rpc_score
	gen rpc_score = (total_rpc_correct/4)*100
	order rpc_score , after(total_rpc_correct) 
	la var rpc_score "Reading Comprehension"	

	*Listening Comprehension 
	************************
	des lc1-lc4
	br lc1-lc4
	tab lc1 
	tab lc1 , nol
	lab def _lc 1 "Correct" 0 "Incorrect" , replace

	foreach var of varlist lc1-lc4 {
	di "***`var'*****"
	replace `var' = upper(`var')
	tab `var' 
	replace `var' = "1" if `var' == "CORRECT" 
	replace `var' = "" if `var' ==" "
	replace `var' = "0"  if `var' == "INCORRECT"
	replace `var' = "0"  if `var' == "INCORREC"
	replace `var' = "0"  if `var' == "NO ANSWER"
	replace `var' = "0"  if `var' == "NON ANSWER"
	replace `var' = "0"  if `var' == ""
	
	destring `var' , replace 
	lab val `var' _lc 
	tab `var' , m 
	}
	*


	*Listening comprehension socre 
	cap drop total_lc_correct
	egen total_lc_correct = rsum(lc1-lc4) , missing
	la var total_lc_correct "LC Score (0-4)"
	order total_lc_correct , after(lc4)
	sort total_lc_correct

	cap drop lc_score
	gen lc_score = (total_lc_correct/4)*100
	order lc_score , after(total_lc_correct) 
	la var lc_score "Listening Comprehension"	

	*Dictation
	**********
	des dct1-dct8
	br dct1-dct8
	tab dct1
	tab dct1 , nol

		
	*Dictation socre 
	cap drop total_dct_correct
	egen total_dct_correct = rsum(dct1-dct8) , missing
	la var total_dct_correct "DCT Score (0-16)"
	order total_dct_correct , after(dct8)
	sort total_dct_correct

	cap drop dct_score
	gen dct_score = (total_dct_correct/16)*100
	order dct_score , after(total_dct_correct) 
	la var dct_score "Dictation"	

	*Initial Letter Sound 
	*********************
	des ils1-ils10
	tab ils1
	tab ils1 , nol
	lab define _ils 1 "Correct" 0 "Incorrect" , replace 
	foreach var of varlist ils1-ils10 { 
	di "***`var'*****"
	replace `var' = upper(`var')
	tab `var' 
	replace `var' = "1" if `var' == "CORRECT" 
	replace `var' = "" if `var' ==" "
	replace `var' = "0"  if `var' == "INCORRECT"
	replace `var' = "0"  if `var' == "INCORREC"
	replace `var' = "0"  if `var' == "NO ANSWER"
	replace `var' = "0"  if `var' == "NON ANSWER"
	replace `var' = "0"  if `var' == ""
	
	destring `var' , replace 
	lab val `var' _ils 
	tab `var' 

	}
	* 
	
	*Initial Letter Sound socre 
	cap drop total_ils_correct
	egen total_ils_correct = rsum(ils1-ils10), missing
	la var total_ils_correct "ILS Score (0-10)"
	order total_ils_correct , after(ils10)
	sort total_ils_correct

	cap drop ils_score
	gen ils_score = (total_ils_correct/10)*100
	order ils_score , after(total_ils_correct) 
	la var ils_score "Inital Letter Sound"	

	

*Flag observations that are 3 Standard Deviation Away 
foreach var of varlist  ln_permin fw_permin ufw_permin rp_permin ov_score rpc_score lc_score dct_score ils_score {
	cap drop `var'_sd
	cap drop `var'_flag
	di "***`var'****"
	egen `var'_sd = std(`var') 
	order `var'_sd , after(`var') 
	gen `var'_flag =(`var'_sd>= 3)
	order `var'_flag , after(`var'_sd)
	tab `var'_flag
	sum `var', d 
 }
 
 cap drop sd_flags
 gen sd_flags= ln_permin_flag+ fw_permin_flag+ ufw_permin_flag+ rp_permin_flag+ ov_score_flag+ rpc_score_flag+  dct_score_flag+ lc_score_flag+ ils_score_flag
 tab sd_flags  //20 observations are outliers 
 
/****notes on outliers before we drop them, AT
LN has 4 outliers, all on high side and not unbelievlably higher than 99th percent, but still dropping to keep consistent use of rule >3sd away will be replaced with missing
FW has 1 outlier, also just a bit higher
UFW has 11 outliers. because there are many and data appears to have long tail, we'll keep them.
RP has 8 outliers. because there are many and data appears to have long tail, we'll keep them.
ov has none
rc has none
lc has none
dict has none
ils has none

*/

*Removing Outliers 
******************
des ln_permin fw_permin ufw_permin rp_permin ov_score rpc_score lc_score dct_score ils_score

foreach var of varlist  ln_permin fw_permin {
    tab `var'_flag
	sum `var', d 
	replace `var' =. if `var'_sd>= 3 
}
*

 
 

 
 *******************************
 destring rptim1 , replace

 *Dropping variables we don't need 
 drop rptim_m2 rp_23  rptim_m fw_23 fwtim_m fwtim_m2 
 drop ln_string ln_string2 lnt_string fw_string fw_string2 fwt_string ufw_string ufw_string2 ufwt_string rp_string rp_string2 rpt_string
 drop ln_correct ln_correct2 I_stop_err_ln total_ils_correct fw_correct fw_correct2 ufw_correct ufw_correct2 I_stop_err_ufw total_ov_correct rp_correct rp_correct2 I_stop_err_rp total_dct_correct I_stop_err_fw
drop ln_permin_sd ils_score_sd fw_permin_sd ufw_permin_sd ov_score_sd rp_permin_sd rpc_score_sd lc_score_sd dct_score_sd sd_flags
drop ln_permin_flag ils_score_flag fw_permin_flag ufw_permin_flag ov_score_flag rp_permin_flag rpc_score_flag lc_score_flag dct_score_flag
drop total_rpc_correct total_lc_correct
drop minute2
