#!/usr/bin/perl
=pod
Copyright (c) 2015 Wilfredo Rosario

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


my($CHECK_FOLDER, @files,%fhash,%fpartidhash,%fpartidhash_pop,$CollectionCode,$PartnerID,$unit_of_work);

	if(scalar(@ARGV) == 1){
		$CHECK_FOLDER=$ARGV[0];
		if(($CHECK_FOLDER=~m/^(\s)*(-)+h/i)or($CHECK_FOLDER=~m/^(\s)*\/\?$/i)){
			print"\nTo use this program: type its path into a terminal and then \ntype the path of the folder you want to check \nSample: /Path/to/script/Program_Name.pl /Path/to/some/folder\n\n";	
			exit;
		}else{
		
			opendir($DH, $CHECK_FOLDER) || die "can't open $CHECK_FOLDER $!";
			@files = grep {!/^(\.)+/ && -f "$CHECK_FOLDER/$_"} readdir($DH); # all files that not hidden
			closedir $DH;
		}
	}
	else{
		if($] >= 5.011){
			opendir($DH, $FindBin::Bin) || die "can't open $FindBin::Bin $!";
			$CHECK_FOLDER=$FindBin::Bin;
			@files = grep {!/^(\.)+/ && -f "$CHECK_FOLDER/$_"} readdir($DH); # all files that not hidden
			closedir $DH;
		}else{
			die "You must enter a folder path\n";
		}
	}

	print "\nHello,\nYou are in \n$CHECK_FOLDER/\n\n";


for(my $i=0;$i<=scalar(@files);$i++){
	$fhash{$files[$i]}='failure of name: ';#files fail by default
}

#=================Start of Automatic Assignation of Variables===================

for my $key(keys %fPartIDhash_pop){
	$fPartIDhash_pop{$key}=undef;
}
undef($key);
for my $key(keys %fPartIDhash){
	$fPartIDhash{$key}=undef;
}
undef($key);


