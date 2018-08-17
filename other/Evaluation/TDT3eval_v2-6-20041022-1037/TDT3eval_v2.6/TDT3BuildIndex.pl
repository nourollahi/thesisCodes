#!/usr/bin/perl -w

require "flush.pl";
require "TDT3.pm";
use strict;

$SIG{__WARN__} = sub { CORE::die "Warning:\n", @_, "\n" };

my $Expected_TDT3Version = "2.5";
my $prog = "TDT3BuildIndex.pl";

my $Usage ="Usage: $prog <OPTIONS> -R Rootdir -f DocList -O OutputDir\n".
"TDT library Version: ".&TDT3pm_Version()."\n".
"Desc: $prog builds the TDT3 evaluation indexes for an evaluation.  The\n".
"      script reads in a list of document filenames 'Doclist'.  The list\n".
"      should be one document filename per file without extensions.  The\n".
"      script then reads the boundary file information from the TDT3 \n".
"      corpus' root directory, 'Rootdir', and writes index files into\n".
"      'OutputDir'\n".
"Options\n".
"   -a [ccap|fdch|] -> For the ABC shows, choose either the closed captioning\n".
"                   transcripts (ccap) or the Federal Documents Clearing\n".
"                   House transcripts (fdch) in the index files.  The \n".
"                   default is not use either.\n".
"   -A              Do not search for alternative asr boundary files\n".
"   -j reltable  -> Specify the ON-TOPIC relavance table(s).  Filenames can be\n".
"                   sepaparted by a colon.  e.g., file1:file2:file3\n".
"   -J reltable  -> Specify the OFF-TOPIC relavance table(s).  Filenames can be\n".
"                   sepaparted by a colon.  e.g., file1:file2:file3\n".
"   -l LNKfile   -> Use the link database found in 'LNKfile' rather than\n".
"                   randomizing the docno selection from the '*.complete_annot' file.\n".
"   -L LNKfile   -> Dump the link database file toi 'LNKfile'..\n".
"   -r Randomseed   Specify a starting value to the random number generator. The\n".
"                   default seed is set to be the output of 'time()|\$\$'.  This is\n".
"                   to generate a prototype Link Detection key and\n".
"                   index file.\n".
"   -s           -> Run with all available speedups\n".
"   -S English=EXT[:EXT]*,Mandarin=EXT[:EXT]*,Arabic=EXT[:EXT]*  -> \n".
"                   Define the extensions to use for the ASR files.  The \n".
"                   default is the '.asr' extension.  The argument specifies\n".
"                   language-dependent extensions only.  Failback extensions\n".
"                   are identified using a colon separated list of extensions\n".
"                   for each language.  EXT can be any extension of 'as[r0-9]'\n".
"   -t Nt        -> Maximum number of training stories per topic for the\n".
"                   tracking indexes.  Default is 16\n".
"   -n Nn        -> Maximum number of certified off-topic training stories per\n".
"                   topic for the tracking indexes.  Default is 2.\n".
"   -T 'topic-regexp' ->\n".
"                   Build the tracking indexes files for only those defined\n".
"                   in the PERL5 regular expression.  Otherwise, all possible\n".
"                   topics are used.  There are macros defined for topic sets,\n".
"                   they are: TDT98_Train, TDT98_DevTest, TDT98_EvalTest, and\n".
"                   TDT99_mul.  See the documentation for their rebplacements.\n".
"   -v num       -> Set the verbose level to 'num'. Default 1\n".
"                   ==0 None, ==1 Normal, >5 Slight, >10 way too much\n".
"   -y YEAR      -> Build index files for the evaluation year 'YEAR'.  The default\n".
"                   is 1999.  Possible values are 1999 and 2000.\n".
"   -X nwt|bn    -> Exclude either the Newswire files, or the BN files.  (not both)\n".
"   -m           -> Do NOT force the randomized link detection index files to use only\n".
"                   the multilingual topics.  Instead all topics will be used.\n".
"\n";


die ("Error: Expected version of TDT3.pm is ".&TDT3pm_Version()." not $Expected_TDT3Version")
    if ($Expected_TDT3Version ne &TDT3pm_Version());


#### Globals Variables #####
my $Root = "";
my $DocList = "";
my $OutDir = "";
$main::Vb = 1;
my $Max_Nt = 16;
my $Max_Nn = 2;
my $ABCChoice = "";
my $NotABCChoice = "";
my $CommandLine = $0." ".join(" ",@ARGV);
my $Date = `date`; chop($Date);
my $TopicRegexp = "";
my $RandomSeed = time()|$$;
my %ASR_ext = ( "eng" => [ "asr" ], "man" => [ "asr" ] , "arb" => [ "asr" ] );
my $LNKdb = "";
my $LNKdbOut = "";
my $EvalYear = "1999";
my %Abbrev = ( "nwt+bnasr" => "nwba", "nwt+bnman" => "nwbm", 
	       "nwt" => "nw",         "bnman" => "bm",       "bnasr" => "ba", 
	       "eng" => "en",         "man" => "ma",         "arb" => "ar",    "mul" => "mu",    "nat" => "na");
my %Descriptions = ( "nwt+bnasr" => "NWT + BNews ASR Trans.",
	       "nwt+bnman" => "NWT + BNews Manual Trans.", 
	       "nwt" => "NWT",
	       "bnman" => "BNews Manual Trans.",
	       "bnasr" => "BNews ASR Trans.", 
	       "eng" => "English",
	       "man" => "Mandarin",
	       "arb" => "Arabic",
	       "mul" => "Multilingual",
	       "nat" => "Native");
my $ExcludeSrcType = "";
my $NONMultiLingualLinkDetectionTopicAllowed = 0;
my  @OnTopicRelevanceJudgementTables = ();
my  @OffTopicRelevanceJudgementTables = ();
my  $UseAutoBoundaries = "true";
my $BaseTaskIndex = "htd";
############################

############################ Main ###########################
{

    &ProcessCommandLine();
    print "Reading Document File List, and sorting by ASCII order\n" if ($main::Vb > 0);
    my @DocList = sort(&Read_file_into_array($DocList));

    print "Checking Database Contents\n" if ($main::Vb > 0);
    my $rh_DocInfo = BuildSourceInfo(\@DocList, $LNKdb, $Root);
    ReduceDocListByType(\@DocList, $rh_DocInfo);
    open(HTM,">$OutDir/index.htm") || die "Failed to open $OutDir/index.htm";

    StartHTML(*HTM);
    &BuildAuxInfo(*HTM, $OutDir, \@DocList, $rh_DocInfo);
    if ($ExcludeSrcType ne "bn"){
	&BuildSegmentationIndex(*HTM, $OutDir, \@DocList, $rh_DocInfo);
    } else {
	print "!!! Excluding segmentation files because BN was excluded\n";
    }
    if ($BaseTaskIndex eq "det"){
	&BuildDetectionIndex(*HTM, $OutDir, \@DocList, $rh_DocInfo, $Root);
    } else {
	&BuildHTDIndex(*HTM, $OutDir, \@DocList, $rh_DocInfo, $Root);
    }
    &BuildLinkIndex(*HTM, $OutDir, \@DocList, $rh_DocInfo, $LNKdb, $LNKdbOut, $Root);
    &BuildFSDIndex(*HTM, $OutDir, \@DocList, $rh_DocInfo, $Root);
    &BuildTrackingIndex(*HTM, $OutDir, \@DocList, $rh_DocInfo, $Root, $Max_Nt);
    &BuildSSDFiles(*HTM, $OutDir, \@DocList, $rh_DocInfo, $Root);

    FinishHTML(*HTM);
    close HTM;
    exit 0;
}
################# End of main  ###################

#################  Subroutines  ######################
sub die_usage{  my($mesg) = @_;    print "$Usage";   
		die("Error: ".$mesg."\n");  }

sub ProcessCommandLine{
    use Getopt::Std;

    getopts('mAsT:R:O:f:v:t:a:r:S:l:L:y:n:j:J:X:');

    die_usage("Root Directory for LDC TDT Corpus Req'd") if (!defined($main::opt_R));
    die_usage("Output Directory for index files Req'd") if (!defined($main::opt_O));
    die_usage("Document list file Req'd") if (!defined($main::opt_f));

    $Root = $main::opt_R;
    $OutDir = $main::opt_O;
    $DocList = $main::opt_f;
    $main::Vb = $main::opt_v if (defined($main::opt_v));
    $RandomSeed = $main::opt_r if (defined($main::opt_r));
    set_TDT3Fast($main::opt_s) if (defined($main::opt_s));
    $NONMultiLingualLinkDetectionTopicAllowed = $main::opt_m if (defined($main::opt_m));
    $LNKdb = $main::opt_l if (defined($main::opt_l));
    $LNKdbOut = $main::opt_L if (defined($main::opt_L));
    if (defined($main::opt_X)){
	die "Error: Excluded src can only be either 'nwt' or 'bn'" if ($main::opt_X !~ /^(nwt|bn)/);
	$ExcludeSrcType = $main::opt_X;
    }
    if (defined($main::opt_S)){
	die "Warning: Malformed ASR extensions via the -S option, ".
	    "expecting 'English=EXT[:EXT]*,Mandarin=EXT[:EXT]*,Arabic=EXT[:EXT]*'\n"
	    if ($main::opt_S !~ /^((English|Mandarin|Arabic)=(as[r0-9])(:as[r0-9])*)(,((English|Mandarin|Arabic)=(as[r0-9])(:as[r0-9])*))*$/);
	### Parse it
	my ($langext, $lang, $ext);
	foreach $langext(split(/,/,$main::opt_S)){
	    ($lang, $ext) = split(/=/,$langext);
	    $ASR_ext{abbrevLang($lang)} = [ split(/:/,$ext) ];
	}
    }
    if (defined($main::opt_T)){
	$TopicRegexp = $main::opt_T;
	Convert_Topic_set_macros(\$TopicRegexp);
    }
    $Max_Nt = $main::opt_t if (defined($main::opt_t));
    $Max_Nn = $main::opt_n if (defined($main::opt_n));
    if (defined($main::opt_a)){
	die_usage( "ABC transcript choice must be either 'ccap' or 'fdch'")
	    if ($main::opt_a !~ /^(ccap|fdch)/i);
	($ABCChoice = $main::opt_a) =~ tr/A-Z/a-z/;
	$NotABCChoice = ($ABCChoice eq "ccap") ? "fdch" : "ccap";
    }
    if (defined($main::opt_y)){
	$EvalYear = $main::opt_y;
	die_usage("Evaluation year most be either 1999 or 2000") 
	    if ($EvalYear !~ /^(1999|2000)$/);
    }
    die_usage("Option -j now REQUIRED") if (!defined($main::opt_j));
    foreach $_(split(/:/,$main::opt_j)){
	die_usage("Unable to read on-topic relevance table '$_'") if (! -r $_);
	push @OnTopicRelevanceJudgementTables, $_;
    }
    if (defined($main::opt_J)){
	foreach $_(split(/:/,$main::opt_J)){
	    die_usage("Unable to read off-topic relevance table '$_'") if (! -r $_);
	    push @OffTopicRelevanceJudgementTables, $_;
	}
    }
    if (defined($main::opt_A)){
	$UseAutoBoundaries = ! (defined($main::opt_A));
    }

    die_usage("TDT3 Root directory '$Root' does not exist") if (! -d $Root);
    die_usage("Output index directory '$OutDir' does not exist") if (! -d $OutDir);
    die_usage("Document file list '$DocList' does not exist") if (! -f $DocList);
}

