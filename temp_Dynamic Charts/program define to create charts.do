** Project:                                        Acumen Data Analysis Exercise
** Author:                                                           Shiyao Wang
** Date and Time:                                               03/07/2023 20:15
********************************************************************************
********************************************************************************

clear
set more off
cd "C:\Users\m1321\Downloads"

**************************
** Preparation
	capture ssc install missings
	import excel using "Acumen_Data_Analysis_Exercise.xlsx", sheet("Data") firstrow clear
	
	** Global Color Settings
	global c1 =  "31 73 125"
	global c1s =  "197 217 241"
	global c2 =  "245 130 49"
	global c3 =  "0 128 128"
	
	**************************
	** Box Chart Program Define
	cap program drop _all	
	program define boxchart
	// Main Chart Area
	graph box H_Score,   ///	
		box(1, fcolor("$c1s") fintensity(100) lcolor("$c1") lwidth(2pt) lalign(center))   ///
		over(`1', sort(/* order */ 1) label(labcolor("127 127 127")) gap(50))   ///
	/// Basic Settings
		nooutsides   ///
		outergap(70)   /// 
		alsize(40)   /// 
		ysize(5) xsize(5)   ///
		plotregion(color(white) margin(0 0 0 5))   ///
		graphregion(color(white) margin(l r+5 b t))   ///
	/// Chart Title
		title({bf: Health Score and `1'}, size(6) position(11) margin(-7 0 0 0) color("$c3"))   ///
		subtitle(" ", size(5) position(11))   ///
	/// Chart Legends and Notes
		note("Data Source：Acumen Exercise", color("127 127 127") size(2.5) position(5) margin(l r-5 b t+5))   ///
		legend(off)  /// 
		showyvars yvaroptions(label(labsize(0) labcolor("127 127 127")) axis(lwidth(none)))   ///
	/// Axis Title
		ytitle("")   ///
	/// Axis Scales
		yscale(lcolor("217 217 217"))   ///
	/// Axis Labels, Gridlines and Ticks
		ylabel(0(1)6, labsize(3.5) labcolor("127 127 127") labgap(5pt) angle(0) nogrid noticks)
		graph export "Health Score and `1'.png", replace
	end
	
	**************************
	** Scatter Chart Program Define
	program define scatterchart
	// Main Chart Area
	twoway   ///
	/// Scatter Plot	
	(scatter `1' `2', msize(1.75) mfcolor("$c1")  mlwidth(none))   ///
	/// Confidence Line
	(qfitci `1' `2', level(95) lcolor("$c2") lwidth(0.75)   ///
		ciplot(rline)   ///
		alpattern(longdash)   ///
		fcolor("255 255 255")   ///
		alcolor("$c3")),   ///
	/// Basic Settings
		ysize(5) xsize(5)   ///
		plotregion(color(white) margin(0 0 0 5))   ///
		graphregion(color(white) margin(l r+5 b t))   ///
	/// Chart Title
		title({bf:Health Score and `2'}, size(6) position(11) margin(-10 0 -5 0) color("$c3"))   ///
		subtitle(" ", size(4) position(11))   ///
	/// Chart Legends and Notes
		note("Data Source：Acumen Exercise", color("127 127 127") size(2.5) position(5) margin(l r-5 b t))   ///
		legend(label(1 "Obs") label(2 "CI") label(3 "Linear") size(2.5) rows(1) region(fcolor(none) lpattern(blank)) position(12) margin(l r b t))  /// 
	/// Axis Title
		xtitle("`2'", size(2.5) margin(0 0 0 1) color("89 89 89"))   ///
		ytitle("`1'", size(2.5) margin(0 1 0 0) color("89 89 89"))   ///
	/// Axis Scales
		xscale(lcolor("255 255 255"))   ///
		yscale(lcolor("217 217 217") lwidth(0.75pt) lpattern(shortdash))   ///
	/// Axis Labels, Gridlines and Ticks
		xlabel(, labsize(3.5) labcolor("127 127 127") angle(90) labgap(5pt) grid glwidth(0.75pt) glcolor("217 217 217") glpattern(dash))   ///
		xlabel(, noticks)   ///
		ylabel(, labsize(3.5) labcolor("127 127 127") labgap(5pt) angle(0) glwidth(0.75pt) glcolor("217 217 217") glpattern(shortdash) noticks)
		graph export "Health Score and `2'.png", replace
	end


**************************
** Question 1 

	ren (SexMale1 HospitalVisitThisQuarter1Y HealthScore) (Sex Visit H_Score)
	codebook, compact
	missings report
	
	foreach v of varlist * {
		drop if missing(`v')
	}
	replace Age = . if Age >= 110  // replace the abnormal values (Age and HealthScore) with missing 
	replace H_Score = . if H_Score == 10 
	
	table Quarter, stat(fvpercent Sex Race) stat(mean Age) stat(median Age) /* stat(max Age) stat(min Age) */ nformat(%5.1f) listwise  // table method, cannot export to Excel
	
	preserve
	quiet {
	tab Sex, gen(Sex_)
	rename Sex_1 Female
	rename Sex_2 Male
	tab Race, gen(Race_)
	foreach v of varlist Female - Race_3 {
		replace `v' = . if `v' == 0
	}
	collapse (count) Female - Race_3 Sex Race (mean) Age_Mean = Age (median) Age_Median = Age, by(Quarter)
	cap program drop fvp
	program define fvp
		replace `1' = `1'/`2'*100
	end
	fvp Female Sex
	fvp Male Sex
	fvp Race_1 Race
	fvp Race_2 Race
	fvp Race_3 Race
	drop Sex Race
	format * %5.1f
	format Quarter %5.1g
	}
	export excel using "Acumen_Data_Analysis_Exercise.xlsx", sheet("Q1(b)") cell("H20") firstrow(variables) sheetmodify keepcellfmt
	list
	restore
	
	exit
	
	
	
**************************
** Question 2

/*
	boxchart Sex
	boxchart Race
	boxchart Visit
	scatterchart H_Score Salary
	scatterchart H_Score Age
*/

	regress H_Score Salary Visit Age i.Race Sex i.Quarter, robust


