#!/usr/bin/perl -w

require "flush.pl";
require "TDT3.pm";
use strict;

my $Expected_TDT3Version = "2.5";

my $Usage ="Usage: DetectionScore.pl -K key_file <Options> DetectionOutput\n".
"TDT library Version: ".&TDT3pm_Version()."\n".
"Desc:  DetectionScore.pl is a generic Detection System evaluation program.  It\n".
"       requires two inputs, the key file, via the '-K' option, and the system\n".
"       output file, 'DetectionOutput'.  The HTML manual page describes the formats\n".
"       of the to input files.\n".
"Options\n".
"   -v num       -> Set the verbose level to 'num'. Default 1\n".
"                   ==0 None, ==1 Normal, >5 Slight, >10 way too much\n".
"   -P P(target)  -> Use P(target) in the cost function.o  Default is 0.02\n".
"   -C Cmiss:Cfa -> Use 'Cmiss' and 'Cfa' as the cost of a miss and cost of a\n".
"                   false alarm in the cost function respectively.  Defaults are\n".
"                   1 and 0.1\n".
"   -W Wrel      -> Use 'Wrel' as the weight of relevant stories in computing\n".
"                   the utility measure\n".
"   -M Umin      -> Use 'Umin' as the minimum normalized utility value\n".
"   -N TaskID,BlockID,TrialID ->\n".
"                   Define the names used in the reports.  'TaskID' is the detection\n".
"                   task name, 'Link' is the default.  'BlockID' is the name that\n".
"                   describes the block divisions, 'Topic' is the default.  'DecisionID'\n".
"                   describes what individual decisions are made on, 'Story' is the\n".
"                   default.\n".
"   -r Report    -> Write the summary report to the file 'Report'\n".
"   -D DetailFile -> Write a detailed report of the scoring.\n".
"   -Z UNCOMP    -> Define the uncompression command, it's typically 'zcat' or the\n".
"                   default 'gunzip'\n".
"   -S           -> Skip system output lines that do not exist in the key file\n".
"   -d DETfile   -> Filename root to write the DET file to.\n".
"      DET Plotting Options:\n".
"      -t title  -> The title to use in DET plot, default is the command line.\n".
"      -p        -> Produce an pooled DET line trace pooled over all decisions.\n".
"      -w        -> Produce a Block Weighted DET line trace, which is the average.\n".
"                   Pmiss and Pfa over test blocks.  The default plot printed.\n".
"      -n        -> Add 90% confidence intervals for the block-weighted DET plots.\n".
"\n";

die ("Error: Expected version of TDT3.pm is ".&TDT3pm_Version()." not $Expected_TDT3Version")
    if ($Expected_TDT3Version ne &TDT3pm_Version());

#### Globals Variables #####
$main::Vb = 1;
##
my $Key;
my $Sysout; 
my $CommandLine = $0." ".join(" ",@ARGV);
my $CF_Ptarget = 0.02;
my $CF_Cmiss = 1;
my $CF_Cfa = 0.1;
#
my $ReportFile = "-";
my $DetailFile="";
#
my $DETFile = "";
my $DETTitle = "";
my $DET_pooled = 0;
my $DET_TrialWeighted = 1;
my $DET_TrialWeighted_90conf = 0;
my $DET_mindet = 0;
my $TW_min_DET_Pmiss = "NULL";
my $TW_min_DET_Pfa = "NULL";
my $TW_min_DET_Cost = "NULL";
my $TW_min_DET_normCost = "NULL";
my $SW_min_DET_Pmiss = "NULL";
my $SW_min_DET_Pfa = "NULL";
my $SW_min_DET_Cost = "NULL";
my $SW_min_DET_normCost = "NULL";
my $UT_wtrel = 10;                        # utility weight
my $UT_min = -0.5;                        # utility mininum score
#
my $UNDEF  = "--";
#
my $rh_KeyInfo;
my $start_time = time();
#
my $TaskID = "Link";
my $BlockID = "Topic";
my $DecisionID = "Story";
#
my $SkipSystemResponseNotInKey = 0;
############################

############################ Main ###########################
&ProcessCommandLine();

my %TrialData = ();
my %LnkInfo = ();
Build_ensemble_trial_data2(\%TrialData, \%LnkInfo, $Key, $Sysout, $TaskID, $BlockID, $DecisionID, $DetailFile);

