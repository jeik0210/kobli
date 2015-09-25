#!/usr/bin/perl

use strict;
use warnings;
use diagnostics;

use InstallAuth;
use CGI;
use IPC::Cmd;

#prefs-imges-upload.pl
use Image::Magick;
use POSIX qw(ceil);
use autouse 'Data::Dumper' => qw(Dumper);
#==

use Modern::Perl;


use C4::Context;
use C4::Output;

#members-password.pl
use C4::Members;

use C4::Templates;
use C4::Languages qw(getAllLanguages getTranslatedLanguages);

#members-password.pl
use C4::Members::Attributes qw(GetBorrowerAttributes);

#members-password.pl
use Digest::MD5 qw(md5_base64);







my $query = new CGI;
my $step  = $query->param('step');
my $op  = $query->param('op');
my $cuentaConfigurada   = $query->param('cuentaConfigurada ');


#prefs-imges-upload.pl
my $upload_dir = C4::Context->config('opachtdocs')."/prog/imgs/"; 
my $intra_dir = C4::Context->config('intrahtdocs')."/prog/imgs/"; 
#==

my $language = $query->param('language') ;
my ( $template, $loggedinuser, $cookie );

my $all_languages = getAllLanguages();







my $KohaOpacLanguage = $query->cookie("KohaOpacLanguage");

if ( defined($language) ) {
    #C4::Templates::setlanguagecookie( $query,  'es-ES', "1clickinstall.pl?step=1" );
} 
if ( $KohaOpacLanguage ne "es-ES" ){
	C4::Templates::setlanguagecookie( $query,  'es-ES', "1clickinstall.pl?step=1" );
}

( $template, $loggedinuser, $cookie ) = get_template_and_user(
    {
        template_name => "installer/1clickstep" . ( $step ? $step : 1 ) . ".tmpl",
        query         => $query,
        type          => "intranet",
        authnotrequired => 0,
        debug           => 1,
    }
);

#=============================
#   DDBB Conn
#=============================
my %info;
$info{'dbname'} = C4::Context->config("database");
$info{'dbms'} =
  (   C4::Context->config("db_scheme")
    ? C4::Context->config("db_scheme")
    : "mysql" );
$info{'hostname'} = C4::Context->config("hostname");
$info{'port'}     = C4::Context->config("port");
$info{'user'}     = C4::Context->config("user");
$info{'password'} = C4::Context->config("pass");
my $dbh = DBI->connect(
    "DBI:$info{dbms}:dbname=$info{dbname};host=$info{hostname}"
      . ( $info{port} ? ";port=$info{port}" : "" ),
    $info{'user'}, $info{'password'}
);

# ====================================================================================================================
#   1clickinstall Install Form State
#   1:  Superlibrarian Password Change pending
#   2:  Library Name , Librarian Email and/or Password Change pending
#   3:  Finished -> Can go to App.
# ====================================================================================================================
	my $queryCI =  "SELECT value FROM systempreferences WHERE variable = '1clickinstall';";
	my $sthCI = $dbh->prepare($queryCI);
	$sthCI->execute(); 
	my $clickinstall  = $sthCI->fetchrow_hashref->{value};
# =============================

# ====================================================================================================================
#   Form inputs
# ====================================================================================================================
my $nombreBiblioteca = $query->param('nombreBiblioteca');
my $correoBibliotecario = $query->param('correoBibliotecario');
my $newpassword = $query->param('passBibliotecario');
my $newpassword2 = $query->param('passBibliotecario2');
my $systempassword = $query->param('systempassword');
my $systempassword2 = $query->param('systempassword2');
my $cuantosprestamos  = $query->param('cuantosprestamos');
my $cuantosdias  = $query->param('cuantosdias');
my $OpacStarRatings = $query->param('OpacStarRatings');
my $reviewson = $query->param('reviewson');
my $AnonSuggestions = $query->param('AnonSuggestions');
my $OpacShowRecentComments = $query->param('OpacShowRecentComments');
my $SocialNetworks = $query->param('SocialNetworks');
my $urlOPAC = $query->param('urlOPAC');
# =============================