for my $key(keys %fhash){
my($key2, $PageID, $uow,$ext,$front_matter,$back_matter,$is_d,$PartID);
	undef($key2);undef($PageID);undef($uow);undef($ext);undef($front_matter);undef($back_matter);

	$key2=$key;
	$key2=~s/\.(\w)+$//;

	undef($is_d);
	if($key2=~m/(_|-)(m|d)$/){
		$is_d=substr($key2, $-[0], $+[0]-$-[0]);
		$is_d=~s/(_)+//;
		$key2=~s/(_m|_d)$//;

	}
	undef($front_matter); undef($back_matter);
	if($key=~m/(\d)+(_|-)(\d){6}(_|-)(\w){1}\.(\w)+$/){#regular file name

		$PartID=$key2;
		$PartID=~s/_(\d){6}$//;
		$PartID=~s/(\d){6}$//;

	}elsif($key=~m/(\d){6}(_|-)(\d){6}(_|-)(\d){2}(_|-)(\w){1}\.(\w)+$/){#oversized xx file name

		$key2=~s/_(\d){2}$//;
		$PartID=$key2;
		$PartID=~s/_(\d){6}$//;
		$PartID=~s/(\d){6}$//;

	}elsif($key=~m/(\d){6}(_|-)(\d){6}(_|-)(\d){2}(_|-)(\d){2}(_|-)(\w){1}\.(\w)+$/){#oversized xx yy file name

		$key2=~s/_(\d){2}$//;
		$key2=~s/(\d){2}$//;
		$PartID=$key2;
		$PartID=~s/_(\d){6}$//;
		$PartID=~s/(\d){6}$//;

	}elsif($key=~m/(\d){6}(_|-)fr(\d){2}(_|-)(\w){1}\.(\w)+$/){#front matter file name

		if($key2=~m/(\d){2}$/){
			$front_matter=substr($key2, $-[0], $+[0]-$-[0]);
			$front_matter=$front_matter+0;
			$key2=~s/(_|-)(fr){1}(\d){2}$//;
			$key2=~s/(\d){6}$//;
			$PartID=$key2;

		}

	}elsif($key=~m/(\d){6}(_|-)bk(\d){2}(_|-)(\w){1}\.(\w)+$/){#back matter file name

		if($key2=~m/(\d){2}$/){
			$back_matter=substr($key2, $-[0], $+[0]-$-[0]);
			$back_matter=$back_matter+0;
			$key2=~s/(_|-)(bk){1}(\d){2}$//;
			$key2=~s/(\d){6}$//;
			$PartID=$key2;

		}
	}


	if ($PartID !~ m/^(\s)*$/){

		$fPartIDhash{'MAXfront'.$PartID}=$front_matter unless (($fPartIDhash{'MAXfront'.$PartID}+0)>$front_matter);

		$fPartIDhash{'MAXback'.$PartID}=$back_matter unless (($fPartIDhash{'MAXback'.$PartID}+0)>$back_matter);

		if($front_matter=~m/^(\s)*$/){
			#PageID
			if($key2=~m/(\d){6}$/){
				$PageID=substr($key2, $-[0], $+[0]-$-[0]);
				$PageID=$PageID+0;
				$key2=~s/\_(\d){6}$//;
				if(($fPartIDhash{'MAXpageID'.$PartID} =~m/^(\s)*$/)||($fPartIDhash{'MAXpageID'.$PartID} eq undef)){
					$fPartIDhash{'MAXpageID'.$PartID}=$PageID+0;
				}
				$fPartIDhash{'MAXpageID'.$PartID}=$PageID unless ((($fPartIDhash{'MAXpageID'.$PartID}+0)>=$PageID)||($PageID eq undef)||($PageID=~m/^(\s)*$/));
				if(($fPartIDhash{'MINpageID'.$PartID} =~m/^(\s)*$/)||($fPartIDhash{'MINpageID'.$PartID} eq undef)){
					$fPartIDhash{'MINpageID'.$PartID}=$PageID+0;
				}
				$fPartIDhash{'MINpageID'.$PartID}=$PageID unless ((($fPartIDhash{'MINpageID'.$PartID}+0)<=$PageID)||($PageID eq undef)||($PageID=~m/^(\s)*$/));
			}
		}
		#unit of work
		if($key2=~m/(\d){6}$/){
			$unit_of_work=substr($key2, $-[0], $+[0]-$-[0]);
			$unit_of_work=$unit_of_work+0;
			$key2=~s/(\d){6}$//;
				
			if(($fPartIDhash{'MINuow'.$PartID}=~m/^(\s)*$/)||($fPartIDhash{'MINuow'.$PartID}eq undef)){
				$fPartIDhash{'MINuow'.$PartID}=$unit_of_work;
			}
			$fPartIDhash{'MINuow'.$PartID}=$unit_of_work unless ($fPartIDhash{'MINuow'.$PartID}<$unit_of_work);
			if(($fPartIDhash{'MAXuow'.$PartID}=~m/^(\s)*$/)||($fPartIDhash{'MAXuow'.$PartID} eq undef)){
				$fPartIDhash{'MAXuow'.$PartID}=$unit_of_work
			}
			$fPartIDhash{'MAXuow'.$PartID}=$unit_of_work unless ($fPartIDhash{'MAXuow'.$PartID}>$unit_of_work);
			$fPartIDhash{'MINuow'.$PartID}=$fPartIDhash{'MINuow'.$PartID}+0;
			$fPartIDhash{'MAXuow'.$PartID}=$fPartIDhash{'MAXuow'.$PartID}+0;
			if($fPartIDhash{'MAXuow'.$PartID}==$fPartIDhash{'MINuow'.$PartID}){
				$fPartIDhash{'uow'.$PartID}=$fPartIDhash{'MINuow'.$PartID};
			}
		
		}
		
		#file sizes
		if($is_d=~m/d/i){#max size of d
			$fPartIDhash{'d_count'.$PartID}=$fPartIDhash{'d_count'.$PartID}+1;
			#regular d size
			$sized=(-s "$CHECK_FOLDER/$key");# regular size d file;
			if(($fPartIDhash{'sized'.$PartID}=~m/^(\s)*$/)||($fPartIDhash{'sized'.$PartID}eq undef)){
				$fPartIDhash{'sized'.$PartID}=$sized;
			}else{
				$fPartIDhash{'sized'.$PartID}=int(($fPartIDhash{'sized'.$PartID}+$sized));
			}
			

		}elsif($is_d=~m/m/i){#min size of m
			$fPartIDhash{'m_count'.$PartID}=$fPartIDhash{'m_count'.$PartID}+1;
			#regular m size
			$sizem=(-s "$CHECK_FOLDER/$key");# average size d file;
			if(($fPartIDhash{'sizem'.$PartID}=~m/^(\s)*$/)||($fPartIDhash{'sized'.$PartID}eq undef)){
				$fPartIDhash{'sizem'.$PartID}=$sizem;
			}else{
				$fPartIDhash{'sizem'.$PartID}=int(($fPartIDhash{'sizem'.$PartID}+$sizem));
			}

	
		}

		#extension
		if($key=~m/\.(\w|\W)+$/){
			$fPartIDhash{'ext'.$PartID}=substr($key, $-[0], $+[0]-$-[0]);
		}
		
		#popularity of PartID
		if(($fPartIDhash_pop{$PartID}=~m/^(\s)*$/)||($fPartIDhash_pop{$PartID}eq undef)){
			$fPartIDhash_pop{$PartID}=1;
		}
		$fPartIDhash_pop{$PartID}=$fPartIDhash_pop{$PartID}+1;
	

		$PartID=~m/^(\w|\W)+_/;
		$PartnerID=substr($PartID,$-[0],$+[0]-$-[0]);
		$PartnerID=~s/(_)+$//;
		$CollectionCode=substr($PartID,$+[0]);
		$CollectionCode=~s/(_)+$//;
		$fPartIDhash{'PartnerID'.$PartID}=$PartnerID;
		$fPartIDhash{'CollectionCode'.$PartID}=$CollectionCode;
	}
	
	#target file name
	if ($fPartIDhash{'target'.$PartID} !~ m/^(y|n)/i){
		$fPartIDhash{'target'.$PartID}='no';
	}
	if($key=~m/_target/i){
	$PartID=$key;
	$PartID=~s/(\d){6}_target_(\w|\W)*$//;
	undef($fPartIDhash{'target'.$PartID});
		$fPartIDhash{'target'.$PartID}='yes';
	}
	
	#environment of creation
	if ($fPartIDhash{'EOC'} !~ m/^(y|n)/i){
		$fPartIDhash{'EOC'}='no';
	}
	if($key=~m/eoc\.csv$/i){
	undef($fPartIDhash{'EOC'});
		$fPartIDhash{'EOC'}='yes';
		$fPartIDhash{$key}='pass EOC';
		$fhash{$key}='pass EOC';

	}
	
}

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
undef $key;
undef $value;
for$key(%fPartIDhash_pop){
	$value=$fPartIDhash_pop{$key};
	push(@popularity,"$value <= $key");
}
@popularity2=reverse(sort(@popularity));
$value='false';
$PreferredPartID='';
$popularity_count=0;
$popularity_count2=scalar @popularity;
while((($value!~m/^(\d)+$/) or ($PreferredPartID=~m/^(\s)*$/)) and ($popularity_count<=($popularity_count2))){
	$PreferredPartID2=shift(@popularity2);
	($value,$PreferredPartID3)=split(/ \<\= /g,$PreferredPartID2);
	if($value =~ m/^(\d)+$/){
	$PreferredPartID=$PreferredPartID3;
	}
	$popularity_count++;
}
undef(@popularity);
undef(@popularity2);

