//DO FILE, POP_TAG META-ANALYSIS//

//PAPER: Perimetric Outcomes of Melbourne Rapid Field Perimetry in Patients with Glaucoma: A Systematic Review and Meta-Analysis//

//DATE: Started OCT 16TH, 2025//

//Last Code Update: 26, NOV, 2025//

//Thesis Project 1, Harvard Medical School Masters of Medical Science in Clinical Investigation, 2024-2026//

//AUTHOR: ANDRES INZUNZA,MD//

//Last Dataset Update: 26, NOV, 2025 //

//[GitHub LINK](https://github.com/andresinzunza/pop_tag/tree/main) //


//ANALYSIS 1//
//TESTING DURATION (TIME, IN MINUTES AND FRACTIONAL MINUTES), HFA VS MRF//


//Sub-analysis 1: MRF time//

clear

import excel "/Users/andresinzunza/Documents/Medicina/HARVARD MMSCI/Thesis/Project 1/Pop_Tag_Meta_analysis/data_extraction_sheet/pop_tag.xlsx", sheet("combined") firstrow case(lower)

keep if !missing(duration_min_mrf) & !missing(dis_duration_min_mrf) & !missing(n_eyes)

gen se_duration_mrf = dis_duration_min_mrf / sqrt(n_eyes)

sort year

meta set duration_min_mrf se_duration_mrf, studylabel(study_id)

meta summarize, random

meta forestplot

quietly summarize n_eyes if !missing(_meta_es)
local Neyes = r(sum)


display as text " Number of eyes included in this meta-analysis: " as result `Neyes'


display as text "Included studies and sample sizes (n_eyes):"
list study_id n_eyes if !missing(_meta_es), noobs clean separator(0)


//Sub-analysis 2: HFA time//

clear

import excel "/Users/andresinzunza/Documents/Medicina/HARVARD MMSCI/Thesis/Project 1/Pop_Tag_Meta_analysis/data_extraction_sheet/pop_tag.xlsx", sheet("combined") firstrow case(lower)

keep if !missing(duration_min_hfa) & !missing(dis_duration_min_hfa) & !missing(n_eyes)

gen se_duration_hfa = dis_duration_min_hfa / sqrt(n_eyes)

sort year

meta set duration_min_hfa se_duration_hfa, studylabel(study_id)

meta summarize, random

quietly summarize n_eyes if !missing(_meta_es)
local Neyes = r(sum)


display as text " Number of eyes included in this meta-analysis: " as result `Neyes'


display as text "Included studies and sample sizes (n_eyes):"
list study_id n_eyes if !missing(_meta_es), noobs clean separator(0)


//Sub-analysis 3: Mean Differences in Time//


gen diff_time = duration_min_mrf - duration_min_hfa

gen se_diff_time = sqrt((dis_duration_min_mrf^2)/n_eyes + (dis_duration_min_hfa^2)/n_eyes) 

sort year


meta set diff_time se_diff_time, studylabel(study_id)

meta summarize, random

quietly summarize n_eyes
scalar total_eyes = r(sum)

meta forestplot, random(reml) coltitleopts(color(black)) itemopts(color(black)) overallopts(color(black)) bodyopts(color(black)) ciopts(color(black)) omarkeropts(mcolor(black)) markeropts(mcolor(black)) gmarkeropts(mcolor(black)) insidemarker(mcolor(black)) title("Difference in time", size(huge)) subtitle("MRF vs HFA") nullrefline(favorsleft("Favors MRF <---") favorsright("---> Favors HFA"))esrefline(lcolor(red) lpattern(dash)) note("Number of Eyes = ")

quietly summarize n_eyes if !missing(_meta_es)
local Neyes = r(sum)


display as text " Number of eyes included in this meta-analysis: " as result `Neyes'


display as text "Included studies and sample sizes (n_eyes):"
list study_id n_eyes if !missing(_meta_es), noobs clean separator(0)



///meta-regression for differences in time//
//Melbourne Location, Author Analysis and Author List//

meta regress developer_analysis, random

meta regressplot



//ANALYSIS 2//
//PAIRED MEAN DIFFERENCE FOR MEAN DEVIATION, MRF VS HFA// ASSUMPTION: 0.8 Correlation//
//Sensitivity analysis comparing different correlations can be found at the end of the page//
//A very high correlation was assumed given that it was the same patient, doing the same kind of test and usually in the same day//
//Senstivity analysis comparing unpaired mean differences instead of paired differences can be found in next analysis//

//Sub-analysis 1: MD for the HFA group//

clear

import excel "/Users/andresinzunza/Documents/Medicina/HARVARD MMSCI/Thesis/Project 1/Pop_Tag_Meta_analysis/data_extraction_sheet/pop_tag.xlsx", sheet("combined") firstrow case(lower)

keep if !missing(mean_md_hfa) & !missing(disp_mean_md_hfa) & !missing(n_eyes)

gen se_md_hfa = disp_mean_md_hfa / sqrt(n_eyes)

sort year

meta set mean_md_hfa se_md_hfa, studylabel(study_id)

meta summarize, random


quietly summarize n_eyes if !missing(_meta_es)
local Neyes = r(sum)


display as text " Number of eyes included in this meta-analysis: " as result `Neyes'


display as text "Included studies and sample sizes (n_eyes):"
list study_id n_eyes if !missing(_meta_es), noobs clean separator(0)

//Sub-analysis 2: MD for MRF group//

clear

import excel "/Users/andresinzunza/Documents/Medicina/HARVARD MMSCI/Thesis/Project 1/Pop_Tag_Meta_analysis/data_extraction_sheet/pop_tag.xlsx", sheet("combined") firstrow case(lower)

keep if !missing(mean_md_mrf) & !missing(disp_mean_md_mrf) & !missing(n_eyes)

gen se_md_mrf = disp_mean_md_mrf / sqrt(n_eyes)

sort year

meta set mean_md_mrf se_md_mrf, studylabel(study_id)

meta summarize, random


quietly summarize n_eyes if !missing(_meta_es)
local Neyes = r(sum)


display as text " Number of eyes included in this meta-analysis: " as result `Neyes'


display as text "Included studies and sample sizes (n_eyes):"
list study_id n_eyes if !missing(_meta_es), noobs clean separator(0)


//Sub-analysis 3: MD for Mean Difference in MD (MRF vs HFA)//ASSUMPTION: 0.8 Correlation//

clear
import excel "/Users/andresinzunza/Documents/Medicina/HARVARD MMSCI/Thesis/Project 1/Pop_Tag_Meta_analysis/data_extraction_sheet/pop_tag.xlsx", sheet("combined") firstrow case(lower)

summarize

drop if study_id == "Kang, 2023"

local rho = 0.8

gen diff_md = mean_md_mrf - mean_md_hfa
gen se_diff_md = sqrt((disp_mean_md_mrf^2 + disp_mean_md_hfa^2 - 2 * `rho' * disp_mean_md_mrf * disp_mean_md_hfa) / n_eyes)

sort year

meta set diff_md se_diff_md, studylabel(study_id)
meta summarize, random

metan diff_md se_diff_md, random label(namevar=study_id) effect("Difference in dB") null(0) title("Mean Difference in MD") xlab(-3.0(1)6.0, grid) subtitle("MRF-HFA") note("Mean Difference, Paired Observations, Assumed Correlation: 0.8")


quietly summarize n_eyes if !missing(_meta_es)
local Neyes = r(sum)


display as text " Number of eyes included in this meta-analysis: " as result `Neyes'


display as text "Included studies and sample sizes (n_eyes):"
list study_id n_eyes if !missing(_meta_es), noobs clean separator(0)



///Meta-Regression //
meta set diff_md se_diff_md, studylabel(study_id)
meta regress developer_analysis, random

//ANALYSIS 3//
//LEAVE ONE-OUT-META-ANALYSIS FOR MEAN DIFFRENCE OF MD, HFA VS MRF//

clear

import excel "/Users/andresinzunza/Documents/Medicina/HARVARD MMSCI/Thesis/Project 1/Pop_Tag_Meta_analysis/data_extraction_sheet/pop_tag.xlsx", sheet("combined") firstrow case(lower)

summarize

local rho = 0.8

gen diff_md = mean_md_mrf - mean_md_hfa

gen se_diff_md = sqrt((disp_mean_md_mrf^2 + disp_mean_md_hfa^2 - 2 * `rho' * disp_mean_md_mrf * disp_mean_md_hfa) / n_eyes)

sort year

meta set diff_md se_diff_md, studylabel(study_id)

meta forestplot, leaveoneout 

quietly summarize n_eyes if !missing(_meta_es)
local Neyes = r(sum)


display as text " Number of eyes included in this meta-analysis: " as result `Neyes'


display as text "Included studies and sample sizes (n_eyes):"
list study_id n_eyes if !missing(_meta_es), noobs clean separator(0)

//ANALYSIS 4//
//UNPAIRED Mean Difference in MD; sensitive analysis not for paper// 
//No assumption for correlation//

clear

import excel "/Users/andresinzunza/Documents/Medicina/HARVARD MMSCI/Thesis/Project 1/Pop_Tag_Meta_analysis/data_extraction_sheet/pop_tag.xlsx", sheet("combined") firstrow case(lower)

summarize

gen diff_md = mean_md_mrf - mean_md_hfa

gen se_diff_md = sqrt((disp_mean_md_mrf^2/n_eyes) + (disp_mean_md_hfa^2/n_eyes))

sort year

meta summarize, random

metan diff_md se_diff_md, random label(namevar=study_id) effect("Difference in dB") null(0) title("Difference in MD") xlab(-3.0(1)6.0, grid)note("Number of Eyes = ")


quietly summarize n_eyes if !missing(_meta_es)
local Neyes = r(sum)


display as text " Number of eyes included in this meta-analysis: " as result `Neyes'


display as text "Included studies and sample sizes (n_eyes):"
list study_id n_eyes if !missing(_meta_es), noobs clean separator(0)

//ANALYSIS 5//
//PSD/PD means differences, UNPAIRED///
//USING the META command//


//Sub-analysis 1: PSD for the HFA group//

clear

import excel "/Users/andresinzunza/Documents/Medicina/HARVARD MMSCI/Thesis/Project 1/Pop_Tag_Meta_analysis/data_extraction_sheet/pop_tag.xlsx", sheet("combined") firstrow case(lower)

keep if !missing(mean_psd_hfa) & !missing(disp_mean_psd_hfa) & !missing(n_eyes)

gen se_psd_hfa = disp_mean_psd_hfa / sqrt(n_eyes)

sort year

meta set mean_psd_hfa se_psd_hfa, studylabel(study_id)

meta summarize, random

quietly summarize n_eyes if !missing(_meta_es)
local Neyes = r(sum)


display as text " Number of eyes included in this meta-analysis: " as result `Neyes'


display as text "Included studies and sample sizes (n_eyes):"
list study_id n_eyes if !missing(_meta_es), noobs clean separator(0)


//Sub-analysis 2: PSD for the MRF group//

clear

import excel "/Users/andresinzunza/Documents/Medicina/HARVARD MMSCI/Thesis/Project 1/Pop_Tag_Meta_analysis/data_extraction_sheet/pop_tag.xlsx", sheet("combined") firstrow case(lower)

keep if !missing(mean_psd_mrf) & !missing(disp_mean_psd_mrf) & !missing(n_eyes)

gen se_psd_mrf = disp_mean_psd_mrf / sqrt(n_eyes)

sort year

meta set mean_psd_mrf se_psd_mrf, studylabel(study_id)

meta summarize, random

quietly summarize n_eyes if !missing(_meta_es)
local Neyes = r(sum)


display as text " Number of eyes included in this meta-analysis: " as result `Neyes'


display as text "Included studies and sample sizes (n_eyes):"
list study_id n_eyes if !missing(_meta_es), noobs clean separator(0)

///Sub-Analysis 3, Mean Difference for PSD (Paired) (Correlation of 0.80)//
clear

import excel "/Users/andresinzunza/Documents/Medicina/HARVARD MMSCI/Thesis/Project 1/Pop_Tag_Meta_analysis/data_extraction_sheet/pop_tag.xlsx", sheet("combined") firstrow case(lower)

summarize