$template->param(URL_Basica => "1clickinstall.pl?step=2",);
$template->param(URL_Avanzado => "1clickinstall.pl?step=2&op=1",);
$template->param(op => $op);
$template->param(clickinstall => $clickinstall);


if ( $step && $step == 1 ) { # Superlibrarian Password Change
	
    	$template->param( language => 1 );

	if ( $clickinstall == "1"){ 
		my @serrors;
		
		push(@serrors,'NOMATCH') if ( ( $systempassword && $systempassword2 ) && ($systempassword ne $systempassword2) );

		my $minpw = C4::Context->preference('minPasswordLength');
		push(@serrors,'SHORTPASSWORD') if( $systempassword && $minpw && (length($systempassword) < $minpw ) );
	

   		if ( $systempassword  && !scalar(@serrors) ) {
	
			#=============================
			#   DDBB root user Conn
			#=============================
			my $dbhroot = DBI->connect(
   			 "DBI:$info{dbms}:dbname=$info{dbname};host=$info{hostname}"
      			. ( $info{port} ? ";port=$info{port}" : "" ),
   			'root', 'mysql_admin'
			);

 			if ($dbhroot) {
			
			#==========================================================
			#   update  <pass> in koha-conf.xml
			#==========================================================
			my $change = 's/<pass>'.$info{'password'}.'</<pass>'.$systempassword.'</gi';
			system(qq{/usr/bin/perl -p -i -e  '$change' /home/www/kobli/etc/koha-conf.xml})  == 0 or die "Can't file ($?)";

		
			#==========================================================
			#   update mysql kobli_usu <pass>
			#==========================================================
			my $systemUpdate = $dbhroot->prepare("update mysql.user set password=PASSWORD(?) where user='kobli_usu' AND host='localhost';" );
			$systemUpdate ->bind_param( 1, $systempassword  );
			$systemUpdate ->execute();
		
			my $systemUpdateFP = $dbhroot->prepare("FLUSH PRIVILEGES; " );
			$systemUpdateFP ->execute();
 			$template->param( "error" => DBI::err, "message" => DBI::errstr );

			#==========================================================
			#   change install for  for next  steap
			#==========================================================
			my $updateCI = $dbh->prepare("UPDATE systempreferences SET value = ? WHERE variable = '1clickinstall';" );
			$updateCI->bind_param( 1, "2" );
			$updateCI->execute();

			#==========================================================
			#   reload apache and go to next step
			#==========================================================
			print $query->redirect("/cgi-bin/koha/installer/1clickinstall.pl?step=2");
			exec(qq{sudo /etc/init.d/apache2 reload})  == 0 or die "Can't restart apache ($?)";
        		exit;
		
			} else {
   				$template->param( "error" => DBI::err, "message" => DBI::errstr );
			}
	
		}
	}
	else { #must go to next step
		print $query->redirect("/cgi-bin/koha/installer/1clickinstall.pl?step=2");
		exit;
	}
}
elsif( $step && $step >= 2 ) {  # Library Name , Librarian Email and/or Password Change
	
	$template->param( language => 1 );

	if ( $clickinstall== "1"){ # must go to previous step
		print $query->redirect("/cgi-bin/koha/installer/1clickinstall.pl?step=1");
		exit;
	}


	#==========================================================
	#   change LibraryName
	#==========================================================
   	if ($nombreBiblioteca  && $nombreBiblioteca  ne ""){
		#LibraryName
		my $updateNB = $dbh->prepare("UPDATE systempreferences SET value = ? WHERE variable = 'LibraryName';" );
		$updateNB->bind_param( 1, $nombreBiblioteca );
	$	updateNB ->execute();	
	}

	#==========================================================
	#   change LibraryName
	#==========================================================   	
   	if ($correoBibliotecario  && $correoBibliotecario  ne ""){
		#email
		my $updateCB = $dbh->prepare("UPDATE borrowers SET email = ? WHERE cardnumber = 1;" );
		$updateCB->bind_param( 1, $correoBibliotecario );
		$updateCB->execute();	
	}


#==========================================================
#   change Librarian password FROM:#members-password.pl
#==========================================================  

my @errors;


push(@errors,'NOMATCH') if ( ( $newpassword && $newpassword2 ) && ($newpassword ne $newpassword2) );

my $minpw = C4::Context->preference('minPasswordLength');
push(@errors,'SHORTPASSWORD') if( $newpassword && $minpw && (length($newpassword) < $minpw ) );

if ( $newpassword  && !scalar(@errors) ) {
    my $digest=md5_base64($newpassword);
    my $uid = 1;
    my $member = 1;
    my $dbh=C4::Context->dbh;
    if (changepassword($uid,$member,$digest)) {
	
	#email -> If password change change surname to  know that al least once change is made.
	my $updateSP = $dbh->prepare("UPDATE borrowers SET surname = ? WHERE cardnumber = 1;" );
	$updateSP->bind_param( 1, "(Superbibliotecario)" );
	$updateSP->execute();	
	
	

    } else {
	push(@errors,'BADUSERID');
    }
} 
# -- members-password.pl -------------------------------------

	#==========================================================
	#   change issuingrules 
	#==========================================================   	
   	if ($cuantosprestamos  && $cuantosprestamos  ne ""){
		#issuingrules
		my $updateIR = $dbh->prepare("UPDATE issuingrules SET maxissueqty = ? WHERE categorycode = '*' AND itemtype = '*' AND branchcode = '*'" );
		$updateIR->bind_param( 1, $cuantosprestamos );
		$updateIR->execute();
		#default_circ_rules
		my $updateCR = $dbh->prepare("UPDATE default_circ_rules SET maxissueqty = ? WHERE singleton = 'singleton'" );
		$updateCR->bind_param( 1, $cuantosprestamos );
		$updateCR->execute();	
	}
	if ( $cuantosdias  && $cuantosdias  ne ""){
		#issuingrules
		my $updateIRD = $dbh->prepare("UPDATE issuingrules SET issuelength = ? WHERE categorycode = '*' AND itemtype = '*' AND branchcode = '*'" );
		$updateIRD->bind_param( 1, $cuantosdias );
		$updateIRD->execute();
			
	}
	#==========================================================  


	#==========================================================
	#   change OpacStarRatings
	#==========================================================
   	if ($OpacStarRatings  && $OpacStarRatings  ne ""){
		#OpacStarRatings
		my $updateSR = $dbh->prepare("UPDATE systempreferences SET value = ? WHERE variable = 'OpacStarRatings';" );
		$updateSR->bind_param( 1, $OpacStarRatings );
		$updateSR->execute();	
	}
 
	#==========================================================
	#   change reviewson
	#==========================================================   
   	if ($reviewson || $reviewson == ""){
		if ( $reviewson == "" ){ $reviewson = '0';}
		#reviewson
		my $updateRS = $dbh->prepare("UPDATE systempreferences SET value = ? WHERE variable = 'reviewson';" );
		$updateRS->bind_param( 1, $reviewson );
		$updateRS->execute();	
	}
  
	#==========================================================
	#   change AnonSuggestions
	#==========================================================  
   	if ($AnonSuggestions || $AnonSuggestions == ""){
		if ( $AnonSuggestions == "" ){ $AnonSuggestions = '0';}
		#$AnonSuggestions
		my $updateAS = $dbh->prepare("UPDATE systempreferences SET value = ? WHERE variable = 'AnonSuggestions';" );
		$updateAS->bind_param( 1, $AnonSuggestions );
		$updateAS->execute();	
	}
 
	
	#==========================================================
	#   change OpacShowRecentComments 
	#========================================================== 	
   	if ($OpacShowRecentComments || $OpacShowRecentComments == ""){
		if ( $OpacShowRecentComments == "" ){ $OpacShowRecentComments = '0';}
		#OpacShowRecentComments 
		my $updateSRC = $dbh->prepare("UPDATE systempreferences SET value = ? WHERE variable = 'OpacShowRecentComments';" );
		$updateSRC->bind_param( 1, $OpacShowRecentComments );
		$updateSRC->execute();	
	}

 	
	#==========================================================
	#   change SocialNetworks 
	#========================================================== 	
   	if ($SocialNetworks || $SocialNetworks == ""){
		if ( $SocialNetworks == "" ){ $SocialNetworks = '0';}
		#SocialNetworks 
		my $updateSN = $dbh->prepare("UPDATE systempreferences SET value = ? WHERE variable = 'SocialNetworks';" );
		$updateSN->bind_param( 1, $SocialNetworks );
		$updateSN->execute();	
	
		#==========================================================
		#   change OPACBaseURL
		#========================================================== 
		if ( $SocialNetworks == "1" ){
			if ($urlOPAC || $urlOPAC == ""){
				if ($urlOPAC ne "http://") {
					my $find = "http://";
					my $replace = "";
					$urlOPAC =~ s/$find/$replace/g;
					my $urlOPAClc =  substr $urlOPAC, -1;
					if ($urlOPAClc =~ /\//) {$urlOPAC = substr($urlOPAC, 0, -1);}
					#OPACBaseURL
					my $updateOP = $dbh->prepare("UPDATE systempreferences SET value = ? WHERE variable = 'OPACBaseURL';" );
					$updateOP->bind_param( 1, $urlOPAC);
					$updateOP->execute();	
				}

			}
		}
	}

#==========================================================
#   change image FROM: #prefs-imges-upload.pl
#========================================================== 
for ($query->param()) {

    my $file_name = $query->param($_) || '';
    my $upload_file = $query->upload($_) || '';
    my $op = $query->param('op') || 'none';
    my $source_file = "$file_name"; # otherwise we end up with what amounts to a pointer to a filehandle rather than a user-friendly filename
    my $pref="";
  if ($_ && $_ =~ /uploadfile(?:_[0-9]+)?/) {

    my $image_limit = C4::Context->preference('ImageLimit') || '';
   
      if ($upload_file) {
        my $image = Image::Magick->new;
        eval{$image->Read($query->tmpFileName($file_name));};
        if ($@) {
            warn sprintf('An error occurred while creating the image object: %s',$@);
            $template->param(
                IMPORT_SUCCESSFUL => 0,
                SOURCE_FILE => $source_file,
                error => 1,
                error_1 => 1,
            );
        }
        elsif($image->Get('height')<=0 || $image->Get('width')<=0){
            warn sprintf('An error occurred while creating the image object: %s',$@);
            $template->param(
                IMPORT_SUCCESSFUL => 0,
                SOURCE_FILE => $source_file,
                error => 1,
                error_2 => 1,
            );
        }
        else {
            my $height = 100;
            my $name ="";
            my $width = ($image->Get('width')/$image->Get('height'))*$height;
            if ($_ eq "uploadfile_1"){
              $pref = "'opacsmallimage'";
              $file_name =~ m/(\w+)$/;
              $name = "opacsmallimage.".$1;
              if($image->Get('width')>$width || $image->Get('height')>$height){
                $image->Resize(width=>$width, height=>$height, blur=>1);
              }if($image->Get('width')>300){
                $width = 300;
                $height = ($image->Get('height')/$image->Get('width'))*$width;
                $image->Resize(width=>$width, height=>$height, blur=>1);
              }
            }
            eval{$image->Write($query->tmpFileName($file_name));};
            open (UPLOADFILE, ">$upload_dir/$name") or die "Couldn't open: $!";
            open (UPLOAD, ">$intra_dir/$name") or die "Couldn't open: $!";
            binmode UPLOADFILE;
            binmode UPLOAD;
            while ( <$upload_file> ) {
              print UPLOADFILE;
              print UPLOAD;
            }
            close UPLOADFILE;
            close UPLOAD;
            my $query =  "UPDATE systempreferences 
                          SET value = ? 
                          WHERE variable = ".$pref.";";
            my $sth = $dbh->prepare($query);
            $sth->execute("/opac-tmpl/prog/imgs/".$name);
        }
      }
    }
  
}

# -----  prefs-imges-upload.pl  ---------


	#==========================================================
	#   Fetch Data
	#========================================================== 	
	

	#   === $surname  ===

	my $querySN =  "SELECT surname FROM borrowers WHERE cardnumber = 1;";
	my $sthSN = $dbh->prepare($querySN);
	$sthSN->execute(); 
	my $surname  = $sthSN->fetchrow_hashref->{surname};

	#   === $email  ===

	my $queryEM =  "SELECT email FROM borrowers WHERE cardnumber = 1;";
	my $sthEM = $dbh->prepare($queryEM);
	$sthEM->execute(); 
	my $email= $sthEM->fetchrow_hashref->{email};

	if ( $email && $email ne "noemail"){
		$template->param(
        		correoBibliotecario => $email,
    		); 
	};
	
	
	#   === cuantosprestamos  ===
	
	my $queryMI =  "SELECT maxissueqty FROM issuingrules WHERE categorycode = '*' AND itemtype = '*' AND branchcode = '*';";
	my $sthMI = $dbh->prepare($queryMI);
	$sthMI->execute(); 
	if(my $dataMI = $sthMI->fetchrow_hashref->{maxissueqty}){
    	$template->param(
        	cuantosprestamos => $dataMI,
    	);  
	}

	#   === cuantosdias  ===
	my $queryIR =  "SELECT issuelength FROM issuingrules WHERE categorycode = '*' AND itemtype = '*' AND branchcode = '*';";
	my $sthIR = $dbh->prepare($queryIR);
	$sthIR->execute(); 
	if(my $dataIR = $sthIR->fetchrow_hashref->{issuelength}){
    	$template->param(
        	 cuantosdias => $dataIR,
    	);  
	}

	#   === nombreBiblioteca  ===
	
	my $queryLN =  "SELECT value FROM systempreferences WHERE variable = 'LibraryName';";
	my $sthLN = $dbh->prepare($queryLN);
	$sthLN->execute(); 
	if(my $dataLN = $sthLN->fetchrow_hashref->{value}){
    	$template->param(
        	nombreBiblioteca=> $dataLN,
    	);  
	}

	#   === OpacStarRatings  ===
	my $querySR =  "SELECT value FROM systempreferences WHERE variable = 'OpacStarRatings';";
	my $sthSR = $dbh->prepare($querySR);
	$sthSR->execute(); 
	if(my $dataSR = $sthSR->fetchrow_hashref->{value}){
    	$template->param(
        	OpacStarRatings=> $dataSR,
    	);  
	}

	#   === reviewson   ===

	my $queryRS =  "SELECT value FROM systempreferences WHERE variable = 'reviewson';";
	my $sthRS = $dbh->prepare($queryRS);
	$sthRS->execute(); 
	my $dataRS = $sthRS->fetchrow_hashref->{value};
	if($dataRS && $dataRS ne ""){
	
    	$template->param(
        	reviewson=> $dataRS,
    	);  
	} else {
	$template->param(
        	reviewson=> "",
    	); 
	}

	#   === AnonSuggestions  ===

	my $queryAS =  "SELECT value FROM systempreferences WHERE variable = 'AnonSuggestions';";
	my $sthAS = $dbh->prepare($queryAS);
	$sthAS->execute(); 
	my $dataAS = $sthAS->fetchrow_hashref->{value};
	if($dataAS && $dataAS ne ""){
	
    	$template->param(
        	AnonSuggestions=> $dataAS,
    	);  
	} else {
	$template->param(
        	AnonSuggestions=> "",
    	); 
	}

	#   === OpacShowRecentComments  ===
	my $querySRC =  "SELECT value FROM systempreferences WHERE variable = 'OpacShowRecentComments';";
	my $sthSRC = $dbh->prepare($querySRC);
	$sthSRC->execute(); 
	my $dataSRC = $sthSRC->fetchrow_hashref->{value};
	if($dataSRC && $dataSRC ne ""){
	
    	$template->param(
        	OpacShowRecentComments=> $dataSRC,
    	);  
	} else {
	$template->param(
        	OpacShowRecentComments=> "",
    	); 
	}

	#   === SocialNetworks  ===
	my $querySN =  "SELECT value FROM systempreferences WHERE variable = 'SocialNetworks';";
	my $sthSN = $dbh->prepare($querySN);
	$sthSN->execute(); 
	my $dataSN = $sthSN->fetchrow_hashref->{value};
	if($dataSN && $dataSN ne ""){
	
    	$template->param(
        	SocialNetworks=> $dataSN,
    	);  
	} else {
	$template->param(
        	SocialNetworks=> "",
    	); 
	}

	#   === OPACBaseURL  ===
	my $queryOP =  "SELECT value FROM systempreferences WHERE variable = 'OPACBaseURL';";
	my $sthOP = $dbh->prepare($queryOP);
	$sthOP->execute(); 
	if(my $dataOP = $sthOP->fetchrow_hashref->{value}){
    	$template->param(
        	OPACBaseURL => "http://" . $dataOP,
    	);  
	}

	#   === SMALLIMAGE ===
	#==== prefs-imges-upload.pl
	my $queryOSI =  "SELECT value FROM systempreferences 
              WHERE variable = 'opacsmallimage';";
	my $sthOSI = $dbh->prepare($queryOSI);
	$sthOSI->execute(); 
	if(my $dataOSI = $sthOSI->fetchrow_hashref->{value}){
    	$dataOSI =~ s/opac/intranet/;
    	$template->param(
        	SMALLIMAGE => $dataOSI,
    	);  
	}
	#==

	#==========================================================
	#   $cuentaConfigurada = "1" -> Can go to App
	#   surname:(_Superbibliotecario) -> default install -> must be changed to know than at least once the password has been changed from default.
	#   email:noemail -> default install -> must be changed to know than at least once the password has been changed from default.
	#========================================================== 
	if ($surname && $surname ne "(_Superbibliotecario)" && $email && $email ne "noemail"){
		$template->param(
        		cuentaConfigurada => "1",
    		); 
		$cuentaConfigurada = "1";
	};

	#==========================================================
	#   $cuentaConfigurada = "1" -> Can go to App
	#   change systempreference version to real one to avoid maintinance mode.
	#   change systempreference 1clickinstall to3 to avoid required redirect to install.
	#========================================================== 
	if ($cuentaConfigurada && $cuentaConfigurada == "1"){
		my $updateKV = $dbh->prepare("UPDATE kobli.systempreferences SET value='3.1204000' WHERE variable='Version';" );
		$updateKV->execute();	
		my $updateCI = $dbh->prepare("UPDATE systempreferences SET value = '3' WHERE variable = '1clickinstall';" );
		$updateCI->execute();
	}
	

if ( $op && $op == 1 ) {

	


}


}
else {

    # LANGUAGE SELECTION page by default
    # using opendir + language Hash
    #my $languages_loop = getTranslatedLanguages('intranet');
    #$template->param( installer_languages_loop => $languages_loop );
	if ( $clickinstall == "1" ) {
		C4::Templates::setlanguagecookie( $query, 'es-ES', "1clickinstall.pl?step=1" );
	} else {
		C4::Templates::setlanguagecookie( $query, 'es-ES', "1clickinstall.pl?step=2" );
	}
 	
    }


output_html_with_http_headers $query, $cookie, $template->output;
