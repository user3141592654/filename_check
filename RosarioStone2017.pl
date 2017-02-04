#!/usr/bin/perl
=pod
Copyright (c) 2017 Wilfredo Rosario

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
=cut

#TO DO
#extract oversized _xx and _xx_yy before name goes to front_matter, back_matter section.
#add section to automatically extract delimeter, add section to ask user for delimeter, add code to build using the delimeters
#add capability to turn off parts of the code when checking name (override of sorts)
#add capability to turn off parts of the code via command line options
#add section to turn off parts of the code automatically, but ask user? check to see if this would be useful.
#create a graphical user interface for this code

#ref names have no padding
#typo @ SIZE_DERIV
$ref=0;#filenames with ref use a different naming scheme


if(scalar(@ARGV) <= 1){
    $CHECK_FOLDER=$ARGV[0];
    if(($CHECK_FOLDER=~m/^(\s)*(-)+h/i)or($CHECK_FOLDER=~m/^(\s)*\/\?$/i)){#show help information
        showHelp();	
        exit;
    }elsif($CHECK_FOLDER=~m/^(\s)*(-)+v/i){#show version information
        showVersion();
        exit;
    }elsif($CHECK_FOLDER=~m/^(\s)*(-)+(no_partner|no_collection|no_uow|no_page|no_front|no_back|no_extension|no_target)/i){#turn off certain features
=pod
#work in progress
        if($CHECK_FOLDER=~m/^(\s)*(-)+(no_partner)/i){# if there is no partner
            $no_partner='yes';
        }if($CHECK_FOLDER=~m/^(\s)*(-)+(no_collection)/i){
            $no_collection='yes';
        }if($CHECK_FOLDER=~m/^(\s)*(-)+(no_uow)/i){
            $no_uow='yes';
        }if($CHECK_FOLDER=~m/^(\s)*(-)+(no_page)/i){
            $no_page='yes';
        }if($CHECK_FOLDER=~m/^(\s)*(-)+(no_front)/i){
            $no_front='yes';
        }if($CHECK_FOLDER=~m/^(\s)*(-)+(no_back)/i){
            $no_back='yes';
        }if($CHECK_FOLDER=~m/^(\s)*(-)+(no_extension)/i){
            $no_extension='yes';
        }if($CHECK_FOLDER=~m/^(\s)*(-)+(no_target)/i){
            $no_target='yes';
        }if($CHECK_FOLDER=~m/^(\s)*(-)+(no_eoc)/i){
            $no_target='yes';
        }
=cut
    }else{
        $no_partner    = 'no';
        $no_collection = 'no';
        $no_uow        = 'no';
        $no_page       = 'no';
        $no_front      = 'no';
        $no_back       = 'no';
        $no_extension  = 'no';
        $no_target     = 'no';
        
        @files       = getVisibleFiles($CHECK_FOLDER);
        @subfolders  = getVisibleSubfolders($CHECK_FOLDER);
        @hiddenfiles = getHiddenFiles($CHECK_FOLDER);
        @hiddenfolder= getHiddenSubfolders($CHECK_FOLDER);
    }
}else{
    die "You must enter a folder path\n";
}

print "\nHello,\nYou are in \n$CHECK_FOLDER/\n\n";#indicates path to folder being checked


for(my $i=0;$i<=scalar(@files);$i++){
	$fhash{$files[$i]}='failure of name: ';#files fail by default
  #  $fhash{'target'}='fail, target';
}

#=================Start of Automatic Assignation of Variables===================

# A PartID is a fragment made from the filenames found in a folder that can be used to identify a unit such as a book. For example: while the pages may change, the name of the book is the same.

for my $key(keys %fPartIDhash_pop){
	$fPartIDhash_pop{$key}=undef;# this hash is used to attempt to choose the most common PartID, the less common PartID's are considered to be due to typos etc.
}


for my $key(keys %fPartIDhash){
	$fPartIDhash{$key}=undef; # this hash contains all the PartID
}



