#!/usr/bin/perl -w

require "flush.pl";
require "TDT3.pm";
use strict;

my $Expected_TDT3Version = "2.5";

my $Usage ="Usage: TDT3fsd.pl <Options> First_Story_File\n".
"TDT library Version: ".&TDT3pm_Version()."\n".
"Desc:  TDT3fsd.pl is the TDT3 First Stry Detection Task Evaluation software.\n".
"       It was designed to implement the test proceedures outlined\n".
"       in the 1998 TDT3 Evaluation Plan Version 1.8\n".
"Options\n".
"   -R Rootdir   -> Define the 'root' directory of the TDT3 Corpus as\n".
"                   originally released by the LDC\n".
"   -j reltable  -> Specify an alternative relavance table(s)\n".
"   -i Indexfile -> Define the NIST provided index file for the \n".
"                   Dectection task.\n".
"   -T 'topic-regexp' ->\n".
"                   Build the tracking indexes files for only those defined\n".
"                   in the PERL5 regular expression.  Otherwise, all possible\n".
"                   topics are used.  There are macros defined for topic sets,\n".
"                   they are: TDT98_Train, TDT98_DevTest, TDT98_EvalTest, and\n".
"                   TDT99_mul.  See the documentation for their replacements.\n".
"   -s           -> Run with all available speedups\n".
"   -v num       -> Set the verbose level to 'num'. Default 1\n".
"                   ==0 None, ==1 Normal, >5 Slight, >10 way too much\n".
"   -m func      -> Set the system output to story mapping function.  May be:\n".
"                   'majority' or 'impulse'.  Default is majority.\n".
"   -L           -> Print the loaded database and exit\n".
"   -P P(topic)  -> Use P(topic) in the cost function.  Default is 0.02\n".
"   -C Cmiss:Cfa -> Use 'Cmiss' and 'Cfa' as the cost o5f a miss and cost of a\n".
"                   false alarm in the cost function respectively.  Defaults are\n".
"                   1 and 0.1\n".
"   -k KeyFile   -> Dump the Computed FSD key to 'KeyFile'.  May not be the same\n".
"                   as used for -K.\n".
"   -K KeyFile   -> Rather than searching the TDT corpus to build an FSD Key, load\n".
"                   the 'KeyFile' and use it instead.  May not be the sane file as -k\n".
"   -r Report    -> write the summary report to the file 'Report'\n".
"   -D DetailFile -> Write a detailed report of the scoring.\n".
"   -E ExcludeFile -> Use the specified source file list to filter the\n".
"                   evaluable source files\n".
"   -o <LBL>     -> Treat topic labels 'LBL' as on-topic.  Default is 'YES' but\n".
"                   can be 'BRIEF+YES' or 'BRIEF'\n".
"   -d DETfile   -> filename root to write the DET file to.\n".
"      DET Plotting Options:\n".
"      -t title  -> title to use in DET plot, default is the command line\n".
"      -p        -> Produce an pooled DET line trace pooled over all decisions.\n".
"      -w        -> Produce a Topic Weighted DET line trace, averaged by topics.\n".
"                   The default plot printed\n".
"      -n        -> Add 90% confidence intervals for the topic-weighted DET plots\n".
"\n";

die ("Error: Expected version of TDT3.pm is ".&TDT3pm_Version()." not $Expected_TDT3Version")
    if ($Expected_TDT3Version ne &TDT3pm_Version());

#### Globals Variables #####
$main::Vb = 1;
##
my $Root = "";
my $Index = "";
my $Sysout; 
my $MapMethod = "majority";
my $CommandLine = $0." ".join(" ",@ARGV);
my $DumpData = 0;
my $CF_Ptopic = 0.02;
my $CF_Cmiss = 1;
my $CF_Cfa = 0.1;
#
my $DETFile = "";
my $DETTitle = "";
my $ReportFile = "-";
my $DetailFile="";
my $TopicRegexp = "";
my $UNDEF = "  --";
my $UNDEF2 = "--";
my $TW_min_DET_Pmiss = "NULL";
my $TW_min_DET_Pfa = "NULL";
my $TW_min_DET_Cfsd = "NULL";
my $TW_min_DET_normCfsd = "NULL";
my $SW_min_DET_Pmiss = "NULL";
my $SW_min_DET_Pfa = "NULL";
my $SW_min_DET_Cfsd = "NULL";
my $SW_min_DET_normCfsd = "NULL";
my $AlternateRelTables = "";
my $DET_pooled = 0;
my $DET_TrialWeighted = 1;
my $DET_TrialWeighted_90conf = 0;
my $Dump_KeyFile = "";
my $Load_KeyFile = "";
my $ExcludeSubsetFile = "";
my %OnTopicLabels = ("YES", 1);
############################

############################ Main ###########################
&ProcessCommandLine();


my(@IndexList) = ( $Index );
my %TDTref = &Load_Boundaries_Into_TDTRef($Root,\@IndexList,"FIRST_STORY",
					  Boundary_DTDs(), $ExcludeSubsetFile);
&Add_Topic_Into_TDTref(($AlternateRelTables eq "") ? TopicRelevance_FILEs() : [ split(/:/,$AlternateRelTables) ],
		       TopicRelevance_DTDs(), \%TDTref, "false");

#### Map then system output onto topic boundaries
&Detection_Map_Topics($Sysout, $Index, \%TDTref, $MapMethod);
&Verify_Complete_Test(\%TDTref, $Index, "");

compute_FSD_score(\%TDTref, $Index, $CF_Ptopic, $CF_Cmiss, $CF_Cfa, $Dump_KeyFile, $Load_KeyFile);

Produce_trial_ensemble_DET(\%{ $TDTref{"results"}{"Fsd_params"}{"scores"}{"trial_data"} },
			   $DETFile, $DETTitle, 
			   0, $DET_pooled, $DET_TrialWeighted, $DET_TrialWeighted_90conf,
			   $CF_Ptopic, $CF_Cmiss, $CF_Cfa,
			   \$TW_min_DET_Pmiss, \$TW_min_DET_Pfa, \$TW_min_DET_Cfsd, \$TW_min_DET_normCfsd,
			   \$SW_min_DET_Pmiss, \$SW_min_DET_Pfa, \$SW_min_DET_Cfsd, \$SW_min_DET_normCfsd)
    if ($DETFile ne "");

&Produce_FSD_Report(\%TDTref, \%{ $TDTref{"results"}{"Fsd_params"}{"scores"} }, $ReportFile,
		    $TW_min_DET_Pmiss, $TW_min_DET_Pfa, $TW_min_DET_Cfsd, $TW_min_DET_normCfsd,
		    $SW_min_DET_Pmiss, $SW_min_DET_Pfa, $SW_min_DET_Cfsd, $SW_min_DET_normCfsd);