if ($DETFile ne ""){
    Produce_trial_ensemble_DET(\%TrialData,
			   $DETFile, $DETTitle, 
			   0, $DET_pooled, $DET_TrialWeighted, $DET_TrialWeighted_90conf,
			   $CF_Ptarget, $CF_Cmiss, $CF_Cfa,
			   \$TW_min_DET_Pmiss, \$TW_min_DET_Pfa, \$TW_min_DET_Cost, \$TW_min_DET_normCost,
		       \$SW_min_DET_Pmiss, \$SW_min_DET_Pfa, \$SW_min_DET_Cost, \$SW_min_DET_normCost);

    Produce_Minimum_DET_v2(\%TrialData, $DETFile, $DETTitle, $CF_Ptarget, $CF_Cmiss, $CF_Cfa)
	if ($DET_mindet);
}
&Produce_SLD_Report(\%TrialData, \%LnkInfo, $ReportFile,
		    $CF_Ptarget, $CF_Cmiss, $CF_Cfa,
		    $TW_min_DET_Pmiss, $TW_min_DET_Pfa, $TW_min_DET_Cost, $TW_min_DET_normCost,
		    $SW_min_DET_Pmiss, $SW_min_DET_Pfa, $SW_min_DET_Cost, $SW_min_DET_normCost);

printf("Scoring Completed .... %d elapsed total seconds\n",
       time - $start_time) if ($main::Vb > 0);
printf "Successful Completion\n" if ($main::Vb > 0);

exit 0;

###################### End of main ############################

sub die_usage{  my($mesg) = @_;    print "$Usage";   
		die("Error: ".$mesg."\n");  }