for my $key(keys %fhash){
    my($key2, $PageID, $uow,$ext,$front_matter,$back_matter,$is_d,$PartID);
	undef($key2);undef($PageID);undef($uow);undef($ext);undef($front_matter);undef($back_matter);
    
    $key_target=$key;
	
    $key2=$key;
    $key2=removeExtension($key2);#remove the file extension
  
    $is_d=getRole($key2);
    $key2=removeRole($key2);# remove the _m or _d file role
    
    $PartID = getPartID($key2);# create a PartID
    $fPartIDhash{'ext'.$PartID}=getExtension($key); # extract the extension
   
   
    $front_matter = getFrontMatter($key2);# extract the front matter page number if applicable (else returns a space character)
#    if($front_matter ne ' '){
        $key2=removeFrontMatter($key2);# remove the front matter if applicable
#    }


    $back_matter = getBackMatter($key2);# extract the back matter page number if applicable (else returns a space character)
#    if($back_matter ne ' '){
        $key2=removeBackMatter($key2);#remove the backmatter if applicable
#    }
    

    $PageID = getPageID($key2);# extract the paginated page number if applicable (else returns a space character)
#    if($PageID ne ' '){
        $key2=removePageID($key2);#remove the backmatter if applicable
#    }

    $PartnerID = getPartnerID($PartID);# extract a PartnerID
    $CollectionCode = getCollectionCode($PartID); #extract a CollectionCode

    #PartID looks like PID_CC
	if ($PartID !~ m/^(\s)*$/){
        #------------------------------
        #get maximum front matter pages
		$fPartIDhash{'MAXfront'.$PartID}=$front_matter unless (($fPartIDhash{'MAXfront'.$PartID}+0)>$front_matter); #get the largest frontmatter page number
        
        #get maximum back matter pages
		$fPartIDhash{'MAXback'.$PartID}=$back_matter unless (($fPartIDhash{'MAXback'.$PartID}+0)>$back_matter); #get the largest backmatter page number
        #------------------------------
    
		if(($front_matter=~m/^(\s)*$/) and ($back_matter=~m/^(\s)*$/)){ #if not front matter or backmatter, the name contains a paginated-page-like number
			#get the minimum and maximum page numbers (of the paginated pages) from the filenames
			#if($key2=~m/(\d)+$/){

                #get the maximum paginated page number
				if(($fPartIDhash{'MAXpageID'.$PartID} =~m/^(\s)*$/)||($fPartIDhash{'MAXpageID'.$PartID} eq undef)){#if there is no page number choose the first valid one
					$fPartIDhash{'MAXpageID'.$PartID}=$PageID+0;
				}else{
                    $fPartIDhash{'MAXpageID'.$PartID}=max($PageID,$fPartIDhash{'MAXpageID'.$PartID});#get the maximum page number
                }
                
                #get the minimum paginated page number
				if(($fPartIDhash{'MINpageID'.$PartID} =~m/^(\s)*$/)||($fPartIDhash{'MINpageID'.$PartID} eq undef)){# if there is no page number choose the first valid one
					$fPartIDhash{'MINpageID'.$PartID}=$PageID+0;
				}else{
                    $fPartIDhash{'MINpageID'.$PartID}=min($PageID,$fPartIDhash{'MINpageID'.$PartID});#get the minimum page number
                }
                
			     #$key2 = removePageID($key2);
            #}
		}
        #------------------------------
		#unit of work
        
#=pod
		if($key2=~m/(\d)+$/){
            #get the minimum and maximum unit of work from the filenames 
            #minimum and maximum unit of work can occur when there are many different works in a single folder
            #this feature was not expanded upon, rest of code assumes one unit of work
			$unit_of_work=substr($key2, $-[0], $+[0]-$-[0]);
			$unit_of_work=$unit_of_work+0;
			$key2=~s/(\d)+$//;
            

            #get the minimum unit of work, 
			if(($fPartIDhash{'MINuow'.$PartID}=~m/^(\s)*$/)||($fPartIDhash{'MINuow'.$PartID}eq undef)){
				$fPartIDhash{'MINuow'.$PartID}=$unit_of_work;
			}else{
                $fPartIDhash{'MINuow'.$PartID}=$unit_of_work unless ($fPartIDhash{'MINuow'.$PartID}<$unit_of_work);
                $fPartIDhash{'MINuow'.$PartID}=$fPartIDhash{'MINuow'.$PartID}+0;# make sure that it is a number
            }
            
            #get the maximum unit of work
			if(($fPartIDhash{'MAXuow'.$PartID}=~m/^(\s)*$/)||($fPartIDhash{'MAXuow'.$PartID} eq undef)){
				$fPartIDhash{'MAXuow'.$PartID}=$unit_of_work;
			}else{
			     $fPartIDhash{'MAXuow'.$PartID}=$unit_of_work unless ($fPartIDhash{'MAXuow'.$PartID}>$unit_of_work);
			     $fPartIDhash{'MAXuow'.$PartID}=$fPartIDhash{'MAXuow'.$PartID}+0;
            }
            
            #check if the minimum unit of work is equal to the maximum unit of work, if it is set the uow as the unit of work
			if($fPartIDhash{'MAXuow'.$PartID}==$fPartIDhash{'MINuow'.$PartID}){
				$fPartIDhash{'uow'.$PartID}=$fPartIDhash{'MINuow'.$PartID};
			}		
		}
#=cut
		#------------------------------
		#file sizes
        #the purpose of this section is to find out the file sizes of the current files, and to keep a tally of how many files there are
        #in a later section this information is used to calculate the average size of a master file, and the average size of a d file.
        #a large deviation indicates that there might be a problem with the image (cropped master, uncropped derivative etc.)
		if($is_d=~m/d/i){#get d file size information
			$fPartIDhash{'d_count'.$PartID}=$fPartIDhash{'d_count'.$PartID}+1; # counts how many dfiles have gone through
			#regular d size
			$sized=(-s "$CHECK_FOLDER/$key");# get the size of the current d file
			if(($fPartIDhash{'sized'.$PartID}=~m/^(\s)*$/)||($fPartIDhash{'sized'.$PartID}eq undef)){
				$fPartIDhash{'sized'.$PartID}=$sized;
			}else{
				$fPartIDhash{'sized'.$PartID}=int(($fPartIDhash{'sized'.$PartID}+$sized));
			}
		}elsif($is_d=~m/m/i){#get m file size information
			$fPartIDhash{'m_count'.$PartID}=$fPartIDhash{'m_count'.$PartID}+1; # counts how many m files have gone though
			#regular m size
			$sizem=(-s "$CHECK_FOLDER/$key");# get the size of the current m file
			if(($fPartIDhash{'sizem'.$PartID}=~m/^(\s)*$/)||($fPartIDhash{'sized'.$PartID}eq undef)){
				$fPartIDhash{'sizem'.$PartID}=$sizem;
			}else{
				$fPartIDhash{'sizem'.$PartID}=int(($fPartIDhash{'sizem'.$PartID}+$sizem));
			} 
		}

		#------------------------------
		#popularity of PartID
		if(($fPartIDhash_pop{$PartID}=~m/^(\s)*$/)||($fPartIDhash_pop{$PartID}eq undef)){
			$fPartIDhash_pop{$PartID}=1; #create a key-value pair of each new PartID encountered and initialize its count to 1;
		}
        
		$fPartIDhash_pop{$PartID}=$fPartIDhash_pop{$PartID}+1; #increment the count of the current PartID by 1
        
		$fPartIDhash{'PartnerID'.$PartID}=$PartnerID;#creates an entry for the PartnerID for the current $PartID
		$fPartIDhash{'CollectionCode'.$PartID}=$CollectionCode;#creates an entry for the CollectionCode for the current $PartID
        #------------------------------
	}
	#------------------------------
	#target filename
	if ($fPartIDhash{'target'.$PartID} !~ m/^(y|n)/i){#this section creates the default answers if the field is blank
		$fPartIDhash{'target'.$PartID}='no'; #no target found
        $fhash{$key}='fail target';
	}

	if($key=~m/target/i){ #if the filename has the word target in it, there is a target
		$target_name=$key;
		$PartID=$key;
		$PartID=~s/(\d)+(_|-)target(_|-)*(\w|\W)*$//;	
        undef($fPartIDhash{'target'.$PartID});
		$fPartIDhash{'target'.$PartID}='yes';
        $fPartIDhash{'target'}='yes';
		#$fhash{$key}='pass target';
	}

	#------------------------------
	#environment of creation
	if ($fPartIDhash{'EOC'} !~ m/^(y|n)/i){ #if this is the first run, initialize the EOC to 'no'
		$fPartIDhash{'EOC'}='no';
	}
	if($key=~m/eoc\.csv$/i){
		undef($fPartIDhash{'EOC'});
		$fPartIDhash{'EOC'}='yes';
		$fPartIDhash{$key}='pass EOC';
		$fhash{$key}='pass EOC';

	}
	#------------------------------
}
#------------------------------
#Assign values to the global variables
undef($key);undef($value);undef(@popularity);undef(@popularity2);
$MoreCollectionCodes='no';
$first=1;
for$key(keys %fPartIDhash){

	if($first==1){
		if($key =~ m/CollectionCode/i){
		$old_key=$key;
		$first=0;
		}
	}else{
		if($key =~ m/CollectionCode/i){
			$MoreCollectionCodes='yes' unless $key =~ m/$old_key/i;
			$old_key=$key;
		}
	}
}
#------------------------------
undef $key;
undef $value;

#find out which is the most common PartID
for$key(%fPartIDhash_pop){
    #turn the hash into a key-value pair string with <= as a delimeter between the key and the value. The key-value pair is enetered into a perl array.
    #the value of the key-value pair contains the number of times a given key appeared. The key of the key-value pair contains the unique PartID.
	$value=$fPartIDhash_pop{$key};
	push(@popularity,"$value <= $key");
}
@popularity2=reverse(sort(@popularity));# sort by most common PartID since the value (which keeps track of number of occurrences) is listed first
$PreferredPartID=shift(@popularity2);
(undef,$PreferredPartID)=split(/ \<\= /,$PreferredPartID);#throw away the value from the key-value pair

undef(@popularity);
undef(@popularity2);
#------------------------------


#once the most common PartID is found, extract the appropriate partner id, collection code etc. from the fPartIDhash hash
$partner_id       = $fPartIDhash{'PartnerID'.$PreferredPartID};
$collection_code  = $fPartIDhash{'CollectionCode'.$PreferredPartID};
$uow              = $fPartIDhash{'uow'.$PreferredPartID};
$MIN_page_id      = ($fPartIDhash{'MINpageID'.$PreferredPartID})unless $fPartIDhash{'MINpageID'.$PreferredPartID}=~m/^(\s)*$/;
$MINPAGEID        = ($MIN_page_id+0) unless $fPartIDhash{'MINpageID'.$PreferredPartID}=~m/^(\s)*$/;
$MAX_page_id      = ($fPartIDhash{'MAXpageID'.$PreferredPartID})unless $fPartIDhash{'MAXpageID'.$PreferredPartID}=~m/^(\s)*$/;
$MAX_page         = ($MAX_page_id+0) unless $fPartIDhash{'MAXpageID'.$PreferredPartID}=~m/^(\s)*$/;
$MAX_front_matter = ($fPartIDhash{'MAXfront'.$PreferredPartID}+0);
$MAX_back_matter  = ($fPartIDhash{'MAXback'.$PreferredPartID}+0);
$extension        = $fPartIDhash{'ext'.$PreferredPartID};
$EOC              = $fPartIDhash{'EOC'};
#------------------------------