&dump_TDTref(\%TDTref,$DetailFile) if ($DetailFile ne "");

printf "Successful Completion\n" if ($main::Vb > 0);

exit 0;

###################### End of main ############################

sub die_usage{  my($mesg) = @_;    print "$Usage";   
		die("Error: ".$mesg."\n");  }

sub ProcessCommandLine{
    require "getopts.pl";
    &Getopts('snwpLR:T:r:D:i:v:m:d:t:C:P:S:j:k:K:E:o:');

    ### So that automatic library checks can be made
    exit 0 if ($ARGV[0] eq "__CHECKLIB__");
    
    die_usage("Root Directory for LDC TDT Corpus Req'd") if (!defined($main::opt_R));
    die_usage("NIST Detection index file Req'd") if (!defined($main::opt_i));

    $Root = $main::opt_R;
    $Index = $main::opt_i;
    $main::Vb = $main::opt_v if (defined($main::opt_v));
    set_TDT3Fast($main::opt_s) if (defined($main::opt_s));
    $DumpData = $main::opt_L if (defined($main::opt_L));
    $ReportFile = $main::opt_r if (defined($main::opt_r));
    $DetailFile = $main::opt_D if (defined($main::opt_D));
    $AlternateRelTables = $main::opt_j if (defined($main::opt_j));
    $ExcludeSubsetFile = $main::opt_E if (defined($main::opt_E));
    die_usage("Error: -k and -K are identical.\n")
	if (defined($main::opt_k) && defined($main::opt_K) && $main::opt_k eq $main::opt_K);
    $Dump_KeyFile = $main::opt_k if (defined($main::opt_k));
    $Load_KeyFile = $main::opt_K if (defined($main::opt_K));
    if (defined($main::opt_T)){	
	$TopicRegexp = $main::opt_T;
	Convert_Topic_set_macros(\$TopicRegexp);
    }
    if (defined($main::opt_m)){
	die("Undefined map method '$main::opt_m'")
	    if ($main::opt_m !~ /^(majority|impulse)$/);
	$MapMethod = $main::opt_m;
    }
    if (defined($main::opt_P)){
	die "Error: P(topic) range is: 0 <= P(topic) <=1.0" 
	    if ($main::opt_P < 0.0 || $main::opt_P > 1.0);
	$CF_Ptopic = $main::opt_P;
    }
    if (defined($main::opt_C)){
	die "Mal-formed Miss/Fa Costs.  Must be formatted as <num>:<num> and both positive."
	    if ($main::opt_C !~ /^([\d]+|[\d]*\.[\d]+|[\d]+\.[\d]*):([\d]+|[\d]*\.[\d]+|[\d]+\.[\d]*)$/);
	($CF_Cmiss, $CF_Cfa) = ($1,$2);
    }
    if (defined($main::opt_d)){
	$DETFile = $main::opt_d;
	$DETTitle = $CommandLine;
	$DETTitle = $main::opt_t if (defined($main::opt_t));
	if (defined($main::opt_p)){
	    $DET_pooled = $main::opt_p;
	    $DET_TrialWeighted = (defined($main::opt_w) ? 1 : 0);
	    $DET_TrialWeighted_90conf = (defined($main::opt_n) ? 1 : 0);
	}
	$DET_TrialWeighted = 1 if (defined($main::opt_w));
	$DET_TrialWeighted_90conf = 1 if (defined($main::opt_n));
    } else {
	print STDERR "Warning: -t option ignored\n" if (defined($main::opt_t));
	print STDERR "Warning: -n option ignored\n" if (defined($main::opt_n));
    }
    if (defined($main::opt_o)){
	%OnTopicLabels = ();
	foreach $_(split(/\+/,$main::opt_o)){
	    $_ =~ tr/a-z/A-Z/;
	    die "Error: unknown topic label '$_' used in option '-o $main::opt_o'" if ($_ !~ /^(BRIEF|YES)$/);
	    $OnTopicLabels{$_} = 1;
	}
    }
    die_usage("Detection system output file Req'd") if ($#ARGV != 0);
    $Sysout = $ARGV[0];
}

sub Produce_FSD_Report{
    my($rh_TDTref, $rh_scores, $OutFile, $TW_min_DET_Pmiss, $TW_min_DET_Pfa, $TW_min_DET_Cfsd, $TW_min_DET_normCfsd, $SW_min_DET_Pmiss, $SW_min_DET_Pfa, $SW_min_DET_Cfsd, $SW_min_DET_normCfsd) = @_;

    if (! open(OUT,">$OutFile")){
	die "Error: unable to open report file '$OutFile'\n";
    }
    print "Writing Report to '$OutFile'\n" if ($main::Vb > 0 && $OutFile ne "-");
    if ($OutFile ne "-" && $main::ATNIST){
	if ($main::ATNIST){  #### hack to keep perl from complaining about single use variable
	    print "Writing Report (EDES Format) to '$OutFile.edes'\n"
		if ($main::Vb > 0 && $OutFile ne "-");
	}
	EDES_set_file($OutFile.".edes");
    }
    EDES_add_to_avalue("System",$rh_TDTref->{'results'}{'Fsd_params'}{'System'});

    print OUT "----------------------------------------";
    print OUT "---------------------------------------\n";
    print OUT "-------------  TDT First Story Detection Task Performance Report";
    print OUT "  ------------\n";
    print OUT "\n";
    print OUT "Command line:   $CommandLine\n";
    print OUT "Execution Date: ".`date`;
    print OUT "\n";
    
    printf OUT ("Story Weighted First Story Detection: P(Miss)       = %.4f\n",$rh_scores->{"SW_Pmiss"});
    printf OUT ("                                      P(Fa)         = %.4f\n",$rh_scores->{"SW_Pfa"});
    printf OUT ("                                      Cfsd          = %.4f\n",$rh_scores->{"SW_Cfsd"});
    printf OUT ("                                      (Cfsd)norm    = %.4f\n",$rh_scores->{"SW_normCfsd"});
    printf OUT ("\n");

    printf OUT ("Topic Weighted First Story Detection: P(Miss)       = %.4f\n",
		$rh_scores->{"TW_Pmiss"});
    printf OUT ("                                      P(Fa)         = %.4f\n",
		$rh_scores->{"TW_Pfa"});
    printf OUT ("                                      Cfsd          = %.4f\n",
		$rh_scores->{"TW_Cfsd"});
    printf OUT ("                                      (Cfsd)norm  * = %.4f\n",
		$rh_scores->{"TW_normCfsd"});
    print OUT "\n";
    print OUT "  *   Primary Evaluation Metric\n";

    EDES_add_to_avalue("Subset","Global");
    EDES_add_to_avalue("Topic","All");
    EDES_print("Type","Stat", "Stat.name","TW P(Miss)", "Stat.value",$rh_scores->{"TW_Pmiss"});
    EDES_print("Type","Stat", "Stat.name","TW P(Fa)", "Stat.value",$rh_scores->{"TW_Pfa"});
    EDES_print("Type","Stat", "Stat.name","TW Cfsd", "Stat.value",$rh_scores->{"TW_Cfsd"});
    EDES_print("Type","Stat", "Stat.name","TW Norm(Cfsd)", "Stat.value",$rh_scores->{"TW_normCfsd"});
    EDES_print("Type","Stat", "Stat.name","SW P(Miss)", "Stat.value",$rh_scores->{"SW_Pmiss"});
    EDES_print("Type","Stat", "Stat.name","SW P(Fa)", "Stat.value",$rh_scores->{"SW_Pfa"});
    EDES_print("Type","Stat", "Stat.name","SW Cfsd", "Stat.value",$rh_scores->{"SW_Cfsd"});
    EDES_print("Type","Stat", "Stat.name","SW Norm(Cfsd)", "Stat.value",$rh_scores->{"SW_normCfsd"});

    if ($TW_min_DET_Pmiss ne "NULL" || $SW_min_DET_Pmiss ne "NULL"){
	print OUT "\n";
	print OUT "DET Graph Minimum Cfsd Analysis:\n";
	printf OUT ("     Story Weighted Minimum Cfsd = %.4f Norm(Cfsd) = %.4f at P(Miss) = %.4f and P(Fa) = %.4f\n",
		    $SW_min_DET_Cfsd, $SW_min_DET_normCfsd, $SW_min_DET_Pmiss, $SW_min_DET_Pfa) if ($SW_min_DET_Pmiss ne "NULL");
	printf OUT ("     Topic Weighted Minimum Cfsd = %.4f Norm(Cfsd) = %.4f at P(Miss) = %.4f and P(Fa) = %.4f\n", 
		    $TW_min_DET_Cfsd, $TW_min_DET_normCfsd, $TW_min_DET_Pmiss, $TW_min_DET_Pfa)  if ($TW_min_DET_Pmiss ne "NULL");

	EDES_print("Type","Stat", "Stat.name","SW Min DET Cfsd", "Stat.value",$SW_min_DET_Cfsd);
	EDES_print("Type","Stat", "Stat.name","SW Min DET normCfsd", "Stat.value",$SW_min_DET_normCfsd);
	EDES_print("Type","Stat", "Stat.name","SW Min DET P(miss)", "Stat.value",$SW_min_DET_Pmiss);
	EDES_print("Type","Stat", "Stat.name","SW Min DET P(fa)", "Stat.value",$SW_min_DET_Pfa);
	EDES_print("Type","Stat", "Stat.name","TW Min DET Cfsd", "Stat.value",$TW_min_DET_Cfsd);
	EDES_print("Type","Stat", "Stat.name","TW Min DET normCfsd", "Stat.value",$TW_min_DET_normCfsd);
	EDES_print("Type","Stat", "Stat.name","TW Min DET P(miss)", "Stat.value",$TW_min_DET_Pmiss);
	EDES_print("Type","Stat", "Stat.name","TW Min DET P(fa)", "Stat.value",$TW_min_DET_Pfa);
    }
    EDES_delete_from_avalue("Topic");

    #### Build a topic Table
    print OUT "\n\nFirst Story Detection Performance Calculations:\n\n";
    tabby(*OUT,make_FSD_table($rh_scores),"l",2,"    ");
    print OUT "\n\n";

    write_details($rh_TDTref, *OUT);
    print OUT "\n";
    
    print OUT "----------------  End of TDT Detection Task Performance Report";
    print OUT "  ---------------\n";
    print OUT "----------------------------------------";
    print OUT "---------------------------------------\n";

    EDES_delete_from_avalue("Subset");
}

sub numer {$a <=> $b; }

sub make_FSD_table{
    my($rh_scores) = @_;
    my(@tab, $topic);
    @tab = ();

    push(@tab,
	 [ ("Ref." ,"",      "",         "| # Corr","# Miss","# Corr", "# Fa",   "|| ",       "",     "",     "(Cfsd)") ]);
    push(@tab,
	 [ ("Topic","# First","# !First","| First" ,"First", "! First","! First","|| P(Miss)","P(Fa)","Cfsd", "norm"  ) ]);
    push(@tab,
	 [ ("-----","-------","--------","| ------","-------","------","-------","|| -------","-----","----", "------") ]);
    foreach $topic(sort numer keys(%{$rh_scores->{"by_topic"}})){
	push(@tab, [ ($topic,
		      sprintf("%4d",$rh_scores->{"by_topic"}{$topic}{"#targ"}),
		      sprintf("%4d",$rh_scores->{"by_topic"}{$topic}{"#nontarg"}),
		      (($rh_scores->{"by_topic"}{$topic}{"#targ"} == 0) ? "|   $UNDEF2" :		       
		       sprintf("| %4d",
			       $rh_scores->{"by_topic"}{$topic}{"#targ"} - $rh_scores->{"by_topic"}{$topic}{"#miss"})),
		      (($rh_scores->{"by_topic"}{$topic}{"#targ"} == 0) ? "  $UNDEF2" :		       
		       sprintf("%4d",$rh_scores->{"by_topic"}{$topic}{"#miss"})),

		      (($rh_scores->{"by_topic"}{$topic}{"#nontarg"} == 0) ? "  $UNDEF2" :
		       sprintf("%4d",$rh_scores->{"by_topic"}{$topic}{"#nontarg"} - $rh_scores->{"by_topic"}{$topic}{"#fa"})),	
		      (($rh_scores->{"by_topic"}{$topic}{"#nontarg"} == 0) ? "  $UNDEF2" :		       
		       sprintf("%4d",$rh_scores->{"by_topic"}{$topic}{"#fa"})),	
		      sprintf("|| %".(($rh_scores->{"by_topic"}{$topic}{"Pmiss"} eq $UNDEF) ? "s" : ".4f"),
			      $rh_scores->{"by_topic"}{$topic}{"Pmiss"}),
		      sprintf("%".(($rh_scores->{"by_topic"}{$topic}{"Pfa"} eq $UNDEF) ? "s" : ".4f"),
			      $rh_scores->{"by_topic"}{$topic}{"Pfa"}),	
		      sprintf("%".(($rh_scores->{"by_topic"}{$topic}{"Cfsd"} eq $UNDEF) ? "s" : ".4f"),
			      $rh_scores->{"by_topic"}{$topic}{"Cfsd"}),	
		      sprintf("%".(($rh_scores->{"by_topic"}{$topic}{"normCfsd"} eq $UNDEF) ? "s" : ".4f"),
			      $rh_scores->{"by_topic"}{$topic}{"normCfsd"}) ) ] );

	EDES_add_to_avalue("Topic", $topic);
	EDES_print("Type","Stat", "Stat.name","# First", "Stat.value",
		   sprintf("%4d",$rh_scores->{"by_topic"}{$topic}{"#targ"}));
	EDES_print("Type","Stat", "Stat.name","# ! First", "Stat.value",
		   sprintf("%4d",$rh_scores->{"by_topic"}{$topic}{"#nontarg"}));
	EDES_print("Type","Stat", "Stat.name","# Corr First", "Stat.value",
		   ($rh_scores->{"by_topic"}{$topic}{"#targ"} == 0) ? "" : 
		   $rh_scores->{"by_topic"}{$topic}{"#targ"} - $rh_scores->{"by_topic"}{$topic}{"#miss"});
	EDES_print("Type","Stat", "Stat.name","# Miss First", "Stat.value",
		   ($rh_scores->{"by_topic"}{$topic}{"#targ"} == 0) ? "" : $rh_scores->{"by_topic"}{$topic}{"#miss"});
	EDES_print("Type","Stat", "Stat.name","# Corr ! First", "Stat.value",
		   ($rh_scores->{"by_topic"}{$topic}{"#nontarg"} == 0) ? "" : 
		   $rh_scores->{"by_topic"}{$topic}{"#nontarg"} - $rh_scores->{"by_topic"}{$topic}{"#fa"});
	EDES_print("Type","Stat", "Stat.name","# FA ! First", "Stat.value",
		   ($rh_scores->{"by_topic"}{$topic}{"#nontarg"} == 0) ? "" : $rh_scores->{"by_topic"}{$topic}{"#fa"});
	EDES_print("Type","Stat", "Stat.name","P(Miss)", "Stat.value",
		   ($rh_scores->{"by_topic"}{$topic}{"Pmiss"} eq $UNDEF) ? "" : $rh_scores->{"by_topic"}{$topic}{"Pmiss"});
	EDES_print("Type","Stat", "Stat.name","P(Fa)", "Stat.value",
		   ($rh_scores->{"by_topic"}{$topic}{"Pfa"} eq $UNDEF) ? "" : $rh_scores->{"by_topic"}{$topic}{"Pfa"});
	EDES_print("Type","Stat", "Stat.name","Cfsd", "Stat.value",
		   ($rh_scores->{"by_topic"}{$topic}{"Cfsd"} eq $UNDEF) ? "" : $rh_scores->{"by_topic"}{$topic}{"Cfsd"});
	EDES_print("Type","Stat", "Stat.name","Norm(Cfsd)", "Stat.value",
		   ($rh_scores->{"by_topic"}{$topic}{"normCfsd"} eq $UNDEF) ? "" : $rh_scores->{"by_topic"}{$topic}{"normCfsd"});
	EDES_delete_from_avalue("Topic"); 

    }
    push(@tab,
	 [ ("-----","-------","--------","| ------","-------","------","-------","|| -------","-----","----", "------") ]);
    push(@tab,[ ("Sums",
		 sprintf("%4d",$rh_scores->{"#targ"}),
		 sprintf("%4d",$rh_scores->{"#nontarg"}),
		 sprintf("| %4d",$rh_scores->{"#targ"} - $rh_scores->{"#miss"}),
		 sprintf("%4d",$rh_scores->{"#miss"}),
		 sprintf("%4d",$rh_scores->{"#nontarg"} - $rh_scores->{"#fa"}),	
		 sprintf("%4d",$rh_scores->{"#fa"}),	
		 "||", "", "" ) ] );
    push(@tab,[ ("Story Weighted",
		 "", "", "|", "", "", "",
		 sprintf("|| %.4f",$rh_scores->{"SW_Pmiss"}),
		 sprintf("%.4f",$rh_scores->{"SW_Pfa"}),	
		 sprintf("%.4f",$rh_scores->{"SW_Cfsd"}),	
		 sprintf("%.4f",$rh_scores->{"SW_normCfsd"}) ) ] );
# sprintf("%6.1f", $rh_scores->{"#ontopic"} / $rh_scores->{"#topic"}),	
    push(@tab,[ ("Topic Weighted",
		 "","",
		 sprintf("| %6.1f",$rh_scores->{"TW_cor_targ"}),
		 sprintf("%6.1f",$rh_scores->{"TW_#miss"}),	
		 sprintf("%6.1f",$rh_scores->{"TW_cor_nontarg"}),
		 sprintf("%6.1f",$rh_scores->{"TW_#fa"}),	
		 sprintf("|| %.4f",$rh_scores->{"TW_Pmiss"}),
		 sprintf("%.4f",$rh_scores->{"TW_Pfa"}),	
		 sprintf("%.4f",$rh_scores->{"TW_Cfsd"}),	
		 sprintf("%.4f",$rh_scores->{"TW_normCfsd"}) ) ] );
    \@tab;
}

sub write_details{
    my($rh_TDTref, $OUT) = @_;
    my(@kl) = (keys %{ $rh_TDTref->{'IndexList'} });

    print $OUT "LDC TDT Corpus Root Dir: ".$rh_TDTref->{'RootDir'}."\n";
    print $OUT "Index File:              ".$kl[0]."\n";
    print $OUT "System Output File:      ".
	$rh_TDTref->{'results'}{'Fsd_params'}{'System_Output'}."\n";
    print $OUT "Pointer Type:            ".
	$rh_TDTref->{'IndexList'}{$kl[0]}{'index_pointer_type'}."\n";
    print $OUT "Cost Function Parameters:\n";
    print $OUT "              P(topic) = $CF_Ptopic\n";
    print $OUT "              Cmiss    = $CF_Cmiss\n";
    print $OUT "              Cfa      = $CF_Cfa\n";
    print $OUT "\n";
    print $OUT "Detection Performance Calculations:\n";
    print $OUT "    System Identifier:   ".
	$rh_TDTref->{'results'}{'Fsd_params'}{'System'};
    print $OUT " '".$rh_TDTref->{'results'}{'Fsd_params'}{'Desc'}."'"
    if ($rh_TDTref->{'results'}{'Fsd_params'}{'Desc'} ne "");
    print $OUT "\n";
    print $OUT "    Deferral Period:     ".
	$rh_TDTref->{'results'}{'Fsd_params'}{'Deferral'}."\n";
    print $OUT "\n";

    print $OUT "System Output to Story Mapping Function:  '$MapMethod'\n";
}

#### Map then system output onto topic boundaries
sub Detection_Map_Topics{
    my($Sysout, $Index, $rh_TDTref, $MapMethod) = @_;
    my($inrec, $src, $pnt, $source);
    my(@HypPointers);
    my($System, $DefPeriod, $PointerType, $WithBoundary);
    my($last_point);
    my($topic, $decision, $score);

    print "Performing first story detection scoring on '$Sysout'.\n" if ($main::Vb > 0);
    print "   (one period printed per source file)\n" if ($main::Vb == 1);

    die("First Story Detection system output file '$Sysout' not found") 
	if (! -f $Sysout);
    $rh_TDTref->{'results'}{'Fsd_params'}{'System_Output'} = $Sysout;
    my $SYS = TDT_open($Sysout);

    ### Read in the header 
    $_ = <$SYS>;
    $rh_TDTref->{'results'}{'Fsd_params'}{'Desc'} = "";
    if ($_ =~ /^#/) {
	### Save the description
	chop;
	($rh_TDTref->{'results'}{'Fsd_params'}{'Desc'} = $_) =~ s/^#\s*//;
	### Read until we find data
	while ($_ =~ /^#/){  $_ = <$SYS>;  }       
    }
	
    # parse the information line
    s/^\s+//;
    ($System, $WithBoundary, $DefPeriod, $PointerType) = split;
    $PointerType =~ tr/a-z/A-Z/;
    $WithBoundary =~ tr/a-z/A-Z/;

    die("Illegal pointer type '$PointerType' != RECID or TIME") 
	if ($PointerType !~ /^(RECID|TIME)$/);
    die("System output Pointer type '$PointerType' but index file".
	" pointer type is '".
	$rh_TDTref->{"IndexList"}{$Index}{'index_pointer_type'}."'")
	if ($rh_TDTref->{"IndexList"}{$Index}{'index_pointer_type'} ne $PointerType);
    printf STDERR "Warning: Illegal deferral period '$DefPeriod' != 1, 10 or 100" 
	if ($DefPeriod !~ /^(1|10|100)$/);
    die("Illegal Boundary Knowledge indication '$WithBoundary' != YES or NO") 
	if ($WithBoundary !~ /^(YES|NO)$/);


    ### Set upt the scoring structure
    
    $rh_TDTref->{'results'}{'Fsd_params'}{'WithBoundary'} = $WithBoundary;
    $rh_TDTref->{'results'}{'Fsd_params'}{'n_source'} = 0;

    $rh_TDTref->{'results'}{'Fsd_params'}{'System'} = $System;
    $rh_TDTref->{'results'}{'Fsd_params'}{'Deferral'} = $DefPeriod;

    ### Let's Party, Read in data until the filename changes
    @HypPointers = ();
    push (@HypPointers, [ (0.0, 'NO', -1.0e+99, 'TDT3FSD_UNASSIGNED_TOPIC') ]);
    $last_point = 0.0;

    while (! eof($SYS)){
	($inrec = <$SYS>) =~ s/^\s+//;
	$inrec =~ s/#.*$//;
	next if ($inrec =~ /^\s*$/);
	($src, $pnt, $decision, $score) = split(/\s+/,$inrec);
	$decision =~ tr/a-z/A-Z/;
	die("Hard Decision not YES or NO '$inrec'") if ($decision !~ /^(NO|YES)$/);
	#### Translate the source name int an appropriate form
	$src =~ s:^.*/::;
	$src =~ s:\.mt(tkn|as[r0-9])$::;
	$src =~ s:\.(tkn|as[r0-9])$::;

	if ($#HypPointers == 0){
	    $source = $src;
	} elsif ($source ne $src){
	    &DetectSscore(\@HypPointers, $rh_TDTref, $source, $PointerType, $MapMethod, $.);
	    
	    @HypPointers = ();
 	    push (@HypPointers, [ (0.0, 'NO', -1.0e+99, 'TDT3FSD_UNASSIGNED_TOPIC') ]);
	    $source = $src;
	} else {
	    #### check for ascending order
	    if (($pnt - $last_point) < 0.00001){
		print STDERR "Warning: decisions for input file $src are not in ascending order\n";
	    }
	}
	push (@HypPointers, [ ($pnt, $decision, $score) ]);
	$last_point = $pnt;
    }
    if ($#HypPointers > -1){
	&DetectSscore(\@HypPointers, $rh_TDTref, $source, $PointerType, $MapMethod, $.);
    }	    
	
    print "\n" if ($main::Vb == 1); 

    close($SYS);
}


sub DetectSscore{
    my($ra_Hyp, $rh_TDTref, $source, $PointerType, $MapMethod, $line) = @_;
    my(@Ref) = ();
    my($sid, $eid, $origin);
    my($i, $t, %b, $addit);

    if ($main::Vb == 1){ print "."; &flush(*STDOUT); }
    if ($main::Vb > 5){
	print "Scoring '$source' $PointerType\n    Hypothesis:\n" if ($main::Vb > 5);
	for ($i=0; $i<=$#$ra_Hyp; $i++){
	    print "        ".join(" ",@{ $ra_Hyp->[$i] })."\n"; }
    }

    if (! defined($rh_TDTref->{'bsets'}{$source})){
	## First Check to see if there is an exclude set entry, ifso, cheerfully ignore 
	## the source file
	if (defined($rh_TDTref->{"ExcludeSSD"}{"source"}{$source})){
	    print "    Excluding source file '$source' from scoring\n" if ($main::Vb > 3);
	    return;
	}
	die("Source file '$source' not loaded from index.  Find matching index.");
    }
    
    ## Record the fact that we have scored this file
    if (defined($rh_TDTref->{'results'}{'Scored_files'}{$source})){
	die "Error: the source file '$source' appears at least twice in the system output".
	    " at lines ".$rh_TDTref->{'results'}{'Scored_files'}{$source}." and $line of the file";
    }
    $rh_TDTref->{'results'}{'Scored_files'}{$source} = $line;
    $rh_TDTref->{'results'}{'Fsd_params'}{'n_source'} ++;

    ### Extract the Reference Pointers
    if ($PointerType eq "RECID"){ $sid = 'Brecid'; $eid = 'Erecid'; $origin = 1 } 
    else { $sid = 'Bsec'; $eid = 'Esec'; $origin = 0;}

    foreach ($i=0; $i<= $#{ $rh_TDTref->{'bsets'}{$source}{'boundary'} }; $i++){
	$addit = 1;

	my ($rh_b) = $rh_TDTref->{'bsets'}{$source}{'boundary'}[$i];       

	&dump_boundary($rh_b) if ($main::Vb > 5);

	$addit = 0 if ($rh_b->{'doctype'} ne "NEWS");
	if ($addit == 1){
	    push(@Ref,[ ($rh_b->{$sid}, $rh_b->{$eid}, $rh_b->{'docno'} ) ] );		
	} elsif ($main::Vb > 5) {
	    print "Skipping Story:  "; &dump_boundary($rh_b); 
	}
    }

    if ($main::Vb > 5){
	print "    Reference:\n" if ($main::Vb > 5);
	for ($i=0; $i<=$#Ref; $i++){
	    print "        ".join(" ",@{ $Ref[$i] })."\n"; }
    }
    

    ### Mate the reference docid's to hyp topics
    for ($i=0; $i<=$#Ref; $i++){
	my(%th) = ();
	my $foo;
	($th{'score'}, $th{'decision'}, $foo, $th{'justify'}) =
	    &Find_system_score_for_doc($ra_Hyp,$Ref[$i][0],$Ref[$i][1], $origin,
				       $MapMethod, 'first_story');
	    
	$th{'docno'} = $Ref[$i][2];
	push ( @{ $rh_TDTref->{'results'}{'Fsd_params'}{'eval'} }, { %th } );
    }
}


sub compute_FSD_score{
    my($rh_TDTref, $ind_file, $CF_Ptopic, $CF_Cmiss, $CF_Cfa, $Dump_KeyFile, $Load_KeyFile) = @_;
    %{ $rh_TDTref->{"results"}{"Fsd_params"}{"key"} } = ();
    %{ $rh_TDTref->{"results"}{"Fsd_params"}{"hdoc"} } = ();
    %{ $rh_TDTref->{"results"}{"Fsd_params"}{"scores"} } = ();
    %{ $rh_TDTref->{"results"}{"Fsd_params"}{"scores"}{"trial_data"} } = ();

    my($rh_key) = \%{ $rh_TDTref->{"results"}{"Fsd_params"}{"key"} };
    my($rh_hdoc) = \%{ $rh_TDTref->{"results"}{"Fsd_params"}{"hdoc"} };
    my($rh_scores) = \%{ $rh_TDTref->{"results"}{"Fsd_params"}{"scores"} };
    my($rh_trial_data) = \%{ $rh_TDTref->{"results"}{"Fsd_params"}{"scores"}{"trial_data"} };

    ### initialize the trial_data
    $rh_trial_data->{"pooledtitle"} = "Story Weighted Curve";
    $rh_trial_data->{"trialweightedtitle"} = "Topic Weighted Curve";
    $rh_trial_data->{"is_poolable"} = 1;
    $rh_trial_data->{"TaskID"} = "FSD";
    $rh_trial_data->{"BlockID"} = "Topic";
    $rh_trial_data->{"DecisionID"} = "Story";

    print "Scoring the FSD Test\n" if ($main::Vb > 0);

    if ($Load_KeyFile eq ""){
	CreateFSDKey($rh_TDTref, $ind_file, $rh_key);
    } else {
	LoadFSDKey($rh_key, $Load_KeyFile);
    }
    DumpFSDKey($rh_key,$Dump_KeyFile) if ($Dump_KeyFile ne "");

    CreateHDOCKey($rh_TDTref, $rh_hdoc);
    
    ### Do the scoring!!!!
    Score_KEY_vs_HDOC($rh_key, $rh_hdoc, $rh_scores, $rh_trial_data, $CF_Ptopic, $CF_Cmiss, $CF_Cfa);
}

sub Score_KEY_vs_HDOC{
    my($rh_key, $rh_hdoc, $rh_scores, $rh_trial_data, $CF_Ptopic, $CF_Cmiss, $CF_Cfa) = @_;     
    
    my($topic, $dn, $attr);
    my($S_Pfa, $S_Pmiss, $S_Cfsd, $S_normCfsd) = (0, 0, 0, 0);
    my($nS_Pfa, $nS_Pmiss, $nS_Cfsd, $nS_normCfsd) = (0, 0, 0, 0);

    $rh_scores->{"#ontopic"} = 0;
    $rh_scores->{"#miss"} = 0;
    $rh_scores->{"#fa"} = 0;
    $rh_scores->{"#targ"} = 0;
    $rh_scores->{"#nontarg"} = 0;
    $rh_scores->{"#topic"} = 0;
    $rh_scores->{"CF_Ptopic"} = $CF_Ptopic;
    $rh_scores->{"CF_Cmiss"} = $CF_Cmiss;
    $rh_scores->{"CF_Cfa"} = $CF_Cfa;
    foreach $topic(sort(keys %$rh_key)){	
	if (!defined($rh_scores->{"by_topic"}{$topic})){
	    $rh_scores->{"by_topic"}{$topic}{"#ontopic"} = 0;
	    $rh_scores->{"by_topic"}{$topic}{"#miss"} = 0;
	    $rh_scores->{"by_topic"}{$topic}{"#fa"} = 0;
	    $rh_scores->{"by_topic"}{$topic}{"#nontarg"} = 0;
	    $rh_scores->{"by_topic"}{$topic}{"#targ"} = 0;
	    $rh_scores->{"#topic"} ++;
	    $rh_trial_data->{"trials"}{$topic}{"TARG"} = [];
	    $rh_trial_data->{"trials"}{$topic}{"NONTARG"} = [];
	    $rh_trial_data->{"trials"}{$topic}{"title"} = "Topic $topic";
	}
	$rh_scores->{"by_topic"}{$topic}{"#ontopic"} = 0;
   
	foreach $attr("TARG", "NONTARG"){
	    foreach $dn(0 .. $#{ $rh_key->{$topic}{$attr} }){
		die("Error: The following document was in the reference answer key, but not in the ".
		    "system output file\n    $attr docno=$rh_key->{$topic}{$attr}[$dn] for topic $topic")
		    if (!defined($rh_hdoc->{$rh_key->{$topic}{$attr}[$dn]}));
		
		$rh_scores->{"by_topic"}{$topic}{"#ontopic"} ++;
		$rh_scores->{"#ontopic"}++;
		
		push(@{ $rh_trial_data->{"trials"}{$topic}{$attr} },
		     @{ $rh_hdoc->{$rh_key->{$topic}{$attr}[$dn]} }[1]);
		if ($attr eq "TARG"){
		    $rh_scores->{"by_topic"}{$topic}{"#targ"} ++;	
		    $rh_scores->{"#targ"}++;
		    if (@{ $rh_hdoc->{$rh_key->{$topic}{$attr}[$dn]} }[0] eq "NO"){
			$rh_scores->{"by_topic"}{$topic}{"#miss"} ++;	
			$rh_scores->{"#miss"}++;
		    }
		} else {
		    $rh_scores->{"by_topic"}{$topic}{"#nontarg"} ++;
		    $rh_scores->{"#nontarg"} ++;
		    if (@{ $rh_hdoc->{$rh_key->{$topic}{$attr}[$dn]} }[0] eq "YES"){
			$rh_scores->{"by_topic"}{$topic}{"#fa"} ++;
			$rh_scores->{"#fa"}++;	    
		    }
		}
	    }
	}
    }    

    ### Compute Story weighted stats
    $rh_scores->{"SW_Pmiss"} = $rh_scores->{"#miss"} / $rh_scores->{"#targ"};
    $rh_scores->{"SW_Pfa"} =   $rh_scores->{"#fa"}   / $rh_scores->{"#nontarg"};
    $rh_scores->{"SW_Cfsd"} = detect_CF($rh_scores->{"SW_Pmiss"}, $rh_scores->{"SW_Pfa"},
					$rh_scores->{"CF_Ptopic"}, $rh_scores->{"CF_Cmiss"},
					$rh_scores->{"CF_Cfa"});
    $rh_scores->{"SW_normCfsd"} = norm_detect_CF($rh_scores->{"SW_Pmiss"}, $rh_scores->{"SW_Pfa"},
						 $rh_scores->{"CF_Ptopic"}, $rh_scores->{"CF_Cmiss"},
						 $rh_scores->{"CF_Cfa"});

    ### Now,,,,, compute the needed statistics to a by_topic basis
    foreach $topic(keys %{$rh_scores->{"by_topic"}}){
	$rh_scores->{"by_topic"}{$topic}{"Pfa"} = ($rh_scores->{"by_topic"}{$topic}{"#nontarg"} == 0) ? $UNDEF :
	    $rh_scores->{"by_topic"}{$topic}{"#fa"} / $rh_scores->{"by_topic"}{$topic}{"#nontarg"};
	$rh_scores->{"by_topic"}{$topic}{"Pmiss"} = ($rh_scores->{"by_topic"}{$topic}{"#targ"} == 0) ? $UNDEF :
	    $rh_scores->{"by_topic"}{$topic}{"#miss"} / $rh_scores->{"by_topic"}{$topic}{"#targ"};
	$rh_scores->{"by_topic"}{$topic}{"Cfsd"} = 
	    ($rh_scores->{"by_topic"}{$topic}{"Pmiss"} eq $UNDEF ||
	     $rh_scores->{"by_topic"}{$topic}{"Pfa"} eq $UNDEF) ? $UNDEF :
		 detect_CF($rh_scores->{"by_topic"}{$topic}{"Pmiss"}, 
			   $rh_scores->{"by_topic"}{$topic}{"Pfa"},
			   $rh_scores->{"CF_Ptopic"}, $rh_scores->{"CF_Cmiss"},
			   $rh_scores->{"CF_Cfa"});	
	$rh_scores->{"by_topic"}{$topic}{"normCfsd"} = 
	    ($rh_scores->{"by_topic"}{$topic}{"Pmiss"} eq $UNDEF ||
	     $rh_scores->{"by_topic"}{$topic}{"Pfa"} eq $UNDEF) ? $UNDEF :
		 norm_detect_CF($rh_scores->{"by_topic"}{$topic}{"Pmiss"}, 
				$rh_scores->{"by_topic"}{$topic}{"Pfa"},
				$rh_scores->{"CF_Ptopic"}, $rh_scores->{"CF_Cmiss"},
				$rh_scores->{"CF_Cfa"});	
	if ($rh_scores->{"by_topic"}{$topic}{"Pfa"} ne $UNDEF){
	    $S_Pfa += $rh_scores->{"by_topic"}{$topic}{"Pfa"};
	    $nS_Pfa ++;
	}
	if ($rh_scores->{"by_topic"}{$topic}{"Pmiss"} ne $UNDEF){
	    $S_Pmiss += $rh_scores->{"by_topic"}{$topic}{"Pmiss"};
	    $nS_Pmiss ++;
	}
	if ($rh_scores->{"by_topic"}{$topic}{"Cfsd"} ne $UNDEF){
	    $S_Cfsd += $rh_scores->{"by_topic"}{$topic}{"Cfsd"}; 
	    $nS_Cfsd ++;
	}
	if ($rh_scores->{"by_topic"}{$topic}{"normCfsd"} ne $UNDEF){
	    $S_normCfsd += $rh_scores->{"by_topic"}{$topic}{"normCfsd"}; 
	    $nS_normCfsd ++;
	}
    }
    $rh_scores->{"TW_#fa"}   = $rh_scores->{"#fa"}   / $nS_Pfa;
    $rh_scores->{"TW_cor_nontarg"}=  ($rh_scores->{"#nontarg"} - $rh_scores->{"#fa"})  / $nS_Pfa;
    $rh_scores->{"TW_#miss"} = $rh_scores->{"#miss"} / $nS_Pmiss;
    $rh_scores->{"TW_cor_targ"} = ($rh_scores->{"#targ"} - $rh_scores->{"#miss"})  / $nS_Pmiss;
    $rh_scores->{"TW_Pmiss"} = $S_Pmiss / $nS_Pmiss;
    $rh_scores->{"TW_Pfa"}   = $S_Pfa / $nS_Pfa;
    $rh_scores->{"TW_Cfsd"}  = $S_Cfsd / $nS_Cfsd;
    $rh_scores->{"TW_normCfsd"}  = $S_normCfsd / $nS_normCfsd;
}

### Build a document decision hash table
### The structure is:  hdoc = { <docno> => (Actual_decision, score)
###                             <docno> => (Actual_decision, score) ... 
sub CreateHDOCKey{
    my($rh_TDTref, $rh_hdoc) = @_;
    my($i, $topic, $dn);

    print "    Building Hyp Doc List\n" if ($main::Vb > 0);

    my($ra_eval) = \@{ $rh_TDTref->{'results'}{'Fsd_params'}{'eval'} };
    for ($i=0; $i <= $#$ra_eval; $i++){
	$rh_hdoc->{$ra_eval->[$i]{"docno"}} = [ $ra_eval->[$i]{"decision"}, $ra_eval->[$i]{"score"} ];
    }
}


####  The rules for inclusion in the topic sets:
####  1: Include stories marked YES for two topics if the story is unambiguously 
####     a target or nontarget.  I.e.:
####       a) include the story if it is a target for all annotated topics
####       b) include the story if it is a non target for all annotated topics
sub CreateFSDKey{
    my($rh_TDTref, $ind_file, $rh_fsd_key) = @_;
    my($index_file, $file, $rh_bnd, @toplist, @levlist, $nyes, $ntarg);
    my($test_files) = 0;
    my($test_docs) = 0;

    print "    Building FSD key for $ind_file\n" if ($main::Vb > 0);

    ### Search for Topics (just like the tracking code!!!!)
    open(IND,$ind_file) || die("Failed to open fsd index '$ind_file'");
    while(<IND>){	
	my($t);
	next if ($_ =~ /^\#/ || $_ =~ /^\s*$/);
	chomp;
	$index_file = $_;
	($file = $index_file) =~ s:.*/(.*)\.[^.]+$:$1:;
	$test_files++;

	foreach $rh_bnd(@{ $TDTref{'bsets'}{$file}{'boundary'} }){
	    ### Work with ONLY news stories
	    next if ($rh_bnd->{'doctype'} ne "NEWS");
	    $test_docs++;

	    @toplist = @{ $rh_bnd->{'topicid'} }; 
	    @levlist = @{ $rh_bnd->{'t_level'} }; 

	    ### Only include data that's got a single YES!!!!
	    $nyes=$ntarg=0;
	    foreach $t(0 .. $#toplist){
		if (($TopicRegexp eq "" || $toplist[$t] =~ /^${TopicRegexp}$/) &&
		    (defined($OnTopicLabels{$levlist[$t]}))){
		    $nyes++;
		    $ntarg ++ if (!defined($rh_fsd_key->{$toplist[$t]}{"TARG"}));
		}
	    }

	    ### No YES's
	    next if ($nyes == 0);  

	    ### if there are targets and nontargets mixed, force there to be
	    ### NO target for those topics
	    ### and don't include the story in the topic set;
	    if ($ntarg != 0 && $ntarg < $nyes){
		foreach $t(0 .. $#toplist){
		    if (($TopicRegexp eq "" || $toplist[$t] =~ /^${TopicRegexp}$/) && 
			(defined($OnTopicLabels{$levlist[$t]}))){
			if (!defined($rh_fsd_key->{$toplist[$t]}{"TARG"})){
			    $rh_fsd_key->{$toplist[$t]}{"TARG"} = [];
			    $rh_fsd_key->{$toplist[$t]}{"NONTARG"} = [];
			}
		    }
		}
		next;
	    }

	    ### This is it, add it to the list
	    foreach $t(0 .. $#toplist){
		if (($TopicRegexp eq "" || $toplist[$t] =~ /^${TopicRegexp}$/) && 
		    (defined($OnTopicLabels{$levlist[$t]}))){
		    if (!defined($rh_fsd_key->{$toplist[$t]}{"TARG"})){
			push @{ $rh_fsd_key->{$toplist[$t]}{"TARG"}}, $rh_bnd->{'docno'};
			$rh_fsd_key->{$toplist[$t]}{"NONTARG"} = [];
		    } else {
			push @{ $rh_fsd_key->{$toplist[$t]}{"NONTARG"}}, $rh_bnd->{'docno'};
		    }
		}
	    }
	}
    }
    close(IND);

    ### There is a possibility that the code above WILL make a topic structure even though there is no 
    ### Targets and no Nontargets,  If this occurs, the remove the topic structure    
    foreach (sort(keys %$rh_fsd_key)){     
	delete($rh_fsd_key->{$_})
	    if ($#{ $rh_fsd_key->{$_}{"TARG"} } < 0 &&
		$#{ $rh_fsd_key->{$_}{"NONTARG"} } < 0);
    }    

    my $xxtop = 0; 
    my $nontarg = 0;
    my $targ = 0;
    foreach (sort(keys %$rh_fsd_key)){     
	$targ += $#{ $rh_fsd_key->{$_}{"TARG"} } + 1;
        $nontarg += $#{ $rh_fsd_key->{$_}{"NONTARG"} } + 1;
        $xxtop++;
    }    
    print "    ... The FSD key has $xxtop topics, $targ targets, $nontarg nontargets\n"
    if ($main::Vb > 0);

    die "Internal Error: Either there are not topics, or no target stories.\n".
        "                #test_files=$test_files, #test_docs=$test_docs"
        if ($xxtop == 0 || $targ == 0);
}

sub LoadFSDKey{
    my($rh_key,$Load_KeyFile) = @_;
    my($topic) = ("", "");

    print "    Loading FSD Key from '$Load_KeyFile'\n" if ($main::Vb > 0);
    open(KEY,"$Load_KeyFile") || die "Error: Unable to open FSD Key file '$Dump_KeyFile' for read";

    while(<KEY>){
	chomp;
	if ($_ =~ /<FSD_KEY/) {
	    next;
	} elsif ($_ =~ /<\/FSD_KEY/) {
	    next;
	} elsif ($_ =~ /<\/TOPIC/) {
	    die "Error: end TOPIC tag found before begin TOPIC" if ($topic eq "");
	    $topic = "";
	} elsif ($_ =~ /<TOPIC /) {
	    die "Error: Begin TOPIC tag found before closing tage for TOPIC id $topic"
		if ($topic ne "");
	    die "Error: mal-formed TOPIC tag '$_'" if ($_ !~ /<TOPIC id=(\S+)>/);
	    $topic = $1;
	} elsif ($_ =~ /<(TARG|NONTARG)_STORY/) {
	    die "Error: TARGET tag '$_' found before begin TOPIC tag" if ($topic eq "");
	    die "Error: mal-formed TARGET tag '$_'" if ($_ !~ /<(TARG|NONTARG)_STORY docno=(\S+)>/);
	    if (!defined($rh_key->{$topic}{"TARG"})){
		$rh_key->{$topic}{"TARG"} = [];
		$rh_key->{$topic}{"NONTARG"} = [];
	    }
	    push(@{ $rh_key->{$topic}{$1} }, $2);
	}
    }
    close KEY;
}


sub DumpFSDKey{
    my($rh_key,$Dump_KeyFile) = @_;
    my($topic,$dn);

    print "    Writing FSD Key to '$Dump_KeyFile'\n" if ($main::Vb > 0);
    open(KEY,">$Dump_KeyFile") || die "Error: Unable to open FSD Key file '$Dump_KeyFile' for write";

    print KEY "<FSD_KEY>\n";
    ### Write the key file
    foreach $topic(sort(keys %$rh_key)){     
	print KEY "<TOPIC id=$topic>\n";
	foreach ("TARG", "NONTARG"){
	    foreach $dn(0 .. $#{ $rh_key->{$topic}{$_} }){
		print KEY "<${_}_STORY docno=$rh_key->{$topic}{$_}[$dn]>\n";
	    }
	}
	print KEY "</TOPIC>\n";
    }    
    print KEY "</FSD_KEY>\n";
    close KEY;
}


