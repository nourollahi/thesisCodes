
###############################################################################
###############################################################################
###############################################################################
####################
####################            LIBRARY Function Calls
####################

use strict;


### Global Variables
$main::Vb = 0;
$main::ATNIST = 1;
%main::TopicSets = ("TDT98_Train" ,    "20+([1-9]|[12][0-9]|3[0-7])",
		    "TDT98_DevTest",   "20+(3[89]|[45][0-9]|6[0-6])",
		    "TDT98_EvalTest",  "20+(6[7-9]|[89][0-9]|100)",
		    "TDT99_mul",       "20+(1|2|5|7|13|15|20|23|39|44|48|57|70|71|76|85|88|89|91|96)",
                    "TDT3_Arabic", "(300(0[23]|16|33|4[0279]|5[13])|310(0[12469]|1[234679]|2[02469]|3[13456]|4[023458]|5[179]))");

$main::UncompressCommand = "gunzip";
$main::CompressCommand = "gzip";
### End of Globals


my $TDT3Fast = 0;
my $TDT3SkipEmptyStory = 0;

#test $Name:  $
sub TDT3pm_Version{
    "2.5";
}

sub set_TDT3Fast{
    $TDT3Fast = 1;
}

sub set_UncompressCommand{
    ($main::UncompressCommand) = @_;
    print "Uncompression command set to '$main::UncompressCommand'" if ($main::Vb > 5);
}
sub set_CompressCommand{
    ($main::CompressCommand) = @_;
    print "Compression command set to '$main::CompressCommand'" if ($main::Vb > 5);
}

sub Boundary_DTDs{ [ ("bnd_table.dtd", "boundset.dtd") ] }
sub Docset_DTDs{ [ ("docset.dtd") ] }
sub TopicRelevance_FILEs{ [ ("tables/topic_relevance.table", "topics/tdt2_topic_rel.complete_annot", "topics/tdt3_topic_rel.complete_annot", "topics/tdt3_em_topic_rel.v1_0", "topics/tdt3_a_topic_rel.v1_0") ] }
sub TopicTopNoStory_FILEs{ [ ("topics/tdt2_topic_rel.ranked_offtopic_annot", "topics/tdt3_topic_rel.ranked_offtopic_annot", "topics/tdt3_em_ranked_offtopic.v1_0", "topics/tdt3_a_off_topic.v1_0") ] }
sub TopicRelevance_DTDs{ [ ("topic_relevance.dtd", "topicset.dtd") ] }
sub LNKdb_DTDs{ [ ("linkset.dtd") ] }

sub find_FILE{
    my($Root, $interdir,  $ra_dtd) = @_;
    my($name);
    foreach (@$ra_dtd){
	$name = $Root . "/" . (($interdir eq "") ? "" : "$interdir/") . $_;
	return $name if (-f $name);
    }
    die "Error: Unable to locate File, ".(($interdir eq "") ? "" : "$interdir/").
	"'".join("' or '",@{$ra_dtd})."' in '$Root'.";
}

sub Convert_Topic_set_macros{
    my ($r_te) = @_;

    foreach $_(keys %main::TopicSets){
	$$r_te =~ s/$_/$main::TopicSets{$_}/;
    }
}

#
# Boundary Table Structure
# { 

######  Corpus Information   ####
#   Boundary_DTD => "",
#   RootDir => "",
#   Topic_DTD => "",
#   Topic_File => "",

######  Index file Information ####
#   IndexFileList => ""   ### name of the file containing index file name
#                         ### Only used in tracking task
#   IndexList => { '<filename>' => {
#                    index_type => "SEGMENTATION|TRACKING|DETECTION|HIEARCHICAL_DETECTION",
#                    index_pointer_type => "", 
#                    tracking_topic => "", 
#                    source_condition => "",
#                    test:source_language => "",
#                    test:content_language => "",
#                    contents => { '<fileid1>' => 1, ...   },
#                                   list of index file entries, the number indicates the
#                                   starting position, default is 1.
#                                  
#                  } , 
#                }

#######
#
#   datafile_list = { '<boundary_filename>' => '<fileid>',
#                      ## List of read in boundary filenames
#                   }
#   docno2fileid = { '<docno>' => '<fileid>',
#                  }
#   bsets => { "<fileid1>" =>  { doc_index => { '<docno>' => 0,
#                                               '<docno>' => 1,
#                                             }
#                                indexsourcefile => ""   name of the source file in the index
#                                max_recid = XXX;
#                                type = "NEWSWIRE | ASRTEXT | ..."
#                                boundary => ( {docno => "",
#                                               doctype => ""
#                                               Bsec => ""
#                                               Esec => ""
#                                               Brecid => ""
#                                               Erecid => ""
#                                               topicid => ("", "", "")
#                                               t_level => ("", "", "")
#                                               (optionally) offtop_rank => ("", "", ""),  ## the rank of the off-topic story
#                                               (optionally) offtop_score =>("", "", ""),  ## the rank of the off-topic story
#                                              },
#                                              { }
#                                            );
#              "<fileid1>" =>  
#            }
#   results => {  'Scored_files' => { <fileid1> => 1, <fileid2> => 2, ... )
#                 'Seg_params' => { 'System_Output' => "",
#                                   "Pmiss_num" => xx,
#                                   "Pmiss_denom" => xx,
#                                   "Pfa_num" => xx,
#                                   "Pfa_denom" => xx,
#                                   "n_source" => xx,
#                                   "Deferral" => xx,
#                                   "System" => xx,
#                                   "Desc" => xx,
#                                   "FrameSize" => xx,
#                                   "broadcast" => { <broadcast> => { "Pmiss_num" => xx,
#                                                                     "Pmiss_denom" => xx,
#                                                                     "Pfa_num" => xx,
#                                                                     "Pfa_denom" => xx,
#                                                                     "n_source" => xx },
#                                                    ...
#                                   "source" => { <source> => { "Pmiss_num" => xx,
#                                                                     "Pmiss_denom" => xx,
#                                                                     "Pfa_num" => xx,
#                                                                     "Pfa_denom" => xx,
#                                                                     "n_source" => xx },
#                                                    ...
#                                   }
#                                 }
#                 'Det_params' => { 'System_Output' => "",
#                                   "n_source" => xx,
#                                   "Deferral" => xx,
#                                   "System" => xx,
#                                   "Desc" => xx,
#                                   "WithBoundary" => xx,
#                                   "Cost_YDZ_table" = ((,,),(,,)...)
#                                   ###     eval is a list of system judgements for a docno
#                                   "eval" => ( { 'docno' => "",
#                                                 'htopic' => "",
#                                                 'decis' => "",
#                                                 'score' => ""
#                                               }
#                                             )
#                                   "subset_defined" => 1|0  ### true => 1
#                                   "subset_map" => { '<setid>' => 
#                                                     { "title" => "",
#                                                       "heading" => "",
#                                                       "source" => { <source1> => 1,
#                                                                     <source2> => 1, ...
#                                                     }
#                                                   }
#				    "topic_scores" = ( { type = 'hard | thresh'
#                                                        thresh -> 'number' (optional)
#                                                        'Ntestdoc' => "",
#                                                        'Nrefdoc' => "",
#                                                        'Nhypdoc' => "",
#                                                        'Nmiss' => "",
#                                                        'Nfa' => "",
#                                                        'Ncorr' => "", 
#                                                        'Pmiss' => "",
#                                                        'Pfa' => "",
#                                                      used only in [0]
#                                                        'S_Pmiss' => "",
#                                                        'S_Pfa' => "",
#                                                        'S_n' => "",
#                                                        'S_Cdet' => ""}
#                                                      } )
#                                   #### a hash of scores for each ref topic set.  This
#                                        struct is deleted to comput DET curves
#                                   "topic_map" => { '<ref_topic>' => 
#                                                    { 'htopic' => "",
#                                                      'Ntestdoc' => "",
#                                                      'Nrefdoc' => "",
#                                                      'Nhypdoc' => "",
#                                                      'Nmiss' => "",
#                                                      'Nfa' => "",
#                                                      'Ncorr' => "", 
#                                                      'Cdet' => "",
#                                                      'cluster' => { docno => "REF:HYP",
#                                                                     docno => "REF:   ",
#                                                                     docno => "   :   " }
#                                                      ## a structure to hold subset scores
#                                                      'subsets' =>  
#                                                         { 'setid' =>   ## defined in subset map
#                                                           { 'Nmiss' => "",
#                                                             'Nfa' => "", 
#                                                             ...
#                                                           }
#                                                         },
#                                                      },
#                                                    },
#                                                  }
#                                 }
#                 'Trk_params' => { 'System_Output_List' => "",
#                                   'stats' => { 'SW_Pmiss' =>
#                                                'SW_Ctrack' => 
#                                                'SW_Ctrack' => 
#                                                'TW_Pmiss' => 
#                                                'TW_Pfa' => 
#                                                'TW_Ctrack' => 
#                                              }
#                                   "subset_defined" => 1|0  ### true => 1
#                                   "subset_map" => { '<setid>' => 
#                                                     { "title" => "",
#                                                       "heading" => "",
#                                                       "source" => { <source1> => 1,
#                                                                     <source2> => 1, ...
#                                                     }
#                                                   }
#                                   'eval' => ( { TargTopic => ""
#                                                 System_Output => ""
#                                                 System_Name => ""
#                                                 System_Desc => ""
#                                                 WithBoundary => ""
#                                                 TrainNTopic => ""
#                                                     (( In order to speed up the code, and use less
#                                                        Memory, each doc jugement is an array, 
#                                                        indexed by this hash.  so 
#                                                        $eval{'scores'}[X][$eval{'scores_ind'}{'score'}]
#                                                        is the score of the Xth document!
#                                                 scores_ind => { 'score' => 0, 'decision' => '1',
#                                                                 'justify' => 2, 'docno' => '3',
#                                                                 'rtopic' => 4, 'sid' => 5, 'eid' => 6 }
#                                                 scores => (  (0.333, 'YES', 'XX', 'XX', '45'),
#                                                              (X, X, X, X), ...
#                                                            ), 
#                                                }
#                                              )
#                                 }
#                 'Fsd_params' => { 'System_Output' => "",
#                                   "n_source" => xx,
#                                   "Deferral" => xx,
#                                   "System" => xx,
#                                   "Desc" => xx,
#                                   "WithBoundary" => xx,
#                                   "key" => { <topic1> => { "TARG" => (<docno1>, <docno2>, ...),
#                                                            "NONTARG" => (<docno1>, <docno2>, ...)}
#                                               ... }
#                                   "scores" => { "by_topic" => {"#ontopic" => "",
#                                                                "#miss"    => "",
#                                                                "#fa"      => ""}
#                                 }
#  }


#### Make sure there's an system output for each index file
sub Verify_Complete_Test{
    my($rh_TDTref, $indexid, $pad) = @_;
    my($failed) = 0;
    my($k);

    print "${pad}Verifying completness of system output\n" if ($main::Vb > 0);
    die "Undefined index, internal error" 
	if (!defined($rh_TDTref->{'IndexList'}{$indexid}));
    foreach $k(keys %{ $rh_TDTref->{'IndexList'}{$indexid}{'contents'} }) {
	if (! defined($rh_TDTref->{'results'}{'Scored_files'}{$k})){
	    print STDERR "Error: missing system results for file '$k'\n";
	    $failed++;
	}
    }

    die("Correct index/System Output miss-match\n") if ($failed > 0);
    print "${pad}    Complete system output\n" if ($main::Vb > 0);
}

sub Add_Topic_Into_TDTref{
    my($ra_TopicFiles, $ra_Topic_DTDs, $rh_ref, $readAllTopicFiles) = @_;
    my($TopicFile, $name);
    my($loaded) = "";

    ### Search for a single DTD
    foreach (@$ra_Topic_DTDs){
	$rh_ref->{"Topic_DTD"} = $rh_ref->{"RootDir"}."/dtd/$_"
	    if (!defined($rh_ref->{"Topic_DTD"}) && -f $rh_ref->{"RootDir"}."/dtd/$_");
    }
    die "Error: Unable to locate topic relevance DTD.  Not any of the following ".
	join(" ",@$ra_Topic_DTDs) if (!defined($rh_ref->{"Topic_DTD"}));

    ### Try to load all applicable tables
    $rh_ref->{"Topic_File"} = "";
    foreach $name(@$ra_TopicFiles){
	if (-f $rh_ref->{"RootDir"}."/$name" || -f $name){
	    $name = $rh_ref->{"RootDir"}."/$name" if (-f $rh_ref->{"RootDir"}."/$name");

	    if ($loaded ne "" && ($readAllTopicFiles eq "false")){
		print STDERR "Warning: Topic judgements loaded from '$loaded', However, judgements\n".
		    "         from '$name' were ignored.\n";
		next;
	    }
	    
	    $rh_ref->{"Topic_File"} .= " $name";

	    if ($TDT3Fast == 1){
		Add_Topic_Into_TDTref_fast($name, $rh_ref->{"Topic_DTD"}, $rh_ref);
	    } else { 
		Add_Topic_Into_TDTref_sgml($name, $rh_ref->{"Topic_DTD"}, $rh_ref);
	    }
	    $loaded = $name if ($loaded eq "");
	} elsif ($readAllTopicFiles eq "true"){
	    die "Error: Unable to load topic file '$name'.\n";
	}
    }
    die "Error: Unable to load any topic relevance files.  Not any of ".
	join(" ",@$ra_TopicFiles) if ($rh_ref->{"Topic_File"} eq "");
}

sub Add_Topic_Into_TDTref_sgml{
    my($TopicFile, $Topic_DTD, $rh_ref) = @_;
    my($Conformance) = 0;
    my($t_fileid,$t_docno,$t_ind);
    my($RootDir) = $rh_ref->{"RootDir"};
    my($beg_time) = time;

    print "Loading Topic Index '$TopicFile'\n" if ($main::Vb > 0);

    ### open the data Stream
    open(TOPIC,"cat $Topic_DTD $TopicFile |nsgmls |") || die("Unable to open nsgmls parsed data");

    use SGMLS;
    
    my($this_parse) = new SGMLS(*TOPIC); # Read from standard input.
    my($this_event);

    while ($this_event = $this_parse->next_event) {
	my $type = $this_event->type;
	my $data = $this_event->data;
      SWITCH: {
	  $type eq 'start_element' && do {
	      #print "Beginning element: " . $data->name . "\n";
	      if ($data->name eq "ONTOPIC"){
	  $t_docno = $data->attribute('docno')->value;

		  ### Lookup the docno in the docno2fileid hash
		  if (defined($rh_ref->{"docno2fileid"}{$t_docno})){
		      $t_fileid = $rh_ref->{"docno2fileid"}{$t_docno};

		      $t_ind = $rh_ref->{'bsets'}{$t_fileid}{'doc_index'}{$t_docno};
		      
		      if ($rh_ref->{'bsets'}{$t_fileid}{'boundary'}[$t_ind]{'topicid'}[0] ne
			  'n/a'){
			  #### Check the assumption that only one YES topic per docno
			  # if ($data->attribute('level')->value eq 'YES'){
			  # my($l);  
			  # foreach $l(@{ $rh_ref->{'bsets'}{$t_fileid}{'boundary'}
			  # [$t_ind]{'t_level'}}){
			  # die("Multiple YES topic levels for document '$t_docno'")
			  # if ($l eq "YES");
		          # }
		          # }
			  #### Check the assumption that there are no duplicate judgements
			  if (1) {
			      my($i);  
			      for ($i=0; $i<= $#{ $rh_ref->{'bsets'}{$t_fileid}{'boundary'}[$t_ind]{'topicid'} }; $i++){
				  if ($rh_ref->{'bsets'}{$t_fileid}{'boundary'}[$t_ind]{'topicid'}[$i] eq $data->attribute('topicid')->value){
				      if ($rh_ref->{'bsets'}{$t_fileid}{'boundary'}[$t_ind]{'t_level'}[$i] eq $data->attribute('level')->value){
					  print "Warning: story '$t_docno' for topic '".$data->attribute('topicid')->value.
					      "' is multiply annotated as ".$data->attribute('level')->value."\n"
						  if ($main::Vb > 5);
				      } else {
					  die ("Error: story '$t_docno' for topic '".$data->attribute('topicid')->value.
					       "' is ambiguously annotated as ".$data->attribute('level')->value." and ".
					       $rh_ref->{'bsets'}{$t_fileid}{'boundary'}[$t_ind]{'t_level'}[$i])
					      if ($rh_ref->{'bsets'}{$t_fileid}{'boundary'}[$t_ind]{'topicid'}[$i] eq $data->attribute('topicid')->value);
				      }
				  }
			      }
			  }
			  push(@{ $rh_ref->{'bsets'}{$t_fileid}{'boundary'}[$t_ind]{'topicid'}},
			       $data->attribute('topicid')->value);
			  push(@{ $rh_ref->{'bsets'}{$t_fileid}{'boundary'}[$t_ind]{'t_level'}},
			       $data->attribute('level')->value);
			  push(@{ $rh_ref->{'bsets'}{$t_fileid}{'boundary'}[$t_ind]{'offtop_rank'}},
			      ($data->attribute('level')->value eq "NO" && defined($data->attribute('rank')->value)) 
				  ? $data->attribute('rank')->value : "");
			  push(@{ $rh_ref->{'bsets'}{$t_fileid}{'boundary'}[$t_ind]{'offtop_score'}},
			      ($data->attribute('level')->value eq "NO" && defined($data->attribute('score')->value)) 
				  ? $data->attribute('score')->value : "");
		      } else {
			  $rh_ref->{'bsets'}{$t_fileid}{'boundary'}[$t_ind]{'topicid'}[0] =
			      $data->attribute('topicid')->value;
			  $rh_ref->{'bsets'}{$t_fileid}{'boundary'}[$t_ind]{'t_level'}[0] =
			      $data->attribute('level')->value;
			  $rh_ref->{'bsets'}{$t_fileid}{'boundary'}[$t_ind]{'offtop_rank'}[0] =
			      (($data->attribute('level')->value eq "NO" && defined($data->attribute('rank')->value))
			       ? $data->attribute('rank')->value : "");
			  $rh_ref->{'bsets'}{$t_fileid}{'boundary'}[$t_ind]{'offtop_score'}[0] =
			      (($data->attribute('level')->value eq "NO" && defined($data->attribute('score')->value)) 
				  ? $data->attribute('score')->value : "");
		      }
		  }
	      }
	      last SWITCH;
	  };
	  $type eq 'end_element' && do {
	      last SWITCH;
	  };
	  $type eq 'conforming' && do {
	      $Conformance = 1;
	      last SWITCH;
	  };
	  die "Undefined event occurred '$type' in Topic file";
      }
    }
    die("Topic file does not conform to DTD")
	if ($Conformance == 0);
	
    close(TOPIC);

    printf("   .... Topic Index loaded, %d elapsed seconds\n",
	   time - $beg_time) if ($main::Vb > 0);
}