# d_count and m_count cannot be zero, 
if($fPartIDhash{'d_count'.$PreferredPartID} =~m/^(\s)*$/){
	$fPartIDhash{'d_count'.$PreferredPartID}=1;
}
if($fPartIDhash{'m_count'.$PreferredPartID} =~m/^(\s)*$/){
	$fPartIDhash{'m_count'.$PreferredPartID}=1;
}
unless($fPartIDhash{'sized'.$PreferredPartID}=~m/^(\s)*$/){
$AVG_SIZE_DERIVS=int(($fPartIDhash{'sized'.$PreferredPartID})/$fPartIDhash{'d_count'.$PreferredPartID});
}
unless($fPartIDhash{'sizem'.$PreferredPartID}=~m/^(\s)*$/){
	$AVG_SIZE_MASTER=int(($fPartIDhash{'sizem'.$PreferredPartID})/$fPartIDhash{'m_count'.$PreferredPartID});
}
$target=$fPartIDhash{'target'.$PreferredPartID};


#present the user with a simple report ('SUMMARY_OF_FEATURES') about the information extracted from the filenames
$~ = 'SUMMARY_OF_FEATURES';
write; #write the 'SUMMARY_OF_FEATURES' report to STDOUT

#=================End of Automatic Assignation of Variables===================

#=============================== start of questions ===================================
#TO DO: ask the user for the type of delimeter instead of assuming it is an underscore
#When the script fails to extract the information properly, the user can make corrections
$redo='n';
while($redo=~m/^(\s)*n/i){
#---this section verifies that the automatic assignation of variables was able to extract the relevant pieces of information,
#---if the automatic portion failed it will ask the user to input the pertinent data
print"\n\n";

	if($partner_id =~ m/^(\s)*$/i){
        $partner_id=askPartnerID();#ask the user for a partnerID
	}

	if($collection_code =~ m/^(\s)*$/i){
        $collection_code=askCollectionCode();#ask the user for a collection code
	}

	if($uow !~ m/^(\d)+$/){#ask the user for a unit of work
        $uow=askUOW();
	}

	if($MIN_page_id !~ m/^(\d)+$/){
        $MIN_page_id = askMinPageID();#ask the user for a minimum paginated page number
        $MINPAGEID = $MIN_page_id;
	}
    

	if($MAX_page_id !~ m/^(\d)+$/){
        $MAX_page_id = askMaxPageID();
        $MAX_page = $MAX_page_id;
	}

	if($MAX_front_matter !~ m/^(\d)+$/){
        $MAX_front_matter = askMaxFrontMatter();
	}
    
    if($MAX_back_matter !~ m/^(\d)+$/){
        $MAX_back_matter = askMaxBackMatter();
        
	}

	if($extension !~ m/^(\s)*\.(\w|\W)+$/i){
        $extension = askExtension();
	}

	if($target !~ m/^(\s)*(y|n)/i){
        $target = askTarget();
	}


#turn off
=pod
#work in progress
$partner_id       = "" unless $no_partner eq 'no';
$collection_code  = "" unless $no_collection eq 'no';
$uow              = "" unless $no_uow eq 'no';
$MIN_page_id      = "" unless $no_page eq 'no';
$MINPAGEID        = "" unless $no_page eq 'no';
$MAX_page_id      = "" unless $no_page eq 'no';
$MAX_page         = "" unless $no_page eq 'no';
$MAX_front_matter = "" unless $no_front eq 'no';
$MAX_back_matter  = "" unless $no_back eq 'no';
$extension        = "" unless $no_extension eq 'no';
$EOC              = "" unless $no_EOC eq 'no';
=cut
#-----------------------

#---This is a report on the sample filenames based on the information provided
	print "For roles we will assume m for master and d for derivatives\n";
#	print "For the extension we will assume .tif for TIFF files\n";
#	$extension='.tif';
    print "\nSAMPLE FILE NAMES:\n";
    #display the automatically generated paginated page name   
    print createPaginatedName($partner_id, $collection_code, $uow, $MIN_page_id,"m",$extension);
    print "\n";
    print createPaginatedName($partner_id, $collection_code, $uow, $MIN_page_id,"d",$extension);
    print "\n";
        
    if($target =~ m/^(\s)*y/i){
    #display the automatically generated target name
        @target_names = createTargetName($partner_id,$collection_code,$uow,'target','m',$extension);
        showIndentList(@target_names,"\n");     
    }
    
    if($MAX_back_matter>0){
    #display the automatically generated backmatter page name
        print createFrontMatterName($partner_id, $collection_code, $uow, "bk", $MAX_back_matter, "_m", $extension);
        print "\n";
        print createFrontMatterName($partner_id, $collection_code, $uow, "bk", $MAX_back_matter, "_d", $extension);
        print "\n";
    }
    
    if($MAX_front_matter>0){
    #display the automatically generated backmatter page name
        print createBackMatterName($partner_id, $collection_code, $uow, "fr", $MAX_back_matter, "_m", $extension);
        print "\n";
        print createBackMatterName($partner_id, $collection_code, $uow, "fr", $MAX_back_matter, "_d", $extension);
        print "\n";
    }

    $redo_inner = askManualEntry();
    if($redo_inner =~ m/^(\s)*n/i){#if the user is not satisfied with the automatic names generated, erase the values created automatically
        undef($partner_id);undef($collection_code);undef($uow);undef($MIN_page_id);undef($MAX_page_id);undef($MAX_front_matter);undef($MAX_back_matter);
        undef($target);undef($extension);
    } 
}




#this section checks for the proper naming of the target
	if($target =~ m/^(\s)*y/i){# if there is a target present
    # remember: target is lowercase
        ($proper_target_name,$proper_target_name2)=createTargetName($partner_id,$collection_code,$uow,'target','m',$extension);

       #check that the filename matches the proper target name 
        if (quotemeta($target_name) eq quotemeta($proper_target_name)){
            $is_target_ok=$is_target_ok+1;
        }elsif (quotemeta($target_name) eq quotemeta($proper_target_name2)){
            $is_target_ok=$is_target_ok+1;
        }else{
            $is_target_ok=0;# a value less than or equal to zero indicates that the target has an incorrect name
        }
        
        
        if($is_target_ok > 0){
            $fhash{$target_name}='pass, target';
        }else{
            $fhash{$target_name}='failure of name:';
        }


	}

#===================================== end of questions =================================

$SUM=$MAX_page+$MAX_front_matter+$MAX_back_matter;


#==================BEGIN FILENAME CHECK=====================

for($j=$MINPAGEID;$j<=$SUM;$j++){


#---create frontmatter name
	$go=1;
    if($MAX_front_matter>0){
        $master=createFrontMatterName($partner_id, $collection_code,$uow,$MAX_front_matter,'m',$extension);
        $deriv =createFrontMatterName($partner_id, $collection_code,$uow,$MAX_front_matter,'d',$extension);

        $MAX_front_matter--;# decrease the frontmatter counter
        $go=0;   
    }
     
#---create backmatter name once the frontmatter name has been checked
	$go2=1;
	if(($MAX_back_matter>0) && ($go==1)){ #checks that there is frontmatter material and that the relevant frontmatter material has been finished
        $master=createBackMatterName($partner_id, $collection_code,$uow,$MAX_back_matter,'m',$extension);
        $deriv =createBackMatterName($partner_id, $collection_code,$uow,$MAX_back_matter,'d',$extension);
        
		$MAX_back_matter--;# decrease the backmatter counter
		$go2=0;	
	}
    
#---create the paginated page name once the frontmatter and backmatter names have been checked
	if((($MIN_page_id<=$MAX_page_id) && ($go==1)) && ($go2==1)){ 
		if($MIN_page_id<=$MAX_page_id){
             $master=createPaginatedName($partner_id, $collection_code,$uow,$MIN_page_id,'m',$extension);#create a master paginated page name to check
             $deriv= createPaginatedName($partner_id, $collection_code,$uow,$MIN_page_id,'d',$extension);#create a derivative paginated page name to check
			 $MIN_page_id++;
		}
        
	}


#---check compliance of file sizes
    #master file size
	if(exists $fhash{$master}){ 
        $fhash{$master} = checkMasterFileSize("$CHECK_FOLDER/$master", "$CHECK_FOLDER/$deriv"); # check the size of the master file
	}
    
    #deriv file size
	if(exists $fhash{$deriv}){
        $fhash{$deriv}  = checkDerivFileSize("$CHECK_FOLDER/$master", "$CHECK_FOLDER/$deriv"); # check the size of the derivative file
  
	}

#---determine if master and derivative files exist
    #master file
	unless(exists $fhash{$master}){ #unless the properly named master file exists in fhash, 
        $fhash{$master}= 'fail, missing'; #set the value of the key-value pair to the missing file error message
	}
    
    #derivative file
	unless(exists $fhash{$deriv}){
        $fhash{$deriv}= 'fail, missing';
	}
    
}
#==================END FILENAME CHECK=====================

