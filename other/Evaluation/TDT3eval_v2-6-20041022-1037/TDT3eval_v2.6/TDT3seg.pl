#!/usr/bin/perl -w

require "flush.pl";
require "TDT3.pm";
use strict;

my $Expected_TDT3Version = "2.5";

my $Usage ="Usage: TDT3seg.pl -R Rootdir -I Indexfile <Options> Segmentation_File\n".
"TDT library Version: ".&TDT3pm_Version()."\n".
"Desc: TDT3seg.pl is the TDT3 Segmentation Evaluation software.\n".
"      It was designed to implement the test proceedures outlined\n".
"      in the 1998 TDT3 Evaluation Plan Version 1.8\n".
"\n".
"      The program requires the directory path, 'Rootdir',  to the LDC's\n".
"      TDT3 Test corpus.  The corpus must be in the same structure as \n".
"      released by the LDC, with all file formats identical to their\n".
"      original form.  The program uses the index file 'Indexfile',\n".
"      provide with the test corpus, to load the appropriate data from\n".
"      the corpus and to verify the completeness of the 'Segmentation_File'\n".
"      \n".
"      Upon completion of the load, the segmentations are scored, and a\n".
"      report is generated.\n".
"Options\n".
"   -C Cmiss:Cfa -> Use 'Cmiss' and 'Cfa' as the cost of a miss and cost of a\n".
"                   false alarm in the cost function respectively.  Defaults are\n".
"                   1 and 1\n".
"   -D DetailFile -> Write a detailed report of the scoring.\n".
"   -f size      -> Set the evaluation frame interval to 'size'.  Defaulte is\n".
"                   50 for 'RECID' segmentation and 15 for 'TIME' segmentation\n".
"   -i           -> Include all bounded regions of text in scoring, otherwise\n".
"                   evluation frames within stories not marked as NEWS are not\n".
"                   tallied\n".
"   -L           -> print the loaded database and exit\n".
"   -P P(seg)    -> Use P(seg) in the segmentation cost function.  Default is 0.3\n".
"   -r Report    -> write the summary report to the file 'Report'\n".
"   -s           -> Run with all available speedups\n".
"   -v num       -> Set the verbose level to 'num'. Default 1\n".
"                   ==0 None, ==1 Normal, >5 Slight, >10 way too much\n".
"   -p           -> Print precision and recall if the framesize '-f' is 1\n".
"   -E ExcludeFile -> Use the specified source file list to filter the\n".
"                   evaluable source files\n".
"DET Plot options\n".
"   -d DETfile   -> filename root to write the DET file to.\n".
"      DET Plotting Options:\n".
"      -t title  -> title to use in DET plot, default is the command line\n".
"\n";

die ("Error: Expected version of TDT3.pm is ".&TDT3pm_Version()." not $Expected_TDT3Version")
    if ($Expected_TDT3Version ne &TDT3pm_Version());

#### Globals Variables #####
$main::Vb = 1;
##
my $Root = "";
my $Index = "";
my $DumpData = 0;
my $CommandLine = $0." ".join(" ",@ARGV);
my $FrameSize = "";
my $OmitNonNews = 1;
my $CF_Pseg = 0.3;
my $CF_Cmiss = 1;
my $CF_Cfa = 0.3;
my $DETFile = "";
my $DETTitle = "";
my $ReportFile = "-";
my $DetailFile="";
my $Sysout;
my $DoPrecRecall = 0;
my $ExcludeSubsetFile = "";
############################

############################ Main ###########################
&ProcessCommandLine();

my(@IndexList) = ( $Index );
my %TDTref = &Load_Boundaries_Into_TDTRef($Root,\@IndexList,"SEGMENTATION",
					  Boundary_DTDs(), $ExcludeSubsetFile);

if ($DumpData == 1){ &dump_TDTref(\%TDTref, "-"); exit 0; }

&Segmentation_Eval($Sysout, $Index, \%TDTref, $FrameSize, $OmitNonNews);
&Verify_Complete_Test(\%TDTref, $Index, "");
&Produce_Segmentation_Report(\%TDTref, $CF_Pseg, $CF_Cmiss, $CF_Cfa, $ReportFile);
&make_DET_plot(\%TDTref, $DETFile, $DETTitle) if (${DETFile} ne "");
&dump_TDTref(\%TDTref,$DetailFile) if ($DetailFile ne "");

printf "Successful Completion\n" if ($main::Vb > 0);

exit 0;

###################### End of main ############################



sub die_usage{  my($mesg) = @_;    print "$Usage";   
		die("Error: ".$mesg."\n");  }

