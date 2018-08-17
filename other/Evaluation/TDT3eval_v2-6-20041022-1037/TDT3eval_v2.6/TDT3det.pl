#!/usr/bin/perl -w

require "flush.pl";
require "TDT3.pm";
use strict;

# Version: v1  
#    Mark:   Line 762 area.  
#          I counted the number of NO topics and subtracted from the 
#          following count before setting addit to zero
#	$addit = 0 if ($#{ $rh_b->{'t_level'} } > 0);
#
my $Expected_TDT3Version = "2.5";

my $Usage ="Usage: TDT3det.pl <Options> Detection_File\n".
"TDT library Version: ".&TDT3pm_Version()."\n".
"Desc:  TDT3det.pl is the TDT3 Detection Task Evaluation software.\n".
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
"   -l           -> Print the loaded decision database for link analysis and exit\n".
"   -P P(topic)  -> Use P(topic) in the cost function for mapping reference\n".
"                   and hypothesis topic clusters.  Default is 0.02\n".
"   -C Cmiss:Cfa -> Use 'Cmiss' and 'Cfa' as the cost of a miss and cost of a\n".
"                   false alarm in the cost function respectively.  Defaults are\n".
"                   1 and 0.1\n".
"   -r Report    -> write the summary report to the file 'Report'\n".
"   -D DetailFile -> Write a detailed report of the scoring.\n".
"   -d DETfile   -> filename root to write the DET file to.\n".
"      DET Plotting Options:\n".
"      -t title  -> title to use in DET plot, default is the command line\n".
"   -S SubsetFile -> Use the specified source file subset definition file.\n".
"                   If this option is used, report subset-conditioned scores.\n".
"   -E ExcludeFile -> Use the specified source file list to filter the\n".
"                   evaluable source files\n".
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
my $SubsetFile = "";
my $AlternateRelTables = "";
my $UNDEF = "--";
my $DecDatabase = "";
my $ExcludeSubsetFile = "";
############################

############################ Main ###########################
&ProcessCommandLine();


my(@IndexList) = ( $Index );
my %TDTref = &Load_Boundaries_Into_TDTRef($Root,\@IndexList,"DETECTION",
					  Boundary_DTDs(), $ExcludeSubsetFile);
&Add_Topic_Into_TDTref(($AlternateRelTables eq "") ? 
		       TopicRelevance_FILEs() : [ split(/:/,$AlternateRelTables) ],
		       TopicRelevance_DTDs(), \%TDTref, "false");
if ($DumpData == 1){ &dump_TDTref(\%TDTref,"-"); exit 0; }

#### Map then system output onto topic boundaries
&Detection_Map_Topics($Sysout, $Index, \%TDTref, $MapMethod);

&Verify_Complete_Test(\%TDTref, $Index, "");

if ($DecDatabase ne ""){
    #### Dump the decision map for link assessment
    &Dump_detection_decisions(\%TDTref, $DecDatabase);
}

#### Build ref/hyp topic sets, and map them to each other
&Detection_Build_Subset_Map(\%TDTref, $SubsetFile);
&Detection_Score_Topic_Sets(\%TDTref, $CF_Ptopic, $CF_Cmiss, $CF_Cfa, "hard_decision",
			    0.0, $TopicRegexp);
&Produce_Detection_Report(\%TDTref, 0, $CF_Ptopic, $CF_Cmiss, $CF_Cfa, $ReportFile);

&make_DET_plot(\%TDTref, $DETFile, $DETTitle, 0)
    if (${DETFile} ne "");

&dump_TDTref(\%TDTref,$DetailFile) if ($DetailFile ne "");

printf "Successful Completion\n" if ($main::Vb > 0);

exit 0;

###################### End of main ############################

sub die_usage{  my($mesg) = @_;    print "$Usage";   
		die("Error: ".$mesg."\n");  }

sub ProcessCommandLine{
    require "getopts.pl";
    &Getopts('sLR:T:r:D:i:v:m:d:t:C:P:S:j:l:E:');

    ### So that automatic library checks can be made
    exit 0 if ($ARGV[0] eq "__CHECKLIB__");
    
    die_usage("Root Directory for LDC TDT Corpus Req'd") if (!defined($main::opt_R));
    die_usage("NIST Detection index file Req'd") if (!defined($main::opt_i));

    $Root = $main::opt_R;
    $Index = $main::opt_i;
    $main::Vb = $main::opt_v if (defined($main::opt_v));
    set_TDT3Fast($main::opt_s) if (defined($main::opt_s));
    $DumpData = $main::opt_L if (defined($main::opt_L));
    $DecDatabase = $main::opt_l if (defined($main::opt_l));
    $ReportFile = $main::opt_r if (defined($main::opt_r));
    $DetailFile = $main::opt_D if (defined($main::opt_D));
    $AlternateRelTables = $main::opt_j if (defined($main::opt_j));
    if (defined($main::opt_T)){
	$TopicRegexp = $main::opt_T;
	Convert_Topic_set_macros(\$TopicRegexp);
    }
    $SubsetFile = $main::opt_S if (defined($main::opt_S));
    $ExcludeSubsetFile = $main::opt_E if (defined($main::opt_E));
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
    } else {
	print STDERR "Warning: -t option ignored\n" if (defined($main::opt_t));
    }
    die_usage("Detection system output file Req'd") if ($#ARGV != 0);
    $Sysout = $ARGV[0];
}

sub Produce_Detection_Report{
    my($rh_TDTref, $sumind, $CF_Ptopic, $CF_Cmiss, $CF_Cfa, $OutFile) = @_;

    print "Writing Report to '$OutFile'\n" if ($main::Vb > 0 && $OutFile ne "-");
    open(OUT,">$OutFile") || die "Error: unable to open report file '$OutFile'\n";
    if ($OutFile ne "-" && $main::ATNIST){
	if ($main::ATNIST){  #### hack to keep perl from complaining about single use variable
	    print "Writing Report (EDES Format) to '$OutFile.edes'\n" 
		if ($main::Vb > 0 && $OutFile ne "-");
	}
	EDES_set_file($OutFile.".edes");
    }
    EDES_add_to_avalue("System",$rh_TDTref->{'results'}{'Det_params'}{'System'});

    my(@Table) = build_det_table($rh_TDTref, $CF_Ptopic, $CF_Cmiss, $CF_Cfa);
    my(@SubsetTable) = build_det_subsettable($rh_TDTref, $CF_Ptopic, $CF_Cmiss, $CF_Cfa);


    print OUT "----------------------------------------";
    print OUT "---------------------------------------\n";
    print OUT "-------------------  TDT Detection Task Performance Report";
    print OUT "  ------------------\n";
    print OUT "\n";
    print OUT "Command line:   $CommandLine\n";
    print OUT "Execution Date: ".`date`;
    print OUT "\n";

    my($rh_ts) = $rh_TDTref->{'results'}{'Det_params'}{'topic_scores'}[$sumind] ;

    printf OUT ("Story Weighted Detection: P(Miss)       = %.4f\n",$rh_ts->{'Pmiss'});
    printf OUT ("                          P(Fa)         = %.4f\n",$rh_ts->{'Pfa'});
    printf OUT ("                          Cdet          = %.4f\n",$rh_ts->{'Cdet'});
    printf OUT ("                          (Cdet)norm    = %.4f\n",$rh_ts->{'Norm(Cdet)'});
    printf OUT ("\n");

    printf OUT ("Topic Weighted Detection: P(Miss)       = %.4f\n",$rh_ts->{'S_Pmiss'} / $rh_ts->{'S_n'});
    printf OUT ("                          P(Fa)         = %.4f\n",$rh_ts->{'S_Pfa'} / $rh_ts->{'S_n'});
    printf OUT ("                          Cdet          = %.4f\n",$rh_ts->{'S_Cdet'} / $rh_ts->{'S_n'});
    printf OUT ("                          (Cdet)norm *  = %.4f\n",$rh_ts->{'S_normCdet'} / $rh_ts->{'S_n'});
    print OUT "\n";
    print OUT "  *   Primary Evaluation Metric\n";

    print OUT "\n";
    print OUT "Detection Performance Calculations:\n";
    print OUT "\n";
    &tabby(*OUT,\@Table,'l',2,"    "); 
    print OUT "\n";

    print OUT "\n";
    print OUT "Cost Based YDZ Calculations:\n";
    print OUT "\n";
    &tabby(*OUT,$rh_TDTref->{"results"}{"Det_params"}{"Cost_YDZ_table"},'l',2,"    "); 
    print OUT "\n";

    if ($rh_TDTref->{'results'}{'Det_params'}{'subset_defined'}){
	print OUT "\n";
	print OUT "Detection Performance by Test Subset:\n";
	print OUT "\n";
	&tabby(*OUT,\@SubsetTable,'l',2,"    "); 
	print OUT "\n";  
    }
    
    print OUT "\n";
    print OUT "Execution parameters:\n";
    print OUT "\n";
    write_details($rh_TDTref, $sumind, *OUT);

    print OUT "\n";

    print OUT "----------------  End of TDT Detection Task Performance Report";
    print OUT "  ---------------\n";
    print OUT "----------------------------------------";
    print OUT "---------------------------------------\n";
}