$partner_id=$fPartIDhash{'PartnerID'.$PreferredPartID};
$collection_code=$fPartIDhash{'CollectionCode'.$PreferredPartID};
$uow=$fPartIDhash{'uow'.$PreferredPartID};
$MIN_page_id=($fPartIDhash{'MINpageID'.$PreferredPartID})unless $fPartIDhash{'MINpageID'.$PreferredPartID}=~m/^(\s)*$/;
$MINCARDS=($MIN_page_id+0) unless $fPartIDhash{'MINpageID'.$PreferredPartID}=~m/^(\s)*$/;
$MAX_page_id=($fPartIDhash{'MAXpageID'.$PreferredPartID})unless $fPartIDhash{'MAXpageID'.$PreferredPartID}=~m/^(\s)*$/;
$MAXCARDS=($MAX_page_id+0) unless $fPartIDhash{'MAXpageID'.$PreferredPartID}=~m/^(\s)*$/;
$MAX_front_matter=($fPartIDhash{'MAXfront'.$PreferredPartID}+0);
$MAX_back_matter=($fPartIDhash{'MAXback'.$PreferredPartID}+0);
$extension=$fPartIDhash{'ext'.$PreferredPartID};
$EOC=$fPartIDhash{'EOC'};

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


write;
format STDOUT =
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
#=================End of Automatic Assignation of Variables===================