sub ProcessCommandLine{
    require "getopts.pl";
    &Getopts('iLpsr:D:R:I:v:f:d:t:E:');

    ### So that automatic library checks can be made
    exit 0 if ($ARGV[0] eq "__CHECKLIB__");

    die_usage("Root Directory for LDC TDT Corpus Req'd") if (!defined($main::opt_R));
    die_usage("NIST segmentation index file Req'd") if (!defined($main::opt_I));

    $Root = $main::opt_R;
    $Index = $main::opt_I;
    $main::Vb = $main::opt_v if (defined($main::opt_v));
    set_TDT3Fast($main::opt_s) if (defined($main::opt_s));
    $DumpData = $main::opt_L if (defined($main::opt_L));
    $ReportFile = $main::opt_r if (defined($main::opt_r));
    $DetailFile = $main::opt_D if (defined($main::opt_D));
    $ExcludeSubsetFile = $main::opt_E if (defined($main::opt_E));
    if (defined($main::opt_i)) { $OmitNonNews = !$main::opt_i };
    if (defined($main::opt_f)){
	$FrameSize = $main::opt_f;
	die "Positive Frame size req'd" if ($main::opt_f <= 0);
    }
    if (defined($main::opt_p)){
	if ($FrameSize ne 1){
	    print STDERR "Warning: Unable to compute Precision and Recal, Frame Size != 1\n";
	} else {
	    $DoPrecRecall = $main::opt_p;
	}
    }
    if (defined($main::opt_P)){
	die "Error: P(seg) range is: 0 <= P(seg) <=1.0" 
	    if ($main::opt_P < 0.0 || $main::opt_P > 1.0);
	$CF_Pseg = $main::opt_P;
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

    die_usage("Segmentation system output file Req'd") if ($#ARGV != 0);
    $Sysout = $ARGV[0];
}

sub Produce_Segmentation_Report{
    my($rh_TDTref, $CF_Pseg, $CF_Cmiss, $CF_Cfa, $OutFile) = @_;
    my(@kl) = (keys %{ $rh_TDTref->{'IndexList'} });
    my(@tab) = ();
    my($Pmiss, $Pfa, $Cseg, $fmt, $s, $normCseg);

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
    EDES_add_to_avalue("System",$rh_TDTref->{'results'}{'Seg_params'}{'System'});
    EDES_add_to_avalue("Subset","Global");
    
    print OUT "----------------------------------------";
    print OUT "---------------------------------------\n";
    print OUT "------------------  TDT Segmentation Task Performance Report";
    print OUT "  -----------------\n";
    print OUT "\n";
    print OUT "Command line:   $CommandLine\n";
    print OUT "Execution Date: ".`date`;
    print OUT "\n";
    print OUT "LDC TDT Corpus Root Dir: ".$rh_TDTref->{'RootDir'}."\n";
    print OUT "Index File:              ".$kl[0]."\n";
    print OUT "System Output File:      ".
	$rh_TDTref->{'results'}{'Seg_params'}{'System_Output'}."\n";
    print OUT "Omit Non-NEWS stories:   ";
    if ($OmitNonNews) {print OUT "TRUE\n"; } else { print OUT "FALSE\n"; }
    print OUT "Pointer Type:            ".
	$rh_TDTref->{'IndexList'}{$kl[0]}{'index_pointer_type'}."\n";
    print OUT "Deferral Period:         ".
	$rh_TDTref->{'results'}{'Seg_params'}{'Deferral'}."\n";
    print OUT "Evaluation Frame Size:   ".
	$rh_TDTref->{'results'}{'Seg_params'}{'FrameSize'}."\n";
    print OUT "\n";
    print OUT "Segmentation Performance Calculations:\n";
    print OUT "    System Identifier:   ".
	$rh_TDTref->{'results'}{'Seg_params'}{'System'};
    print OUT " '".$rh_TDTref->{'results'}{'Seg_params'}{'Desc'}."'"
    if ($rh_TDTref->{'results'}{'Seg_params'}{'Desc'} ne "");
    print OUT "\n";
    print OUT "    Number Source Files:  ".
	$rh_TDTref->{'results'}{'Seg_params'}{'n_source'}."\n";
    print OUT "\n";
    print OUT "Cseg parameters:\n";
    print OUT "              P(seg)   = $CF_Pseg\n";
    print OUT "              Cmiss    = $CF_Cmiss\n";
    print OUT "              Cfa      = $CF_Cfa\n";
    print OUT "\n\n";

    $fmt = "%d"; 
    $fmt = "%.2f" if ($rh_TDTref->{'IndexList'}{$kl[0]}{'index_pointer_type'} eq
		      'TIME');

    $Pmiss = ( $rh_TDTref->{'results'}{'Seg_params'}{'Pmiss_num'}/
	      $rh_TDTref->{'results'}{'Seg_params'}{'Pmiss_denom'});
    $Pfa   = ($rh_TDTref->{'results'}{'Seg_params'}{'Pfa_num'}/
	      $rh_TDTref->{'results'}{'Seg_params'}{'Pfa_denom'});
    $Cseg = &detect_CF($Pmiss, $Pfa, $CF_Pseg, $CF_Cmiss, $CF_Cfa);
    $normCseg = &norm_detect_CF($Pmiss, $Pfa, $CF_Pseg, $CF_Cmiss, $CF_Cfa);

    printf OUT ("Story Weighted (Pooled) Segmentation: P(Miss)    = %.4f\n", $Pmiss);
    printf OUT ("                                      P(Fa)      = %.4f\n", $Pfa  );
    printf OUT ("                                      Cseg       = %.4f\n", $Cseg);
    printf OUT ("                                      (Cseg)norm = %.4f\n", $normCseg);
    printf OUT ("\n");

    push(@tab, [ ('',     '# Src.', '|', 'Missed', 'Detect', '|', 'False',  'Alarm',  '|', '',        '',       '',       '(Cseg)') ]);
    push(@tab, [ ('Show', 'Files',  '|', 'Numer',  'Denom',  '|', 'Numer',  'Denom',  '|', 'P(miss)', 'P(fa)',  'Cseg',   'norm'  ) ]);
    push(@tab, [ ('-----','-----',  '|', '------', '------', '|', '------', '------', '|', '-------', '------', '------', '------') ]);
    
    my(@bkeys) = sort(keys %{ $rh_TDTref->{'results'}{'Seg_params'}{'broadcast'} });
    my($Sum_Pmiss, $Sum_Pfa, $Sum_Cseg, $Sum_normCseg) = (0,0,0);

    foreach $s(@bkeys){
	$Pmiss = ($rh_TDTref->{'results'}{'Seg_params'}{'broadcast'}{$s}{'Pmiss_num'}/
		  $rh_TDTref->{'results'}{'Seg_params'}{'broadcast'}{$s}{'Pmiss_denom'});
	$Pfa   = ($rh_TDTref->{'results'}{'Seg_params'}{'broadcast'}{$s}{'Pfa_num'}/
		  $rh_TDTref->{'results'}{'Seg_params'}{'broadcast'}{$s}{'Pfa_denom'});
	$Cseg = &detect_CF($Pmiss, $Pfa, $CF_Pseg, $CF_Cmiss, $CF_Cfa);
	$normCseg = &norm_detect_CF($Pmiss, $Pfa, $CF_Pseg, $CF_Cmiss, $CF_Cfa);
	EDES_add_to_avalue("Source",$s);

	push(@tab, [ ($s,
		      sprintf("%4d",$rh_TDTref->{'results'}{'Seg_params'}{'broadcast'}{$s}{'n_source'}),
		      '|',
		      sprintf("%6d",$rh_TDTref->{'results'}{'Seg_params'}{'broadcast'}{$s}{'Pmiss_num'}),
		      sprintf("%6d",$rh_TDTref->{'results'}{'Seg_params'}{'broadcast'}{$s}{'Pmiss_denom'}),
		      '|',
		      sprintf("%6d",$rh_TDTref->{'results'}{'Seg_params'}{'broadcast'}{$s}{'Pfa_num'}),
		      sprintf("%6d",$rh_TDTref->{'results'}{'Seg_params'}{'broadcast'}{$s}{'Pfa_denom'}),
		      '|',
		      sprintf("%.4f",$Pmiss),
		      sprintf("%.4f",$Pfa),
		      sprintf("%.4f",$Cseg),
		      sprintf("%.4f",$normCseg) ) ]);
	$Sum_Pmiss += $Pmiss;
	$Sum_Pfa += $Pfa;
	$Sum_Cseg += $Cseg;
	$Sum_normCseg += $normCseg;

	EDES_print("Type","Stat", "Stat.name","# Source",
		   "Stat.value",$rh_TDTref->{'results'}{'Seg_params'}{'broadcast'}{$s}{'n_source'});
	EDES_print("Type","Stat", "Stat.name","miss num",
		   "Stat.value",$rh_TDTref->{'results'}{'Seg_params'}{'broadcast'}{$s}{'Pmiss_num'});
	EDES_print("Type","Stat", "Stat.name","Miss denom",
		   "Stat.value",$rh_TDTref->{'results'}{'Seg_params'}{'broadcast'}{$s}{'Pmiss_denom'});
	EDES_print("Type","Stat", "Stat.name","Fa num",
		   "Stat.value",$rh_TDTref->{'results'}{'Seg_params'}{'broadcast'}{$s}{'Pfa_num'});
	EDES_print("Type","Stat", "Stat.name","Fa denom",
		   "Stat.value",$rh_TDTref->{'results'}{'Seg_params'}{'broadcast'}{$s}{'Pfa_denom'});
	EDES_print("Type","Stat", "Stat.name","P(Miss)",
		   "Stat.value",$Pmiss);
	EDES_print("Type","Stat", "Stat.name","P(Fa)",
		   "Stat.value",$Pfa);
	EDES_print("Type","Stat", "Stat.name","Cseg",
		   "Stat.value",$Cseg);
	EDES_print("Type","Stat", "Stat.name","Norm(Cseg)",
		   "Stat.value",$normCseg);

	EDES_delete_from_avalue("Source");
    }
    push(@tab, [ ('-----','-----',  '|', '------', '------', '|', '------', '------', '|', '-------', '------', '------', '------') ]);

    $Pmiss = ($rh_TDTref->{'results'}{'Seg_params'}{'Pmiss_num'}/
	      $rh_TDTref->{'results'}{'Seg_params'}{'Pmiss_denom'});
    $Pfa   = ($rh_TDTref->{'results'}{'Seg_params'}{'Pfa_num'}/
	      $rh_TDTref->{'results'}{'Seg_params'}{'Pfa_denom'});
    $Cseg = &detect_CF($Pmiss, $Pfa, $CF_Pseg, $CF_Cmiss, $CF_Cfa);
    $normCseg = &norm_detect_CF($Pmiss, $Pfa, $CF_Pseg, $CF_Cmiss, $CF_Cfa);

    push(@tab, [ ('Sums',
		  sprintf("%4d",$rh_TDTref->{'results'}{'Seg_params'}{'n_source'}),
		  '|',
		  sprintf("%6d",$rh_TDTref->{'results'}{'Seg_params'}{'Pmiss_num'}),
		  sprintf("%6d",$rh_TDTref->{'results'}{'Seg_params'}{'Pmiss_denom'}),
		  '|',
		  sprintf("%6d",$rh_TDTref->{'results'}{'Seg_params'}{'Pfa_num'}),
		  sprintf("%6d",$rh_TDTref->{'results'}{'Seg_params'}{'Pfa_denom'}),
		  '|',
		  sprintf("%.4f",$Pmiss),
		  sprintf("%.4f",$Pfa),
		  sprintf("%.4f",$Cseg),
		  sprintf("%.4f",$normCseg) ) ]);

    EDES_print("Type","Stat", "Stat.name","# Source",
	       "Stat.value",$rh_TDTref->{'results'}{'Seg_params'}{'n_source'});
    EDES_print("Type","Stat", "Stat.name","SW miss num",
	       "Stat.value",$rh_TDTref->{'results'}{'Seg_params'}{'Pmiss_num'});
    EDES_print("Type","Stat", "Stat.name","SW Miss denom",
	       "Stat.value",$rh_TDTref->{'results'}{'Seg_params'}{'Pmiss_denom'});
    EDES_print("Type","Stat", "Stat.name","SW Fa num",
	       "Stat.value",$rh_TDTref->{'results'}{'Seg_params'}{'Pfa_num'});
    EDES_print("Type","Stat", "Stat.name","SW Fa denom",
	       "Stat.value",$rh_TDTref->{'results'}{'Seg_params'}{'Pfa_denom'});
    EDES_print("Type","Stat", "Stat.name","SW P(Miss)", "Stat.value",$Pmiss);
    EDES_print("Type","Stat", "Stat.name","SW P(Fa)", "Stat.value",$Pfa);
    EDES_print("Type","Stat", "Stat.name","SW Cseg", "Stat.value",$Cseg);
    EDES_print("Type","Stat", "Stat.name","SW Norm(Cseg)", "Stat.value",$normCseg);
    
    push(@tab, [ ('Means',
		  sprintf("%4d",$rh_TDTref->{'results'}{'Seg_params'}{'n_source'} / ($#bkeys + 1)),
		  '|',
		  sprintf("%6d",$rh_TDTref->{'results'}{'Seg_params'}{'Pmiss_num'} / ($#bkeys+1)),
		  sprintf("%6d",$rh_TDTref->{'results'}{'Seg_params'}{'Pmiss_denom'} / ($#bkeys+1)),
		  '|',
		  sprintf("%6d",$rh_TDTref->{'results'}{'Seg_params'}{'Pfa_num'} / ($#bkeys+1)),
		  sprintf("%6d",$rh_TDTref->{'results'}{'Seg_params'}{'Pfa_denom'} / ($#bkeys+1)),
		  '|',
		  sprintf("%.4f",$Sum_Pmiss  / ($#bkeys+1)),
		  sprintf("%.4f",$Sum_Pfa / ($#bkeys+1)),
		  sprintf("%.4f",$Sum_Cseg / ($#bkeys+1)),
		  sprintf("%.4f",$Sum_normCseg / ($#bkeys+1)) ) ]);

    EDES_print("Type","Stat", "Stat.name","BSW # Source", 
	       "Stat.value", $rh_TDTref->{'results'}{'Seg_params'}{'n_source'} / ($#bkeys + 1));
    EDES_print("Type","Stat", "Stat.name","BSW miss num", 
	       "Stat.value", $rh_TDTref->{'results'}{'Seg_params'}{'Pmiss_num'} / ($#bkeys+1));
    EDES_print("Type","Stat", "Stat.name","BSW Miss denom",
	       "Stat.value", $rh_TDTref->{'results'}{'Seg_params'}{'Pmiss_denom'} / ($#bkeys+1));
    EDES_print("Type","Stat", "Stat.name","BSW Fa num",
	       "Stat.value", $rh_TDTref->{'results'}{'Seg_params'}{'Pfa_num'} / ($#bkeys+1));
    EDES_print("Type","Stat", "Stat.name","BSW Fa denom", 
	       "Stat.value", $rh_TDTref->{'results'}{'Seg_params'}{'Pfa_denom'} / ($#bkeys+1));
    EDES_print("Type","Stat", "Stat.name","BSW P(Miss)", "Stat.value", $Sum_Pmiss  / ($#bkeys+1));
    EDES_print("Type","Stat", "Stat.name","BSW P(Fa)", "Stat.value", $Sum_Pfa / ($#bkeys+1));
    EDES_print("Type","Stat", "Stat.name","BSW Cseg", "Stat.value", $Sum_Cseg / ($#bkeys+1));
    EDES_print("Type","Stat", "Stat.name","BSW Norm(Cseg)", 
	       "Stat.value", $Sum_normCseg / ($#bkeys+1));;
    
    &tabby(*OUT, \@tab,'l',2,"    ");

    if ($DoPrecRecall){
	@tab = ();
        push(@tab, [ ('',     '# Src.', '|', 'Recall', 'Recall', '|', 'Precision', 'Precision', '|', '',        ''   ) ]);
        push(@tab, [ ('Show', 'Files',  '|', 'Numer',  'Denom',  '|', 'Numer',     'Denom',     '|', 'Recall', 'Precision') ]);
        push(@tab, [ ('-----','-----',  '|', '------', '------', '|', '---------', '---------', '|', '------', '---------') ]);
        my($meanPrecisionNum, $meanPrecisionDen, $meanRecallNum, $meanRecallDen, $meanRecall, $meanPrecision) = (0,0,0,0,0,0); 
        foreach $s(@bkeys){
            $Pmiss = ($TDTref{'results'}{'Seg_params'}{'broadcast'}{$s}{'Pmiss_num'}/
                      $TDTref{'results'}{'Seg_params'}{'broadcast'}{$s}{'Pmiss_denom'});
            $Pfa   = ($TDTref{'results'}{'Seg_params'}{'broadcast'}{$s}{'Pfa_num'}/
                      $TDTref{'results'}{'Seg_params'}{'broadcast'}{$s}{'Pfa_denom'});
            my($PrecallNum) = $TDTref{'results'}{'Seg_params'}{'broadcast'}{$s}{'Pmiss_denom'} - $TDTref{'results'}{'Seg_params'}{'broadcast'}{$s}{'Pmiss_num'};
	    my($PrecallDen) = $TDTref{'results'}{'Seg_params'}{'broadcast'}{$s}{'Pmiss_denom'};
            my($Precall) = ( $PrecallNum / $PrecallDen);
            my($PprecisionNum) = $TDTref{'results'}{'Seg_params'}{'broadcast'}{$s}{'Pmiss_denom'} - $TDTref{'results'}{'Seg_params'}{'broadcast'}{$s}{'Pmiss_num'};
            my($PprecisionDen) = $PprecisionNum + $TDTref{'results'}{'Seg_params'}{'broadcast'}{$s}{'Pfa_num'};
            my($Pprecision) = ( $PprecisionNum / $PprecisionDen);
#           printf("    Recall = ( $fmt / $fmt) = %f \n", $PrecallNum, $PrecallDen, $Precall);
#           printf("    Precision = ( $fmt / $fmt) = %f \n", $PprecisionNum, $PprecisionDen, $Pprecision);
            
            push(@tab, [ ($s,
                          sprintf("%4d",$TDTref{'results'}{'Seg_params'}{'broadcast'}{$s}{'n_source'}),
                          '|',
                          sprintf("%d", $PrecallNum),
                          sprintf("%d", $PrecallDen),
                          '|',
                          sprintf("%d", $PprecisionNum),
                          sprintf("%d", $PprecisionDen),
                          '|',
                          sprintf("%.4f",$Precall),
                          sprintf("%.4f",$Pprecision),
                          ) ]);
            $meanPrecisionNum += $PprecisionNum;
            $meanPrecisionDen += $PprecisionDen;
            $meanRecallNum += $PrecallNum;
            $meanRecallDen += $PrecallDen;

            $meanRecall += $Precall;
            $meanPrecision += $Pprecision;
        }
#       $meanRecall = $meanRecallNum / $meanRecallDen;
#       $meanPrecision = $meanPrecisionNum / $meanPrecisionDen;
        push(@tab, [ ('-----','-----',  '|', '------', '------', '|', '---------', '---------', '|', '------', '---------') ]);
        my($PrecallNum) = $TDTref{'results'}{'Seg_params'}{'Pmiss_denom'} - $TDTref{'results'}{'Seg_params'}{'Pmiss_num'};
        my($PrecallDen) = $TDTref{'results'}{'Seg_params'}{'Pmiss_denom'};
        my($Precall) = ( $PrecallNum / $PrecallDen);
        my($PprecisionNum) = $TDTref{'results'}{'Seg_params'}{'Pmiss_denom'} - $TDTref{'results'}{'Seg_params'}{'Pmiss_num'};
        my($PprecisionDen) = $PprecisionNum + $TDTref{'results'}{'Seg_params'}{'Pfa_num'};
        my($Pprecision) = ( $PprecisionNum / $PprecisionDen);
        push(@tab, [ ("Sums",
                      sprintf("%4d",$TDTref{'results'}{'Seg_params'}{'n_source'}),
                      '|',
                      sprintf("%d", $PrecallNum),
                      sprintf("%d", $PrecallDen),
                      '|',
                      sprintf("%d", $PprecisionNum),
                      sprintf("%d", $PprecisionDen),
                      '|',
                      sprintf("%.4f",$Precall),
                      sprintf("%.4f",$Pprecision),
                      ) ]);
        push(@tab, [ ("Means",
                      sprintf("%4d",$TDTref{'results'}{'Seg_params'}{'n_source'} / ($#bkeys+1)) ,
                      '|',
                      sprintf("%d", $meanRecallNum/ ($#bkeys+1)),
                      sprintf("%d", $meanRecallDen/ ($#bkeys+1)),
                      '|',
                      sprintf("%d", $meanPrecisionNum/ ($#bkeys+1)),
                      sprintf("%d", $meanPrecisionDen/ ($#bkeys+1)),
                      '|',
                      sprintf("%.4f",$meanRecall/ ($#bkeys+1)),
                      sprintf("%.4f",$meanPrecision/ ($#bkeys+1)),
                      ) ]);

        print OUT  "\n\n                          pvm's Unofficial Recall/Precision Numbers\n\n";
	&tabby(*OUT, \@tab,'l',2,"    ");
    }
    
    print OUT "\n";
    print OUT "--------------- End of TDT Segmentation Task Performance Report";
    print OUT "  --------------\n";
    print OUT "----------------------------------------";
    print OUT "---------------------------------------\n";

    EDES_delete_from_avalue("System");

    close OUT;
}

sub make_DET_plot{
    my($rh_TDTref, $DETFile, $DETTitle) = @_;
    
    my ($s, $Pmiss, $Pfa);

    print "Producing DET source cloud plot, file '${DETFile}.plt'\n" if ($main::Vb == 1);
   
    open(PLT,"> ${DETFile}.plt") ||
	die("unable to open DET gnuplot file ${DETFile}.plt");

    &write_gnuplot_DET_header(*PLT, $DETTitle,
			      0.01, 90, 1, 90);
    ### Source scores
    open(DAT,"> ${DETFile}.DET.0") ||
	die("unable to open DET data file ${DETFile}.DET.0");    
    foreach $s(keys %{ $rh_TDTref->{'results'}{'Seg_params'}{'broadcast'} }){
	$Pmiss = ($rh_TDTref->{'results'}{'Seg_params'}{'broadcast'}{$s}{'Pmiss_num'}/
		  $rh_TDTref->{'results'}{'Seg_params'}{'broadcast'}{$s}{'Pmiss_denom'});
	$Pfa   = ($rh_TDTref->{'results'}{'Seg_params'}{'broadcast'}{$s}{'Pfa_num'}/
		  $rh_TDTref->{'results'}{'Seg_params'}{'broadcast'}{$s}{'Pfa_denom'});
	printf DAT ("%f %f\n",&ppndf($Pmiss), &ppndf($Pfa));
    }
    close(DAT);

    ### overall score
    $Pmiss = ( $rh_TDTref->{'results'}{'Seg_params'}{'Pmiss_num'}/
	      $rh_TDTref->{'results'}{'Seg_params'}{'Pmiss_denom'});
    $Pfa   = ($rh_TDTref->{'results'}{'Seg_params'}{'Pfa_num'}/
	      $rh_TDTref->{'results'}{'Seg_params'}{'Pfa_denom'});
    open(DAT,"> ${DETFile}.DET.1") ||
	die("unable to open DET data file ${DETFile}.DET.1");
    printf DAT ("%f %f\n",&ppndf($Pmiss), &ppndf($Pfa));
    close(DAT);

    ### Write the plot line
    print PLT ",\\\n";
    print PLT "    '${DETFile}.DET.0' using 2:1 title '".
	$rh_TDTref->{'results'}{'Seg_params'}{'System'}." source score cloud' with points, \\\n";
    print PLT "    '${DETFile}.DET.1' using 2:1 title '".
	$rh_TDTref->{'results'}{'Seg_params'}{'System'}." story weighted score' with points\n";

    close PLT;
}

sub Segmentation_Eval{
    my($Sysout, $Index, $rh_TDTref, $FrameSize, $OmitNonNews) = @_;
    my($inrec, $src, $pnt, $source, $broadcast);
    my(@HypPointers, $System, $DefPeriod, $PointerType, $last_point);
    my($Convert_recid_to_chars) = 0;

    print "Performing segmentation scoring on '$Sysout'.\n" if ($main::Vb > 0);
    print "   (one period printed per source file)\n" if ($main::Vb == 1);

    die("Segmentation system output file '$Sysout' not found") 
	if (! -f $Sysout);
    $rh_TDTref->{'results'}{'Seg_params'}{'System_Output'} = $Sysout;
    open(SYS,$Sysout) || die("Unable to open Segmentation system ".
			     "output file '$Sysout'");
    ### Read in the header 
    $_ = <SYS>;
    $rh_TDTref->{'results'}{'Seg_params'}{'Desc'} = "";
    if ($_ =~ /^#/) {
	### Save the description
	chop;
	($rh_TDTref->{'results'}{'Seg_params'}{'Desc'} = $_) =~ s/^#\s*//;
	### Read until we find data
	while ($_ =~ /^#/){  $_ = <SYS>;  }       
    }
	
    # parse the information line
    s/^\s+//;
    ($System, $DefPeriod, $PointerType) = split;
    $PointerType =~ tr/a-z/A-Z/;
    die("Illegal pointer type '$PointerType' != RECID or TIME") 
	if ($PointerType !~ /^(RECID|TIME)$/);
    die("System output Pointer type '$PointerType' but index file".
	" pointer type is '".
	$rh_TDTref->{"IndexList"}{$Index}{'index_pointer_type'}."'")
	if ($rh_TDTref->{"IndexList"}{$Index}{'index_pointer_type'}ne $PointerType);
    if ($PointerType eq "RECID"){
	print STDERR ("Warning: Illegal RECID deferral period ".
		      "'$DefPeriod' != 100, 1000 or 10000") 
	    if ($DefPeriod !~ /^(100|1\,*000|10\,*000)$/);
    } else {
	print STDERR ("Warning: Illegal TIME deferral period ".
	    "'$DefPeriod' != 30, 300 or 3000") 
	    if ($DefPeriod !~ /^(30|300|3\,*000)$/);
    }
    ### Set upt the scoring structure
     
    $rh_TDTref->{'results'}{'Seg_params'}{'Pmiss_num'} = 0;
    $rh_TDTref->{'results'}{'Seg_params'}{'Pmiss_denom'} = 0;
    $rh_TDTref->{'results'}{'Seg_params'}{'Pfa_num'} = 0;
    $rh_TDTref->{'results'}{'Seg_params'}{'Pfa_denom'} = 0;
    $rh_TDTref->{'results'}{'Seg_params'}{'n_source'} = 0;

    $rh_TDTref->{'results'}{'Seg_params'}{'System'} = $System;
    $rh_TDTref->{'results'}{'Seg_params'}{'Deferral'} = $DefPeriod;

    if ($PointerType eq "TIME" && $FrameSize ne ""){
	$FrameSize = 15.0;
    } elsif ($PointerType eq "RECID" && $FrameSize eq ""){
	$FrameSize = 50;
	if ($rh_TDTref->{"IndexList"}{$Index}{'test:source_language'} eq "man"){
	    $FrameSize = 75;
	    if ($rh_TDTref->{"IndexList"}{$Index}{'source_condition'} eq "bnasr" &&
		$rh_TDTref->{"IndexList"}{$Index}{'test:content_language'} eq "nat"){
		$Convert_recid_to_chars = 1;
	    }
	}
    } elsif ($PointerType !~ /(RECID|TIME)/){
	die "Unknown Pointer Type '$PointerType'";
    }    
    $rh_TDTref->{'results'}{'Seg_params'}{'FrameSize'} = $FrameSize;

    ### Let's Party, Read in data until the filename changes
    @HypPointers = ();
    $last_point = 0.0;

    while (! eof(SYS)){
	($inrec = <SYS>) =~ s/^\s+//;
	$inrec =~ s/#.*$//;
	next if ($inrec =~ /^\s*$/);
	($src, $pnt) = split(/\s+/,$inrec);
	#### Translate the source name int an appropriate form
	$src =~ s:^.*/::;
	$src =~ s:\.mt(tkn|as[r0-9])$::;
	$src =~ s:\.(tkn|as[r0-9])$::;

	if ($#HypPointers == -1){
	    $source = $src;
	} elsif ($source ne $src){
	    #### Record the broadcast identifier
	    ($broadcast = $source) =~ s/^.*_([^_]+_[^_]+)$/$1/;

	    &SegSscore(\@HypPointers, $rh_TDTref,
		       \%{ $rh_TDTref->{'results'}{'Seg_params'} },
		       $source, $PointerType, $FrameSize,
		       $OmitNonNews, $broadcast, $Convert_recid_to_chars);
	    
	    @HypPointers = ();
	    $source = $src;
	} else {
	    #### check for ascending order
	    if (($pnt - $last_point) < 0.00001){
		print STDERR "Warning: decisions for input file $src are not in ascending order\n";
	    }
	}
	push (@HypPointers, $pnt);
	$last_point = $pnt;		
    }
    if ($#HypPointers > -1){
	#### Record the broadcast identifier
	($broadcast = $source) =~ s/^.*_([^_]+_[^_]+)$/$1/;
	&SegSscore(\@HypPointers, $rh_TDTref, 
		   \%{ $rh_TDTref->{'results'}{'Seg_params'} },
		   $source, $PointerType, $FrameSize,
		   $OmitNonNews, $broadcast, $Convert_recid_to_chars);
    }	    
	
   print "\n" if ($main::Vb == 1); 

   close(SYS);
}

sub SegSscore{
    my($ra_HypPointers, $rh_TDTref, $rh_Ans, $source, $PointerType, $FrameSize, $OmitNonNews, $broadcast, $Convert_recid_to_chars) = @_;
    my(@RefPointers) = ();
    my(@RefOmitFlags) = ();
    my($begin_attr, $end_attr, $origin, $base);
    my($i, $o, $k, $s);

    if ($PointerType eq "RECID"){
	($begin_attr, $end_attr, $base) = ('Brecid', 'Erecid', 1);
    } elsif ($PointerType eq "TIME"){
	($begin_attr, $end_attr, $base) = ('Bsec', 'Esec', 0);
    } else {
	die "Unknown Pointer Type '$PointerType'";
    }

    if ($main::Vb == 1){ print "."; &flush(*STDOUT); }
    print "Scoring '$source' $PointerType\n" if ($main::Vb > 5);

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
    $rh_TDTref->{'results'}{'Scored_files'}{$source} = 1;
    $rh_TDTref->{'results'}{'Seg_params'}{'n_source'} ++;

    ## inititalize the by-broadcast structure
    if (defined($rh_Ans->{'broadcast'}{$broadcast})){
	$rh_Ans->{'broadcast'}{$broadcast}{'n_source'} ++;
    } else {
	$rh_Ans->{'broadcast'}{$broadcast}{'Pmiss_num'} = 0;
	$rh_Ans->{'broadcast'}{$broadcast}{'Pmiss_denom'} = 0;
	$rh_Ans->{'broadcast'}{$broadcast}{'Pfa_num'} = 0;
	$rh_Ans->{'broadcast'}{$broadcast}{'Pfa_denom'} = 0;
	$rh_Ans->{'broadcast'}{$broadcast}{'n_source'} = 1;
    }

    ### Remember the per show information
    $rh_Ans->{'source'}{$source}{'Pmiss_num'} = 0;
    $rh_Ans->{'source'}{$source}{'Pmiss_denom'} = 0;
    $rh_Ans->{'source'}{$source}{'Recall_denom'} = 0;
    $rh_Ans->{'source'}{$source}{'Precision_denom'} = 0;
    $rh_Ans->{'source'}{$source}{'Pfa_num'} = 0;
    $rh_Ans->{'source'}{$source}{'Pfa_denom'} = 0;
    $rh_Ans->{'source'}{$source}{'n_source'} = 1;

    ## Extract the reference pointers
    foreach ($i=0; $i<= $#{ $rh_TDTref->{'bsets'}{$source}{'boundary'} }; $i++){
	if ($rh_TDTref->{'bsets'}{$source}{'boundary'}[$i]{$begin_attr} ne ""){
	    push(@RefPointers,
		 $rh_TDTref->{'bsets'}{$source}{'boundary'}[$i]{$begin_attr});
	    if ($rh_TDTref->{'bsets'}{$source}{'boundary'}[$i]{'doctype'} eq "NEWS"){
		push(@RefOmitFlags,0);
	    } else {
		if ($OmitNonNews) {
		    push(@RefOmitFlags,1);
		} else {
		    push(@RefOmitFlags,0);	
		    #$rh_Ans->{'source'}{$source}{'Recall_denom'} ++;
		    #$rh_Ans->{'Recall_denom'} ++;
		    #$rh_Ans->{'broadcast'}{$broadcast}{"Recall_denom"} ++;
		}
	    }
	}

	#### Merge OMITED Regions!!!!!
	if ($#RefOmitFlags > 0 && 
	    $RefOmitFlags[$#RefOmitFlags] == 1 &&
	    $RefOmitFlags[$#RefOmitFlags-1] == 1){
	    print "   -- Merging omitted docs that begin at ".
		$RefPointers[$#RefPointers-1]." and ".
		    $RefPointers[$#RefPointers]."\n"
		if ($main::Vb > 10);
	    splice(@RefOmitFlags,$#RefOmitFlags,1);
	    splice(@RefPointers,$#RefPointers,1);
	}
    }
    #### The origin is the first boundary record's begin time!!!!
    $o = 0;
    while ($o <= $#{ $rh_TDTref->{'bsets'}{$source}{'boundary'}} &&
	   ($origin = $rh_TDTref->{'bsets'}{$source}{'boundary'}[$o]{$begin_attr}) eq "") {
	$o++; }
    die "Unable to find starting point for segmentation scoring"
	if ($o > $#{ $rh_TDTref->{'bsets'}{$source}{'boundary'}});

    ### Convert the Omitflags list to indicate the previous story type
    splice(@RefOmitFlags,0,0,0);

    ### Add the end time/recid of the last story to bound the search    
    $o = $#{ $rh_TDTref->{'bsets'}{$source}{'boundary'} };
    while ($o >= 0 && $rh_TDTref->{'bsets'}{$source}{'boundary'}[$o]{$end_attr} eq ""){
	$o--; }
    die "Error: unable to set reference ending bound\n" if ($o < 0);
    push(@RefPointers,
	 $rh_TDTref->{'bsets'}{$source}{'boundary'}[$o]{$end_attr});
    
    if ($Convert_recid_to_chars) {
	Convert_recid_to_charid($rh_TDTref->{'bsets'}{$source}{'indexsourcefile'},
				$ra_HypPointers, \@RefPointers);
    }

    &fast_seg_score($rh_Ans, $origin, $base, $FrameSize, $ra_HypPointers,
		    \@RefPointers, \@RefOmitFlags, $broadcast, $source);

    if ($main::Vb > 10){
	print "Seg Scoring Structure\n";
	foreach $k(keys %$rh_Ans){ print "   $k $rh_Ans->{$k}\n" if ($k !~ /broadcast/)}
	print "   broadcast\n";
	foreach $s(keys %{ $rh_Ans->{'broadcast'} }) {
	    foreach $k(keys %{ $rh_Ans->{'broadcast'}{$s} }) {
		print "      $s $k -> ".$rh_Ans->{'broadcast'}{$s}{$k}."\n";
	    }	
	}
    }
}

sub Convert_recid_to_charid{
    my($tknfile, $ra_hyp, $ra_ref) = @_;
	
    ### Build a list of numbers to find
    my %num_lut = ();
    my %th;
    my $charcnt = 0;
    my $i;
    foreach (@$ra_hyp, @$ra_ref) {$num_lut{$_} = -1}
    
    ### Build a lookup table for each word in the nums list
    open(TKN,$tknfile) || die("Unable to open token file ".$tknfile);
    while (<TKN>){
	next if ($_ !~ /<W/);
	
	### Divide the line
	s/<\S+\s+(.*)>\s*/$1 tkn /;
	%th = split(/[=\s]/);
	
	## Extract data
	$num_lut{$th{"recid"}} = $charcnt+1 if (defined($num_lut{$th{"recid"}}));
	$charcnt += int((length($th{"tkn"}) + 1)/2);
    }
    close TKN;

    ### Convert the numbers
    foreach ($i=0; $i<=$#$ra_hyp; $i++){ $ra_hyp->[$i] = $num_lut{$ra_hyp->[$i]};    }
    foreach ($i=0; $i<=$#$ra_ref; $i++){ $ra_ref->[$i] = $num_lut{$ra_ref->[$i]};    }
}


#   Frame Size = Fs = 5
#
#   Hyp:      1          1314         27+28        
#             ------------==--------------------------
#    Delta:   11111111000001111
#
#    Delta:   110000011111111111111111
#   Ref:      1     78                      33+34
#             ------==------------------------------
#             12
#             I
#
#   Case 1:   D(hyp,S_i, S_i+Fs) == 1   &&  D(ref,S_i,S_I+Fs) == 1
#   Case 2:   D(hyp,S_i, S_i+Fs) == 1   &&  D(ref,S_i,S_I+Fs) == 0
#   Case 3:   D(hyp,S_i, S_i+Fs) == 0   &&  D(ref,S_i,S_I+Fs) == 1
#   Case 4:   D(hyp,S_i, S_i+Fs) == 0   &&  D(ref,S_i,S_I+Fs) == 0

#
sub fast_seg_score{
    my($rh_Ans, $Init_S_i, $base, $Fs, $ra_Hyp, $ra_Ref, $ra_Omit, $broadcast, $source) = @_; 
    my($max_adv, $k); 
    my($S_i) = $Init_S_i;
    ### The END of the search area
    my($max_S_i) = $ra_Ref->[$#$ra_Ref] - $Fs;

    if ($main::Vb > 10){
	print "   Hyp  $#$ra_Hyp ".join("_",@$ra_Hyp)."'\n" if ($main::Vb > 10);
	print "   Ref  $#$ra_Ref '".join("_",@$ra_Ref)."'\n";
	print "   Omit $#$ra_Omit '".join("_",@$ra_Omit)."'\n";
    }

    ### Push onto the end of the HYP array, the maximum value,  This simplifies
    ### the code sincer there will ALWAYS be data in both hyp and ref
    push(@$ra_Hyp,$ra_Ref->[$#$ra_Ref]) if ($ra_Hyp->[$#$ra_Hyp] < $ra_Ref->[$#$ra_Ref]);

    if ($main::Vb > 15){
	print "max_S_i = $max_S_i,  S_i = $S_i\n";
	print "   Hyp ".join(" ",@$ra_Hyp)."\n";
	print "   ra_Ref ".join(" ",@$ra_Ref)."\n";
    }
    while ($max_S_i - $S_i > 0.001){
	### Destructive make the first element in both the ra_Ref and hyp
	### the first number > S_i
	while ($#$ra_Hyp >= 0 && $ra_Hyp->[0] <= $S_i){ splice(@$ra_Hyp,0,1);  }
	while ($#$ra_Ref >= 0 && $ra_Ref->[0] <= $S_i){ splice(@$ra_Ref,0,1); splice(@$ra_Omit,0,1);}
	
	if ($main::Vb >= 15){
	    print "------------------------------------\n";
	    print "SS: S_i= $S_i ra_Hyp->[0]= $ra_Hyp->[0] ra_Ref->[0]= $ra_Ref->[0] ".
		"ra_Omit->[0]= $ra_Omit->[0]  \$#\$ra_Hyp=$#$ra_Hyp  \$#\$ra_Ref=$#$ra_Ref\n";
	    print "if ($S_i + $Fs < $ra_Hyp->[0]) = ".($S_i + $Fs < $ra_Hyp->[0])."\n";
	    print "if ($S_i + $Fs < $ra_Ref->[0]) = ".($S_i + $Fs < $ra_Ref->[0])."\n";
	}
	
	if ($ra_Omit->[0] == 1){
	    print "ra_Omit TRUE:\n" if ($main::Vb >= 15);
	    if ($#$ra_Ref == 0){
		# this is the last ra_Ref story marker, skip the rest
		print "  Final ra_Ref segment completely skipped\n" if ($main::Vb >= 15);
		$S_i = $max_S_i + 1;
		next;
	    } elsif ($S_i + $Fs >= $ra_Ref->[0]){
		# Do nothing, the emit region is smaller than the FrameSize
		print "  Do nothing, ra_Omit region smaller that FS\n" if ($main::Vb >= 15);
	    } else {
		### There is at least a word that must be omitted!!!
		printf("  Advanced S_i= $S_i by %d to %d:\n",
		       $ra_Ref->[0] - $Fs - $S_i,$ra_Ref->[0] - $Fs)
		    if ($main::Vb >= 15);	
		$S_i = $ra_Ref->[0] - $Fs;
		next;
	    }
	}

	### Decide on the Case!!!
	if ($S_i + $Fs < $ra_Hyp->[0]){
	    ### ra_Hyp is in a delta==1 range
	    if ($S_i + $Fs < $ra_Ref->[0]){
		### ra_Ref is in a delta==1 range
		print "Case 1: \n" if ($main::Vb >= 15);
		$max_adv = &MIN(($ra_Hyp->[0] - ($S_i + $Fs)),
				($ra_Ref->[0] - ($S_i + $Fs)),
				($max_S_i - $S_i + $base));
		$rh_Ans->{"Pfa_denom"}   += $max_adv;
		$rh_Ans->{'broadcast'}{$broadcast}{"Pfa_denom"}   += $max_adv;
		$rh_Ans->{'source'}{$source}{"Pfa_denom"}   += $max_adv;
	    } else {
		### ra_Ref is in a delta==0 range
		print "Case 2: \n" if ($main::Vb > 15);
		$max_adv = &MIN(($ra_Hyp->[0] - ($S_i + $Fs)),
				($ra_Ref->[0] - $S_i),
				($max_S_i - $S_i + $base));
		$rh_Ans->{"Pmiss_num"}   += $max_adv;
		$rh_Ans->{"Pmiss_denom"} += $max_adv;

		$rh_Ans->{'broadcast'}{$broadcast}{"Pmiss_num"}   += $max_adv;
		$rh_Ans->{'broadcast'}{$broadcast}{"Pmiss_denom"} += $max_adv;

		$rh_Ans->{'source'}{$source}{"Pmiss_num"}   += $max_adv;
		$rh_Ans->{'source'}{$source}{"Pmiss_denom"} += $max_adv;
	    }
	} else {
	    ### ra_Hyp is in a delta==0 range
	    if ($S_i + $Fs < $ra_Ref->[0]){
		### ra_Ref is in a delta==1 range
		print "Case 3: \n" if ($main::Vb >= 15);
		$max_adv = &MIN(($ra_Hyp->[0] - $S_i),
				($ra_Ref->[0] - ($S_i + $Fs)),
				($max_S_i - $S_i + $base));
		$rh_Ans->{"Pfa_num"}     += $max_adv;
		$rh_Ans->{"Pfa_denom"}   += $max_adv;

		$rh_Ans->{'broadcast'}{$broadcast}{"Pfa_num"}     += $max_adv;
		$rh_Ans->{'broadcast'}{$broadcast}{"Pfa_denom"}   += $max_adv;

		$rh_Ans->{'source'}{$source}{"Pfa_num"}     += $max_adv;
		$rh_Ans->{'source'}{$source}{"Pfa_denom"}   += $max_adv;
	    } else {
		### ra_Ref is in a delta==0 range
		print "Case 4: \n" if ($main::Vb >= 15);
		$max_adv = &MIN(($ra_Hyp->[0] - $S_i),
				($ra_Ref->[0] - $S_i),
				($max_S_i - $S_i + $base));
		$rh_Ans->{"Pmiss_denom"} += $max_adv;

		$rh_Ans->{'broadcast'}{$broadcast}{"Pmiss_denom"} += $max_adv;

		$rh_Ans->{'source'}{$source}{"Pmiss_denom"} += $max_adv;
	    }
	}
	$S_i += $max_adv;
	if ($main::Vb >= 15){
	    print "    max_adv = $max_adv\n";
	    for $k(sort(keys %$rh_Ans)) { print "  Res $k = $rh_Ans->{$k}\n" if ($k !~ /broadcast/);   }
	}
    }

}