sub Add_Topic_Into_TDTref_fast{
    my($TopicFile, $Topic_DTD, $rh_ref) = @_;
    my($Conformance) = 0;
    my($t_fileid,$t_docno,$t_ind);
    my($RootDir) = $rh_ref->{"RootDir"};
    my(%th);
    my($beg_time) = time;
    print "Loading Topic Index '$TopicFile'\n" if ($main::Vb > 0);

    ### open the data Stream
    open(TOPIC,$TopicFile) || die("Unable to open Topic file '$TopicFile'");

    while (<TOPIC>){
	if ($_ =~ "<ONTOPIC"){
	    ### Divide the line
	    s/<\S+\s+(.*)>\s*$/$1/;
	    s/\s(\S+=)/=$1/g;
	    %th = split(/=/);

	    $t_docno = $th{'docno'};

	    ### Lookup the docno in the docno2fileid hash
	    if (defined($rh_ref->{"docno2fileid"}{$t_docno})){
		$t_fileid = $rh_ref->{"docno2fileid"}{$t_docno};

		$t_ind = $rh_ref->{'bsets'}{$t_fileid}{'doc_index'}{$t_docno};
		      
		if ($rh_ref->{'bsets'}{$t_fileid}{'boundary'}[$t_ind]{'topicid'}[0] ne
		    'n/a'){
		    #### Check the assumption that only one YES topic per docno
		    # if ($data->attribute('level')->value eq 'YES'){
		    # my($l);  
		    # foreach $l(@{ $rh_ref->{'bsets'}{$t_fileid}{'boundary'}
		    # [$t_ind]{'t_level'}}){
		    # die("Multiple YES topic levels for document '$t_docno'")
		    # if ($l eq "YES");
		    # }
		    # }
		    if (1) {
			my($i);  
			for ($i=0; $i<= $#{ $rh_ref->{'bsets'}{$t_fileid}{'boundary'}[$t_ind]{'topicid'} }; $i++){
			    if ($rh_ref->{'bsets'}{$t_fileid}{'boundary'}[$t_ind]{'topicid'}[$i] eq $th{'topicid'}){
				if ($rh_ref->{'bsets'}{$t_fileid}{'boundary'}[$t_ind]{'t_level'}[$i] eq $th{'level'}){
				    print "Warning: story '$t_docno' for topic '".$th{'topicid'}.
					"' is multiply annotated as ".$th{"level"}."\n"
					    if ($main::Vb > 5);				    
				} else {
				    die ("Error: story '$t_docno' for topic '".$th{'topicid'}.
					 "' is ambiguously annotated as ".$th{"level"}." and ".
					 $rh_ref->{'bsets'}{$t_fileid}{'boundary'}[$t_ind]{'t_level'}[$i])
					if ($rh_ref->{'bsets'}{$t_fileid}{'boundary'}[$t_ind]{'topicid'}[$i] eq $th{'topicid'});
				}
			    }
			}
		    }
		    push(@{ $rh_ref->{'bsets'}{$t_fileid}{'boundary'}[$t_ind]{'topicid'}},
			 $th{'topicid'});
		    push(@{ $rh_ref->{'bsets'}{$t_fileid}{'boundary'}[$t_ind]{'t_level'}},
			 $th{'level'});
		    push(@{ $rh_ref->{'bsets'}{$t_fileid}{'boundary'}[$t_ind]{'offtop_rank'}},
			 ($th{'level'} eq "NO" && defined($th{'rank'}) ? $th{'rank'} : ""));
		    push(@{ $rh_ref->{'bsets'}{$t_fileid}{'boundary'}[$t_ind]{'offtop_score'}},
			 ($th{'level'} eq "NO" && defined($th{'score'}) ? $th{'score'} : ""));
		} else {
		    $rh_ref->{'bsets'}{$t_fileid}{'boundary'}[$t_ind]{'topicid'}[0] =
			$th{'topicid'};
		    $rh_ref->{'bsets'}{$t_fileid}{'boundary'}[$t_ind]{'t_level'}[0] =
			$th{'level'};
		    $rh_ref->{'bsets'}{$t_fileid}{'boundary'}[$t_ind]{'offtop_rank'}[0] =
			 ($th{'level'} eq "NO" && defined($th{'rank'}) ? $th{'rank'} : "");	
		    $rh_ref->{'bsets'}{$t_fileid}{'boundary'}[$t_ind]{'offtop_score'}[0] =
			 ($th{'level'} eq "NO" && defined($th{'score'}) ? $th{'score'} : "");
		}
	    }
	}
    }
    close(TOPIC);

    printf("   .... Topic Index loaded, %d elapsed seconds\n",
	   time - $beg_time) if ($main::Vb > 0);
}