#Is the EOC included?
if($EOC =~ m/^(\s)*n/i){
	$fhash{'EOC.csv'}='fail, missing EOC.csv';
}


#other folders within folder?
if(scalar(@subfolders) == 0){# if there are no subfolders
    $fhash{'folder'}='pass';
}else{
     foreach $_ (@subfolders){ #if there are subfolders
      $fhash{$_}='fail, folder within folder';  #create an entry inthe fhash hash with the key set to the subfolder name
    }
}


#check if there are hidden files within folder
if(scalar(@hiddenfiles) == 0){#if there are no hidden files
    $fhash{'hiddenfile'}='pass';
}else{
     foreach$_(@hiddenfiles){# if there are hidden files
        $fhash{$_}='fail, hidden file(s) within this folder' unless $_=~ /\.DS_Store/; # an exception for the .DS_Store file on macintosh computers
    }
}



for $key (keys %fhash){
#go through the fhash hash and sort each failure type such that a given array (such as @hidden for hidden files) only contains one type of error.
	$value = $fhash{$key};
	unless($key=~m/^(\s)*$/){;
		if($value =~m/^fail/){
        
            if($value =~m/^fail, missing/){
                push(@missing,$key);
                @missing=sort(@missing);
            }
            
            elsif($value =~m/^failure of name/){# does not match a standard filename
                push(@badnames,$key);
                @badnames=sort(@badnames);
            }
            
            elsif($value =~m/^fail, hidden/){#hidden files
                push(@hidden,$key);
                @hidden=sort(@hidden);
            }
            
            #file size issues, same size
            elsif($value =~m/^fail, derivative &/){
                push(@samesize,$key);
                @samesize=sort(@samesize);
            }
            #file size issues
            elsif($value =~m/^fail, derivative file larger/){
                push(@dlarger,$key);
                @dlarger=sort(@dlarger);
            }
            #file size issues
            elsif($value =~m/^fail, master file smaller/){
                push(@msmaller,$key);
                @msmaller=sort(@msmaller);
            }
            
            elsif($value =~m/^fail, folder/){
                push(@badfolder,$key);
                @badfolder=sort(@badfolder);
            }
		}
	}
}

if($target =~ m/^(\s)*n/i){# check the vaule of the target variable
    push(@missing, 'target');
}

#let the first element of the perl array explain what the rest of the array contains
unshift(@badfolder,'fail, found subfolder(s) within this folder:');# folder present that should not be there
unshift(@missing,'fail, missing:');# missing files
unshift(@hidden,'fail, found hidden file(s) within this folder:');# hidden files that should not be there
unshift(@samesize,'fail, derivative & master have same size:'); 
unshift(@dlarger,'fail, derivative file larger than master file:');
unshift(@msmaller,'fail, master file smaller than derivative file:');
unshift(@badnames,'fail, file name does not follow naming convention:'); # file name does not follow convention
unshift(@hiddenfolder,'fail, found hidden subfolder(s) within this folder:');# hidden subfolder that should not be there

#create a string of the contents for each perl array, where the array is a container for the errors found
$missingstring=join("\n\t",@missing);
$hiddenstring=join("\n\t",@hidden);
$samesizestring=join("\n\t",@samesize);
$dlargerstring=join("\n\t",@dlarger);
$msmallerstring=join("\n\t",@msmaller);
$badnamesstring=join("\n\t",@badnames);
$badfolderstring=join("\n\t",@badfolder);
$hiddenfolderstring=join("\n\t",@hiddenfolder);

#collect all of the error types in the @Errors array
if((scalar(@missing)-1)>0){
    push(@Errors,$missingstring);
}
if((scalar(@hidden)-1)>0){
    push(@Errors,$hiddenstring);
}
if((scalar(@samesize)-1)>0){
    push(@Errors,$samesizestring);
}
if((scalar(@dlarger)-1)>0){
    push(@Errors,$dlargerstring);
}
if((scalar(@msmaller)-1)>0){
    push(@Errors,$msmallerstring);
}
if((scalar(@badnames)-1)>0){
    push(@Errors,$badnamesstring);
}
if((scalar(@badfolder)-1)>0){
    push(@Errors,$badfolderstring);
}
if((scalar(@hiddenfolder)-1)>0){
    push(@Errors,$hiddenfolderstring);
}

if(scalar(@Errors)!=0){
	fail();
    print "\n\n";
	foreach(@Errors){
		if($_ =~ m/^fail/ig){
			print "$_\n\n";
		}
	}
	endfail();
}else{
	pass();
}

#==========================================================================================================================
#subroutines
#show   = display on STDOUT
#create = generate a string
#ask    = request user input from STDIN
#check  = verify compliance
#remove = return a string with a character sequence that has been removed
#get    = attempt to extract a character sequence from a string without modifying string

sub askManualEntry{
    #About: asks the user whether the filenames are OK, returns a string beginning with either y for yes or n for no, case insensitive.
    #Input: void
    #Output: A string beginning with either y for yes or n for no, case insensitive.
    #Usage: $output = askManualEntry();
    #Dependency: none
    my $redo_inner;
    undef($redo_inner);
    $redo_inner=' ';
	while ($redo_inner !~ m/^(\s)*(y|n)/i){
		print "\nFile names ok? (y for yes, n for no. If not, you will be asked more questions.)\n";
		$redo_inner=<STDIN>;#(manual version) leave this line uncommented to have the user manually interact with the program
        #$redo_inner='y';#(batch version) leave this line uncommented to have the program run automatically. This line just assumes that everything is OK; that the filename is standard. not recommended.
		$redo=$redo_inner;
	}
}

sub createPaginatedName{
    #About: creates a proper paginated page name
    #Input: ($partner_id, $collection_code,$unit_of_work,$page_number,$role,$extension)
    #Output: properly formatted target names
    #Usage: $output = createBackMatterName($partner_id, $collection_code,$unit_of_work,$page_number,$role,$extension);
    #Dependency: none
    
    my $partner_id;my $collection_code; my $unit_of_work; my $page_number; my $role, my $extension;my $proper_name;
    ($partner_id, $collection_code,$unit_of_work,$page_number,$role,$extension)=@_;
        
    #this section creates the proper name for the target that will be checked
    if($collection_code !~ m/ref/i){
        $proper_name= $partner_id."_".$collection_code.sprintf("%06d",$unit_of_work)."_"; #this is the base name for non-ref backmatter pages
        $proper_name= $proper_name.sprintf("%06d",$page_number)."_".$role.$extension;# typical non-ref book paginated page Partner_collection123456_123456_m.tif

    }else{
        $proper_name= $partner_id."_".$collection_code.$unit_of_work."_";#this is the basename for ref backmatter pages
        $proper_name= $proper_name.sprintf("%06d",$page_number)."_".$role.$extension;#this is the default typical ref book paginated page basename. example: Partner_Collection123_123456_m.tif

    }
        
    return($proper_name);
}

