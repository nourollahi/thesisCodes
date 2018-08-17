#!/usr/bin/perl -w

require "flush.pl";

use strict;

require "TDT3.pm";
#require "/data/data2/TDT99/Software/TDT3eval_v1.3/TDT3-v1.pm";

my $Expected_TDT3Version = "2.3";

my $Usage ="Usage: Seg2Bnd.pl <Options> <Arguments>\n".
"TDT library Version: ".&TDT3pm_Version()."\n".
"Desc:  Seg2Bnd.pl converts the output of a TDT Story Segmentation \n".
"       system into TDT3 Corpus compliant story boundary files.\n".
"Options\n".
"   -v num       -> Set the verbose level to 'num'. Default 1\n".
"                   ==0 None, ==1 Normal, >5 Slight, >10 way too much\n".
"   -s           -> Run with all available speedups\n".
"   -m           -> Apply the boundaries to the machine translations.\n".
"                   (This option requires specific files from NIST that\n".
"                    are not documented.)\n".
"Arguments\n".
"   -S           -> Segmentation Output File\n".
"   -d OutDir    -> Write the output files in the 'OutDir' directory\n".
"   -e enum      -> Use the extension '_bnd<enum>' when building the files\n".    
"   -R Rootdir   -> Define the 'root' directory of the TDT3 Corpus as\n".
"                   originally released by the LDC\n".
"   -D str       -> Descriptive string of segmentation type.  e.g. \n".
"                   'IBM Segmentation'.  This datum is added to the remarks\n".
"                   tag of the boundset.\n".
"   -w mtwas0dir -> Directory of the MT working directory for ASR data.\n".
"                   this directory ONLY req'd with option -m\n".
"\n";

die ("Error: Expected version of TDT3.pm is ".&TDT3pm_Version()." not $Expected_TDT3Version")
    if ($Expected_TDT3Version ne &TDT3pm_Version());

#### Globals Variables #####
$main::Vb = 1;
##
my $Root = "";
my $OutDir = "";
my $Sysout = "";
my $BndExtNum = "";
my $Description = "";
my $CommandLine = $0." ".join(" ",@ARGV);
my $ApplyToMT = 0;
my $MT_workdir = "";
############################

############################ Main ###########################
&ProcessCommandLine();
&Generate_boundaries($Sysout, $Root, $Description, $BndExtNum, $OutDir, $ApplyToMT, $MT_workdir);

exit 0;

###################### End of main ############################



sub die_usage{  my($mesg) = @_;    print "$Usage";   
		die("Error: ".$mesg."\n");  }

sub ProcessCommandLine{
    require "getopts.pl";
    &Getopts('D:S:s:d:e:R:v:w:m');

    die_usage("Root Directory for LDC TDT Corpus Req'd") if (!defined($main::opt_R));
    die_usage("Descrition segmentation string Req'd") if (!defined($main::opt_D));
    die_usage("Segmentation Output file Req'd") if (!defined($main::opt_S));
    die_usage("Output Directory Req'd") if (!defined($main::opt_d));
    die_usage("Boundary extension number Req'd") if (!defined($main::opt_e));

    $Root = $main::opt_R;
    $Description = $main::opt_D;
    $OutDir = $main::opt_d;
    if (! -d $OutDir){
	system("mkdir -p $OutDir");
    }
    $Sysout = $main::opt_S;
    $BndExtNum = $main::opt_e;
    $main::Vb = $main::opt_v if (defined($main::opt_v));
    set_TDT3Fast($main::opt_s) if (defined($main::opt_s));
    if (defined($main::opt_m)){
	$ApplyToMT = $main::opt_m;
	die_usage("MT working directory req'd with -m") if (!defined($main::opt_w));
	$MT_workdir = $main::opt_w;
    } else {
	print "MT working directory ignored\n" if (defined($main::opt_w));
    }		  
}