sub BuildSourceInfo{
    my($ra_DocList, $LNKdb, $Root) = @_;
    my($src) = "";
    my($errors) = 0; 
    my(@types) = ();
    my($type) = "";
    my($dir, $aext);
    my(%DI) = ();
    my($root);
    my($docset_dtd) = find_FILE($Root, "dtd", Docset_DTDs());
    my($boundset_dtd) = find_FILE($Root, "dtd", Boundary_DTDs());
    my($complete_annot_dtd) = find_FILE($Root, "dtd", TopicRelevance_DTDs());
    my($vsgml) = 0;   #### Set to 1 if you want the sgml validated for each file
    my($vrecid) = 0;  #### Set to 1 if you want to check the recids in all the files

    if ($vsgml){
	print "   Validating the topic relevance file\n";
	my($rel_file);
	foreach $rel_file(@OnTopicRelevanceJudgementTables, @OffTopicRelevanceJudgementTables){
	    die "Error: Invalid SGML in relevence file '$rel_file'" 
		if (! SGML_valid($complete_annot_dtd, $rel_file));
	}
	if ($LNKdb ne ""){
	    my($LNKdb_dtd) = find_FILE($Root, "dtd", LNKdb_DTDs());
	    print "   Validating the link database file\n";
	    die "Error: Invalid SGML in link database file '$LNKdb'" 
		if (! SGML_valid($LNKdb_dtd, $LNKdb));
	}
    }

    foreach $src(@$ra_DocList){	
	### Set the default choice
	my(%tinfo) = ();

	($tinfo{"source"} = $src) =~ s/^.*(\S\S\S_\S\S\S)$/$1/;
	($tinfo{"date"} = $src) =~ s/^([^_]+_[^_]+).*$/$1/;

	$tinfo{"tknroot"} = $src;
	$tinfo{"asrroot"} = $src;
	if ($src =~ /ABC/ && ${ABCChoice} ne ""){
	    #### possible modify tknroot for the ABC data
	    $tinfo{"tknroot"} = "$src.${ABCChoice}";
	    if (! check(\%tinfo, \$errors, "opt", "tkn", $Root, "", $docset_dtd, $vsgml)){
		$tinfo{"tknroot"} = "$src.${NotABCChoice}";
		check(\%tinfo, \$errors, "req", "tkn", $Root, "", $docset_dtd, $vsgml);
	    }
	}
	
	$tinfo{"is_nwt+bn"} =      1;
	$tinfo{"is_nwt+bnman"} =   1;
	$tinfo{"is_nwt+bnasr"} =   1;
	$tinfo{"is_nwt"} =         ($tinfo{"tknroot"} =~ /(APW|NYT|XIN|ZBN|AFP|ALH|ANN|CNA|LAT|UMM)_/) ? 1 : 0;
	$tinfo{"is_bn"} =          ($tinfo{"tknroot"} =~ /(VOA|ABC|CNN|PRI|NBC|MNB|CBS|CTS|CNR|NTV|CTV)_/) ? 1 : 0;
	$tinfo{"is_bnasr"} =       $tinfo{"is_bn"};
	$tinfo{"is_bnman"} =       $tinfo{"is_bn"};
	die "Error: Source file ".$tinfo{"tknroot"}." not classified as either NWT or BNews"
	    if ($tinfo{"is_nwt"} == 0 && $tinfo{"is_bn"} == 0);
	$tinfo{"is_man"} = ($tinfo{"tknroot"} =~ /(_MAN)/) ? 1 : 0;
	$tinfo{"is_arb"} = ($tinfo{"tknroot"} =~ /(_ARB)/) ? 1 : 0;
	$tinfo{"is_eng"} = ($tinfo{"is_man"} == 1 || $tinfo{"is_arb"} == 1) ? 0 : 1;
	$tinfo{"lang"} =   ($tinfo{"is_man"} == 1) ? "man" : (($tinfo{"is_arb"} == 1) ? "arb" : "eng");
	$tinfo{"is_mul"} = 1;
	
	### Build the check list
	check(\%tinfo, \$errors, "req", "sgm",    $Root, "", "",          , $vsgml);
	check(\%tinfo, \$errors, "req", "tkn",    $Root, "", $docset_dtd  , $vsgml);
	check(\%tinfo, \$errors, "req", "tkn_bnd",$Root, "", $boundset_dtd, $vsgml);
        check_recid(\%tinfo, \$errors, "req", "tkn", "tkn_bnd", $Root) if ($vrecid);

	if ($tinfo{"is_bn"} == 1){
	    foreach $aext(@{ $ASR_ext{$tinfo{"lang"} } }){
		if (check(\%tinfo, \$errors, "opt", "asr",      $Root, $aext, $docset_dtd  , $vsgml)){
		    check(\%tinfo, \$errors, "req", "asr_bnd",  $Root, $aext, $boundset_dtd, $vsgml);
		    if ($UseAutoBoundaries){
			check(\%tinfo, \$errors, "req", "asr_bnd1", $Root, $aext, $boundset_dtd, $vsgml);
		    }
		    check_recid(\%tinfo, \$errors, "req", "asr", "asr_bnd", $Root) if ($vrecid);

		    if (! $tinfo{"is_eng"}){
			check(\%tinfo, \$errors, "req", "mtasr",      $Root, "$aext", $docset_dtd,   $vsgml);
			check(\%tinfo, \$errors, "req", "mtasr_bnd",  $Root, "$aext", $boundset_dtd, $vsgml);
			if ($UseAutoBoundaries){
			    check(\%tinfo, \$errors, "req", "mtasr_bnd1", $Root, "$aext", $boundset_dtd, $vsgml);
			}
			check_recid(\%tinfo, \$errors, "req", "mtasr", "mtasr_bnd", $Root) if ($vrecid);
		    }
		    last;   ### Abort the loop because we found and ASR file
		}
	    }
	    print "   Warning: No ASR file exists for '$src'\n" if (! defined($tinfo{"asr"}));
	}
        if (! $tinfo{"is_eng"}){
	    check(\%tinfo, \$errors, "req", "mttkn",      $Root, "", $docset_dtd,   $vsgml);
	    check(\%tinfo, \$errors, "req", "mttkn_bnd",  $Root, "", $boundset_dtd, $vsgml);
	    check_recid(\%tinfo, \$errors, "req", "mttkn", "mttkn_bnd", $Root) if ($vrecid);
	}
	$DI{$src} = \%tinfo ;
    }
    die "Aborting due to $errors errors\n" if ($errors > 0);
    return \%DI;
}

sub ReduceDocListByType{
    my ($DocList, $DocInfo) = @_;
    return if ($ExcludeSrcType eq "");
    print "Reducing the source list by removing $ExcludeSrcType files\n";
    my $numRemoved = 0;
    for (my $i=0; $i<@$DocList; $i++){
	if ($DocInfo->{$DocList->[$i]}->{"is_".$ExcludeSrcType} == 1){
	    $numRemoved ++;
	    splice(@$DocList, $i,1);
	    $i--;
	}
    }
    print "   $numRemoved $ExcludeSrcType source file removed.\n";
}