sub createBackMatterName{
    #About: creates a proper back-matter name
    #Input: ($partner_id, $collection_code,$unit_of_work,$page_number,$role,$extension)
    #Output: properly formatted target names
    #Usage: $output = createBackMatterName($partner_id, $collection_code,$unit_of_work,$page_number,$role,$extension);
    #Dependency: none
    
    my $partner_id;my $collection_code; my $unit_of_work; my $page_number; my $role, my $extension;
    my $proper_name;
    ($partner_id, $collection_code,$unit_of_work,$page_number,$role,$extension)=@_;
        
    #this section creates the proper name for the target that will be checked
    if($collection_code !~ m/ref/i){
        $proper_name= $partner_id."_".$collection_code.sprintf("%06d",$unit_of_work)."_bk"; #this is the base name for non-ref backmatter pages
        if($page_number < 10){#add a leading zero if less than 10
            $proper_name=$proper_name.sprintf("%02d",$page_number)."_".$role.$extension;# typical non-ref book paginated page Partner_collection123456_bk12
        }else{
            $proper_name=$proper_name.$page_number."_".$role.$extension;# typical non-ref book paginated page Partner_collection123456_bk12
        }
    }else{
        $proper_name= $partner_id."_".$collection_code.$unit_of_work."_bk";#this is the basename for ref backmatter pages
        if($page_number < 10){#add a leading zero if less than 10
            $proper_name=$proper_name.sprintf("%02d",$page_number)."_".$role.$extension;#this is the default typical ref book paginated page basename. example: Partner_Collection123_bk12
        }else{
            $proper_name=$proper_name.$page_number."_".$role.$extension;# typical ref book paginated page Partner_collection123456_bk12
        }
    }
        
    return($proper_name);
}

sub createFrontMatterName{
    #About: creates a proper front-matter name
    #Input: ($partner_id, $collection_code,$unit_of_work,$page_number,$role,$extension)
    #Output: properly formatted target names
    #Usage: $output = createBackMatterName($partner_id, $collection_code,$unit_of_work,$page_number,$role,$extension);
    #Dependency: none
    
    my $partner_id;my $collection_code; my $unit_of_work; my $page_number; my $role, my $extension;
    my $proper_name;
    ($partner_id, $collection_code,$unit_of_work,$page_number,$role,$extension)=@_;
        
    #this section creates the proper name for the target that will be checked
    if($collection_code !~ m/ref/i){
        $proper_name= $partner_id."_".$collection_code.sprintf("%06d",$unit_of_work)."_fr"; #this is the base name for non-ref backmatter pages
        if($page_number < 10){#add a leading zero if less than 10
            $proper_name=$proper_name.sprintf("%02d",$page_number)."_".$role.$extension;# typical non-ref book paginated page Partner_collection123456_bk12
        }else{
            $proper_name=$proper_name.$page_number."_".$role.$extension;# typical non-ref book paginated page Partner_collection123456_bk12
        }
    }else{
        $proper_name= $partner_id."_".$collection_code.$unit_of_work."_fr";#this is the basename for ref backmatter pages
        if($page_number < 10){#add a leading zero if less than 10
            $proper_name=$proper_name.sprintf("%02d",$page_number)."_".$role.$extension;#this is the default typical ref book paginated page basename. example: Partner_Collection123_bk12
        }else{
            $proper_name=$proper_name.$page_number."_".$role.$extension;# typical ref book paginated page Partner_collection123456_bk12
        }
    }
        
    return($proper_name);
}

sub showIndentList{
    #About: displays the contents of a list indented, one item per line
    #Input: a string or an array
    #Output: displays the contents on STDOUT as a list indented, one item per line
    #Usage: $output = showIndentList(@list);
    #Dependency: none
    foreach(@_){
        print "\n\t".$_;
    }
}

sub createTargetName{
    #About: creates a proper target name
    #Input: ($partner_id, $collection_code,$unit_of_work,'target',$role,$extension) where 'target' is the word target
    #Output: properly formatted target names
    #Usage: $output = createTargetName($partner_id, $collection_code,$unit_of_work,'target',$role,$extension);
    #Dependency: none
    
    my $partner_id;my $collection_code; my $unit_of_work; my $target_name; my $role, my $extension;
    ($partner_id, $collection_code,$unit_of_work,$target_name,$role,$extension)=@_;
        
    #this section creates the proper name for the target that will be checked
    if($collection_code !~ m/ref/i){#for long filenames such as: partner_collection123456_target_m.tif
        $proper_target_name=$partner_id."_".$collection_code.sprintf("%06d",$uow)."_".$target_name."_".$role.$extension; # with role
        $proper_target_name2=$partner_id."_".$collection_code.sprintf("%06d",$uow)."_".$target_name.$extension; #without role
              
    }else{#for long filenames such as: partner_collection123_target_m.tif
        $proper_target_name=$partner_id."_".$collection_code.$uow."_".$target_name."_".$role.$extension;
        $proper_target_name2=$partner_id."_".$collection_code.$uow."_".$target_name.$extension;
    }
        
    return($proper_target_name,$proper_target_name2);
}

sub askPartnerID{
    #About: asks the user for a ParnerID
    #Input: STDIN input
    #Output: user's input
    #Usage: $output = askPartnerID();
    #Dependency: none
    my $partner_id;
    print "\nWhat is the Partner ID?\n";
    $partner_id=<STDIN>;
    $partner_id=~s/(\s)+//g;
    return $partner_id;
}

sub askCollectionCode{
    #About: asks the user for a Collection Code
    #Input: STDIN input
    #Output: user's input
    #Usage: $output = askCollectionCode();
    #Dependency: none
    my $collection_code;
    print "\nwhat is the collection code?\n";
    $collection_code=<STDIN>;
    $collection_code=~s/(\s)+//g;
    return $collection_code;
}

sub askUOW{
    #About: asks the user for a Unit of Work (UOW)
    #Input: STDIN input
    #Output: user's input
    #Usage: $output = askUOW();
    #Dependency: none
    my $uow;
    print "\nwhat is the unit of work? (number)\n";
    $uow=<STDIN>;#
    $uow=~s/(\s)+//g;
    $uow=$uow+0;
    return $uow;
}

sub askMinPageID{
    #About: asks the user for a Minimum page number for the paginated pages
    #Input: STDIN input
    #Output: user's input
    #Usage: $output = askMinPageID();
    #Dependency: none
    my $MIN_page_id;
    print "\nwhat is the minimum page id number? (number)\n";
    $MIN_page_id=<STDIN>;#
    $MIN_page_id=~s/(\s)+//g;
    $MIN_page_id=$MIN_page_id+0;
    return $MIN_page_id;
}
sub askMaxPageID{
    #About: asks the user for a Maximum page number for the paginated pages
    #Input: STDIN input
    #Output: user's input
    #Usage: $output = askMaxPageID();
    #Dependency: none
    my $MAX_page_id;
    print "\nwhat is the maximum page id number? (number)\n";
    $MAX_page_id=<STDIN>;#
    $MAX_page_id=~s/(\s)+//g;
    $MAX_page_id=$MAX_page_id+0;
    return $MAX_page_id;
}
sub askMaxBackMatter{
    #About: asks the user for a Maximum page number for the Back Matter pages
    #Input: STDIN input
    #Output: user's input
    #Usage: $output = askMaxBackMatter();
    #Dependency: none  
    my $MAX_back_matter;
    print "\nHow many pages of back matter are there? (number)\n";
    $MAX_back_matter=<STDIN>;#
    $MAX_back_matter=~s/(\s)+//g;
    $MAX_back_matter=$MAX_back_matter+0;   
    return $MAX_back_matter;
}