sub Generate_boundaries{
    my($Sysout, $Root, $Description, $BndExtNum,$OutDir, $ApplyToMT, $MT_workdir) = @_;
    my($inrec, $sysoutsrc, $src, $pnt, $sysoutsource, $filetype);
    my(@HypPointers, $System, $DefPeriod, $PointerType, $last_point);
    my($Convert_recid_to_chars) = 0;
    my($ext, $extension, $docnoext, $newbnd, $mtaligned);

    print "Generating Boundary files for '$Sysout'.\n" if ($main::Vb > 0);

    die("Segmentation system output file '$Sysout' not found") 
	if (! -f $Sysout);
    open(SYS,$Sysout) || die("Unable to open Segmentation system ".
			     "output file '$Sysout'");
    ### Read in the header 
    $_ = <SYS>;
    if ($_ =~ /^#/) {
	### Save the description
	chop;
	### Read until we find data
	while ($_ =~ /^#/){  $_ = <SYS>;  }       
    }
	
    # parse the information line
    s/^\s+//;
    ($System, $DefPeriod, $PointerType) = split;
    $PointerType =~ tr/a-z/A-Z/;
    die("Illegal pointer type '$PointerType' != RECID or TIME") 
	if ($PointerType !~ /^(RECID|TIME)$/);
    if ($PointerType eq "RECID"){
	print STDERR ("Warning: Illegal RECID deferral period ".
		      "'$DefPeriod' != 100, 1000 or 10000") 
	    if ($DefPeriod !~ /^(100|1\,*000|10\,*000)$/);
    } else {
	print STDERR ("Warning: Illegal TIME deferral period ".
	    "'$DefPeriod' != 30, 300 or 3000") 
	    if ($DefPeriod !~ /^(30|300|3\,*000)$/);
    }
    die "Error: Script only works using boundaries based on RECIDs" if ($PointerType !~ /^RECID$/);

    ### Let's Party, Read in data until the filename changes
    @HypPointers = ();
    $last_point = 0.0;

    while (! eof(SYS)){
	($inrec = <SYS>) =~ s/^\s+//;
	$inrec =~ s/#.*$//;
	next if ($inrec =~ /^\s*$/);
	($sysoutsrc, $pnt) = split(/\s+/,$inrec);

	#### Translate the source name into an appropriate form
	die "Error: Unable to parse filename '$sysoutsrc'" if ($sysoutsrc !~ /^(.*)\/([^\/]+)\.([^\.]+)$/);
	$src = $2;
	$ext = $3;

	if ($#HypPointers == -1){
	    $sysoutsource = $sysoutsrc;
	    ($mtaligned = "$sysoutsrc.mt_alignedto_asr") =~ s/$ext/mtw$ext/;
	    $extension = ($ApplyToMT ? "mt" : "").$ext;
	    $docnoext = "bnd$BndExtNum";
	    $filetype = "${extension}_$docnoext";
	    $newbnd = "$OutDir/$filetype/$src.$filetype";
	    system("mkdir -p $OutDir/$filetype") if (! -d "$OutDir/$filetype");
	} elsif ($sysoutsource ne $sysoutsrc){
	    &BuildBoundaries(\@HypPointers, $sysoutsource, $Root, $Description, 
			     $docnoext, $newbnd, $mtaligned, $ApplyToMT, $MT_workdir);
    
	    @HypPointers = ();
	    $sysoutsource = $sysoutsrc;
	    ($mtaligned = "$sysoutsrc.mt_alignedto_asr") =~ s/$ext/mtw$ext/;
	    $extension = ($ApplyToMT ? "mt" : "").$ext;
	    $docnoext = "bnd$BndExtNum";
	    $filetype = "${extension}_$docnoext";
	    $newbnd = "$OutDir/$filetype/$src.$filetype";
	    system("mkdir -p $OutDir/$filetype") if (! -d "$OutDir/$filetype");
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
	&BuildBoundaries(\@HypPointers, $sysoutsource, $Root, $Description, 
			 $docnoext, $newbnd, $mtaligned, $ApplyToMT, $MT_workdir);
    }	    
	
   print "\n" if ($main::Vb == 1); 

   close(SYS);
}

sub BuildBoundaries{
    my($ra_HypPointers, $tknsource, $RootDir, $Description, $docnoext, $newbnd, $mtaligned, $ApplyToMT, $MT_workdir) = @_;
    my($max_recid) = 0;
    my $tkndocset = "";
    my %num_lut = ();
    my %MT_xtags = ();
    my ($i, $docno, $docnohead, $prec_wasX, $btext, $max_mt_recid);
    
    if ($main::Vb > 0){
	print "   Build Boundaries $Root/$tknsource,\n";
	print "         Outputing  $newbnd\n";
    }
    
    ############  Load the tokenized text into a structure
    ### Build a lookup table for each word in the nums list
    open(TKN,"$Root/$tknsource") || die("Unable to open token file $Root/$tknsource");
    $prec_wasX = "<X Bsec=0 Dur=0.0 Conf=NA>";
    while (<TKN>){
	if ($_ =~ /^<DOCSET/){
	    $tkndocset = $_;	    
	} elsif ($_ =~ /<W/){	
	    ### Divide the line
	    s/<\S+\s+(.*)>\s*/$1 tkn /;
	    my %th = split(/[=\s]/);
	    $th{"prec_wasX"} = $prec_wasX;
	    $max_recid = $th{"recid"} if ($max_recid < $th{"recid"});
	    $num_lut{$th{"recid"}} = { %th };
	    $prec_wasX = "";
	} elsif ($_ =~ /<X/){	
	    chomp;
	    $prec_wasX = $_;
	}

    }
    close TKN;
    die "Error: unable to find <DOCSET> tag in $Root/$tknsource" if ($tkndocset eq "");

    ##########  If We need to apply the segmentation to the Machine Translations, do this
    if ($ApplyToMT){
	my ($eng, $nat, $xtag);
	open(MTA,"$MT_workdir/$mtaligned") || die("Unable to open aligned MT file $MT_workdir/$mtaligned");
	$max_mt_recid = 0;
	while (<MTA>){
	    next unless ($_ =~ /<eval>[CSID].*<text>(.*)<\/text>.*<text>(.*)<\/text>/);
	    ($eng, $nat) = ($1, $2);
	    
	    ### Get the last recid in the english text.  if there isn't one, ues the last one
	    if ($eng =~ /<W recid=(\d+)[^>]+>[^<>]*$/){
		$max_mt_recid = $1;
	    }

	    next unless ($nat =~ /(<X[^>]+>)/);
	    $xtag = $1;
	    $MT_xtags{$xtag} = $max_mt_recid;
	}
	close MTA;
	### PRIME THE PUMP with a dummy begin tag
	$MT_xtags{"<X Bsec=0 Dur=0.0 Conf=NA>"} = 0;
    }
    
    ### Modify the docset tag
    $tkndocset =~ s/DOCSET/BOUNDSET/;
    if ($tkndocset =~ /remarks=""/){
	$tkndocset = s/remarks=""/remarks="$Description"/;
    } elsif ($tkndocset =~ /remarks="[^"]+"/){ 
        $tkndocset =~ s/(remarks="[^"]+)"/$1 - $Description"/;
    } else {
        die "Error: unable to update remarks attribute in $tkndocset";
    }

    ### Get the collection data
    die "Error: unable to extract collect_src from tage '$tkndocset'" if ($tkndocset !~ /collect_src=(\S{3})/);
    $docnohead = "$1";
    ### Get the collection data
    die "Error: unable to extract collect_date from tage '$tkndocset'" if ($tkndocset !~ /collect_date=(\d{8})_(\d{4})/);
    $docnohead .= "$1.$2";

    ### Set the minimum story beginning point
    unshift(@$ra_HypPointers,1) if ($ra_HypPointers->[0] ne 1);    

    ### Set the maximum point
    if ($ra_HypPointers->[$#{ $ra_HypPointers }] < $max_recid){
	push @{ $ra_HypPointers }, $max_recid + 1;
    }
    
    open (NEWBND,">$newbnd") || die "Error: Failed to open $newbnd for write";
    print NEWBND $tkndocset;
    ### Convert using the lookup tables, find the times for the recids
    for ($i=0; $i < $#{ $ra_HypPointers }; $i++){
	my $begin = $ra_HypPointers->[$i];
	my $end   = $ra_HypPointers->[$i+1] - 1;

	die "Error: Unble to find RECID $begin in TKN file $Root/$tknsource"
	    if (! defined($num_lut{$begin}));
	die "Error: Unble to find RECID $end in TKN file $Root/$tknsource"
	    if (! defined($num_lut{$end}));

        $docno = sprintf("%s.%04d.%s",$docnohead,int($num_lut{$begin}{"Bsec"}),$docnoext);

        if ($ApplyToMT){          
	    die "Error: Story boundary '$btext' does not begin at an <X> tag boundary"
                if ($num_lut{$begin}{"prec_wasX"} eq "");
	    die "Error: Story boundary '$btext' does not end at an <X> tag boundary"
                if ($end < $max_recid && $num_lut{$end+1}{"prec_wasX"} eq "");

            die "Error: Unable to find preceeding recid for tag ".$num_lut{$begin}{"prec_wasX"}.
                " in MT aligned text,  ASR begin recid $begin"
                if (! defined($MT_xtags{$num_lut{$begin}{"prec_wasX"}}));
            die "Error: Unable to find preceeding recid for tag ".$num_lut{$end+1}{"prec_wasX"}.
                " in MT aligned text,  ASR end recid ".($end+1)
                if ($end < $max_recid && (! defined($MT_xtags{$num_lut{$end+1}{"prec_wasX"}})));

	    $btext = sprintf("<BOUNDARY docno=$docno doctype=AUTOMATIC Bsec=%s Esec=%s Brecid=%s Erecid=%s>",
	                 $num_lut{$begin}{"Bsec"},
		         $num_lut{$end}{"Bsec"} + $num_lut{$end}{"Dur"},
		         $MT_xtags{$num_lut{$begin}{"prec_wasX"}} + 1,
		         ($end < $max_recid ? $MT_xtags{$num_lut{$end+1}{"prec_wasX"}} : $max_mt_recid));
        } else {
	    $btext = sprintf("<BOUNDARY docno=$docno doctype=AUTOMATIC Bsec=%s Esec=%s Brecid=%s Erecid=%s>",
	                 $num_lut{$begin}{"Bsec"},
		         $num_lut{$end}{"Bsec"} + $num_lut{$end}{"Dur"},
		         $num_lut{$begin}{"recid"},
		         $num_lut{$end}{"recid"});	       
        }

	print NEWBND "$btext\n";
    }

    print NEWBND "</BOUNDSET>\n";
    close NEWBND;
}