sub write_details{
    my($rh_TDTref, $sumind, $OUT) = @_;
    my(@kl) = (keys %{ $rh_TDTref->{'IndexList'} });

    print $OUT "LDC TDT Corpus Root Dir: ".$rh_TDTref->{'RootDir'}."\n";
    print $OUT "Index File:              ".$kl[0]."\n";
    print $OUT "System Output File:      ".
	$rh_TDTref->{'results'}{'Det_params'}{'System_Output'}."\n";
    print $OUT "Pointer Type:            ".
	$rh_TDTref->{'IndexList'}{$kl[0]}{'index_pointer_type'}."\n";
    print $OUT "Topic cluster Mapping Function:\n";
    print $OUT "              P(topic) = $CF_Ptopic\n";
    print $OUT "              Cmiss    = $CF_Cmiss\n";
    print $OUT "              Cfa      = $CF_Cfa\n";
    print $OUT "              Topic inclusion by: ".
	$rh_TDTref->{'results'}{'Det_params'}{'topic_scores'}[$sumind]{'type'}."\n";
    if ($rh_TDTref->{'results'}{'Det_params'}{'topic_scores'}[$sumind]{'type'} eq 
	"score_decision"){
	print $OUT "              Topic score thresshold: ".
	    $rh_TDTref->{'results'}{'Det_params'}{'topic_scores'}[$sumind]{'thresh'}."\n";
    }
    print $OUT "\n";
    print $OUT "Detection Performance Calculations:\n";
    print $OUT "    System Identifier:   ".
	$rh_TDTref->{'results'}{'Det_params'}{'System'};
    print $OUT " '".$rh_TDTref->{'results'}{'Det_params'}{'Desc'}."'"
    if ($rh_TDTref->{'results'}{'Det_params'}{'Desc'} ne "");
    print $OUT "\n";
    print $OUT "    Deferral Period:     ".
	$rh_TDTref->{'results'}{'Det_params'}{'Deferral'}."\n";
    print $OUT "\n";

    print $OUT "System Output to Story Mapping Function:  '$MapMethod'\n";
}

sub numerically1 {$a <=> $b; }