sub askMaxFrontMatter{
    #About: asks the user for a Maximum page number for the Front Matter pages
    #Input: STDIN input
    #Output: user's input
    #Usage: $output = askMaxFrontMatter();
    #Dependency: none
    my $MAX_front_matter;
    print "\nHow many pages of front matter are there? (number)\n";
    $MAX_front_matter=<STDIN>;#
    $MAX_front_matter=~s/(\s)+//g;
    $MAX_front_matter=$MAX_front_matter+0;
    return $MAX_front_matter;
}
sub askExtension{
    #About: asks the user for the extension
    #Input: STDIN input
    #Output: user's input
    #Usage: $output = askExtension();
    #Dependency: none
    my $extension;
    print "\nWhat is the extension? (examples: .tif .jpg)\n";
    $extension=<STDIN>;	
    $extension=~s/(\s)+//g;
    return $extension;
}

sub askTarget{
    #About: asks the user if there is a target
    #Input: STDIN input
    #Output: user's input
    #Usage: $output = askTarget();
    #Dependency: none
    my $target;
    print "\nIs there a target? (y for yes, n for no)\n";
    $target=<STDIN>;	
    $target=~s/(\s)+//g;
    return $target;
}

sub checkMasterFileSize{
    #About: Checks master and derivative file sizes. Checks that the derivative file is smaller than the master file (cropped). Checks that the master and deriv files are not empty.
    #Input: full path to the properly named master file, full path to the properly named derivative file
    #Output: pass or fail message explaining what went wrong
    #Usage: $output = checkMasterFileSize($path_to_master,$path_to_deriv)
    #Dependency: none
    
    my $master; my $deriv; my $SIZE_MASTER; my $SIZE_DERIV; my $message;
    $master=shift; #first argument is the masterfile
    $deriv=shift;
    
    
    #---get file sizes
    $SIZE_MASTER=(-s "$CHECK_FOLDER/$master");
    $SIZE_DERIV=(-s "$CHECK_FOLDER/$deriv");
    
    #master file size
    if($SIZE_MASTER==0){  
        $message = 'fail, empty file';
        
    }elsif($SIZE_MASTER<$SIZE_DERIV){
        $message = 'fail, master file smaller than derivative file';
        
    }elsif($SIZE_MASTER==$SIZE_DERIV){
        $message = 'fail, derivative & master have same size';
        
    }else{
        $message = 'pass legacy master size';      
    }
    
    return $message;
}

sub checkDerivFileSize{
    #About: Checks master and derivative file sizes. Checks that the derivative file is smaller than the master file (cropped). Checks that the master and deriv files are not empty.
    #Input: full path to the properly named master file, full path to the properly named derivative file
    #Output: pass or fail message explaining what went wrong
    #Usage: $output = checkDerivFileSize($path_to_master,$path_to_deriv)
    #Dependency: none
    
    my $master; my $deriv; my $SIZE_MASTER; my $SIZE_DERIV; my $message;
    $master=shift; #first argument is the masterfile
    $deriv=shift;
    
    
    #---get file sizes
    $SIZE_MASTER=(-s "$CHECK_FOLDER/$master");
    $SIZE_DERIV=(-s "$CHECK_FOLDER/$deriv");
    
    #deriv file size
        if($SIZE_DERIV==0){# empty file
			 $message='fail, empty file';

		}elsif($SIZE_DERIV>$SIZE_MASTER){
			 $message='fail, derivative file larger than master file';

		}elsif($SIZE_DERIV==$SIZE_MASTER){
             $message='fail, derivative & master have same size';
                
        }else{
			 $message='pass legacy deriv size';

		}	
    
    return $message;
}

sub getVisibleFiles{
    #About: returns a list of filenames that are not hidden files
    #Input: full path to the directory whose contents are to be listed
    #Output: list of filenames
    #Usage: $output = getVisibleFiles(Input)
    #Dependency: none
    
    my $directory_path; my @files;
    $directory_path = shift;
    #get non-hidden filenames
    opendir($DH, $directory_path) || die "can't open $directory_path $!";
        @files = grep {!/^(\.)+/ && -f "$directory_path/$_"} readdir($DH); # all files that not hidden
    closedir $DH;
    return @files;
}

sub getVisibleSubfolders{
    #About: returns a list of subdirectory names
    #Input: full path to the directory whose contents are to be listed
    #Output: list of subdirectories inside the directory being checked
    #Usage: $output = getSubfolders(Input)
    #Dependency: none
    
    my @subfolders; my $directory_path;
    $directory_path = shift;
    #get all subfolder names
    opendir($DH, $directory_path) || die "can't open $directory_path; $!";
        @subfolders = grep {!/^(\.)+/ &&  -d "$directory_path/$_"} readdir($DH); # all non-hidden folders
    closedir $DH;
    return @subfolders;
}

sub getHiddenSubfolders{
    #About: returns a list of hidden subdirectory names
    #Input: full path to the directory whose contents are to be listed
    #Output: list of subdirectories inside the directory being checked
    #Usage: $output = getHiddenSubfolders(Input)
    #Dependency: none
    
    my @hidden_subfolders; my $directory_path;
    $directory_path = shift;
    #get all subfolder names
    opendir($DH, $directory_path) || die "can't open $directory_path; $!";
        @hidden_subfolders = grep {!/^(\.)+$/ && /^(\.)+/ && -d "$directory_path/$_"} readdir($DH); # all hidden folders 
    closedir $DH;
    return @hidden_subfolders;
}

sub getHiddenFiles{
    #About: returns a list of subdirectory names
    #Input: full path to the directory whose contents are to be listed
    #Output: list of subdirectories inside the directory being checked
    #Usage: $output = getSubfolders(Input)
    #Dependency: none
    
    my @hiddenfiles; my $directory_path;          
    $directory_path = shift;      
    #get all hidden filenames
    opendir($DH, $directory_path) || die "can't open $directory_path $!";
        @hiddenfiles = grep {!/^(\.)+$/ && /^(\.)+/ && -f "$directory_path/$_"} readdir($DH); # all hidden files except (. ..) etc
    closedir $DH;
    
    return @hiddenfiles;
}

sub max{
    #About: returns the maximum number given two numners as input, else returns a space character
    #Input: list of numbers; example: @numbers =(1,2,3);
    #Output: number with the maximum value; example: 3
    #Usage: $output = max(Input)
    #Dependency: none
    
    my $num1; my $num2; my $result;
    ($num1,$num2)= @_;
    
    #make sure that the inputs are digits, return a space character if not digits
    if($num1 =~ m/\D/i){
    return ' ';
    }
    if($num2 =~ m/\D/i){
    return ' ';
    }
    
    #if empty character return a space character
    if($num1 eq ''){
    return ' ';
    }
    if($num2 eq ''){
    return ' ';
    }
    
    #compare the numbers
    $result= $num1 <=> $num2;
    if ($result == -1){ #num1 is less than $num2
        return $num2;
    }elsif($result == 1){#num1 is greater than $num2
        return $num1;
    }else{# $num1 is equal to $num2
        return $num1;
    }
   
}

sub min{
    #About: returns the minimum number given two numners as input, else returns a space character
    #Input: list of numbers; example: @numbers =(1,2,3);
    #Output: number with the minimum value; example: 1
    #Usage: $output = min(Input)
    #Dependency: none
    
    my $num1; my $num2; my $result;
    ($num1,$num2)= @_;
    
    #make sure that the inputs are digits, return a space character if not digits
    if($num1 =~ m/\D/i){
    return ' ';
    }
    if($num2 =~ m/\D/i){
    return ' ';
    }
    
    #if empty character return a space character
    if($num1 eq ''){
    return ' ';
    }
    if($num2 eq ''){
    return ' ';
    }
    
    #compare the numbers
    $result= $num1 <=> $num2;
    if ($result == -1){ # $num1 is less than $num2
        return $num1;
    }elsif($result == 1){ # $num1 is greater than num2
        return $num2;
    }else{ # $num1 is equal to $num2
        return $num2;
    }
   
}