sub check{
    my($rh_tinfo, $rs_errors, $stat, $type, $Root, $opt_ext, $dtd, $vsgml) = @_;
    my($ext, $dir, $root);
    my(@exts, @dirs);
    die "Internal Error: ASR type requires an optional extension" 
	if ($type =~ /asr/ && $opt_ext eq "");
    SW1: {
	($type eq "sgm")       && do { @exts = ("sgm", "src_sgm");                  last SW1; };
	($type eq "tkn")       && do { @exts = ("tkn");                             last SW1; };
	($type eq "tkn_bnd")   && do { @exts = ("bndtkn", "tkn_bnd");               last SW1; };
	($type eq "mttkn")     && do { @exts = ("mtr", "mttkn");                    last SW1; };
	($type eq "mttkn_bnd") && do { @exts = ("bndmtr", "mttkn_bnd");             last SW1; };
	($type eq "asr")       && do { @exts = ("$opt_ext");                        last SW1; };
	($type eq "asr_bnd")   && do { @exts = ("bnd${opt_ext}", "${opt_ext}_bnd"); last SW1; };
	if ($UseAutoBoundaries){
	    ($type eq "asr_bnd1")  && do { @exts = ("bnd${opt_ext}", "${opt_ext}_bnd1");last SW1; };
	}
	($type eq "mtasr")     && do { @exts = ("mta", "mt${opt_ext}");             last SW1; };
	($type eq "mtasr_bnd") && do { @exts = ("bndmta", "mt${opt_ext}_bnd");      last SW1; };
	if ($UseAutoBoundaries){
	    ($type eq "mtasr_bnd1")&& do { @exts = ("bndmta", "mt${opt_ext}_bnd1");     last SW1; };
	}
	die "Internal Error: Undefined file type $type for extensions";
    }
    SW2: {
	($type eq "sgm")       && do { @dirs = ("sgml", "sgm", "src_sgm");          last SW2; };
	($type eq "tkn")       && do { @dirs = ("tkntext", "tkn");                  last SW2; };
	($type eq "tkn_bnd")   && do { @dirs = ("tables", "tkn_bnd");               last SW2; };
	($type eq "mttkn")     && do { @dirs = ("mtrtext", "mttkn");                last SW2; };
	($type eq "mttkn_bnd") && do { @dirs = ("tables", "mttkn_bnd");             last SW2; };
	($type eq "asr")       && do { @dirs = ("${opt_ext}text", $opt_ext);        last SW2; };
        ($type eq "asr_bnd")   && do { @dirs = ("tables", "${opt_ext}_bnd");        last SW2; };
	if ($UseAutoBoundaries){
	    ($type eq "asr_bnd1")  && do { @dirs = ("tables", "${opt_ext}_bnd1");       last SW2; };
	}
        ($type eq "mtasr")     && do { @dirs = ("mtatext", "mt${opt_ext}");         last SW2; };
        ($type eq "mtasr_bnd") && do { @dirs = ("tables", "mt${opt_ext}_bnd");      last SW2; };
	if ($UseAutoBoundaries){
	    ($type eq "mtasr_bnd1")&& do { @dirs = ("tables", "mt${opt_ext}_bnd1");     last SW2; };
	}
	die "Internal Error: Undefined file type $type for directories";
    }
    ### This statement disables old TDT2 directory structure information
    if (0){
	die "Sanity check failed, number of dirs > 1" if ($#dirs > 1 && $dirs[0] !~ /sgm/);
	shift(@dirs) if ($#dirs >= 1);
	die "Sanity check failed, number of exts > 1" if ($#exts > 1);
	shift(@exts) if ($#exts == 1);
    }

    foreach $ext(@exts){
	foreach $dir(@dirs){
	    $root = $rh_tinfo->{ ($type =~ /asr/) ? "asrroot" : "tknroot" };
	    
	    # print "   $Root/$dir/$root.$ext\n";
	    if (-f "$Root/$dir/$root.$ext") {
		$rh_tinfo->{$type} = "$dir/$root.$ext";
		die if (! defined($vsgml));
		if ($vsgml == 1 && $dtd ne "" && (! SGML_valid($dtd, "$Root/".$rh_tinfo->{$type}))){
		    print STDERR "Error: file '$rh_tinfo->{$type}' is invalid SGML\n";
		    $$rs_errors++;
		}
		return 1;
	    }
	}
    }
    if ($stat eq "req") {
	print STDERR "Error: missing file '$Root/{".
	    join(",",@dirs)."}/$root.{".join(",",@exts)."}'\n"
		if ($main::Vb > 0);
	$$rs_errors++;
	return 0;
    }
}

sub SGML_valid{
    my ($dtd, $file) = @_;
    my $ret;
    
    $ret = system("nsgmls -E 5 -s $dtd $file");
    ($ret == 0) ? 1 : 0;
}

sub check_recid{
    my($rh_tinfo, $rs_errors, $stat, $tkn, $bnd, $Root) = @_;
    my($min_recid_tkn) = -1;
    my($max_recid_tkn) = -1;
    my $sgmlsout;

    print "Verify Boundary Pairs, $rh_tinfo->{$tkn},  $rh_tinfo->{$bnd}\n";
    my ($tkn_min_recid, $tkn_max_recid) = TKN_is_valid($Root."/".$rh_tinfo->{$tkn}, $rs_errors);
    my ($bnd_min_recid, $bnd_max_recid) = BND_is_valid($Root."/".$rh_tinfo->{$bnd}, $rs_errors);
    if ($tkn_min_recid != $bnd_min_recid) {
	print STDERR "Error: Minimum recids for $rh_tinfo->{$tkn}($tkn_min_recid)".
	    " and $rh_tinfo->{$bnd}($bnd_min_recid) are different\n";
	$$rs_errors++;
    }
    if ($tkn_max_recid != $bnd_max_recid) {
	print STDERR "Error: Maximum recids for $rh_tinfo->{$tkn}($tkn_max_recid)".
	    " and $rh_tinfo->{$bnd}($bnd_max_recid) are different\n";
	$$rs_errors++;
    }

}

sub TKN_is_valid{
    my ($tknfile, $rs_errors) = @_;
    my ($min_recid, $max_recid) = (9999999, 0);
    my (%th);
    open (TKN, $tknfile) || die "Error: unable to open $tknfile";
    while(<TKN>){
	if ($_ =~ /<DOCSET/){
	} elsif ($_ =~ /<\/DOCSET/){
	} elsif ($_ =~ /<W/){
	    s/<\S+\s+([^>]+)>.*/$1/;
	    %th = split(/[\s=]+/);
	    $min_recid = $th{"recid"} if ($min_recid > $th{"recid"});
	    if ($max_recid +1 != $th{"recid"}){
		chomp;
		print STDERR "Error: missing recids between $max_recid and ".
		    $th{"recid"}." line $_ in File '$tknfile'\n";
		$rs_errors++;
	    }
	    $max_recid = $th{"recid"} if ($max_recid < $th{"recid"});
	} elsif ($_ =~ /<X/){
	    ;
	} else {
	    chomp;
	    die "Strange data '$_' in Tokenized text file '$tknfile'";
	}
    }
    ($min_recid, $max_recid);
}

sub BND_is_valid{
    my ($bndfile, $rs_errors) = @_;
    my ($min_recid, $max_recid) = (9999999, 0);
    my (%th);
    open (BND, $bndfile) || die "Error: unable to open $bndfile";
    while(<BND>){
	if ($_ =~ /<BOUNDSET/){
	} elsif ($_ =~ /<\/BOUNDSET/){
	} elsif ($_ =~ /<BOUNDARY/){
	    next unless ($_ =~ /recid/);
	    s/<\S+\s+([^>]+)>.*/$1/;
	    %th = split(/[\s=]+/);
	    $min_recid = $th{"Brecid"} if ($min_recid > $th{"Brecid"});
	    if ($max_recid +1 != $th{"Brecid"}){
		chomp;
		print STDERR "Error: missing recids between $max_recid and ".
		    $th{"Brecid"}." line $_ in File '$bndfile'\n";
		$rs_errors++;
	    }
	    $max_recid = $th{"Erecid"} if ($max_recid < $th{"Erecid"});
	} else {
	    chomp;
	    die "Strange data '$_' in Tokenized text file '$bndfile'";
	}
    }
    ($min_recid, $max_recid);
}

sub date_header_as_array{
    my(@a) = ();
    push @a, "#";
    push @a, "# Generated: on $Date";
    push @a, "#            by command '$CommandLine'";
    push @a, "#";
    \@a;
}

sub add_date{
    my($FIL) = @_;
    print $FIL join("\n",@{ date_header_as_array() })."\n";
}

sub BuildAuxInfo{
    my($HTM, $OutDir, $ra_DocList, $rh_DocInfo) = @_;
    my($ind_file) = "aux_info.ndx";
    my($file, $root);

    print "Building Auxiliary Information File\n" if ($main::Vb > 0);

    print $HTM "<P> <A name=\"auxinfo\"><H2> Auxiliary Information File</H2></A>";
    print $HTM "The evaluation specification declares certain side information to be available\n";
    print $HTM "to the automatic systems.  This information is contained in the auxiliary inforamtion\n";
    print $HTM "file <a HREF=\"$ind_file\">$ind_file</A>\n";

    open(IND,">$ind_file") || die("Unable to open index file '$ind_file' for write");
    ### Write the Header
    print IND "# Auxiliary Information File\n";
    &add_date(*IND);
		
    foreach $file(@$ra_DocList){
	foreach $root(sortuniq($rh_DocInfo->{$file}->{"tknroot"}, $rh_DocInfo->{$file}->{"asrroot"})){
	    print IND ($root." ".
		       $rh_DocInfo->{$file}->{"source"}." ".
		       ($rh_DocInfo->{$file}->{"lang"} eq "eng" ? "English" : 
			($rh_DocInfo->{$file}->{"lang"} eq "man" ? "Mandarin" :
			 ($rh_DocInfo->{$file}->{"lang"} eq "arb" ? "Arabic" : "Unknown" ) ) )." ".
		       $rh_DocInfo->{$file}->{"date"}."\n");
	}
    }
    close(IND);
}

sub BuildSegmentationIndex{
    my($HTM, $OutDir, $ra_DocList, $rh_DocInfo) = @_;
    my($src, $lang, $root, $file, $translate);
    
    print "Building Segmentation Indexes\n" if ($main::Vb > 0);

    print $HTM "<P><A name=\"seg\"><H2> Segmentation Index Files</H2></a>";
    print $HTM "<DIR>\n<TABLE border=2>\n";
    print $HTM "<TR> <TH> Source Condition <TH> Source Language <TH> Index Filename\n";

    foreach $src ("bnasr", "bnman"){
	foreach $lang("eng", "man", "arb"){
	    if ($lang eq "eng"){
		print $HTM "<TR> <TH rowspan=3>  ".$Descriptions{$src}." <TH> English ";
	    } elsif ($lang eq "man") {
		print $HTM "<TR> <TH> Mandarin ";
	    } elsif ($lang eq "arb") {
		print $HTM "<TR> <TH> Arabic ";
	    } else {
		die "Internal Error";
	    }
	    foreach $translate("nat"){
		my $iname = "seg_SR=${src}_TE=${lang},${translate}.ndx";
		my $ind_file = "$OutDir/$iname";
		print $HTM "<TD> <A HREF=\"$iname\"> $iname </A>\n";
		open(IND,">$ind_file") || die("Unable to open index file '$ind_file' for write");
		### Write the Header
		print IND "# SEGMENTATION RECID SRC=${src} TEST:SL=${lang} TEST:CL=${translate}\n";
		&add_date(*IND);
		
		foreach $file(@$ra_DocList){
		    if ($rh_DocInfo->{$file}->{"is_bn"} == 1 &&
			$rh_DocInfo->{$file}->{"is_$lang"} == 1){
			print IND $rh_DocInfo->{$file}->{($src eq "bnasr") ? "asr" : "tkn"}."\n"
			    if (defined($rh_DocInfo->{$file}->{"asr"}));
		    }
		}
		close(IND);
	    }
	}
    }
    print $HTM "</TABLE>\n</DIR>\n";
}

sub BuildHTDIndex{
    my($HTM, $OutDir, $ra_DocList, $rh_DocInfo, $Root) = @_;
    my($src, $lang, $translate);
    
    print "Building Hierarchical Topic Detection Indexes\n" if ($main::Vb > 0);
    
    print $HTM "<P><A name=\"fsd\"><H2> Hierarchical Topic Detection Index Files</H2></A>\n";
    print $HTM "<DIR>\n<TABLE border=2>\n";
    print $HTM "<TR> <TH> Source Condition\n".
	"     <TH> Source Language\n     <TH>     Content Language\n     <TH> Index Filename <TH> Story List Index Filename*\n";
    my @srcs = ("nwt+bnasr", "nwt+bnman");
    @srcs = ("nwt") if ($ExcludeSrcType eq "bn");
    @srcs = ("bnasr", "bnman") if ($ExcludeSrcType eq "nwt");
    my %TDTref;
    foreach $src (@srcs){
	print $HTM "<TR>\n    <TH rowspan=".(@srcs * 8)."> ".$Descriptions{$src}."\n";
	foreach $lang("mul", "eng", "man", "arb"){
	    print $HTM "<TR> " if ($lang ne "mul");
	    print $HTM "    <TH rowspan=2> ".langAbbrevToWord($lang)."\n";
	    foreach $translate("eng", "nat"){
		print $HTM "<TR> " if ($translate ne "eng");
		my $rname = "htd_SR=${src}_TE=${lang},${translate}";
		my $iname = "${rname}.ndx";
		my $slIname = "${rname}.slndx";
		my $ind_file = "$OutDir/$iname";
		my $sl_ind_file = "$OutDir/$slIname";
		
		print $HTM "    <TH> ".(($translate eq "nat") ? "Native" : "English")."\n";
		if ($lang eq "eng" && $translate eq "eng"){
		    print $HTM "     <TD>Not Defined by the Eval. Spec.\n";
		    next;
		} 
		print $HTM "     <TD> <A HREF=\"$iname\">$iname</A>\n";
		make_det_or_fsd_or_ssd_index($rh_DocInfo, $ind_file, "", "htd",
				      $ra_DocList, $src, $lang, $translate);
		print "Load $ind_file  -$Root\n";

		%TDTref = &Load_Boundaries_Into_TDTRef($Root,[($ind_file)],'HIEARCHICAL_DETECTION',
						       Boundary_DTDs(), "");

		print $HTM "     <TD> <A HREF=\"$slIname\">$slIname</A>\n";
		use Data::Dumper;
#		print Dumper(\%TDTref);
		my @docListData = ();
		push @docListData, "# STORY_LIST_INDEX DOCNO";
		push @docListData, @{ date_header_as_array() };
		foreach my $srcFile(sort keys %{ $TDTref{IndexList}->{$ind_file}->{contents} }){
		    my @stories = ();
		    foreach my $boundary(@{ $TDTref{bsets}->{$srcFile}->{boundary} }){
			push (@stories,$boundary->{docno}) if ($boundary->{doctype} eq "NEWS");			
		    }
		    my $indexSrcFile = $TDTref{bsets}->{$srcFile}->{indexsourcefile};
		    $indexSrcFile =~ s/\Q$Root\E\///;
		    push @docListData, "$indexSrcFile ".join(" ",@stories);
		}
		open (SLI, ">$sl_ind_file") || die "Failed to open Story List Index file '$sl_ind_file'";
		print SLI join("\n",@docListData)."\n";
		close SLI
	    }
	}
    }
    print $HTM "</TABLE>\n";
    print $HTM "* The Story List Index files are for use by the HTD evaluation code.  Systems MUST not use these files prior to scoring.\n";
    print $HTM "</DIR>\n";
}

sub BuildFSDIndex{
    my($HTM, $OutDir, $ra_DocList, $rh_DocInfo, $Root) = @_;
    my($src, $lang, $translate);
    
    print "Building First Story Detection Indexes\n" if ($main::Vb > 0);
    
    print $HTM "<P><A name=\"fsd\"><H2> First Story Detection Index Files</H2></A>\n";
    print $HTM "<DIR>\n<TABLE border=2>\n";
    print $HTM "<TR> <TH> Source Condition\n".
	"     <TH> Source Language\n     <TH>     Content Language\n     <TH> Index Filename\n";
    my @srcs = ("nwt+bnasr", "nwt+bnman");
    @srcs = ("nwt") if ($ExcludeSrcType eq "bn");
    @srcs = ("bnasr", "bnman") if ($ExcludeSrcType eq "nwt");
    foreach $src (@srcs){
	print $HTM "<TR> <TH> ".$Descriptions{$src}."\n";
	foreach $lang("eng"){
	    print $HTM "<TH> ".langAbbrevToWord($lang)."\n";
	    foreach $translate("nat"){
		my $rname = "fsd_SR=${src}_TE=${lang},${translate}";
		my $iname = "${rname}.ndx";
		my $ind_file = "$OutDir/$iname";
		
		print $HTM (($translate eq "nat") ? "     <TH> Native" : "<TR> <TH> English")."\n";
		if ($lang eq "eng" && $translate eq "eng"){
		    print $HTM "     <TD>Not Defined by the Eval. Spec.\n";
		    next;
		} 
		print $HTM "     <TD> <A HREF=\"$iname\">$iname</A>\n";

		make_det_or_fsd_or_ssd_index($rh_DocInfo, $ind_file, "", "fsd",
				      $ra_DocList, $src, $lang, $translate);
	    }
	}
    }
    print $HTM "</TABLE>\n</DIR>\n";
}

sub BuildLinkIndex{
    my($HTM, $OutDir, $ra_DocList, $rh_DocInfo, $LNKdb, $LNKdbOut, $Root) = @_;
    my($src, $lang, $translate, $ra_Master_LNK);
    my $do_random = ($LNKdb eq "") ? 1 : 0;
    
    print "Building Link Detection Indexes\n" if ($main::Vb > 0);
    if ($do_random){
	print "    Using randomized docno selection\n" if ($main::Vb > 0);
	print "    Random seed is: $RandomSeed\n" if ($main::Vb > 0);
	srand($RandomSeed);
    } else {
	print "    Using LNKdb database '$LNKdb'\n" if ($main::Vb > 0);
    }

    print $HTM "<P><A name=\"lnk\"><H2> Link Detection Index Files</H2></A>\n";
    print $HTM "<DIR>\n<TABLE border=2>\n";
    print $HTM "<TR> <TH> Source Language\n".
	"     <TH> Content Language\n".
	"     <TH> Source Condition\n".
	"     <TH> Index/Key Filenames\n";

    my ($det_ind_file, $lnk_ind_file, $lnk_key_file);
    my $prototypeSrc = ("nwt+bnasr");
    $prototypeSrc = ("nwt") if ($ExcludeSrcType eq "bn");
    $prototypeSrc = ("bn")  if ($ExcludeSrcType eq "nwt");
    my @srcs = ("nwt+bnasr", "nwt+bnman");
    @srcs = ("nwt") if ($ExcludeSrcType eq "bn");
    @srcs = ("bnasr", "bnman") if ($ExcludeSrcType eq "nwt");
    foreach $lang("mul", "man", "arb"){
	print $HTM "<TR> <TH rowspan=".(($lang eq "eng") ? 2 : 2 * @srcs).">".langAbbrevToWord($lang)."\n";
	if ($lang ne "mul") { print $HTM "<BR><BOLD>** not a sanctioned TDT test condition</BOLD>\n"; }

	if ($lang eq "mul"){
	    if ($do_random){
		$ra_Master_LNK = build_random_LNK($Root, "$OutDir/${BaseTaskIndex}_SR=".$prototypeSrc."_TE=mul,nat.ndx",
						  $ra_DocList, $rh_DocInfo);
	    } else {
		$ra_Master_LNK = build_LNK_from_db($Root, "$OutDir/${BaseTaskIndex}_SR=".$prototypeSrc."_TE=mul,nat.ndx",
						   $ra_DocList, $rh_DocInfo, $LNKdb);
	    }
	    
	    write_Master_LNK_as_LNKdb($ra_Master_LNK, $LNKdbOut."_lang=$lang") if ($LNKdbOut ne "");
	}

	foreach $translate("nat", "eng"){
	    next if ($lang eq "eng" && $translate eq "eng");
	    foreach $src (@srcs){
		print $HTM "<TR>\n" unless ($translate eq "nat" && $src eq $srcs[0]);
		    
		if ($src eq $srcs[0]){
		    print $HTM "    <TH rowspan=".scalar(@srcs)."> ".
			(($translate eq "nat") ? "Native" : "English")."\n";
		}
	       
		print $HTM "    <TH> ".$Descriptions{$src}."\n";

		$lnk_ind_file = "$OutDir/lnk_SR=${src}_TE=${lang},${translate}.ndx";
		$lnk_key_file = "$OutDir/lnk_SR=${src}_TE=${lang},${translate}.key";
		print $HTM "     <TD> <A HREF=\"$lnk_ind_file\">$lnk_ind_file</A>\n";
		print $HTM "      <A HREF=\"$lnk_key_file\">$lnk_key_file</A>\n";

		if ($lang eq "mul"){
		    $det_ind_file = "$OutDir/${BaseTaskIndex}_SR=${src}_TE=${lang},${translate}.ndx";
		    print "    Building files for $lnk_ind_file\n".
			"        ... from DETECTION index $det_ind_file\n"
			    if ($main::Vb > 1);
		    write_lnk_index($ra_Master_LNK, $det_ind_file, $lnk_ind_file, $lnk_key_file);
		} else {
		    my $src_lnk_ind_file = "$OutDir/lnk_SR=${src}_TE=mul,${translate}.ndx";
		    my $src_lnk_key_file = "$OutDir/lnk_SR=${src}_TE=mul,${translate}.key";
		    print "    Building files for $lnk_ind_file\n".
			"        ... from the filtered Link detection files\n"
			    if ($main::Vb > 1);
		    LinkFilter($src_lnk_ind_file, $lnk_ind_file, $lang, $rh_DocInfo);
		    LinkFilter($src_lnk_key_file, $lnk_key_file, $lang, $rh_DocInfo);
		}
	    }
	}
    }
    print $HTM "</TABLE>\n</DIR>\n";
}    

sub LinkFilter{
    my ($src, $dest, $lang, $rh_DocInfo) = @_;
    my ($write, $doc1, $doc2, $rest, $line, $file, $sourceCount, $name);
    open (SRC, $src) || die "Failed to open '$src' as source to filter link detection files";
    open (DEST, ">$dest")||die "Failed to open '$src' as destination to filter link detection files";
    $sourceCount = 1;
    while (<SRC>){
	$line = $_;
	$write = 1;
	if ($_ =~ /^# SOURCE_FILE/){ 
	    ($file = $line) =~ s:^[^/]+/([^\.]+)\..*$:$1:;
	    chomp $file;
	    if ($rh_DocInfo->{$file}->{"lang"} ne $lang) {
		$write = 0;
	    } else {
		chomp $line;
		($name = $line) =~ s:^.*\s+::;
		$line = "# SOURCE_FILE ".$sourceCount++." $name\n";  
	    }	    
	} elsif ($_ !~ /^#/){ 
	    ## Parse the line
	    ($doc1, $doc2, $rest) = split(/\s+/,$_, 3);
	    ($file = $doc1) =~ s:^[^/]+/([^\.]+)\..*$:$1:;
	    $write = 0 if ($rh_DocInfo->{$file}->{"lang"} ne $lang);
	    ($file = $doc2) =~ s:^[^/]+/([^\.]+)\..*$:$1:;
	    $write = 0 if ($rh_DocInfo->{$file}->{"lang"} ne $lang);
	}
	print DEST $line if ($write == 1);
    }
    close SRC;
    close DEST;
}

sub write_Master_LNK_as_LNKdb{
    my ($ra_Master_LNK, $OutLNKdb) = @_;
    my ($entry, $seed, $comp, $eval, $topic, $label);

    print "    Writing LNKdb to '$OutLNKdb'\n" if ($main::Vb > 0);
    open (OUT,">$OutLNKdb") || die "Error: Unable to open $OutLNKdb for writing";
    print OUT "<LINKSET>\n";
    foreach $entry(@{ $ra_Master_LNK }){
	($seed, $comp, $topic, $eval) = split(/\s+/,$entry);
	$label = ($eval eq "TARGET") ? "Y" : "N";
	print OUT "<LINK seed_docno=".lnkdocno2docno($seed).
	    " comp_docno=".lnkdocno2docno($comp)." label=$label>\n";
    }
    print OUT "</LINKSET>\n";
    close OUT;
}

sub dump_LNKset{
    my ($rh_LNKset) = @_;
    my ($seed, $comp, $attr);
    print "Dump of LKNset\n";
    foreach $seed(keys %{ $rh_LNKset->{"seed"} }){
	foreach $comp (keys %{ $rh_LNKset->{"seed"}{$seed}{"compare"} }){
	    print "   Seed=$seed(".$rh_LNKset->{"lnkdocno"}{$seed}.")";
	    print " Sn=".$rh_LNKset->{"seed"}{$seed}{"number"};
	    print " Comp=$comp(".$rh_LNKset->{"lnkdocno"}{$comp}.")";
	    foreach $attr (keys %{ $rh_LNKset->{"seed"}{$seed}{"compare"}{$comp} }){
		print " $attr=".$rh_LNKset->{"seed"}{$seed}{"compare"}{$comp}{$attr};
	    }	    
	    print "\n";	    
	}
    }
}

sub load_LNKset_from_LNKdb{
    my ($InLNKdb) = @_;
    my (%LNKset) = ();
    my (%Set_history) = ();
    my %th;
    my $sn = 1;
    my ($pairkey1, $pairkey2);

    print "    Reading LNKdb '$InLNKdb'\n" if ($main::Vb > 0);
    open (IN,"$InLNKdb") || die "Error: Unable to open $InLNKdb for reading";
    while (<IN>){
	next unless ($_ =~ /<LINK /i);
	s/<\S+\s+(.*)\s*>\s*$/$1/;
	%th = split(/[\s+=]/);

	#### Check the history
	$pairkey1 = $th{"seed_docno"}."-".$th{"comp_docno"};
	$pairkey2 = $th{"comp_docno"}."-".$th{"seed_docno"};
	if (defined($Set_history{$pairkey1}) || defined($Set_history{$pairkey2})){
	    print "    Warning: LNK pair '$pairkey1' already exists on line ".
		$Set_history{$pairkey1}.".  Skiping this pair on line $.\n";    
	    next;
	}
	$Set_history{$pairkey1} = $.;
	$Set_history{$pairkey2} = $.;

	$LNKset{"seed"}{$th{"seed_docno"}}{"number"} = $th{"seed_docno"}
	    unless (defined($LNKset{"seed"}{$th{"seed_docno"}}));
	$LNKset{"seed"}{$th{"seed_docno"}}{"compare"}{$th{"comp_docno"}} =
	    { "judgement" =>
		  ($th{"label"} eq "Y" ? "TARGET" : ($th{"label"} eq "N" ? "NONTARGET" : "OTHER" ))};
	### Make entries here to fill later
	$LNKset{"lnkdocno"}{$th{"seed_docno"}} = "undef";
	$LNKset{"lnkdocno"}{$th{"comp_docno"}} = "undef";
    }
    close IN;
    
    \%LNKset;
}

sub write_lnk_index{
    my ($ra_Master_LNK, $det_ind_file, $lnk_ind_file, $lnk_key_file) = @_;
    my ($i);
    my ($doc1, $doc2, $topic, $eval, $ndx_file);
    my ($doc1id, $doc2id);
    my (@Master_LNK);
    my %docinfo_to_ndx_lut = ();

    open (LNK_IND,">$lnk_ind_file") || die "Unable to open LNK index file '$lnk_ind_file' for write";
    open (LNK_KEY,">$lnk_key_file") || die "Unable to open LNK key file '$lnk_key_file' for write";

    ### Write the headers into the files, includind the validation key
    print LNK_IND "# LINK_DETECTION\n";
    &add_date(*LNK_IND);
    print LNK_IND "#\n";

    ### Generate the file sequence information
    print LNK_IND "# Source file sequence data\n";
    print LNK_IND "#\n";
    open (DET_IND,"$det_ind_file") || die "Unable to open DET index file '$det_ind_file' for read";
    $i = 1;
    while (<DET_IND>){		
	next if ($_ =~ /^\#/); 
	print LNK_IND "# SOURCE_FILE ".$i++." $_";  
	chomp;
	$ndx_file = $_;
	s:.*/(.*)\.[^.]+$:$1:;
	s/\.(ccap|fdch)$//;
	$docinfo_to_ndx_lut{$_} = $ndx_file;
    }
    close DET_IND;

    print LNK_IND "#\n";
    print LNK_IND "# Test fecord format : '<FILE_1>:<DOCNO_1> <FILE_2>:<DOCNO_2>'\n";
    print LNK_IND "#\n";    

    print LNK_KEY "# LINK_DETECTION\n";
    &add_date(*LNK_KEY);
    print LNK_KEY "# Record format : '<FILE_1>:<DOCNO_1> <FILE_2>:<DOCNO_2> TARGET|NONTARGET <TOPICID>'\n";
    print LNK_KEY "#\n";


    ### Sort the data, first order the docs within a line
    for ($i=0; $i<=$#$ra_Master_LNK; $i++){
	($doc1, $doc2, $topic, $eval) = split(/\s+/,$ra_Master_LNK->[$i]);
	if (lnkdocno2ind($doc1) > lnkdocno2ind($doc2)){
	    $ra_Master_LNK->[$i] = "$doc2 $doc1 $topic $eval";
	}
    }
    ### Now Sort the lines by doc1 and then by doc2
    @Master_LNK = sort sort_func_Master_LNK @$ra_Master_LNK;

    ### Now output the index and the key
    foreach (@Master_LNK){
	($doc1, $doc2, $topic, $eval) = split;

	die "Error: Unable to find docinfo file for story definition '$doc1' '".lnkdocno2docinfo_file($doc1)."'"
	    if (!defined($docinfo_to_ndx_lut{lnkdocno2docinfo_file($doc1)}));
	die "Error: Unable to find docinfo file for story definition '$doc2' ".lnkdocno2docinfo_file($doc2)."'"
	    if (!defined($docinfo_to_ndx_lut{lnkdocno2docinfo_file($doc2)}));

	$doc1id = $docinfo_to_ndx_lut{lnkdocno2docinfo_file($doc1)}.":".lnkdocno2docno($doc1);
	$doc2id = $docinfo_to_ndx_lut{lnkdocno2docinfo_file($doc2)}.":".lnkdocno2docno($doc2);

	print LNK_IND "$doc1id $doc2id\n";
	print LNK_KEY "$doc1id $doc2id $eval $topic\n";	
    }
	    
    close LNK_IND;
    close LNK_KEY;

    close DET_IND;
}

#sub handler{    die $_[0];}

sub sort_func_Master_LNK {
    my ($a_d1, $a_d2, $a_t, $a_evl) = split(/\s+/,$a);
    my ($b_d1, $b_d2, $b_t, $b_evl) = split(/\s+/,$b);
    lnkdocno2ind($a_d2) <=> lnkdocno2ind($b_d2)
	or
    lnkdocno2ind($a_d1) <=> lnkdocno2ind($b_d1)
	or
    $a cmp $b; 
}


sub build_random_LNK{
    my($Root, $det_ind_file, $ra_DocList, $rh_DocInfo) = @_;
    my (%TDTref) = ();
    my ($rh_bnd, @toplist, @levlist, $file, $t, %slist, %tlist, @slist_sort);
    my (%ontop,%offtop);
    my (@linked,@notlinked);
    my ($topic);
    my ($seedstory, $seedstory_time, $seedstory_day, $ots_time);
    my @Master_LNK = ();
    my $story_count = 0;
#    my $old_Vb = $main::Vb;
    my $old_Vb = 3;
    my $docinfo_file;
    my %used_story_pairs = ();
    my ($selected, $sid);

####  These two sets of variables control the languages for randomized link generation.
####  Someday this should be an command line option
    my (@languages) = ("eng", "man", "arb");
    my (@langconditions) = ("eng:eng", "eng:man", "man:eng",
			    "man:man", 
			    "arb:arb", "arb:eng", "eng:arb", "arb:man", "man:arb");
#    my (@languages) = ("eng");
#    my (@langconditions) = ("eng:eng");


    undef(%TDTref) if (%TDTref);
    $main::Vb = 0; 
    my(@IndexList) = ( $det_ind_file );
						   
    %TDTref = &Load_Boundaries_Into_TDTRef($Root,\@IndexList,$BaseTaskIndex eq "det" ? 'DETECTION' : 'HIEARCHICAL_DETECTION',
					   Boundary_DTDs(), "");
    &Add_Topic_Into_TDTref(\@OnTopicRelevanceJudgementTables,
			   TopicRelevance_DTDs(), \%TDTref, "true");
	    
    open(DETIND,$det_ind_file) || die("Failed to open detection index '$det_ind_file'");
    while(<DETIND>){		
	next if ($_ =~ /^\#/ || $_ =~ /^\s*$/);
	chomp;
	($file = $_) =~ s:.*/(.*)\.[^.]+$:$1:;
	($docinfo_file = $file) =~ s/\.(ccap|fdch)$//;
	foreach $rh_bnd(@{ $TDTref{'bsets'}{$file}{'boundary'} }){
	    @toplist = @{ $rh_bnd->{'topicid'} }; 
	    @levlist = @{ $rh_bnd->{'t_level'} }; 		    
	    next if ($rh_bnd->{'doctype'} ne 'NEWS');
	    foreach $t(0 .. $#toplist){
		$sid = $story_count++.":".$docinfo_file.":".$file.":".$rh_bnd->{'docno'}.":".$rh_DocInfo->{$file}->{"lang"};

		if (($TopicRegexp eq "" || $toplist[$t] =~ /^${TopicRegexp}$/) &&
		    ($levlist[$t] eq "YES") && ($#toplist <= 0)){
		    push(@slist_sort, $sid);
		    $slist{$slist_sort[$#slist_sort]} = $toplist[$t];

		    $tlist{$toplist[$t]} = 0 if (! defined($tlist{$toplist[$t]}));
		    $tlist{$toplist[$t]} ++;
		} elsif ($levlist[$t] eq "n/a") {
		    push(@slist_sort, $sid);
		    $slist{$slist_sort[$#slist_sort]} = "off";
		}
	    }
        }
    }
    close(DETIND);

    #### We have what we need, loop through the topics, select a seed, select the on-topic
    #### Select the off-topic
 TOPIC:
    foreach $topic (scramble(keys %tlist)){
	%ontop = (); %offtop = (); @linked = (); @notlinked = ();
	my ($i, $j, $sj, $si, $lang);
	my @day_gap = ();
	my @story_day = ();

	print "        Working on topic $topic\n" if ($old_Vb > 2);
	
	### Build a set of on-topic stories
	foreach (@slist_sort) {
	    if ($slist{$_} eq $topic){
		push (@{ $ontop{lnkdocno2lang($_,$rh_DocInfo)} }, $_) ;
		push @story_day, lnkdocno2day($_,$rh_DocInfo);
	    } else {
		push (@{ $offtop{lnkdocno2lang($_,$rh_DocInfo)} }, $_) ;
	    } 
	}

        if ($old_Vb > 2){
	    print "            Ontopic";
	    foreach $lang(@languages){ print " $lang=".$#{ $ontop{$lang} };  }
	    printf("\n");
	}
	if (! $NONMultiLingualLinkDetectionTopicAllowed){
	    foreach $lang(@languages){
		if ($#{ $ontop{$lang} } < 2) {
		    print "        Topic $topic has only ".@{ $ontop{$lang} }.
			" occurances in language $lang, skipping topic\n"
			if ($old_Vb > 2);;
		    next TOPIC;
		} 
	    }
	}

	### Loop through the evaluation conditions
	my ($seedlang, $complang, $seedcomp);
	foreach $seedcomp(@langconditions){
	    ($seedlang, $complang) = split(/:/,$seedcomp);
	    if ($NONMultiLingualLinkDetectionTopicAllowed){
		if (@{ $ontop{$seedlang}} < 3 || @{ $ontop{$complang}} < 3){
		    print "            Condition:  Topic $topic TargLang $seedlang CompareLang $complang, Not enough stories, Omitting condition.\n";
		    next;
		}
	    }
	    my %params_ontop;
	    my %params_offtop;
	    
	    my $targ_pairs = ($seedlang ne $complang) ? 50 : 100;
	    my $nontarg_pairs = $targ_pairs * 5;
    
	    ### Build the on-topic trials
	    %params_ontop = ("dist1", "uniform",  "dist2", "uniform");
	    pair_select($ontop{$seedlang}, $ontop{$complang}, \%used_story_pairs, \%params_ontop, $targ_pairs, $rh_DocInfo);
	    # foreach (sort(keys %params_ontop)){ print "            Params_Ontop $_  -> $params_ontop{$_}\n";}
	    foreach (@{ $params_ontop{"pairs"} }){   push (@Master_LNK, "$_ $topic TARGET"); }

	    ### Build the off topic trials
	    %params_offtop = ("dist1", "uniform",  "dist2", "x_power",
			  "dist2_power", 0.96, "dist2_scale", 0.7);
	    pair_select($ontop{$seedlang}, $offtop{$complang}, \%used_story_pairs, \%params_offtop, $nontarg_pairs, $rh_DocInfo);
	    #foreach (sort(keys %params_offtop)){ print "            Params_Offtop $_  -> $params_offtop{$_}\n";}
	    foreach (@{ $params_offtop{"pairs"} }){ push (@Master_LNK, "$_ $topic NONTARGET"); }

	    print "            Condition:  Topic $topic TargLang $seedlang CompareLang $complang, ".
		"#TargPairs=".$params_ontop{"#pairs"}." #NontargPairs=".$params_offtop{"#pairs"}.
		    " #TotPairs=".scalar(@Master_LNK)." #SearchRedo=".$params_offtop{"redo"}."\n";
	}
    }

    $main::Vb = $old_Vb;

    \@Master_LNK;
}				     


### Array1 gets used as a round robin list,  array two gets sampled
sub pair_select{
    my ($ra_1, $ra_2, $rh_used, $rh_params, $needed, $rh_DocInfo) = @_;
    my (@robin) = ();
    my (@choice) = ();
    my ($rselect, $cselect);
    my ($daysum, $passed, $day, $pdf) = 0;
    my (@daydelta) = ();
    my $randind;
    my (%robin_lut) = ();
    my (%choice_lut) = ();
    my $PI = 3.14159265358979323846;
    
    ### Calculate the needed statistics
    $rh_params->{"#NeededPairs"} = $needed;
    $rh_params->{"redo"} = (-$needed);
    $rh_params->{"avgday1"} = 0;
    foreach (@{ $ra_1 }){ 	$rh_params->{"avgday1"} += lnkdocno2day($_,$rh_DocInfo);     }
    $rh_params->{"avgday1"} /= @{ $ra_1 };	
    $rh_params->{"#day1"} = @{ $ra_1 };	
    $rh_params->{"#day2"} = @{ $ra_2 };	
    $rh_params->{"pairs"} = [ () ];
    $rh_params->{"#pairs"} = 0;
    $rh_params->{"#prevpairs"} = 0;

    ### Setup and initialize the lut's.  Search the existing pairs, and update the 
    ### robin lut before begining
    foreach (@{ $ra_2 }){ 	$choice_lut{$_} = 0;    }
    foreach (@{ $ra_1 }){ 	$robin_lut{$_} = $#{ $ra_2 };  }   ### minus one to skip self compares
    ### loop through the used hash, updating the lut
    foreach (keys %$rh_used){
	($rselect, $cselect) = split;
	if (defined($robin_lut{$rselect}) && defined($choice_lut{$cselect})){
	    $robin_lut{$rselect} --;
	    $rh_params->{"#prevpairs"} += 0.5;
	}
    }
    $rh_params->{"#MaxPairs"} = ($rh_params->{"#day1"} * ($rh_params->{"#day2"} - 1) / 2) - $rh_params->{"#prevpairs"};
    
    return if ($rh_params->{"#MaxPairs"} <= 0);

    print "            Pair select, #1=".$rh_params->{"#day1"}." #2=".$rh_params->{"#day2"}."\n" if ($main::Vb > 1);

    while (@{ $rh_params->{"pairs"} } < $needed && @{ $rh_params->{"pairs"} } < $rh_params->{"#MaxPairs"}){
	### Prime de pump
	@choice = @{ $ra_2 } if ($#choice < 0);
	# print "  Selected ".scalar(@{ $rh_params->{"pairs"} })." pairs, reds ".$rh_params->{"redo"}."\n";
	### Select a story from the first array
	if ($rh_params->{"dist1"} eq "uniform"){
	    ### randomly
	    do {
		if ($#robin < 0){
		    @robin = @{ $ra_1 } ;
		    print "Reload robin\n" if ($main::Vb > 2);
		}

		$rselect = splice(@robin, rand @robin, 1);
	    } while ($robin_lut{$rselect} <= 0);
	} else {
	    die;
	}
	print "rselect $rselect $robin_lut{$rselect}\n"  if ($main::Vb > 2);
	### Select the story from the choice array
	### randomly
	do {
	    $randind = rand @choice;
	    if ($rh_params->{"dist2"} eq "uniform"){
		$passed = 1;
	    } elsif ($rh_params->{"dist2"} eq "x_power"){
		### Implements the formula (1 + Ax) ** (-Y).  
		###  where 'x' is the distance in days from the selected seed
		###        'A' is a supplied scaling factor on the days
		###        'Y' is a supplied power term
		$day = int(lnkdocno2day($choice[$randind],$rh_DocInfo) - lnkdocno2day($rselect,$rh_DocInfo));
		$pdf = (1.0 + (($day *= ($day < 1)?-1:1) * $rh_params->{"dist2_scale"})) ** 
		    (- $rh_params->{"dist2_power"});
		$passed = ((rand() < $pdf) ? 1 : 0);
	    } elsif ($rh_params->{"dist2"} eq "normal"){
		### Compute the PDF function for the selected stories day.  See page 163 of
		### "Simulation Modeling and Analysis" Law and Kelton for the PDF formula of a
		### normal distribution.
		$day = lnkdocno2day($choice[$randind],$rh_DocInfo);
		$pdf = (1.0 / sqrt(2 * $PI * $rh_params->{"dist2_stddev"})) *
		    exp(-(($day-$rh_params->{"dist2_mean"})*($day-$rh_params->{"dist2_mean"}))/2 * $rh_params->{"dist2_stddev"});
		$passed = ((rand() < $pdf) ? 1 : 0);
	    } else {
		die;
	    }
	    $rh_params->{"redo"} ++;
	} while (defined($rh_used->{$rselect." ".$choice[$randind]}) ||
		 defined($rh_used->{$choice[$randind]." ".$rselect}) ||
		 $choice[$randind] eq $rselect ||
		 (! $passed));		
	$cselect = $choice[$randind];

	## keep track of how many times the story was used
	$robin_lut{$rselect} --;
	## Check to see of $cselect is in robin, and $rselect is in choice
	## This checks handles the condition when robin and choice have a non-empty intersection
	if (defined($choice_lut{$rselect}) && defined($robin_lut{$cselect})){
	    $robin_lut{$cselect} --;
	}

	push @daydelta, lnkdocno2day($rselect,$rh_DocInfo) - lnkdocno2day($cselect,$rh_DocInfo);
	# print "Delta $daydelta[$#daydelta]\n";

	### Add the pairs to the array
	push @{ $rh_params->{"pairs"} }, $rselect." ".$cselect;

	### update the used list
	$rh_used->{$rselect." ".$cselect} = 1;
	$rh_used->{$cselect." ".$rselect} = 1;
	print scalar(@{ $rh_params->{"pairs"} })."\n" if ($main::Vb > 2);
    }    

    ($rh_params->{"delta_mean"}, $rh_params->{"delta_var"}, 
     $rh_params->{"delta_stddev"}, $rh_params->{"delta_stderr"}) = sumstat(@daydelta);
    $rh_params->{"#pairs"} = scalar(@{ $rh_params->{"pairs"} });
}

sub build_LNK_from_db{
    my($Root, $det_ind_file, $ra_DocList, $rh_DocInfo, $LNKdb) = @_;
    my (%TDTref) = ();
    my ($rh_bnd, @toplist, @levlist, $file, $t, %slist, %tlist, @slist_sort);
    my (@ontop,@offtop);
    my (@linked,@notlinked);
    my ($topic);
    my @Master_LNK = ();
    my $story_count = 0;
    my $old_Vb = $main::Vb;
    my $docinfo_file;
    my %used_story_pairs = ();
    my $selected;
    my $rh_LNKset ;
    my $errors;

    #### Load the link database
    $rh_LNKset = load_LNKset_from_LNKdb($LNKdb);
    
    ### Load the database ONLY to build the lnkdocno entries for the LNKset structure

    undef(%TDTref) if (%TDTref);
    $main::Vb = 0; 
    my(@IndexList) = ( $det_ind_file );
						   
    %TDTref = &Load_Boundaries_Into_TDTRef($Root,\@IndexList,$BaseTaskIndex eq "det" ? 'DETECTION' : 'HIEARCHICAL_DETECTION',
					   Boundary_DTDs(), "");
    &Add_Topic_Into_TDTref(\@OnTopicRelevanceJudgementTables,
			   TopicRelevance_DTDs(), \%TDTref, "true");

    open(DETIND,$det_ind_file) || die("Failed to open detection index '$det_ind_file'");
    while(<DETIND>){		
	next if ($_ =~ /^\#/ || $_ =~ /^\s*$/);
	chomp;
	($file = $_) =~ s:.*/(.*)\.[^.]+$:$1:;
	($docinfo_file = $file) =~ s/\.(ccap|fdch)$//;
	foreach $rh_bnd(@{ $TDTref{'bsets'}{$file}{'boundary'} }){
	    @toplist = @{ $rh_bnd->{'topicid'} }; 
	    @levlist = @{ $rh_bnd->{'t_level'} }; 		    
	    next if ($rh_bnd->{'doctype'} ne 'NEWS');
	    foreach $t(0 .. $#toplist){
		if (defined($rh_LNKset->{"lnkdocno"}{$rh_bnd->{'docno'}})){
		    $rh_LNKset->{"lnkdocno"}{$rh_bnd->{'docno'}} = 
		        $story_count.":".$docinfo_file.":".$file.":".$rh_bnd->{'docno'};	
		}
		$story_count++;
	    }
	}
    }
    close(DETIND);
    $main::Vb = $old_Vb;

#    dump_LNKset($rh_LNKset);
    ### Verify that all docnos have been found!!!!
    print "    Verifying a complete set of docnos from the LNKdb\n" if ($main::Vb > 0);
    $errors = 0;
    foreach $_(keys %{ $rh_LNKset->{"lnkdocno"} }){
	if ($rh_LNKset->{"lnkdocno"}{$_} eq "undef"){
	    print "       docno $_ is undefined\n" ;
	    $errors ++;
	}
    }
    die "Aborting due to errors" if ($errors > 0);

    #### Now build the master list!
    my ($seed, $comp, $attr);
    foreach $seed(keys %{ $rh_LNKset->{"seed"} }){
	foreach $comp (keys %{ $rh_LNKset->{"seed"}{$seed}{"compare"} }){
	    push (@Master_LNK, $rh_LNKset->{"lnkdocno"}{$seed}." ".$rh_LNKset->{"lnkdocno"}{$comp}.
		  " ".$rh_LNKset->{"seed"}{$seed}{"number"}.
		  " ".$rh_LNKset->{"seed"}{$seed}{"compare"}{$comp}{"judgement"});
	}
    }
    \@Master_LNK;
}          


sub lnkdocno2ind{
    my($ind_docno, $rh_DocInfo) = @_;
    my($ind,$docinfo_file,$file,$docno,$lang) = split(/\:/,$ind_docno);
    $ind;
}

sub lnkdocno2file{
    my($ind_docno, $rh_DocInfo) = @_;
    my($ind,$docinfo_file,$file,$docno,$lang) = split(/\:/,$ind_docno);
    $file;
}

sub lnkdocno2docinfo_file{
    my($ind_docno, $rh_DocInfo) = @_;
    my($ind,$docinfo_file,$file,$docno,$lang) = split(/\:/,$ind_docno);
    $docinfo_file;
}

sub lnkdocno2docno{
    my($ind_docno, $rh_DocInfo) = @_;
    my($ind,$docinfo_file,$file,$docno,$lang) = split(/\:/,$ind_docno);
    $docno;
}

sub lnkdocno2lang{
    my($ind_docno, $rh_DocInfo) = @_;
    my($ind,$docinfo_file,$file,$docno,$lang) = split(/\:/,$ind_docno);
    $lang;
}

sub lnkdocno2day{
    my($ind_docno, $rh_DocInfo) = @_;
    int(lnkdocno2time($ind_docno, $rh_DocInfo)) / 24;
}
 
sub lnkdocno2time{
    my($ind_docno, $rh_DocInfo) = @_;
    my($ind,$docinfo_file,$file,$docno) = split(/\:/,$ind_docno);

    my($date,$hour) = split(/_/,$rh_DocInfo->{$docinfo_file}->{"date"});
    # print "ind $ind_docno $ind $file $docno - ".$rh_DocInfo->{$docinfo_file}->{"date"}." $date $hour \n";

    die "Illegal date '$date'" unless ($date =~ /^(....)(..)(..)/);
    my($year,$month,$day) = ($1,$2,$3);
    my($dp_month) = (($month eq "01" ? 0 :
		      ($month eq "02" ? 31 :
		       ($month eq "03" ? 60 :
			($month eq "04" ? 91 :
			 ($month eq "05" ? 121 :
			  ($month eq "06" ? 152 :
			   ($month eq "07" ? 182 :
			    ($month eq "08" ? 213 :
			     ($month eq "09" ? 244 :
			      ($month eq "10" ? 275 :
			       ($month eq "11" ? 305 : 
				($month eq "12" ? 335 : 0)))))))))))));
#    ($year * 365*24) + ($month*$dp_month*24) + ($day*24);
    ($dp_month*24) + (($day-1)*24) + $hour/1200;
}


sub BuildSSDFiles{
    my($HTM, $OutDir, $ra_DocList, $rh_DocInfo, $Root) = @_;
    my($src, $lang, $translate);
    
    print "Building Sourcefile Subset Definition Files\n" if ($main::Vb > 0);
    
    print $HTM "<P><A name=\"ssd\"><H2> Subset Definitions Files</H2></A>\n";
    print $HTM "For the tracking and detection tasks, the evaluation conditions involve pooling source texts\n";
    print $HTM "from languages.  The subset definition files below provide a way\n";
    print $HTM "to compute performance statistics on multiple, independent 'subsets' of an evaluation run.\n";
    print $HTM "The 'standard' divisions are to divide the data by source texts, Newswire and Broadcast News,\n";
    print $HTM "and by the test source language, English or Mandarin.  \n";
    print $HTM "<P> \n";
    print $HTM "Currently, only the tracking and detection evaluation scripts support the subset definition file.\n";
    print $HTM "To use a subset definition file, add the command line argument '-U SubsetFile' to the\n";
    print $HTM "tracking evaluation script 'TDT3trk.pl', or for the detection evaluation script 'TDT3det.pl', add\n";
    print $HTM "the command line option '-S SubsetFile'.\n";
    print $HTM "<DIR>\n<TABLE border=2>\n";
    print $HTM "<TR> <TH> Source Condition\n";
    print $HTM "     <TH> Test Source Language\n";
    print $HTM "     <TH> Test Content Language\n";
    print $HTM "     <TH> Sourcefile Subset Definition Filename\n";
    foreach $src ("nwt+bnasr"){
	foreach $lang("mul", "man", "eng", "arb"){
	    print $HTM "<TR> <TH> All Source Conditions.\n";
	    print $HTM "     <TH> ".langAbbrevToWord($lang)."\n";
	    foreach $translate("nat"){
		my $rname = "TE=${lang}";
		my $sname = "Subsets_${rname}.ssd";
		my $s_file = "$OutDir/$sname";
		print $HTM "     <TH> Native <br>or<br> English\n";
		
		print $HTM "     <TD> <A HREF=\"$sname\">$sname</A>\n";
		
		make_det_or_fsd_or_ssd_index($rh_DocInfo, "", $s_file, "ssd",
					     $ra_DocList, $src, $lang, $translate);
	    }
	}
    }
    print $HTM "</TABLE>\n</DIR>\n";
}


sub BuildDetectionIndex{
    my($HTM, $OutDir, $ra_DocList, $rh_DocInfo, $Root) = @_;
    my($src, $lang, $translate);
    
    print "Building Detection Indexes\n" if ($main::Vb > 0);
    
    print $HTM "<P><A name=\"detect\"><H2> Detection Index Files</H2></A>\n";
    print $HTM "<DIR>\n<TABLE border=2>\n";
    print $HTM "<TR> <TH> Source Condition\n".
	"     <TH> Source Language\n     <TH>     Content Language\n     <TH> Index Filename\n";
    my @srcs = ("nwt+bnasr", "nwt+bnman");
    @srcs = ("nwt") if ($ExcludeSrcType eq "bn");
    @srcs = ("bn") if ($ExcludeSrcType eq "nwt");
    foreach $src (@srcs) {
	print $HTM "<TR> <TH rowspan=8> ".$Descriptions{$src}."\n";
	foreach $lang("mul", "man", "eng", "arb"){
	    if ($lang eq "mul"){
		print $HTM "     ";
	    } else {
		print $HTM "<TR> ";
	    }	
	    print $HTM "<TH rowspan=2> ".langAbbrevToWord($lang)."\n";
	    foreach $translate("nat", "eng"){
		my $rname = "det_SR=${src}_TE=${lang},${translate}";
		my $iname = "${rname}.ndx";
		my $ind_file = "$OutDir/$iname";
		
		print $HTM (($translate eq "nat") ? "     <TH> Native" : "<TR> <TH> English")."\n";
		if ($lang eq "eng" && $translate eq "eng"){
		    print $HTM "     <TD>Not Defined by the Eval. Spec.\n";
		    next;
		} 
		print $HTM "     <TD> <A HREF=\"$iname\">$iname</A>\n";
		
		make_det_or_fsd_or_ssd_index($rh_DocInfo, $ind_file, "", "det",
				      $ra_DocList, $src, $lang, $translate);
	    }
	}
    }
    print $HTM "</TABLE>\n</DIR>\n";

}

sub make_det_or_fsd_or_ssd_index{
    my ($rh_DocInfo, $ind_file, $subset_file, $eval, $ra_DocList, $src, $lang, $translate) = @_;
    my ($file, $filename, $use_man, $sid, $lkey);

    ### Define the possible subsets

    my (@Subsets) = ({ "title" => "NWT Subset, English Subset", "heading" => "NWT English",           
		       "src" => "nwt", "lang" => "eng", "slist" => [ () ],
		       "num" => { "eng" => 0, "man" => 0, "arb" => 0 } },
		     { "title" => "NWT Subset, Mandarin Subset", "heading" => "NWT Mandarin",          
		       "src" => "nwt", "lang" => "man", "slist" => [ () ],
		       "num" => { "eng" => 0, "man" => 0, "arb" => 0 } },
		     { "title" => "NWT Subset, Arabic Subset", "heading" => "NWT Arabic",          
		       "src" => "nwt", "lang" => "arb", "slist" => [ () ],
		       "num" => { "eng" => 0, "man" => 0, "arb" => 0 } },
		     { "title" => "NWT Subset, Multilingual Texts", "heading" => "NWT M-ling",      
		       "src" => "nwt", "lang" => "mul", "slist" => [ () ],
		       "num" => { "eng" => 0, "man" => 0, "arb" => 0 } },
		     { "title" => "BNews Subset, English Subset", "heading" => "BN English",         
		       "src" => "bn", "lang" => "eng", "slist" => [ () ],
		       "num" => { "eng" => 0, "man" => 0, "arb" => 0 } },
		     { "title" => "BNews Subset, Mandarin Subset", "heading" => "BN Mandarin",        
		       "src" => "bn", "lang" => "man", "slist" => [ () ],
		       "num" => { "eng" => 0, "man" => 0, "arb" => 0 } },
		     { "title" => "BNews Subset, Arabic Subset", "heading" => "BN Arabic",        
		       "src" => "bn", "lang" => "arb", "slist" => [ () ],
		       "num" => { "eng" => 0, "man" => 0, "arb" => 0 } },
		     { "title" => "BNews Subset, Multilingual Texts", "heading" => "BN M-ling",    
		       "src" => "bn", "lang" => "mul", "slist" => [ () ],
		       "num" => { "eng" => 0, "man" => 0, "arb" => 0 } },
		     { "title" => "NWT+BNews, English Subset", "heading" => "NWT+BN English",     
		       "src" => "nwt+bn", "lang" => "eng", "slist" => [ () ],
		       "num" => { "eng" => 0, "man" => 0, "arb" => 0 } },
		     { "title" => "NWT+BNews, Mandarin Subset", "heading" => "NWT+BN Mandarin",    
		       "src" => "nwt+bn", "lang" => "man", "slist" => [ () ],
		       "num" => { "eng" => 0, "man" => 0, "arb" => 0 } },
		     { "title" => "NWT+BNews, Arabic Subset", "heading" => "NWT+BN Arabic",   
		       "src" => "nwt+bn", "lang" => "arb", "slist" => [ () ],
		       "num" => { "eng" => 0, "man" => 0, "arb" => 0 } },
		     { "title" => "NWT+BNews, Multilingual Texts", "heading" => "NWT+BN M-ling",
		       "src" => "nwt+bn", "lang" => "mul", "slist" => [ () ],
		       "num" => { "eng" => 0, "man" => 0, "arb" => 0 } } );
    ### Filter out all excluded srcs from the subset lists
    if ($ExcludeSrcType ne ""){
	for (my $i=0; $i<@Subsets; $i++){
	    if ($Subsets[$i]{"heading"} =~ /$ExcludeSrcType/i){
		splice(@Subsets, $i, 1);
		$i--;
	    }
	}
    }

    ###
    if ($eval ne "ssd"){
	open(IND,">$ind_file") || die("Unable to open index file '$ind_file' for write");
	if ($eval eq "htd"){
	    print IND "# HIEARCHICAL_DETECTION DOCNO\n";
	} else {
	    print IND "# ".(($eval eq "det") ? "DETECTION" : "FIRST_STORY" )." RECID\n";
	} 
	&add_date(*IND);
    }
    foreach $file(@$ra_DocList){
	if (($rh_DocInfo->{$file}->{"is_$lang"} == 1) &&
	    ($rh_DocInfo->{$file}->{"is_$src"} == 1)){
	    $use_man = 1;
	    if ($src =~ /asr/){
		$use_man = 0;
		if (! defined($rh_DocInfo->{$file}->{"asr"})){
		    $use_man = 1;
		} else {
		    if ($translate ne "nat" && defined($rh_DocInfo->{$file}->{"mtasr"})){
			$filename = $rh_DocInfo->{$file}->{"mtasr"};
		    } else {
			$filename = $rh_DocInfo->{$file}->{"asr"};
		    }		}
	    } 
	    if ($use_man == 1 || $src =~ /bnman/){
		if ($translate ne "nat" && defined($rh_DocInfo->{$file}->{"mttkn"})){
		    $filename = $rh_DocInfo->{$file}->{"mttkn"};
		} else {
		    $filename = $rh_DocInfo->{$file}->{"tkn"};
		}
	    }
	    print IND "$filename\n" if ($eval ne "ssd");
	    ### Check the subsets structure and update it
	    for($sid=0; $sid<=$#Subsets; $sid++){
		if (($rh_DocInfo->{$file}->{"is_".$Subsets[$sid]{"lang"}} == 1) &&
		    ($rh_DocInfo->{$file}->{"is_".$Subsets[$sid]{"src"}} == 1)){
		    push (@{ $Subsets[$sid]{"slist"} }, $file);
		    foreach $lkey(keys %{ $Subsets[$sid]{"num"} }){
			$Subsets[$sid]{"num"}{$lkey} ++
			    if ($rh_DocInfo->{$file}->{"is_$lkey"} == 1);
		    }
		}
	    }		
	}
    }
    close(IND) if ($eval ne "ssd");

    if ($eval eq "ssd"){
	#### Build the subset definition file
	open(SSD,">$subset_file") || die("Unable to open SSD file '$subset_file' for write");
	print SSD "<source_subset>\n";
	for($sid=0; $sid<=$#Subsets; $sid++){
	    if ($#{ $Subsets[$sid]{"slist"} } >= 0){
		next if ($Subsets[$sid]{"lang"} eq "mul" && 
			 ($Subsets[$sid]{"num"}{"eng"} == 0 || $Subsets[$sid]{"num"}{"man"} == 0));
		printf SSD ("<set title=\"%s\" heading=\"%s\">\n",
			    $Subsets[$sid]{"title"}, $Subsets[$sid]{"heading"});
		print SSD "<source_file filename=\"";
		print SSD join("\">\n<source_file filename=\"",@{ $Subsets[$sid]{"slist"} })."\">\n";
		print SSD "</set>\n";
	    }
	}		
	print SSD "</source_subset>\n";
	close(SSD);
    }
    ###
}


sub BuildTrackingIndex{
    my($HTM, $OutDir, $ra_DocList, $rh_DocInfo, $Root, $Max_Nt) = @_;
    my($src, $lang, $translate);
    my(%TDTref) = ();
    my($locvb) = $main::Vb;
    my($compare_file) = "";
    my($file, $t, $index_file, $docinfo_file);
    my(%trki) = ();
    my(@toplist);
    my(@levlist);
    my(@ranklist);
    my($rh_bnd);
    my %indexline_lut = ();
    my $trk_dir = "trk_ndx";
    my $do_topno = "yes";
    my (@ExemplarLangs) = ("eng", "man", "arb");
    my ($eLang);


    die "Error: Index files can on be generated for the TDT2000 evaluation" if ($EvalYear ne "2000");

    print "Building Tracking Indexes\n" if ($main::Vb > 0);

    print $HTM "<P><A name=\"track\"><H2> Tracking Index Files</H2></a>\n";
    print $HTM "There is only one test language condition for the tracking evaluation, which is\n".
	"multilingual tracking.  The variations are on broadcast source, test content \n".
	    "language, and training story source language.\n".
	    "  For each evalution test and training condition, there is a\n".
		"individual index file for each test topic.  Due to the large number of index files, all\n".
		"tracking Index files are stored in a single directory, '<A href=$trk_dir>$trk_dir</a>',\n".
		"and experiment control files\n".
		"identify which topic index files consitute an evalulation.  (Note this is a new format\n".
		    " as of August, 2000).\n";
    print $HTM "<DIR>\n<TABLE border=2>\n";
    print $HTM "<TR> <TH rowspan=2> Source Condition\n".
	"     <TH colspan=2> TEST     <TH> TRAIN\n    <TH rowspan=2> Nt\n".
        "     <TH rowspan=2> Experiment Control Files\n";
    print $HTM "<TR> <TH> Source Language\n".
	"     <TH> Contenr\n     <TH>     Language\n";

    ### Test the assertion that the source files are the same across all detection index
    ### files that keep the language =MUL, but vary the src and translation
    print "    Verifying assertion: all detection index files are identical\n" if ($main::Vb > 0);
    my @srcs = ("nwt+bnasr", "nwt+bnman");
    @srcs = ("nwt") if ($ExcludeSrcType eq "bn");
    @srcs = ("bnasr", "bnman") if ($ExcludeSrcType eq "nwt");
    foreach $src (@srcs){
	$lang = "mul";
	foreach $translate("nat", "eng"){
	    my $det_ind_file = "$OutDir/${BaseTaskIndex}_SR=${src}_TE=${lang},${translate}.ndx";
	    if ($compare_file eq ""){
		$compare_file = $det_ind_file;
	    } else {
		die "Error: assertion failed.  Detection index files".
		    "$compare_file and $det_ind_file have different source file sequences"
			if (index_source_files_identical($compare_file,$det_ind_file) == 0);
		
	    }
	}
    }

    ###############################################################
    #### Load the corpus to find the topic training stories
    $src = $srcs[0];
    $lang = "mul";
    $translate = "nat";
    
    my $det_ind_file = "$OutDir/${BaseTaskIndex}_SR=${src}_TE=${lang},${translate}.ndx";

    #### hash indexed by the topic number,

    print "    Loading the detection index $det_ind_file\n" if ($main::Vb > 1);
    undef(%TDTref) if (%TDTref);
    $main::Vb = 0; 
    my(@IndexList) = ( $det_ind_file );
    %TDTref = &Load_Boundaries_Into_TDTRef($Root,\@IndexList,$BaseTaskIndex eq "det" ? 'DETECTION' : 'HIEARCHICAL_DETECTION',
					   Boundary_DTDs(),"");
    &Add_Topic_Into_TDTref(\@OnTopicRelevanceJudgementTables, TopicRelevance_DTDs(), \%TDTref, "true");
    if ($EvalYear eq "2000"){
	### annotations for the Certified NO stories
	### Check to see if there are topno annotations
	$do_topno = "no";
	if (@OffTopicRelevanceJudgementTables > 0){
	    $do_topno = "yes";
	    &Add_Topic_Into_TDTref(\@OffTopicRelevanceJudgementTables, TopicRelevance_DTDs(), \%TDTref, "true");
	} else {
	    print STDERR "   *** WARNING: Top No Story Annotations not found.  Skipping their processing.\n";
	}
    }
    # { &dump_TDTref(\%TDTref, "foo"); exit 0; }
    $main::Vb = $locvb;
	    
    ### Foreach Topic, build an index	  
    print "    Searching topics\n" if ($main::Vb > 1);

    ### Find the defined topics
    open(DETIND,$det_ind_file) || die("Failed to open detection index '$det_ind_file'");
    while(<DETIND>){		
	next if ($_ =~ /^\#/ || $_ =~ /^\s*$/);
	chomp;
	$index_file = $_;
	($file = $index_file) =~ s:.*/(.*)\.[^.]+$:$1:;
	($docinfo_file = $file) =~ s/\.(ccap|fdch)$//;

	## Remeber the ordinal position of the sourcefile in the index
	$indexline_lut{$docinfo_file} = $.;

	die "Internal error, unable to find docinfo for '$file'"
	    if (!defined($rh_DocInfo->{$docinfo_file}));
	foreach $rh_bnd(@{ $TDTref{'bsets'}{$file}{'boundary'} }){
	    @toplist = @{ $rh_bnd->{'topicid'} }; 
	    @levlist = @{ $rh_bnd->{'t_level'} }; 		    
	    @ranklist = @{ $rh_bnd->{'offtop_rank'} }; 		    
	    foreach $t(0 .. $#toplist){
		next if ($toplist[$t] eq "n/a");
		
		### initialize
		if (!defined $trki{$toplist[$t]}){
		    foreach $eLang(@ExemplarLangs){
			$trki{$toplist[$t]}{"${eLang}_docno"} = ();
			$trki{$toplist[$t]}{"${eLang}_srcfile"} = ();
			$trki{$toplist[$t]}{"${eLang}_offtopic_docno"} = ();
			$trki{$toplist[$t]}{"${eLang}_offtopic_srcfile"} = ();
			$trki{$toplist[$t]}{"${eLang}_offtopic_rank"} = ();
		    }
		}
		
		next unless ($TopicRegexp eq "" || $toplist[$t] =~ /^${TopicRegexp}$/);
		next unless ($rh_bnd->{'doctype'} eq 'NEWS');
	    	       
		if ($levlist[$t] eq "YES"){
		    ### Add to the train documents for each language
		    foreach $eLang(@ExemplarLangs){
			if ($rh_DocInfo->{$docinfo_file}->{"is_${eLang}"} == 1 &&
			    $#{ $trki{$toplist[$t]}{"${eLang}_docno"} } < $Max_Nt -1){
			    push( @{ $trki{$toplist[$t]}{"${eLang}_docno"} }, $rh_bnd->{'docno'});
			    push( @{ $trki{$toplist[$t]}{"${eLang}_srcfile"} }, $docinfo_file);
			}
		    }
		} elsif ($levlist[$t] eq "NO"){
		    my $nt;
		    my $lang = $rh_DocInfo->{$docinfo_file}->{"lang"};
		    if ($#{ $trki{$toplist[$t]}{"${lang}_docno"} } < $Max_Nt -1){
			#print "--- ".$#{ $trki{$toplist[$t]}{"${lang}_offtopic_docno"} }."  insert '$ranklist[$t]'\n";
			if ($#{ $trki{$toplist[$t]}{"${lang}_offtopic_docno"} } < 0){
			    push( @{ $trki{$toplist[$t]}{"${lang}_offtopic_docno"} },   $rh_bnd->{'docno'});
			    push( @{ $trki{$toplist[$t]}{"${lang}_offtopic_srcfile"} }, $docinfo_file);
			    push( @{ $trki{$toplist[$t]}{"${lang}_offtopic_rank"} },    $ranklist[$t]);
			} else {
			    ### Decide where to insert into the list
			    if ($ranklist[$t] eq ""){  ### push it on the end
				push( @{ $trki{$toplist[$t]}{"${lang}_offtopic_docno"} },   $rh_bnd->{'docno'});
				push( @{ $trki{$toplist[$t]}{"${lang}_offtopic_srcfile"} }, $docinfo_file);
				push( @{ $trki{$toplist[$t]}{"${lang}_offtopic_rank"} },    $ranklist[$t]);
			    } else {
				for ($nt=0; $nt <= $#{ $trki{$toplist[$t]}{"${lang}_offtopic_docno"} }; $nt++){
				    #print "   $nt rank is ".$trki{$toplist[$t]}{"${lang}_offtopic_rank"}[$nt]."\n";
				    if (($trki{$toplist[$t]}{"${lang}_offtopic_rank"}[$nt] eq "") ||
					($trki{$toplist[$t]}{"${lang}_offtopic_rank"}[$nt] gt $ranklist[$t])){
					
					last;
				    }
				}
				#print "    nt= $nt\n";
				splice( @{ $trki{$toplist[$t]}{"${lang}_offtopic_docno"} },   $nt, 0, $rh_bnd->{'docno'});
				splice( @{ $trki{$toplist[$t]}{"${lang}_offtopic_srcfile"} }, $nt, 0, $docinfo_file);
				splice( @{ $trki{$toplist[$t]}{"${lang}_offtopic_rank"} },    $nt, 0, $ranklist[$t]);
			    }
			}
		    }
		}		    
	    }
	}
    }

    foreach $eLang(@ExemplarLangs){
	my $cnt = 0; my $topic;
	print "        Warning: Topics without $Max_Nn ".langAbbrevToWord($eLang)." off-topic stories: (topic-#ontopic-#offtopic)\n";
	foreach $topic(sort(keys %trki)){
	    if (($TopicRegexp eq "" || $topic =~ /^${TopicRegexp}$/) &&
		MIN($Max_Nn-1,$#{ $trki{$topic}{"${eLang}_offtopic_docno"} }) != $Max_Nn-1){
		print "            " if ($cnt++ == 0);
		print " $topic-".(defined($trki{$topic}{"${eLang}_docno"}) ? scalar(@{ $trki{$topic}{"${eLang}_docno"} }) : 0);
		print "-".(defined($trki{$topic}{"${eLang}_offtopic_docno"}) ? scalar(@{ $trki{$topic}{"${eLang}_offtopic_docno"} }) : 0);
		if ($cnt == 5){   $cnt = 0; print "\n"; }
	    }
	}
	print "\n";
    }


    close DETIND;
    ### Erase the TDT corpus structure
    undef(%TDTref) if (%TDTref);

    print "    Picking Variable Nt topics\n" if ($main::Vb > 1);
    ### Reduce the set of Nt=v topic by a factor of 2
    ### Make Choose 1 Nt=V topic for every 2 topics
    my (%NtV_topics) = ();
    my (@NtVt) = sort(keys %trki);
    my (@tmp, @newtdt3, @oldtdt3);
    ### For TDT 2000, I want 30 topics from the set of topics 30001-30060 and 
    ### 300 topics from the set 31001-31060
    my ($Special_tdt2000_selection) = 1;
    foreach(@NtVt){ 
	next if ($_ eq "n/a");
	if ($_ >= 30001 && $_ <= 30060){
	    ### Make sure there are 4 training stories in both languages before the push
	    push @oldtdt3, $_
		if ($#{ $trki{$_}{"eng_docno"} } == $Max_Nt -1 &&
		    $#{ $trki{$_}{"man_docno"} } == $Max_Nt -1 &&
		    $#{ $trki{$_}{"arb_docno"} } == $Max_Nt -1);
	} elsif ($_ >= 31001 && $_ <= 31060){
	    push @newtdt3, $_
		if ($#{ $trki{$_}{"eng_docno"} } == $Max_Nt -1 &&
		    $#{ $trki{$_}{"man_docno"} } == $Max_Nt -1 &&
		    $#{ $trki{$_}{"arb_docno"} } == $Max_Nt -1);
	} else { $Special_tdt2000_selection = 0; }
    }
    if ($Special_tdt2000_selection == 1){
	print "        Limiting Nt=V topics to 60 topics, ".
	    "from the ranges 30001-30060 and 31001-31060\n" if ($main::Vb > 1);
	@oldtdt3 = scramble(@oldtdt3);
	@newtdt3 = scramble(@newtdt3);
	@NtVt = (splice(@oldtdt3,0,30), splice(@newtdt3,0,30));
    } else {
	print "        Using all topics got Nt=V topics\n" if ($main::Vb > 1);
    }
    foreach(@NtVt){
	$NtV_topics{$_}{'selected'} = 1;  
	### Select the bitmap for the chosen topics (this applies to both eng and man)
	$NtV_topics{$_}{'chosentraining'} = [ ( choose([ ("0001","0010","0100","1000") ], 2),
					      choose([ ("0011 1100","0110 1001","0101 1010") ], 1),
					      choose([ ("0111","1011","1101","1110") ], 1),
					      "1111") ];
    }

    ################################################################################
    ### Build the index files for all the bloody conditions
    foreach $src (@srcs){
	foreach $lang("mul", "man"){
	    foreach $translate("nat", "eng"){
		print "    Building Tracking Index files, SR=${src} TE=${lang},${translate}\n" if ($main::Vb > 1);
		my $det_ind_file = "$OutDir/${BaseTaskIndex}_SR=${src}_TE=mul,${translate}.ndx";
		
		make_trk_indexes($HTM, $OutDir, $Root, $Max_Nt, \%trki, $src, $lang,
				 $translate, $det_ind_file, $trk_dir, $do_topno, \%NtV_topics, $rh_DocInfo,
				 \@ExemplarLangs);
	    }
        }
    }
    print $HTM "</TABLE></DIR>\n";
}

sub make_trk_indexes{
    my($HTM, $OutDir, $Root, $Max_Nt, $rh_trki, $test_src, $test_lang, $test_translate, $det_ind_file, $trk_dir, $do_topno, $rh_NtV_topics, $rh_DocInfo, $ra_ExemplarLangs) = @_;
    my($topic, $tr_lang, $tr_trans, $was_last, $nt);
    my $docinfo_file;
    my %docinfo_to_ndx_lut = ();
    my @ndx_list;
    my %trk_ctl;
    my $do_NtV = 0;
    my (@Nt) = (1, 2, 4); 
    if ($test_lang eq "mul") {
	push (@Nt, "V"); 
	$do_NtV = 1;
    }
    my ($eLang, $sourceFile);

    foreach $tr_lang(@$ra_ExemplarLangs){

 	#### Open all of the Control files
	foreach (@Nt){
	    $trk_ctl{$_} = "trk_SR=${test_src}_".
		"TR=${tr_lang}_".
		    "TE=${test_lang},${test_translate}_Nt=${_}.ctl";
	    (($_ eq "1") ? open(TRKCTL_NT1,">$OutDir/$trk_ctl{$_}") :
	     (($_ eq "2") ? open(TRKCTL_NT2,">$OutDir/$trk_ctl{$_}") :
	      (($_ eq "4") ? open(TRKCTL_NT4,">$OutDir/$trk_ctl{$_}") :
	       (($_ eq "V") ? open(TRKCTL_NTv,">$OutDir/$trk_ctl{$_}") : 1)))) || 
		 die "Failed to open $OutDir/$trk_ctl{$_}";
	    my $str = "# $test_src $tr_lang $test_lang $_\n";
	    print TRKCTL_NT1 $str if ($_ eq "1");
	    print TRKCTL_NT2 $str if ($_ eq "2");
	    print TRKCTL_NT4 $str if ($_ eq "4");
	    print TRKCTL_NTv $str if ($_ eq "V");
	}

	if ($test_translate =~ /nat/ && $tr_lang eq "eng"){
	    print $HTM "<TR> <TH rowspan=".(3 * scalar(@Nt) * 2)."> ".$Descriptions{$test_src}."\n";
	} else {
	    print $HTM "<TR>\n";
	}

	print $HTM "     <TH rowspan=".(3 * scalar(@Nt) * 2)."> ".langAbbrevToWord($test_lang).
	    ($test_lang ne "mul" ? "<BR><BOLD>** not a sanctioned TDT test condition</BOLD>\n" : "")
		if ($test_translate =~ /nat/ && $tr_lang eq "eng");

	print $HTM ((($test_translate eq "nat") ? "     <TH rowspan=".(3 * scalar(@Nt))."> Native" :
		     "     <TH rowspan=".(3 * scalar(@Nt))."> English")."\n")
	    if ($tr_lang eq "eng");

	print $HTM "     <TH rowspan=".scalar(@Nt)."> ".langAbbrevToWord($tr_lang)."\n";

	foreach (@Nt){
	    print $HTM "<TR>\n" if ($_ ne "1");
	    print $HTM "     <TD> Nt=$_ \n";
	    print $HTM "     <TD> <A HREF=\"$trk_ctl{$_}\">$trk_ctl{$_}</A>\n";
	}
    
	#### Load the appropriate detection index file, building a lookup table
	open(DETIND,$det_ind_file) || die("Failed to open detection index '$det_ind_file'");
	@ndx_list = ();
	while(<DETIND>){		
	    next if ($_ =~ /^\#/ || $_ =~ /^\s*$/);
	    chomp;
	    ### Convert filename to docninfo file
	    ($docinfo_file = $_) =~ s:.*/(.*)\.[^.]+$:$1:;
	    $docinfo_file =~ s/\.(ccap|fdch)$//;
	    $docinfo_to_ndx_lut{$docinfo_file} = $_;
	    push(@ndx_list,$_);
	}
	close(DETIND);
	########################################################
 
	foreach $topic(sort(keys %$rh_trki)){
	    if (0){
		print "   Topic $topic: man=".$#{ $rh_trki->{$topic}{"man_docno"} };
		print "  eng=".$#{ $rh_trki->{$topic}{"eng_docno"} };
				print "\n";
	    }

	    next if ($#{ $rh_trki->{$topic}{"${tr_lang}_srcfile"} } < 0);

	    if (! -d "$OutDir/$trk_dir"){
		die "Unable to make tracking dir $OutDir/$trk_dir" if (! mkdir("$OutDir/$trk_dir",511));
	    }
#	    my $trk_ind_file = "$OutDir/${trk_dir}/${trk_dir}_TP=${topic}".".ndx";
	    my $trk_file =     "${trk_dir}/$Abbrev{${test_src}}_$Abbrev{${tr_lang}}".
		"_$Abbrev{${test_lang}},$Abbrev{${test_translate}}_${topic}".".ndx";
	    my $trk_ind_file = "$OutDir/${trk_file}";	    
	    
	    open(IND,">$trk_ind_file") ||
		die("Unable to open index file '$trk_ind_file' for write");
	    write_trk_head(*IND,$topic);
	    ### Write the appropriat training stories
	    foreach $eLang(@$ra_ExemplarLangs){
		foreach $nt(0..MIN($Max_Nt-1, $#{ $rh_trki->{$topic}{"${eLang}_docno"} })){
		    if ($tr_lang eq "${eLang}" || $tr_lang eq "mul"){
			printf IND ("# Topic_training_story %s %s %s %s\n",
				    $rh_trki->{$topic}{"${eLang}_docno"}[$nt],
				    $docinfo_to_ndx_lut{$rh_trki->{$topic}{"${eLang}_srcfile"}[$nt]},
				    get_docno_bound($docinfo_to_ndx_lut{$rh_trki->{$topic}{"${eLang}_srcfile"}[$nt]},
						    $rh_trki->{$topic}{"${eLang}_docno"}[$nt]));
			print TRKCTL_NT1 "$trk_file\n" if ($nt eq "0");
			print TRKCTL_NT2 "$trk_file\n" if ($nt eq "1");
			print TRKCTL_NT4 "$trk_file\n" if ($nt eq "3");
		    }
		}
	    }

	    if ($EvalYear eq "2000"){
		if ($do_topno eq "yes"){
		    print IND "#\n";
		    print IND "# Certified Off-topic Training documents are chronologically listed.  \n";
		    print IND "# Use the last Nn(th) storys for training condition Nn.  The format \n";
		    print IND "# of the lines are as follows:\n";
		    print IND "#    '# Off_topic_training_story <Target_Story_docno> <Source_file> <Begin> <End>'\n";
		    print IND "# Should the training story NOT have any words associated with it, the begin\n";
		    print IND "# and end time/recids will be -1.\n";
		    print IND "#\n";
		    
		    foreach $eLang(@$ra_ExemplarLangs){
			foreach $nt(0..MIN($Max_Nn-1,$#{ $rh_trki->{$topic}{"${eLang}_offtopic_docno"} })){
			    printf IND ("# Off_topic_training_story %s %s %s %s\n",
					$rh_trki->{$topic}{"${eLang}_offtopic_docno"}[$nt],
					$docinfo_to_ndx_lut{$rh_trki->{$topic}{"${eLang}_offtopic_srcfile"}[$nt]},
					get_docno_bound($docinfo_to_ndx_lut{$rh_trki->{$topic}{"${eLang}_offtopic_srcfile"}[$nt]},
							$rh_trki->{$topic}{"${eLang}_offtopic_docno"}[$nt]))
				if ($tr_lang eq "${eLang}" || $tr_lang eq "mul");
			}
		    }
		} else {
		    print IND "#\n";
		    print IND "# The Certified Off-topic Training documents are not present because the\n";
		    print IND "# database of decisions was not found in the following files of the TDT\n";
		    print IND "# root directory.\n";
		    foreach (@{ TopicTopNoStory_FILEs()}){ print IND "#      $Root/$_\n"; }
		    print IND "#\n";
		}
	    }

	    print IND "#\n";
	    print IND "# The following constitutes the source files to be tested on.\n";
	    print IND "# Each line contains two tokens, the source file under test and\n";
	    print IND "# the recid in the tokenized stream where the testing begins.\n";
	    print IND "#\n";
	    $was_last = 0;
	    die if (! defined($rh_trki->{$topic}{"${tr_lang}_srcfile"}[$#{ $rh_trki->{$topic}{"${tr_lang}_srcfile"} }]));
	    foreach(@ndx_list){		
		if ($_ =~ /$rh_trki->{$topic}{"${tr_lang}_srcfile"}[$#{ $rh_trki->{$topic}{"${tr_lang}_srcfile"} }]/ ){
		    $was_last = 1;
		} else {
		    if ($was_last == 1){
			($sourceFile = $_) =~ s:.*/([^\.]+)\..*$:$1:;
			chomp $sourceFile;
			print IND "$_ 1\n" if ($rh_DocInfo->{$sourceFile}->{"is_${test_lang}"} == 1);
		    }
		}
	    }
	}
 	#### Close the Control files
	close IND; 
	close TRKCTL_NT1;
	close TRKCTL_NT2;
	close TRKCTL_NT4;

        if ($do_NtV == 1){
	    print "        Building NtV files\n";
	    #### Build the variable Nt control files
	    my ($ntvindex, $nt4index, $subindex, $condition, $c) = ("", "", "0", "", "");
	    my (@training) = ();
	    my (@vtrain) = ();
	    my ($i, $vid, $vtopic);
	    my @tr;
	    my (@omittedTopics) = ();
	    # open the NT=4 file, and use all of those topics to build new topics
	    open (NT4, $trk_ctl{"4"}) || die "Error: Failed to open Nt=4 ctl file ".$trk_ctl{"4"}."\n";
	    while (<NT4>){
		next if ($_ =~ /^\#/); 
		chomp;
		$nt4index = $_;
		### Build the a list of training stories
		open (TOPICNDX, $nt4index) || die "Error: Failed to open topic index $nt4index\n";
		$topic = "";
		@training = ();
		while(<TOPICNDX>){
		    if ($_ =~ /\# TRACKING RECID TOPIC=(\d+)/) { $topic = $1; }
		    elsif ($_ =~ /^\# Topic_training_story/) { push @training, $_ }
		    
		}
		close TOPICNDX;
		die "Error: Unable to find tracking topic in NT4 indexfile '$nt4index'" if ($topic eq "");
		
		## Do not build variable NT files for multilingual training
		next if ($tr_lang eq "mul");
		
		if (! defined($rh_NtV_topics->{$topic}{'selected'})){
		    push @omittedTopics, $topic;
		    next;
		}
		
		### build each test Nt condition index file
		foreach $c(@{ $rh_NtV_topics->{$topic}{'chosentraining'} }){
		    foreach $condition(split(/\s+/,$c)){
			@vtrain = ();
			## Build the training set
			my @tr = split(//,$condition);
			$vid = 0;
			for ($i=0; $i < @tr; $i++){
			    if ($tr[$i] == 1){
				push (@vtrain, $training[$i]);
				$vid += 2**(4-($i+1));
			    }
			}
			
			## Now read in the NT4 file, replacing the topic id with another one
			## and replacing the training stories with the reduced set
			$vtopic = $topic.sprintf("%02d",$vid);
			($ntvindex = $nt4index) =~ s/_(\d+).ndx/_${vtopic}.ndx/;
		        open (TOPICNDX, $nt4index) || die "Error: Failed to open topic index $nt4index\n";
 		        open (NTV, ">$ntvindex") || die "Error: Failed to open topic index $ntvindex\n";
		        print TRKCTL_NTv "$ntvindex\n";
		        while(<TOPICNDX>){
			    if ($_ =~ /\# TRACKING RECID TOPIC=(\d+)/) { 
				s/(TOPIC=)(\d+)/$1$vtopic/;
				print NTV;
			    } elsif ($_ =~ /^\# Topic_training_story/) { 
				while ($_ =~ /^\# Topic_training_story/) { 
				    $_ = <TOPICNDX>
				    }
				print NTV @vtrain;
				print NTV "#\n";
			    } else {
				print NTV;
			    }			
			}
		        close TOPICNDX;
		        close NTV;
		    }
	        }
	    }
	    if ($main::Vb > 1){
		print "        Topics omitted from training language $tr_lang, NtV topics";
		my $cnt = 0;
		for ($cnt=0; $cnt < @omittedTopics; $cnt++){
		    print "\n            " if ($cnt % 10 == 0);
		    print "$omittedTopics[$cnt] ";
		}
		print "\n";
	    }
	    close NT4;
            close TRKCTL_NTv;
	}
    }
}

sub choose{
    my ($ra_a, $num) = @_;
    my @choice = ();
    my $i;
    for ($i=0; $i<$num; $i++){
	push @choice, splice(@{ $ra_a}, rand(scalar(@{ $ra_a })), 1);
    }
    @choice;
}

sub get_docno_bound{
    my($srcfile, $docno) = @_;
    my (%TDTref) = ();
    my $xVb = $main::Vb;
    my($ind,$rh_bnd);

    ### Build a fake index file
    open(NDX,">/tmp/tmp.ndx") || die "Error: Unable to open temporary index file";
    print NDX "# DETECTION RECID\n";
    print NDX "$srcfile\n";
    close NDX;
    

    my(@IndexList) = ( "/tmp/tmp.ndx" );
    $main::Vb = 0;     
    %TDTref = &Load_Boundaries_Into_TDTRef($Root,\@IndexList,'DETECTION',
					   Boundary_DTDs(),"");
    $main::Vb = $xVb; 
    unlink("/tmp/tmp.ndx");

    die "Error: unable to find fileid for docno '$docno' in file '$srcfile'" 
	if (!defined($TDTref{"docno2fileid"}{$docno}));
    die "Error: unable to lookup docno index for '$docno'"
	if (!defined($TDTref{"bsets"}{$TDTref{"docno2fileid"}{$docno}}{"doc_index"}{$docno}));

    $ind = $TDTref{"bsets"}{$TDTref{"docno2fileid"}{$docno}}{"doc_index"}{$docno};
    $rh_bnd = $TDTref{"bsets"}{$TDTref{"docno2fileid"}{$docno}}{"boundary"}[$ind];
    ($rh_bnd->{"Brecid"}, $rh_bnd->{"Erecid"});
}

sub write_trk_head{
    my($IND,$topic) = @_;
    
    print $IND "# TRACKING RECID TOPIC=${topic}\n";
    &add_date($IND);
    print $IND "#\n";
    print $IND "# Training documents are chronologically listed.  Use the last Nt(th) storys\n";
    print $IND "# for training condition Nt.  The format of the lines are as follows:\n";
    print $IND "#    '# Topic_training_story <Target_Story_docno> <Source_file> <Begin> <End>'\n";
    print $IND "# Should the training story NOT have any words associated with it, the begin\n";
    print $IND "# and end time/recids will be -1\n";
    print $IND "#\n";
}

sub load_ndx_sf{
    my ($file) = @_;
    my @st = ();
    my ($src, $pnt);

    open(FILE,$file) || die "Error: can't open index file $file to extract source files";
    while(<FILE>){
	s/^\s+//;
	s/#.*$//;
	next if ($_ =~ /^\s*$/);
	($src, $pnt) = split(/\s+/,$_);
	#### Translate the source name into an appropriate form
	$src =~ s:^.*/::;
	$src =~ s:\.mt(tkn|as[r0-9])$::;
	$src =~ s:\.(tkn|as[r0-9])$::;
	$src =~ s:\.(ccap|fdch)$::;
	push(@st,$src);
    }
    close FILE;
    @st;
}

sub index_source_files_identical{
    my($file1, $file2) = @_;
    my(@sf1, @sf2);
    
    @sf1 = load_ndx_sf($file1);
    @sf2 = load_ndx_sf($file2);

    ### different number of source files, jusf die
    if ($#sf1 != $#sf2) { 
	print STDERR "Error: index source file sets have different lengths, $#sf1 and $#sf2\n";
	return 0;
    }

    ### Compare the arrays
    while ($#sf1 >= 0){
	if ($sf1[0] ne $sf2[0]){
	    print STDERR "Error: index source file sets are different at files $sf1[0] and $sf2[0]\n";
	    return 0;
	}
	shift(@sf1);
	shift(@sf2);
    } 
    return(1);
}

sub StartHTML{
    my($HTM) = @_;
    
    print $HTM
"<HTML>
<HEAD>
<CENTER><TITLE>TDT Index files</TITLE></CENTER>
<BODY>

<P>
<B><CENTER><FONT COLOR=\"#0000EE\" size=7>TDT Index files</FONT></CENTER></H1></B>

<CENTER>Date: $Date</CENTER>
</HEAD>
<BODY><p><hr>

This directory contains TDT index files.  This directory and HTML file
was automatically generated by $prog, Version $Expected_TDT3Version.  The command executed to
generate this file was:

<DIR>
$CommandLine
</DIR>

The index files define the processing sequence of tokenized
text files and other required evaluation information.  See the
TDT Evaluation Specification for a
description of the index files.

"

}

sub FinishHTML{
    my($HTM) = @_;

    print $HTM "</BODY>\n";
    print $HTM "</HTML>\n";
}

sub numerically_build {$a <=> $b; }

sub langAbbrevToWord{
    my ($lang) = @_;
    my $name = (($lang eq "man") ? "Mandarin" : 
		(($lang eq "mul") ? "Multilingual" :
		 (($lang eq "eng") ? "English" :
		  (($lang eq "arb") ? "Arabic" : "UNKNOWN") ) ) );
    die "Internal Error" if ($name eq "UNKNOWN");
    $name;
}

sub abbrevLang{
    my ($lang) = @_;
    my $name = (($lang eq "Mandarin") ? "man" : 
		(($lang eq "English") ? "eng" :
		 (($lang eq "Arabic") ? "arb" : "UNKNOWN")));
    die "Internal Error" if ($name eq "UNKNOWN");
    $name;
}