#=============================== start of questions ===================================
$redo='n';
while($redo=~m/^(\s)*n/i){
print"\n\n";
	while($partner_id =~ m/^(\s)*$/i){
		print "\nWhat is the Partner ID?\n";
		$partner_id=<>;
		$partner_id=~s/(\s)+//g;
	}
	while($collection_code =~ m/^(\s)*$/i){
		print "\nwhat is the collection code?\n";
		$collection_code=<>;
		$collection_code=~s/(\s)+//g;
	}
	while($uow !~ m/^(\d)+$/){
		print "\nwhat is the unit of work? (number)\n";
		$uow=<>;#
		$uow=~s/(\s)+//g;
		$uow=$uow+0;
	}

	while($MIN_page_id !~ m/^(\d)+$/){
		print "\nwhat is the minimum page id number? (number)\n";
		$MIN_page_id=<>;#
		$MIN_page_id=~s/(\s)+//g;
		$MIN_page_id=$MIN_page_id+0;
		$MINCARDS=$MIN_page_id+0;
	}
	while($MAX_page_id !~ m/^(\d)+$/){
		print "\nwhat is the maximum page id number? (number)\n";
		$MAX_page_id=<>;#
		$MAX_page_id=~s/(\s)+//g;
		$MAX_page_id=$MAX_page_id+0;
		$MAXCARDS=$MAX_page_id+0;
	}
	while($MAX_front_matter !~ m/^(\d)+$/){
		print "\nHow many pages of front matter are there? (number)\n";
		$MAX_front_matter=<>;#
		$MAX_front_matter=~s/(\s)+//g;
		$MAX_front_matter=$MAX_front_matter+0;
	}
	while($MAX_back_matter !~ m/^(\d)+$/){
		print "\nHow many pages of back matter are there? (number)\n";
		$MAX_back_matter=<>;#
		$MAX_back_matter=~s/(\s)+//g;
		$MAX_back_matter=$MAX_back_matter+0;
	}
	while($extension !~ m/^(\s)*\.(\w|\W)+$/i){
		print "\nWhat is the extension? (examples: .tif .jpg)\n";
		$extension=<>;	
		$extension=~s/(\s)+//g;
	}

	while($target !~ m/^(\s)*(y|n)/i){
		print "\nIs there a target? (y for yes, n for no)\n";
		$target=<>;	
		$target=~s/(\s)+//g;
	}

	print "For roles we will assume m for master and d for derivatives\n";
#	print "For the extension we will assume .tif for TIFF files\n";
#	$extension='.tif';

	print "\nSAMPLE FILE NAMES:\n";
	print $partner_id."_".$collection_code.sprintf("%06d",$uow)."_".sprintf("%06d",$MIN_page_id)."_m"."$extension\n";
	print $partner_id."_".$collection_code.sprintf("%06d",$uow)."_".sprintf("%06d",$MIN_page_id)."_d"."$extension\n";
	if($target =~ m/^(\s)*y/i){
		print $partner_id."_".$collection_code.sprintf("%06d",$uow)."_target_m"."$extension\n";
	}
	if($MAX_back_matter>0){
		print $partner_id."_".$collection_code.sprintf("%06d",$uow)."_bk".sprintf("%02d",$MAX_back_matter)."_m"."$extension\n";
		print $partner_id."_".$collection_code.sprintf("%06d",$uow)."_bk".sprintf("%02d",$MAX_back_matter)."_d"."$extension\n";
	}
	if($MAX_front_matter>0){
		print $partner_id."_".$collection_code.sprintf("%06d",$uow)."_fr".sprintf("%02d",$MAX_front_matter)."_m"."$extension\n";
		print $partner_id."_".$collection_code.sprintf("%06d",$uow)."_fr".sprintf("%02d",$MAX_front_matter)."_d"."$extension\n";
	}
	undef($redo_inner);
	while ($redo_inner !~ m/^(\s)*(y|n)/i){
		print "\nFile names ok? (y for yes, n for no. If not, you will be asked more questions.)\n";
		$redo_inner=<>;
		$redo=$redo_inner;
		if($redo_inner =~ m/^(\s)*n/i){
			undef($partner_id);undef($collection_code);undef($uow);undef($MIN_page_id);undef($MAX_page_id);undef($MAX_front_matter);undef($MAX_back_matter);
			undef($target);undef($extension);
		} 
	}
}

	if($target =~ m/^(\s)*y/i){
		$proper_target_name=$partner_id."_".$collection_code.sprintf("%06d",$uow).'_target_m'.$extension;
		if(exists $fhash{$proper_target_name}){
			$fhash{$proper_target_name}='pass';
		}
	}

#===================================== end of questions =================================