sub ProcessCommandLine{
    require "getopts.pl";
    &Getopts('Sapwnt:v:P:C:r:d:K:D:N:Z:W:M:');

    ### So that automatic library checks can be made
    exit 0 if ($ARGV[0] eq "__CHECKLIB__");
    
    die_usage("Detection Key File Req'd") if (!defined($main::opt_K));

    $Key = $main::opt_K;
    $main::Vb = $main::opt_v if (defined($main::opt_v));
    $ReportFile = $main::opt_r if (defined($main::opt_r));
    $DetailFile = $main::opt_D if (defined($main::opt_D));
    $SkipSystemResponseNotInKey = $main::opt_S if (defined($main::opt_S));
    if (defined($main::opt_N)){
	($TaskID,$BlockID, $DecisionID) = split(/,/,$main::opt_N);
	die "Error: Mal-formed TaskID in -N option" if (!defined($TaskID));
	die "Error: Mal-formed BlockID in -N option" if (!defined($BlockID));
	die "Error: Mal-formed DecisionID in -N option" if (!defined($DecisionID));
    }
    if (defined($main::opt_P)){
	die "Error: Ptarget range is: 0 <= Ptarget <=1.0" 
	    if ($main::opt_P < 0.0 || $main::opt_P > 1.0);
	$CF_Ptarget = $main::opt_P;
    }
    if (defined($main::opt_C)){
	die "Mal-formed Miss/Fa Costs.  Must be formatted as <num>:<num> and both positive."
	    if ($main::opt_C !~ /^([\d]+|[\d]*\.[\d]+|[\d]+\.[\d]*):([\d]+|[\d]*\.[\d]+|[\d]+\.[\d]*)$/);
	($CF_Cmiss, $CF_Cfa) = ($1,$2);
    }

    $UT_wtrel = $main::opt_W if (defined($main::opt_W));
    $UT_min = $main::opt_M if (defined($main::opt_M));

    set_UncompressCommand($main::opt_Z) if (defined($main::opt_Z)) ;
    if (defined($main::opt_d)){
	$DETFile = $main::opt_d;
	$DETTitle = $CommandLine;
	$DETTitle = $main::opt_t if (defined($main::opt_t));
	if (defined($main::opt_p)){
	    $DET_pooled = $main::opt_p;
	    $DET_TrialWeighted = (defined($main::opt_w) ? 1 : 0);
	    $DET_TrialWeighted_90conf = (defined($main::opt_n) ? 1 : 0);
	}
	if (defined($main::opt_w)){
	    $DET_TrialWeighted = 1 ;
	    $DET_TrialWeighted_90conf = 1 if (defined($main::opt_n));
	    $DET_mindet = $main::opt_a if (defined($main::opt_a));	    
	} else {
	    print STDERR "Warning: -n option ignored without using -w\n" if (defined($main::opt_n));
	    print STDERR "Warning: -a option ignored without using -w\n" if (defined($main::opt_a));
	}
    } else {
	print STDERR "Warning: -t option ignored\n" if (defined($main::opt_t));
	print STDERR "Warning: -n option ignored\n" if (defined($main::opt_n));
	print STDERR "Warning: -a option ignored\n" if (defined($main::opt_a));
    }
    die_usage("Detection system output file Req'd") if ($#ARGV != 0);
    $Sysout = $ARGV[0];
}


sub Build_ensemble_trial_data2{
    my ($rh_trial_data, $rh_lnkinfo, $Key, $Sys, $TaskID, $BlockID, $DecisionID, $DetailFile) = @_;
    my ($topic, $attr, %keydata, %sysdata, $sysstr, $keystr);
    my ($syskey, $sysdecision, $sysscore);
    my ($keykey, $keydata, $keyeval, $keyblock, $k1, $k2);
    my ($syslines) = 0;
    my $beg_time = time();
    my ($skipped) = 0;
    my ($syserrors) = 0;

    open (DETAIL, ">$DetailFile") || die "Failed to open detail file '$DetailFile'" if ($DetailFile ne "");
    print DETAIL "<link>\n" if ($DetailFile ne "");
    print "Simultaneously reading Keyfile and System File.\n" if ($main::Vb > 0);
    print "   1 Dot == 10000 trials read: " if ($main::Vb == 1);

    ### Initialize the linkinfo elements
    $rh_lnkinfo->{"keyfilename"} = $Key;
    $rh_lnkinfo->{"System_Output"} = $Sys;

    ##########################################3
    ### open the key file
    my $KEY = TDT_open($Key);
    parse_key_header(\%keydata, scalar(<$KEY>));

    #####################################
    ### open the System file
    my $SYS = TDT_open($Sys);
    parse_sys_header($rh_lnkinfo, $SYS);
    
    ### initialize the trial_data
    $rh_trial_data->{"pooledtitle"} = "$DecisionID Weighted Curve";
    $rh_trial_data->{"trialweightedtitle"} = "$BlockID Weighted Curve";
    $rh_trial_data->{"is_poolable"} = 1;
    $rh_trial_data->{"TaskID"} = $TaskID;
    $rh_trial_data->{"BlockID"} = $BlockID;
    $rh_trial_data->{"DecisionID"} = $DecisionID;

    while ($sysstr = <$SYS>){
	chomp($sysstr);
	$sysstr =~ s/#.*$//;    next if ($sysstr =~ /^\s*$/);

	# print $sysstr;
	($k1, $k2, $sysdecision, $sysscore) = split(/\s+/,$sysstr,4);
	$syskey = $k1." ".$k2; 

	### Find the matchin line in the key file
	while (! eof($KEY) && !defined($keydata{"lines"}{$syskey})){
	    $keystr = <$KEY>; 
	    last if (!defined($keystr));
	    $keystr =~ s/#.*$//;
	    next if ($keystr =~ /^\s*$/);

	    die "Error: Unable to find KEY entry for system line '$sysstr'" if (! defined($keystr));
	    ($k1, $k2, $keydata) = split(/\s+/,$keystr,3);
	    $keykey = $k1." ".$k2; 
	    $keydata{"lines"}{$keykey} = $keydata;
	}
	
	if (!defined($keydata{"lines"}{$syskey})){
	    if (! $SkipSystemResponseNotInKey){
		print "Error: Spurious system key '$syskey'\n" if ($main::Vb > 0);
		$syserrors++;
	    }
	    $skipped ++;
	    next;
	}

	### add the trail to the trial data!!!!!
	($keyeval, $keyblock) = split(/\s+/,$keydata{"lines"}{$syskey});

	### Decide if this trial is evaluable
	if ($keyeval ne "OTHER"){
	    if ($keyeval eq "TARGET"){
		$attr = "TARG";
	    } else {
		$attr = "NONTARG";
	    }

	    ### init the structure
	    if (! defined($rh_trial_data->{"trials"}{$keyblock}{"title"})){
		$rh_trial_data->{"trials"}{$keyblock}{"TARG"} = [];
		$rh_trial_data->{"trials"}{$keyblock}{"NONTARG"} = [];
		$rh_trial_data->{"trials"}{$keyblock}{"title"} = "$keyblock";
		$rh_trial_data->{"trials"}{$keyblock}{"YES TARG"} = 0;
		$rh_trial_data->{"trials"}{$keyblock}{"NO TARG"} = 0;
		$rh_trial_data->{"trials"}{$keyblock}{"YES NONTARG"} = 0;
		$rh_trial_data->{"trials"}{$keyblock}{"NO NONTARG"} = 0;
	    }
	    
	    ## update the counts
	    push(@{ $rh_trial_data->{"trials"}{$keyblock}{$attr} }, $sysscore);
	    $rh_trial_data->{"trials"}{$keyblock}{$sysdecision." $attr"} ++;
	    
	    ## Write the detail file
	    print DETAIL "<trial doc1=\"$k1\" doc2=\"$k2\" truth=\"$keyeval\" topic=\"$keyblock\"><simplemodel decision=\"$sysdecision\" score=\"$sysscore\"/></trial>\n"  if ($DetailFile ne "");

	    if ($main::Vb == 1 && ++$syslines % 10000 == 0){ print "."; &flush(*STDOUT); }
	}

	### OK, delete the key line 
	delete($keydata{"lines"}{$syskey});
    }

    die "Aborting due to $syserrors errors!" if ($syserrors > 0);

    while($keystr = <$KEY>){
	$keystr =~ s/#.*$//;  next if ($keystr =~ /^\s*$/);
	($k1, $k2, $keydata) = split(/\s+/,$keystr,3);
	$keykey = $k1." ".$k2; 
	$keydata{"lines"}{$keykey} = $keydata;
    }
    my @missingkeys = keys %{ $keydata{"lines"} };
    if ($#missingkeys >= 0){
	die "Error: Incomplete System file.  Missing key(s) are:\n  ",join("\n  ",@missingkeys)."\n";
    }
    close $KEY;
    close $SYS;
    print DETAIL "</link>\n" if ($DetailFile ne "");
    close DETAIL if ($DetailFile ne "");
    if ($main::Vb == 1) { print "\n"; &flush(*STDOUT); }
    if ($main::Vb > 0){
	printf("    ... Loading Completed .... %d elapsed total seconds, %d trials",
	       time - $beg_time, $syslines);
	printf(", %d skipped trials", $skipped) if ($skipped > 0);
	print "\n";
    }	    
}

sub parse_sys_header{
    my ($rh_lnkinfo, $SYS) = @_;

    ### Read in the header 
    $_ = <$SYS>;
    $rh_lnkinfo->{'System_Output_Desc'} = "";
    if ($_ =~ /^#/) {
	### Save the description
	chop;
	($rh_lnkinfo->{'System_Output_Desc'} = $_) =~ s/^#\s*//;
	### Read until we find data
	while ($_ =~ /^#/){  $_ = <$SYS>;  }       
    }
	
    # parse the information line
    s/^\s+//;
    my ($System, $DefPeriod) = split;
    $rh_lnkinfo->{'System_Id'} = (defined($System) ? $System : "");
    $rh_lnkinfo->{'Deferral_Period'} = (defined($DefPeriod) ? $DefPeriod : "");

    printf STDERR "\nWarning: Illegal deferral period '$DefPeriod' != 1, 10 or 100\n" 
	if ($DefPeriod !~ /^(1|10|100)$/);
}

sub  parse_key_header{
    my ($rh_keydata, $line) = @_;

    my @head = split(/\s+/,$line);

    die("Illegal INDEX header line, first field '$head[0]' not '#'")
	if ($head[0] ne '#');
    print STDERR "\nWarning: INDEX header line, type field '$head[1]' not 'LINK_DETECTION'\n"
	if ($head[1] !~ /^(LINK_DETECTION)$/);
    $rh_keydata->{"key_eval_type"} = $head[1];
    $rh_keydata->{"lines"} = {};
}

sub Produce_SLD_Report{
    my ($rh_trial_data, $rh_lnkinfo, $ReportFile, 
	$CF_Ptarget, $CF_Cmiss, $CF_Cfa,
	$TW_min_DET_Pmiss, $TW_min_DET_Pfa, $TW_min_DET_Cost, $TW_min_DET_normCost,
	$SW_min_DET_Pmiss, $SW_min_DET_Pfa, $SW_min_DET_Cost, $SW_min_DET_normCost) = @_;
    my (@table) = ();
    my ($TW_Pmiss, $TW_Pfa, $TW_Cost, $TW_norm_Cost,
	$SW_Pmiss, $SW_Pfa, $SW_Cost, $SW_norm_Cost);
    my($taskid, $blockid, $DecisionID) =
       ($rh_trial_data->{"TaskID"},$rh_trial_data->{"BlockID"},
	$rh_trial_data->{"DecisionID"});

    if (! open(OUT,">$ReportFile")){
	die "Error: unable to open report file '$ReportFile'\n";
    }
    print "Writing Report to '$ReportFile'\n" if ($main::Vb > 0 && $ReportFile ne "-");

    if ($ReportFile ne "-" && $main::ATNIST){
	if ($main::ATNIST){  #### hack to keep perl from complaining about single use variable
	    print "Writing Report (EDES Format) to '$ReportFile.edes'\n"
		if ($main::Vb > 0 && $ReportFile ne "-");
	}
	EDES_set_file($ReportFile.".edes");
    }
    EDES_add_to_avalue("System",$rh_lnkinfo->{"System_Output"});

    #### Computations
        
    ### Dump Trial_data_report
    make_trial_data_report(\@table, $rh_trial_data, $CF_Ptarget, $CF_Cmiss, $CF_Cfa,
			   \$TW_Pmiss, \$TW_Pfa, \$TW_Cost, \$TW_norm_Cost,
			   \$SW_Pmiss, \$SW_Pfa, \$SW_Cost, \$SW_norm_Cost);

    #### The report


    print OUT "----------------------------------------";
    print OUT "---------------------------------------\n";
    print OUT "------------------  Detection Task Performance Report";
    print OUT "  ------------------\n";
    print OUT "\n";
    print OUT "Command line:   $CommandLine\n";
    print OUT "Execution Date: ".`date`;
    print OUT "\n";
    
    printf OUT ("%-40s P(Miss)           = %.4f\n","$DecisionID Weighted Link Detection:",
		$SW_Pmiss);
    printf OUT ("%-40s P(Fa)             = %.4f\n","",$SW_Pfa);
    printf OUT ("%-40s %s = %.4f\n","",
		sprintf("%-17s","C".$rh_trial_data->{"TaskID"}),$SW_Cost);
    printf OUT ("%-40s %s = %.4f\n","",
		sprintf("%-17s","Norm(C".$rh_trial_data->{"TaskID"}.")"),$SW_norm_Cost);
    printf OUT ("\n");

    printf OUT ("%-40s P(Miss)           = %.4f\n","$blockid Weighted Link Detection:",
		$TW_Pmiss);
    printf OUT ("%-40s P(Fa)             = %.4f\n","",
		$TW_Pfa);
    printf OUT ("%-40s %s = %.4f\n","",
		sprintf("%-17s","C".$rh_trial_data->{"TaskID"}),$TW_Cost);
    printf OUT ("%-40s %s*   = %.4f\n","",
		sprintf("%-14s","Norm(C".$rh_trial_data->{"TaskID"}.")"),$TW_norm_Cost);
    print OUT "\n";
    print OUT "  *   Primary Evaluation Metric\n";

    EDES_add_to_avalue($blockid,"All");
    EDES_print("Type","Stat", "Stat.name","TW P(Miss)", "Stat.value",$TW_Pmiss);
    EDES_print("Type","Stat", "Stat.name","TW P(Fa)", "Stat.value",$TW_Pfa);
    EDES_print("Type","Stat", "Stat.name","TW C$taskid", "Stat.value",$TW_Cost);
    EDES_print("Type","Stat", "Stat.name","TW Norm(C$taskid)","Stat.value",$TW_norm_Cost);
    EDES_print("Type","Stat", "Stat.name","SW P(Miss)", "Stat.value",$SW_Pmiss);
    EDES_print("Type","Stat", "Stat.name","SW P(Fa)", "Stat.value",$SW_Pfa);
    EDES_print("Type","Stat", "Stat.name","SW C$taskid", "Stat.value",$SW_Cost);
    EDES_print("Type","Stat", "Stat.name","SW Norm(C$taskid)", "Stat.value",$SW_norm_Cost);

    if ($TW_min_DET_Pmiss ne "NULL" || $SW_min_DET_Pmiss ne "NULL"){
	print OUT "\n";
	print OUT "DET Graph Minimum Detection Cost Analysis:\n";
	printf OUT ("     $DecisionID Weighted Minimum C$taskid = %.4f Norm(C$taskid) = %.4f at P(Miss) = %.4f and P(Fa) = %.4f\n",
		    $SW_min_DET_Cost, $SW_min_DET_normCost, $SW_min_DET_Pmiss, $SW_min_DET_Pfa) if ($SW_min_DET_Pmiss ne "NULL");
	printf OUT ("     $blockid Weighted Minimum C$taskid = %.4f Norm(C$taskid) = %.4f at P(Miss) = %.4f and P(Fa) = %.4f\n", 
		    $TW_min_DET_Cost, $TW_min_DET_normCost, $TW_min_DET_Pmiss, $TW_min_DET_Pfa)  if ($TW_min_DET_Pmiss ne "NULL");
	EDES_print("Type","Stat", "Stat.name","TW Min DET P(miss)", "Stat.value",$TW_min_DET_Pmiss);
	EDES_print("Type","Stat", "Stat.name","TW Min DET P(fa)", "Stat.value",$TW_min_DET_Pfa);
	EDES_print("Type","Stat", "Stat.name","TW Min DET C$taskid","Stat.value",$TW_min_DET_Cost);
	EDES_print("Type","Stat", "Stat.name","TW Min DET Norm(C$taskid)","Stat.value",$TW_min_DET_normCost);
	EDES_print("Type","Stat", "Stat.name","SW Min DET P(miss)", "Stat.value",$SW_min_DET_Pmiss);
	EDES_print("Type","Stat", "Stat.name","SW Min DET P(fa)", "Stat.value",$SW_min_DET_Pfa);
	EDES_print("Type","Stat", "Stat.name","SW Min DET C$taskid","Stat.value",$SW_min_DET_Cost);
	EDES_print("Type","Stat", "Stat.name","SW Min DET Norm(C$taskid)","Stat.value",$SW_min_DET_normCost);
    }
    EDES_delete_from_avalue($blockid);

    print OUT "\n";
    tabby(*OUT,\@table,"l",2,"   ");
    printf OUT ("\n");
    printf OUT ("\n");

    print OUT "Key File:                ".$rh_lnkinfo->{"keyfilename"}."\n";
    print OUT "System Output File:      ".$rh_lnkinfo->{"System_Output"}."\n";
    print OUT "Cost Function Parameters:\n";
    print OUT "              Ptarget  = $CF_Ptarget\n";
    print OUT "              Cmiss    = $CF_Cmiss\n";
    print OUT "              Cfa      = $CF_Cfa\n";
    print OUT "\n";
    print OUT "Utility Measure Parameters:\n";
    print OUT "              Wrel     = $UT_wtrel\n";
    print OUT "              Umin     = $UT_min\n";
    print OUT "\n";
    print OUT "Detection Performance Calculations:\n";
    print OUT "    System Identifier:   ".$rh_lnkinfo->{"System_Id"}."  ";
    print OUT " Description: '".$rh_lnkinfo->{"System_Output_Desc"}."'"
	if ($rh_lnkinfo->{"System_Output_Desc"} ne "");
    print OUT "\n";
    print OUT "    Deferral Period:     ".$rh_lnkinfo->{"Deferral_Period"}."\n";
    print OUT "\n";

}

sub numer {$a cmp $b; }

sub make_trial_data_report{
    my($ra_tab, $rh_trial_data, $CF_Ptarget, $CF_Cmiss, $CF_Cfa,
       $r_TW_Pmiss, $r_TW_Pfa, $r_TW_Cost, $r_TW_norm_Cost,
       $r_SW_Pmiss, $r_SW_Pfa, $r_SW_Cost, $r_SW_norm_Cost) = @_;
    my($k1, $k2);
     my($Pmiss, $Pfa, $Cost, $norm_Cost);
    my(@blks_cor_targ) = ();
    my(@blks_mis_targ) = ();
    my(@blks_cor_nontarg) = ();
    my(@blks_mis_nontarg) = ();
    my(@blks_Pmiss) = ();
    my(@blks_Pfa) = ();
    my(@blks_Cost) = ();
    my(@blks_norm_Cost) = ();
    my($taskid, $blockid, $DecisionID) =
	($rh_trial_data->{"TaskID"},$rh_trial_data->{"BlockID"},$rh_trial_data->{"DecisionID"});

    $k1 = "trials";

    push(@$ra_tab,
	 [ ("" ,    "| # Corr","# Miss","# Corr",  "# Fa",    "|| ",       "",     ""       ,"| Norm", "|| Utility", "Utility", "Utility"   ) ]);
    push(@$ra_tab,
	 [ ("$blockid","| $taskid","$taskid","! $taskid","! $taskid","|| P(Miss)","P(Fa)","C$taskid","| C$taskid","|| ","Normed","Scaled") ]);
    push(@$ra_tab,
	 [ ("-----","| ------","------","--------","--------","|| -------","-----","-------","| -------","|| -------","-------","-------") ]);
    
    my ($SUtility, $SnormUtility, $SscaleUtility);  # accumulate sums for utility scores
    my $nNonzeroTopics = 0;
    my $nTopics = 0;
    foreach $k2(sort numer (keys %{ $rh_trial_data->{$k1} })){
	
	# compute raw utility score for all cases
	my ($Utility, $normUtility, $scaleUtility);
	$Utility = ($UT_wtrel * $rh_trial_data->{$k1}{$k2}{"YES TARG"}) - $rh_trial_data->{$k1}{$k2}{"YES NONTARG"};
	$SUtility += $Utility;
	$nTopics++;

	# compute miss probability and normalized/scaled utility scores only when there are some target items
	my $nrel = $rh_trial_data->{$k1}{$k2}{"YES TARG"} + $rh_trial_data->{$k1}{$k2}{"NO TARG"};
	$Pfa = $rh_trial_data->{$k1}{$k2}{"YES NONTARG"} / 
	    ($rh_trial_data->{$k1}{$k2}{"YES NONTARG"} + $rh_trial_data->{$k1}{$k2}{"NO NONTARG"});
	if ($nrel != 0){
	    $Pmiss = $rh_trial_data->{$k1}{$k2}{"NO TARG"} / $nrel; 

	    # normalize and scale utility scores
	    $normUtility = $Utility / ($UT_wtrel * $nrel);
	    my $floorUtility = $normUtility > $UT_min ? $normUtility : $UT_min;
	    $scaleUtility = ( $floorUtility - $UT_min ) / ( 1 - $UT_min );

	    $Cost = detect_CF($Pmiss, $Pfa, $CF_Ptarget, $CF_Cmiss, $CF_Cfa);
	    $norm_Cost = norm_detect_CF($Pmiss, $Pfa, $CF_Ptarget, $CF_Cmiss, $CF_Cfa);

	    $nNonzeroTopics++;
	    $SnormUtility += $normUtility;
	    $SscaleUtility += $scaleUtility;

        } else {
	    $Pmiss = $UNDEF;
	    $Cost = $UNDEF;
	    $norm_Cost = $UNDEF;
	    $normUtility = $UNDEF;
	    $scaleUtility = $UNDEF;
	}

	push(@$ra_tab, [ ($k2,
			  sprintf("| %4d",$rh_trial_data->{$k1}{$k2}{"YES TARG"}),
			  sprintf("%4d",$rh_trial_data->{$k1}{$k2}{"NO TARG"}),
			  sprintf("%4d",$rh_trial_data->{$k1}{$k2}{"NO NONTARG"}),
			  sprintf("%4d",$rh_trial_data->{$k1}{$k2}{"YES NONTARG"}),
			  ($Pmiss eq $UNDEF ? sprintf("|| %4s",$UNDEF) : sprintf("|| %.4f",$Pmiss)),
			  sprintf("%.4f",$Pfa),
			  ($Cost eq $UNDEF ? sprintf("%4s",$UNDEF) : sprintf("%.4f",$Cost)),
			  ($norm_Cost eq $UNDEF ? sprintf("| %4s",$UNDEF) : sprintf("| %.4f",$norm_Cost)),
			  sprintf("|| %7d", $Utility),
			  ($normUtility eq $UNDEF ? sprintf("%7s", $UNDEF) : sprintf("%7.4f", $normUtility)),
			  ($scaleUtility eq $UNDEF ? sprintf("%7s", $UNDEF) : sprintf("%7.4f", $scaleUtility))
			  ) ] );

	EDES_add_to_avalue($blockid, $k2);
	EDES_print("Type","Stat", "Stat.name","# Corr $taskid", "Stat.value",$rh_trial_data->{$k1}{$k2}{"YES TARG"});
	EDES_print("Type","Stat", "Stat.name","# Miss $taskid", "Stat.value",$rh_trial_data->{$k1}{$k2}{"NO TARG"});
	EDES_print("Type","Stat", "Stat.name","# Corr ! $taskid", "Stat.value",$rh_trial_data->{$k1}{$k2}{"NO NONTARG"});
	EDES_print("Type","Stat", "Stat.name","# Fa ! $taskid", "Stat.value",$rh_trial_data->{$k1}{$k2}{"YES NONTARG"});
	EDES_print("Type","Stat", "Stat.name","P(Miss)", "Stat.value",$Pmiss);
	EDES_print("Type","Stat", "Stat.name","P(Fa)", "Stat.value",$Pfa);
	EDES_print("Type","Stat", "Stat.name","C$taskid", "Stat.value",$Cost);
	EDES_print("Type","Stat", "Stat.name","Norm(C$taskid)", "Stat.value",$norm_Cost);
	EDES_delete_from_avalue($blockid);

	push(@blks_cor_targ,$rh_trial_data->{$k1}{$k2}{"YES TARG"});
	push(@blks_mis_targ,$rh_trial_data->{$k1}{$k2}{"NO TARG"});
	push(@blks_cor_nontarg,$rh_trial_data->{$k1}{$k2}{"NO NONTARG"});
	push(@blks_mis_nontarg,$rh_trial_data->{$k1}{$k2}{"YES NONTARG"});
	push(@blks_Pmiss,$Pmiss) if ($Pmiss ne $UNDEF);
	push(@blks_Pfa,$Pfa);
	push(@blks_Cost,$Cost) if ($Pmiss ne $Cost);
	push(@blks_norm_Cost,$norm_Cost) if ($norm_Cost ne $UNDEF);
    }	
    push(@$ra_tab,
	 [ ("-----","| ------","------","--------","--------","|| -------","-----","-------","| -------", "|| -------", "-------", "-------") ]);
    push(@$ra_tab,[ ("Sums",
		 sprintf("| %4d", SUM(@blks_cor_targ)),
		 sprintf("%4d", SUM(@blks_mis_targ)),
		 sprintf("%4d", SUM(@blks_cor_nontarg)),
		 sprintf("%4d", SUM(@blks_mis_nontarg)),
		 "||", "", "", "|", "||", "", "" ) ] );
    $$r_SW_Pmiss = SUM(@blks_mis_targ) / (SUM(@blks_cor_targ) + SUM(@blks_mis_targ));
    $$r_SW_Pfa = SUM(@blks_mis_nontarg) / (SUM(@blks_cor_nontarg) + SUM(@blks_mis_nontarg));
    $$r_SW_Cost = detect_CF($$r_SW_Pmiss, $$r_SW_Pfa, $CF_Ptarget, $CF_Cmiss, $CF_Cfa);
    $$r_SW_norm_Cost = norm_detect_CF($$r_SW_Pmiss, $$r_SW_Pfa, $CF_Ptarget, $CF_Cmiss, $CF_Cfa);
    push(@$ra_tab,[ ("$DecisionID Weighted",
		 "|", "", "", "", 
		 sprintf("|| %.4f",$$r_SW_Pmiss),
		 sprintf("%.4f",$$r_SW_Pfa),
		 sprintf("%.4f",$$r_SW_Cost),
		 sprintf("| %.4f",$$r_SW_norm_Cost),
		    "||","","")] );
# sprintf("%6.1f", $rh_scores->{"#ontopic"} / $rh_scores->{"#topic"}),	
    $$r_TW_Pmiss     = MEAN(@blks_Pmiss);
    $$r_TW_Pfa       = MEAN(@blks_Pfa);
#    $$r_TW_Cost      = MEAN(@blks_Cost);
#    $$r_TW_norm_Cost = MEAN(@blks_norm_Cost);
    $$r_TW_Cost      = detect_CF($$r_TW_Pmiss, $$r_TW_Pfa, $CF_Ptarget, $CF_Cmiss, $CF_Cfa);;
    $$r_TW_norm_Cost = norm_detect_CF($$r_TW_Pmiss, $$r_TW_Pfa, $CF_Ptarget, $CF_Cmiss, $CF_Cfa);;

    # compute topic-weighted averages for utility scores
    my ($aveUtility, $aveNormUtility, $aveScaleUtility) = (0, 0, 0);
    $aveUtility = $SUtility / $nTopics;
    if ($nNonzeroTopics > 0) {
	$aveNormUtility = $SnormUtility / $nNonzeroTopics;
	$aveScaleUtility = $SscaleUtility / $nNonzeroTopics;
    } else {
	$aveNormUtility = $UNDEF;
	$aveScaleUtility = $UNDEF;
    }
   
    push(@$ra_tab,[ ("$blockid Weighted",
		     "|", "", "", "",
		     sprintf("|| %.4f",$$r_TW_Pmiss),
		     sprintf("%.4f",$$r_TW_Pfa),
		     sprintf("%.4f",$$r_TW_Cost),
		     sprintf("| %.4f",$$r_TW_norm_Cost),
		     sprintf("|| %7.2f", $aveUtility),
		     ($aveNormUtility eq $UNDEF) ? $UNDEF : sprintf("%7.4f", $aveNormUtility),
		     ($aveScaleUtility eq $UNDEF) ? $UNDEF : sprintf("%7.4f", $aveScaleUtility)
		     ) ] );

}
