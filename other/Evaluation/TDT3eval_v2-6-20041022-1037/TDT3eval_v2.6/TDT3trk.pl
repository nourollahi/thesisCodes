#!/usr/bin/perl -w

require "flush.pl";
use strict;
require "TDT3.pm";
#require "/data/data2/TDT99/Software/TDT3eval_v1.3/TDT3-v1.pm";

### This changes the function of a runtime warning to dump a stack trace
use Carp ();  local $SIG{__WARN__} = \&Carp::cluck;

my $Expected_TDT3Version = "2.5";

my $Usage ="Usage: TDT3trk.pl <Options> Tracking_filelist\n".
"TDT library Version: ".&TDT3pm_Version()."\n".
"Desc:  TDT3trk.pl is the TDT3 Tracking Task Evaluation software.\n".
"       It was designed to implement the test proceedures outlined\n".
"       in the 1998 TDT3 Evaluation Plan Version 1.8.  The Tracking file\n".
"       list is a simple, newline separated list of output files each\n".
"       containing the output for a single topic.\n".
"Options\n".
"   -s           -> Run with all available speedups\n".
"   -R Rootdir   -> Define the 'root' directory of the TDT3 Corpus as\n".
"                   originally released by the LDC\n".
"   -j reltable  -> Specify an alternative relavance table(s)\n".
"   -I Indexfilelist -> Specifies a filename containing a list of TDT3\n".
"                   Tracking Task index files provided by NIST.  The file\n".
"                   is a simple, newline separated list of filenames\n".
"   -v num       -> Set the verbose level to 'num'. Default 1\n".
"                   ==0 None, ==1 Normal, >5 Slight, >10 way too much\n".
"   -m func      -> Set the system output to story mapping function.  May be:\n".
"                   'majority' or 'impulse'.  Default is majority.\n".
"   -P P(topic)  -> Use P(topic) in the tracking cost function.  Default is 0.02\n".
"   -C Cmiss:Cfa -> Use 'Cmiss' and 'Cfa' as the cost of a miss and cost of a\n".
"                   false alarm in the cost function respectively.  Defaults are\n".
"                   1 and 0.1\n".
"   -W Wrel      -> Use 'Wrel' as the weight of relevant stories in computing\n".
"                   the utility measure\n".
"   -M Umin      -> Use 'Umin' as the minimum normalized utility value\n".
"   -S           -> Skip system output files that do not exist in the index files\n".
### Not fully implemented
#"   -o <LBL>     -> Treat topic labels 'LBL' as on-topic.  Default is 'YES' but\n".
#"                   can be 'BRIEF+YES' or 'BRIEF'\n".
"   -U SSDFile   -> Use the Source File Definition file to compute performance\n".
"                   by source file subsets.\n".
"   -r Report    -> write the summary report to the file 'Report'\n".
"   -D DetailFile -> Write a detailed report of the scoring.\n".
"   -Q QCfile    -> Write intermediate result to the QCfile.{sys,key,col}.gz files\n".
"                   for input to the DetectionScore.pl program\n".
"   -Z UNCOMP    -> Define the uncompression command, it's typically 'zcat' or the\n".
"                   default 'gunzip'\n".
"   -E ExcludeFile -> Use the specified source file list to filter the\n".
"                   evaluable source files\n".
"   -d DETfile   -> filename root to write the DET file to.\n".
"      DET Plotting Options:\n".
"      -t title  -> title to use in DET plot, default is the command line\n".
"      -p        -> Produce an pooled DET plot rather than a DET plot\n".
"                   line for each output file included in 'Tracking_filelist'.\n".
"                   Default\n".
"      -e        -> Produce a DET line for each output file included in \n".
"                   'Tracking_filelist'.  Use -p to add the Pooled line \n".
"      -n        -> Produce 90% confidence interval to Topicweighted DET lines\n".
"      -w        -> Produce a Topic Weighted DET line, rather than  a DET line\n".
"                   for each output file in 'Tracking_filelist'.\n".
"      -a        -> Produce a minimum topic weighted DET plot in file 'DETfile.mindet.plt'.\n".  
"                   Options -d and -w are req'd\n".
"      -u 1|Many -> Also produce a DET plot for the subsets defined via the -U option.\n".
"                   The arguemnt '1' puts a single pooled or topic weighted DET line\n".
"                   into the plot for each subset, the 'Many' argument builts separate\n".
"                   plot files for each subset.  The root filename will be 'DETFile'_subsets\n".
"      -f        -> Force a pooled plot to be made even4 if Nt isn't constant\n".
"\n";

die ("Error: Expected version of TDT3.pm is ".&TDT3pm_Version()." not $Expected_TDT3Version")
    if ($Expected_TDT3Version ne &TDT3pm_Version());

#### Globals Variables #####
$main::Vb = 1;
###
my $Root = "";
my $Index = "";
my $DETFile = "";
my $SSDFile = "";
my $SSD_makeDET = "";
my $CommandLine = $0." ".join(" ",@ARGV);
my $Title = "";
my $DET_per_file = 0;
my $DET_pooled = 1;
my $DET_mindet = 0;
my $DET_TrialWeighted = 0;
my $DET_TrialWeighted_90conf = 0; 
my $ForcedPool = 0;
my $MapMethod = "majority";
my $CF_Ptopic = 0.02;
my $CF_Cmiss = 1;
my $CF_Cfa = 0.1;
my $UT_wtrel = 10;
my $UT_min = -0.5;
my $SkipExtraSys = 0;
my $ReportFile = "-";
my $DetailFile="";
my $TW_min_DET_Pmiss = "NULL";
my $TW_min_DET_Pfa = "NULL";
my $TW_min_DET_Ctrack = "NULL";
my $TW_min_DET_normCtrack = "NULL";
my $SW_min_DET_Pmiss = "NULL";
my $SW_min_DET_Pfa = "NULL";
my $SW_min_DET_Ctrack = "NULL";
my $SW_min_DET_normCtrack = "NULL";
my $AlternateRelTables = "";
my $QC_file = "";
my $UNDEF = "--";
my $Sysout = "";
my $ExcludeSubsetFile = "";
my %OnTopicLabels = ("YES", 1);
############################

############################ Main ###########################
&ProcessCommandLine();

my($start_time) = time;

my @IndexList = &Read_file_into_array($Index);

my %TDTref = &Load_Boundaries_Into_TDTRef($Root,\@IndexList,"TRACKING",
					  Boundary_DTDs(), $ExcludeSubsetFile);
$TDTref{'IndexFileList'} = $Index;
&Add_Topic_Into_TDTref((($AlternateRelTables eq "") ? 
			TopicRelevance_FILEs() : [ split(/:/,$AlternateRelTables) ]),
		       TopicRelevance_DTDs(), \%TDTref, "false");
&Tracking_Eval($Sysout, \%TDTref, $MapMethod, $SkipExtraSys);
&Write_QC_file(\%TDTref, $QC_file) if ($QC_file ne "");
&Tracking_Build_Subset_Map( \%TDTref, $SSDFile);

if ($DETFile ne ""){
    &Produce_Tracking_Combined_DET(\%TDTref, $DETFile, $Title,
				   $DET_per_file, $DET_pooled,
				   $DET_TrialWeighted, $DET_TrialWeighted_90conf, $ForcedPool,
				   $CF_Ptopic, $CF_Cmiss, $CF_Cfa,
				   \$TW_min_DET_Pmiss, \$TW_min_DET_Pfa,
				   \$TW_min_DET_Ctrack, \$TW_min_DET_normCtrack,
				   \$SW_min_DET_Pmiss, \$SW_min_DET_Pfa,
				   \$SW_min_DET_Ctrack, \$SW_min_DET_normCtrack);
    #### Experimental code, not released yet
    Produce_Minimum_DET(\%TDTref, $DETFile, $Title, $CF_Ptopic, $CF_Cmiss, $CF_Cfa)
	if ($DET_mindet == 1);
}

Produce_Subsetted_Tracking_Combined_DET(\%TDTref, $DETFile, $SSD_makeDET, $Title,
					$DET_per_file, $DET_pooled,
					$DET_TrialWeighted, $DET_TrialWeighted_90conf, $ForcedPool,
					$CF_Ptopic, $CF_Cmiss, $CF_Cfa)
    if ($SSD_makeDET ne "");

&Produce_Tracking_Report(\%TDTref, $CF_Ptopic, $CF_Cmiss, $CF_Cfa, 
			 $TW_min_DET_Pmiss, $TW_min_DET_Pfa, $TW_min_DET_Ctrack, $TW_min_DET_normCtrack,
			 $SW_min_DET_Pmiss, $SW_min_DET_Pfa, $SW_min_DET_Ctrack, $SW_min_DET_normCtrack,
			 $ReportFile);

&dump_TDTref(\%TDTref,$DetailFile) if ($DetailFile ne "");

printf(".... Total script time, %d elapsed seconds\n",time - $start_time) if ($main::Vb > 0);
printf "Successful Completion\n" if ($main::Vb > 0);

exit 0;

###################### End of main ############################



sub die_usage{  my($mesg) = @_;    print "$Usage";   
		die("Error: ".$mesg."\n");  }