$SUM=$MAXCARDS+$MAX_front_matter+$MAX_back_matter;
for($j=$MINCARDS;$j<=$SUM;$j++){
if($collection_code !~ m/^(\s)*$/){#the collection code may or may not be there
	$basename= $partner_id."_".$collection_code.sprintf("%06d",$uow)."_".sprintf("%06d",$MIN_page_id);
}else{
	$basename= $partner_id.sprintf("%06d",$uow)."_".sprintf("%06d",$MIN_page_id);
}
	$go=1;
	if($MAX_front_matter>0){
		$basename=~s/_(\d){6}$//g;
		$basename=~s/(\_fr|\_bk){1}(\d){2}$//g;
		$basename=$basename.'_fr'.sprintf("%02d",$MAX_front_matter);
		$MAX_front_matter--;
		
		$go=0;
	}
	$go2=1;

	if(($MAX_back_matter>0) and ($go==1)){
		$basename=~s/_(\d){6}$//g;
		$basename=~s/(\_fr|\_bk){1}(\d){2}$//g;
		$basename=$basename.'_bk'.sprintf("%02d",$MAX_back_matter);
		$MAX_back_matter--;
		$go2=0;	
	}

	if(($MAX_back_matter<=0) and ($MAX_max_matter<=0) and ($go2==1)){
		if($MIN_page_id<$MAX_page_id){
			$basename=~s/_(\d){6}$//g;
			$basename=~s/(\_fr|\_bk){1}(\d){2}$//g;
			$basename=$basename.'_'.sprintf("%06d",$MIN_page_id);
			$MIN_page_id++;
		}
	}

	$master=$basename."_m".$extension;
	$deriv =$basename."_d".$extension;

	#check compliance of file sizes
    $SIZE_MASTER=(-s "$CHECK_FOLDER/$master");
    $SIZE_DERIV=(-s "$CHECK_FOLDER/$deriv");

        #master file size
	if(exists $fhash{$master}){
		if(($SIZE_MASTER==0)||($SIZE_MASTER<=$SIZE_DERIVS)){

			$fhash{$master}='failure of size, too small';	
		}else{
			$fhash{$master}='pass';
		}
		

	}
        #deriv file size
	if(exists $fhash{$deriv}){
		if($SIZE_DERIV>=$SIZE_MASTER){
			$fhash{$deriv}='failure of size, too large';
		}elsif($SIZE_DERIV==0){# empty file
			$fhash{$deriv}='failure of size, too small';

		}else{
			$fhash{$deriv}='pass';	
		}	
	}


	#used to determine the state of m and d as a set, i.e. if the files exist
	$file_exists=1;#true
	$err_str=undef;
	$fhash{$basename}='pass: exists _m';
	unless(exists $fhash{$master}){
		$err_str=$err_str."\t\t $master\n";
		$file_exists=0;
	}
	$fhash{$basename}='pass: exists _d';
	unless(exists $fhash{$deriv}){
		$err_str=$err_str."\t\t $deriv\n";
		$file_exists=0;
	}
	if($file_exists==0){
		$fhash{$basename}="fail, missing:\n$err_str";
	}
}

#Is the EOC included?
if($EOC =~ m/^(\s)*n/i){
	$fhash{'EOC'}='failure of EOC, missing EOC.csv';
}


for $key (keys %fhash){
	$value = $fhash{$key};
	unless($key=~m/^(\s)*$/){;
		if($value =~m/^fail, /){
			push(@Errors,$value);
		}elsif($value =~m/^failure/){
			push(@Errors,"$value  =>  $key\n");
		}
	}
}

if(scalar(@Errors)!=0){
	fail();
	foreach(sort @Errors){
		if($_ =~ m/^fail/ig){
			print "$_\n";
		}
	}
	fail();
}else{
	pass();
}

#==========================================================================================================================


sub fail{
	my(@fail);
	push(@fail,' ==================================== ');
	push(@fail,'|                                    |');
	push(@fail,'|  *****    ***     *****     *      |');
	push(@fail,'|  *       ** **      *       *      |');
	push(@fail,'|  ***     *****      *       *      |');
	push(@fail,'|  *       *   *      *       *      |');
	push(@fail,'|  *       *   *    *****     *****  |');
	push(@fail,'|                                    |');
	push(@fail,' ==================================== ');
	
	foreach(@fail){
		$_=~s/\*/#/g;
	}
	print "\n";
	
	foreach(@fail){
		print $_."\n";
	}
	
}

sub pass{
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
		$_=~s/\*/#/g;
	}
	print "\n";
	
	foreach(@pass){
		print $_."\n";
	}	
}