gen diff = mean_psd_mrf - mean_psd_hfa

gen se_diff = sqrt( (disp_mean_psd_mrf^2 + disp_mean_psd_hfa^2 - 2*0.8*disp_mean_psd_mrf*disp_mean_psd_hfa) / n_eyes )

sort year

meta set diff se_diff, studylabel(study_id)

meta summarize, random

meta forestplot, random(reml) coltitleopts(color(black)) itemopts(color(black)) overallopts(color(black)) bodyopts(color(black)) ciopts(color(black)) omarkeropts(mcolor(black)) markeropts(mcolor(black)) gmarkeropts(mcolor(black)) insidemarker(mcolor(black)) title("Difference in PSD", size(huge)) esrefline(lcolor(red) lpattern(dot) lwidth(medium)) nullrefline xlab(-1(1)4, grid) note("Number of Eyes = ")

quietly summarize n_eyes if !missing(_meta_es)
local Neyes = r(sum)


display as text " Number of eyes included in this meta-analysis: " as result `Neyes'


display as text "Included studies and sample sizes (n_eyes):"
list study_id n_eyes if !missing(_meta_es), noobs clean separator(0)

///meta-regression PSD//

meta set diff se_diff, studylabel(study_id)
meta regress developer_analysis, random



//Sub-Analysis 4, MEAN DIfference for PSD//Sensitivy analysis for unpaired//

clear

import excel "/Users/andresinzunza/Documents/Medicina/HARVARD MMSCI/Thesis/Project 1/Pop_Tag_Meta_analysis/data_extraction_sheet/pop_tag.xlsx", sheet("combined") firstrow case(lower)

summarize

gen diff = mean_psd_mrf - mean_psd_hfa

gen se_diff = sqrt((disp_mean_psd_mrf ^2 / n_eyes) + (disp_mean_psd_hfa ^2 / n_eyes))

sort year

meta set diff se_diff, studylabel(study_id)

meta summarize, random

meta forestplot, random(reml) coltitleopts(color(black)) itemopts(color(black)) overallopts(color(black)) bodyopts(color(black)) ciopts(color(black)) omarkeropts(mcolor(black)) markeropts(mcolor(black)) gmarkeropts(mcolor(black)) insidemarker(mcolor(black)) title("Difference in PSD", size(huge)) esrefline(lcolor(red) lpattern(dot) lwidth(medium)) nullrefline xlab(-1(1)4, grid) note("Number of Eyes = ")

quietly summarize n_eyes if !missing(_meta_es)
local Neyes = r(sum)


display as text " Number of eyes included in this meta-analysis: " as result `Neyes'


display as text "Included studies and sample sizes (n_eyes):"
list study_id n_eyes if !missing(_meta_es), noobs clean separator(0)


//Analysis 6//
//Sensitivity Analysis using the PAIRED//
//PSD/PD mean differences, PAIRED// 
//ASSUMPTION OF CORRELATION OF 0.8, RATIONALE EXPLAINED BEFORE//
//Using the Metan Command//

clear

import excel "/Users/andresinzunza/Documents/Medicina/HARVARD MMSCI/Thesis/Project 1/Pop_Tag_Meta_analysis/data_extraction_sheet/pop_tag.xlsx", sheet("combined") firstrow case(lower)

gen diff = mean_psd_mrf - mean_psd_hfa

gen se_diff = sqrt((disp_mean_psd_mrf^2 + disp_mean_psd_hfa^2 - 2*0.8*disp_mean_psd_mrf*disp_mean_psd_hfa) / n_eyes)

sort year

metan diff se_diff, random label(namevar=study_id) lcols(study_id year n_eyes) xlabel(-1(1)4, grid) title("Difference in PSD (Paired, r = 0.8)") note("Number of eyes: ")

quietly summarize n_eyes if !missing(_meta_es)
local Neyes = r(sum)