sub getPartnerID{
    #About: extracts the PartnerID from the PartID
    #Input: Partner_collection123456
    #Output: Partner
    #Usage: $output = getPartnerID($input)
    #Dependency: getPartID()
    
    my $PartID; my $CollectionCode;
    $PartID = shift;
    $PartID =~ m/^(\w|\W)+_/;        
    $PartnerID = substr($PartID,$-[0],$+[0]-$-[0]);#get the matched section
    $PartnerID =~ s/(_|-)+$//;
    return $PartnerID;
}

sub getCollectionCode{ # Collection123456
    #About: extracts the CollectionCode from the PartID
    #Input: Partner_collection123456
    #Output: collection
    #Usage: $output = getCollectionCode($input)
    #Dependency: getPartID()
    
    my $PartID; my $CollectionCode;
    $PartID = shift;
    $PartID =~ m/^(\w|\W)+_/;  
    $CollectionCode = substr($PartID,$+[0]);#get the postmatched section 
    $CollectionCode =~ s/(_|-)+$//;
    return $CollectionCode;
}

sub getPageID{
    #About: extracts the paginated page from a filename without an extension, without a role, without the oversized _xx or _xx_yy character sequence if applicable. Otherwise returns a space character.
    #Input: string_123456
    #Output: 123456
    #Usage: $output = getPageID($input)
    #Dependency: removeRole(); removeExtension();
    
    my $key2; my $PageID;
    $key2 = shift;
    if($key2=~m/(_|-)+(\d)+$/){
        #print "PageID matched";
        $PageID=substr($key2, $-[0], $+[0]-$-[0]); #extract matched substring
        $PageID=~s/^(_|-)+//;
        $PageID=~s/(_|-)+$//;
        $PageID=$PageID+0;
        $key2=~s/(_|-)(\d)+$//;
        $PageID=$PageID+0;
        return $PageID;
    }else{
        return ' ';
    }
    
}

sub removePageID{
    #About: removes the paginated page from a filename without an extension, without a role, without the oversized _xx or _xx_yy character sequence if applicable. Otherwise returns a space character.
    #Input: string_123456
    #Output: string
    #Usage: $output = getPageID($input)
    #Dependency: removeRole(); removeExtension();
    
    my $key2;
    $key2 = shift;
    $key2=~s/(_|-)(\d)+$//;
    return $key2;
}

sub getFrontMatter{
    #About: extracts the front matter page number from the filename when possible
    #Input: $string filename without extension and without role.
    #$Output: $string containing the front matter page number or returns a space character if filename is not front matter.
    #Usage: $output = getFrontMatter($input)
    #Dependency: removeRole(); removeExtension();
    my $key3; my $key2; my $front_matter;
    $key2 = shift;
    $key3 = $key2;
    
    if($key3=~m/(_|-)fr(\d)+$/i){
            $front_matter=substr($key3, $-[0], $+[0]-$-[0]); #get the matched sequence
        if($front_matter=~m/(\d)+$/){
			$front_matter=substr($front_matter, $-[0], $+[0]-$-[0]); #get the matched sequence       
			$front_matter=$front_matter+0;
            return $front_matter;
        }
    }else{
        return ' ';
    }
}

sub removeFrontMatter{
    #About: removes the front matter page number(_fr00 or -fr00) from the filename when possible
    #Input: $string filename without extension and without role.
    #$Output: $string without the front matter page number
    #Usage: $output = removeFrontMatter($input)
    #Dependency: removeRole(); removeExtension();
    my $string;
    $string = shift;

    $string =~ s/(_|-)+$//;
    $string =~ s/(_|-)fr(\d)+$//i;
    return $string;
}


sub getBackMatter{
    #About: extracts the back matter page number from the filename when possible
    #Input: $string filename without extension and without role.
    #$Output: $string containing the back matter page number or returns a space character if filename is not back matter.
    #Usage: $output = getBackMatter($input)
    #Dependency: removeRole(); removeExtension();
    my $key3; my $key2; my $back_matter;
    $key2 = shift;
    $key3 = $key2;
    
    if($key3=~m/(_|-)bk(\d)+$/i){
        $back_matter=substr($key3, $-[0], $+[0]-$-[0]); #get the matched sequence
        if($back_matter=~m/(\d)+$/){
			$back_matter=substr($back_matter, $-[0], $+[0]-$-[0]); #get the matched sequence   
			$back_matter=$back_matter+0;
            return $back_matter;
        }
    }else{
        return ' ';
    }
}

sub removeBackMatter{
    #About: removes the back matter page number(_bk00 or -bk00) from the filename when possible
    #Input: $string filename without extension, without role, without _xx and without _xx_yy oversized strings.
    #Output: $string without the back matter page number
    #Usage: $output = removeBackMatter($input)
    #Dependency: removeRole(); removeExtension();
    my $string;
    $string = shift;

    $string =~ s/(_|-)+$//;
    $string =~ s/(_|-)bk(\d)+$//i;
    return $string;
}

sub removeOversizedXXYY{
    #TODO: getOversizedXXYY
    #About: removes the _xx_yy sequence from the oversized file's filename if applicable, otherwise returns a space character
    #Input: $string filename without extension, without role
    #Output: $string filename without _xx_yy sequence
    #Usage: $output = removeOversizedXXYY($input)
    #Dependency: removeRole(); removeExtension();
    my $key2; my $key3;
    $key2=shift;
    $key3=$key2;
    
    if($key3=~m/(\d)+(_|-)(\d)+(_|-)(\d)+(_|-)(\d)+$/){#oversized xx yy file name
		$key2=~s/(_|-)(\d)+$//; #removes _yy
		$key2=~s/(_|-)(\d)+$//; #removes _xx
        return $key2;
    }else{
        return ' ';
    }  
}

sub removeOversizedXX{
    #TODO: getOversizedXX
    #About: removes the _xx sequence from the oversized file's filename if applicable, otherwise returns a space character
    #Input: $string filename without extension, without role
    #Output: $string filename without _xx sequence
    #Usage: $output = removeOversizedXX($input)
    #Dependency: removeRole(); removeExtension();
    my $key2; my $key3;
    $key2=shift;
    $key3=$key2;
    
    if($key3=~m/(\d)+(_|-)(\d)+(_|-)(\d)+$/){#oversized xx file name
		$key2=~s/(_|-)(\d)+$//; #removes _xx
        return $key2;
    }else{
        return ' ';
    }  
}