sub build_det_table{
    my($rh_TDTref, $CF_Ptopic, $CF_Cmiss, $CF_Cfa) = @_;

    my($ra_a) = $rh_TDTref->{'results'}{'Det_params'}{'topic_map'} ;
    my($rh_b) = $rh_TDTref->{'results'}{'Det_params'}{'topic_scores'}[0] ;
    my(@tab) = ();
    my($i);

    EDES_add_to_avalue("Subset","Global");

    # print join(" ",keys %{ $rh_TDTref->{'results'}{'Det_params'} })."\n";
    push(@tab,
	 [ ('Ref.' ,'Hyp.', '# Ref','# Sys.','# Corr','# Miss','# Fa', '| # Test','',       '',     '',     '(Cdet)') ]);
    push(@tab,
	 [ ('Topic','Topic','Story','Story', 'Story' ,'Story', 'Story','| Story', 'P(Miss)','P(Fa)','Cdet', 'norm'  ) ]);
    push(@tab,
	 [ ('-----','-----','-----' ,'-----','------','------','-----','| ------','-------','-----','----', '------') ]);
    
    my(@rl);

    ### enable sorting of reference topics
    my(%rtops);
    my($k);   
    for ($i=0; $i <= $#$ra_a; $i++){	$rtops{$ra_a->[$i]{'rtopic'}} = $i;    }

    foreach $k(sort numerically1 (keys %rtops)){
	$i = $rtops{$k};

	@rl = ();
	push(@rl, ( $ra_a->[$i]{'rtopic'}, $ra_a->[$i]{'htopic'},
		   sprintf("%3s",$ra_a->[$i]{'Nrefdoc'})));

	push(@rl, (sprintf("%3s",$ra_a->[$i]{'Nhypdoc'}),
		   sprintf("%3s",$ra_a->[$i]{'Ncorr'}),
		   sprintf("%3s",$ra_a->[$i]{'Nmiss'}),
		   sprintf("%3s",$ra_a->[$i]{'Nfa'}),
		   sprintf("| %3s",$ra_a->[$i]{'Ntestdoc'}),, 
		   ($ra_a->[$i]{'Pmiss'} eq $UNDEF) ? $UNDEF :    sprintf("%.4f", $ra_a->[$i]{'Pmiss'}),
		   ($ra_a->[$i]{'Pfa'} eq $UNDEF) ? $UNDEF :      sprintf("%.4f", $ra_a->[$i]{'Pfa'}),
		   ($ra_a->[$i]{'Cdet'} eq $UNDEF) ? $UNDEF :     sprintf("%.4f", $ra_a->[$i]{'Cdet'}),
		   ($ra_a->[$i]{'normCdet'} eq $UNDEF) ? $UNDEF : sprintf("%.4f", $ra_a->[$i]{'normCdet'})));
	push(@tab, [ @rl ]);

	EDES_add_to_avalue("Topic", $ra_a->[$i]{'rtopic'});
	EDES_print("Type","Stat", "Stat.name","htopic", "Stat.value",$ra_a->[$i]{'htopic'});
	EDES_print("Type","Stat", "Stat.name","# refdoc", "Stat.value",$ra_a->[$i]{'Nrefdoc'});
	EDES_print("Type","Stat", "Stat.name","# hypdoc", "Stat.value",$ra_a->[$i]{'Nhypdoc'});
	EDES_print("Type","Stat", "Stat.name","# Corr", "Stat.value",$ra_a->[$i]{'Ncorr'});
	EDES_print("Type","Stat", "Stat.name","# Miss", "Stat.value",$ra_a->[$i]{'Nmiss'});
	EDES_print("Type","Stat", "Stat.name","# Fa", "Stat.value",$ra_a->[$i]{'Nfa'});
	EDES_print("Type","Stat", "Stat.name","# Test Story", "Stat.value",$ra_a->[$i]{'Ntestdoc'});
	EDES_print("Type","Stat", "Stat.name","P(Miss)", "Stat.value",$ra_a->[$i]{'Pmiss'});
	EDES_print("Type","Stat", "Stat.name","P(Fa)", "Stat.value",$ra_a->[$i]{'Pfa'});
	EDES_print("Type","Stat", "Stat.name","Cdet", "Stat.value",$ra_a->[$i]{'Cdet'});
	EDES_print("Type","Stat", "Stat.name","Norm(Cdet)", "Stat.value",$ra_a->[$i]{'normCdet'});
	EDES_delete_from_avalue("Topic"); 
   }
    push(@tab,
	 [ ('=====','=====','=====' ,'=====','======','======','=====','| ======','=======','=====','====', '======') ]);
    @rl = ();
    $rh_b->{'Pmiss'} = ($rh_b->{'Nrefdoc'} == 0 ) ? 0 : $rh_b->{'Nmiss'} / $rh_b->{'Nrefdoc'};
    $rh_b->{'Pfa'} = $rh_b->{'Nfa'} / ( $rh_b->{'Ntestdoc'} - $rh_b->{'Nrefdoc'});
    $rh_b->{'Cdet'} = detect_CF($rh_b->{'Pmiss'}, $rh_b->{'Pfa'},
				$CF_Ptopic, $CF_Cmiss, $CF_Cfa);
    $rh_b->{'Norm(Cdet)'} = norm_detect_CF($rh_b->{'Pmiss'}, $rh_b->{'Pfa'},
					   $CF_Ptopic, $CF_Cmiss, $CF_Cfa);
    push(@rl, 'Story', 'Weight');
    push(@rl, ("",
	       "",
	       "",
	       "",
	       "",
	       "",
	       sprintf("%.4f", $rh_b->{'Pmiss'}),
	       sprintf("%.4f", $rh_b->{'Pfa'}),
	       sprintf("%.4f", $rh_b->{'Cdet'}),
	       sprintf("%.4f", $rh_b->{'Norm(Cdet)'})));
    push(@tab, [ @rl ]);
    EDES_print("Type","Stat", "Stat.name","SW P(Miss)", "Stat.value",$rh_b->{'Pmiss'});
    EDES_print("Type","Stat", "Stat.name","SW P(Fa)", "Stat.value",$rh_b->{'Pfa'});
    EDES_print("Type","Stat", "Stat.name","SW Cdet", "Stat.value",$rh_b->{'Cdet'});
    EDES_print("Type","Stat", "Stat.name","SW Norm(Cdet)", "Stat.value",$rh_b->{'Norm(Cdet)'});
    
    @rl = ();
    push(@rl, 'Topic', 'Sums');
    push(@rl, (sprintf("%3s",$rh_b->{'Nrefdoc'}),
	       sprintf("%3s",$rh_b->{'Nhypdoc'}),
	       sprintf("%3s",$rh_b->{'Ncorr'}),
	       sprintf("%3s",$rh_b->{'Nmiss'}),
	       sprintf("%3s",$rh_b->{'Nfa'}),
	       sprintf("| %3s",$rh_b->{'Ntestdoc'}),));
    push(@tab, [ @rl ]);
    EDES_print("Type","Stat", "Stat.name","# refdoc", "Stat.value",$rh_b->{'Nrefdoc'});
    EDES_print("Type","Stat", "Stat.name","# hypdoc", "Stat.value",$rh_b->{'Nhypdoc'});
    EDES_print("Type","Stat", "Stat.name","# Corr Detect", "Stat.value",$rh_b->{'Ncorr'});
    EDES_print("Type","Stat", "Stat.name","# Miss", "Stat.value",$rh_b->{'Nmiss'});
    EDES_print("Type","Stat", "Stat.name","# Fa", "Stat.value",$rh_b->{'Nfa'});
    EDES_print("Type","Stat", "Stat.name","# Test Story", "Stat.value",$rh_b->{'Ntestdoc'});

    @rl = ();
    push(@rl, 'Topic', 'Means');
    push(@rl, (sprintf("%5.1f",($#$ra_a <= 0) ? 0 : $rh_b->{'Nrefdoc'} / $rh_b->{'S_n'}   ),
	       sprintf("%5.1f",($#$ra_a <= 0) ? 0 : $rh_b->{'Nhypdoc'} / $rh_b->{'S_n'}   ),
	       sprintf("%5.1f",($#$ra_a <= 0) ? 0 : $rh_b->{'Ncorr'} / $rh_b->{'S_n'} ),
	       sprintf("%5.1f",($#$ra_a <= 0) ? 0 : $rh_b->{'Nmiss'} / $rh_b->{'S_n'} ),
	       sprintf("%5.1f",($#$ra_a <= 0) ? 0 : $rh_b->{'Nfa'} / $rh_b->{'S_n'}   ),
	       sprintf("| %5.1f",($#$ra_a <= 0) ? 0 : $rh_b->{'Ntestdoc'} / $rh_b->{'S_n'}   ),
	       sprintf("%.4f", ($#$ra_a <= 0) ? 0 : $rh_b->{'S_Pmiss'} / $rh_b->{'S_n'}),
	       sprintf("%.4f", ($#$ra_a <= 0) ? 0 : $rh_b->{'S_Pfa'} / $rh_b->{'S_n'}  ),
	       sprintf("%.4f", ($#$ra_a <= 0) ? 0 : $rh_b->{'S_Cdet'} / $rh_b->{'S_n'}),
	       sprintf("%.4f", ($#$ra_a <= 0) ? 0 : $rh_b->{'S_normCdet'} / $rh_b->{'S_n'})));

    push(@tab, [ @rl ]);
    EDES_print("Type","Stat", "Stat.name","Nrefdoc", "Stat.value",($#$ra_a <= 0) ? 0 : $rh_b->{'Nrefdoc'} / $rh_b->{'S_n'});
    EDES_print("Type","Stat", "Stat.name","TW # hypdoc",
	       "Stat.value",($#$ra_a <= 0) ? 0 : $rh_b->{'Nhypdoc'} / $rh_b->{'S_n'});
    EDES_print("Type","Stat", "Stat.name","TW # Corr Detect",
	       "Stat.value",($#$ra_a <= 0) ? 0 : $rh_b->{'Ncorr'} / $rh_b->{'S_n'});
    EDES_print("Type","Stat", "Stat.name","TW # Miss", 
	       "Stat.value",($#$ra_a <= 0) ? 0 : $rh_b->{'Nmiss'} / $rh_b->{'S_n'});
    EDES_print("Type","Stat", "Stat.name","TW # Fa",
	       "Stat.value",($#$ra_a <= 0) ? 0 : $rh_b->{'Nfa'} / $rh_b->{'S_n'});
    EDES_print("Type","Stat", "Stat.name","TW # Test Story",
	       "Stat.value",($#$ra_a <= 0) ? 0 : $rh_b->{'Ntestdoc'} / $rh_b->{'S_n'});
    EDES_print("Type","Stat", "Stat.name","TW P(Miss)", 
	       "Stat.value",($#$ra_a <= 0) ? 0 : $rh_b->{'S_Pmiss'} / $rh_b->{'S_n'});
    EDES_print("Type","Stat", "Stat.name","TW P(Fa)",
	       "Stat.value",($#$ra_a <= 0) ? 0 : $rh_b->{'S_Pfa'} / $rh_b->{'S_n'});
    EDES_print("Type","Stat", "Stat.name","TW Cdet",
	       "Stat.value",($#$ra_a <= 0) ? 0 : $rh_b->{'S_Cdet'} / $rh_b->{'S_n'});
    EDES_print("Type","Stat", "Stat.name","TW Norm(Cdet)",
	       "Stat.value",($#$ra_a <= 0) ? 0 : $rh_b->{'S_normCdet'} / $rh_b->{'S_n'});
    EDES_delete_from_avalue("Subset");

    @tab;
}

sub build_det_subsettable{
    my($rh_TDTref, $CF_Ptopic, $CF_Cmiss, $CF_Cfa) = @_;

    my($ra_a) = $rh_TDTref->{'results'}{'Det_params'}{'topic_map'} ;
    my($rh_b) = $rh_TDTref->{'results'}{'Det_params'}{'topic_scores'}[0] ;
    my($rh_c) = $rh_TDTref->{'results'}{'Det_params'}{'subset_map'} ;
    my(@tab) = ();


    # print join(" ",keys %{ $rh_TDTref->{'results'}{'Det_params'} })."\n";
    push(@tab,
	 [ ('Sub-', '|| Ref.' ,'Hyp.', '# Ref','# Sys.','# Corr','# Miss','# Fa', '| # Test','',       '',     '',     '(Cdet)' ) ]);
    push(@tab,
	 [ ('set',  '|| Topic','Topic','Story','Story', 'Story' ,'Story', 'Story','| Story', 'P(Miss)','P(Fa)','Cdet', 'norm' ) ]);
    push(@tab,
	 [ ('----', '|| -----','-----','-----' ,'-----','------','------','-----','| ------','-------','-----','----', '------') ]);
    
    my(@rl, $set);
    foreach $set(keys %$rh_c ){
	my($sumNrefdoc, $sumNhypdoc, $sumNcorr, $sumNmiss, $sumNfa, $sumNtestdoc) = (0, 0, 0, 0, 0, 0);
	my($sumPmiss, $sumNPmiss, $sumPfa, $sumNPfa) = (0, 0, 0, 0);
	my($i);
	### enable sorting of reference topics
	my(%rtops);
	my($k);   
	for ($i=0; $i <= $#$ra_a; $i++){	$rtops{$ra_a->[$i]{'subsets'}{$set}{'rtopic'}} = $i;    }

	EDES_add_to_avalue("Subset",$rh_c->{$set}{'heading'});

	foreach $k(sort numerically1 (keys %rtops)){
	    $i = $rtops{$k};
	    @rl = ();
	    push(@rl, $rh_c->{$set}{'heading'});
	    push(@rl, ( "|| ".$ra_a->[$i]{'subsets'}{$set}{'rtopic'},
		       $ra_a->[$i]{'subsets'}{$set}{'htopic'},
		       sprintf("%3s",$ra_a->[$i]{'subsets'}{$set}{'Nrefdoc'})));
	    
	    push(@rl, (sprintf("%3s",$ra_a->[$i]{'subsets'}{$set}{'Nhypdoc'}),
		       sprintf("%3s",$ra_a->[$i]{'subsets'}{$set}{'Ncorr'}),
		       sprintf("%3s",$ra_a->[$i]{'subsets'}{$set}{'Nmiss'}),
		       sprintf("%3s",$ra_a->[$i]{'subsets'}{$set}{'Nfa'}),
		       sprintf("| %3s",$ra_a->[$i]{'subsets'}{$set}{'Ntestdoc'}),, 
		       (($ra_a->[$i]{'subsets'}{$set}{'Pmiss'} eq $UNDEF) ? $UNDEF :	
			sprintf("%.4f", $ra_a->[$i]{'subsets'}{$set}{'Pmiss'})),
		       (($ra_a->[$i]{'subsets'}{$set}{'Pfa'} eq $UNDEF) ? $UNDEF :
			sprintf("%.4f", $ra_a->[$i]{'subsets'}{$set}{'Pfa'})),
		       (($ra_a->[$i]{'subsets'}{$set}{'Cdet'} eq $UNDEF) ? $UNDEF :
			sprintf("%.4f", $ra_a->[$i]{'subsets'}{$set}{'Cdet'})),
		       (($ra_a->[$i]{'subsets'}{$set}{'normCdet'} eq $UNDEF) ? $UNDEF :
			sprintf("%.4f", $ra_a->[$i]{'subsets'}{$set}{'normCdet'}))));
	    push(@tab, [ @rl ]);
	    $sumNrefdoc += $ra_a->[$i]{'subsets'}{$set}{'Nrefdoc'};
	    $sumNhypdoc += $ra_a->[$i]{'subsets'}{$set}{'Nhypdoc'};
	    $sumNcorr   += $ra_a->[$i]{'subsets'}{$set}{'Ncorr'};
	    $sumNmiss   += $ra_a->[$i]{'subsets'}{$set}{'Nmiss'};
	    $sumNfa     += $ra_a->[$i]{'subsets'}{$set}{'Nfa'};
	    $sumNtestdoc+= $ra_a->[$i]{'subsets'}{$set}{'Ntestdoc'};
	    if ($ra_a->[$i]{'subsets'}{$set}{'Pmiss'} ne $UNDEF){
		$sumNPmiss ++;
		$sumPmiss   += $ra_a->[$i]{'subsets'}{$set}{'Pmiss'};
	    }
	    if ($ra_a->[$i]{'subsets'}{$set}{'Pmiss'} ne $UNDEF){
		$sumNPfa ++;
		$sumPfa     += $ra_a->[$i]{'subsets'}{$set}{'Pfa'};
	    }

	    EDES_add_to_avalue("Topic", $ra_a->[$i]{'subsets'}{$set}{'rtopic'});
	    EDES_print("Type","Stat", "Stat.name","htopic", 
		       "Stat.value", $ra_a->[$i]{'subsets'}{$set}{'htopic'});
	    EDES_print("Type","Stat", "Stat.name","# refdoc",
		       "Stat.value",$ra_a->[$i]{'subsets'}{$set}{'Nrefdoc'});
	    EDES_print("Type","Stat", "Stat.name","# hypdoc",
		       "Stat.value",$ra_a->[$i]{'subsets'}{$set}{'Nhypdoc'});
	    EDES_print("Type","Stat", "Stat.name","# Corr",
		       "Stat.value",$ra_a->[$i]{'subsets'}{$set}{'Ncorr'});
	    EDES_print("Type","Stat", "Stat.name","# Miss",
		       "Stat.value",$ra_a->[$i]{'subsets'}{$set}{'Nmiss'});
	    EDES_print("Type","Stat", "Stat.name","# Ffa",
		       "Stat.value",$ra_a->[$i]{'subsets'}{$set}{'Nfa'});
	    EDES_print("Type","Stat", "Stat.name","# Test Story",
		       "Stat.value",$ra_a->[$i]{'subsets'}{$set}{'Ntestdoc'} );
	    EDES_print("Type","Stat", "Stat.name","P(Miss)",
		       "Stat.value",$ra_a->[$i]{'subsets'}{$set}{'Pmiss'});
	    EDES_print("Type","Stat", "Stat.name","P(Fa)",
		       "Stat.value",$ra_a->[$i]{'subsets'}{$set}{'Pfa'});
	    EDES_print("Type","Stat", "Stat.name","Cdet",
		       "Stat.value",$ra_a->[$i]{'subsets'}{$set}{'Cdet'});
	    EDES_print("Type","Stat", "Stat.name","Norm(Cdet)",
		       "Stat.value",$ra_a->[$i]{'subsets'}{$set}{'normCdet'});
	    EDES_delete_from_avalue("Topic"); 
	}
	push(@tab,
	     [ ('====', '|| =====','=====','=====' ,'=====','======','======','=====','| ======','=======','=====','====', '======') ]);
	@rl = ();
	push(@rl, $rh_c->{$set}{'heading'}, '|| Story', 'Weight');
	push(@rl, ("",
		   "",
		   "",
		   "",
		   "",
		   "|",
		   sprintf("%.4f", $sumNmiss / $sumNrefdoc),
		   sprintf("%.4f", $sumNfa   / ($sumNtestdoc - $sumNrefdoc)),
		   sprintf("%.4f", &detect_CF($sumNmiss / $sumNrefdoc,
					      $sumNfa   / ($sumNtestdoc - $sumNrefdoc),
					      $CF_Ptopic, $CF_Cmiss, $CF_Cfa)),
		   sprintf("%.4f", &norm_detect_CF($sumNmiss / $sumNrefdoc,
						   $sumNfa   / ($sumNtestdoc - $sumNrefdoc),
						   $CF_Ptopic, $CF_Cmiss, $CF_Cfa))));
	push(@tab, [ @rl ]);
	EDES_print("Type","Stat", "Stat.name","SW P(Miss)", "Stat.value",$sumNmiss / $sumNrefdoc);
	EDES_print("Type","Stat", "Stat.name","SW P(Fa)", "Stat.value",
		   $sumNfa   / ($sumNtestdoc - $sumNrefdoc));
	EDES_print("Type","Stat", "Stat.name","SW Cdet", "Stat.value",
		   &detect_CF($sumNmiss / $sumNrefdoc,
			      $sumNfa   / ($sumNtestdoc - $sumNrefdoc),
			      $CF_Ptopic, $CF_Cmiss, $CF_Cfa));
	EDES_print("Type","Stat", "Stat.name","SW Norm(Cdet)", "Stat.value",
		   &norm_detect_CF($sumNmiss / $sumNrefdoc,
				   $sumNfa   / ($sumNtestdoc - $sumNrefdoc),
				   $CF_Ptopic, $CF_Cmiss, $CF_Cfa));
	############################3
	@rl = ();
	push(@rl, $rh_c->{$set}{'heading'}, '|| Topic', 'Sums');
	push(@rl, (sprintf("%3s",$sumNrefdoc),
		   sprintf("%3s",$sumNhypdoc),
		   sprintf("%3s",$sumNcorr),
		   sprintf("%3s",$sumNmiss),
		   sprintf("%3s",$sumNfa),
		   sprintf("| %3s",$sumNtestdoc)));
	push(@tab, [ @rl ]);
	EDES_print("Type","Stat", "Stat.name","# refdoc", "Stat.value",$sumNrefdoc);
	EDES_print("Type","Stat", "Stat.name","# hypdoc", "Stat.value",$sumNhypdoc);
	EDES_print("Type","Stat", "Stat.name","# Corr Detect", "Stat.value",$sumNcorr);
	EDES_print("Type","Stat", "Stat.name","# Miss", "Stat.value",$sumNmiss);
	EDES_print("Type","Stat", "Stat.name","# Fa", "Stat.value",$sumNfa);
	EDES_print("Type","Stat", "Stat.name","# Test Story", "Stat.value",$sumNtestdoc);

	@rl = ();
	push(@rl, $rh_c->{$set}{'heading'}, '|| Topic', 'Means');
	push(@rl, (sprintf("%5.1f",($#$ra_a <= 0) ? 0 : $sumNrefdoc / $rh_b->{'S_n'}   ),
		   sprintf("%5.1f",($#$ra_a <= 0) ? 0 : $sumNhypdoc / $rh_b->{'S_n'}   ),
		   sprintf("%5.1f",($#$ra_a <= 0) ? 0 : $sumNcorr / $rh_b->{'S_n'} ),
		   sprintf("%5.1f",($#$ra_a <= 0) ? 0 : $sumNmiss / $rh_b->{'S_n'} ),
		   sprintf("%5.1f",($#$ra_a <= 0) ? 0 : $sumNfa / $rh_b->{'S_n'}   ),
		   sprintf("| %5.1f",($#$ra_a <= 0) ? 0 : $sumNtestdoc / $rh_b->{'S_n'}   ),
		   sprintf("%.4f", ($#$ra_a <= 0) ? 0 : $sumPmiss / $sumNPmiss),
		   sprintf("%.4f", ($#$ra_a <= 0) ? 0 : $sumPfa / $sumNPfa),
		   sprintf("%.4f", ($#$ra_a <= 0) ? 0 : &detect_CF($sumPmiss / $sumNPmiss,
								   $sumPfa / $sumNPfa,
								   $CF_Ptopic, $CF_Cmiss, $CF_Cfa)),
		   sprintf("%.4f", ($#$ra_a <= 0) ? 0 : &norm_detect_CF($sumPmiss / $sumNPmiss,
									$sumPfa / $sumNPfa,
									$CF_Ptopic, $CF_Cmiss, $CF_Cfa))));
	
	push(@tab, [ @rl ]);
	push(@tab, [ () ]);
	push(@tab, [ () ]);
	EDES_print("Type","Stat", "Stat.name","Nrefdoc",
		   "Stat.value",($#$ra_a <= 0) ? 0 : $sumNrefdoc / $rh_b->{'S_n'}   );
	EDES_print("Type","Stat", "Stat.name","TW # hypdoc",
		   "Stat.value",($#$ra_a <= 0) ? 0 : $sumNhypdoc / $rh_b->{'S_n'}   );
	EDES_print("Type","Stat", "Stat.name","TW # Corr Detect",
		   "Stat.value",($#$ra_a <= 0) ? 0 : $sumNcorr / $rh_b->{'S_n'} );
	EDES_print("Type","Stat", "Stat.name","TW # Miss", 
		   "Stat.value",($#$ra_a <= 0) ? 0 : $sumNmiss / $rh_b->{'S_n'} );
	EDES_print("Type","Stat", "Stat.name","TW # Fa",
		   "Stat.value",($#$ra_a <= 0) ? 0 : $sumNfa / $rh_b->{'S_n'}   );
	EDES_print("Type","Stat", "Stat.name","TW # Test Story",
		   "Stat.value",($#$ra_a <= 0) ? 0 : $sumNtestdoc / $rh_b->{'S_n'}   );
	EDES_print("Type","Stat", "Stat.name","TW P(Miss)", 
		   "Stat.value",$sumPmiss / $sumNPmiss),
	EDES_print("Type","Stat", "Stat.name","TW P(Fa)",
		   "Stat.value",$sumPfa / $sumNPfa),
	EDES_print("Type","Stat", "Stat.name","TW Cdet",
		   "Stat.value", &detect_CF($sumPmiss / $sumNPmiss,
					    $sumPfa / $sumNPfa,
					    $CF_Ptopic, $CF_Cmiss, $CF_Cfa)),
	EDES_print("Type","Stat", "Stat.name","TW Norm(Cdet)",
		   "Stat.value",&norm_detect_CF($sumPmiss / $sumNPmiss,
						$sumPfa / $sumNPfa,
						$CF_Ptopic, $CF_Cmiss, $CF_Cfa));
	EDES_delete_from_avalue("Subset");
    }
	
    @tab;
}

sub make_DET_plot{
    my($rh_TDTref, $DETFile, $DETTitle, $sumind) = @_;

    my($ts, $i);
    my($ra_a) = $rh_TDTref->{'results'}{'Det_params'}{'topic_map'} ;
    my($min_fa, $max_fa, $min_miss, $max_miss) = (0.01, 90, 1, 90);
    my($pmin_fa, $pmax_fa, $pmin_miss, $pmax_miss) = 
	($min_fa/100.0, $max_fa/100.0, $min_miss/100.0, $max_miss/100.0);
    
    print "Producing DET cloud plot, file '${DETFile}.plt'\n" if ($main::Vb == 1);
   
    open(PLT,"> ${DETFile}.plt") ||
	die("unable to open DET gnuplot file ${DETFile}.plt");

    &write_gnuplot_DET_header(*PLT, $DETTitle, $min_fa, $max_fa, $min_miss, $max_miss);
    open(DAT,"> ${DETFile}.DET.0") ||
	die("unable to open DET data file ${DETFile}.DET.0");
    open(DAT2,"> ${DETFile}.DET.2") ||
	die("unable to open DET data file ${DETFile}.DET.2");
    for ($i=0; $i <= $#$ra_a; $i++){
	if (($ra_a->[$i]{'Pmiss'} > $pmin_miss && $ra_a->[$i]{'Pmiss'} < $pmax_miss) && 
	    ($ra_a->[$i]{'Pfa'}   > $pmin_fa && $ra_a->[$i]{'Pfa'}   < $pmax_fa)){
	    print DAT &ppndf($ra_a->[$i]{'Pmiss'})." ".&ppndf($ra_a->[$i]{'Pfa'})."\n";
	} else {
	    ## it's off the graph
	    print DAT2 &ppndf((($ra_a->[$i]{'Pmiss'} < $pmin_miss) ? $pmin_miss :
			       (($ra_a->[$i]{'Pmiss'} > $pmax_miss) ? $pmax_miss : $ra_a->[$i]{'Pmiss'})))." ";
	    print DAT2 &ppndf((($ra_a->[$i]{'Pfa'} < $pmin_fa) ? $pmin_fa :
			       (($ra_a->[$i]{'Pfa'} > $pmax_fa) ? $pmax_fa : $ra_a->[$i]{'Pfa'})))."\n";
	}
    }
    close(DAT);
    close(DAT2);

    open(DAT,"> ${DETFile}.DET.1") ||
	die("unable to open DET data file ${DETFile}.DET.1");
    my($rh_ts) = $rh_TDTref->{'results'}{'Det_params'}{'topic_scores'}[$sumind];
    printf DAT ("%f %f\n",
		&ppndf($rh_ts->{'S_Pmiss'} / $rh_ts->{'S_n'}), 
		&ppndf($rh_ts->{'S_Pfa'} / $rh_ts->{'S_n'}));
    close(DAT);

    ### Write the plot line
    print PLT ",\\\n";
    print PLT "    '${DETFile}.DET.0' using 2:1 title '".
	$rh_TDTref->{'results'}{'Det_params'}{'System'}." cluster score cloud' with points 3 1, \\\n";
    print PLT "    '${DETFile}.DET.2' using 2:1 title '".
	$rh_TDTref->{'results'}{'Det_params'}{'System'}." OFF-GRAPH cluster score cloud' with points 3 3, \\\n";
    print PLT "    '${DETFile}.DET.1' using 2:1 title '".
	$rh_TDTref->{'results'}{'Det_params'}{'System'}." topic weighted score' with points 4 2\n";

    close PLT;
}

#### Map then system output onto topic boundaries
sub Detection_Map_Topics{
    my($Sysout, $Index, $rh_TDTref, $MapMethod) = @_;
    my($inrec, $src, $pnt, $source);
    my(@HypPointers);
    my($System, $DefPeriod, $PointerType, $WithBoundary);
    my($last_point);
    my($topic, $decision, $score);

    print "Performing detection scoring on '$Sysout'.\n" if ($main::Vb > 0);
    print "   (one period printed per source file)\n" if ($main::Vb == 1);

    die("Detection system output file '$Sysout' not found") 
	if (! -f $Sysout);
    $rh_TDTref->{'results'}{'Det_params'}{'System_Output'} = $Sysout;
    open(SYS,$Sysout) || die("Unable to open Detection system ".
			     "output file '$Sysout'");
    ### Read in the header 
    $_ = <SYS>;
    $rh_TDTref->{'results'}{'Det_params'}{'Desc'} = "";
    if ($_ =~ /^#/) {
	### Save the description
	chop;
	($rh_TDTref->{'results'}{'Det_params'}{'Desc'} = $_) =~ s/^#\s*//;
	### Read until we find data
	while ($_ =~ /^#/){  $_ = <SYS>;  }       
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
    
    $rh_TDTref->{'results'}{'Det_params'}{'WithBoundary'} = $WithBoundary;
    $rh_TDTref->{'results'}{'Det_params'}{'n_source'} = 0;

    $rh_TDTref->{'results'}{'Det_params'}{'System'} = $System;
    $rh_TDTref->{'results'}{'Det_params'}{'Deferral'} = $DefPeriod;

    ### Let's Party, Read in data until the filename changes
    @HypPointers = ();
    push (@HypPointers, [ (0.0, 'NO', -1.0e+99, 'TDT3det_UNASSIGNED_TOPIC') ]);
    $last_point = 0.0;

    while (! eof(SYS)){
	($inrec = <SYS>) =~ s/^\s+//;
	$inrec =~ s/#.*$//;
	next if ($inrec =~ /^\s*$/);
	($topic, $src, $pnt, $decision, $score) = split(/\s+/,$inrec);
	$decision =~ tr/a-z/A-Z/;
	die("Hard Decision not YES or NO '$inrec'") if ($decision !~ /^(NO|YES)$/);
	#### Translate the source name int an appropriate form
	$src =~ s:^.*/::;
	$src =~ s:\.mt(tkn|as[r0-9])$::;
	$src =~ s:\.(tkn|as[r0-9])$::;

	if ($#HypPointers == 0){
	    $source = $src;
	} elsif ($source ne $src){
	    &DetectSscore(\@HypPointers, $rh_TDTref, $source, $PointerType, $MapMethod);
	    
	    @HypPointers = ();
 	    push (@HypPointers, [ (0.0, 'NO', -1.0e+99, 'TDT3det_UNASSIGNED_TOPIC') ]);
	    $source = $src;
	} else {
	    #### check for ascending order
	    if (($pnt - $last_point) < 0.00001){
		print STDERR "Warning: decisions for input file $src are not in ascending order\n";
	    }
	}
	push (@HypPointers, [ ($pnt, $decision, $score, $topic) ]);
	$last_point = $pnt;
    }
    if ($#HypPointers > -1){
	&DetectSscore(\@HypPointers, $rh_TDTref, $source, $PointerType, $MapMethod);
    }	    
	
    print "\n" if ($main::Vb == 1); 

    close(SYS);
}

sub DetectSscore{
    my($ra_Hyp, $rh_TDTref, $source, $PointerType, $MapMethod) = @_;
    my(@Ref) = ();
    my($sid, $eid, $origin);
    my($i, $t, %b, $addit);
    my($NO_CNT, $YES_CNT);

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
	die "Error: the source file '$source' appears at least twice in the system output";
    }
    $rh_TDTref->{'results'}{'Scored_files'}{$source} = 1;
    $rh_TDTref->{'results'}{'Det_params'}{'n_source'} ++;

    ### Extract the Reference Pointers
    if ($PointerType eq "RECID"){ $sid = 'Brecid'; $eid = 'Erecid'; $origin = 1 } 
    else { $sid = 'Bsec'; $eid = 'Esec'; $origin = 0;}

    foreach ($i=0; $i<= $#{ $rh_TDTref->{'bsets'}{$source}{'boundary'} }; $i++){
	$addit = 1;

	my ($rh_b) = $rh_TDTref->{'bsets'}{$source}{'boundary'}[$i];       

	&dump_boundary(*b) if ($main::Vb > 5);

	## Search the possibly multiple ref judgments
	$NO_CNT=0; $YES_CNT=0;
	for ($t=0; $t<=$#{ $rh_b->{'t_level'} }; $t++){
	    $addit = 0 if ($rh_b->{'t_level'}[$t] eq 'BRIEF');
	    $NO_CNT++ if ($rh_b->{'t_level'}[$t] eq 'NO');
	    $YES_CNT++ if ($rh_b->{'t_level'}[$t] eq 'YES');
	}
#	$addit = 0 if (($#{ $rh_b->{'t_level'} } - $NO_CNT) > 0);
	$addit = 0 if ($YES_CNT > 1);

	$addit = 0 if ($rh_b->{'doctype'} ne "NEWS");
	if ($addit == 1){
	    push(@Ref,[ ($rh_b->{$sid}, $rh_b->{$eid}, $rh_b->{'docno'} ) ] );		
	} elsif ($main::Vb > 5) {
	    print "Skipping Story:  "; &dump_boundary(*b); 
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
	($th{'score'}, $th{'decision'}, $th{'htopic'}, $th{'justify'}) =
	    &Find_system_score_for_doc($ra_Hyp,$Ref[$i][0],$Ref[$i][1], $origin,
				       $MapMethod, 'detection');
	    
	$th{'docno'} = $Ref[$i][2];
	push ( @{ $rh_TDTref->{'results'}{'Det_params'}{'eval'} }, { %th } );
    }
}

sub Detection_Build_Subset_Map{
    my($rh_TDTref, $subsetfile) = @_;

    if ($subsetfile eq ""){
	$rh_TDTref->{'results'}{'Det_params'}{'subset_defined'} = 0;
    } else {
	$rh_TDTref->{'results'}{'Det_params'}{'subset_defined'} = 1;
$rh_TDTref->{'results'}{'Det_params'}{'subset_map'} = Load_SSDFile($subsetfile,0);
    }
}

sub build_clusters{
    my($rh_TDTref, $rh_ref_ts, $rh_hyp_ts, $ra_ref_top, $ra_hyp_top, $decision_style) = @_;
    my($ra_a) = $rh_TDTref->{'results'}{'Det_params'}{'eval'} ;
    my($i, $sf, $bn, $b, $t, $rh_b, $ht, $rt, $n, $k1);
    my($use_hard) = ($decision_style eq "hard_decision") ? 1 : 0;

    ### First make the Topic Sets
    for ($i=0; $i <= $#$ra_a; $i++){
	### Lookup the source file 
	die "Internal Error, docno2fileid failed on '".$ra_a->[$i]{'docno'}."'"
	    if (! defined($rh_TDTref->{"docno2fileid"}{$ra_a->[$i]{'docno'}}));
	$sf = $rh_TDTref->{"docno2fileid"}{$ra_a->[$i]{'docno'}};
	$bn = $rh_TDTref->{'bsets'}{$sf}{'doc_index'}{$ra_a->[$i]{'docno'}};
	## @b is the boundary information of the currently judged docno
	$rh_b = $rh_TDTref->{'bsets'}{$sf}{'boundary'}[$bn];       

	## Search the possibly multiple ref judgments
	for ($t=0; $t<=$#{ $rh_b->{'topicid'} }; $t++){	
	    if ((${TopicRegexp} eq "" || 
		 $rh_b->{'topicid'}[$t] =~ /^${TopicRegexp}$/) &&
		$rh_b->{'topicid'}[$t] ne 'n/a' && $rh_b->{'t_level'}[$t] eq 'YES'){
		$rh_ref_ts->{$rh_b->{'topicid'}[$t]}{$ra_a->[$i]{'docno'}} = 1;
	    }
	}
	
	## Tally the system judgements
	if ($use_hard){
	    if ($ra_a->[$i]{'htopic'} ne 'n/a'){
		$rh_hyp_ts->{$ra_a->[$i]{'htopic'}}{$ra_a->[$i]{'docno'}} = $ra_a->[$i]{'decision'};
	    }
	} else {
	    #### Disregard the hard decisions, using the threshhold to compute the score
	    if ($ra_a->[$i]{'htopic'} ne 'n/a'){
		$rh_hyp_ts->{$ra_a->[$i]{'htopic'}}{$ra_a->[$i]{'docno'}} = 
		    ($ra_a->[$i]{'score'} > 0.5) ? "YES" : "NO";
	    }
	    
	}
    }

    @$ra_ref_top = sort(keys %$rh_ref_ts);
    @$ra_hyp_top = sort(keys %$rh_hyp_ts);

    die "Error: No Valid Reference topic clusters found for input documents!!!" if ($#$ra_ref_top < 0);
    die "Error: No Valid Hypothesis topic clusters found in input documents!!!" if ($#$ra_hyp_top < 0);
}

sub compute_cost_of_detection{
    my($rh_TDTref, $rh_ref_ts, $rh_hyp_ts, $ra_ref_top, $ra_hyp_top, $decision_style) = @_;

    my($sf, $bn, $t, $i, $set);
    my($fileid);
    my($use_hard) = ($decision_style eq "hard_decision") ? 1 : 0;
    my($k1);
    my($rt, $ht);

    ### @a is the list of hyp jugdements for docno's
    my($ra_a) = $rh_TDTref->{'results'}{'Det_params'}{'eval'} ;

    my(%topscr) = ();  ### Set up the hash to hold the overall scores

    %topscr = ('Ntestdoc' => 0, 'Nrefdoc' => 0, 'Nhypdoc' => 0,
	       'Nmiss' => 0,  'Nfa' => 0,  'Ncorr' => 0,
	       'Pmiss' => 0, 'Pfa' => 0, 'Cdet' => 0, 'normCdet' => 0,
	       'type' => $decision_style, 'thresh' => 0.5,
	       'S_n' => 0, 'S_Pmiss' => 0, 'S_Pfa' => 0, 'S_Cdet' => 0, 'S_normCdet' => 0);

    ### Do the Array Search 

    foreach $rt(@$ra_ref_top){
	my($th) = ();
	my($score, $norm_score);
	my($minscore, $normminscore);

	### Initialize to the NULL topic
	$minscore = &detect_CF(1.0, 0, $CF_Ptopic, $CF_Cmiss, $CF_Cfa);
	$normminscore = &norm_detect_CF(1.0, 0, $CF_Ptopic, $CF_Cmiss, $CF_Cfa);
	my %th = ('Nrefdoc' => 0, 'htopic' => 'NULL', 'Nhypdoc' => 0,
		  'Ntestdoc' => $#$ra_a + 1,
		  'Nmiss' => 0,  'Nfa' => 0, 'Ncorr' => 0,
		  'Pmiss' => 1.0, 'Pfa' => 0, 'Cdet' =>  $minscore,
		  'normCdet' =>  $normminscore,
		  'rtopic' => $rt );
	foreach $k1(keys %{ $rh_ref_ts->{$rt} }){  $th{'Nrefdoc'} ++;  $th{'Nmiss'} ++;  }	

	## Search the hyp doc clusters
	foreach $ht(@$ra_hyp_top){
	    print "Comparing Ref Topic $rt to hyp topic $ht\n" if ($main::Vb > 8);
	    my($Ns, $Nmiss, $Nfa, $Ncorr) = (0,0,0,0);
	    foreach $k1(keys %{ $rh_ref_ts->{$rt} }){ 	
		if (defined($rh_hyp_ts->{$ht}{$k1}) && $rh_hyp_ts->{$ht}{$k1} eq "YES") {
		    $Ncorr ++;
		} else {
		    $Nmiss ++;
		}
	    }
	    foreach $k1(keys %{ $rh_hyp_ts->{$ht} }){ 	
		if ($rh_hyp_ts->{$ht}{$k1} eq "YES") {
		    $Ns ++;
		    $Nfa ++ if (! defined($rh_ref_ts->{$rt}{$k1}));
		}
	    }
	    print "   Na= ".$th{'Nrefdoc'}."  Nmiss= $Nmiss ".
		" Ns= $Ns Nfa=$Nfa Ncorr=$Ncorr ".$th{'Nrefdoc'}.
		    "  ".$th{'Ntestdoc'}."\n" if ($main::Vb > 8);
	    if ($Ncorr > 0) { 
		# $score = ($Nmiss * $CF_Ptopic $th{'Nrefdoc'}) + ($Nfa / $Ns);
		$score = &detect_CF($Nmiss / $th{'Nrefdoc'},
				    $Nfa / ($th{'Ntestdoc'} - $th{'Nrefdoc'}),
				    $CF_Ptopic, $CF_Cmiss, $CF_Cfa);
		$norm_score = &norm_detect_CF($Nmiss / $th{'Nrefdoc'},
					      $Nfa / ($th{'Ntestdoc'} - $th{'Nrefdoc'}),
					      $CF_Ptopic, $CF_Cmiss, $CF_Cfa);
		
		if ($score < $minscore ||
		    (($score == $minscore) && ($Nfa < $th{'Nfa'}))){ 
		    $th{'Cdet'} = $score;
		    $th{'normCdet'} = $norm_score;
		    $minscore = $score;
		    $th{'Ntestdoc'} = $#$ra_a + 1; 
		    $th{'Nhypdoc'} = $Ns; 
		    $th{'Nmiss'} = $Nmiss; 
		    $th{'Nfa'} = $Nfa; 
		    $th{'Ncorr'} = $Ncorr; 
		    $th{'htopic'} = $ht;
		    $th{'Pmiss'} = $th{'Nmiss'} / $th{'Nrefdoc'};
		    $th{'Pfa'} =   $th{'Nfa'} / ($th{'Ntestdoc'} - $th{'Nrefdoc'});
		}	    
	    }
	}
	printf("   Topic '$rt' maps to '%s' score %.4f\n",
	       $th{'htopic'},$th{'Cdet'}) if ($main::Vb > 5);

        #### Record the topic cluster matches in the reference structure
        %{ $th{'cluster'} } = ();
        foreach $k1(sortuniq(keys %{ $rh_ref_ts->{$rt} }, keys %{ $rh_hyp_ts->{$th{'htopic'}} })){
	    $th{'cluster'}{$k1} = ((defined($rh_ref_ts->{$rt}{$k1})) ? "REF" : "   ").":".
		((defined($rh_hyp_ts->{$th{'htopic'}}{$k1})) ? "HYP.".$rh_hyp_ts->{$th{'htopic'}}{$k1} : "   ");
	    if ($rh_TDTref->{'results'}{'Det_params'}{'subset_defined'}){
		foreach $set(keys %{ $rh_TDTref->{'results'}{'Det_params'}{'subset_map'} }){
		    $fileid=$rh_TDTref->{'docno2fileid'}{$k1};
		    if (defined($rh_TDTref->{'results'}{'Det_params'}{'subset_map'}{$set}{'source'}{$fileid})){
			$th{'cluster'}{$k1} .= " ${set}=yes";
		    } else {
			$th{'cluster'}{$k1} .= " ${set}=no ";
		    }
		}
	    }
	}
	####

	### Set up the totals structure
	$topscr{'Ntestdoc'} += $th{'Ntestdoc'};
	$topscr{'Nrefdoc'} += $th{'Nrefdoc'};
	$topscr{'Nhypdoc'} += $th{'Nhypdoc'};
	$topscr{'Nmiss'} += $th{'Nmiss'};
	$topscr{'Nfa'} += $th{'Nfa'};
	$topscr{'Ncorr'} += $th{'Ncorr'};
	
	## Make the variables for topic weighted scores
        $topscr{'S_n'} ++;
	$topscr{'S_Pmiss'} += $th{'Pmiss'};
	$topscr{'S_Pfa'} += $th{'Pfa'};
	$topscr{'S_Cdet'} += $th{'Cdet'};
	$topscr{'S_normCdet'} += $th{'normCdet'};

        ###########################################################################3
        ## Now that the ref topic is assigned a hyp topic, DO the SUBSET Scoring
        if ($rh_TDTref->{'results'}{'Det_params'}{'subset_defined'}){
	    foreach $set(keys %{ $rh_TDTref->{'results'}{'Det_params'}{'subset_map'} }){
		$th{'subsets'}{$set} = { 'Nrefdoc' => 0, 'htopic' => $th{'htopic'}, 
					 'Ntestdoc' => 0,'Nhypdoc' => 0,
					 'Nmiss' => 0,  'Nfa' => 0, 'Ncorr' => 0,
					 'Pmiss' => 0,  'Pfa' => 0, 'Cdet' =>  0, 'normCdet' =>  0,
					 'rtopic' => $rt };
		#### my(*a) = $rh_TDTref->{'results'}{'Det_params'}{'eval'} ;
		for ($i=0; $i <= $#$ra_a; $i++){
		    $fileid=$rh_TDTref->{'docno2fileid'}{$ra_a->[$i]{'docno'}};
		    $th{'subsets'}{$set}{'Ntestdoc'} ++
			if (defined($rh_TDTref->{'results'}{'Det_params'}{'subset_map'}{$set}{'source'}{$fileid}));
		}
	    }
	    ### Pruning subsets with no test documents
	    foreach $set(keys %{ $rh_TDTref->{'results'}{'Det_params'}{'subset_map'} }){
		if ($th{'subsets'}{$set}{'Ntestdoc'} == 0){
		    print STDERR "Warning: Subset heading=".
			"'".$rh_TDTref->{'results'}{'Det_params'}{'subset_map'}{$set}{'heading'}."'".
			" title=".
			"'".$rh_TDTref->{'results'}{'Det_params'}{'subset_map'}{$set}{'title'}."'".
			" disregarded\n";
		    delete $rh_TDTref->{'results'}{'Det_params'}{'subset_map'}{$set};
		    delete $th{'subsets'}{$set};
		}
	    }
	    foreach $set(keys %{ $rh_TDTref->{'results'}{'Det_params'}{'subset_map'} }){
		foreach $k1(keys %{ $rh_ref_ts->{$rt} }){ 	
		### Compute the subset id
		    $fileid=$rh_TDTref->{'docno2fileid'}{$k1};

		    if (defined($rh_TDTref->{'results'}{'Det_params'}{'subset_map'}{$set}{'source'}{$fileid})){
			$th{'subsets'}{$set}{'Nrefdoc'} ++;
			if (defined($rh_hyp_ts->{$th{'htopic'}}{$k1}) 
			    && $rh_hyp_ts->{$th{'htopic'}}{$k1} eq "YES") {
			    $th{'subsets'}{$set}{'Ncorr'} ++;
			} else {
			    $th{'subsets'}{$set}{'Nmiss'} ++;
			}
		    }
		}
	    
		foreach $k1(keys %{ $rh_hyp_ts->{$th{'htopic'}} }){ 	
		    $fileid=$rh_TDTref->{'docno2fileid'}{$k1};
				    
		    if (defined($rh_TDTref->{'results'}{'Det_params'}{'subset_map'}{$set}{'source'}{$fileid})){
			$th{'subsets'}{$set}{'Nhypdoc'} ++;
			if ($rh_hyp_ts->{$th{'htopic'}}{$k1} eq "YES") {
			    $th{'subsets'}{$set}{'Ns'} ++;
			    $th{'subsets'}{$set}{'Nfa'} ++
				if (! defined($rh_ref_ts->{$th{'rtopic'}}{$k1}));
			}
		    }
		}
		
		$th{'subsets'}{$set}{'Pmiss'} = ($th{'subsets'}{$set}{'Nrefdoc'} <= 0) ? $UNDEF :
		    $th{'subsets'}{$set}{'Nmiss'} / $th{'subsets'}{$set}{'Nrefdoc'};
		$th{'subsets'}{$set}{'Pfa'} = ( $th{'subsets'}{$set}{'Ntestdoc'} - $th{'subsets'}{$set}{'Nrefdoc'}  == 0) ? $UNDEF :
		    $th{'subsets'}{$set}{'Nfa'} / 
			( $th{'subsets'}{$set}{'Ntestdoc'} - $th{'subsets'}{$set}{'Nrefdoc'} );
		$th{'subsets'}{$set}{'Cdet'} = ($th{'subsets'}{$set}{'Pmiss'} eq $UNDEF ||
						$th{'subsets'}{$set}{'Pmiss'} eq $UNDEF) ? $UNDEF :
						    &detect_CF($th{'subsets'}{$set}{'Pmiss'},
							       $th{'subsets'}{$set}{'Pfa'},
							       $CF_Ptopic, $CF_Cmiss, $CF_Cfa);
		$th{'subsets'}{$set}{'normCdet'} = ($th{'subsets'}{$set}{'Pmiss'} eq $UNDEF ||
						    $th{'subsets'}{$set}{'Pmiss'} eq $UNDEF) ? $UNDEF :
							&norm_detect_CF($th{'subsets'}{$set}{'Pmiss'},
									$th{'subsets'}{$set}{'Pfa'},
									$CF_Ptopic, $CF_Cmiss, $CF_Cfa);
	    }
	}
        ######################  End subsets  #######################

        ## Push the scoring structure into the list
	# print "TOT "; foreach $cra(keys %topscr){ print "$cra=$topscr{$cra} "; } print "\n";
	push ( @{ $rh_TDTref->{'results'}{'Det_params'}{'topic_map'} }, { %th } );
        
    }
    push ( @{ $rh_TDTref->{'results'}{'Det_params'}{'topic_scores'} }, { %topscr } );
}


sub Compute_Cost_YDZ{
    my($rh_TDTref, $rh_ref_ts, $rh_hyp_ts, $ra_ref_top, $ra_hyp_top) = @_;
    my(@Table) = ();
    my($Cmiss, $Cexam, $i, $k);

    push(@Table, [ ('Cexam', 'Cmiss', 'Ccluster', 'Cmin', 'Cmax', 'Cnorm') ]);
    push(@Table, [ ('-----', '-----', '--------', '----', '----', '-----') ]);

    print "Computing YDZ measures\n" if ($main::Vb > 0);

    $Cexam=1;   
    foreach $Cmiss(1, 10, 100, 1000, 10000, 100000){
	my $SUMNtarget_k = 0;
	my $Ntargets     = $#$ra_ref_top+1;
	my $Nclusters    = $#$ra_hyp_top+1;
	my $Ntotal       = 0;
	
	foreach $i(@$ra_hyp_top){ 
	    foreach (keys %{ $rh_hyp_ts->{$i} }){
		$Ntotal++;
	    }
	}
	
	my $Ccluster = 0;
	my $Cmin = 0;
 	my $Cmin_G = 0;
	my $Cmax = $Cexam * $Ntargets * $Ntotal;
	my $Cmax_G = $Cexam * $Ntargets * $Ntotal;
	
	foreach $k(@$ra_ref_top){
	    my $Ntarget_k = 0;
	    foreach (keys %{ $rh_ref_ts->{$k} }){
		$Ntarget_k++;
	    }
	    $SUMNtarget_k += $Ntarget_k;
	    $Cmax_G += $Cmiss * $Ntarget_k * $Ntarget_k / $Ntotal;
	    $Cmax += $Cmiss / $Ntotal * ($Ntarget_k * ($Ntotal - $Ntarget_k));
	    
	    foreach $i(@$ra_hyp_top){ 
		
		my $Ntarget_i_k = 0;
		my $Ncluster_i = 0;
		my $i_doc;
		
		foreach $i_doc(keys %{ $rh_hyp_ts->{$i} }){ 
		    $Ntarget_i_k ++ if (defined($rh_ref_ts->{$k}{$i_doc}));
		    $Ncluster_i ++;
		}
		$Ccluster += (($Cexam * ($Ntarget_i_k + 1 - ($Ntarget_i_k / $Ncluster_i))) +
			      ($Cmiss * $Ntarget_i_k / $Ncluster_i * ($Ncluster_i - $Ntarget_i_k)));
	    }
	}
	
	$Cmax_G += $Cmiss * $SUMNtarget_k;
	
	$Cmin_G = $Cexam * ($Ntotal - $Ntargets*($Ntargets - 1));
	$Cmin = $Cexam * ($SUMNtarget_k + $Ntargets*($Ntargets - 1));
	my $Cnorm = ($Ccluster - $Cmin) / ($Cmax - $Cmin);
	my $Cnorm_G = ($Ccluster - $Cmin_G) / ($Cmax_G - $Cmin_G);
	
	if ($main::Vb > 2){
	    print "Cmiss        = $Cmiss\n";
	    print "Cexam        = $Cexam\n";
	    print "Ntargets     = $Ntargets\n";
	    print "SUMNtarget_k = $SUMNtarget_k\n";
	    print "Ntotal       = $Ntotal\n";
	    print "Nclusters    = $Nclusters\n";
	    print "\n";
	    print "Cluster      = $Ccluster\n";
	    print "Cmin         = $Cmin\n";
	    print "Cmax         = $Cmax\n";
	    print "Cnorm        = $Cnorm\n";
	    print "\n";
	    print "Cmin_G       = $Cmin_G\n";
	    print "Cmax_G       = $Cmax_G\n";
	    print "Cnorm_G      = $Cnorm_G\n";
	}
	
	push(@Table, [ ($Cexam, $Cmiss, 
			sprintf("%.2f",$Ccluster),
			sprintf("%.2f",$Cmin),
			sprintf("%.2f",$Cmax),
			sprintf("%.6f",$Cnorm)) ]);
    }
    @Table;
}

#### Build ref/hyp topic sets, and map them to each other
sub Detection_Score_Topic_Sets{
    my($rh_TDTref, $CF_Ptopic, $CF_Cmiss, $CF_Cfa, $decision_style, $score_threshhold, $TopicRegexp) = @_;
    ### Format
    #   { 'topicid' => { 'docid' => 1, 'docid' => 1, ...} }
    my(%ref_ts) = ();  ### this is a hash of hashs, the first is the 
                          ### topic id, the second is a hash of docno's
    my(%hyp_ts) = ();  ### this is a hash of hashs, the first is the 
                          ### topic id, the second is a hash of docno's
                          ### they point to the hard decisions
    my(@hyp_top) = ();
    my(@ref_top) = ();


    print "Mapping reference clusters to hypothesis clusters\n" if ($main::Vb > 0);
    
    &build_clusters($rh_TDTref, \%ref_ts, \%hyp_ts, \@ref_top, \@hyp_top, $decision_style);
    #&cluster_analysis($rh_TDTref, \%ref_ts, \%hyp_ts, \@ref_top, \@hyp_top);    
    &compute_cost_of_detection($rh_TDTref, \%ref_ts, \%hyp_ts, \@ref_top, \@hyp_top, $decision_style);
    $rh_TDTref->{"results"}{"Det_params"}{"Cost_YDZ_table"} = 
	[ &Compute_Cost_YDZ($rh_TDTref, \%ref_ts, \%hyp_ts, \@ref_top, \@hyp_top) ];
}

sub cluster_analysis{
    my ($rh_TDTref, $rh_ref_ts, $rh_hyp_ts, $ra_ref_top, $ra_hyp_top) = @_;
    my ($rt, $ht, $rd, $hd, $in, @list);
    print "Cluster Analysis\n";

    print "   Number of Ref Topics: ".scalar(@{ $ra_ref_top })."\n";
    print "   Number of Hyp Topics: ".scalar(@{ $ra_hyp_top })."\n";
    foreach $rt(@$ra_ref_top){ 
	@list = ();
	my @x = keys %{ $rh_ref_ts->{$rt} }; 
	my $totlink = scalar(@x)*(scalar(@x)-1)/2;
	my $reallink = 0;
	my $falink = 0;
	foreach $ht(@$ra_hyp_top){ 
	    $in = 0;
	    foreach $hd(keys %{ $rh_hyp_ts->{$ht} }){ 
		$in ++ if (defined($rh_ref_ts->{$rt}{$hd}))
	    }
	    my @x = keys %{ $rh_hyp_ts->{$ht} }; 
	    if ($in > 0){
		push @list, "$ht=$in(".scalar(@x).")" ;
		$reallink += $in*($in-1)/2;
		$falink += (scalar(@x)-$in)*((scalar(@x)-$in)-1)/2;
	    }
	}
	my $misslink = $totlink-$reallink;
	print "   reftopic=$rt #doc=".scalar(@x).
	    " #link=$totlink #miss=$misslink #fa=$falink".
	    " #hclus=".scalar(@list)." ".join(" ",@list)."\n"
    }


}