display as text " Number of eyes included in this meta-analysis: " as result `Neyes'


display as text "Included studies and sample sizes (n_eyes):"
list study_id n_eyes if !missing(_meta_es), noobs clean separator(0)


//ANALYSIS 7//
//R squared, MD, HFA and MRF//
//Fischer Transformation for R squared//

clear

import excel "/Users/andresinzunza/Documents/Medicina/HARVARD MMSCI/Thesis/Project 1/Pop_Tag_Meta_analysis/data_extraction_sheet/pop_tag.xlsx", sheet("combined") firstrow case(lower)

drop if missing(r_squ_corr_cof_md) | missing(r_squ_ll) | missing(r_squ_ul)

gen z_md = 0.5 * ln((1 + r_squ_corr_cof_md) / (1 - r_squ_corr_cof_md))
gen z_ll = 0.5 * ln((1 + r_squ_ll) / (1 - r_squ_ll))
gen z_ul = 0.5 * ln((1 + r_squ_ul) / (1 - r_squ_ul))
gen se_z = (z_ul - z_ll) / (2 * 1.96)

meta set z_md se_z, studylabel(study_id)

meta summarize, random

meta forestplot, random(reml)coltitleopts(color(black)) itemopts(color(black)) overallopts(color(black)) bodyopts(color(black)) ciopts(color(black)) omarkeropts(mcolor(black))markeropts(mcolor(black)) gmarkeropts(mcolor(black)) insidemarker(mcolor(black))title("Fisher Transformed Correlation Coefficient", size(huge))

local pooled_z = r(theta)
local lower_z  = r(ci_lb)
local upper_z  = r(ci_ub)

local pooled_r = (exp(2*`pooled_z') - 1) / (exp(2*`pooled_z') + 1)
local lower_r  = (exp(2*`lower_z')  - 1) / (exp(2*`lower_z') + 1)
local upper_r  = (exp(2*`upper_z')  - 1) / (exp(2*`upper_z') + 1)

display as text "Pooled r:   " %6.3f `pooled_r' " [" %6.3f `lower_r' ", " %6.3f `upper_r' "]"

gen r_md = (exp(2*z_md) - 1) / (exp(2*z_md) + 1)
gen r_ll = (exp(2*z_ll) - 1) / (exp(2*z_ll) + 1)
gen r_ul = (exp(2*z_ul) - 1) / (exp(2*z_ul) + 1)

sort year

metan r_md r_ll r_ul, random label(namevar=study_id) effect("R Squared") null(0) xlab(0(.1)1.0, grid) title("R Squared") subtitle("Correlation Coefficient, Mean Defect, MRF vs HFA") note("Number of Eyes = ")

quietly summarize n_eyes if !missing(_meta_es)
local Neyes = r(sum)


display as text " Number of eyes included in this meta-analysis: " as result `Neyes'


display as text "Included studies and sample sizes (n_eyes):"
list study_id n_eyes if !missing(_meta_es), noobs clean separator(0)


//ANALYSIS 8//
//CONCORDANCE// MD Obtained by MRF VS HFA ICC coefficient MD; CONCORDANCE//

clear

import excel "/Users/andresinzunza/Documents/Medicina/HARVARD MMSCI/Thesis/Project 1/Pop_Tag_Meta_analysis/data_extraction_sheet/pop_tag.xlsx", sheet("combined") firstrow case(lower)

drop if missing(concordance_icc_mean_defect) | missing(ll_ci_concordance_icc_mean_defec) | missing(ul_ci_concordance_icc_mean_defec) 

gen z_icc    = 0.5 * ln((1 + concordance_icc_mean_defect) / (1 - concordance_icc_mean_defect))
gen z_ll     = 0.5 * ln((1 + ll_ci_concordance_icc_mean_defec) / (1 - ll_ci_concordance_icc_mean_defec))
gen z_ul     = 0.5 * ln((1 + ul_ci_concordance_icc_mean_defec) / (1 - ul_ci_concordance_icc_mean_defec))

gen se_z_icc = (z_ul - z_ll) / (2 * 1.96)

meta set z_icc se_z_icc, studylabel(study_id)

meta summarize, random

local pooled_z = r(theta)
local lower_z  = r(ci_lb)
local upper_z  = r(ci_ub)

local pooled_icc = (exp(2*`pooled_z') - 1) / (exp(2*`pooled_z') + 1)
local lower_icc  = (exp(2*`lower_z')  - 1) / (exp(2*`lower_z') + 1)
local upper_icc  = (exp(2*`upper_z')  - 1) / (exp(2*`upper_z') + 1)

display as text "Pooled ICC:   " %6.3f `pooled_icc' " [" %6.3f `lower_icc' ", " %6.3f `upper_icc' "]"

gen icc_md = (exp(2*z_icc) - 1) / (exp(2*z_icc) + 1)
gen icc_ll = (exp(2*z_ll)  - 1) / (exp(2*z_ll) + 1)
gen icc_ul = (exp(2*z_ul)  - 1) / (exp(2*z_ul) + 1)

sort year

metan icc_md icc_ll icc_ul, random label(namevar=study_id) effect("ICC") null(0) title ("MRF and HFA Concordance") subtitle(" Mean Deviation") xlab(0(.1)1.0, grid) subtitle("MRF and HFA")note("Number of Eyes = ")

quietly summarize n_eyes if !missing(_meta_es)
local Neyes = r(sum)


display as text " Number of eyes included in this meta-analysis: " as result `Neyes'


display as text "Included studies and sample sizes (n_eyes):"
list study_id n_eyes if !missing(_meta_es), noobs clean separator(0)


///meta-regression//

meta set z_icc se_z_icc, studylabel(study_id)
meta regress developer_analysis, random


//ANALYSIS 9//
//TEST-RETEST (MRF; MEAN DEVIATION)(MD MRF AND repeated MD MRF)/// Time-points INCLUDE IMMEDIATE, 4-6 MONTHS AND 6 MONTHS///

clear

import excel "/Users/andresinzunza/Documents/Medicina/HARVARD MMSCI/Thesis/Project 1/Pop_Tag_Meta_analysis/data_extraction_sheet/pop_tag.xlsx", sheet("combined") firstrow case(lower)

drop if missing(test_retest_com_icc_md_mrf) | missing(ll_test_retest_com_icc_md_mrf) | missing(ul_test_retest_com_icc_md_mrf)

gen z_icc = 0.5 * ln((1 + test_retest_com_icc_md_mrf) / (1 - test_retest_com_icc_md_mrf))
gen z_ll = 0.5 * ln((1 + ll_test_retest_com_icc_md_mrf) / (1 - ll_test_retest_com_icc_md_mrf))
gen z_ul = 0.5 * ln((1 + ul_test_retest_com_icc_md_mrf) / (1 - ul_test_retest_com_icc_md_mrf))

gen se_z_icc = (z_ul - z_ll) / (2 * 1.96)

meta set z_icc se_z_icc, studylabel(study_id)
meta summarize, random

local pooled_z = r(theta)
local lower_z = r(ci_lb)
local upper_z = r(ci_ub)

local pooled_icc = (exp(2*`pooled_z') - 1) / (exp(2*`pooled_z') + 1)
local lower_icc = (exp(2*`lower_z') - 1) / (exp(2*`lower_z') + 1)
local upper_icc = (exp(2*`upper_z') - 1) / (exp(2*`upper_z') + 1)

display "Pooled ICC: " %6.3f `pooled_icc' " [" %6.3f `lower_icc' ", " %6.3f `upper_icc' "]"

gen icc_md = (exp(2*z_icc) - 1) / (exp(2*z_icc) + 1)
gen icc_ll = (exp(2*z_ll) - 1) / (exp(2*z_ll) + 1)
gen icc_ul = (exp(2*z_ul) - 1) / (exp(2*z_ul) + 1)

sort year

metan icc_md icc_ll icc_ul, random label(namevar=study_id) effect("ICC") null(0) title("MD Test–Retest Comparability MRF") subtitle("Intraclass Correlation Coefficient ") xlab(0(.1)1.0, grid)

quietly summarize n_eyes if !missing(_meta_es)
local Neyes = r(sum)


display as text " Number of eyes included in this meta-analysis: " as result `Neyes'


display as text "Included studies and sample sizes (n_eyes):"
list study_id n_eyes if !missing(_meta_es), noobs clean separator(0)


//meta-regression ICC test_retest//

meta set z_icc se_z_icc, studylabel(study_id)
meta regress developer_analysis, random



//ANALYSIS 10//
//Just for comparison purposes, this can also be derived from the literature, but it is a useful comparison//
///HFA; TEST RETEST; mean deviation///

clear
import excel "/Users/andresinzunza/Documents/Medicina/HARVARD MMSCI/Thesis/Project 1/Pop_Tag_Meta_analysis/data_extraction_sheet/pop_tag.xlsx", sheet("combined") firstrow case(lower)

drop if missing(test_retest_com_icc_md_hfa) | missing(ll_test_retest_com_icc_md_hfa) | missing(ul_test_retest_com_icc_md_hfa)

gen z_icc = 0.5 * ln((1 + test_retest_com_icc_md_hfa) / (1 - test_retest_com_icc_md_hfa))
gen z_ll  = 0.5 * ln((1 + ll_test_retest_com_icc_md_hfa) / (1 - ll_test_retest_com_icc_md_hfa))
gen z_ul  = 0.5 * ln((1 + ul_test_retest_com_icc_md_hfa) / (1 - ul_test_retest_com_icc_md_hfa))

gen se_z_icc = (z_ul - z_ll) / (2 * 1.96)

meta set z_icc se_z_icc, studylabel(study_id)
meta summarize, random

local pooled_z = r(theta)
local lower_z = r(ci_lb)
local upper_z = r(ci_ub)

local pooled_icc = (exp(2*`pooled_z') - 1) / (exp(2*`pooled_z') + 1)
local lower_icc = (exp(2*`lower_z') - 1) / (exp(2*`lower_z') + 1)
local upper_icc = (exp(2*`upper_z') - 1) / (exp(2*`upper_z') + 1)

display "Pooled ICC: " %6.3f `pooled_icc' " [" %6.3f `lower_icc' ", " %6.3f `upper_icc' "]"

gen icc_md = (exp(2*z_icc) - 1) / (exp(2*z_icc) + 1)
gen icc_ll = (exp(2*z_ll) - 1) / (exp(2*z_ll) + 1)
gen icc_ul = (exp(2*z_ul) - 1) / (exp(2*z_ul) + 1)

sort year

metan icc_md icc_ll icc_ul, random label(namevar=study_id) effect("ICC") null(0) title("MD Test–Retest Comparability HFA") subtitle("Intraclass Correlation Coefficient") xlab(0(.1)1.0, grid)

quietly summarize n_eyes if !missing(_meta_es)
local Neyes = r(sum)


display as text " Number of eyes included in this meta-analysis: " as result `Neyes'


display as text "Included studies and sample sizes (n_eyes):"
list study_id n_eyes if !missing(_meta_es), noobs clean separator(0)


//Analysis 11//
//Zonal CONCORDANCE//
//MD Obtained by MRF VS HFA ICC coefficient MD; BY REGION//

//ZONE 1 (SUPERIOR-CENTRAL)//

clear

import excel "/Users/andresinzunza/Documents/Medicina/HARVARD MMSCI/Thesis/Project 1/Pop_Tag_Meta_analysis/data_extraction_sheet/pop_tag.xlsx", sheet("combined") firstrow case(lower)

drop if missing(icc_zone_1_hfa_mrf) | missing(ll_icc_zone_1_hfa_mrf) | missing(ul_icc_zone_1_hfa_mrf)

gen z_icc = 0.5 * ln((1 + icc_zone_1_hfa_mrf) / (1 - icc_zone_1_hfa_mrf))
gen z_ll  = 0.5 * ln((1 + ll_icc_zone_1_hfa_mrf) / (1 - ll_icc_zone_1_hfa_mrf))
gen z_ul  = 0.5 * ln((1 + ul_icc_zone_1_hfa_mrf) / (1 - ul_icc_zone_1_hfa_mrf))

gen se_z_icc = (z_ul - z_ll) / (2 * 1.96)

meta set z_icc se_z_icc, studylabel(study_id)
meta summarize, random

local pooled_z = r(theta)
local lower_z  = r(ci_lb)
local upper_z  = r(ci_ub)

local pooled_icc = (exp(2*`pooled_z') - 1) / (exp(2*`pooled_z') + 1)
local lower_icc  = (exp(2*`lower_z')  - 1) / (exp(2*`lower_z') + 1)
local upper_icc  = (exp(2*`upper_z')  - 1) / (exp(2*`upper_z') + 1)

display as text "Pooled ICC (Zone 1): " %6.3f `pooled_icc' " [" %6.3f `lower_icc' ", " %6.3f `upper_icc' "]"

gen icc_md = (exp(2*z_icc) - 1) / (exp(2*z_icc) + 1)
gen icc_ll = (exp(2*z_ll)  - 1) / (exp(2*z_ll) + 1)
gen icc_ul = (exp(2*z_ul)  - 1) / (exp(2*z_ul) + 1)

sort year

metan icc_md icc_ll icc_ul, random label(namevar=study_id) effect("ICC") null(0) title("ICC, Zone 1") xlab(0(.1)1.0, grid) note("Zone 1 ICC MRF-HFA")

quietly summarize n_eyes if !missing(_meta_es)
local Neyes = r(sum)


display as text " Number of eyes included in this meta-analysis: " as result `Neyes'


display as text "Included studies and sample sizes (n_eyes):"
list study_id n_eyes if !missing(_meta_es), noobs clean separator(0)


//Analysis 12//
//Zonal CONCORDANCE//
//MD Obtained by MRF VS HFA ICC coefficient MD; BY REGION//

//ZONE 2 (inferior–central)//

clear

import excel "/Users/andresinzunza/Documents/Medicina/HARVARD MMSCI/Thesis/Project 1/Pop_Tag_Meta_analysis/data_extraction_sheet/pop_tag.xlsx", sheet("combined") firstrow case(lower)

drop if missing(icc_zone_2_hfa_mrf) | missing(ll_icc_zone_2_hfa_mrf) | missing(ul_icc_zone_2_hfa_mrf)

gen z_icc = 0.5 * ln((1 + icc_zone_2_hfa_mrf) / (1 - icc_zone_2_hfa_mrf))
gen z_ll  = 0.5 * ln((1 + ll_icc_zone_2_hfa_mrf) / (1 - ll_icc_zone_2_hfa_mrf))
gen z_ul  = 0.5 * ln((1 + ul_icc_zone_2_hfa_mrf) / (1 - ul_icc_zone_2_hfa_mrf))

gen se_z_icc = (z_ul - z_ll) / (2 * 1.96)

meta set z_icc se_z_icc, studylabel(study_id)
meta summarize, random

local pooled_z = r(theta)
local lower_z  = r(ci_lb)
local upper_z  = r(ci_ub)

local pooled_icc = (exp(2*`pooled_z') - 1) / (exp(2*`pooled_z') + 1)
local lower_icc  = (exp(2*`lower_z')  - 1) / (exp(2*`lower_z') + 1)
local upper_icc  = (exp(2*`upper_z')  - 1) / (exp(2*`upper_z') + 1)

display as text "Pooled ICC (Zone 2): " %6.3f `pooled_icc' " [" %6.3f `lower_icc' ", " %6.3f `upper_icc' "]"

gen icc_md = (exp(2*z_icc) - 1) / (exp(2*z_icc) + 1)
gen icc_ll = (exp(2*z_ll)  - 1) / (exp(2*z_ll) + 1)
gen icc_ul = (exp(2*z_ul)  - 1) / (exp(2*z_ul) + 1)

sort year

metan icc_md icc_ll icc_ul, random label(namevar=study_id) effect("ICC") null(0) title("ICC, Zone 2") xlab(0(.1)1.0, grid) note("Zone 2 ICC MRF-HFA")


//Analysis 13//
//Zonal CONCORDANCE//
//MD Obtained by MRF VS HFA ICC coefficient MD; BY REGION//

//ZONE 3 (superior–peripheral–nasal)//

clear

import excel "/Users/andresinzunza/Documents/Medicina/HARVARD MMSCI/Thesis/Project 1/Pop_Tag_Meta_analysis/data_extraction_sheet/pop_tag.xlsx", sheet("combined") firstrow case(lower)

drop if missing(icc_zone_3_hfa_mrf) | missing(ll_icc_zone_3_hfa_mrf) | missing(ul_icc_zone_3_hfa_mrf)

gen z_icc = 0.5 * ln((1 + icc_zone_3_hfa_mrf) / (1 - icc_zone_3_hfa_mrf))
gen z_ll  = 0.5 * ln((1 + ll_icc_zone_3_hfa_mrf) / (1 - ll_icc_zone_3_hfa_mrf))
gen z_ul  = 0.5 * ln((1 + ul_icc_zone_3_hfa_mrf) / (1 - ul_icc_zone_3_hfa_mrf))

gen se_z_icc = (z_ul - z_ll) / (2 * 1.96)

meta set z_icc se_z_icc, studylabel(study_id)
meta summarize, random

local pooled_z = r(theta)
local lower_z  = r(ci_lb)
local upper_z  = r(ci_ub)

local pooled_icc = (exp(2*`pooled_z') - 1) / (exp(2*`pooled_z') + 1)
local lower_icc  = (exp(2*`lower_z')  - 1) / (exp(2*`lower_z') + 1)
local upper_icc  = (exp(2*`upper_z')  - 1) / (exp(2*`upper_z') + 1)

display as text "Pooled ICC (Zone 3): " %6.3f `pooled_icc' " [" %6.3f `lower_icc' ", " %6.3f `upper_icc' "]"

gen icc_md = (exp(2*z_icc) - 1) / (exp(2*z_icc) + 1)
gen icc_ll = (exp(2*z_ll)  - 1) / (exp(2*z_ll) + 1)
gen icc_ul = (exp(2*z_ul)  - 1) / (exp(2*z_ul) + 1)

sort year

metan icc_md icc_ll icc_ul, random label(namevar=study_id) effect("ICC") null(0) title("ICC, Zone 3") xlab(0(.1)1.0, grid) note("Zone 3 ICC MRF-HFA")


//Analysis 14//
//Zonal CONCORDANCE//
//MD Obtained by MRF VS HFA ICC coefficient MD; BY REGION//

//ZONE 4 (superior–nasal)//


clear

import excel "/Users/andresinzunza/Documents/Medicina/HARVARD MMSCI/Thesis/Project 1/Pop_Tag_Meta_analysis/data_extraction_sheet/pop_tag.xlsx", sheet("combined") firstrow case(lower)

drop if missing(icc_zone_4_hfa_mrf) | missing(ll_icc_zone_4_hfa_mrf) | missing(ul_icc_zone_4_hfa_mrf)

gen z_icc = 0.5 * ln((1 + icc_zone_4_hfa_mrf) / (1 - icc_zone_4_hfa_mrf))
gen z_ll  = 0.5 * ln((1 + ll_icc_zone_4_hfa_mrf) / (1 - ll_icc_zone_4_hfa_mrf))
gen z_ul  = 0.5 * ln((1 + ul_icc_zone_4_hfa_mrf) / (1 - ul_icc_zone_4_hfa_mrf))

gen se_z_icc = (z_ul - z_ll) / (2 * 1.96)

meta set z_icc se_z_icc, studylabel(study_id)
meta summarize, random

local pooled_z = r(theta)
local lower_z  = r(ci_lb)
local upper_z  = r(ci_ub)

local pooled_icc = (exp(2*`pooled_z') - 1) / (exp(2*`pooled_z') + 1)
local lower_icc  = (exp(2*`lower_z')  - 1) / (exp(2*`lower_z') + 1)
local upper_icc  = (exp(2*`upper_z')  - 1) / (exp(2*`upper_z') + 1)

display as text "Pooled ICC (Zone 4): " %6.3f `pooled_icc' " [" %6.3f `lower_icc' ", " %6.3f `upper_icc' "]"

gen icc_md = (exp(2*z_icc) - 1) / (exp(2*z_icc) + 1)
gen icc_ll = (exp(2*z_ll)  - 1) / (exp(2*z_ll) + 1)
gen icc_ul = (exp(2*z_ul)  - 1) / (exp(2*z_ul) + 1)

sort year

metan icc_md icc_ll icc_ul, random label(namevar=study_id) effect("ICC") null(0) title("ICC, Zone 4") xlab(0(.1)1.0, grid) note("Zone 4 ICC MRF-HFA")

//Analysis 15//
//Zonal CONCORDANCE//
//MD Obtained by MRF VS HFA ICC coefficient MD; BY REGION//

//ZONE 5 (superior–temporal)//

clear

import excel "/Users/andresinzunza/Documents/Medicina/HARVARD MMSCI/Thesis/Project 1/Pop_Tag_Meta_analysis/data_extraction_sheet/pop_tag.xlsx", sheet("combined") firstrow case(lower)

drop if missing(icc_zone_5_hfa_mrf) | missing(ll_icc_zone_5_hfa_mrf) | missing(ul_icc_zone_5_hfa_mrf)

gen z_icc = 0.5 * ln((1 + icc_zone_5_hfa_mrf) / (1 - icc_zone_5_hfa_mrf))
gen z_ll  = 0.5 * ln((1 + ll_icc_zone_5_hfa_mrf) / (1 - ll_icc_zone_5_hfa_mrf))
gen z_ul  = 0.5 * ln((1 + ul_icc_zone_5_hfa_mrf) / (1 - ul_icc_zone_5_hfa_mrf))

gen se_z_icc = (z_ul - z_ll) / (2 * 1.96)

meta set z_icc se_z_icc, studylabel(study_id)
meta summarize, random

local pooled_z = r(theta)
local lower_z  = r(ci_lb)
local upper_z  = r(ci_ub)

local pooled_icc = (exp(2*`pooled_z') - 1) / (exp(2*`pooled_z') + 1)
local lower_icc  = (exp(2*`lower_z')  - 1) / (exp(2*`lower_z') + 1)
local upper_icc  = (exp(2*`upper_z')  - 1) / (exp(2*`upper_z') + 1)

display as text "Pooled ICC (Zone 5): " %6.3f `pooled_icc' " [" %6.3f `lower_icc' ", " %6.3f `upper_icc' "]"

gen icc_md = (exp(2*z_icc) - 1) / (exp(2*z_icc) + 1)
gen icc_ll = (exp(2*z_ll)  - 1) / (exp(2*z_ll) + 1)
gen icc_ul = (exp(2*z_ul)  - 1) / (exp(2*z_ul) + 1)

sort year

metan icc_md icc_ll icc_ul, random label(namevar=study_id) effect("ICC") null(0) title("ICC, Zone 5") xlab(0(.1)1.0, grid) note("Zone 5 ICC MRF-HFA")


//Analysis 16//
//Zonal CONCORDANCE//
//MD Obtained by MRF VS HFA ICC coefficient MD; BY REGION//

//ZONE 6 (inferior–temporal)//

clear

import excel "/Users/andresinzunza/Documents/Medicina/HARVARD MMSCI/Thesis/Project 1/Pop_Tag_Meta_analysis/data_extraction_sheet/pop_tag.xlsx", sheet("combined") firstrow case(lower)

drop if missing(icc_zone_6_hfa_mrf) | missing(ll_icc_zone_6_hfa_mrf) | missing(ul_icc_zone_6_hfa_mrf)

gen z_icc = 0.5 * ln((1 + icc_zone_6_hfa_mrf) / (1 - icc_zone_6_hfa_mrf))
gen z_ll  = 0.5 * ln((1 + ll_icc_zone_6_hfa_mrf) / (1 - ll_icc_zone_6_hfa_mrf))
gen z_ul  = 0.5 * ln((1 + ul_icc_zone_6_hfa_mrf) / (1 - ul_icc_zone_6_hfa_mrf))

gen se_z_icc = (z_ul - z_ll) / (2 * 1.96)

meta set z_icc se_z_icc, studylabel(study_id)
meta summarize, random

local pooled_z = r(theta)
local lower_z  = r(ci_lb)
local upper_z  = r(ci_ub)

local pooled_icc = (exp(2*`pooled_z') - 1) / (exp(2*`pooled_z') + 1)
local lower_icc  = (exp(2*`lower_z')  - 1) / (exp(2*`lower_z') + 1)
local upper_icc  = (exp(2*`upper_z')  - 1) / (exp(2*`upper_z') + 1)

display as text "Pooled ICC (Zone 6): " %6.3f `pooled_icc' " [" %6.3f `lower_icc' ", " %6.3f `upper_icc' "]"

gen icc_md = (exp(2*z_icc) - 1) / (exp(2*z_icc) + 1)
gen icc_ll = (exp(2*z_ll)  - 1) / (exp(2*z_ll) + 1)
gen icc_ul = (exp(2*z_ul)  - 1) / (exp(2*z_ul) + 1)

sort year

metan icc_md icc_ll icc_ul, random label(namevar=study_id) effect("ICC") null(0) title("ICC, Zone 6") xlab(0(.1)1.0, grid) note("Zone 6 ICC MRF-HFA")


//Analysis 17//
//Zonal CONCORDANCE//
//MD Obtained by MRF VS HFA ICC coefficient MD; BY REGION//

//ZONE 7 (inferior–nasal)//
clear

import excel "/Users/andresinzunza/Documents/Medicina/HARVARD MMSCI/Thesis/Project 1/Pop_Tag_Meta_analysis/data_extraction_sheet/pop_tag.xlsx", sheet("combined") firstrow case(lower)

drop if missing(icc_zone_7_hfa_mrf) | missing(ll_icc_zone_7_hfa_mrf) | missing(ul_icc_zone_7_hfa_mrf)

gen z_icc = 0.5 * ln((1 + icc_zone_7_hfa_mrf) / (1 - icc_zone_7_hfa_mrf))
gen z_ll  = 0.5 * ln((1 + ll_icc_zone_7_hfa_mrf) / (1 - ll_icc_zone_7_hfa_mrf))
gen z_ul  = 0.5 * ln((1 + ul_icc_zone_7_hfa_mrf) / (1 - ul_icc_zone_7_hfa_mrf))

gen se_z_icc = (z_ul - z_ll) / (2 * 1.96)

meta set z_icc se_z_icc, studylabel(study_id)
meta summarize, random

local pooled_z = r(theta)
local lower_z  = r(ci_lb)
local upper_z  = r(ci_ub)

local pooled_icc = (exp(2*`pooled_z') - 1) / (exp(2*`pooled_z') + 1)
local lower_icc  = (exp(2*`lower_z')  - 1) / (exp(2*`lower_z') + 1)
local upper_icc  = (exp(2*`upper_z')  - 1) / (exp(2*`upper_z') + 1)

display as text "Pooled ICC (Zone 7): " %6.3f `pooled_icc' " [" %6.3f `lower_icc' ", " %6.3f `upper_icc' "]"

gen icc_md = (exp(2*z_icc) - 1) / (exp(2*z_icc) + 1)
gen icc_ll = (exp(2*z_ll)  - 1) / (exp(2*z_ll) + 1)
gen icc_ul = (exp(2*z_ul)  - 1) / (exp(2*z_ul) + 1)

sort year

metan icc_md icc_ll icc_ul, random label(namevar=study_id) effect("ICC") null(0) title("ICC, Zone 7") xlab(0(.1)1.0, grid) note("Zone 7 ICC MRF-HFA")


//Analysis 18//
//Zonal CONCORDANCE//
//MD Obtained by MRF VS HFA ICC coefficient MD; BY REGION//

//ZONE 8 (inferior–peripheral–nasal)//

clear

import excel "/Users/andresinzunza/Documents/Medicina/HARVARD MMSCI/Thesis/Project 1/Pop_Tag_Meta_analysis/data_extraction_sheet/pop_tag.xlsx", sheet("combined") firstrow case(lower)

drop if missing(icc_zone_8_hfa_mrf) | missing(ll_icc_zone_8_hfa_mrf) | missing(ul_icc_zone_8_hfa_mrf)

gen z_icc = 0.5 * ln((1 + icc_zone_8_hfa_mrf) / (1 - icc_zone_8_hfa_mrf))
gen z_ll  = 0.5 * ln((1 + ll_icc_zone_8_hfa_mrf) / (1 - ll_icc_zone_8_hfa_mrf))
gen z_ul  = 0.5 * ln((1 + ul_icc_zone_8_hfa_mrf) / (1 - ul_icc_zone_8_hfa_mrf))

gen se_z_icc = (z_ul - z_ll) / (2 * 1.96)

meta set z_icc se_z_icc, studylabel(study_id)
meta summarize, random

local pooled_z = r(theta)
local lower_z  = r(ci_lb)
local upper_z  = r(ci_ub)

local pooled_icc = (exp(2*`pooled_z') - 1) / (exp(2*`pooled_z') + 1)
local lower_icc  = (exp(2*`lower_z')  - 1) / (exp(2*`lower_z') + 1)
local upper_icc  = (exp(2*`upper_z')  - 1) / (exp(2*`upper_z') + 1)

display as text "Pooled ICC (Zone 8): " %6.3f `pooled_icc' " [" %6.3f `lower_icc' ", " %6.3f `upper_icc' "]"

gen icc_md = (exp(2*z_icc) - 1) / (exp(2*z_icc) + 1)
gen icc_ll = (exp(2*z_ll)  - 1) / (exp(2*z_ll) + 1)
gen icc_ul = (exp(2*z_ul)  - 1) / (exp(2*z_ul) + 1)

sort year

metan icc_md icc_ll icc_ul, random label(namevar=study_id) effect("ICC") null(0) title("ICC, Zone 8") xlab(0(.1)1.0, grid) note("Zone 8 ICC MRF-HFA")


//Anlysis 19//
//TOTAL Zonal CONCORDANCE Analysis// 
//One big forest plot to compare them, treating each zone as a subgroup//

clear

import excel "/Users/andresinzunza/Documents/Medicina/HARVARD MMSCI/Thesis/Project 1/Pop_Tag_Meta_analysis/data_extraction_sheet/pop_tag.xlsx", sheet("combined") firstrow case(lower)

keep study_id year icc_zone_*_hfa_mrf ll_icc_zone_*_hfa_mrf ul_icc_zone_*_hfa_mrf

foreach z of numlist 1/8 {
    rename icc_zone_`z'_hfa_mrf icc_zone_`z'
    rename ll_icc_zone_`z'_hfa_mrf ll_icc_zone_`z'
    rename ul_icc_zone_`z'_hfa_mrf ul_icc_zone_`z'
}

reshape long icc_zone_ ll_icc_zone_ ul_icc_zone_, i(study_id) j(zone)

rename icc_zone_ icc
rename ll_icc_zone_ ll
rename ul_icc_zone_ ul

drop if missing(icc) | missing(ll) | missing(ul)

gen se_icc = (ul - ll) / (2*1.96)

metan icc se_icc, random by(zone) nosubgroup effect("ICC") lcols(study_id year) null(0) xlab(0.10(0.1)1, grid) title("Zonal ICC: MRF vs HFA")



//TABLE FORM//

clear

import excel "/Users/andresinzunza/Documents/Medicina/HARVARD MMSCI/Thesis/Project 1/Pop_Tag_Meta_analysis/data_extraction_sheet/pop_tag.xlsx", sheet("combined") firstrow case(lower)

keep study_id year icc_zone_*_hfa_mrf ll_icc_zone_*_hfa_mrf ul_icc_zone_*_hfa_mrf

foreach z of numlist 1/8 {
    rename icc_zone_`z'_hfa_mrf icc_`z'
    rename ll_icc_zone_`z'_hfa_mrf ll_`z'
    rename ul_icc_zone_`z'_hfa_mrf ul_`z'
}

reshape long icc_ ll_ ul_, i(study_id) j(zone)

rename icc_ icc
rename ll_ ll
rename ul_ ul

drop if missing(icc) | missing(ll) | missing(ul)

tempfile results
capture postutil clear
postfile table str20 zone_name pooled_icc lower_ci upper_ci using `results'

levelsof zone, local(zlist)

foreach z of local zlist {

    preserve
    keep if zone == `z'

    gen z_icc = 0.5 * ln((1 + icc) / (1 - icc))
    gen z_ll  = 0.5 * ln((1 + ll)  / (1 - ll))
    gen z_ul  = 0.5 * ln((1 + ul)  / (1 - ul))

    gen se_z_icc = (z_ul - z_ll) / (2 * 1.96)

    meta set z_icc se_z_icc, studylabel(study_id)
    meta summarize, random

    local pooled_z = r(theta)
    local lower_z  = r(ci_lb)
    local upper_z  = r(ci_ub)

    local ICC  = (exp(2*`pooled_z') - 1) / (exp(2*`pooled_z') + 1)
    local LCI  = (exp(2*`lower_z')  - 1) / (exp(2*`lower_z') + 1)
    local UCI  = (exp(2*`upper_z')  - 1) / (exp(2*`upper_z') + 1)

    post table ("Zone `z'") (`ICC') (`LCI') (`UCI')

    restore
}

postclose table

use `results', clear
list, noobs sep(8)


//Analysis 20//
///Bland Altman analysis for MD (HFA-MRF) (HFA MINUS MRF)//

clear

import excel "/Users/andresinzunza/Documents/Medicina/HARVARD MMSCI/Thesis/Project 1/Pop_Tag_Meta_analysis/data_extraction_sheet/pop_tag.xlsx", sheet("combined") firstrow case(lower)

gen SD_md = (ul_95_loa_db_md - ll_95_loa_db_md) / (2*1.96)

gen SE_bias_md = SD_md / sqrt(n_eyes)

meta set bias_db_md SE_bias_md, studylabel(study_id) eslabel("Bias (MD, dB)")
meta summarize, random

scalar pooled_bias_md = r(theta)
display "Pooled Bias (dB): " pooled_bias_md


gen logSD_md = log(SD_md)
gen SE_logSD_md = 1/sqrt(2*(n_eyes - 1))


meta set logSD_md SE_logSD_md, studylabel(study_id) eslabel("log SD (MD)")
meta summarize, random

scalar pooled_SD_md = exp(r(theta))
display "Pooled SD (MD): " pooled_SD_md

scalar pooled_LLA_md = pooled_bias_md - 1.96 * pooled_SD_md
scalar pooled_ULA_md = pooled_bias_md + 1.96 * pooled_SD_md

display "------------------------------------------"
display "Pooled Bland–Altman Limits of Agreement:"
display "Lower LoA (dB): " pooled_LLA_md
display "Upper LoA (dB): " pooled_ULA_md
display "------------------------------------------"


quietly summarize n_eyes if !missing(_meta_es)
local Neyes = r(sum)


display as text " Number of eyes included in this meta-analysis: " as result `Neyes'


display as text "Included studies and sample sizes (n_eyes):"
list study_id n_eyes if !missing(_meta_es), noobs clean separator(0)

//Analysis 21//
//ZONAL REPEATABILITY, Test 1 vs Test 2, MRF///
//ZONE 1//

clear

import excel "/Users/andresinzunza/Documents/Medicina/HARVARD MMSCI/Thesis/Project 1/Pop_Tag_Meta_analysis/data_extraction_sheet/pop_tag.xlsx", sheet("combined") firstrow case(lower)

drop if missing(icc_zone_1_test_retest) | missing(ll_icc_zone_1_test_retest) | missing(ul_icc_zone_1_test_retest)

gen z_icc = 0.5 * ln((1 + icc_zone_1_test_retest) / (1 - icc_zone_1_test_retest))
gen z_ll  = 0.5 * ln((1 + ll_icc_zone_1_test_retest) / (1 - ll_icc_zone_1_test_retest))
gen z_ul  = 0.5 * ln((1 + ul_icc_zone_1_test_retest) / (1 - ul_icc_zone_1_test_retest))

gen se_z_icc = (z_ul - z_ll) / (2 * 1.96)

meta set z_icc se_z_icc, studylabel(study_id)
meta summarize, random

local pooled_z = r(theta)
local lower_z  = r(ci_lb)
local upper_z  = r(ci_ub)

local pooled_icc = (exp(2*`pooled_z') - 1) / (exp(2*`pooled_z') + 1)
local lower_icc  = (exp(2*`lower_z') - 1) / (exp(2*`lower_z') + 1)
local upper_icc  = (exp(2*`upper_z') - 1) / (exp(2*`upper_z') + 1)

display as text "Pooled ICC (Zone 1 Test–Retest): " %6.3f `pooled_icc' " [" %6.3f `lower_icc' ", " %6.3f `upper_icc' "]"

gen icc_md = (exp(2*z_icc) - 1) / (exp(2*z_icc) + 1)
gen icc_ll = (exp(2*z_ll) - 1) / (exp(2*z_ll) + 1)
gen icc_ul = (exp(2*z_ul) - 1) / (exp(2*z_ul) + 1)

sort year

metan icc_md icc_ll icc_ul, random label(namevar=study_id) effect("ICC") null(0) title("ICC Test–Retest, Zone 1") xlab(0(.1)1.0, grid) note("Zone 1 ICC Test–Retest")


quietly summarize n_eyes if !missing(_meta_es)
local Neyes = r(sum)


display as text " Number of eyes included in this meta-analysis: " as result `Neyes'


display as text "Included studies and sample sizes (n_eyes):"
list study_id n_eyes if !missing(_meta_es), noobs clean separator(0)

//Analysis 22//
//ZONAL REPEATABILITY, Test 1 vs Test 2, MRF///
//ZONE 2//

clear

import excel "/Users/andresinzunza/Documents/Medicina/HARVARD MMSCI/Thesis/Project 1/Pop_Tag_Meta_analysis/data_extraction_sheet/pop_tag.xlsx", sheet("combined") firstrow case(lower)

drop if missing(icc_zone_2_test_retest) | missing(ll_icc_zone_2_test_retest) | missing(ul_icc_zone_2_test_retest)

gen z_icc = 0.5 * ln((1 + icc_zone_2_test_retest) / (1 - icc_zone_2_test_retest))
gen z_ll  = 0.5 * ln((1 + ll_icc_zone_2_test_retest) / (1 - ll_icc_zone_2_test_retest))
gen z_ul  = 0.5 * ln((1 + ul_icc_zone_2_test_retest) / (1 - ul_icc_zone_2_test_retest))

gen se_z_icc = (z_ul - z_ll) / (2 * 1.96)

meta set z_icc se_z_icc, studylabel(study_id)
meta summarize, random

local pooled_z = r(theta)
local lower_z  = r(ci_lb)
local upper_z  = r(ci_ub)

local pooled_icc = (exp(2*`pooled_z') - 1) / (exp(2*`pooled_z') + 1)
local lower_icc  = (exp(2*`lower_z') - 1) / (exp(2*`lower_z') + 1)
local upper_icc  = (exp(2*`upper_z') - 1) / (exp(2*`upper_z') + 1)

display as text "Pooled ICC (Zone 2 Test–Retest): " %6.3f `pooled_icc' " [" %6.3f `lower_icc' ", " %6.3f `upper_icc' "]"

gen icc_md = (exp(2*z_icc) - 1) / (exp(2*z_icc) + 1)
gen icc_ll = (exp(2*z_ll) - 1) / (exp(2*z_ll) + 1)
gen icc_ul = (exp(2*z_ul) - 1) / (exp(2*z_ul) + 1)

sort year

metan icc_md icc_ll icc_ul, random label(namevar=study_id) effect("ICC") null(0) title("ICC Test–Retest, Zone 2") xlab(0(.1)1.0, grid) note("Zone 2 ICC Test–Retest")

//Analysis 23//
//ZONAL REPEATABILITY, Test 1 vs Test 2, MRF///
//ZONE 3//

clear

import excel "/Users/andresinzunza/Documents/Medicina/HARVARD MMSCI/Thesis/Project 1/Pop_Tag_Meta_analysis/data_extraction_sheet/pop_tag.xlsx", sheet("combined") firstrow case(lower)

drop if missing(icc_zone_3_test_retest) | missing(ll_icc_zone_3_test_retest) | missing(ul_icc_zone_3_test_retest)

gen z_icc = 0.5 * ln((1 + icc_zone_3_test_retest) / (1 - icc_zone_3_test_retest))
gen z_ll  = 0.5 * ln((1 + ll_icc_zone_3_test_retest) / (1 - ll_icc_zone_3_test_retest))
gen z_ul  = 0.5 * ln((1 + ul_icc_zone_3_test_retest) / (1 - ul_icc_zone_3_test_retest))

gen se_z_icc = (z_ul - z_ll) / (2 * 1.96)

meta set z_icc se_z_icc, studylabel(study_id)
meta summarize, random

local pooled_z = r(theta)
local lower_z  = r(ci_lb)
local upper_z  = r(ci_ub)

local pooled_icc = (exp(2*`pooled_z') - 1) / (exp(2*`pooled_z') + 1)
local lower_icc  = (exp(2*`lower_z') - 1) / (exp(2*`lower_z') + 1)
local upper_icc  = (exp(2*`upper_z') - 1) / (exp(2*`upper_z') + 1)

display "Pooled ICC (Zone 3 Test–Retest): " %6.3f `pooled_icc' " [" %6.3f `lower_icc' ", " %6.3f `upper_icc' "]"

gen icc_md = (exp(2*z_icc) - 1) / (exp(2*z_icc) + 1)
gen icc_ll = (exp(2*z_ll) - 1) / (exp(2*z_ll) + 1)
gen icc_ul = (exp(2*z_ul) - 1) / (exp(2*z_ul) + 1)

sort year

metan icc_md icc_ll icc_ul, random label(namevar=study_id) effect("ICC") null(0) title("ICC Test–Retest, Zone 3") xlab(0(.1)1.0, grid) note("Zone 3 ICC Test–Retest")


//Analysis 24//
//ZONAL REPEATABILITY, Test 1 vs Test 2, MRF///
//ZONE 4//

clear

import excel "/Users/andresinzunza/Documents/Medicina/HARVARD MMSCI/Thesis/Project 1/Pop_Tag_Meta_analysis/data_extraction_sheet/pop_tag.xlsx", sheet("combined") firstrow case(lower)

drop if missing(icc_zone_4_test_retest) | missing(ll_icc_zone_4_test_retest) | missing(ul_icc_zone_4_test_retest)

gen z_icc = 0.5 * ln((1 + icc_zone_4_test_retest) / (1 - icc_zone_4_test_retest))
gen z_ll  = 0.5 * ln((1 + ll_icc_zone_4_test_retest) / (1 - ll_icc_zone_4_test_retest))
gen z_ul  = 0.5 * ln((1 + ul_icc_zone_4_test_retest) / (1 - ul_icc_zone_4_test_retest))

gen se_z_icc = (z_ul - z_ll) / (2 * 1.96)

meta set z_icc se_z_icc, studylabel(study_id)
meta summarize, random

local pooled_z = r(theta)
local lower_z  = r(ci_lb)
local upper_z  = r(ci_ub)

local pooled_icc = (exp(2*`pooled_z') - 1) / (exp(2*`pooled_z') + 1)
local lower_icc  = (exp(2*`lower_z') - 1) / (exp(2*`lower_z') + 1)
local upper_icc  = (exp(2*`upper_z') - 1) / (exp(2*`upper_z') + 1)

display "Pooled ICC (Zone 4 Test–Retest): " %6.3f `pooled_icc' " [" %6.3f `lower_icc' ", " %6.3f `upper_icc' "]"

gen icc_md = (exp(2*z_icc) - 1) / (exp(2*z_icc) + 1)
gen icc_ll = (exp(2*z_ll) - 1) / (exp(2*z_ll) + 1)
gen icc_ul = (exp(2*z_ul) - 1) / (exp(2*z_ul) + 1)

sort year

metan icc_md icc_ll icc_ul, random label(namevar=study_id) effect("ICC") null(0) title("ICC Test–Retest, Zone 4") xlab(0(.1)1.0, grid) note("Zone 4 ICC Test–Retest")


//Analysis 25//
//ZONAL REPEATABILITY, Test 1 vs Test 2, MRF///
//ZONE 5//

clear

import excel "/Users/andresinzunza/Documents/Medicina/HARVARD MMSCI/Thesis/Project 1/Pop_Tag_Meta_analysis/data_extraction_sheet/pop_tag.xlsx", sheet("combined") firstrow case(lower)

drop if missing(icc_zone_5_test_retest) | missing(ll_icc_zone_5_test_retest) | missing(ul_icc_zone_5_test_retest)

gen z_icc = 0.5 * ln((1 + icc_zone_5_test_retest) / (1 - icc_zone_5_test_retest))
gen z_ll  = 0.5 * ln((1 + ll_icc_zone_5_test_retest) / (1 - ll_icc_zone_5_test_retest))
gen z_ul  = 0.5 * ln((1 + ul_icc_zone_5_test_retest) / (1 - ul_icc_zone_5_test_retest))

gen se_z_icc = (z_ul - z_ll) / (2 * 1.96)

meta set z_icc se_z_icc, studylabel(study_id)
meta summarize, random

local pooled_z = r(theta)
local lower_z  = r(ci_lb)
local upper_z  = r(ci_ub)

local pooled_icc = (exp(2*`pooled_z') - 1) / (exp(2*`pooled_z') + 1)
local lower_icc  = (exp(2*`lower_z') - 1) / (exp(2*`lower_z') + 1)
local upper_icc  = (exp(2*`upper_z') - 1) / (exp(2*`upper_z') + 1)

display "Pooled ICC (Zone 5 Test–Retest): " %6.3f `pooled_icc' " [" %6.3f `lower_icc' ", " %6.3f `upper_icc' "]"

gen icc_md = (exp(2*z_icc) - 1) / (exp(2*z_icc) + 1)
gen icc_ll = (exp(2*z_ll) - 1) / (exp(2*z_ll) + 1)
gen icc_ul = (exp(2*z_ul) - 1) / (exp(2*z_ul) + 1)

sort year

metan icc_md icc_ll icc_ul, random label(namevar=study_id) effect("ICC") null(0) title("ICC Test–Retest, Zone 5") xlab(0(.1)1.0, grid) note("Zone 5 ICC Test–Retest")


//Analysis 26//
//ZONAL REPEATABILITY, Test 1 vs Test 2, MRF///
//ZONE 6//

clear

import excel "/Users/andresinzunza/Documents/Medicina/HARVARD MMSCI/Thesis/Project 1/Pop_Tag_Meta_analysis/data_extraction_sheet/pop_tag.xlsx", sheet("combined") firstrow case(lower)

drop if missing(icc_zone_6_test_retest) | missing(ll_icc_zone_6_test_retest) | missing(ul_icc_zone_6_test_retest)

gen z_icc = 0.5 * ln((1 + icc_zone_6_test_retest) / (1 - icc_zone_6_test_retest))
gen z_ll  = 0.5 * ln((1 + ll_icc_zone_6_test_retest) / (1 - ll_icc_zone_6_test_retest))
gen z_ul  = 0.5 * ln((1 + ul_icc_zone_6_test_retest) / (1 - ul_icc_zone_6_test_retest))

gen se_z_icc = (z_ul - z_ll) / (2 * 1.96)

meta set z_icc se_z_icc, studylabel(study_id)
meta summarize, random

local pooled_z = r(theta)
local lower_z  = r(ci_lb)
local upper_z  = r(ci_ub)

local pooled_icc = (exp(2*`pooled_z') - 1) / (exp(2*`pooled_z') + 1)
local lower_icc  = (exp(2*`lower_z') - 1) / (exp(2*`lower_z') + 1)
local upper_icc  = (exp(2*`upper_z') - 1) / (exp(2*`upper_z') + 1)

display "Pooled ICC (Zone 6 Test–Retest): " %6.3f `pooled_icc' " [" %6.3f `lower_icc' ", " %6.3f `upper_icc' "]"

gen icc_md = (exp(2*z_icc) - 1) / (exp(2*z_icc) + 1)
gen icc_ll = (exp(2*z_ll) - 1) / (exp(2*z_ll) + 1)
gen icc_ul = (exp(2*z_ul) - 1) / (exp(2*z_ul) + 1)

sort year

metan icc_md icc_ll icc_ul, random label(namevar=study_id) effect("ICC") null(0) title("ICC Test–Retest, Zone 6") xlab(0(.1)1.0, grid) note("Zone 6 ICC Test–Retest")



//Analysis 27//
//ZONAL REPEATABILITY, Test 1 vs Test 2, MRF///
//ZONE 7//

clear

import excel "/Users/andresinzunza/Documents/Medicina/HARVARD MMSCI/Thesis/Project 1/Pop_Tag_Meta_analysis/data_extraction_sheet/pop_tag.xlsx", sheet("combined") firstrow case(lower)

drop if missing(icc_zone_7_test_retest) | missing(ll_icc_zone_7_test_retest) | missing(ul_icc_zone_7_test_retest)

gen z_icc = 0.5 * ln((1 + icc_zone_7_test_retest) / (1 - icc_zone_7_test_retest))
gen z_ll  = 0.5 * ln((1 + ll_icc_zone_7_test_retest) / (1 - ll_icc_zone_7_test_retest))
gen z_ul  = 0.5 * ln((1 + ul_icc_zone_7_test_retest) / (1 - ul_icc_zone_7_test_retest))

gen se_z_icc = (z_ul - z_ll) / (2 * 1.96)

meta set z_icc se_z_icc, studylabel(study_id)
meta summarize, random

local pooled_z = r(theta)
local lower_z  = r(ci_lb)
local upper_z  = r(ci_ub)

local pooled_icc = (exp(2*`pooled_z') - 1) / (exp(2*`pooled_z') + 1)
local lower_icc  = (exp(2*`lower_z') - 1) / (exp(2*`lower_z') + 1)
local upper_icc  = (exp(2*`upper_z') - 1) / (exp(2*`upper_z') + 1)

display "Pooled ICC (Zone 7 Test–Retest): " %6.3f `pooled_icc' " [" %6.3f `lower_icc' ", " %6.3f `upper_icc' "]"

gen icc_md = (exp(2*z_icc) - 1) / (exp(2*z_icc) + 1)
gen icc_ll = (exp(2*z_ll) - 1) / (exp(2*z_ll) + 1)
gen icc_ul = (exp(2*z_ul) - 1) / (exp(2*z_ul) + 1)

sort year

metan icc_md icc_ll icc_ul, random label(namevar=study_id) effect("ICC") null(0) title("ICC Test–Retest, Zone 7") xlab(0(.1)1.0, grid) note("Zone 7 ICC Test–Retest")


//Analysis 28//
//ZONAL REPEATABILITY, Test 1 vs Test 2, MRF///
//ZONE 8//

clear

import excel "/Users/andresinzunza/Documents/Medicina/HARVARD MMSCI/Thesis/Project 1/Pop_Tag_Meta_analysis/data_extraction_sheet/pop_tag.xlsx", sheet("combined") firstrow case(lower)

drop if missing(icc_zone_8_test_retest) | missing(ll_icc_zone_8_test_retest) | missing(ul_icc_zone_8_test_retest)

gen z_icc = 0.5 * ln((1 + icc_zone_8_test_retest) / (1 - icc_zone_8_test_retest))
gen z_ll  = 0.5 * ln((1 + ll_icc_zone_8_test_retest) / (1 - ll_icc_zone_8_test_retest))
gen z_ul  = 0.5 * ln((1 + ul_icc_zone_8_test_retest) / (1 - ul_icc_zone_8_test_retest))

gen se_z_icc = (z_ul - z_ll) / (2 * 1.96)

meta set z_icc se_z_icc, studylabel(study_id)
meta summarize, random

local pooled_z = r(theta)
local lower_z  = r(ci_lb)
local upper_z  = r(ci_ub)

local pooled_icc = (exp(2*`pooled_z') - 1) / (exp(2*`pooled_z') + 1)
local lower_icc  = (exp(2*`lower_z') - 1) / (exp(2*`lower_z') + 1)
local upper_icc  = (exp(2*`upper_z') - 1) / (exp(2*`upper_z') + 1)

display "Pooled ICC (Zone 8 Test–Retest): " %6.3f `pooled_icc' " [" %6.3f `lower_icc' ", " %6.3f `upper_icc' "]"

gen icc_md = (exp(2*z_icc) - 1) / (exp(2*z_icc) + 1)
gen icc_ll = (exp(2*z_ll) - 1) / (exp(2*z_ll) + 1)
gen icc_ul = (exp(2*z_ul) - 1) / (exp(2*z_ul) + 1)

sort year

metan icc_md icc_ll icc_ul, random label(namevar=study_id) effect("ICC") null(0) title("ICC Test–Retest, Zone 8") xlab(0(.1)1.0, grid) note("Zone 8 ICC Test–Retest")


//Analysis 29//
//ZONAL REPEATABILITY, Test 1 vs Test 2, MRF///
//ONE BIG FOREST PLOT for ZONAL REPEATABILITY//

clear

import excel "/Users/andresinzunza/Documents/Medicina/HARVARD MMSCI/Thesis/Project 1/Pop_Tag_Meta_analysis/data_extraction_sheet/pop_tag.xlsx", sheet("combined") firstrow case(lower)

keep study_id year icc_zone_*_test_retest ll_icc_zone_*_test_retest ul_icc_zone_*_test_retest

forvalues z = 1/8 {
    rename icc_zone_`z'_test_retest icc_`z'
    rename ll_icc_zone_`z'_test_retest ll_`z'
    rename ul_icc_zone_`z'_test_retest ul_`z'
}

reshape long icc_ ll_ ul_, i(study_id) j(zone)

rename icc_ icc
rename ll_ ll
rename ul_ ul

drop if missing(icc) | missing(ll) | missing(ul)

gen se_icc = (ul - ll) / (2 * 1.96)

metan icc se_icc, random by(zone) nosubgroup  effect("ICC") lcols(study_id year) null(0) xlab(0.10(0.1)1, grid) title("Zonal Test–Retest Repeatability (ICC)")

//Analysis 30//
//ZONAL REPEATABILITY, Test 1 vs Test 2, MRF///
//ONE BIG TABLE TU SUMMARIZE ZONAL REPEATABILITY//

clear

import excel "/Users/andresinzunza/Documents/Medicina/HARVARD MMSCI/Thesis/Project 1/Pop_Tag_Meta_analysis/data_extraction_sheet/pop_tag.xlsx", sheet("combined") firstrow case(lower)

tempfile results
capture postutil clear
postfile table str20 zone_name pooled_icc lower_ci upper_ci using `results'

forvalues z = 1/8 {

    preserve

    local var_icc  icc_zone_`z'_test_retest
    local var_ll   ll_icc_zone_`z'_test_retest
    local var_ul   ul_icc_zone_`z'_test_retest

    drop if missing(`var_icc') | missing(`var_ll') | missing(`var_ul')

    gen z_icc = 0.5 * ln((1 + `var_icc') / (1 - `var_icc'))
    gen z_ll  = 0.5 * ln((1 + `var_ll')  / (1 - `var_ll'))
    gen z_ul  = 0.5 * ln((1 + `var_ul')  / (1 - `var_ul'))

    gen se_z_icc = (z_ul - z_ll) / (2 * 1.96)

    meta set z_icc se_z_icc, studylabel(study_id)
    meta summarize, random

    local pooled_z = r(theta)
    local lower_z  = r(ci_lb)
    local upper_z  = r(ci_ub)

    local ICC  = (exp(2*`pooled_z') - 1) / (exp(2*`pooled_z') + 1)
    local LCI  = (exp(2*`lower_z')  - 1) / (exp(2*`lower_z') + 1)
    local UCI  = (exp(2*`upper_z')  - 1) / (exp(2*`upper_z') + 1)

    post table ("Zone `z'") (`ICC') (`LCI') (`UCI')

    restore
}

postclose table

use `results', clear
list, noobs sep(8)


//ANALYSIS 31//
////fixation losses, crude proportions////


clear

import excel "/Users/andresinzunza/Documents/Medicina/HARVARD MMSCI/Thesis/Project 1/Pop_Tag_Meta_analysis/data_extraction_sheet/pop_tag.xlsx", sheet("combined") firstrow case(lower)

drop if missing(fixation_loss_mrf, dispersion_fixation_loss_mrf, fixation_loss_hfa, dispersion_fixation_loss_hfa)

rename fixation_loss_mrf fixation_loss_MRF
rename fixation_loss_hfa fixation_loss_HFA
rename dispersion_fixation_loss_mrf dispersion_fixation_loss_MRF
rename dispersion_fixation_loss_hfa dispersion_fixation_loss_HFA

reshape long fixation_loss_ dispersion_fixation_loss_, i(study_id year) j(group) string

gen se = dispersion_fixation_loss / sqrt(n_eyes)

sort year

meta set fixation_loss se, studylabel(study_id) random

metan fixation_loss se, by(group) random label(namevar=study_id) sortby(year) xlab(0(0.05).5) nodiamonds interaction nooverall title("Fixation Loss")subtitle("MRF vs HFA")note("Number of Eyes = ")

quietly summarize n_eyes if !missing(_meta_es)
local Neyes = r(sum)


display as text " Number of eyes included in this meta-analysis: " as result `Neyes'


display as text "Included studies and sample sizes (n_eyes):"
list study_id n_eyes if !missing(_meta_es), noobs clean separator(0)

//ANALYSIS 32//
///FALSE POSITIVES, Analysis///

clear

import excel "/Users/andresinzunza/Documents/Medicina/HARVARD MMSCI/Thesis/Project 1/Pop_Tag_Meta_analysis/data_extraction_sheet/pop_tag.xlsx", sheet("combined") firstrow case(lower)

drop if missing(false_pos_mrf, dis_false_pos_mrf, false_pos_hfa, dis_false_pos_hfa, n_eyes)

rename false_pos_mrf false_pos_MRF
rename dis_false_pos_mrf dis_false_pos_MRF
rename false_pos_hfa false_pos_HFA
rename dis_false_pos_hfa dis_false_pos_HFA

reshape long false_pos_ dis_false_pos_, i(study_id year) j(group) string

gen se = dis_false_pos / sqrt(n_eyes)

sort year


meta set false_pos se, studylabel(study_id) random

metan false_pos se, by(group) random label(namevar=study_id) sortby(year) xlab(0.0(0.01)0.15) title("False Positive Rate") subtitle("MRF vs HFA")nodiamonds interaction nooverall note("Number of Eyes = ")


quietly summarize n_eyes if !missing(_meta_es)
local Neyes = r(sum)


display as text " Number of eyes included in this meta-analysis: " as result `Neyes'


display as text "Included studies and sample sizes (n_eyes):"
list study_id n_eyes if !missing(_meta_es), noobs clean separator(0)





//ANALYSIS 33//
////FALSE NEGATIVES///

clear

import excel "/Users/andresinzunza/Documents/Medicina/HARVARD MMSCI/Thesis/Project 1/Pop_Tag_Meta_analysis/data_extraction_sheet/pop_tag.xlsx", sheet("combined") firstrow case(lower)

drop if missing(false_neg_mrf, dis_false_neg_mrf, false_neg_hfa, dis_false_neg_hfa, n_eyes)

rename false_neg_mrf false_neg_MRF
rename dis_false_neg_mrf dis_false_neg_MRF
rename false_neg_hfa false_neg_HFA
rename dis_false_neg_hfa dis_false_neg_HFA

reshape long false_neg_ dis_false_neg_, i(study_id year) j(group) string
gen se = dis_false_neg / sqrt(n_eyes)

sort year


meta set false_neg se, studylabel(study_id) random

metan false_neg se, by(group) random label(namevar=study_id) sortby(year) xlab(0.0(0.01)0.16) title("False Negative Rate") subtitle("MRF vs HFA") nodiamonds nooverall note("Number of Eyes = ")


quietly summarize n_eyes if !missing(_meta_es)
local Neyes = r(sum)


display as text " Number of eyes included in this meta-analysis: " as result `Neyes'


display as text "Included studies and sample sizes (n_eyes):"
list study_id n_eyes if !missing(_meta_es), noobs clean separator(0)

///ANAlysis 34//
//AUC MD-MRF///

clear

import excel "/Users/andresinzunza/Documents/Medicina/HARVARD MMSCI/Thesis/Project 1/Pop_Tag_Meta_analysis/data_extraction_sheet/pop_tag.xlsx", sheet("combined") firstrow case(lower)

sort year

gen logit_auc_md_mrf = log(auc_md_mrf/(1-auc_md_mrf))
gen se_md_mrf        = (ul_auc_md_mrf - ll_auc_md_mrf) / (2*1.96)

gen logit_auc_md_hfa = log(auc_md_hfa/(1-auc_md_hfa))
gen se_md_hfa        = (ul_auc_md_hfa - ll_auc_md_hfa) / (2*1.96)

gen logit_auc_psd_mrf = log(auc_psd_mrf/(1-auc_psd_mrf))
gen se_psd_mrf        = (ul_auc_psd_mrf - ll_auc_psd_mrf) / (2*1.96)

gen logit_auc_psd_hfa = log(auc_psd_hfa/(1-auc_psd_hfa))
gen se_psd_hfa        = (ul_auc_psd_hfa - ll_auc_psd_hfa) / (2*1.96)


keep if !missing(auc_md_mrf, ll_auc_md_mrf, ul_auc_md_mrf)
metan logit_auc_md_mrf se_md_mrf, random label(namevar=study_id)
scalar pooled_logit_md_mrf = _ES[1]
scalar lci_logit_md_mrf    = _LCI[1]
scalar uci_logit_md_mrf    = _UCI[1]
scalar pooled_auc_md_mrf   = exp(pooled_logit_md_mrf)/(1+exp(pooled_logit_md_mrf))
scalar lci_auc_md_mrf      = exp(lci_logit_md_mrf)/(1+exp(lci_logit_md_mrf))
scalar uci_auc_md_mrf      = exp(uci_logit_md_mrf)/(1+exp(uci_logit_md_mrf))
display pooled_auc_md_mrf
display lci_auc_md_mrf
display uci_auc_md_mrf



///ANAlysis 35//
//AUC MD-HFA///

clear

import excel "/Users/andresinzunza/Documents/Medicina/HARVARD MMSCI/Thesis/Project 1/Pop_Tag_Meta_analysis/data_extraction_sheet/pop_tag.xlsx", sheet("combined") firstrow case(lower)

sort year

gen logit_auc_md_hfa = log(auc_md_hfa/(1-auc_md_hfa))
gen se_md_hfa        = (ul_auc_md_hfa - ll_auc_md_hfa) / (2*1.96)
keep if !missing(auc_md_hfa, ll_auc_md_hfa, ul_auc_md_hfa)
metan logit_auc_md_hfa se_md_hfa, random label(namevar=study_id)
scalar pooled_logit_md_hfa = _ES[1]
scalar lci_logit_md_hfa    = _LCI[1]
scalar uci_logit_md_hfa    = _UCI[1]
scalar pooled_auc_md_hfa   = exp(pooled_logit_md_hfa)/(1+exp(pooled_logit_md_hfa))
scalar lci_auc_md_hfa      = exp(lci_logit_md_hfa)/(1+exp(lci_logit_md_hfa))
scalar uci_auc_md_hfa      = exp(uci_logit_md_hfa)/(1+exp(uci_logit_md_hfa))
display pooled_auc_md_hfa
display lci_auc_md_hfa
display uci_auc_md_hfa


quietly summarize n_eyes if !missing(_meta_es)
local Neyes = r(sum)


display as text " Number of eyes included in this meta-analysis: " as result `Neyes'


display as text "Included studies and sample sizes (n_eyes):"
list study_id n_eyes if !missing(_meta_es), noobs clean separator(0)
///ANAlysis 36//
//AUC PD-MRF///

clear

import excel "/Users/andresinzunza/Documents/Medicina/HARVARD MMSCI/Thesis/Project 1/Pop_Tag_Meta_analysis/data_extraction_sheet/pop_tag.xlsx", sheet("combined") firstrow case(lower)

sort year

sort year

gen logit_auc_psd_mrf = log(auc_psd_mrf/(1-auc_psd_mrf))
gen se_psd_mrf        = (ul_auc_psd_mrf - ll_auc_psd_mrf) / (2*1.96)
keep if !missing(auc_psd_mrf, ll_auc_psd_mrf, ul_auc_psd_mrf)
metan logit_auc_psd_mrf se_psd_mrf, random label(namevar=study_id)
scalar pooled_logit_psd_mrf = _ES[1]
scalar lci_logit_psd_mrf    = _LCI[1]
scalar uci_logit_psd_mrf    = _UCI[1]
scalar pooled_auc_psd_mrf   = exp(pooled_logit_psd_mrf)/(1+exp(pooled_logit_psd_mrf))
scalar lci_auc_psd_mrf      = exp(lci_logit_psd_mrf)/(1+exp(lci_logit_psd_mrf))
scalar uci_auc_psd_mrf      = exp(uci_logit_psd_mrf)/(1+exp(uci_logit_psd_mrf))
display pooled_auc_psd_mrf
display lci_auc_psd_mrf
display uci_auc_psd_mrf

///ANAlysis 37//
//AUC PD-HFA///

clear

import excel "/Users/andresinzunza/Documents/Medicina/HARVARD MMSCI/Thesis/Project 1/Pop_Tag_Meta_analysis/data_extraction_sheet/pop_tag.xlsx", sheet("combined") firstrow case(lower)

sort year


gen logit_auc_psd_hfa = log(auc_psd_hfa/(1-auc_psd_hfa))
gen se_psd_hfa        = (ul_auc_psd_hfa - ll_auc_psd_hfa) / (2*1.96)
keep if !missing(auc_psd_hfa, ll_auc_psd_hfa, ul_auc_psd_hfa)
metan logit_auc_psd_hfa se_psd_hfa, random label(namevar=study_id)
scalar pooled_logit_psd_hfa = _ES[1]
scalar lci_logit_psd_hfa    = _LCI[1]
scalar uci_logit_psd_hfa    = _UCI[1]
scalar pooled_auc_psd_hfa   = exp(pooled_logit_psd_hfa)/(1+exp(pooled_logit_psd_hfa))
scalar lci_auc_psd_hfa      = exp(lci_logit_psd_hfa)/(1+exp(lci_logit_psd_hfa))
scalar uci_auc_psd_hfa      = exp(uci_logit_psd_hfa)/(1+exp(uci_logit_psd_hfa))
display pooled_auc_psd_hfa
display lci_auc_psd_hfa
display uci_auc_psd_hfa



////POOLED RESULTS///
display "-------------------------------------------------------------"
display "        SUMMARY OF RANDOM-EFFECTS META-ANALYSIS (AUC)"
display "-------------------------------------------------------------"

display "MD – MRF:  "   %4.3f pooled_auc_md_mrf  "  (" %4.3f lci_auc_md_mrf  " – " %4.3f uci_auc_md_mrf  ")"
display "MD – HFA:  "   %4.3f pooled_auc_md_hfa  "  (" %4.3f lci_auc_md_hfa  " – " %4.3f uci_auc_md_hfa  ")"
display "PSD – MRF: "   %4.3f pooled_auc_psd_mrf "  (" %4.3f lci_auc_psd_mrf " – " %4.3f uci_auc_psd_mrf ")"
display "PSD – HFA: "   %4.3f pooled_auc_psd_hfa "  (" %4.3f lci_auc_psd_hfa " – " %4.3f uci_auc_psd_hfa ")"

display "-------------------------------------------------------------"

////ROC: POOLED FOREST PLOT///
clear
set more off

import excel "/Users/andresinzunza/Documents/Medicina/HARVARD MMSCI/Thesis/Project 1/Pop_Tag_Meta_analysis/data_extraction_sheet/pop_tag.xlsx", sheet("combined") firstrow case(lower)

keep study_id year auc_md_mrf ll_auc_md_mrf ul_auc_md_mrf auc_md_hfa ll_auc_md_hfa ul_auc_md_hfa auc_psd_mrf ll_auc_psd_mrf ul_auc_psd_mrf auc_psd_hfa ll_auc_psd_hfa ul_auc_psd_hfa

tempfile all
save `all', replace

clear
use `all'

preserve
keep study_id year auc_md_mrf ll_auc_md_mrf ul_auc_md_mrf
rename auc_md_mrf auc
rename ll_auc_md_mrf ll
rename ul_auc_md_mrf ul
gen subgroup = "MRF – MD"
tempfile mrf_md
save `mrf_md'
restore

preserve
keep study_id year auc_md_hfa ll_auc_md_hfa ul_auc_md_hfa
rename auc_md_hfa auc
rename ll_auc_md_hfa ll
rename ul_auc_md_hfa ul
gen subgroup = "HFA – MD"
tempfile hfa_md
save `hfa_md'
restore

preserve
keep study_id year auc_psd_mrf ll_auc_psd_mrf ul_auc_psd_mrf
rename auc_psd_mrf auc
rename ll_auc_psd_mrf ll
rename ul_auc_psd_mrf ul
gen subgroup = "MRF – PSD"
tempfile mrf_psd
save `mrf_psd'
restore

preserve
keep study_id year auc_psd_hfa ll_auc_psd_hfa ul_auc_psd_hfa
rename auc_psd_hfa auc
rename ll_auc_psd_hfa ll
rename ul_auc_psd_hfa ul
gen subgroup = "HFA – PSD"
tempfile hfa_psd
save `hfa_psd'
restore

clear
use `mrf_md'
append using `hfa_md'
append using `mrf_psd'
append using `hfa_psd'

drop if missing(auc) | missing(ll) | missing(ul)

gen logit = log(auc/(1-auc))
gen se_logit = (ul - ll) / (2 * 1.96)

gen auc_bt = exp(logit)/(1 + exp(logit))
gen ll_bt = exp(logit - 1.96*se_logit)/(1 + exp(logit - 1.96*se_logit))
gen ul_bt = exp(logit + 1.96*se_logit)/(1 + exp(logit + 1.96*se_logit))

metan auc_bt ll_bt ul_bt, random by(subgroup) nooverall effect("AUC") lcols(study_id year) title("ROC") xlab(0(0.1)1) xscale(range(0 1))



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// APPENDIX AND SUPPLEMENTARY ANALYSIS// 
//SE calculated from paired measurements, with a high correlation//
///MD extra high correlation (0.90)//

clear

import excel "/Users/andresinzunza/Documents/Medicina/HARVARD MMSCI/Thesis/Project 1/Pop_Tag_Meta_analysis/data_extraction_sheet/pop_tag.xlsx", sheet("combined") firstrow case(lower)

summarize

local rho = 0.9

gen diff_md = mean_md_mrf - mean_md_hfa

gen se_diff_md = sqrt((disp_mean_md_mrf^2 + disp_mean_md_hfa^2 - 2 * `rho' * disp_mean_md_mrf * disp_mean_md_hfa) / n_eyes)

sort year

meta set diff_md se_diff_md, studylabel(study_id)

meta summarize, random

metan diff_md se_diff_md, random label(namevar=study_id) effect("Difference in dB") null(0) title("Mean Difference in MD") xlab(-3.0(1)6.0, grid) subtitle("Paired, 0.9 Correlation")


////MD, correlated, high correlation, 0.8///


clear

import excel "/Users/andresinzunza/Documents/Medicina/HARVARD MMSCI/Thesis/Project 1/Pop_Tag_Meta_analysis/data_extraction_sheet/pop_tag.xlsx", sheet("combined") firstrow case(lower)

summarize

local rho = 0.8

gen diff_md = mean_md_mrf - mean_md_hfa

gen se_diff_md = sqrt((disp_mean_md_mrf^2 + disp_mean_md_hfa^2 - 2 * `rho' * disp_mean_md_mrf * disp_mean_md_hfa) / n_eyes)

sort year

meta set diff_md se_diff_md, studylabel(study_id)

meta summarize, random

metan diff_md se_diff_md, random label(namevar=study_id) effect("Difference in dB") null(0) title("Mean Difference in MD") xlab(-3.0(1)6.0, grid) subtitle("Paired, 0.8 Correlation")

////MD, correlated, low correlation, 0.5///

clear

import excel "/Users/andresinzunza/Documents/Medicina/HARVARD MMSCI/Thesis/Project 1/Pop_Tag_Meta_analysis/data_extraction_sheet/pop_tag.xlsx", sheet("combined") firstrow case(lower)


local rho = 0.5

gen diff_md = mean_md_mrf - mean_md_hfa

gen se_diff_md = sqrt((disp_mean_md_mrf^2 + disp_mean_md_hfa^2 - 2 * `rho' * disp_mean_md_mrf * disp_mean_md_hfa) / n_eyes)

sort year

meta set diff_md se_diff_md, studylabel(study_id)

meta summarize, random

metan diff_md se_diff_md, random label(namevar=study_id) effect("Difference in dB") null(0) title("Mean Difference in MD") xlab(-3.0(1)6.0, grid) subtitle("Paired, 0.5 Correlation")









///////////////////////Sub-Analysis Vingrys Data/////FAST///MD



clear
import excel "/Users/andresinzunza/Documents/Medicina/HARVARD MMSCI/Thesis/Project 1/Pop_Tag_Meta_analysis/data_extraction_sheet/pop_tag.xlsx", sheet("combined") firstrow case(lower)

drop if study_id == "Kang, 2023"

local rho = 0.8

gen diff_md = mean_md_mrf - mean_md_hfa
gen se_diff_md = sqrt((disp_mean_md_mrf^2 + disp_mean_md_hfa^2 - 2*`rho'*disp_mean_md_mrf*disp_mean_md_hfa) / n_eyes)

sort year

meta set diff_md se_diff_md, studylabel(study_id)

meta summarize, random

metan diff_md se_diff_md, random label(namevar=study_id) effect("Difference in dB") null(0) title("Mean Difference in MD – Overall") xlab(-3(1)6, grid)

quietly summarize n_eyes if !missing(_meta_es)
local Neyes = r(sum)
display "Total eyes included: " `Neyes'

list study_id n_eyes if !missing(_meta_es), noobs clean separator(0)

gen subgroup = .
replace subgroup = 1 if fast == 0
replace subgroup = 2 if fast == 1
replace subgroup = 0 if fast == .

label define g 0 "HFA" 1 "MRF" 2 "MRF-Rapid"
label values subgroup g

metan diff_md se_diff_md, random by(subgroup) label(namevar=study_id) effect("Difference in dB") null(0) title("Mean Difference in MD – Subgrouped by Test Type") xlab(-3(1)6, grid)

foreach g in 0 1 2 {
    quietly summarize n_eyes if subgroup == `g' & !missing(diff_md)
    local N`g' = r(sum)
}

display "Eyes per subgroup:"
display "HFA:        " `N0'
display "MRF:        " `N1'
display "MRF-Rapid:  " `N2'

list study_id n_eyes subgroup if !missing(diff_md), noobs clean separator(0)



/////////////////////////////////////////////////////////////////////ICC /////////////////////////////////////////////////////////


clear

import excel "/Users/andresinzunza/Documents/Medicina/HARVARD MMSCI/Thesis/Project 1/Pop_Tag_Meta_analysis/data_extraction_sheet/pop_tag.xlsx", sheet("mrf_mrf_fast") firstrow case(lower)

drop if study_id == "Kang, 2023"

ds concordance_icc_mean_defect
local icc = r(varlist)

ds ll_ci_concord*
local ll_all = r(varlist)
local ll : word 1 of `ll_all'

ds ul_ci_concord*
local ul_all = r(varlist)
local ul : word 1 of `ul_all'

drop if missing(`icc') | missing(`ll') | missing(`ul')

gen z_icc = 0.5 * ln((1 + `icc') / (1 - `icc'))
gen z_ll  = 0.5 * ln((1 + `ll')  / (1 - `ll'))
gen z_ul  = 0.5 * ln((1 + `ul')  / (1 - `ul'))

gen se_z_icc = (z_ul - z_ll) / (2 * 1.96)

meta set z_icc se_z_icc, studylabel(study_id)

meta summarize, random

local pooled_z = r(theta)
local lower_z  = r(ci_lb)
local upper_z  = r(ci_ub)

local pooled_icc = (exp(2*`pooled_z') - 1) / (exp(2*`pooled_z') + 1)
local lower_icc  = (exp(2*`lower_z') - 1) / (exp(2*`lower_z') + 1)
local upper_icc  = (exp(2*`upper_z') - 1) / (exp(2*`upper_z') + 1)

display "Pooled ICC: " %6.3f `pooled_icc' " [" %6.3f `lower_icc' ", " %6.3f `upper_icc' "]"

gen icc_md = (exp(2*z_icc) - 1) / (exp(2*z_icc) + 1)
gen icc_ll = (exp(2*z_ll)  - 1) / (exp(2*z_ll) + 1)
gen icc_ul = (exp(2*z_ul)  - 1) / (exp(2*z_ul) + 1)

sort year

gen subgroup = .
replace subgroup = 1 if fast == 0
replace subgroup = 2 if fast == 1
replace subgroup = 0 if fast == .

label define g 0 "HFA" 1 "MRF" 2 "MRF-Rapid"
label values subgroup g

metan icc_md icc_ll icc_ul, random by(subgroup) label(namevar=study_id) effect("ICC") null(0) title("ICC Concordance – Subgrouped by Test Type") xlab(0(.1)1.0, grid)

foreach g in 0 1 2 {
    quietly summarize n_eyes if subgroup == `g' & !missing(icc_md)
    local N`g' = r(sum)
}

display "Eyes per subgroup:"
display "HFA:        " `N0'
display "MRF:        " `N1'
display "MRF-Rapid:  " `N2'

display "Included studies and sample sizes:"
list study_id n_eyes subgroup if !missing(icc_md), noobs clean separator(0)



/////////////////////////////////////////////////////////////////////////////TEST RETEST/////////////////////////////////////


clear

import excel "/Users/andresinzunza/Documents/Medicina/HARVARD MMSCI/Thesis/Project 1/Pop_Tag_Meta_analysis/data_extraction_sheet/pop_tag.xlsx", sheet("mrf_mrf_fast") firstrow case(lower)

drop if missing(test_retest_com_icc_md_mrf) | missing(ll_test_retest_com_icc_md_mrf) | missing(ul_test_retest_com_icc_md_mrf)

gen z_icc = 0.5 * ln((1 + test_retest_com_icc_md_mrf) / (1 - test_retest_com_icc_md_mrf))
gen z_ll  = 0.5 * ln((1 + ll_test_retest_com_icc_md_mrf) / (1 - ll_test_retest_com_icc_md_mrf))
gen z_ul  = 0.5 * ln((1 + ul_test_retest_com_icc_md_mrf) / (1 - ul_test_retest_com_icc_md_mrf))

gen se_z_icc = (z_ul - z_ll) / (2 * 1.96)

meta set z_icc se_z_icc, studylabel(study_id)
meta summarize, random

local pooled_z = r(theta)
local lower_z  = r(ci_lb)
local upper_z  = r(ci_ub)

local pooled_icc = (exp(2*`pooled_z') - 1) / (exp(2*`pooled_z') + 1)
local lower_icc  = (exp(2*`lower_z') - 1) / (exp(2*`lower_z') + 1)
local upper_icc  = (exp(2*`upper_z') - 1) / (exp(2*`upper_z') + 1)

display "Pooled ICC: " %6.3f `pooled_icc' " [" %6.3f `lower_icc' ", " %6.3f `upper_icc' "]"

gen icc_md = (exp(2*z_icc) - 1) / (exp(2*z_icc) + 1)
gen icc_ll = (exp(2*z_ll) - 1) / (exp(2*z_ll) + 1)
gen icc_ul = (exp(2*z_ul) - 1) / (exp(2*z_ul) + 1)

sort year

gen subgroup = .
replace subgroup = 1 if fast == 0
replace subgroup = 2 if fast == 1
replace subgroup = 0 if fast == .

label define g 0 "HFA" 1 "MRF" 2 "MRF-Rapid"
label values subgroup g

metan icc_md icc_ll icc_ul, random by(subgroup) label(namevar=study_id) effect("ICC") null(0) title("MD Test–Retest Reliability – Subgrouped by Test Speed") xlab(0(.1)1.0, grid)

foreach g in 0 1 2 {
    quietly summarize n_eyes if subgroup == `g' & !missing(icc_md)
    local N`g' = r(sum)
}

display "Eyes per subgroup:"
display "HFA:        " `N0'
display "MRF:        " `N1'
display "MRF-Rapid:  " `N2'

display "Included studies and sample sizes:"
list study_id n_eyes subgroup if !missing(icc_md), noobs clean separator(0)