sub getPartID{
    #About: creates a PartID from the filename
    #Input: $string filename without extension and without role. examples: Partner_Collection123456_123456_12_12 or Partner_Collection123456_123456_12 or Partner_Collection123456_123456
    #$Output: $string containing the PartID example: Partner_Collection123456
    #Usage: $output = getPartID($input)
    #Dependencies: removeOversizedXXYY(); removeOversizedXX(); removePageID();
    my $key2; my $key3; my $PartID; my $back_matter; my $front_matter;
    $key2=shift;
    	$key3=$key2;
	#undef($front_matter); undef($back_matter);
    
	if($key3=~m/(\d)+(_|-)(\d)+(_|-)(\d)+(_|-)(\d)+$/){#oversized xx yy file name
        
        $key2=removeOversizedXXYY($key2);
		$PartID=$key2;
		#$PartID=~s/(_|-)(\d)+$//; #removes page number
        $PartID = removePageID($PartID);#removes page number
		$PartID=~s/(\d)+$//;#removes UOW number
	}
    
	elsif($key3=~m/(\d)+(_|-)(\d)+(_|-)(\d)+$/){#oversized xx file name
		$key2=removeOversizedXX($key2);
		$PartID=$key2;
		#$PartID=~s/(_|-)(\d)+$//; #removes page number
        $PartID = removePageID($PartID);#removes page number
		$PartID=~s/(\d)+$//; #removes UOW number
        
	}
	elsif($key3=~m/(\d)+(_|-)(\d)+$/){#regular file name

		$PartID=$key2;
		#$PartID=~s/(_|-)(\d)+$//; #removes page number
        $PartID = removePageID($PartID);#removes page number
		$PartID=~s/(\d)+$//;#removes UOW number

	}

	elsif($key3=~m/(\d)+(_|-)fr(\d)+$/){#front matter file name

			$key2=~s/(_|-)fr(\d)+$//; #removes _fr and page number
			$key2=~s/(\d)+$//;#removes UOW number
			$PartID=$key2;

	}elsif($key3=~m/(\d)+(_|-)bk(\d)+$/){#back matter file name

			$key2=~s/(_|-)bk(\d)+$//;#removes _bk and page number
			$key2=~s/(\d)+$//;#removes UOW number
			$PartID=$key2;
            
	}
    return $PartID;
}

 sub getRole{
    #About: extracts the role of the file. For example _d for derivative, _m for master
    #Input: $string filename without extension
    #$Output: $string containing _m or _d etc.
    #Usage: $output = getRole($input)   
    
    my $string; my $role;
    $string =shift;
    if($string=~m/(_|-)(m|d)$/){ #valid roles to seek
    $role=substr($string, $-[0], $+[0]-$-[0]);
    }
    
    return $role;
}

sub removeRole{
    #About: removes the role of the file. For example: roles are _d for derivative, _m for master etc. abc_d --> abc; 
    #Input: $string filename without extension
    #$Output: $string without _m or _d
    #Usage: $output = removeRole($input)   
    my $string;
    $string = shift;
    $string =~ s/(_|-)+$//;
    $string =~ s/(_|-)(m|d)$//;
    
    return $string;
}

sub removeExtension{
    #About: removes the characters after a "." character, including the dot: for example: abc.txt --> abc
    #Input: $string
    #$Output: $string
    #Usage: $output = removeExtension($input)
    my $string;
    $string = shift;
    $string =~ s/\.(\w)+$//;
    return $string;
}  

sub getExtension{
    #About: extracts the characters after a "." character, including the dot: for example: abc.txt --> .txt
    #Input: abc.tiff
    #$Output: .tiff
    #Usage: $output = getExtension($input)
    my $string; my $key;
    $key = shift;
    if($key=~m/\.(\w|\W)+$/){
			$string=substr($key, $-[0], $+[0]-$-[0]); # extract the matched sequence for the extension
		}
    return $string;
}  


#this format uses global variables. Produces the "Summary of Features" report shown to the user which indicates what the script was able to do automatically
format SUMMARY_OF_FEATURES =
@<<<<<<<<<<<<<<<<<<<<
'SUMMARY OF FEATURES'
@|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
' ----------------------------------------------------------------'
@<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<@<<<<<<<<<<<<<<<<<<<<<@>>
'| <partner id>  (there may not be one): ', $partner_id            ,' |'
@<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<@<<<<<<<<<<<<<<<<<<<<<@>>
'| <collection code> : ', $collection_code      ,' |'
@<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<@<<<<<<<<<<<<<<<<<<<<<@>>
'| <unit of work>    : ', $uow                  ,' |'
@<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<@<<<<<<<<<<<<<<<<<<<<<@>>
'| <page id> starts  : ', $MIN_page_id          ,' |'
@<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<@<<<<<<<<<<<<<<<<<<<<<@>>
'| <page id> ends    : ', $MAX_page_id          ,' |'
@<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<@<<<<<<<<<<<<<<<<<<<<<@>>
'| front matter pages  : ', $MAX_front_matter     ,' |'
@<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<@<<<<<<<<<<<<<<<<<<<<<@>>
'| back matter pages   : ', $MAX_back_matter      ,' |'
@<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<@<<<<<<<<<<<<<<<<<<<<<@>>
'| extension           : ', $extension            ,' |'
@<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<@<<<<<<<<<<<<<<<<<<<<<@>>
'| Is there a target?  : ', $target               ,' |'
@<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<@<<<<<<<<<<<<<<<<<<<<<@>>
'| More than 1 <collection code>? : ', $MoreCollectionCodes   ,' |'
@|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
'|                                                                |'
@<<<<<<<<<<<<<<<<<<<<<<<<<<<<@||||||||||||||||||||||||||||@>>>>>>>
'| Average size of derivs: ', $AVG_SIZE_DERIVS,' bytes |'
@<<<<<<<<<<<<<<<<<<<<<<<<<<<<@||||||||||||||||||||||||||||@>>>>>>>
'| Average size of master: ', $AVG_SIZE_MASTER,' bytes |'
@|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
' ----------------------------------------------------------------'
.


sub showHelp{
    print "\nTo use this program: type its path into a terminal and then";
    print "\ntype the path of the folder you want to check ";
    print "\nSample: /Path/to/script/Program_Name.pl /Path/to/some/folder\n\n";
}

sub showVersion{
    print "\nVersion 1.3 (NonBatch Hyphen)\n\n";	
}

sub fail{
#purpose: display an ASCII FAIL graphic on the command line, indicating the beginning of the report on what failed. 
#input: void
#output: prints the fail graphic to STDOUT
#sample usage: fail();

	my(@fail);
	push(@fail,' =========================================== ');
	push(@fail,'|                                           |');
	push(@fail,'|      *****    ***     *****     *         |');
	push(@fail,'|      *       ** **      *       *         |');
	push(@fail,'|      ***     *****      *       *         |');
	push(@fail,'|      *       *   *      *       *         |');
	push(@fail,'|      *       *   *    *****     *****     |');
	push(@fail,'|                                           |');
	push(@fail,' =========================================== ');
	
	foreach(@fail){
		$_=~s/\*/#/g;# makes the characters look bolder
	}
	print "\n";
	
	foreach(@fail){
		print $_."\n";#prints to STDOUT
	}
	
}

sub endfail{
#purpose: display an ASCII FAIL graphic on the command line, indicating the end of the report on what failed. 
#input: void
#output: prints the fail graphic to STDOUT
#sample usage: endfail();

	my(@fail);
	push(@fail,' =========================================== ');
	push(@fail,'|                                           |');
	push(@fail,'|      -  *****    ***     *****     *      |');
	push(@fail,'|     -   *       ** **      *       *      |');
	push(@fail,'|    -    ***     *****      *       *      |');
	push(@fail,'|   -     *       *   *      *       *      |');
	push(@fail,'|  -      *       *   *    *****     *****  |');
	push(@fail,'|                                           |');
	push(@fail,' =========================================== ');
	
	foreach(@fail){
		$_=~s/\*/#/g;# makes the characters look bolder
        $_=~s/-/#/g;# makes the characters look bolder
	}
	print "\n";
	
	foreach(@fail){
		print $_."\n";#prints to STDOUT
	}
	
}

sub pass{
#purpose: display an ASCII PASS graphic on the command line
#input: void
#output: prints the PASS graphic to STDOUT
#sample usage: pass();
	my(@pass);
	push(@pass,' ==================================== ');
	push(@pass,'|                                    |');
	push(@pass,'|  ****     ***     ****     ****    |');
	push(@pass,'|  *  **   ** **   **       **       |');
	push(@pass,'|  ****    *****    ****     ****    |');
	push(@pass,'|  *       *   *       **       **   |');
	push(@pass,'|  *       *   *    ****     ****    |');
	push(@pass,'|                                    |');
	push(@pass,' ==================================== ');
	
	foreach(@pass){
		$_=~s/\*/#/g;# makes the characters look bolder
	}
	print "\n";
	
	foreach(@pass){
		print $_."\n";#prints to STDOUT
	}	
}