sub ProcessCommandLine{
    require "getopts.pl";
    &Getopts('anwsSpefr:D:R:I:v:d:t:M:m:P:C:j:U:u:W:Z:Q:E:');

    ### So that automatic library checks can be made
    exit 0 if ($ARGV[0] eq "__CHECKLIB__");

    die_usage("Root Directory for LDC TDT Corpus Req'd") if (!defined($main::opt_R));
    $Root = $main::opt_R;
    
    die_usage("Tracking Index file list file Req'd") if (!defined($main::opt_I));
    $Index = $main::opt_I;
    
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

    # utility measure parameters
    $UT_wtrel = $main::opt_W if (defined($main::opt_W));
    $UT_min = $main::opt_M if (defined($main::opt_M));

    $main::Vb = $main::opt_v if (defined($main::opt_v));
    $ReportFile = $main::opt_r if (defined($main::opt_r));
    $DetailFile = $main::opt_D if (defined($main::opt_D));
    $QC_file= $main::opt_Q if (defined($main::opt_Q));
    $AlternateRelTables = $main::opt_j if (defined($main::opt_j));
    set_TDT3Fast($main::opt_s) if (defined($main::opt_s));
    $ExcludeSubsetFile = $main::opt_E if (defined($main::opt_E));
### Not fully implemented.  The non-YES stories should not get removed from
### the set of possible stories to be non-targets
#    if (defined($main::opt_o)){
#	%OnTopicLabels = ();
#	foreach $_(split(/\+/,$main::opt_o)){
#	    $_ =~ tr/a-z/A-Z/;
#	    die "Error: unknown topic label '$_' used in option '-o $main::opt_o'" if ($_ !~ /^(BRIEF|YES)$/);
#	    $OnTopicLabels{$_} = 1;
#	}
#    }
    if (defined($main::opt_Z)) {
	set_UncompressCommand($main::opt_Z);
	print "Uncompression command set to '$main::UncompressCommand'" if ($main::Vb > 5);
    }
    if (defined($main::opt_U)){
	$SSDFile = $main::opt_U;
	die "Error: SSD file '$SSDFile' not found" if (! -f $SSDFile);
    }

    if (defined($main::opt_d)){
	$DETFile = $main::opt_d;
	$Title = $CommandLine;
	$Title = $main::opt_t if (defined($main::opt_t));       

	$DET_pooled = (defined($main::opt_p) ? 1 : 0);
	$DET_per_file = (defined($main::opt_e) ||
			 (! defined($main::opt_w) &&
			  ! defined($main::opt_p))) ? 1 : 0; 

	if (defined($main::opt_w)){
	    $DET_TrialWeighted = (defined($main::opt_w) ? 1 : 0);
	    $DET_TrialWeighted_90conf = $main::opt_n if (defined($main::opt_n));
	    $DET_mindet = $main::opt_a if (defined($main::opt_a));	    
	} else {
	    print STDERR "Warning: -n option ignored without using -w\n" if (defined($main::opt_n));
	    print STDERR "Warning: -t option ignored without using -w\n" if (defined($main::opt_t));
	    print STDERR "Warning: -a option ignored without using -w\n" if (defined($main::opt_a));
	}
	$ForcedPool = 1 if (defined($main::opt_f));
	if (defined($main::opt_u)){
	    if ($SSDFile ne ""){
		($SSD_makeDET = $main::opt_u) =~ tr/a-z/A-Z/;
		die_usage "The argument of '-u' must be either 1 or many" 
		    if ($SSD_makeDET !~ /^(1|MANY)$/);
	    } else {
		print STDERR "Warning: -u argument ignored without the use of the -U argument\n" 
		    if (defined($main::opt_u));
	    }
	}
    } else {
	print STDERR "Warning: -t option ignored\n" if (defined($main::opt_t));
	print STDERR "Warning: -u option ignored\n" if (defined($main::opt_u));
	print STDERR "Warning: -p option ignored\n" if (defined($main::opt_p));
	print STDERR "Warning: -e option ignored\n" if (defined($main::opt_e));
	print STDERR "Warning: -f option ignored\n" if (defined($main::opt_f));
	print STDERR "Warning: -w option ignored\n" if (defined($main::opt_w));
	print STDERR "Warning: -a option ignored\n" if (defined($main::opt_a));
    }


    if (defined($main::opt_m)){
	die("Undefined map method '$main::opt_m'")
	    if ($main::opt_m !~ /^(majority|impulse)$/);
	$MapMethod = $main::opt_m;
    }
    $SkipExtraSys = $main::opt_S if (defined($main::opt_S));

    die_usage("Tracking system output file list Req'd") if ($#ARGV != 0);
    $Sysout = $ARGV[0];
}

sub source_all{
    1;
}

sub Build_trial_data_for_tracking{
    my($rh_TDTref, $ForcedPool, $rf_sourcefilt, $rh_sourcefilt_data) = @_;

    ### build target and non-targets
    ### This will be a structure of the form:
    ### trial_data = { pooledtitle  => "",
    ###                trialweightedtitle => "",
    ###                is_poolable  0|1,    Boolean, is a pooled plot allowed
    ###                trials => { <topicid> => { TARG => (NN,NN,NN,...)
    ###                                           NONTARG => (NN,NN,NN,...)
    ###                                           title => ""
    ###                                         }
    ###                            ....
    ###                          }
    ###              }
    my(%trial_data) = ();
    my(@Targ, @NonTarg);
    my(%Nts);
    my($i);
    $trial_data{'is_poolable'} = 1;

    for ($i=0; $i<=$#{ $TDTref{'results'}{'Trk_params'}{'eval'} }; $i++){
	my($rh_e,$ra_scores,$topicid, $j);
	my(%th);
	$topicid = $TDTref{'results'}{'Trk_params'}{'eval'}[$i]{'TargTopic'};
	
	$rh_e = \%{ $TDTref{'results'}{'Trk_params'}{'eval'}[$i] };
	$ra_scores = \@{ $TDTref{'results'}{'Trk_params'}{'eval'}[$i]{'scores'} };
	
	$Nts{$rh_e->{'TrainNTopic'}} = 1;
	
	@Targ = ();  @NonTarg = ();

	for ($j=0; $j <= $#{ $ra_scores }; $j++){
	    %th = split(/\0/,$ra_scores->[$j]);
	    
	    next if (&{ $rf_sourcefilt }($rh_TDTref, $rh_sourcefilt_data, \%th) == 0);

	    if ($th{'rtopic'} eq $rh_e->{'TargTopic'}){
		push(@Targ,$th{'score'});
	    } else {
		push(@NonTarg,$th{'score'});
	    }
	}
	$trial_data{'trials'}{$topicid}{'TARG'} = [ @Targ ];
	$trial_data{'trials'}{$topicid}{'NONTARG'} = [ @NonTarg ];
	$trial_data{'trials'}{$topicid}{'title'} = 
	    $rh_e->{'System_Name'}." topic=".$rh_e->{'TargTopic'}." Nt=".$rh_e->{'TrainNTopic'};
    }
    $trial_data{'pooledtitle'} = (defined($rh_sourcefilt_data->{"heading"}) ? 
				  $rh_sourcefilt_data->{"heading"}." " : "") . 
				      "Story Weighted Curve Nt=".join(",",keys %Nts);
    $trial_data{'trialweightedtitle'} = (defined($rh_sourcefilt_data->{"heading"}) ? 
				  $rh_sourcefilt_data->{"heading"}." " : "") . 
				      "Topic Weighted Curve Nt=".join(",",keys %Nts);
    $trial_data{"TaskID"} = "Tracking";
    $trial_data{"BlockID"} = "Topic";
    $trial_data{"DecisionID"} = "Story";
    ### Check to see if a pooled plot is permitted, if not forced!
    if ($ForcedPool != 1){
	my(@ntskey) = keys %Nts;
	$trial_data{'is_poolable'} = 0 if ($#ntskey != 0);
    }
    %trial_data
}

sub Produce_Tracking_Combined_DET{
    my($rh_TDTref, $DETFile, $Title, $PerFile, $Pooled, $TrialWeighted, $TrialWeighted_90conf, $ForcedPool, $CF_Ptopic, $CF_Cmiss, $CF_Cfa, $r_TW_min_DET_Pmiss, $r_TW_min_DET_Pfa, $r_TW_min_DET_Ctrack, $r_TW_min_DET_normCtrack, $r_SW_min_DET_Pmiss, $r_SW_min_DET_Pfa, $r_SW_min_DET_Ctrack, $r_SW_min_DET_normCtrack) = @_;
    my($beg_time) = time;

    my %data = ();
    my(%trial_data) = Build_trial_data_for_tracking($rh_TDTref, $ForcedPool, \&source_all, \%data);

    Produce_trial_ensemble_DET(\%trial_data, $DETFile, $Title,
			       $PerFile, $Pooled, $TrialWeighted, $TrialWeighted_90conf,
			       $CF_Ptopic, $CF_Cmiss, $CF_Cfa,
			       $r_TW_min_DET_Pmiss, $r_TW_min_DET_Pfa, $r_TW_min_DET_Ctrack, $r_TW_min_DET_normCtrack,
			       $r_SW_min_DET_Pmiss, $r_SW_min_DET_Pfa, $r_SW_min_DET_Ctrack, $r_SW_min_DET_normCtrack );

    printf("    .... DET plots generated, %d elapsed seconds\n",time - $beg_time) if ($main::Vb > 0);
}

sub Produce_Minimum_DET{
    my($rh_TDTref, $DETFile, $Title, $CF_Ptopic, $CF_Cmiss, $CF_Cfa) = @_;
    my($beg_time) = time;
    my ($x, $MinStyle);
    my ($TW_mDET_Pmiss, $TW_mDET_Pfa, $TW_mDET_Ctrack, $TW_mDET_normCtrack,
	$SW_mDET_Pmiss, $SW_mDET_Pfa, $SW_mDET_Ctrack, $SW_mDET_normCtrack);
    my ($d_line, $d_f, $d_col, $d_nt, $p_line, $p_f, $p_col, $p_cost);
    my ($color) = 2;

    printf("Starting Minimum DET plots.  This takes a while\n") if ($main::Vb > 0);

    ### Start the GNU plot file
    print "Writing Minumum DET plot to '${DETFile}.mindet.*'\n" if ($main::Vb > 0);
    open(NPLT,"> ${DETFile}.mindet.plt") ||
	die("unable to open DET gnuplot file ${DETFile}.mindet.plt");
    &write_gnuplot_DET_header(*NPLT, $Title, 0.01, 90, 1, 90);

    ### Include the Normal curve
    ($d_line, $d_f, $d_col, $d_nt) =
	GetLine($DETFile.".plt", "'([^']+)'\\s+using\\s+(\\S+)\\s+title\\s+'Topic Weighted Curve Nt=([^']+)'");
    ($p_line, $p_f, $p_col, $p_cost) =
	GetLine($DETFile.".plt", "'([^']+)'\\s+using\\s+(\\S+)\\s+title\\s+'TW Min DET Norm.Cost. = ([^']+)'");
    print NPLT ",\\\n   '$p_f' using $p_col title 'TW NT=$d_nt Min Norm(Cost) $p_cost' with linespoints $color";
    print NPLT ",\\\n   '$d_f' using $d_col notitle with lines $color";
    $color++;
    
    foreach $MinStyle("mean", "mean+shape", "mean+shape+oraclecost", "oraclecost"){
	my %data = ();
	my(%trial_data) = Build_trial_data_for_tracking($rh_TDTref, 1, \&source_all, \%data);
	
	Rescale_Trial_data(\%trial_data, $MinStyle, $CF_Ptopic, $CF_Cmiss, $CF_Cfa);

	Produce_trial_ensemble_DET(\%trial_data, $DETFile."_$MinStyle", $Title,
				   0, 0, 1, 0,
				   $CF_Ptopic, $CF_Cmiss, $CF_Cfa,
				   \$TW_mDET_Pmiss, \$TW_mDET_Pfa, \$TW_mDET_Ctrack, \$TW_mDET_normCtrack,
				   \$SW_mDET_Pmiss, \$SW_mDET_Pfa, \$SW_mDET_Ctrack, \$SW_mDET_normCtrack );
	($d_line, $d_f, $d_col, $d_nt) =
	    GetLine($DETFile."_$MinStyle.plt",
		    "'([^']+)'\\s+using\\s+(\\S+)\\s+title\\s+'Topic Weighted Curve Nt=([^']+)'");
	($p_line, $p_f, $p_col, $p_cost) =
	    GetLine($DETFile."_$MinStyle.plt",
		    "'([^']+)'\\s+using\\s+(\\S+)\\s+title\\s+'TW Min DET Norm.Cost. = ([^']+)'");
	print NPLT ",\\\n   '$p_f' using $p_col title 'Norm=$MinStyle Min Norm(Cost) $p_cost' with linespoints $color";
	print NPLT ",\\\n   '$d_f' using $d_col notitle with lines $color";
	$color++;
    }
    printf("    .... Minimum DET plots generated, %d elapsed seconds\n",time - $beg_time) if ($main::Vb > 0);
    print NPLT "\n";
    close NPLT;
}


sub source_subsetfilt{
    my ($rh_TDTref, $rh_sourcefilt_data, $rh_th) = @_;

    ### The $rh_th is a score judgment record
    ### THEREFORE, we need to lookup the filename from the document, then
    ### if the filename is in this set, use this judgement!!!!
    die "Failed to lookup fileid from docno '".$rh_th->{'docno'}."'" 
	if (!defined($rh_TDTref->{'docno2fileid'}{$rh_th->{'docno'}}));
    if (!defined($rh_sourcefilt_data->{'source'}{$rh_TDTref->{'docno2fileid'}{$rh_th->{'docno'}}})){
	return 0;
    }
    return 1;
}

sub Produce_Subsetted_Tracking_Combined_DET{
    my($rh_TDTref, $DETFile, $SSD_makeDET, $Title, $PerFile, $Pooled, $TrialWeighted, $TrialWeighted_90conf, $ForcedPool, $CF_Ptopic, $CF_Cmiss, $CF_Cfa) = @_;
    my($beg_time) = time;
    my $x = 0;
    my($set);
    my $SubsetDETFile;

    my($rh_c) = $rh_TDTref->{'results'}{'Trk_params'}{'subset_map'} ;
    return if ($rh_TDTref->{'results'}{'Trk_params'}{'subset_defined'} == 0);

    my(@trial_data_list) = ();
    
    foreach $set(sort(keys %$rh_c)){
	### Remove spaces from the filename
	my $rh_smap = $rh_TDTref->{'results'}{'Trk_params'}{'subset_map'}{$set};
	($SubsetDETFile = $DETFile." subset=".$rh_smap->{'heading'}) =~ s/\s+/_/g; 

	my(%trial_data) = Build_trial_data_for_tracking($rh_TDTref, $ForcedPool,
							\&source_subsetfilt, $rh_smap);
	
	if ($SSD_makeDET eq "MANY"){
	    Produce_trial_ensemble_DET(\%trial_data, $SubsetDETFile, $Title,
				       $PerFile, $Pooled, $TrialWeighted, $TrialWeighted_90conf,
				       $CF_Ptopic, $CF_Cmiss, $CF_Cfa, \$x, \$x, \$x, \$x, \$x, \$x);
	} else {
	    push(@trial_data_list, { %trial_data });
	}
    }
    ($SubsetDETFile = $DETFile." subsets") =~ s/\s+/_/g; 
    Produce_multi_trial_DET(\@trial_data_list, $SubsetDETFile, $Title,
			    $Pooled, $TrialWeighted, $CF_Ptopic, $CF_Cmiss, $CF_Cfa);
    
    printf("    .... DET plots generated, %d elapsed seconds\n",time - $beg_time) if ($main::Vb > 0);
}

sub Produce_Tracking_Report{
    my($rh_TDTref, $CF_Ptopic, $CF_Cmiss, $CF_Cfa, $TW_min_DET_Pmiss, $TW_min_DET_Pfa, $TW_min_DET_Ctrack, $TW_min_DET_normCtrack, $SW_min_DET_Pmiss, $SW_min_DET_Pfa, $SW_min_DET_Ctrack, $SW_min_DET_normCtrack, $OutFile) = @_;
    my(@tab) = ();
    my(@kl) = (keys %{ $TDTref{'IndexList'} });
    my($k);
    my($Scor_det, $Scor_ndet, $Snfa, $Snmiss, $Snd, $SPmiss, $SPfa, $nset_miss, $nset_fa) = 
	(0, 0, 0, 0, 0, 0, 0, 0, 0);
    my(%stats) = ();
    my($beg_time) = time;
    my (@Table) = ();
    my (@SubsetTable) = ();
    my $date = `date`;
    chomp ($date);


    print "Writing Report to '$OutFile'\n" if ($main::Vb > 0 && $OutFile ne "-");
    open(OUT,">$OutFile") || die "Error: unable to open report file '$OutFile'\n";

    if ($OutFile ne "-" && $main::ATNIST){
	if ($main::ATNIST){  #### hack to keep perl from complaining about single use variable
	    print "Writing Report (EDES Format) to '$OutFile.edes'\n"
		if ($main::Vb > 0 && $OutFile ne "-");
	}
	EDES_set_file($OutFile.".edes");
    }
    EDES_add_to_avalue("System",$TDTref{'results'}{'Trk_params'}{'eval'}[0]{'System_Name'});


    calc_table($rh_TDTref, \@Table, \$Scor_det, \$Scor_ndet, \$Snfa, \$Snmiss,
	       \$Snd, \$SPmiss, \$SPfa, \$nset_miss, \$nset_fa,
	       $CF_Ptopic, $CF_Cmiss, $CF_Cfa);

    calc_subset_table($rh_TDTref, \@SubsetTable, $CF_Ptopic, $CF_Cmiss, $CF_Cfa);

    print OUT "----------------------------------------";
    print OUT "---------------------------------------\n";
    print OUT "--------------------  TDT Tracking Task Performance Report";
    print OUT "  ------------------\n";
    print OUT "\n";
    print OUT "Command line:   $CommandLine\n";
    print OUT "Execution Date: $date\n";
    print OUT "\n";
    
    $stats{'SW_Pmiss'} = (($Scor_det + $Snmiss) == 0) ? $UNDEF : $Snmiss / ($Scor_det + $Snmiss);
    $stats{'SW_Pfa'}   = (($Scor_ndet + $Snfa) == 0) ? $UNDEF :  $Snfa / ($Scor_ndet + $Snfa);
    die "Error: Internal Error" if ($stats{'SW_Pfa'} eq $UNDEF || $stats{'SW_Pmiss'}  eq $UNDEF);
    $stats{'SW_Ctrack'}= &detect_CF($stats{'SW_Pmiss'}, $stats{'SW_Pfa'},
				    $CF_Ptopic, $CF_Cmiss, $CF_Cfa);
    $stats{'SW_normCtrack'}= &norm_detect_CF($stats{'SW_Pmiss'}, $stats{'SW_Pfa'},
					     $CF_Ptopic, $CF_Cmiss, $CF_Cfa);
    
    printf OUT ("Story Weighted (Pooled) Tracking: P(Miss)       = %.4f\n", $stats{'SW_Pmiss'});
    printf OUT ("                                  P(Fa)         = %.4f\n", $stats{'SW_Pfa'});
    printf OUT ("                                  Ctrack        = %.4f\n", $stats{'SW_Ctrack'});
    printf OUT ("                                  (Ctrack)norm  = %.4f\n", $stats{'SW_normCtrack'});
   
    $stats{'TW_Pmiss'} = $SPmiss / $nset_miss;
    $stats{'TW_Pfa'}   = $SPfa / $nset_fa;
    $stats{'TW_Ctrack'}= detect_CF($stats{'TW_Pmiss'},$stats{'TW_Pfa'},$CF_Ptopic,$CF_Cmiss,$CF_Cfa);
    $stats{'TW_normCtrack'}= norm_detect_CF($stats{'TW_Pmiss'},$stats{'TW_Pfa'},$CF_Ptopic,$CF_Cmiss,$CF_Cfa);

    print OUT "\n";
    printf OUT ("Topic Weighted Tracking:          P(Miss)       = %.4f\n", $stats{'TW_Pmiss'}); 
    printf OUT ("                                  P(Fa)         = %.4f\n", $stats{'TW_Pfa'});     
    printf OUT ("                                  Ctrack        = %.4f\n", $stats{'TW_Ctrack'});     
    printf OUT ("                         *        (Ctrack)norm  = %.4f\n", $stats{'TW_normCtrack'});     
    print OUT "\n";
    print OUT "  *   Primary Evaluation Metric\n";
    print OUT "\n";

    if ($TW_min_DET_Pmiss ne "NULL" || $SW_min_DET_Pmiss ne "NULL"){
	print OUT "DET Graph Minimum Ctrack Analysis:\n";
	printf OUT ("     Story Weighted Minimum Ctrack = %.4f Norm(Ctrack) = %.4f at P(Miss) = %.4f and P(Fa) = %.4f\n",
		    $SW_min_DET_Ctrack, $SW_min_DET_normCtrack, $SW_min_DET_Pmiss, $SW_min_DET_Pfa) if ($SW_min_DET_Pmiss ne "NULL");
	printf OUT ("     Topic Weighted Minimum Ctrack = %.4f Norm(Ctrack) = %.4f at P(Miss) = %.4f and P(Fa) = %.4f\n", 
		    $TW_min_DET_Ctrack, $TW_min_DET_normCtrack, $TW_min_DET_Pmiss, $TW_min_DET_Pfa) if ($TW_min_DET_Pmiss ne "NULL");
	print OUT "\n";

	EDES_print("Type","Stat", "Stat.name","SW Min DET Ctrack", "Stat.value",$SW_min_DET_Ctrack);
	EDES_print("Type","Stat", "Stat.name","SW Min DET normCtrack", "Stat.value",$SW_min_DET_normCtrack);
	EDES_print("Type","Stat", "Stat.name","SW Min DET P(miss)", "Stat.value",$SW_min_DET_Pmiss);
	EDES_print("Type","Stat", "Stat.name","SW Min DET P(fa)", "Stat.value",$SW_min_DET_Pfa);
	EDES_print("Type","Stat", "Stat.name","TW Min DET Ctrack", "Stat.value",$TW_min_DET_Ctrack);
	EDES_print("Type","Stat", "Stat.name","TW Min DET normCtrack", "Stat.value",$TW_min_DET_normCtrack);
	EDES_print("Type","Stat", "Stat.name","TW Min DET P(miss)", "Stat.value",$TW_min_DET_Pmiss);
	EDES_print("Type","Stat", "Stat.name","TW Min DET P(fa)", "Stat.value",$TW_min_DET_Pfa);
    }

    print OUT "Tracking Performance Calculations:\n";
    print OUT "\n";
    &tabby(*OUT,\@Table,'l',2,"    ");

    if ($rh_TDTref->{'results'}{'Trk_params'}{'subset_defined'}){
	print OUT "\n";
	print OUT "Tracking Performance by Test Subset:\n";
	print OUT "\n";
	&tabby(*OUT,\@SubsetTable,'l',2,"    "); 
	print OUT "\n";  
    }

    print OUT "\n";
    print OUT "Execution parameters:\n";
    print OUT "\n";
    write_details($rh_TDTref, $CF_Ptopic, $CF_Cmiss, $CF_Cfa, *OUT);

    print OUT "\n";
    
    print OUT "-----------------  End of TDT Tracking Task Performance Report";
    print OUT "  ---------------\n";
    print OUT "----------------------------------------";
    print OUT "---------------------------------------\n";

    close OUT;
    EDES_delete_from_avalue("System");

    ## Save off the statistics
    $TDTref{'results'}{'Trk_params'}{'stats'} = { %stats };

    printf("    .... Report generation concluded, %d elapsed seconds\n",time - $beg_time) if ($main::Vb > 0);
}

sub write_details{
    my($rh_TDTref, $CF_Ptopic, $CF_Cmiss, $CF_Cfa, $OUT) = @_;
    my(@kl) = (keys %{ $TDTref{'IndexList'} });
    my ($k);

    print OUT "LDC TDT Corpus Root Dir: ".$TDTref{'RootDir'}."\n";
    print OUT "Index File list:         ".$TDTref{'IndexFileList'}."\n";
    print OUT "    Index Files:             ".$kl[0]."\n";
    for ($k=1; $k<=$#kl; $k++){   
	print OUT "                             ".$kl[$k]."\n"; }
    print OUT "System Output File List: ".
	$TDTref{'results'}{'Trk_params'}{'System_Output_List'}."\n";
    for ($k=0; $k <= $#{ $TDTref{'results'}{'Trk_params'}{'eval'}}; $k++){
	print OUT "    System Output File:      ".
	    $TDTref{'results'}{'Trk_params'}{'eval'}[$k]{'System_Output'}.
 	    "  Name: ".
	    $TDTref{'results'}{'Trk_params'}{'eval'}[$k]{'System_Name'};
	print OUT "  Desc: ".
	    $TDTref{'results'}{'Trk_params'}{'eval'}[$k]{'System_Desc'}
	if ($TDTref{'results'}{'Trk_params'}{'eval'}[$k]{'System_Desc'} ne "");
	print OUT "\n";
    }
    print OUT "Pointer Type:            ".
	$TDTref{'IndexList'}{$kl[0]}{'index_pointer_type'}."\n";
    print OUT "\n";
    print OUT "Ctrack parameters:\n";
    print OUT "              P(topic) = $CF_Ptopic\n";
    print OUT "              Cmiss    = $CF_Cmiss\n";
    print OUT "              Cfa      = $CF_Cfa\n";
    print OUT "\n";
    print OUT "Utility parameters:\n";
    print OUT "              Wrel     = $UT_wtrel\n";
    print OUT "              Umin     = $UT_min\n";
}

sub calc_table{
    my($rh_TDTref, $ra_tab, $r_Scor_det, $r_Scor_ndet, $r_Snfa, $r_Snmiss,
       $r_Snd, $r_SPmiss, $r_SPfa, $r_nset_miss, $r_nset_fa, 
       $CF_Ptopic, $CF_Cmiss, $CF_Cfa) = @_;
    my($Pmiss, $Pfa, $Ctrack, $normCtrack, $i);

    # variables to compute average utility score
    my ($nTopics, $nNonzeroTopics, $SUtility, $SnormUtility, $SscaleUtility) = (0, 0, 0, 0, 0);

    EDES_add_to_avalue("Subset","Global");

    push(@$ra_tab, [ ('Filename', 'Topic', 'Train', 'Test',  'Corr',
		      'Corr',     'Miss',  'F/A',   'Pct.',  'Pct.',  'Ctrack', '(Ctrack)',
		      'Utility',  'Utility',  'Utility' ) ]);
    push(@$ra_tab, [ ('',         ''     , 'Story', 'Story', 'Det.', 
		      '! Det.',   'Story', 'Story', 'Miss',  'F/A',   '',       'norm',
                      '',         'Normed',     'Scaled' ) ]);
    push(@$ra_tab, [ ('--------', '-----', '-----', '------','------', 
		      '------',   '------','------','------','------','------', '--------',
		      '-------', '-------', '-------' ) ]);
    $$r_nset_miss = 0;
    $$r_nset_fa = 0;

    for ($i=0; $i<=$#{ $rh_TDTref->{'results'}{'Trk_params'}{'eval'} }; $i++){
	my(@rl);
	my($nd);
	my($rh_e) = \%{ $rh_TDTref->{'results'}{'Trk_params'}{'eval'}[$i] };
	my(%th, $cor_det, $cor_ndet, $nfa, $nmiss, $j);
	
	@rl = ();
	$nd = $#{ $rh_e->{'scores'} } + 1;
	$cor_det = $cor_ndet = $nfa = $nmiss = 0;
	for ($j=0; $j<= $#{ $rh_e->{'scores'} }; $j++){
	    %th = split(/\0/,$rh_e->{'scores'}[$j]);
	    if ($th{'decision'} eq "YES"){
		if ($th{'rtopic'} eq $rh_e->{'TargTopic'}){
		    $cor_det ++;
		} else {
		    $nfa ++;
		}
	    } else {
		if ($th{'rtopic'} eq $rh_e->{'TargTopic'}){
		    $nmiss ++;
		} else {
		    $cor_ndet ++;
		}
	    }
	}
	$Pmiss = ($cor_det + $nmiss == 0) ? $UNDEF : ($nmiss / ($cor_det + $nmiss));
	$Pfa = ($cor_ndet + $nfa == 0) ? $UNDEF : ($nfa / ($cor_ndet + $nfa));
	$Ctrack = ($Pmiss eq $UNDEF || $Pfa eq $UNDEF) ? $UNDEF :
	    &detect_CF($Pmiss, $Pfa, $CF_Ptopic, $CF_Cmiss, $CF_Cfa);
	$normCtrack = ($Pmiss eq $UNDEF || $Pfa eq $UNDEF) ? $UNDEF : 
	    &norm_detect_CF($Pmiss, $Pfa, $CF_Ptopic, $CF_Cmiss, $CF_Cfa);

	# compute utility score
	my $nrel = $cor_det + $nmiss;     # total relevant stories
	my ($Utility, $normUtility, $scaleUtility);
	$Utility = ($UT_wtrel * $cor_det) - $nfa;
	$SUtility += $Utility;
	$nTopics++;

	if ($nrel > 0) {
	    $normUtility = $Utility / ($UT_wtrel * $nrel);
	    my $floorUtility = $normUtility > $UT_min ? $normUtility : $UT_min;
	    $scaleUtility = ( $floorUtility - $UT_min ) / ( 1 - $UT_min ); 

	    # accumulate sums, used to compute means
	    $nNonzeroTopics++;
	    $SnormUtility += $normUtility;
	    $SscaleUtility += $scaleUtility;
	}
	else
	{
	    $normUtility = $UNDEF;
	    $scaleUtility = $UNDEF;
	}

	push(@rl, ($rh_e->{'System_Output'},
		   $rh_e->{'TargTopic'},
		   $rh_e->{'TrainNTopic'},
		   sprintf("%6d",$nd),
		   sprintf("%6d",$cor_det),
		   sprintf("%6d",$cor_ndet),
		   sprintf("%6d",$nmiss),
		   sprintf("%6d",$nfa),
		   ($Pmiss        eq $UNDEF) ? $UNDEF : sprintf("%.4f",$Pmiss),
		   ($Pfa          eq $UNDEF) ? $UNDEF : sprintf("%.4f",$Pfa),
		   ($Ctrack       eq $UNDEF) ? $UNDEF : sprintf("%.4f",$Ctrack),
		   ($normCtrack   eq $UNDEF) ? $UNDEF : sprintf("%.4f",$normCtrack),
		   sprintf("%6d",$Utility),
		   ($normUtility  eq $UNDEF) ? $UNDEF : sprintf("%7.4f",$normUtility),
		   ($scaleUtility eq $UNDEF) ? $UNDEF : sprintf("%7.4f",$scaleUtility)
		   ));

	push(@$ra_tab, [ @rl ]);

	$$r_Scor_det += $cor_det;
	$$r_Scor_ndet += $cor_ndet;
	$$r_Snfa += $nfa;
	$$r_Snmiss += $nmiss;
	$$r_Snd += $nd;

	if ($cor_det + $nmiss != 0){
	    $$r_nset_miss ++;
	    $$r_SPmiss += $Pmiss;
	}
	if ($cor_ndet + $nfa != 0){
	    $$r_nset_fa ++;
	    $$r_SPfa += $Pfa;
	}

	EDES_add_to_avalue("Topic",$rh_e->{'TargTopic'});
	EDES_print("Type","Stat","Stat.name","# Test Story","Stat.value", $nd);
	EDES_print("Type","Stat","Stat.name","# Corr Detect","Stat.value", $cor_det);
	EDES_print("Type","Stat","Stat.name","# Corr Not Detect","Stat.value", $cor_ndet);
	EDES_print("Type","Stat","Stat.name","# Miss","Stat.value", $nmiss);
	EDES_print("Type","Stat","Stat.name","# Fa","Stat.value", $nfa);
	EDES_print("Type","Stat","Stat.name","P(Miss)","Stat.value", $Pmiss);
	EDES_print("Type","Stat","Stat.name","P(Fa)","Stat.value", $Pfa);
	EDES_print("Type","Stat","Stat.name","Ctrack","Stat.value", $Ctrack);
	EDES_print("Type","Stat","Stat.name","Norm(Ctrack)","Stat.value", $normCtrack);
	EDES_delete_from_avalue("Topic");

    }
    
    push(@$ra_tab, [ ('========', '=====', '======', '======', '======',
		  '======', '======', '======',  '======', '======', '======', , '========',
		      '=======', '=======', '=======') ]); 
    push(@$ra_tab, [ ('Sums',     '',      '',       
		  sprintf("%6d",$$r_Snd),
		  sprintf("%6d",$$r_Scor_det),
		  sprintf("%6d",$$r_Scor_ndet),
		  sprintf("%6d",$$r_Snmiss),
		  sprintf("%6d",$$r_Snfa),
		  '', '') ]);
    EDES_print("Type","Stat", "Stat.name","# Test Story", "Stat.value",$$r_Snd);
    EDES_print("Type","Stat", "Stat.name","# Corr Detect", "Stat.value",$$r_Scor_det);
    EDES_print("Type","Stat", "Stat.name","# Corr Not Detect", "Stat.value",$$r_Scor_ndet);
    EDES_print("Type","Stat", "Stat.name","# Miss", "Stat.value",$$r_Snmiss);
    EDES_print("Type","Stat", "Stat.name","# Fa", "Stat.value",$$r_Snfa);
    my $SW_Pmiss = (($$r_Scor_det + $$r_Snmiss) == 0) ? $UNDEF : $$r_Snmiss / ($$r_Scor_det + $$r_Snmiss);
    my $SW_Pfa = (($$r_Scor_ndet + $$r_Snfa) == 0) ? $UNDEF :  $$r_Snfa / ($$r_Scor_ndet + $$r_Snfa);
    EDES_print("Type","Stat", "Stat.name","SW P(Miss)", "Stat.value",$SW_Pmiss);
    EDES_print("Type","Stat", "Stat.name","SW P(Fa)", "Stat.value",$SW_Pfa);		 
    EDES_print("Type","Stat", "Stat.name","SW Ctrack", "Stat.value",
	       &detect_CF($SW_Pmiss, $SW_Pfa, $CF_Ptopic, $CF_Cmiss, $CF_Cfa));
    EDES_print("Type","Stat", "Stat.name","SW Norm(Ctrack)", "Stat.value",
	       &norm_detect_CF($SW_Pmiss, $SW_Pfa, $CF_Ptopic, $CF_Cmiss, $CF_Cfa));

    push(@$ra_tab, [ ('Means',    '',      '',       
		      sprintf("%6d",$$r_Snd/($#{ $rh_TDTref->{'results'}{'Trk_params'}{'eval'} } + 1)),
		      sprintf("%6d",$$r_Scor_det/($#{ $rh_TDTref->{'results'}{'Trk_params'}{'eval'} } + 1)),
		      sprintf("%6d",$$r_Scor_ndet/($#{ $rh_TDTref->{'results'}{'Trk_params'}{'eval'} } + 1)),
		      sprintf("%6d",$$r_Snmiss/($#{ $rh_TDTref->{'results'}{'Trk_params'}{'eval'} } + 1)),
		      sprintf("%6d",$$r_Snfa/($#{ $rh_TDTref->{'results'}{'Trk_params'}{'eval'} } + 1)),
		      sprintf("%.4f",$$r_SPmiss / $$r_nset_miss),
		      sprintf("%.4f",$$r_SPfa / $$r_nset_fa),
		      sprintf("%.4f",&detect_CF($$r_SPmiss / $$r_nset_miss, $$r_SPfa / $$r_nset_fa,
						$CF_Ptopic, $CF_Cmiss, $CF_Cfa)),
		      sprintf("%.4f",&norm_detect_CF($$r_SPmiss / $$r_nset_miss, $$r_SPfa / $$r_nset_fa,
						     $CF_Ptopic, $CF_Cmiss, $CF_Cfa)),
		      sprintf("%7.2f",$SUtility / $nTopics),
		      ($nNonzeroTopics == 0) ? "$UNDEF" : sprintf("%7.4f",$SnormUtility / $nNonzeroTopics),
		      ($nNonzeroTopics == 0) ? "$UNDEF" : sprintf("%7.4f",$SscaleUtility / $nNonzeroTopics)
		  ) ]);
    EDES_print("Type","Stat", "Stat.name","TW # Test Story", "Stat.value",
	       $$r_Snd/($#{ $rh_TDTref->{'results'}{'Trk_params'}{'eval'} } + 1));
    EDES_print("Type","Stat", "Stat.name","TW # Corr Detect", "Stat.value",
	       $$r_Scor_det/($#{ $rh_TDTref->{'results'}{'Trk_params'}{'eval'} } + 1));
    EDES_print("Type","Stat", "Stat.name","TW # Corr Not Detect", "Stat.value",
	       $$r_Scor_ndet/($#{ $rh_TDTref->{'results'}{'Trk_params'}{'eval'} } + 1));
    EDES_print("Type","Stat", "Stat.name","TW # Miss", "Stat.value",
	       $$r_Snmiss/($#{ $rh_TDTref->{'results'}{'Trk_params'}{'eval'} } + 1));
    EDES_print("Type","Stat", "Stat.name","TW # Fa", "Stat.value",
	       $$r_Snfa/($#{ $rh_TDTref->{'results'}{'Trk_params'}{'eval'} } + 1));
    EDES_print("Type","Stat", "Stat.name","TW P(Miss)", "Stat.value",
	       $$r_SPmiss / $$r_nset_miss);
    EDES_print("Type","Stat", "Stat.name","TW P(Fa)", "Stat.value",
	       $$r_SPfa / $$r_nset_fa);
    EDES_print("Type","Stat", "Stat.name","TW Ctrack", "Stat.value",
	       &detect_CF($$r_SPmiss / $$r_nset_miss, $$r_SPfa / $$r_nset_fa, $CF_Ptopic, $CF_Cmiss, $CF_Cfa));
    EDES_print("Type","Stat", "Stat.name","TW Norm(Ctrack)", "Stat.value",
	       &norm_detect_CF($$r_SPmiss / $$r_nset_miss, $$r_SPfa / $$r_nset_fa, $CF_Ptopic, $CF_Cmiss, $CF_Cfa));
    EDES_delete_from_avalue("Subset");
}

sub calc_subset_table{
    my($rh_TDTref, $ra_tab, $CF_Ptopic, $CF_Cmiss, $CF_Cfa) = @_;
    my($Pmiss, $Pfa, $Ctrack, $normCtrack);
    my($rh_c) = $rh_TDTref->{'results'}{'Trk_params'}{'subset_map'} ;
    my($set);

    push(@$ra_tab, [ ('Subset', '|| Filename', 'Topic', 'Train', 'Test',  'Corr',
		      'Corr',     'Miss',  'F/A',   'Pct.',  'Pct.',  'Ctrack', '(Ctrack)') ]);
    push(@$ra_tab, [ ('',       '|| ',         ''     , 'Story', 'Story', 'Det.', 
		      '! Det.',   'Story', 'Story', 'Miss',  'F/A',   '',       'norm') ]);
    push(@$ra_tab, [ ('------', '|| --------', '-----', '-----', '------','------', 
		      '------',   '------','------','------','------','------', '--------') ]);

    foreach $set(keys %$rh_c ){
	my $Scor_det = 0;
	my $Scor_ndet = 0;
	my $Snfa = 0;
	my $Snmiss = 0;
	my $Snd = 0;
	my $SPmiss = 0;
	my $SPfa = 0;
	my $nset = 0;
	my $nset_miss = 0;
	my $nset_fa = 0;
	my $rh_smap = $rh_TDTref->{'results'}{'Trk_params'}{'subset_map'}{$set};
	my ($i);

	EDES_add_to_avalue("Subset",$rh_c->{$set}{'heading'});

	for ($i=0; $i<=$#{ $rh_TDTref->{'results'}{'Trk_params'}{'eval'} }; $i++){
	    my(@rl);
	    my($nd);
	    my($rh_e) = \%{ $rh_TDTref->{'results'}{'Trk_params'}{'eval'}[$i] };
	    my(%th, $j, $cor_det, $cor_ndet, $nfa, $nmiss);
	    
	    @rl = ();
	    $cor_det = $cor_ndet = $nfa = $nmiss = 0;
	    for ($j=0; $j<= $#{ $rh_e->{'scores'} }; $j++){
		%th = split(/\0/,$rh_e->{'scores'}[$j]);

		### Loop through the stories !!!  This is a list of story judgements.
		### THEREFORE, we need to lookup the filename from the document, then
		### if the filename is in this set, use this judgement!!!!
		die "Failed to lookup fileid from docno" 
		    if (!defined($rh_TDTref->{'docno2fileid'}{$th{'docno'}}));
		next if (!defined($rh_smap->{'source'}{$rh_TDTref->{'docno2fileid'}{$th{'docno'}}}));
		### End of subset filtration code

		$nd ++;
		if ($th{'decision'} eq "YES"){
		    if ($th{'rtopic'} eq $rh_e->{'TargTopic'}){
			$cor_det ++;
		    } else {
			$nfa ++;
		    }
		} else {
		    if ($th{'rtopic'} eq $rh_e->{'TargTopic'}){
			$nmiss ++;
		    } else {
			$cor_ndet ++;
		    }
		}
	    }
	    $Pmiss = ($cor_det + $nmiss == 0) ? $UNDEF : ($nmiss / ($cor_det + $nmiss));
	    $Pfa = ($cor_ndet + $nfa == 0) ? $UNDEF : ($nfa / ($cor_ndet + $nfa));
	    $Ctrack = ($Pmiss eq $UNDEF || $Pfa eq $UNDEF) ? $UNDEF :
		&detect_CF($Pmiss, $Pfa, $CF_Ptopic, $CF_Cmiss, $CF_Cfa);
	    $normCtrack = ($Pmiss eq $UNDEF || $Pfa eq $UNDEF) ? $UNDEF : 
		&norm_detect_CF($Pmiss, $Pfa, $CF_Ptopic, $CF_Cmiss, $CF_Cfa);
	    
	    push(@rl, ($rh_c->{$set}{'heading'} ,
		       "|| ".$rh_e->{'System_Output'},
		       $rh_e->{'TargTopic'},
		       $rh_e->{'TrainNTopic'},
		       sprintf("%6d",$nd),
		       sprintf("%6d",$cor_det),
		       sprintf("%6d",$cor_ndet),
		       sprintf("%6d",$nmiss),
		       sprintf("%6d",$nfa),
		       ($Pmiss      eq $UNDEF) ? $UNDEF : sprintf("%.4f",$Pmiss),
		       ($Pfa        eq $UNDEF) ? $UNDEF : sprintf("%.4f",$Pfa),
		       ($Ctrack     eq $UNDEF) ? $UNDEF : sprintf("%.4f",$Ctrack),
		       ($normCtrack eq $UNDEF) ? $UNDEF : sprintf("%.4f",$normCtrack)
		       ));
	    
	    push(@$ra_tab, [ @rl ]);
	    
	    $Scor_det += $cor_det;
	    $Scor_ndet += $cor_ndet;
	    $Snfa += $nfa;
	    $Snmiss += $nmiss;
	    $Snd += $nd;

	    if ($cor_det + $nmiss != 0){
		$nset_miss ++;
		$SPmiss += $Pmiss;
	    }
	    if ($cor_ndet + $nfa != 0){
		$nset_fa ++;
		$SPfa += $Pfa;
	    }

	    EDES_add_to_avalue("Topic",$rh_e->{'TargTopic'});
	    EDES_print("Type","Stat", "Stat.name","# Test Story", "Stat.value",$nd);
	    EDES_print("Type","Stat", "Stat.name","# Corr Detect", "Stat.value",$cor_det);
	    EDES_print("Type","Stat", "Stat.name","# Corr Not Detect", "Stat.value",$cor_ndet);
	    EDES_print("Type","Stat", "Stat.name","# Miss", "Stat.value",$nmiss);
	    EDES_print("Type","Stat", "Stat.name","# Fa", "Stat.value",$nfa);
	    EDES_print("Type","Stat", "Stat.name","P(Miss)", "Stat.value",$Pmiss);
	    EDES_print("Type","Stat", "Stat.name","P(Fa)", "Stat.value",$Pfa);
	    EDES_print("Type","Stat", "Stat.name","Ctrack", "Stat.value",$Ctrack);
	    EDES_print("Type","Stat", "Stat.name","Norm(Ctrack)", "Stat.value",$normCtrack);
	    EDES_delete_from_avalue("Topic");
	}
	
	$nset = $#{ $rh_TDTref->{'results'}{'Trk_params'}{'eval'} } + 1;
	
	push(@$ra_tab, [ ('======', '|| ========', '=====', '=====', '======','======', 
			  '======',   '======','======','======','======','======', '========') ]);
	push(@$ra_tab, [ ($rh_c->{$set}{'heading'}, '|| Sums',     '',      '',       
			  sprintf("%6d",$Snd),
			  sprintf("%6d",$Scor_det),
			  sprintf("%6d",$Scor_ndet),
			  sprintf("%6d",$Snmiss),
			  sprintf("%6d",$Snfa),
			  '', '') ]);
	push(@$ra_tab, [ ($rh_c->{$set}{'heading'}, '|| Means',    '',      '',       
			  sprintf("%6d",$Snd/$nset),
			  sprintf("%6d",$Scor_det/$nset),
			  sprintf("%6d",$Scor_ndet/$nset),
			  sprintf("%6d",$Snmiss/$nset),
			  sprintf("%6d",$Snfa/$nset),
			  sprintf("%.4f",$SPmiss / $nset_miss),
			  sprintf("%.4f",$SPfa / $nset_fa),
			  sprintf("%.4f",&detect_CF($SPmiss / $nset_miss, $SPfa / $nset_fa,
						    $CF_Ptopic, $CF_Cmiss, $CF_Cfa)),
			  sprintf("%.4f",&norm_detect_CF($SPmiss / $nset_miss, $SPfa / $nset_fa,
							 $CF_Ptopic, $CF_Cmiss, $CF_Cfa))
			  ) ]);
	push(@$ra_tab, [ () ]);
	push(@$ra_tab, [ () ]);

	$Pmiss = ($Scor_det + $Snmiss == 0) ? $UNDEF : ($Snmiss / ($Scor_det + $Snmiss));
	$Pfa = ($Scor_ndet + $Snfa == 0) ? $UNDEF : ($Snfa / ($Scor_ndet + $Snfa));
	$Ctrack = ($Pmiss eq $UNDEF || $Pfa eq $UNDEF) ? $UNDEF :
	    &detect_CF($Pmiss, $Pfa, $CF_Ptopic, $CF_Cmiss, $CF_Cfa);
	$normCtrack = ($Pmiss eq $UNDEF || $Pfa eq $UNDEF) ? $UNDEF : 
	    &norm_detect_CF($Pmiss, $Pfa, $CF_Ptopic, $CF_Cmiss, $CF_Cfa);
	EDES_print("Type","Stat", "Stat.name","# Test Story", "Stat.value",$Snd);
	EDES_print("Type","Stat", "Stat.name","# Corr Detect", "Stat.value",$Scor_det);
	EDES_print("Type","Stat", "Stat.name","# Corr Not Detect", "Stat.value",$Scor_ndet);
	EDES_print("Type","Stat", "Stat.name","# Miss", "Stat.value",$Snmiss);
	EDES_print("Type","Stat", "Stat.name","# Fa", "Stat.value",$Snfa);
	EDES_print("Type","Stat", "Stat.name","SW P(Miss)", "Stat.value",$SPmiss);
	EDES_print("Type","Stat", "Stat.name","SW P(Fa)", "Stat.value",$SPfa);		 
	EDES_print("Type","Stat", "Stat.name","SW Ctrack", "Stat.value",$Ctrack);
	EDES_print("Type","Stat", "Stat.name","SW Norm(Ctrack)", "Stat.value",$normCtrack);

	EDES_print("Type","Stat", "Stat.name","TW # Test Story", "Stat.value",$Snd/$nset);
	EDES_print("Type","Stat", "Stat.name","TW # Corr Detect", "Stat.value",$Scor_det/$nset);
	EDES_print("Type","Stat", "Stat.name","TW # Corr Not Detect", "Stat.value",$Scor_ndet/$nset);
	EDES_print("Type","Stat", "Stat.name","TW # Miss", "Stat.value",$Snmiss/$nset);
	EDES_print("Type","Stat", "Stat.name","TW # Fa", "Stat.value",$Snfa/$nset);
	EDES_print("Type","Stat", "Stat.name","TW P(Miss)", "Stat.value",$SPmiss / $nset_miss);
        EDES_print("Type","Stat", "Stat.name","TW P(Fa)", "Stat.value",$SPfa / $nset_fa);
	EDES_print("Type","Stat", "Stat.name","TW Ctrack", "Stat.value",
		   &detect_CF($SPmiss / $nset_miss, $SPfa / $nset_fa,
			      $CF_Ptopic, $CF_Cmiss, $CF_Cfa));
	EDES_print("Type","Stat", "Stat.name","TW Norm(Ctrack)", "Stat.value",
		   &norm_detect_CF($SPmiss / $nset_miss, $SPfa / $nset_fa,
				   $CF_Ptopic, $CF_Cmiss, $CF_Cfa));
	EDES_delete_from_avalue("Subset",$rh_c->{$set}{'heading'});
    }
}

sub Tracking_Eval{
    my($Sysout, $rh_TDTref, $MapMethod, $SkipExtraSys) = @_;
    my($atsfile);
    my($beg_time) = time;

    print "Performing Tracking scoring on system output file list '$Sysout'.\n" 
	if ($main::Vb > 0);

    die("List of Tracking output files '$Sysout' not found") 
	if (! -f $Sysout);

    $rh_TDTref->{'results'}{'Trk_params'}{'System_Output_List'} = $Sysout;
    foreach $atsfile(&Read_file_into_array($Sysout)){
	my $k;
	$atsfile =~ s/#.*$//;			  
	next if ($atsfile =~ /^(#.*|\s*)$/);

	print "    Reading tracking output file '$atsfile'.\n" if ($main::Vb > 0);

	### clean 0ut the status arrays for checking
	foreach $k(keys %{ $rh_TDTref->{'results'}{'Scored_files'} }){
	    delete $rh_TDTref->{'results'}{'Scored_files'}{$k};
	}
	&Score_topic($rh_TDTref,$atsfile, $MapMethod, $SkipExtraSys);
    }
    printf(".... Total evaluation time, %d elapsed seconds\n",time - $beg_time)
	if ($main::Vb > 0);
}

sub Score_topic {
    my($rh_TDTref, $Sysout, $MapMethod, $SkipExtraSys) = @_;
    my($k, $Index);
    my(%Trev) = ();
    my($last_point);
    my($beg_time) = time;
    my($is_first_source) = 1;

    printf("    Scoring topic file") if ($main::Vb > 0);
    print "\n" if ($main::Vb != 1);

    $Trev{'System_Output'} = $Sysout;
    if ($Sysout =~ /\.(Z|gz)$/){
	open(SYS,"$main::UncompressCommand < $Sysout |") || die("Unable to open compressed Tracking system ".
								"output file '$Sysout'");
    } else {
	open(SYS,$Sysout) || die("Unable to open Tracking system ".
				 "output file '$Sysout'");
    }
    ### Read in the header 
    $_ = <SYS>;
    $Trev{'System_Desc'} = "";
    if ($_ =~ /^#/) {
	### Save the description
	chop;
	($Trev{'System_Desc'} = $_) =~ s/^#\s*//;
	### Read until we find data
	while ($_ =~ /^#/){  $_ = <SYS>;  }       
    }
	
    # parse the information line
    s/^\s+//;
    my ($System, $Boundaries, $TrainNTopic, $TargTopic, $PointerType) = split;

    #### Interpret the target topic in the case of Nt=v
    if (length($TargTopic) == 7){
	my  $_t = sprintf("%02d",$TrainNTopic);
	if ($TargTopic =~ /^(\d\d\d\d\d)$_t$/){
	    $TrainNTopic = "Nt=$_t";
	    print "\n" if ($main::Vb == 1); 
	    print "    Interpreting Target Topic $TargTopic as Nt=V, Dividing into topic $1 $TrainNTopic\n"
		if ($main::Vb >= 1); 
	    $TargTopic = $1;
	}
    }

    $Boundaries =~ tr/a-z/A-Z/;
    die("Illegal Boundary indicator '$Boundaries' != YES or NO") 
	if ($Boundaries !~ /^(YES|NO)$/);

    $PointerType =~ tr/a-z/A-Z/;
    die("Illegal pointer type '$PointerType' != RECID, TIME, or DOCNO") 
	if ($PointerType !~ /^(RECID|TIME|DOCNO)$/);

    ### Make sure there's an index for this target topic!
    $Index = "";
    foreach $k(keys %{ $rh_TDTref->{'IndexList'} } ){
	if (defined($rh_TDTref->{'IndexList'}{$k}{'tracking_topic'}) &&
	    $rh_TDTref->{'IndexList'}{$k}{'tracking_topic'} eq $TargTopic){
	    $Index = $k; 
	    last;
	}
    }
    die("Unable to find topic index for topic '$TargTopic'") if ($Index eq "");
	
    if ($rh_TDTref->{"IndexList"}{$Index}{'index_pointer_type'} ne $PointerType
	&& $PointerType ne "DOCNO"){
       	print "Warning: System output Pointer type '$PointerType' but index file".
	    " pointer type is '".
		$rh_TDTref->{"IndexList"}{$Index}{'index_pointer_type'}."'";
    };

    print STDERR "Warning: The number of training stories '$TrainNTopic' != 1,2,4,8,16"
	if ($TrainNTopic !~ /^(1|2|4|8|16)$/);

    ### Set up the scoring structure

    $Trev{'System_Name'} = $System;
    $Trev{'WithBoundary'} = $Boundaries;
    $Trev{'TrainNTopic'} = $TrainNTopic;
    $Trev{'TargTopic'} = $TargTopic;

    if ($PointerType eq "DOCNO"){
	my %decision_lut = ();
	my $topic_entry;
	my ($src, $pnt, $decision, $score, $source, $i, $rh_bnd);

	### load the systems data in memory
	while (<SYS>){
	    $_ =~ s/#.*$//;
	    next if ($_ =~ /^\s*$/);
	    ($src, $pnt, $decision, $score) = split(/\s+/,$_);
	    $decision =~ tr/a-z/A-Z/;
	    $decision_lut{$pnt} = "score\0$score\0decision\0$decision";
	}
	### loop through the reference boundaries, adding to the decisions
	foreach $source (keys %{ $rh_TDTref->{'IndexList'}{$Index}{'contents'} }){
	    $rh_TDTref->{'results'}{'Scored_files'}{$source} = 1;

	    if ($main::Vb == 1){ print "."; &flush(*STDOUT); }
	    foreach ($i=0; $i<= $#{ $rh_TDTref->{'bsets'}{$source}{'boundary'} }; $i++){
		$rh_bnd = \%{ $rh_TDTref->{'bsets'}{$source}{'boundary'}[$i] };       
		if (is_EvaluableTracking($rh_TDTref, $rh_bnd, 'Brecid', $Index, \$topic_entry, $source,
					 $TargTopic)){
		    if (!defined($decision_lut{$rh_bnd->{'docno'}})){
			print "(Missing '".$rh_bnd->{'docno'}."' decision)";
			$decision_lut{$rh_bnd->{'docno'}} = "score\0-9E99\0decision\0NO";
		    }
			    
		    ### Make the entry  right place
		    push( @{ $Trev{'scores'} }, 
			  $decision_lut{$rh_bnd->{'docno'}}."\0".
			  "justify\0none\0".
			  "docno\0".$rh_bnd->{'docno'}."\0".
			  "rtopic\0".(($topic_entry >= 0) ? $rh_bnd->{'topicid'}[$topic_entry] : "n/a")."\0".
			  "sid\0".$rh_bnd->{'Brecid'}."\0".
			  "eid\0".$rh_bnd->{'Brecid'}."\0");
		}
	    }
	}
	print "\n" if ($main::Vb == 1); 
    } else { ### RECID or TIME
	### Let's Party, Read in data until the filename changes
	my @HypPointers = ();
	my ($inrec, $src, $pnt, $decision, $score, $source);

	$last_point = 0.0;
	push (@HypPointers, [ (0.0, "NO", -1.0e+99) ]);
	
	while (! eof(SYS)){
	    ($inrec = <SYS>) =~ s/^\s+//;
	    $inrec =~ s/#.*$//;
	    next if ($inrec =~ /^\s*$/);
	    ($src, $pnt, $decision, $score) = split(/\s+/,$inrec);
	    $decision =~ tr/a-z/A-Z/;
	    
	    #### Translate the source name into an appropriate form
	    $src =~ s:^.*/::;
	    $src =~ s:\.mt(tkn|as[r0-9])$::;
	    $src =~ s:\.(tkn|as[r0-9])$::;
	    
	    die("Hard Decision not YES or NO '$inrec'")
		if ($decision !~ /^(NO|YES)$/);
	    
	    if ($#HypPointers == 0){
		$source = $src;
	    } elsif ($source ne $src){
		##### The HypPointers Array gets destroyed during computations
		
		push( @{ $Trev{'scores'} }, 
		      &TrackSscore(\@HypPointers, $rh_TDTref, $source, $is_first_source, $PointerType,
			      $MapMethod, $Index, $TargTopic, $SkipExtraSys)); 	    
		$is_first_source = 0;
		@HypPointers = ();
		push (@HypPointers, [ (0.0, "NO", -1.0e+99) ]);
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
	##### The HypPointers Array gets destroyed during computations
	push( @{ $Trev{'scores'} }, 
	      &TrackSscore(\@HypPointers, $rh_TDTref, $source, $is_first_source, $PointerType,
			   $MapMethod, $Index, $TargTopic, $SkipExtraSys))
	    if ($#HypPointers > -1);	    
	print "\n" if ($main::Vb == 1); 
    }

    close(SYS);
    &Verify_Complete_Test($rh_TDTref, $Index,"        ");
    printf("    .... Scoring completed for topic file, %d elapsed seconds\n",
	   time - $beg_time ) if ($main::Vb > 0);

    push(@{ $rh_TDTref->{'results'}{'Trk_params'}{'eval'} }, { %Trev } );
}

sub is_EvaluableTracking{
    my ($rh_TDTref, $rh_bnd, $sid, $Index, $r_topic_entry, $source, $TargTopic) = @_;
    my ($addit, $tn);

    if ($main::Vb > 10) { print "Checking:  "; &dump_boundary($rh_bnd); }
    
    if ($rh_bnd->{$sid} ne "" &&
	($rh_bnd->{$sid} < $rh_TDTref->{'IndexList'}{$Index}{'contents'}{$source})){
	$addit = 0;
    } else {
	$addit = 1;
	$$r_topic_entry = -1;
	
	### Search the topics for a YES indicator
	for ($tn = 0; $tn <= $#{ $rh_bnd->{'topicid'} } ; $tn++){
	    if ($rh_bnd->{'topicid'}[$tn] eq $TargTopic){
		### Judge to be about the target topic, now ask if it's to be 
		### evaluated as on topic
		if (defined($OnTopicLabels{$rh_bnd->{'t_level'}[$tn]})){
		    $$r_topic_entry = $tn;
		} else {
		    ### Note, if a topic was judge about a topic, but not in the
		    ### set of evaluated levels, the story is thrown out of the eval.
		    ### This means if only breifs are to be on topic, all yes stories
		    ### are disgarded
		    $addit = 0;
		}
	    }
	} 
	### Omit any NON-NEWS tagged stories!!!!!
	$addit = 0 if ($rh_bnd->{'doctype'} ne "NEWS");
    }
    if ($main::Vb > 10 && $addit > 0) { print "Skipping Story:  "; &dump_boundary($rh_bnd); }
    $addit;
}

sub TrackSscore{
    ##### The HYP Array gets destroyed during computations
    my($ra_Hyp, $rh_TDTref, $source, $is_first_source, $PointerType, $MapMethod, $Index, $TargTopic, $SkipExtraSys) = @_;
    my(@Ref) = ();
    my($sid, $eid);
    my($i);
    my(@output) = ();
    my($origin);
    my($addit, $topic_entry);
    my($tn);
    my(%t_bnd);

    ## Push the headings onto the output list
    
    if ($main::Vb == 1){ print "."; &flush(*STDOUT); }
    if ($main::Vb > 5){
	print "Scoring '$source' $PointerType\n    Hypothesis:\n" if ($main::Vb > 5);
	for ($i=0; $i<=$#$ra_Hyp; $i++){
	    print "        ".join(" ",@{ $ra_Hyp->[$i] })."\n"; }
    }

    if ($SkipExtraSys){
	#return () if (! defined($rh_TDTref->{'bsets'}{$source}));
	### Bug fix, it's ok to skip if it's NOT in this index file!!!
	return () if (! defined($rh_TDTref->{'IndexList'}{$Index}{'contents'}{$source}));
    } else {
	if (! defined($rh_TDTref->{'bsets'}{$source})){
	    if (defined($rh_TDTref->{"ExcludeSSD"}{"source"}{$source})){
		print "    Excluding source file '$source' from scoring\n"
		    if ($main::Vb > 1);
		return;
	    }
	    #### Only die if this is the second or later source, AND, the first story begins after 1
	    die("Source file '$source' not loaded from index.  Find matching index file.")
		if ($is_first_source == 0 || ($is_first_source == 1 && $ra_Hyp->[1][0] <= 1));
	    print "\nSkipping it source '$source' because of partial first source for a topic\n" if ($main::Vb > 1);
	    return ;
	}
    }
    
    ## Record the fact that we have scored this file
    $rh_TDTref->{'results'}{'Scored_files'}{$source} = 1;

    ### Extract the Reference Pointers
    if ($PointerType eq "RECID"){ $sid = 'Brecid'; $eid = 'Erecid'; $origin = 1; } 
    else { $sid = 'Bsec'; $eid = 'Esec'; $origin = 0;}

    foreach ($i=0; $i<= $#{ $rh_TDTref->{'bsets'}{$source}{'boundary'} }; $i++){
	my $rh_bnd = \%{ $rh_TDTref->{'bsets'}{$source}{'boundary'}[$i] };      
	
	### IF the test begins after a certain Recid, make sure the preceeding data
	### is ignored!!!
	die "Source file '$source' not in index list" 
	    if (! defined($rh_TDTref->{'IndexList'}{$Index}{'contents'}{$source}));

	if (is_EvaluableTracking($rh_TDTref, $rh_bnd, 'Brecid', $Index, \$topic_entry, $source,
				 $TargTopic)){
	    ### Note, the supplied 'n/a' values handle the case when NO judgements are in the annotations
	    ### These values should be the same as used in TDT3.pm
	    push(@Ref,[ ($rh_bnd->{$sid}, $rh_bnd->{$eid}, $rh_bnd->{'docno'},
			 ($topic_entry >= 0) ? $rh_bnd->{'topicid'}[$topic_entry] : 'n/a',
			 ($topic_entry >= 0) ? $rh_bnd->{'t_level'}[$topic_entry] : 'n/a',
			 ) ] );			    
	}
    }

    if ($main::Vb > 5){
	print "    Reference:\n" if ($main::Vb > 5);
	for ($i=0; $i<=$#Ref; $i++){
	    print "        ".join(" ",@{ $Ref[$i] })."\n"; }
    }

    my(%th);
    my($foo);
    ### Mate the reference docid's to hyp topics
    for ($i=0; $i<=$#Ref; $i++){
#	my(@arr) = ();
	%th = ();
	($th{'score'}, $th{'decision'}, $foo, $th{'justify'}) =
	    &Find_system_score_for_doc($ra_Hyp,$Ref[$i][0],$Ref[$i][1],$origin,
				       $MapMethod, 'tracking');
	push ( @output, 
	       "score\0".$th{'score'}."\0".
	       "decision\0".$th{'decision'}."\0".
	       "justify\0".$th{'justify'}."\0".
	       "docno\0$Ref[$i][2]\0".
	       "rtopic\0$Ref[$i][3]\0".
	       "sid\0".(($Ref[$i][0] eq "") ? " " : $Ref[$i][0])."\0".
	       "eid\0".(($Ref[$i][1] eq "") ? " " : $Ref[$i][1])."\0" );
    }
    @output;
}

sub Tracking_Build_Subset_Map{
    my($rh_TDTref, $subsetfile) = @_;

    if ($subsetfile eq ""){
	$rh_TDTref->{'results'}{'Trk_params'}{'subset_defined'} = 0;
    } else {
	$rh_TDTref->{'results'}{'Trk_params'}{'subset_defined'} = 1;
	$rh_TDTref->{'results'}{'Trk_params'}{'subset_map'} = Load_SSDFile($subsetfile,0);
    }
}

sub Write_QC_file{
    my($rh_TDTref, $QC_file) = @_;
    my($beg_time) = time;
    my($i, $j);

    print "Building QC file '$QC_file.{key,sys,col}.gz'\n" if ($main::Vb > 0);
    open(QCKEY, "| $main::CompressCommand > $QC_file.key.gz") || die "Error: Unable to open QCfile '$QC_file.key.gz'\n";
    open(QCSYS, "| $main::CompressCommand > $QC_file.sys.gz") || die "Error: Unable to open QCfile '$QC_file.sys.gz'\n";
    open(QCCOL, "| $main::CompressCommand > $QC_file.col.gz") || die "Error: Unable to open QCfile '$QC_file.col.gz'\n";

    print QCKEY "# LINK_DETECTION\n";
    print QCSYS $rh_TDTref->{'results'}{'Trk_params'}{'eval'}[0]{'System_Name'}."\n";
    print QCCOL "# COLUMNS = docno puttopic ".$rh_TDTref->{'results'}{'Trk_params'}{'eval'}[0]{'System_Name'}."\n";
    
    for ($i=0; $i<=$#{ $rh_TDTref->{'results'}{'Trk_params'}{'eval'} }; $i++){
	my($ra_scores,$topicid);
	my(%th);
	$topicid = $rh_TDTref->{'results'}{'Trk_params'}{'eval'}[$i]{'TargTopic'};

	$ra_scores = \@{ $rh_TDTref->{'results'}{'Trk_params'}{'eval'}[$i]{'scores'} };

	for ($j=0; $j <= $#{ $ra_scores}; $j++){
	    %th = split(/\0/,$ra_scores->[$j]);

	    my ($c) = $ra_scores->[$j];
	    $c =~ s/\0/ /g;
	    
	    print QCKEY $th{'docno'}," $topicid ".($topicid ne $th{'rtopic'} ? "NON" : "")."TARGET $topicid\n";
	    print QCSYS $th{'docno'}," $topicid ",$th{'decision'}," ",$th{'score'},"\n";
	    print QCCOL $th{'docno'}," $topicid ",$th{'score'},"/",$th{'decision'}.
                    ($topicid ne $th{'rtopic'} ? "/OFF" : "/ON")."\n";

	}
    }
    close(QCKEY);
    close(QCSYS);
    close(QCCOL);
    printf("    .... QC_file generation completed, %d elapsed seconds\n",
	   time - $beg_time ) if ($main::Vb > 0);
}


