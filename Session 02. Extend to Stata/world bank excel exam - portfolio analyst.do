clear
set more off
cd "D:\workshops\Session 02. Extend to Stata"

import excel using "data.xlsx", sheet("Data Set") firstrow

***************************************
** 1. Indicate the date today (or the latest day) with a formula

	dis in red "$S_DATE"
	dis in red c(current_date)


***************************************
** 2. Suppose a CIF team member is looking for the number of MDB Approved projects and the number of cancelled projects as of today (the data-set is the latest). On column I on the dataset tab, you will find the status of the projects. Find the following: count of MDB Approved projects, count of cancelled projects, percentage of each with regard to the total number of projects (in total there are 66).

	drop if Program == ""
	quiet count if Status == "MDB Board Approval"
	display round(100*r(N)/66,0.1)

	quiet count
	global total = r(N)
	quiet count if Status == "MDB Board Approval"
	display round(100*r(N)/${total},0.1)

	* Feel free to try to calculate the cancelled projects below:


***************************************
** 3. A Minister from Germany is inquiring about the number of public sector projects in Bangladesh. Using a formula, calculate how many Bangladesh-based public sector projects there are.

	count if Country == "Bangladesh" & PublicPrivate == "Public Sector"


***************************************
** 4. (a) To enter information in the CIF Collaboration Hub (part of the Financial Intermediary Funds platform), an IT colleague is requesting the project numbers of several projects. Using a formula, extract the last four digits (ex. 005D) of each project ID below to get the numbers. (b) In addition to his first request, he requires you to extract the PPG amount (column J) of these projects to double check for any cancellations in the past three months. Using a formula, automate an extraction of this data from the dataset tab. (c) Using the country code tab and a formula, extract the country name of where these projects are based in. Note that the country code is already provided below.

	global codes = "PPCRBO601A XPCRHT069A XPCRKH011A XPCRNP029A XPCRTJ037A"
	foreach c of global codes {
	display in red substr("`c'", strlen("`c'")-3, 5)
	preserve
	quiet keep if ProjectID == "`c'"
	local ppg = PPGAmount[1]
	restore
	global message = "The PPG amount for project " + "`c'" + " is: " + "`ppg'"
	display in red "$message"
	}

	* Feel free to try to lookup the country full name according to the codes


***************************************
** 5. (a) To enter information in the CIF Collaboration Hub (part of the Financial Intermediary Funds platform), an IT colleague is requesting the project numbers of several projects. Using a formula, extract the last four digits (ex. 005D) of each project ID below to get the numbers. (b) Suppose she wants to find out not only how much MPIS has been distributed to these projects in Latin America, but also how much was distributed to IADB (column G - Lead MDB). Compute for the MPIS with these two conditions.

	summarize TotalMPIS if Region == "Latin America and Caribbean", d
	display r(sum)
	
	summarize TotalMPIS if Region == "Latin America and Caribbean" & LeadMDB == "IADB", d
	display r(sum)


***************************************
** 6. Create a pie graph that analyzes the total grant and non-grant funding (column M) amounts distributed to all PPCR projects by thematic focus (column I). Which thematic focus holds the most funding, and the least?
	
	preserve
	collapse (sum) TotalFundingGrantandNonGran, by(Sector)
	graph pie TotalFundingGrantandNonGran, over(Sector)
// 	exit
	
	graph pie TotalFundingGrantandNonGran, ///
		ysize(5) xsize(5) ///
		plotregion(color(white) margin(0 0 0 4)) ///
		graphregion(color(white) margin(l r b t)) ///
		title({bf:Total Funding Grant and Non-Grant Amount}, size(4.5) position(12) color("53 53 53"))   /// 
		note("Source: World Bank", size(3) margin(r=2) position(5)  color("53 53 53"))   /// 
		legend(color("89 89 89") symysize(3) symxsize(3) keygap(1pt) size(2.5) margin(t=0) row(4) bmargin(t=4) region(fcolor(none) lcolor(none))) ///
		over(Sector) ///
		pie(1, explode) ///
		plabel(_all percent, format(%5.0f) color(white) size(5))
	restore

	
***************************************
** 7. (a) Sort the projects by the following order: Programming, Country, Private/Public Sector. (b) Suppose hypothetically that the CIF wishes to rename the Cancelled status of projects to "Dropped". In the same tab, rename/replace all the "Cancelled" projects status to "Dropped"

	gsort Programming Country -PublicPrivate
	replace Status = "Dropped" if Status == "Cancelled"

	
***************************************
** 8. Create a pivot table in a new worksheet and present the data in the following manner: Regions --> then countries as rows; PPG, Total MPIS and Total Grant and Nont Grant funding as amounts
	
// 	preserve
	collapse (sum) PPGAmount TotalMPIS NonGrantAmount, by(Region Country)
	order Region Country

	
***************************************
** 9. String concatenation

	global newid = "X" + "PCR" + "WK" + string(901) + "B"
	display "$newid"
		