sub Load_Boundaries_Into_TDTRef{
    my($RootDir,$ra_IndexList, $evaltype, $ra_Boundary_DTDs, $ExcludeSSD) = @_;
    my($Conformance) = 0;
    my($Boundary_file);
    my($fileid) = "";
    my($parse_fileid);
    my($beg_time) = time;
    my($IndexFile, $IndexSourceFile, $Position);

    my(%rst);
    print "Loading Topic Boundary tables:\n" if ($main::Vb > 0);    

    ### Start the Structure
    # Search for the DTD
    foreach (@$ra_Boundary_DTDs){
	$rst{"Boundary_DTD"} = "$RootDir/dtd/$_"
	    if (!defined($rst{"Boundary_DTD"}) && -f "$RootDir/dtd/$_");
    }
    die "Error: Unable to locate story Boundary DTD.  Not any of the following '".
	join("', '",@$ra_Boundary_DTDs)."'" if (!defined($rst{"Boundary_DTD"}));
    $rst{"RootDir"} = $RootDir;

    ### File Checks 
    die("Boundary file DTD '".$rst{"Boundary_DTD"}."' not found") 
	if (! -f $rst{"Boundary_DTD"});

    ###Load the exclusion source file list
    if ($ExcludeSSD ne ""){
	die ("Exclusion SSD file '$ExcludeSSD' does not exist") if (! -f $ExcludeSSD);
	$rst{"ExcludeSSD_File"} = $ExcludeSSD;
	my ($x_x) = Load_SSDFile($ExcludeSSD,1);
	$rst{"ExcludeSSD"} = $x_x->{"set1"};
	#print join("\n",keys %{ $rst{"ExcludeSSD"}{"source"} })."\n";
    }

    for $IndexFile(@$ra_IndexList){
	$IndexFile =~ s/#.*$//;			  
	next if ($IndexFile =~ /^(#.*|\s*)$/);

#	push(@{ $rst{"Index"} }, $IndexFile);
	print "  Loading Index File $IndexFile\n" if ($main::Vb > 0);
 
	die("Index file '$IndexFile' not found") if (! -f $IndexFile);

	open(INDEX,$IndexFile) || 
	    die("Unable to open index file '$IndexFile'");

	## PARSE the header
	my @head = split(/\s+/,<INDEX>);
	die("Illegal INDEX header line, first field '$head[0]' not '#'")
	    if ($head[0] ne '#');
	die("Illegal INDEX header line, type field '$head[1]' not".
	    " 'SEGMENTATION|TRACKING|DETECTION|FIRST_STORY|HIEARCHICAL_DETECTION'") 
	    if ($head[1] !~ /^(SEGMENTATION|TRACKING|DETECTION|FIRST_STORY|HIEARCHICAL_DETECTION)$/);
	die("Index type '$head[1]' does not match evaluation type '$evaltype'")
	    if ($head[1] ne $evaltype);

	$rst{"IndexList"}{$IndexFile}{'index_type'} = $head[1];

	$head[2] =~ tr/a-z/A-Z/;
	if ($rst{"IndexList"}{$IndexFile}{'index_type'} eq 'SEGMENTATION'){
	    die("Illegal SEGMENTATION INDEX header line, Pointer field ".
		"'$head[2]' not 'RECID|TIME'")
		if ($head[2] !~ /^(RECID|TIME)$/);
	    $rst{"IndexList"}{$IndexFile}{'index_pointer_type'} = $head[2];
	    $rst{"IndexList"}{$IndexFile}{'source_condition'} = 
		get_source_condition(($#head >= 3) ? $head[3] : "") ;
	    $rst{"IndexList"}{$IndexFile}{'test:source_language'} = 
		get_test_source_lang(($#head >= 4) ? $head[4] : "") ;
	    $rst{"IndexList"}{$IndexFile}{'test:content_language'} = 
		get_test_content_lang(($#head >= 5) ? $head[5] : "") ;
	} elsif ($rst{"IndexList"}{$IndexFile}{'index_type'} eq 'HIEARCHICAL_DETECTION'){
	    die("Illegal HIERARCHICAL DETECTION INDEX header line, Pointer field ".
		"'$head[2]' not 'DOCNO'")
		if ($head[2] !~ /^DOCNO$/);
	    $rst{"IndexList"}{$IndexFile}{'index_pointer_type'} = $head[2];
	    $rst{"IndexList"}{$IndexFile}{'source_condition'} = "";
	    $rst{"IndexList"}{$IndexFile}{'test:source_language'} = "";
	    $rst{"IndexList"}{$IndexFile}{'test:content_language'} = "";
	} elsif ($rst{"IndexList"}{$IndexFile}{'index_type'} eq 'DETECTION'){
	    die("Illegal DETECTION INDEX header line, Pointer field ".
		"'$head[2]' not 'RECID|TIME'")
		if ($head[2] !~ /^(RECID|TIME)$/);
	    $rst{"IndexList"}{$IndexFile}{'index_pointer_type'} = $head[2];
	    $rst{"IndexList"}{$IndexFile}{'source_condition'} = "";
	    $rst{"IndexList"}{$IndexFile}{'test:source_language'} = "";
	    $rst{"IndexList"}{$IndexFile}{'test:content_language'} = "";
	} elsif ($rst{"IndexList"}{$IndexFile}{'index_type'} eq 'FIRST_STORY'){
	    die("Illegal FIRST_STORY INDEX header line, Pointer field ".
		"'$head[2]' not 'RECID|TIME'")
		if ($head[2] !~ /^(RECID|TIME)$/);
	    $rst{"IndexList"}{$IndexFile}{'index_pointer_type'} = $head[2];
	    $rst{"IndexList"}{$IndexFile}{'source_condition'} = "";
	    $rst{"IndexList"}{$IndexFile}{'test:source_language'} = "";
	    $rst{"IndexList"}{$IndexFile}{'test:content_language'} = "";
	} elsif ($rst{"IndexList"}{$IndexFile}{'index_type'} eq 'TRACKING'){
	    die("Illegal TRACKING INDEX header line, Pointer field ".
		"'$head[2]' not 'RECID|TIME'")
		if ($head[2] !~ /^(RECID|TIME)$/);
	    $rst{"IndexList"}{$IndexFile}{'index_pointer_type'} = $head[2];
	    # Get the topic id for the index file 
	    die "Illegal TRACKING INDEX header line, no topic field "
		if ($#head < 3 || ($head[3] !~ /^TOPIC=(\d+)$/));
	    $rst{"IndexList"}{$IndexFile}{'tracking_topic'} = $1;   
	    ### Handle the variable topic ids
	    if (length($rst{"IndexList"}{$IndexFile}{'tracking_topic'}) == 7){
		($rst{"IndexList"}{$IndexFile}{'tracking_topic_NTV'} =
		 $rst{"IndexList"}{$IndexFile}{'tracking_topic'}) =~ s/^(\d\d\d\d\d)(\d\d)$/$2/;
		$rst{"IndexList"}{$IndexFile}{'tracking_topic'} = $1;
	    } else {
		$rst{"IndexList"}{$IndexFile}{'tracking_topic_NTV'} = "";
	    }
	    $rst{"IndexList"}{$IndexFile}{'source_condition'} = "";
	    $rst{"IndexList"}{$IndexFile}{'test:source_language'} = "";
	    $rst{"IndexList"}{$IndexFile}{'test:content_language'} = "";
	} else {
	    die "AHHHHHHHH Somting wong!";
	}
	
	while (<INDEX>){
	    s/#.*$//;			  
	    next if ($_ =~ /^(\#.*|\s*)$/);
	    chop;
	    ($IndexSourceFile, $Position) = split;
	    
	    ### Figure out the boundary file name from the index file
	    die "Error: Unable to parse index source file from '$_'"
		if ($IndexSourceFile !~ /^(.*)\/(.*)\.([^\.]+)$/);
	    my($idf_dir) = $1;
	    my($idf_file) = $2;
	    my($idf_ext) = $3;
	    if (defined($rst{"ExcludeSSD"}{"source"}{$idf_file})){
		print "    Excluding sourcefile '$idf_file'\n" if ($main::Vb > 2);
		next;
	    }

	    ### Check fot the old style 
	    my $Boundary_file1 = "$RootDir/tables/$idf_file.bnd${idf_ext}";
	    my $Boundary_file2 = "$RootDir/${idf_ext}_bnd/$idf_file.${idf_ext}_bnd";
	    if (! -f $Boundary_file1){
		### Check for the new style
		die "Error: Unable to locate boundary file for '$IndexSourceFile' in '$Boundary_file1' or  '$Boundary_file2'"
		    if (! -f $Boundary_file2);
		$Boundary_file = $Boundary_file2;
	    } else {
		$Boundary_file = $Boundary_file1;
	    }
	    ### Found the boundary file

            if (! defined($Position)){
		if ($rst{"IndexList"}{$IndexFile}{'index_pointer_type'} eq "RECID"){
		    $Position = "1"; 
		} else {
		    $Position = "0" ;
		}
	    }
	    if ($TDT3Fast == 1){
		&load_Boundary_file_fast(\%rst, "$Boundary_file",
					 $IndexFile, $Position, "$RootDir/$IndexSourceFile");
	    } else {
		&load_Boundary_file(\%rst, "$Boundary_file",
				    $IndexFile, $Position, "$RootDir/$IndexSourceFile");
	    }
	    
	}
	close(INDEX);
    }

    printf("   .... Topic Boundary tables loaded, %d elapsed seconds\n",
	   time - $beg_time) if ($main::Vb > 0);
    %rst;
}

sub get_source_condition{
    my($text) = @_;
    my $src_exp = "(bnasr|bnman|nwt+bnasr|nwt+bnman)";
    
    if ($text eq ""){
	"default";
    } elsif ($text =~ /^SRC=($src_exp)$/){
	$1;
    } else {
	printf STDERR "Warning: Unknown source condition '$text' ! '$src_exp'\n";
	"default";
    }
}

sub get_test_source_lang{
    my($text) = @_;
    my $src_exp = "(eng|man|mul)";
    
    if ($text eq ""){
	"default";
    } elsif ($text =~ /^TEST:SL=($src_exp)$/){
	$1;
    } else {
	printf STDERR "Warning: Unknown test source language '$text' ! '$src_exp'\n";
	"default";
    }
}

sub get_test_content_lang{
    my($text) = @_;
    my $src_exp = "(nat|eng)";
    
    if ($text eq ""){
	"default";
    } elsif ($text =~ /^TEST:CL=($src_exp)$/){
	$1;
    } else {
	printf STDERR "Warning: Unknown test content language '$text' ! '$src_exp'\n";
	"default";
    }
}

sub load_Boundary_file{
    my($rh_rst, $bfile, $IndexFile, $position, $IndexSourceFile) = @_;
    my($source);
    my($max_recid) = 0;
    my($Conformance);

    ### Remeber the source files in the index for future checking
    ($source = $bfile) =~ s:^.*/::;
    $source =~ s:\.[^\.]+$::;

    $rh_rst->{'IndexList'}{$IndexFile}{'contents'}{$source} = $position;	

    ### Look to see if it has been loaded already.  If so, skip it
    if (defined($rh_rst->{'datafile_list'}{$bfile})){
	print "     Boundary file '$bfile' already loaded\n" if ($main::Vb > 5);
    } else {
	print "     Loading Boundary file '$bfile'\n" if ($main::Vb > 5);
	$max_recid = 0;
	
	### open the data Stream
	die("Boundary file '$bfile' not found") if (! -f $bfile);
	open(BND,"cat ".$rh_rst->{"Boundary_DTD"}." $bfile | nsgmls|")|| 
	    die("Unable to open nsgmls parsed data ".$rh_rst->{"Boundary_DTD"}." $bfile ");
	
	use SGMLS;
	
	my $this_parse = new SGMLS(*BND); 
	my $this_event;
	my (%th, $key, $parse_fileid);

	while ($this_event = $this_parse->next_event) {
	    my $type = $this_event->type;
	    my $data = $this_event->data;
	  SWITCH: {
	      $type eq 'start_element' && do {
 		  if ($data->name eq "BOUNDSET"){
		      # print "Beginning element: " . $data->name . "\n";
		      %th = ();
		      $parse_fileid = $data->attribute('fileid')->value;
		      foreach $key($data->attribute_names ){
			  $rh_rst->{"bsets"}{$parse_fileid}{$key} = 
			      (defined($data->attribute($key)->value) ?
			       $data->attribute($key)->value : "");
		      }
		      $rh_rst->{'datafile_list'}{$bfile} = $parse_fileid;
		      $rh_rst->{"bsets"}{$parse_fileid}{'datafile'} = $bfile;
		  } elsif ($data->name eq "BOUNDARY"){
		      # print "Beginning element: " . $data->name . "\n";
		      foreach $key($data->attribute_names ){
			  $th{$key} = (defined($data->attribute($key)->value) ?
				       $data->attribute($key)->value : "");
		      }	
		      ######### Skip boundaries with no words #######
		      if ((! defined($th{'Brecid'})) &&
			  (! defined($th{'Erecid'} ))){
			  if ($TDT3SkipEmptyStory) {
			      last SWITCH;
			  } else {
			      $th{'Brecid'} = "";
			      $th{'Erecid'} = "";
			  }
		      }
		      ################################################
		      $th{'t_level'} = [ ( 'n/a' ) ];
		      $th{'topicid'} = [ ( 'n/a' ) ];
		      $th{'offtop_rank'} = [ ( 'n/a' ) ];
		      $th{'offtop_score'} = [ ( 'n/a' ) ];

		      if ($rh_rst->{"IndexList"}{$IndexFile}{'index_pointer_type'}
			  eq "RECID"){
			  $th{'Bsec'} = 'n/a'
			      if (! defined($th{'Bsec'}));
			  $th{'Esec'} = 'n/a'
			      if (! defined($th{'Esec'}));
		      } else {
			  die("Index Pointer type is TIME, but no time attrib".
			      "utes found in boundary file '$bfile'")
			      if ((! defined($th{'Bsec'})) ||
				  (! defined($th{'Esec'})));
		      }
		      die("Required Boundary element 'FILEID' not found ")
			  if ($parse_fileid eq "");
		      die("Required Boundary element 'DOCNO' not found")
			  if ($th{'docno'} eq "");
		      
		      if ($th{'Erecid'} ne ""){
			  $max_recid = $th{'Erecid'} if ($th{'Erecid'} > $max_recid);
		      }
		      push(@{ $rh_rst->{'bsets'}{$parse_fileid}{'boundary'} },
			   { %th });
		      $rh_rst->{'bsets'}{$parse_fileid}{'doc_index'}{$th{'docno'}} =
			  $#{ $rh_rst->{'bsets'}{$parse_fileid}{'boundary'} };
		      $rh_rst->{"docno2fileid"}{$th{'docno'}} = $parse_fileid;
		  }
		  last SWITCH;
	      };
	      $type eq 'end_element' && do {
		  last SWITCH;
	      };
	      $type eq 'conforming' && do {
		  $Conformance = 1;
		  last SWITCH;
	      };
	      die "Undefined event occurred '$type'";
	  }
	}
	die("Boundary file '$bfile' does not conform to DTD")
	    if ($Conformance == 0);
	$rh_rst->{'bsets'}{$parse_fileid}{'max_recid'} = $max_recid;
	$rh_rst->{'bsets'}{$parse_fileid}{'indexsourcefile'} = $IndexSourceFile;
	close(BND);
    }
}

sub load_Boundary_file_fast{
    my($rh_rst, $bfile, $IndexFile, $position, $IndexSourceFile) = @_;
    my($source);
    my($max_recid) = 0;
    my(%th) = ();
    my($parse_fileid, $key);

    ### Remeber the source files in the index for future checking
    ($source = $bfile) =~ s:^.*/::;
    $source =~ s:\.[^\.]+$::;

    $rh_rst->{'IndexList'}{$IndexFile}{'contents'}{$source} = $position;	

    ### Look to see if it has been loaded already.  If so, skip it
    if (defined($rh_rst->{'datafile_list'}{$bfile})){
	print "     Boundary file '$bfile' already loaded\n" if ($main::Vb > 5);
    } else {
	print "     Loading Boundary file '$bfile'\n" if ($main::Vb > 5);
	$max_recid = 0;
    
	### open the data Stream
	die("Boundary file '$bfile' not found") if (! -f $bfile);
	open(BND,$bfile) ||  die("Unable to open boundary $bfile ");

	while (<BND>){
	    if ($_ =~ /<BOUNDSET/){
		### Divide the line
		s/<\S+\s+(.*)>\s*$/$1/;
		s/\s(\S+=)/=$1/g;
		%th = split(/=/);
		
		## Extract data
		$parse_fileid = $th{'fileid'};
		foreach $key(keys %th){
		    $rh_rst->{"bsets"}{$parse_fileid}{$key} = $th{$key}
		}
		$rh_rst->{'datafile_list'}{$bfile} = $parse_fileid;
		$rh_rst->{"bsets"}{$parse_fileid}{'datafile'} = $bfile;

	    } elsif ($_ =~ "<BOUNDARY"){
		### Divide the line
		s/<\S+\s+(.*)>\s*$/$1/;
		s/\s(\S+=)/=$1/g;
		%th = split(/=/);
		
		######### Skip boundaries with no words #######
		if ((! defined($th{'Brecid'})) &&
		    (! defined($th{'Erecid'} ))){
		    if ($TDT3SkipEmptyStory) {
			next;
		    } else {
			$th{'Brecid'} = "";
			$th{'Erecid'} = "";
		    }
		}
		################################################
		$th{'t_level'} = [ ( 'n/a' ) ];
		$th{'topicid'} = [ ( 'n/a' ) ];
		$th{'offtop_rank'} = [ ( 'n/a' ) ];
		$th{'offtop_score'} = [ ( 'n/a' ) ];

		if ($rh_rst->{"IndexList"}{$IndexFile}{'index_pointer_type'}
		    eq "RECID"){
		    $th{'Bsec'} = 'n/a'
			if (! defined($th{'Bsec'}));
		    $th{'Esec'} = 'n/a'
			if (! defined($th{'Esec'}));
		} elsif ($rh_rst->{"IndexList"}{$IndexFile}{'index_pointer_type'}
		    eq "TIME"){
		    die("Index Pointer type is TIME, but no time attrib".
			"utes found in boundary file '$bfile'")
			if ((! defined($th{'Bsec'})) ||
			    (! defined($th{'Esec'})));
		}
		die("Required Boundary element 'FILEID' not found ")
		    if ($parse_fileid eq "");
		die("Required Boundary element 'DOCNO' not found")
		    if ($th{'docno'} eq "");
		
		if ($th{'Erecid'} ne ""){
		    $max_recid = $th{'Erecid'} if ($th{'Erecid'} > $max_recid);
		}
		push(@{ $rh_rst->{'bsets'}{$parse_fileid}{'boundary'} },
		     { %th });
		$rh_rst->{'bsets'}{$parse_fileid}{'doc_index'}{$th{'docno'}} =
		    $#{ $rh_rst->{'bsets'}{$parse_fileid}{'boundary'} };
		$rh_rst->{"docno2fileid"}{$th{'docno'}} = $parse_fileid;
	    }
	}
	$rh_rst->{'bsets'}{$parse_fileid}{'max_recid'} = $max_recid;
	$rh_rst->{'bsets'}{$parse_fileid}{'indexsourcefile'} = $IndexSourceFile;
	close(BND);
    }
}


sub Dump_detection_decisions{
    my($rh_ref, $OutFile) = @_;
    my($fileid, $i, $k, $b, $bnd, $k1, $k2, $set, $attr);
    my(@ik) = ();
    my(@sfl, $sf, $key);

    if (! open(OUT,">$OutFile")){
	die "Error: unable to open Detail file '$OutFile'\n";
    }
    print "Writing Decision set to '$OutFile'\n" if ($main::Vb > 0 && $OutFile ne "-");

    print OUT "<Detection_Decisions>\n";
    my($ra_a) = \@{ $rh_ref->{'results'}{'Det_params'}{'eval'} };
    for ($i=0; $i <= $#$ra_a; $i++){
	$k="docno";   print OUT "<Detection docno=".$ra_a->[$i]{$k};
	print OUT " htopic=".$ra_a->[$i]{'htopic'} ;
	if (0){
	    ### Lookup additional info
	    my($lutf) = $rh_ref->{'docno2fileid'}{$ra_a->[$i]{$k}} ;
	    my($lutb) = $rh_ref->{'bsets'}{$lutf}{'doc_index'}{$ra_a->[$i]{$k}};
	    print OUT " Brecid=".$rh_ref->{'bsets'}{$lutf}{'boundary'}[$lutb]{'Brecid'} ;
	    print OUT " Erecid=".$rh_ref->{'bsets'}{$lutf}{'boundary'}[$lutb]{'Erecid'} ;
	}
	print OUT ">\n";
    }
    print OUT "</Detection_Decisions>\n";
    close OUT;
}

sub dump_TDTref{
    my($rh_ref, $OutFile) = @_;
    my($fileid, $i, $k, $b, $bnd, $k1, $k2, $set, $attr);
    my(@ik) = ();
    my(@sfl, $sf, $key);

    if (! open(OUT,">$OutFile")){
	die "Error: unable to open Detail file '$OutFile'\n";
    }
    print "Writing detailed report to '$OutFile'\n" if ($main::Vb > 0 && $OutFile ne "-");

    print OUT "TDTRef table\n";
    @ik = sort(keys %{ $rh_ref->{"IndexList"} });
    for ($i=0; $i<= $#ik; $i++){
	print OUT "  Index:         '$ik[0]'";
	
	foreach $k(keys %{ $rh_ref->{"IndexList"}{$ik[$i]} }){
	    print OUT " $k=".$rh_ref->{"IndexList"}{$ik[$i]}{$k} if ($k ne "contents");
	}
	print OUT "\n";

	print OUT "    Statistics:\n";
	@sfl = keys %{ $rh_ref->{'IndexList'}{$ik[$i]}{'contents'} };
	printf OUT "       Number of source files: %d\n", $#sfl+1;
	my $bnds = 0;
	my(%btypes) = ();
	my(%btypes_empty) = ();
	my(%topics_yes) = ();
	my(%topics_no) = ();
	my(%topics_Nyes) = ();
	my(%topics_Multi_yes) = ();
	my(%topics_Multi_Nyes) = ();
	foreach $sf(@sfl){
	    $bnds += $#{ $rh_ref->{'bsets'}{$sf}{'boundary'} } + 1;
	    for ($bnd=0; $bnd<=$#{ $rh_ref->{'bsets'}{$sf}{'boundary'} }; $bnd++){		
		my $rh_b = \%{ $rh_ref->{'bsets'}{$sf}{'boundary'}[$bnd] };
		my $n;
		
		die "Internal error, missing doctype for ".$rh_b->{'docno'}."\n" 
		    if (!defined($rh_b->{"doctype"}));

		if (!defined($btypes{$rh_b->{'doctype'}})){
		    $btypes{$rh_b->{'doctype'}} = 0;
		    $btypes_empty{$rh_b->{'doctype'}} = 0;
		}
		$btypes{$rh_b->{'doctype'}} ++;
		$btypes_empty{$rh_b->{'doctype'}} ++ 
		    if ($rh_b->{'Brecid'} eq "" && $rh_b->{'Erecid'} eq "");
		

		for ($n=0; $n<= $#{ $rh_b->{'topicid'} }; $n++){
		    if ($rh_b->{'topicid'}[$n] ne 'n/a'){
			if (!defined($topics_yes{$rh_b->{'topicid'}[$n]})){
			    $topics_yes{$rh_b->{'topicid'}[$n]} = 0;
			    $topics_no{$rh_b->{'topicid'}[$n]} = 0;
			    $topics_Nyes{$rh_b->{'topicid'}[$n]} = 0;
			    $topics_Multi_yes{$rh_b->{'topicid'}[$n]} = 0;
			    $topics_Multi_Nyes{$rh_b->{'topicid'}[$n]} = 0;
			}
			if ($rh_b->{'t_level'}[$n] =~ /YES/i){
			    $topics_yes{$rh_b->{'topicid'}[$n]} ++;
			    if ($#{ $rh_b->{'topicid'} } > 0){
				$topics_Multi_yes{$rh_b->{'topicid'}[$n]} ++;
			    }
			} else {
			    $topics_Nyes{$rh_b->{'topicid'}[$n]} ++;
			    if ($#{ $rh_b->{'topicid'} } > 0){
				$topics_Multi_Nyes{$rh_b->{'topicid'}[$n]} ++;
			    }
			    if ($rh_b->{'t_level'}[$n] =~ /NO/i){
				$topics_no{$rh_b->{'topicid'}[$n]} ++;
			    }
			}
		    }
		}
	    }
	}
	printf OUT "       Number of boundary records: %d\n", $bnds;
	foreach $key(keys %btypes){
	    printf OUT "         Number of doctype %20s %d, (%d without recids)\n", 
	               $key, $btypes{$key}, $btypes_empty{$key};
	}
	printf OUT "       Annotated topic occurences\n";
	foreach $key(sort(keys %topics_yes)){
	    printf OUT ("         Topic %3s:  %3d  (%3d:YES[%3d:Multi] %3d:NotYES[%3d:Multi, %3d:NO] ) \n",
			$key, $topics_yes{$key} + $topics_Nyes{$key},
			$topics_yes{$key}, $topics_Multi_yes{$key},
			$topics_Nyes{$key}, $topics_Multi_Nyes{$key}, $topics_no{$key}
			);
	}
    }
    print OUT "  Boundary DTD:  '".$rh_ref->{"Boundary_DTD"}."'\n";
    my @fileids = keys %{ $rh_ref->{'bsets'} };
    printf OUT "  # Boundaryfiles = %d\n",$#fileids+1;

    if (defined($rh_ref->{"ExcludeSSD"})){
	print OUT "  Excluded Source Files, file='".$rh_ref->{"ExcludeSSD_File"}."'\n";
	print OUT "    Title='".$rh_ref->{"ExcludeSSD"}{"title"}."'\n";
	print OUT "    Heading='".$rh_ref->{"ExcludeSSD"}{"heading"}."'\n";
	print OUT "    SourceFiles=\n      ".
	    join("\n      ",keys(%{ $rh_ref->{"ExcludeSSD"}{"source"} }))."\n";
    }
	
    foreach $fileid(sort(keys %{ $rh_ref->{'bsets'} })){
	print OUT "    Fileid: '".$fileid."' \n";
	foreach $k(keys %{ $rh_ref->{'bsets'}{$fileid} }){
	    if ($k ne 'boundary' && $k ne "doc_index"){
		print OUT "      $k -> $rh_ref->{'bsets'}{$fileid}{$k}\n";
	    }
	}
	print OUT "      Documents:\n";
	foreach ($i=0; $i<= $#{ $rh_ref->{'bsets'}{$fileid}{'boundary'} }; $i++){
	    my $dn = $rh_ref->{'bsets'}{$fileid}{'boundary'}[$i]{'docno'};
	    print OUT "        id=> ".
		$rh_ref->{'bsets'}{$fileid}{'doc_index'}{$dn};
	    print OUT " ";
	    foreach $k (keys %{ $rh_ref->{'bsets'}{$fileid}{'boundary'}[$i] }){
		print OUT "$k=> ".$rh_ref->{'bsets'}{$fileid}{'boundary'}[$i]{$k}." "
		    if ($k !~ /^(t_level|topicid|offtop_rank|offtop_score)$/);
	    }
	    my($n); 
	    print OUT "Topic/level=>";
	    for ($n=0; 
		 $n<= $#{ $rh_ref->{'bsets'}{$fileid}{'boundary'}[$i]{'topicid'} };
		 $n++){
		print OUT " ".
		    $rh_ref->{'bsets'}{$fileid}{'boundary'}[$i]{'topicid'}[$n]."/".
		    $rh_ref->{'bsets'}{$fileid}{'boundary'}[$i]{'t_level'}[$n];
	    }
	    print OUT "OfftopicRank/Score=>";
	    for ($n=0; 
		 $n<= $#{ $rh_ref->{'bsets'}{$fileid}{'boundary'}[$i]{'offtop_rank'} };
		 $n++){
		print OUT " ".
		    $rh_ref->{'bsets'}{$fileid}{'boundary'}[$i]{'offtop_rank'}[$n]."/".
		    $rh_ref->{'bsets'}{$fileid}{'boundary'}[$i]{'offtop_score'}[$n];
	    }
	    print OUT "\n";
	}
    }
    print OUT "  RESULTS:\n";
    print OUT "    Scored file ids:\n";
    foreach $k(sort(keys %{ $rh_ref->{'results'}{'Scored_files'} } )){
	print OUT "      $k\n";
    }
    if (defined($rh_ref->{'results'}{'Seg_params'})){
	print OUT "    Segmentation Params:\n";
	foreach $k(sort(keys %{ $rh_ref->{'results'}{'Seg_params'} } )){
	    if ($k !~ /^(broadcast|source)$/ ){
		print OUT "      $k => '".$rh_ref->{'results'}{'Seg_params'}{$k}."'\n";
	    } else {
		foreach $k1(keys %{ $rh_ref->{'results'}{'Seg_params'}{$k} }){
		    print OUT "      $k => $k1 : ";
		    foreach $k2(keys %{ $rh_ref->{'results'}{'Seg_params'}{$k}{$k1} }){
			print OUT " $k2=>".$rh_ref->{'results'}{'Seg_params'}{$k}{$k1}{$k2};
		    }
		    print OUT "\n";
		}
	    }
	}
	
	printf OUT ("\n      P(miss) = %f\n",
	       $rh_ref->{'results'}{'Seg_params'}{'Pmiss_num'}/
	       $rh_ref->{'results'}{'Seg_params'}{'Pmiss_denom'});
	printf OUT ("      P(fa)   = %f\n",
	       $rh_ref->{'results'}{'Seg_params'}{'Pfa_num'}/
	       $rh_ref->{'results'}{'Seg_params'}{'Pfa_denom'});
	
    }
    if (defined($rh_ref->{'results'}{'Det_params'})){
	print OUT "    Detection Params:\n";
	foreach $k(sort(keys %{ $rh_ref->{'results'}{'Det_params'} } )){
	    print OUT "      $k => '".$rh_ref->{'results'}{'Det_params'}{$k}."'\n"
		if ($k !~ /eval|subset_map/);
	}
	$k = "subset_map";
	print OUT "      $k => \n";
	foreach $set(keys %{ $rh_ref->{'results'}{'Det_params'}{$k} }){
	    print OUT "          set $set\n";
	    foreach $attr(keys %{ $rh_ref->{'results'}{'Det_params'}{$k}{$set} }){
		print OUT "              $attr => ".
		    $rh_ref->{'results'}{'Det_params'}{$k}{$set}{$attr}."\n";
	    }
	}
	
	print OUT "      Document Decision List\n";
	my($ra_a) = \@{ $rh_ref->{'results'}{'Det_params'}{'eval'} };
	print OUT "        ".$#$ra_a."\n";
	for ($i=0; $i <= $#$ra_a; $i++){
	    print OUT "        ";
	    $k="docno";   print OUT " [$k=>".$ra_a->[$i]{$k};
	    ### Lookup additional info
	    my($lutf) = $rh_ref->{'docno2fileid'}{$ra_a->[$i]{$k}} ;
	    my($lutb) = $rh_ref->{'bsets'}{$lutf}{'doc_index'}{$ra_a->[$i]{$k}};
	    print OUT " htopic=".$ra_a->[$i]{'htopic'} ;
	    print OUT " Brecid=".$rh_ref->{'bsets'}{$lutf}{'boundary'}[$lutb]{'Brecid'} ;
	    print OUT " Erecid=".$rh_ref->{'bsets'}{$lutf}{'boundary'}[$lutb]{'Erecid'} ;
	    print OUT "]";
	    ### 
	    foreach $k(sort(keys %{ $ra_a->[$i] } )){
		print OUT " $k=> '".$ra_a->[$i]{$k}."'" if ($k ne "docno");
	    }
	    print OUT "\n";
	}
	print OUT "      Topic Mapping List\n";
	$ra_a = \@{ $rh_ref->{'results'}{'Det_params'}{'topic_map'} };
	for ($i=0; $i <= $#$ra_a; $i++){
	    die "oops i=$i" if (!defined($ra_a->[$i]{'rtopic'}));
	    print OUT "        Ref topic: ".$ra_a->[$i]{'rtopic'}." maps to hyp ";
	    print OUT "topic: ".$ra_a->[$i]{'htopic'}."\n          Scores: ";
	    foreach $k(sort(keys %{ $ra_a->[$i] } )){
		print OUT " $k=> ".$ra_a->[$i]{$k} if ($k !~ /topic|subsets|cluster/);
	    }
	    print OUT "\n          Subsets: ";
	    foreach $k(sort(keys %{ $ra_a->[$i]{'subsets'} } )){
		print OUT " { $k :";
		foreach $k1(sort(keys %{ $ra_a->[$i]{'subsets'}{$k} } )){
		    print OUT " $k1=> ".$ra_a->[$i]{'subsets'}{$k}{$k1};
		}
		print OUT " } ";
	    }
	    print OUT "\n          Documents: \n";
	    foreach $k(sort(keys %{ $ra_a->[$i]{'cluster'} } )){
		printf OUT "                     %-40s %s\n",$k,$ra_a->[$i]{'cluster'}{$k};
	    }
	}
    }
    if (defined($rh_ref->{'results'}{'Fsd_params'})){
	my($topic, $dn, $rh_b);

	print OUT "    First Story Params:\n";
	foreach $k(sort(keys %{ $rh_ref->{'results'}{'Fsd_params'} } )){
	    print OUT "      $k => '".$rh_ref->{'results'}{'Fsd_params'}{$k}."'\n"
		if ($k !~ /eval|key|hdoc|scores/);
	}

	$rh_b = \%{ $rh_ref->{'results'}{'Fsd_params'}{'key'} };
	print OUT "      Reference Key\n";
	### Write the key file
	foreach $topic(sort(keys %$rh_b)){     
	    foreach ("TARG", "NONTARG"){
		foreach $dn(0 .. $#{ $rh_b->{$topic}{$_} }){
		    print OUT "        key_topic=$topic $_ dn=$dn docno=$rh_b->{$topic}{$_}[$dn]\n";
		}
	    }
	    print OUT "\n";
	}    
	{
	    $rh_b = \%{ $rh_ref->{'results'}{'Fsd_params'}{'scores'} };
	    print OUT "      Scores Structure\n";
	    foreach $k(sort(keys %{ $rh_b } )){
		print OUT "        $k => '".$rh_ref->{'results'}{'Fsd_params'}{'scores'}{$k}."'\n"
		    if ($k !~ /by_topic|trial_data/);
	    }
	    ### the by_topic stuff
	    $k = "by_topic";
	    print OUT "        $k =>\n";
	    $rh_b = \%{ $rh_ref->{'results'}{'Fsd_params'}{'scores'}{'by_topic'} };
  	    foreach $topic(sort(keys %$rh_b)){	
		print OUT "           $topic => ";
		foreach $k1(keys %{ $rh_b->{$topic} }){
		    print OUT "$k1=$rh_b->{$topic}{$k1} ";
		}
		print OUT "\n";
	    }    
	    Dump_trial_data($rh_ref->{'results'}{'Fsd_params'}{'scores'}{'trial_data'}, *OUT, "        ");
	}
	
	$rh_b = \%{ $rh_ref->{'results'}{'Fsd_params'}{'hdoc'} };
	print OUT "      Hyp Doc\n";
	### Write the key file
	foreach (sort(keys %$rh_b)){	
	    print OUT "        docno=$_ -> ".join(" ",@{ $rh_b->{$_}})."\n";
        }    
						  
	my($ra_a) = \@{ $rh_ref->{'results'}{'Fsd_params'}{'eval'} };
	print OUT "      Document Decision List ".$#$ra_a." document\n";
	for ($i=0; $i <= $#$ra_a; $i++){
	    print OUT "        ";
	    $k="docno";   print OUT " [$k=>".$ra_a->[$i]{$k};
	    ### Lookup additional info
	    my($lutf) = $rh_ref->{'docno2fileid'}{$ra_a->[$i]{$k}} ;
	    my($lutb) = $rh_ref->{'bsets'}{$lutf}{'doc_index'}{$ra_a->[$i]{$k}};
	    print OUT " Brecid=".$rh_ref->{'bsets'}{$lutf}{'boundary'}[$lutb]{'Brecid'} ;
	    print OUT " Erecid=".$rh_ref->{'bsets'}{$lutf}{'boundary'}[$lutb]{'Erecid'} ;
	    print OUT "]";
	    ### 
	    foreach $k(sort(keys %{ $ra_a->[$i] } )){
		print OUT " $k=> '".$ra_a->[$i]{$k}."'" if ($k ne "docno");
	    }
	    print OUT "\n";
	}
    }
    if (defined($rh_ref->{'results'}{'Trk_params'})){
	my($i, $j, $k);
	print OUT "    Tracking Params:\n";
	foreach $k(sort(keys %{ $rh_ref->{'results'}{'Trk_params'} } )){
	    print OUT "      $k => '".$rh_ref->{'results'}{'Trk_params'}{$k}."'\n"
		if ($k !~ /eval|stats/);
	}
	print OUT "      Performance statistics:\n";
	foreach $k(sort(keys %{ $rh_ref->{'results'}{'Trk_params'}{'stats'} })){
	    print OUT "          $k -> ".$rh_ref->{'results'}{'Trk_params'}{'stats'}{$k}."\n";
	}
	print OUT "      Document Decision List by Topic\n";
	for ($i=0; $i<=$#{ $rh_ref->{'results'}{'Trk_params'}{'eval'} }; $i++){
	    my($rh_e) = \%{ $rh_ref->{'results'}{'Trk_params'}{'eval'}[$i] };
	    print OUT "      Topic $i:\n";
	    print OUT "         ";

	    foreach $k(keys %$rh_e){ print OUT " $k=> $rh_e->{$k}" if ($k !~ /scores_ind|scores/)} 
	    print OUT "\n";
	    print OUT "          Docno scoring:\n";
	    for ($j=0; $j<= $#{ $rh_e->{'scores'} }; $j++){
		my %xx = split(/\0/,$rh_e->{'scores'}[$j]);
		print OUT "           ";

		$k="docno";   print OUT " [$k=>".$xx{$k};
		$k="sid";     print OUT " $k=>".$xx{$k};
		$k="eid";     print OUT " $k=>".$xx{$k};
		$k="TargTopic";  print OUT " $k=>".$rh_e->{$k};
		print OUT "]";

		foreach $k(keys %xx){
		    print OUT " $k=> $xx{$k}" if ($k !~ /(docno|sid|eid)/); 
		}
		print OUT "\n";
	    }
	}
    }
    close OUT;
}

#### Pretty prints a 2 dimensional array    
sub tabby{
    my($OUT, $ra_tab, $Justification,$ics,$offset) = @_;
    my($x,$y);
    my(@Maxs) = ();
    my(@fmt) = ();
    my($icsfmt);

    ### Measure the columns
    for ($x=0; $x<= $#{ $ra_tab->[0] }; $x++){ $Maxs[$x] = 0; }
    for ($y=0; $y<= $#$ra_tab; $y++){
	for ($x=0; $x<= $#{ $ra_tab->[$y] }; $x++){
	    $Maxs[$x] = length($ra_tab->[$y][$x])
		if ($Maxs[$x] < length($ra_tab->[$y][$x]));
	}
    }
    ### Make formats 
    for ($x=0; $x <= $#Maxs; $x++){
	if ($Justification =~ /r/){
	    $fmt[$x] = "%$Maxs[$x]s";
	} else {
	    $fmt[$x] = "%-$Maxs[$x]s";
	}
    }
    $icsfmt = "%".$ics."s";
    ### Write the table
    for ($y=0; $y<= $#$ra_tab; $y++){
	print OUT $offset;
	for ($x=0; $x<= $#{ $ra_tab->[$y] }; $x++){
	    printf OUT $fmt[$x],$ra_tab->[$y][$x];
            if ($x <= ($#Maxs - 1)){
                printf OUT $icsfmt,"";
            }
	}
	print OUT "\n";
    }
				       
}

sub Read_file_into_array{
    my($file) = @_;
    my(@a) = ();

    die("Unable to stat '$file'")if (! -f $file);

    ### open the data Stream
    open(F,$file) || die("Unable to open file '$file'");
    
    while (<F>){chop; push(@a,$_); }
    close(F);
    @a;
}


sub MAX{
    my(@a) = @_;
    my($max) = -99e9;

    while ($#a >= 0){
	$max = $a[0] if ($max < $a[0]);
	splice(@a,0,1);
    }
    $max;
}

sub MIN{
    my(@a) = @_;
    my($min) = 99e9;

    while ($#a >= 0){
	# print "  $a[0]\n";
	$min = $a[0] if ($min > $a[0]);
	splice(@a,0,1);
    }
    $min;
}

sub MEAN{
    my($sum) = 0;
    foreach (@_){ $sum += $_; }
    $sum / ($#_ + 1);
}

sub SUM{
    my($sum) = 0;
    foreach (@_){ $sum += $_; }
    $sum;
}

sub dump_boundary{
    my($rh_b) = @_;
    my($key, $n);

    print "Boundary: ";
    foreach $key(keys %$rh_b){
	print "$key=$rh_b->{$key} " if ($key !~ /t_level|topicid/) ;
    }
    print "Topic/level=>";
    for ($n=0; $n<= $#{ $rh_b->{'topicid'} }; $n++){
	print " ".$rh_b->{'topicid'}[$n]."/".$rh_b->{'t_level'}[$n];
    }
    print "\n";
}

## returns any array after a sort uniq
sub sortuniq{
    my(%h);
    my($x);
    foreach $x(@_){ $h{$x} = 1; }
    sort(keys %h);
}

sub Load_SSDFile{
    my ($ssdfile, $justone) = @_;
    my($nset) = 1;
    my(%smth, $setid);
    my(%th);
    my(%subsetmap) = ();
    
    print "Loading Subset definition file '$ssdfile'\n" if ($main::Vb > 0);
    open(SS,$ssdfile) || die "Error: Unable to open subset file '$ssdfile'\n";
    while (<SS>){
	if ($_ =~ /<source_subset/i){
	    ; 
	} elsif ($_ =~ /<set/i){
	    ##Force only the first set to be read in and used
	    last if ($justone == 1 && $nset > 1);

	    my $smth = ();
	    ### Divide smthe line
	    s/<\S+\s+(.*)>\s*$/$1/;
	    while(s/("[^=]+)\s([^=]+")/$1\\_$2/g){;}
	    %smth = split(/[\"=\s]+/);  ## "
	    
	    ($th{"title"} = $smth{'title'}) =~ s/\\_/ /g;
	    ($th{"heading"} = $smth{'heading'}) =~ s/\\_/ /g;
	    $th{"source"} = ();
	    $setid = sprintf("set%d",$nset++);
	} elsif ($_ =~ /<\/set/i){
	    $subsetmap{$setid} = { %th };
	} elsif ($_ =~ /<source_file/i){	
	    ### Divide the line
	    s/<\S+\s+(.*)>\s*$/$1/;
	    while(s/("[^=]+)\s([^=]+")/$1\\_$2/g){;}
	    %smth = split(/[\"=\s]+/);  ### "
	    $smth{'filename'} =~ s/\\_/ /g;
	    $th{"source"}{$smth{'filename'}} = 1;
	}
    }
    close(SS);
    \%subsetmap;
}


############   DETWARE PROGRAMS   ##############

sub numerically {$a <=> $b; }

sub write_gnuplot_DET_header{
    my($FP, $title, $x_min, $x_max, $y_min, $y_max) = @_;

    my($p_x_min, $p_x_max) = ( ppndf($x_min/100), ppndf($x_max/100) );
    my($p_y_min, $p_y_max) = ( ppndf($y_min/100), ppndf($y_max/100) );
    
    my($i, $prev);
    
    print $FP "## GNUPLOT command file\n";
    print $FP "set terminal postscript color\n";
    print $FP "set data style lines\n";
    print $FP "set noxzeroaxis\n";
    print $FP "set noyzeroaxis\n";
    print $FP "set key 1,1\n";
#    print $FP "set size $aratio_x, $aratio_y\n";
    print $FP "set noxtics\n"; 
    print $FP "set noytics\n";
    print $FP "set title '$title'\n";
    print $FP "set ylabel 'Miss probability (in %)'\n";
    print $FP "set xlabel 'False Alarms probability (in %)'\n";
    print $FP "set grid\n";
    print $FP "set pointsize 3\n";
    
### Write the tic marks
    &write_tics($FP, 'ytics', $y_min, $y_max);
    &write_tics($FP, 'xtics', $x_min, $x_max);

    print $FP "plot [${p_x_min}:${p_x_max}] [${p_y_min}:${p_y_max}] \\\n";
    print $FP "   -x title 'Random Performance' with lines 1";

}

sub write_gnuplot_DET_threshhold_header{
    my($FP, $title, $y_min, $y_max) = @_;

    my($p_y_min, $p_y_max) = ( ppndf($y_min/100), ppndf($y_max/100) );
    
    my($i, $prev);
    
    print $FP "## GNUPLOT command file\n";
    print $FP "set terminal postscript color\n";
    print $FP "set data style lines\n";
    print $FP "set noyzeroaxis\n";
    print $FP "set noytics\n";
    print $FP "set title '$title'\n";
    print $FP "set ylabel 'Probability (in %)'\n";
    print $FP "set xlabel 'System Assigned Score'\n";
    print $FP "set grid\n";
    print $FP "set pointsize 3\n";
    
### Write the tic marks
    &write_tics($FP, 'ytics', $y_min, $y_max);

    print $FP "plot [] [${p_y_min}:${p_y_max}] ";
}

sub write_tics{ 
    my($FP, $axis, $min, $max) = @_;
    my($lab, $i, $prev);

    my(@tics) = (.01, 0.02, 0.05, 0.1, 0.2, 0.5,
		    1, 2, 5, 10, 20, 40, 60, 80, 90);

    print $FP "set $axis (";
    for ($i=0, $prev=0; $i<= $#tics; $i++){
	if ($tics[$i] >= $min && $tics[$i] <= $max){
	    print $FP ", " if ($prev > 0);
	    print $FP "\\\n    " if (($prev % 5) == 0);
	    if ($tics[$i] >= 1) {
		$lab = sprintf("%d", $tics[$i]);
	    } elsif ($tics[$i] >= 0.1) {
		($lab = sprintf("%.1f", $tics[$i])) =~ s/^0//;
	    } else {
		($lab = sprintf("%.2f", $tics[$i])) =~ s/^0//;
	    }

	    printf $FP "'$lab' %.4f",ppndf($tics[$i]/100);
	    $prev ++;
	}
    }
    print $FP ")\n";
}

sub Produce_multi_trial_DET{
    my($ra_trial_data_list, $DETFile, $Title, $Pooled, $TrialWeighted, $CF_Ptarg, $CF_Cmiss, $CF_Cfa) = @_;

    my($func) = "Produce_multi_trial_DET";
    my($trialid, $arrayid);
    my($df) = 0;    
    my($prob_scale) = 1;
    my($tlid);
    
    print "Writing DET plot to '${DETFile}.*'\n" if ($main::Vb > 0);

    ### Start the GNU plot file
    open(PLT,"> ${DETFile}.plt") ||
	die("unable to open DET gnuplot file ${DETFile}.plt");
    &write_gnuplot_DET_header(*PLT, $Title, 0.01, 90, 1, 90);

    if ($Pooled || $TrialWeighted){
	### Loop through trail_data_list
	for ($tlid=0; $tlid<= $#$ra_trial_data_list; $tlid++){
	    my(%trial_stat) = ();
	    my($rh_trial_data) = $ra_trial_data_list->[$tlid];
	    my(@a, $i);
	    my(@lev1);
	    my $Score_Pmiss_Pmax;
	    my $Score_Pmiss_Pmin;
	    
	    ### Sorting the TARG and NOTTARG arrays!!!
	    print "    Sorting trial-based information\n" if ($main::Vb > 2);
	    foreach $trialid(keys %{ $rh_trial_data->{'trials'} }) {
		foreach $arrayid('TARG', 'NONTARG') {
		    @{ $rh_trial_data->{'trials'}{$trialid}{$arrayid} } = 
			sort numerically @{ $rh_trial_data->{'trials'}{$trialid}{$arrayid} };
		}
	    }

	    if ($TrialWeighted){
		my($nt, $ti) = (0, 0);
		foreach $ti(keys %{ $rh_trial_data->{'trials'} }) {  $nt++; }
		if ($nt <= 1) {
		    print STDERR "Warning: Topic Weighted Plot aborted, not enough topics\n";
		    $TrialWeighted = 0;
		}
	    }

	    print "    Producing pooled/trial weighted information for trial_data $tlid\n" if ($main::Vb > 2);
	    ### Write the plots!!!	    
	    if ($Pooled){
		print PLT ",\\\n";
		print PLT "    '${DETFile}.DET.$df' using 2:1 title '".
		    $rh_trial_data->{'pooledtitle'}."' with lines";
		open(POOLED,">${DETFile}.DET.$df") || die "Can not open ${DETFile}.DET.$df";
		$df++;
	    }
	    if ($TrialWeighted){
		print PLT ",\\\n";
		print PLT "    '${DETFile}.DET.$df' using 2:1 title '".
		    $rh_trial_data->{'trialweightedtitle'}."' with lines";
		open(TRIALW,">${DETFile}.DET.$df") || die "Can not open ${DETFile}.DET.$df";
		$df++;
	    }
	    
	    ### build the trial stat structure
	    foreach $arrayid('TARG', 'NONTARG') {
		foreach $trialid(keys %{ $rh_trial_data->{'trials'} }) {		
		    $trial_stat{$trialid}{'ntrue'} = 0; 
		    $trial_stat{$trialid}{'nfalse'} = 0; 	
		    $trial_stat{$trialid}{"#".$arrayid} = $#{ $rh_trial_data->{'trials'}{$trialid}{$arrayid} } + 1; 
		    $trial_stat{$trialid}{'Pmiss'} = 0;
		    $trial_stat{$trialid}{'Pfa'} = 0;
		}
	    }
	    
	    ### open output files, and update plot files
	    ### Ok the merge is done!  
	    if ($Pooled || $TrialWeighted){
		my($ntrue, $nfalse) = (0, 0);
		my($Pmiss, $Pfa, $TW_Pmiss, $TW_Pfa, $TW_Pmiss_std, $TW_Pfa_std);
		my($TW_Pmiss_stderr, $TW_Pfa_stderr);
		my($TW_Pmiss_var, $TW_Pfa_var);
		my($thresh);
		####
		my @temp_arr;
		my($cur_trial) = "";
		my($incr_targ) = 0;;
		####
		
		#### Prime the pump
		my @trialids = keys %{ $rh_trial_data->{'trials'} };
		my ($min_targ_score, $min_targ_trial) = (99999999, "");
		my ($min_nontarg_score, $min_nontarg_trial) = (99999999, "");
		my ($num_targ, $num_nontarg) = (0, 0);
		foreach $trialid(@trialids) { 
		    if (($#{ $rh_trial_data->{'trials'}{$trialid}{'TARG'} } >= 0) &&
			$min_targ_score > $rh_trial_data->{'trials'}{$trialid}{'TARG'}[0]){
			$min_targ_score = $rh_trial_data->{'trials'}{$trialid}{'TARG'}[0];
			$min_targ_trial = $trialid;
		    }
		    $num_targ += $#{ $rh_trial_data->{'trials'}{$trialid}{'TARG'} } + 1;
		    if (($#{ $rh_trial_data->{'trials'}{$trialid}{'NONTARG'} } >= 0) &&
			$min_nontarg_score > $rh_trial_data->{'trials'}{$trialid}{'NONTARG'}[0]){
			$min_nontarg_score = $rh_trial_data->{'trials'}{$trialid}{'NONTARG'}[0];
			$min_nontarg_trial = $trialid;
		    }
		    $num_nontarg += $#{ $rh_trial_data->{'trials'}{$trialid}{'NONTARG'} } + 1;
		}
		do {		
		    if ($min_targ_trial ne "" && $min_targ_score <= $min_nontarg_score){
			$trial_stat{ $min_targ_trial}{'ntrue'} ++;
			$thresh    = $min_targ_score;
			$cur_trial = $min_targ_trial;
			$ntrue++;
			$incr_targ = 1;
			shift @{ $rh_trial_data->{'trials'}{$min_targ_trial}{'TARG'} };
			### Find the next data point ONLY for the targets!!!!
			($min_targ_score, $min_targ_trial) = (99999999, "");
			foreach $trialid(@trialids) { 
			    if (($#{ $rh_trial_data->{'trials'}{$trialid}{'TARG'} } >= 0) &&
				$min_targ_score > $rh_trial_data->{'trials'}{$trialid}{'TARG'}[0]){
				$min_targ_score = $rh_trial_data->{'trials'}{$trialid}{'TARG'}[0];
				$min_targ_trial = $trialid;
			    }
			}
		    } else {
			$trial_stat{ $min_nontarg_trial}{'nfalse'} ++;
			$thresh    = $min_nontarg_score;
			$cur_trial = $min_nontarg_trial;
			$nfalse++;
			$incr_targ = 0;
			shift @{ $rh_trial_data->{'trials'}{$min_nontarg_trial}{'NONTARG'} };
			### Find the next data point ONLY for the NONtargets!!!!
			($min_nontarg_score, $min_nontarg_trial) = (99999999, "");
			foreach $trialid(@trialids) { 
			    if (($#{ $rh_trial_data->{'trials'}{$trialid}{'NONTARG'} } >= 0) &&
				$min_nontarg_score > $rh_trial_data->{'trials'}{$trialid}{'NONTARG'}[0]){
				$min_nontarg_score = $rh_trial_data->{'trials'}{$trialid}{'NONTARG'}[0];
				$min_nontarg_trial = $trialid;
			    }
			}
			
			$incr_targ = 1
			    if ($min_nontarg_trial ne "" && $min_targ_score <= $min_nontarg_score);
		    }
		    if ($incr_targ == 1) { 
			$Pmiss = ($num_targ > 0) ? $ntrue / ($num_targ) : 0;
			$Pfa = ($num_nontarg > 0) ? (($num_nontarg - $nfalse) / $num_nontarg) : 0;
			if ($Pooled) { 
			    if ($prob_scale) {
				print POOLED ppndf($Pmiss)," ",ppndf($Pfa),"\n";
			    } else {
				print POOLED "$Pmiss $Pfa\n";
			    }
			}
		    }
		    if ($TrialWeighted && $incr_targ == 1) { 
			### Calculate Pmiss
			@temp_arr = ();
			foreach $trialid(@trialids) { 
			    push(@temp_arr, $trial_stat{$trialid}{'ntrue'} / $trial_stat{$trialid}{'#TARG'})
				if ($trial_stat{$trialid}{'#TARG'} > 0);
			}
			($TW_Pmiss, $TW_Pmiss_var, $TW_Pmiss_std, $TW_Pmiss_stderr) = sumstat(@temp_arr);
			### Calcualate Pfa
			@temp_arr = ();
			foreach $trialid(@trialids) { 
			    push(@temp_arr, (($trial_stat{$trialid}{'#NONTARG'}-$trial_stat{$trialid}{'nfalse'}) /
					     $trial_stat{$trialid}{'#NONTARG'}))
				if ($trial_stat{$trialid}{'#NONTARG'} > 0);
			}
			($TW_Pfa, $TW_Pfa_var, $TW_Pfa_std, $TW_Pfa_stderr) = sumstat(@temp_arr);
			
			if ($prob_scale) {
			    print TRIALW (ppndf($TW_Pmiss)," ",
					  ppndf($TW_Pfa), " ",
					  ppndf($TW_Pmiss+(1.28*$TW_Pmiss_stderr))," ",
					  ppndf($TW_Pmiss-(1.28*$TW_Pmiss_stderr))," ",
					  ppndf($TW_Pfa+(1.28*$TW_Pfa_stderr))," ",
					  ppndf($TW_Pfa-(1.28*$TW_Pfa_stderr))," ",
					  $thresh," ",
					  #ppndf($Pmiss)," ",
					  #ppndf($Pfa)," ",
					  #ppndf(detect_CF($TW_Pmiss,$TW_Pfa,$CF_Ptarg,$CF_Cmiss,$CF_Cfa))," ",
					  #ppndf(detect_CF($Pmiss,$Pfa,$CF_Ptarg,$CF_Cmiss,$CF_Cfa))," ",
					  "\n");
			} else {
			    print TRIALW ($TW_Pmiss," ",
					  $TW_Pfa, " ",
					  $TW_Pmiss+(1.28*$TW_Pmiss_stderr)," ",
					  $TW_Pmiss-(1.28*$TW_Pmiss_stderr)," ",
					  $TW_Pfa+(1.28*$TW_Pfa_stderr)," ",
					  $TW_Pfa-(1.28*$TW_Pfa_stderr)," ",
					  $thresh, " ",
					  #$Pmiss," ",
					  #$Pfa," ",
					  #detect_CF($TW_Pmiss,$TW_Pfa,$CF_Ptarg,$CF_Cmiss,$CF_Cfa)," ",
					  #detect_CF($Pmiss,$Pfa,$CF_Ptarg,$CF_Cmiss,$CF_Cfa)," ",
					  "\n");
			}
		    }
		} while ($min_nontarg_trial ne "" && $min_targ_trial ne "");
		
		### close the data files!!!	    
		close POOLED if ($Pooled);
		close TRIALW if ($TrialWeighted);
	    }
	}
    }
    print PLT "\n";
    close(PLT);
}

sub Produce_Minimum_DET_v2{
    my($rh_trial_data, $DETFile, $Title, $CF_Ptopic, $CF_Cmiss, $CF_Cfa) = @_;
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
    ($d_line, $d_f, $d_col) =
	GetLine($DETFile.".plt", "'([^']+)'\\s+using\\s+(\\S+)\\s+title\\s+'Topic Weighted Curve");
    ($p_line, $p_f, $p_col, $p_cost) =
	GetLine($DETFile.".plt", "'([^']+)'\\s+using\\s+(\\S+)\\s+title\\s+'TW Min DET Norm.Cost. = ([^']+)'");
    print NPLT ",\\\n   '$p_f' using $p_col title 'TW Min Norm(Cost) $p_cost' with linespoints $color";
    print NPLT ",\\\n   '$d_f' using $d_col notitle with lines $color";
    $color++;
    
    foreach $MinStyle("oraclecost"){
	my(%trial_data) = copy_trial_data($rh_trial_data);
	#Dump_trial_data($rh_trial_data, *STDOUT, "");
	
	Rescale_Trial_data(\%trial_data, $MinStyle, $CF_Ptopic, $CF_Cmiss, $CF_Cfa);

	Produce_trial_ensemble_DET(\%trial_data, $DETFile."_$MinStyle", $Title,
				   0, 0, 1, 0,
				   $CF_Ptopic, $CF_Cmiss, $CF_Cfa,
				   \$TW_mDET_Pmiss, \$TW_mDET_Pfa, \$TW_mDET_Ctrack, \$TW_mDET_normCtrack,
				   \$SW_mDET_Pmiss, \$SW_mDET_Pfa, \$SW_mDET_Ctrack, \$SW_mDET_normCtrack );
	($d_line, $d_f, $d_col) =
	    GetLine($DETFile."_$MinStyle.plt",
		    "'([^']+)'\\s+using\\s+(\\S+)\\s+title\\s+'Topic Weighted Curve'");
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


#### This routine modifies the scores in a trial_data data 
#### structure such that the computable minimum DET cost
#### is guarenteed to be at the theroretical minimum.  
####
#### One caveat: this optimization is based on the defined Blocks,
#### there may be a better optimization if a finer grained 
#### trial definition is used, for instance, English vs NonEnglish
#### scores may need to be scaled so that they are compatable.
####
sub Rescale_Trial_data(){
    my ($rh_trial_data, $style, $CF_Ptarg, $CF_Cmiss, $CF_Cfa) = @_;
    my ($i, $trialid, $arrayid, $eqErrCost);
    
    print "Rescaling scores by blocking ".$rh_trial_data->{"BlockID"}." using the '$style' technique\n"
	if ($main::Vb > 0);

    foreach $trialid(keys %{ $rh_trial_data->{'trials'} }) {
	if (0){
	    print " Trial $trialid\n";
	    print "   #TARG = ".scalar(@{ $rh_trial_data->{'trials'}{$trialid}{'TARG'} }).
		" #NONTARG = ".scalar(@{ $rh_trial_data->{'trials'}{$trialid}{'NONTARG'} })."\n";
	}

	my ($mean, $var, $std_dev, $qtr1, $qtr2, $qtr3, $numpts) =
	    sumstat_expensive(@{ $rh_trial_data->{'trials'}{$trialid}{'TARG'} },
			      @{ $rh_trial_data->{'trials'}{$trialid}{'NONTARG'} });

	if ($style eq "mean"){
	    ### Let's just scale everything now to test it!!!!
	    foreach $arrayid('TARG', 'NONTARG') {
		for ($i=0; $i<@{ $rh_trial_data->{'trials'}{$trialid}{$arrayid} }; $i++){
		    $rh_trial_data->{'trials'}{$trialid}{$arrayid}[$i] = 
			($rh_trial_data->{'trials'}{$trialid}{$arrayid}[$i] - $mean);
		}
	    } 
	} elsif ($style eq "mean+shape"){
	    foreach $arrayid('TARG', 'NONTARG') {
		for ($i=0; $i<@{ $rh_trial_data->{'trials'}{$trialid}{$arrayid} }; $i++){
		    $rh_trial_data->{'trials'}{$trialid}{$arrayid}[$i] = 
			($rh_trial_data->{'trials'}{$trialid}{$arrayid}[$i] - $mean) / $std_dev;
		}
	    }
	} elsif (($style eq "mean+shape+oraclecost") ||
		 ($style eq "oraclecost")){ 
	    ### Calc the equal error point
	    my($eqMinCost, $norm_MinCostScore) = (0.0, 0.0);
	    if (scalar(@{ $rh_trial_data->{'trials'}{$trialid}{'TARG'} }) > 0){
		$eqMinCost = Compute_DET_eqMinCost(0,
						   $rh_trial_data->{'trials'}{$trialid}{'TARG'} ,
						   $rh_trial_data->{'trials'}{$trialid}{'NONTARG'},
						   $CF_Ptarg, $CF_Cmiss, $CF_Cfa);
	    } else {
		$eqMinCost = (MAX(@{ $rh_trial_data->{'trials'}{$trialid}{'NONTARG'} }) + $qtr3)/2;
	    }
	    ##print "    EqMinCost $eqMinCost\n";
	    if ($style eq "mean+shape+oraclecost"){
		$norm_MinCostScore = ($eqMinCost - $mean) / $std_dev;
		foreach $arrayid('TARG', 'NONTARG') {
		    for ($i=0; $i<@{ $rh_trial_data->{'trials'}{$trialid}{$arrayid} }; $i++){
			$rh_trial_data->{'trials'}{$trialid}{$arrayid}[$i] = 
			    (($rh_trial_data->{'trials'}{$trialid}{$arrayid}[$i] - $mean) / $std_dev) - 
				$norm_MinCostScore;
		    }
		} 
	    } elsif ($style eq "oraclecost"){
		foreach $arrayid('TARG', 'NONTARG') {
		    for ($i=0; $i<@{ $rh_trial_data->{'trials'}{$trialid}{$arrayid} }; $i++){
			$rh_trial_data->{'trials'}{$trialid}{$arrayid}[$i] = 
			    $rh_trial_data->{'trials'}{$trialid}{$arrayid}[$i] - $eqMinCost;
		    }
		} 
	    } else {
		die "Internal Error";
	    }
	} elsif ($style eq "mean+shape+oracleEER"){ 
	    ### Calc the equal error point
	    my($eqErrScore, $norm_EERScore) = (0.0, 0.0);
	    if (scalar(@{ $rh_trial_data->{'trials'}{$trialid}{'TARG'} }) > 0){
		$eqErrScore = Compute_DET_eqMinCost(0,
						    $rh_trial_data->{'trials'}{$trialid}{'TARG'} ,
						    $rh_trial_data->{'trials'}{$trialid}{'NONTARG'},
						    0.5, 1.0, 1.0);
	    } else {
		$eqErrScore = MAX(@{ $rh_trial_data->{'trials'}{$trialid}{'NONTARG'} });
	    }
	    ##print "    EqErrScore $eqErrScore\n";
	    $norm_EERScore = ($eqErrScore - $mean) / $std_dev;
	    foreach $arrayid('TARG', 'NONTARG') {
		for ($i=0; $i<@{ $rh_trial_data->{'trials'}{$trialid}{$arrayid} }; $i++){
		    $rh_trial_data->{'trials'}{$trialid}{$arrayid}[$i] = 
			(($rh_trial_data->{'trials'}{$trialid}{$arrayid}[$i] - $mean) / $std_dev) -
			    $norm_EERScore;
		}
	    } 
	} else {
	    die "Error: undefined style of score normalization '$style'";
	}
##	print "    Stats ".join(" ",
##				sumstat_expensive(@{ $rh_trial_data->{'trials'}{$trialid}{'TARG'} },
##						  @{ $rh_trial_data->{'trials'}{$trialid}{'NONTARG'} })). "\n";
    }
}

sub Produce_trial_ensemble_DET{
    my($rh_orig_trial_data, $DETFile, $Title, $PerTrial, $Pooled, $TrialWeighted,  $TrialWeighted_90conf, $CF_Ptarg, $CF_Cmiss, $CF_Cfa, $r_TW_min_DET_Pmiss, $r_TW_min_DET_Pfa, $r_TW_min_DET_Cost, $r_TW_min_DET_normCost, $r_SW_min_DET_Pmiss, $r_SW_min_DET_Pfa, $r_SW_min_DET_Cost, $r_SW_min_DET_normCost) = @_;
    my($func) = "Produce_trial_ensemble_DET";
    my($trialid, $arrayid);
    my($df) = 0;    
    my($prob_scale) = 1;
    my($SW_min_DET_thresh, $TW_min_DET_thresh) = ("NULL", "NULL");

    ###  This is a DESTRUCTIVE Routine on the trial data structure, make a copy save the original
    my(%td) = copy_trial_data($rh_orig_trial_data);
    my ($rh_trial_data) = \%td;

    print "Writing DET plot to '${DETFile}.*'\n" if ($main::Vb > 0);

    ### Start the GNU plot file
    open(PLT,"> ${DETFile}.plt") ||
	die("unable to open DET gnuplot file ${DETFile}.plt");
    &write_gnuplot_DET_header(*PLT, $Title, 0.01, 90, 1, 90);

    ### Sorting the TARG and NOTTARG arrays!!!
    print "    Sorting trial-based information\n" if ($main::Vb > 2);
    foreach $trialid(keys %{ $rh_trial_data->{'trials'} }) {
    	foreach $arrayid('TARG', 'NONTARG') {
	    @{ $rh_trial_data->{'trials'}{$trialid}{$arrayid} } = 
		sort numerically @{ $rh_trial_data->{'trials'}{$trialid}{$arrayid} };
	    # Dump_1dimarr("${DETFile}.trial=${trialid}.${arrayid}", 0, 
	    #		 $rh_trial_data->{'trials'}{$trialid}{$arrayid})
	}
	
	if ($PerTrial){
	    my(@pts) = Compute_DET_points(1,
					  $rh_trial_data->{'trials'}{$trialid}{'TARG'} ,
					  $rh_trial_data->{'trials'}{$trialid}{'NONTARG'} );
	    Dump_2dimarr("${DETFile}.DET.$df", $prob_scale, \@pts);
            print PLT ",\\\n";
	    print PLT "    '${DETFile}.DET.$df' using 2:1 title ".
		"'".$rh_trial_data->{'trials'}{$trialid}{'title'}."'";
	    $df++;
	}
    }

    if ($TrialWeighted){
	my($nt, $ti) = (0, 0);
	foreach $ti(keys %{ $rh_trial_data->{'trials'} }) {  $nt++; }
	if ($nt <= 1) {
	    print STDERR "Warning: Topic Weighted Plot aborted, not enough topics\n";
	    $TrialWeighted = 0;
	}
    }
    
    if ($Pooled || $TrialWeighted){
	my(@a, $i);
	my(@lev1);
	my(%trial_stat) = ();
	my $Score_Pmiss_Pmax;
	my $Score_Pmiss_Pmin;
	my $tw_data_file = "";
	
	print "    Producing pooled/trial weighted information\n" if ($main::Vb > 2);
	### Write the plots!!!	    
	if ($Pooled){
	    print PLT ",\\\n";
	    print PLT "    '${DETFile}.DET.$df' using 2:1 title '".
		$rh_trial_data->{'pooledtitle'}."' with lines 2";
	    open(POOLED,">${DETFile}.DET.$df") || die "Can not open ${DETFile}.DET.$df";
	    $df++;
	}
	if ($TrialWeighted){
	    $tw_data_file = "${DETFile}.DET.$df";
	    print PLT ",\\\n";
	    print PLT "    '$tw_data_file' using 2:1 title '".
		$rh_trial_data->{'trialweightedtitle'}."' with lines 3";
	    if ($TrialWeighted_90conf){
		print PLT ",\\\n";
		print PLT "    '$tw_data_file' using 5:3 title '".
		    "90% Conf. ".$rh_trial_data->{'trialweightedtitle'}."' with lines 4,\\\n";
		print PLT "    '$tw_data_file' using 6:4 notitle with lines 4";
	    }
	    open(TRIALW,">$tw_data_file") || die "Can not open $tw_data_file";
	    $df++;
	}

	### build the trial stat structure
	foreach $arrayid('TARG', 'NONTARG') {
	    foreach $trialid(keys %{ $rh_trial_data->{'trials'} }) {		
		$trial_stat{$trialid}{'ntrue'} = 0; 
		$trial_stat{$trialid}{'nfalse'} = 0; 	
		$trial_stat{$trialid}{"#".$arrayid} = $#{ $rh_trial_data->{'trials'}{$trialid}{$arrayid} } + 1; 
		$trial_stat{$trialid}{'Pmiss'} = 0;
		$trial_stat{$trialid}{'Pfa'} = 0;
	    }
	}

	### open output files, and update plot files
        ### Ok the merge is done!  
	if ($Pooled || $TrialWeighted){
	    my($ntrue, $nfalse) = (0, 0);
	    my($Pmiss, $Pfa, $TW_Pmiss, $TW_Pfa, $TW_Pmiss_std, $TW_Pfa_std);
	    my($TW_Cost, $TW_Cost_var, $TW_Cost_std, $TW_Cost_stderr);
	    my($TW_Pmiss_stderr, $TW_Pfa_stderr);
	    my($TW_Pmiss_var, $TW_Pfa_var);
	    my($thresh);
	    ####
	    my @temp_arr;
	    my($cur_trial) = "";
	    my($incr_targ) = 0;;
	    ####

	    $$r_SW_min_DET_Cost = 999999999999 if ($Pooled || $TrialWeighted);
	    $$r_TW_min_DET_Cost = 999999999999 if ($TrialWeighted);

	    #### Prime the pump
	    my @trialids = keys %{ $rh_trial_data->{'trials'} };
	    my ($min_targ_score, $min_targ_trial) = (99999999, "");
	    my ($min_nontarg_score, $min_nontarg_trial) = (99999999, "");
	    my ($num_targ, $num_nontarg) = (0, 0);
	    foreach $trialid(@trialids) { 
		if (($#{ $rh_trial_data->{'trials'}{$trialid}{'TARG'} } >= 0) &&
		    $min_targ_score > $rh_trial_data->{'trials'}{$trialid}{'TARG'}[0]){
		    $min_targ_score = $rh_trial_data->{'trials'}{$trialid}{'TARG'}[0];
		    $min_targ_trial = $trialid;
		}
		$num_targ += $#{ $rh_trial_data->{'trials'}{$trialid}{'TARG'} } + 1;
		if (($#{ $rh_trial_data->{'trials'}{$trialid}{'NONTARG'} } >= 0) &&
		    $min_nontarg_score > $rh_trial_data->{'trials'}{$trialid}{'NONTARG'}[0]){
		    $min_nontarg_score = $rh_trial_data->{'trials'}{$trialid}{'NONTARG'}[0];
		    $min_nontarg_trial = $trialid;
		}
		$num_nontarg += $#{ $rh_trial_data->{'trials'}{$trialid}{'NONTARG'} } + 1;
	    }
	    do {		
 		if ($min_targ_trial ne "" && $min_targ_score <= $min_nontarg_score){
		    $trial_stat{ $min_targ_trial}{'ntrue'} ++;
		    $thresh    = $min_targ_score;
		    $cur_trial = $min_targ_trial;
		    $ntrue++;
		    $incr_targ = 1;
		    shift @{ $rh_trial_data->{'trials'}{$min_targ_trial}{'TARG'} };
		    ### Find the next data point ONLY for the targets!!!!
		    ($min_targ_score, $min_targ_trial) = (99999999, "");
		    foreach $trialid(@trialids) { 
			if (($#{ $rh_trial_data->{'trials'}{$trialid}{'TARG'} } >= 0) &&
			    $min_targ_score > $rh_trial_data->{'trials'}{$trialid}{'TARG'}[0]){
			    $min_targ_score = $rh_trial_data->{'trials'}{$trialid}{'TARG'}[0];
			    $min_targ_trial = $trialid;
			}
		    }
		} else {
		    $trial_stat{ $min_nontarg_trial}{'nfalse'} ++;
		    $thresh    = $min_nontarg_score;
		    $cur_trial = $min_nontarg_trial;
		    $nfalse++;
		    $incr_targ = 0;
		    shift @{ $rh_trial_data->{'trials'}{$min_nontarg_trial}{'NONTARG'} };
		    ### Find the next data point ONLY for the NONtargets!!!!
		    ($min_nontarg_score, $min_nontarg_trial) = (99999999, "");
		    foreach $trialid(@trialids) { 
			if (($#{ $rh_trial_data->{'trials'}{$trialid}{'NONTARG'} } >= 0) &&
			    $min_nontarg_score > $rh_trial_data->{'trials'}{$trialid}{'NONTARG'}[0]){
			    $min_nontarg_score = $rh_trial_data->{'trials'}{$trialid}{'NONTARG'}[0];
			    $min_nontarg_trial = $trialid;
			}
		    }

		    $incr_targ = 1
			if ($min_nontarg_trial ne "" && $min_targ_score <= $min_nontarg_score);
		}
### Change this to print a DET point for every decision.  It makes a big file!
#		$incr_targ = 1;

		if ($incr_targ == 1) { 
		    $Pmiss = ($num_targ > 0) ? $ntrue / ($num_targ) : 0;
		    $Pfa = ($num_nontarg > 0) ? (($num_nontarg - $nfalse) / $num_nontarg) : 0;
		    if ($$r_SW_min_DET_Cost > detect_CF($Pmiss,$Pfa,$CF_Ptarg,$CF_Cmiss,$CF_Cfa)){
			$$r_SW_min_DET_Pmiss = $Pmiss;
			$$r_SW_min_DET_Pfa   = $Pfa;
			$$r_SW_min_DET_Cost= detect_CF($Pmiss,$Pfa,$CF_Ptarg,$CF_Cmiss,$CF_Cfa);
			$$r_SW_min_DET_normCost= norm_detect_CF($Pmiss,$Pfa,$CF_Ptarg,$CF_Cmiss,$CF_Cfa);
			$SW_min_DET_thresh = $thresh;
		    }
		    if ($Pooled) { 
			if ($prob_scale) {
			    print POOLED ppndf($Pmiss)," ",ppndf($Pfa),"\n";
			} else {
			    print POOLED "$Pmiss $Pfa\n";
			}
		    }
		}
		if ($TrialWeighted && $incr_targ == 1) { 
		    ### Calculate Pmiss
		    @temp_arr = ();
		    foreach $trialid(@trialids) { 
			push(@temp_arr, $trial_stat{$trialid}{'ntrue'} / $trial_stat{$trialid}{'#TARG'})
			    if ($trial_stat{$trialid}{'#TARG'} > 0);
		    }
		    ($TW_Pmiss, $TW_Pmiss_var, $TW_Pmiss_std, $TW_Pmiss_stderr) = sumstat(@temp_arr);
		    ### Calcualate Pfa
		    @temp_arr = ();
		    foreach $trialid(@trialids) { 
			push(@temp_arr, (($trial_stat{$trialid}{'#NONTARG'}-$trial_stat{$trialid}{'nfalse'}) /
					$trial_stat{$trialid}{'#NONTARG'}))
			    if ($trial_stat{$trialid}{'#NONTARG'} > 0);
		    }
		    ($TW_Pfa, $TW_Pfa_var, $TW_Pfa_std, $TW_Pfa_stderr) = sumstat(@temp_arr);
		    ### Calcualate TWcost
		    @temp_arr = ();
		    foreach $trialid(@trialids) { 
			push(@temp_arr, detect_CF($trial_stat{$trialid}{'ntrue'} / $trial_stat{$trialid}{'#TARG'},
						  (($trial_stat{$trialid}{'#NONTARG'}-$trial_stat{$trialid}{'nfalse'}) /
						   $trial_stat{$trialid}{'#NONTARG'}),
						  $CF_Ptarg,$CF_Cmiss,$CF_Cfa))	   	    
			    if ($trial_stat{$trialid}{'#NONTARG'} > 0 && $trial_stat{$trialid}{'#TARG'} > 0);
		    }
		    ($TW_Cost, $TW_Cost_var, $TW_Cost_std, $TW_Cost_stderr) = sumstat(@temp_arr);
		
			    
		    if ($$r_TW_min_DET_Cost > $TW_Cost){
			$$r_TW_min_DET_Pmiss = $TW_Pmiss;
			$$r_TW_min_DET_Pfa   = $TW_Pfa;
			$$r_TW_min_DET_Cost  = $TW_Cost;
			$$r_TW_min_DET_normCost= Cost2NormCost($TW_Cost,$CF_Ptarg,$CF_Cmiss,$CF_Cfa);
			$TW_min_DET_thresh = $thresh;
		    }
		    
		    if ($prob_scale) {
			print TRIALW (ppndf($TW_Pmiss)," ",
				      ppndf($TW_Pfa), " ",
				      ppndf($TW_Pmiss+(1.28*$TW_Pmiss_stderr))," ",
				      ppndf($TW_Pmiss-(1.28*$TW_Pmiss_stderr))," ",
				      ppndf($TW_Pfa+(1.28*$TW_Pfa_stderr))," ",
				      ppndf($TW_Pfa-(1.28*$TW_Pfa_stderr))," ",
				      $thresh," ",
				      ppndf($Pmiss), " ",
				      ppndf($Pfa)," ",
				      ppndf(Cost2NormCost($TW_Cost,$CF_Ptarg,$CF_Cmiss,$CF_Cfa))," ",
				      ppndf(norm_detect_CF($Pmiss,$Pfa,$CF_Ptarg,$CF_Cmiss,$CF_Cfa)),"\n");
		    } else {
			print TRIALW ($TW_Pmiss," ",
				      $TW_Pfa, " ",
				      $TW_Pmiss+(1.28*$TW_Pmiss_stderr)," ",
				      $TW_Pmiss-(1.28*$TW_Pmiss_stderr)," ",
				      $TW_Pfa+(1.28*$TW_Pfa_stderr)," ",
				      $TW_Pfa-(1.28*$TW_Pfa_stderr)," ",
				      $thresh, " ", 
				      $Pmiss, " ",
				      $Pfa, " ",
				      Cost2NormCost($TW_Cost,$CF_Ptarg,$CF_Cmiss,$CF_Cfa), " ",
				      norm_detect_CF($Pmiss,$Pfa,$CF_Ptarg,$CF_Cmiss,$CF_Cfa),"\n");
		    }
		}
	    } while ($min_nontarg_trial ne "" && $min_targ_trial ne "");


	    ### close the data files!!!	    
	    close POOLED if ($Pooled);
	    close TRIALW if ($TrialWeighted);

	    #### open the MINimum DET
	    my $mindet_file = "${DETFile}.DET.$df";
	    open(MINDET,">$mindet_file") || die "Can not open $mindet_file";
	    $df++;
	    printf PLT (", \\\n    '$mindet_file' using 8:7 title 'SW Min DET Norm(Cost) = %.4f' with points 2",$$r_SW_min_DET_normCost)
		if ($Pooled);
	    printf PLT (", \\\n    '$mindet_file' using 2:1 title 'TW Min DET Norm(Cost) = %.4f' with points 3",$$r_TW_min_DET_normCost)
		if ($TrialWeighted);
	    
	    if ($$r_TW_min_DET_Pmiss ne "NULL"){
		print MINDET (($prob_scale) ? ppndf($$r_TW_min_DET_Pmiss) : $$r_TW_min_DET_Pmiss, " ",
			      ($prob_scale) ? ppndf($$r_TW_min_DET_Pfa) : $$r_TW_min_DET_Pfa, " ",
			      $$r_TW_min_DET_Cost, " ", 
			      ppndf($$r_TW_min_DET_normCost), " ",
			      $$r_TW_min_DET_normCost, " ",
			      $TW_min_DET_thresh, " ");
	    } else {
		print MINDET ("NULL NULL NULL NULL NULL NULL ");
	    }
	    print MINDET (($prob_scale) ? ppndf($$r_SW_min_DET_Pmiss) : $$r_SW_min_DET_Pmiss, " ",
			  ($prob_scale) ? ppndf($$r_SW_min_DET_Pfa) : $$r_SW_min_DET_Pfa, " ",
			  $$r_SW_min_DET_Cost, " ", 
			  ppndf($$r_SW_min_DET_normCost), " ", 
			  $$r_SW_min_DET_normCost, " ", 
			  $SW_min_DET_thresh,
			  "\n");
	    close MINDET;

	    #### Build the Threshold plots
	    if ($TrialWeighted){
		my $is_first = 0;

		print "Writing DET Threshhold plot to '${DETFile}.thresh.*'\n" if ($main::Vb > 0);

		### Start the THRESHOLD plot file
		open(THRESH,"> ${DETFile}.thresh.plt") ||
		    die("unable to open DET gnuplot file ${DETFile}.thresh.plt");
		&write_gnuplot_DET_threshhold_header(*THRESH, $Title, 1, 90);

		### Add lines to the threshold plot
		if ($Pooled){
		    my $xt = $rh_trial_data->{"DecisionID"} . " Wgt.";

		    print THRESH "," if ($is_first++ != 0);
		    print THRESH "\\\n   '$tw_data_file' using 7:8 title '$xt Pmiss' with lines 1";
		    print THRESH ",\\\n   '$tw_data_file' using 7:9 title '$xt Pfa' with lines 2";
		    print THRESH ",\\\n   '$tw_data_file' using 7:11 title '$xt Norm Cost' with lines 3";
		    printf THRESH (",\\\n   '$mindet_file' using 12:10 title '$xt Min DET Norm Cost = %.4f at score %.4f' with points 3",
				   $$r_SW_min_DET_normCost,$SW_min_DET_thresh);
		}
		if ($TrialWeighted){
		    my $xt =     $rh_trial_data->{"BlockID"}  . " Wgt.";
		    print THRESH "," if ($is_first++ != 0);
		    print THRESH "\\\n   '$tw_data_file' using 7:1 title '$xt Pmiss' with lines 4";
		    print THRESH ",\\\n   '$tw_data_file' using 7:2 title '$xt Pfa' with lines 5";
		    print THRESH ",\\\n   '$tw_data_file' using 7:10 title '$xt Norm Cost' with lines 7";
		    printf THRESH (",\\\n   '$mindet_file' using 6:4 title '$xt Min DET Norm Cost = %.4f at score %.4f' with points 7",
				   $$r_TW_min_DET_normCost,$TW_min_DET_thresh);
		}

	    }
	}
    }
    print PLT "\n";
    close(PLT);
    if ($TrialWeighted){
	print THRESH "\n";
	close(THRESH);
    }
}


sub copy_trial_data(){
    my ($rh_trial_data) = @_;
    my (%newtd) = ();
    my ($i, $trialid, $arrayid, $eqErrCost);
    
    print "Copying trial data\n" if ($main::Vb > 0);

    my($k1, $k2, $k3);
    foreach $k1(keys %$rh_trial_data){
	if ($k1 eq 'trials'){
	    foreach $k2(keys %{ $rh_trial_data->{$k1} }){
		foreach $k3(keys %{ $rh_trial_data->{$k1}{$k2} }){
		    if ($k3 eq "TARG" || $k3 eq "NONTARG"){
			my(@a) = @{ $rh_trial_data->{$k1}{$k2}{$k3} };
			$newtd{$k1}{$k2}{$k3} = [ @a ];
		    } else {
			$newtd{$k1}{$k2}{$k3} = $rh_trial_data->{$k1}{$k2}{$k3};
		    }
		}
	    }
	} else {
	    $newtd{$k1} = $rh_trial_data->{$k1};
#	    print "copy $k1 $newtd{$k1} = $rh_trial_data->{$k1}\n";
	}
    }	
    %newtd;
}

sub Dump_trial_data{
    my($rh_trial_data, $OUT, $pre) = @_;

    my($k1, $k2, $k3);
    print $OUT "${pre}Dump of Trial_data\n";
    foreach $k1(sort(keys %$rh_trial_data)){
	if ($k1 eq 'trials'){
	    print $OUT "${pre}   $k1 -> $rh_trial_data->{$k1}\n";
	    foreach $k2(keys %{ $rh_trial_data->{$k1} }){
		print $OUT "${pre}      $k2 -> $rh_trial_data->{$k1}{$k2}\n";
		foreach $k3(keys %{ $rh_trial_data->{$k1}{$k2} }){
		    if ($k3 eq "TARG" || $k3 eq "NONTARG"){
			my(@a) = @{ $rh_trial_data->{$k1}{$k2}{$k3} };
			print $OUT "${pre}         $k3 ($#a) -> (";
			if ($#a > 3){
			    foreach $_(0..1) {print $OUT "$a[$_],";}
			    print $OUT "...";
			    foreach $_(($#a-1)..$#a) {print $OUT ",$a[$_]";}
			} else {
			    print $OUT join(",",@a);
			}
			print $OUT ")\n";
		    } else {
			print $OUT "${pre}         $k3 -> $rh_trial_data->{$k1}{$k2}{$k3}\n";
		    }
		}
	    }
	} else {
	    print $OUT "${pre}   $k1 -> $rh_trial_data->{$k1}\n";
	}
    }	
}

sub Compute_DET_eqMinCost{
    my ($presorted, $ra_Targets, $ra_NonTarg, $Ptarg, $Cmiss, $Cfa) = @_;

    #   Variables
    my($PMIN)=0.0005;
    my($PMAX)=0.5;
    my($SMAX)=9e99;
    my(@Outputs) = ();
    my(@TARGET);
    my(@NONTARGET);
    my($Pmiss, $Pfa, $Mincost);

    if ($presorted){
	@TARGET = @$ra_Targets;
	@NONTARGET = @$ra_NonTarg;
    } else {
	#
	#   Sort the target and non-target scores
	@TARGET = sort numerically @$ra_Targets;
	@NONTARGET = sort numerically @$ra_NonTarg;
    }
    #
    #  // Append SMAX to very end 
    push(@TARGET,$SMAX);
    push(@NONTARGET,$SMAX);

    my ($ntrue) = 0;
    my ($nfalse) = 0;
    my ($cost, $thresh) = (99999, 99999);
    $Mincost = 99999999.999;

    while  ( ($ntrue < $#TARGET) || ($nfalse < $#NONTARGET)) {
	if ( $TARGET[$ntrue] <= $NONTARGET[$nfalse] && $ntrue < $#TARGET) {
	    $ntrue++;
	} else {
	    $nfalse++;
	}
	
	$Pmiss = ($#TARGET > 0) ? $ntrue / $#TARGET : 0;
	$Pfa = ($#NONTARGET > 0) ? ($#NONTARGET - $nfalse) / $#NONTARGET : 0;

	$cost = detect_CF($Pmiss,$Pfa,$Ptarg,$Cmiss,$Cfa);
	if ($cost < $Mincost){
	    $Mincost = $cost;
	    if ($ntrue > $#TARGET){
		$thresh = $NONTARGET[$nfalse];
	    } elsif ($nfalse > $#NONTARGET){
		$thresh = $TARGET[$ntrue];
	    } else {
		$thresh = (($TARGET[$ntrue] + $NONTARGET[$nfalse]) / 2.0);
	    }
	}
    }
    $thresh;
}

sub Compute_DET_points{
    my ($presorted, $ra_Targets, $ra_NonTarg) = @_;

    #
    #   Variables
    my($PMIN)=0.0005;
    my($PMAX)=0.5;
    my($SMAX)=9e99;
    my(@Outputs) = ();
    my(@TARGET);
    my(@NONTARGET);
    my($Det1, $Det2);

    if ($presorted){
	@TARGET = @$ra_Targets;
	@NONTARGET = @$ra_NonTarg;
    } else {
	#
	#   Sort the target and non-target scores
	@TARGET = sort numerically @$ra_Targets;
	@NONTARGET = sort numerically @$ra_NonTarg;
    }
    #
    #  // Append SMAX to very end 
    push(@TARGET,$SMAX);
    push(@NONTARGET,$SMAX);

    my ($ntrue) = 0;
    my ($nfalse) = 0;

    while  ( ($ntrue < $#TARGET) || ($nfalse < $#NONTARGET)) {
	if ( $TARGET[$ntrue] <= $NONTARGET[$nfalse] &&
	    $ntrue < $#TARGET) {
	    $ntrue++;
	} else {
	    $nfalse++;
	}
	
	$Det1 = ($#TARGET > 0) ? $ntrue / $#TARGET : 0;
	$Det2 = ($#NONTARGET > 0) ? ($#NONTARGET - $nfalse) / $#NONTARGET : 0;
	push(@Outputs, [ ( $Det1, $Det2 ) ] );;
    }

    @Outputs;
}

#
#sub Compute_Ntile_DET_points{
#    my (*Ntile_pts, Targets, *NonTarg) = @_;
#
#    #
#    #   Variables
#    my($PMIN)=0.0005;
#    my($PMAX)=0.5;
#    my($SMAX)=9e99;
#    my(@Outputs) = ();
#    my($cur_pts) = 1;
#    my($bin_cnt) = 0;
#
#    #
#    #   Sort the target and non-target scores
#    my(@TARGET) = sort numerically @Targets;
#    my(@NONTARGET) = sort numerically @NonTarg;
#
#    #
#    #  // Append SMAX to very end 
#    push(@TARGET,$SMAX);
#    push(@NONTARGET,$SMAX);
#
#    my ($ntrue) = 0;
#    my ($ntrue_next) = 0;
#    my ($nfalse) = 0;
#
#    while  ( ($ntrue < $#TARGET) || ($nfalse < $#NONTARGET)) {
#	if ((($ntrue+$ntrue_next) / $#TARGET) <= $Ntile_pts[$cur_pts]){
#	    if ( $TARGET[$ntrue] <= $NONTARGET[$nfalse] &&
#		$ntrue < $#TARGET) {
#		$ntrue++;
#	    } else {
#		$nfalse++;
#	    }
#	    $bin_cnt ++;
#	}
#	$ntrue_next = ($ntrue < $#TARGET &&
#		       $TARGET[$ntrue+1] <= $NONTARGET[$nfalse]) ? 1 : 0;
#
#	$Det1 = ($#TARGET > 0) ? $ntrue / $#TARGET : 0;
#	$Det2 = ($#NONTARGET > 0) ? ($#NONTARGET - $nfalse) / $#NONTARGET : 0;
#
#	if ((($ntrue+$ntrue_next) / $#TARGET) > $Ntile_pts[$cur_pts]){
#	    push(@Outputs, [ ( ppndf($Ntile_pts[$cur_pts-1]),
#			      ppndf($Ntile_pts[$cur_pts]),
#			      $bin_cnt,
#			      $ntrue, 
#			      ppndf($#NONTARGET - $nfalse),
#			      ppndf($Det1),
#			      ppndf($Det2)) ] );;
#	    $cur_pts ++;
#	    $bin_cnt = 0;
#	}
#    }
#
#    @Outputs;
#}

sub ppndf {

    my($ival) = @_;
# // A lot of predefined variables
#
    my $SPLIT=0.42;

    my $EPS=2.2204e-16;
    my $LL=140;

    my $A0=2.5066282388;
    my $A1=-18.6150006252;
    my $A2=41.3911977353;
    my $A3=-25.4410604963;
    my $B1=-8.4735109309;
    my $B2=23.0833674374;
    my $B3=-21.0622410182;
    my $B4=3.1308290983;
    my $C0=-2.7871893113;
    my $C1=-2.2979647913;
    my $C2=4.8501412713;
    my $C3=2.3212127685;
    my $D1=3.5438892476;
    my $D2=1.6370678189;
    my ($p, $q, $r, $retval);

    if ($ival >= 1.0) {
	$p = 1 - $EPS; 
    }
    elsif ($ival <= 0.0) {
	$p = $EPS;
    }
    else {
	$p = $ival;
    }

    $q = $p - 0.5;

    if (abs($q) <= $SPLIT ) {
	$r = $q * $q;
        $retval = $q * ((($A3 * $r + $A2) * $r + $A1) * $r + $A0) /
	    (((($B4 * $r + $B3) * $r + $B2) * $r + $B1) * $r + 1.0);
    } else {
	if ( $q > 0.0 ) {
	    $r = 1.0 - $p;
	} else { 
	    $r = $p;
	}

	if ($r <= 0.0) {
	    printf ("Found r = %f\n", $r);
	    return;
	}
	
	$r = sqrt( (-1.0 * log($r)));

	$retval = ((($C3 * $r + $C2) * $r + $C1) * $r + $C0) / 
	    (($D2 * $r + $D1) * $r + 1.0);
    
	if ($q < 0) { $retval = $retval * -1.0; }
    }
    return ($retval);
}

#########################################################################3
### This function maps system outputs to the reference story boundarys
### for both the tracking and detection evaluations.  The arguments are:
###
### @Hyp -> and array of arrays, the columns are: POINTER, HARD_DECISION, SCORE, (optionally HYP_TOPIC)
### $brec -> reference pointer to the beginning of the story
### #erec -> reference pointer to the last word/time of the story inclusive.
### $origin -> Starting point of the reference file, 0 for TIME, 1 for RECID
### $MapMethod -> either 'majority' or 'impulse'
### $Eval -> either 'tracking' or 'detection'
###
###
sub Find_system_score_for_doc{
    my($ra_Hyp, $brec, $erec, $origin, $MapMethod, $Eval) = @_;
    my($f);
    my($score_sum, $ineff_sum, $hard_dec_sum) = (0, 0, 0);
    my(%topic_score_sum) = ();
    my(%topic_hard_dec_sum) = ();
    my(%topic_hard_dec_sum_yes) = ();
    my(%topic_hard_dec_sum_no) = ();
    my($score, $hard_dec, $htopic) = (-9e99, "", "");
    my($ineff, $key);
    my($bounds) = "";

    print "DETECT story $brec $erec\n" if ($main::Vb > 10);
    if ($brec eq "" && $erec eq ""){
	print "   No brec or erec, returning no match\n" if ($main::Vb > 10);
	return(-9e99, "NO", "TDT3UnMappable", "BOUNDS:");
    }
    ### do the job of searching the hyp array
    for ($f=0; $f <= $#$ra_Hyp; $f++){
        print "HYP: index=$f  ".join(" ",@{ $ra_Hyp->[$f] })."\n" if ($main::Vb > 15);

	### Am I done searching ??????
	if ($ra_Hyp->[$f][0] > $erec){
	    #### strip the list if unnecessary entries, maintaining at least one entry
	    while (($#$ra_Hyp > 1) && ($ra_Hyp->[1][0] <= $erec)) { 
	        print "Stripped HYP: index=0  ".join(" ",@{ $ra_Hyp->[0] })."\n" if ($main::Vb > 15);
		shift(@$ra_Hyp); }
	    last;
	}
	### Short circut the search
	next if ((($f + 1) <= $#$ra_Hyp) && ($ra_Hyp->[$f + 1][0] < $brec));

	print "f=$f #Hyp=$#$ra_Hyp\n" if ($main::Vb > 15);

	if (($ra_Hyp->[$f][0] >= $brec) || 
	    ($f < $#$ra_Hyp && $ra_Hyp->[$f+1][0]-$origin >= $brec) ||
	    ($f == $#$ra_Hyp && $ra_Hyp->[$f][0] < $erec)) {

	    if ($MapMethod eq "majority"){
		### find Num words with this score
		if ($f < $#$ra_Hyp){
		    if ($ra_Hyp->[$f+1][0] <= $erec){
			if ($ra_Hyp->[$f][0] < $brec){
			    print "   Check Cond1a\n" if ($main::Vb > 15);
			    $ineff = ($ra_Hyp->[$f+1][0] - $origin) - $brec + $origin;
			} else {
			    print "   Check Cond1b\n" if ($main::Vb > 15);
			    $ineff = ($ra_Hyp->[$f+1][0] - $origin) - $ra_Hyp->[$f][0] + $origin ;
			}
		    } else {
			if ($ra_Hyp->[$f][0] > $brec){
			    print "   Check Cond2a\n" if ($main::Vb > 15);
			    $ineff = $erec - $ra_Hyp->[$f][0] + $origin;
			} else {
			    print "   Check Cond2b\n" if ($main::Vb > 15);
			    $ineff = $erec - $brec + $origin;
			}
		    }
		} else {  #####   ***** We are on the last HYP record *****
		    ### This conditional fixes a bug :(  The bug effects the scoring of the 
		    ### next to the last story IF the last HYP boundary 'begins' before the
		    ### next to the last REF story ends
		    if ($ra_Hyp->[$f][0] <= $brec){
			print "   Check Cond3\n" if ($main::Vb > 15);
			$ineff = $erec - $brec + $origin;
		    } elsif ($ra_Hyp->[$f][0] <= $erec){
			# version 1.9 fixes a bug here, forgot to use '<='
			print "   Check Cond4\n" if ($main::Vb > 15);
			$ineff = $erec - $ra_Hyp->[$f][0] + $origin;
		    } else {
			die "Internal Error in Find System Score: Undefined search condition, ".
			    "Hypind=$ra_Hyp->[$f][0], brec=$brec, erec=$erec";
		    }
		}
		$bounds .= ":".join(" ",@{ $ra_Hyp->[$f] })." $ineff";
		print "      ineffect = $ineff\n" if ($main::Vb > 15);
		if ($Eval eq 'tracking' || $Eval eq "first_story"){
		    $score_sum += $ineff * $ra_Hyp->[$f][2];
		    $ineff_sum += $ineff;
		    $hard_dec_sum += $ineff if ($ra_Hyp->[$f][1] eq "YES");
		} elsif ($Eval eq 'detection'){
		    if (! defined($topic_score_sum{$ra_Hyp->[$f][3]})){
			$topic_score_sum{$ra_Hyp->[$f][3]} = 0;
			$topic_hard_dec_sum_yes{$ra_Hyp->[$f][3]} = 0;
			$topic_hard_dec_sum_no{$ra_Hyp->[$f][3]} = 0;
		    }
		    $ineff_sum += $ineff;
		    $topic_score_sum{$ra_Hyp->[$f][3]} += $ineff * $ra_Hyp->[$f][2];
		    $topic_hard_dec_sum_yes{$ra_Hyp->[$f][3]} += $ineff if ($ra_Hyp->[$f][1] eq "YES");
		    $topic_hard_dec_sum_no{$ra_Hyp->[$f][3]} += $ineff if ($ra_Hyp->[$f][1] eq "NO");
		} else {
		    die "Illegal evaluation task '$Eval'";
		}		
	    } elsif ($MapMethod eq "impulse"){
		if ($score < $ra_Hyp->[$f][2]){
		    print "      Impulse Set\n" if ($main::Vb > 15);
		    $hard_dec = $ra_Hyp->[$f][1];
		    $score = $ra_Hyp->[$f][2];
		    $htopic = $ra_Hyp->[3] if ($#$ra_Hyp == 3);
		}
	    } else {
		die("Undefined story mapping function '$MapMethod'");
	    }
	}
    }
    if ($MapMethod eq "majority"){
	### Sanity check
	if ($MapMethod eq "majority"){
	    die "Find System Score Internal Error: Contact Jonathan.Fiscus\@nist.gov".
		"     $ineff_sum != ($erec - $brec + $origin).  score_sum=$score_sum"
		    if ($ineff_sum != ($erec - $brec + $origin));
	}
	if ($Eval eq 'tracking' || $Eval eq "first_story"){
	    $score = $score_sum / ($erec - $brec + $origin);
	    $hard_dec = "NO";
	    $hard_dec = "YES" if (($hard_dec_sum / ($erec - $brec + $origin)) >= 0.5);
	    print "        score_sum = $score_sum, hard_dec_sum = $hard_dec_sum\n"
		if ($main::Vb >= 15);
	} elsif ($Eval eq 'detection'){
	    ## Search each associative array for the Max hard decisions scores
	    if ($main::Vb >= 15){
		print "       Searching for the best scoring topic amongst:....\n";
		foreach $key(keys %topic_score_sum){
		    print "          $key, scoresum= $topic_score_sum{$key}".
			"   nyes= $topic_hard_dec_sum_yes{$key}".
			    "   nno= $topic_hard_dec_sum_no{$key}\n";
		}
	    }
	    my($key, $max, $maxkey) = ("", -99999, "");
	    foreach $key(keys %topic_score_sum){
		if (($max < ($topic_hard_dec_sum_yes{$key} + $topic_hard_dec_sum_no{$key})) ||
		    (($max == ($topic_hard_dec_sum_yes{$key} + $topic_hard_dec_sum_no{$key})) && 
		     ($topic_score_sum{$key} > $topic_score_sum{$maxkey} ))){
		    $max = $topic_hard_dec_sum_yes{$key} + $topic_hard_dec_sum_no{$key};
		    $maxkey = $key;
		}
	    }
	    $htopic = $maxkey;
	    die "Internal error, no topic assigned" if ($maxkey eq "");
	    $score = $topic_score_sum{$maxkey} / ($topic_hard_dec_sum_yes{$maxkey} +
					       $topic_hard_dec_sum_no{$maxkey} );
	    $hard_dec = "NO";
	    $hard_dec = "YES" if ($topic_hard_dec_sum_yes{$maxkey} >=
				  $topic_hard_dec_sum_no{$maxkey});
	} else {
	    die "Illegal evaluation task '$Eval'";
	}		
    }
    print "        score = $score, hard = $hard_dec, htopic = $htopic\n" if ($main::Vb >= 15);
    ($score, $hard_dec, $htopic, "BOUNDS$bounds");
}

sub log2{ log($_[0]) / log(2); }

sub sumstat{
    my(@data) = @_;
    my($sum, $sum_sqr, $var, $i) = (0, 0, 0, 0);
    foreach $i(@data){
	$sum += $i;
	$sum_sqr += $i * $i;
    }

    $var = ((($#data+1) * $sum_sqr) - ($sum * $sum)) / (($#data+1) * $#data);
    ### mean          variance, stdev     
    ($sum/($#data+1), $var,     sqrt($var), sqrt($var)/sqrt($#data+1));
}

sub sumstat_expensive{
    my(@data) = sort(@_);
    my($sum, $sum_sqr, $var, $i) = (0, 0, 0, 0);
    foreach $i(@data){
	$sum += $i;
	$sum_sqr += $i * $i;
    }

    $var = ((($#data+1) * $sum_sqr) - ($sum * $sum)) / (($#data+1) * $#data);
    ### mean          variance, stdev     , 1st qtr,  2nd qtr, 3rd qtr, numpts
    ($sum/($#data+1), $var,     sqrt($var), 
     $data[int($#data/4)], $data[int($#data/2)], $data[int($#data*3/4)], scalar(@data))
}


sub Dump_2dimarr{
    my($file, $after_ppndf, $ra_table) = @_;
    my($j, $i);

    open(D2DA,"> $file") || die("unable to open data file $file for write");
    if ($after_ppndf){
	for ($j=0; $j<=$#$ra_table; $j++){
	    for ($i=0; $i<=$#{ $ra_table->[$j] }; $i++){
		print D2DA ppndf($ra_table->[$j][$i]); 
		print D2DA " " if ($i != $#{ $ra_table->[$j] });
	    }
	    print D2DA "\n";	    
	}
    } else {
	for ($j=0; $j<=$#$ra_table; $j++){
	    print D2DA join(" ",@{ $ra_table->[$j] })."\n";
	}
    }
    close(D2DA);
}

sub Dump_1dimarr{
    my($file, $after_ppndf, $ra_table) = @_;
    my($j);

    open(D1DA,"> $file") || die("unable to open data file $file for write");
    if ($after_ppndf){
	for ($j=0; $j<=$#$ra_table; $j++){
	    print D1DA ppndf($ra_table->[$j])."\n"; 
	}
    } else {
	print D1DA join("\n",$#$ra_table)."\n";
    }
    close(D1DA);
}
 
sub detect_CF{
    my($Pmiss, $Pfa, $Ptopic, $Cmiss, $Cfa) = @_;
    ($Cmiss * 
     $Pmiss *
     $Ptopic) +
	 ($Cfa *
	  $Pfa *
	  (1-$Ptopic));
}

 
sub norm_detect_CF{
    my($Pmiss, $Pfa, $Ptopic, $Cmiss, $Cfa) = @_;

    detect_CF($Pmiss, $Pfa, $Ptopic, $Cmiss, $Cfa) / 
	MIN(detect_CF(1.0, 0.0, $Ptopic, $Cmiss, $Cfa),
	    detect_CF(0.0, 1.0, $Ptopic, $Cmiss, $Cfa));
}

sub Cost2NormCost{
    my($Cost, $Ptopic, $Cmiss, $Cfa) = @_;

    $Cost / MIN(detect_CF(1.0, 0.0, $Ptopic, $Cmiss, $Cfa),
		detect_CF(0.0, 1.0, $Ptopic, $Cmiss, $Cfa));
}

### Return zero if the denominator is zero
sub safeDivZero{
    my ($num, $denom) = @_;
    return ($denom == 0) ? 0 : $num / $denom;
}

### Return dash if the denominator is zero
sub safeDivDash{
    my ($num, $denom) = @_;
    return ($denom == 0) ? "-" : $num / $denom;
}

### return a randomize an array
sub scramble{
    my (@out) = ();
    while (@_){
	push @out, splice(@_, rand @_, 1);
    }
    @out;
}

### Open the file and return an array of the first line to match the regulary expression
sub GetLine{
    my ($file, $regexp) = @_;
    open (F, $file) || die "Error: Failed to open '$file' to GetLine matching '$regexp'";
    while(<F>){
	next unless ($_ =~ /$regexp/);
	close F;
	return (/^(.*$regexp.*)$/);
    }	
    close F;
    die "Failed to GetLine of pattern '$regexp' in file '$file'";
    return "";
}

### Open a file and return the file pointer,  deal with compression to
sub TDT_open{
    my ($file) = @_;

    use FileHandle;

    my $handle = new FileHandle;
    if ($file =~ /\.(Z|gz)$/){
	open($handle,"$main::UncompressCommand < $file |") || die("Error: Unable to open compressed file '$file'");
    } else {
	open ($handle,$file) || die "Error: Unable to open file '$file'";
    }
    $handle;
}


###################################  EDES Utilities  #########################
$main::EDES_file = "";
%main::Edes_avalue = ();
sub EDES_set_file{
    my($edes_file) = @_;
    %main::main::Edes_avalue = ();

    $main::EDES_file = $edes_file;
    open(EDES,">$main::EDES_file") || 
	die "Error: unable to open report file '$main::EDES_file'\n" ;
    close(EDES);    
}

sub EDES_add_to_avalue{
    my($attr, $val) = @_;
    return if ($main::EDES_file eq "");
    $main::Edes_avalue{$attr} = $val;
}

sub EDES_delete_from_avalue{
    my($attr) = @_;
    return if ($main::EDES_file eq "");
    delete($main::Edes_avalue{$attr})
}

sub EDES_print{
    my(@av) = @_;
    my($key);

    return if ($main::EDES_file eq "");

    open(ED1,">>$main::EDES_file") || 
	die "Error: unable to open report file '$main::EDES_file'\n" ;

    print ED1 "<EDES";

    foreach $key(sort(keys %main::Edes_avalue)){
	print ED1 " $key=\"$main::Edes_avalue{$key}\"";
    }
    die "Error: EDES_print number of arguments not even"
	unless($#av > 0 && (($#av+1) % 2) == 0);
    while ($#av >= 0){
	print ED1 " ".shift(@av)."=\"".shift(@av)."\"";
    }
    print ED1 ">\n";
    close ED1;
}

#########################  End of EDES Utilities  #########################


1;
