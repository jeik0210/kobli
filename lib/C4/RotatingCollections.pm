package C4::RotatingCollections;

# $Id: RotatingCollections.pm,v 0.1 2007/04/20 kylemhall 

# This package is inteded to keep track of what library
# Items of a certain collection should be at. 

# Copyright 2007 Kyle Hall
#
# This file is part of Koha.
#
# Koha is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# Koha is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with Koha; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use strict;
#use warnings; FIXME - Bug 2505

require Exporter;

use C4::Context;
use C4::Circulation;

use DBI;

use Data::Dumper;

use vars qw($VERSION @ISA @EXPORT);

# set the version for version checking
$VERSION = 3.07.00.049;

=head1 NAME

C4::RotatingCollections - Functions for managing rotating collections

=head1 FUNCTIONS

=cut

@ISA = qw( Exporter );
@EXPORT = qw( 
  CreateCollection
  UpdateCollection
  DeleteCollection
  
  GetItemsInCollection

  GetCollection
  GetCollections
  
  AddItemToCollection
  RemoveItemFromCollection
  TransferCollection  

  GetCollectionItemBranches
);

=head2  CreateCollection
 ( $success, $errorcode, $errormessage ) = CreateCollection( $title, $description );
 Creates a new collection

 Input:
   $title: short description of the club or service
   $description: long description of the club or service

 Output:
   $success: 1 if all database operations were successful, 0 otherwise
   $errorCode: Code for reason of failure, good for translating errors in templates
   $errorMessage: English description of error

=cut

sub CreateCollection {
  my ( $title, $description ) = @_;

  ## Check for all neccessary parameters
  if ( ! $title ) {
    return ( 0, 1, "No Title Given" );
  } 
  if ( ! $description ) {
    return ( 0, 2, "No Description Given" );
  } 

  my $success = 1;

  my $dbh = C4::Context->dbh;

  my $sth;
  $sth = $dbh->prepare("INSERT INTO collections ( colId, colTitle, colDesc ) 
                        VALUES ( NULL, ?, ? )");
  $sth->execute( $title, $description ) or return ( 0, 3, $sth->errstr() );

  return 1;
 
}

=head2 UpdateCollection

 ( $success, $errorcode, $errormessage ) = UpdateCollection( $colId, $title, $description );

Updates a collection

 Input:
   $colId: id of the collection to be updated
   $title: short description of the club or service
   $description: long description of the club or service

 Output:
   $success: 1 if all database operations were successful, 0 otherwise
   $errorCode: Code for reason of failure, good for translating errors in templates
   $errorMessage: English description of error

=cut

sub UpdateCollection {
  my ( $colId, $title, $description ) = @_;

  ## Check for all neccessary parameters
  if ( ! $colId ) {
    return ( 0, 1, "No Id Given" );
  }
  if ( ! $title ) {
    return ( 0, 2, "No Title Given" );
  } 
  if ( ! $description ) {
    return ( 0, 3, "No Description Given" );
  } 

  my $dbh = C4::Context->dbh;

  my $sth;
  $sth = $dbh->prepare("UPDATE collections
                        SET 
                        colTitle = ?, colDesc = ? 
                        WHERE colId = ?");
  $sth->execute( $title, $description, $colId ) or return ( 0, 4, $sth->errstr() );
  
  return 1;
  
}

=head2 DeleteCollection

 ( $success, $errorcode, $errormessage ) = DeleteCollection( $colId );
 Deletes a collection of the given id

 Input:
   $colId : id of the Archtype to be deleted

 Output:
   $success: 1 if all database operations were successful, 0 otherwise
   $errorCode: Code for reason of failure, good for translating errors in templates
   $errorMessage: English description of error

=cut

sub DeleteCollection {
  my ( $colId ) = @_;

  ## Paramter check
  if ( ! $colId ) {
    return ( 0, 1, "No Collection Id Given" );;
  }
  
  my $dbh = C4::Context->dbh;

  my $sth;

  $sth = $dbh->prepare("DELETE FROM collections WHERE colId = ?");
  $sth->execute( $colId ) or return ( 0, 4, $sth->errstr() );

  return 1;
}

=head2 GetCollections

 $collections = GetCollections();
 Returns data about all collections

 Output:
  On Success:
   $results: Reference to an array of associated arrays
  On Failure:
   $errorCode: Code for reason of failure, good for translating errors in templates
   $errorMessage: English description of error

=cut

sub GetCollections {

  my $dbh = C4::Context->dbh;
  
  my $sth = $dbh->prepare("SELECT * FROM collections");
  $sth->execute() or return ( 1, $sth->errstr() );
  
  my @results;
  while ( my $row = $sth->fetchrow_hashref ) {
    push( @results , $row );
  }
  
  return \@results;
}

=head2 GetItemsInCollection

 ( $results, $success, $errorcode, $errormessage ) = GetItemsInCollection( $colId );

 Returns information about the items in the given collection
 
 Input:
   $colId: The id of the collection

 Output:
   $results: Reference to an array of associated arrays
   $success: 1 if all database operations were successful, 0 otherwise
   $errorCode: Code for reason of failure, good for translating errors in templates
   $errorMessage: English description of error

=cut

sub GetItemsInCollection {
  my ( $colId ) = @_;

  ## Paramter check
  if ( ! $colId ) {
    return ( 0, 0, 1, "No Collection Id Given" );;
  }

  my $dbh = C4::Context->dbh;
  
  my $sth = $dbh->prepare("SELECT 
                             biblio.title,
                             items.itemcallnumber,
                             items.barcode
                           FROM collections, collections_tracking, items, biblio
                           WHERE collections.colId = collections_tracking.colId
                           AND collections_tracking.itemnumber = items.itemnumber
                           AND items.biblionumber = biblio.biblionumber
                           AND collections.colId = ? ORDER BY biblio.title");
  $sth->execute( $colId ) or return ( 0, 0, 2, $sth->errstr() );
  
  my @results;
  while ( my $row = $sth->fetchrow_hashref ) {
    push( @results , $row );
  }
  
  return \@results;
}

=head2 GetCollection

 ( $colId, $colTitle, $colDesc, $colBranchcode ) = GetCollection( $colId );

Returns information about a collection

 Input:
   $colId: Id of the collection
 Output:
   $colId, $colTitle, $colDesc, $colBranchcode

=cut

sub GetCollection {
  my ( $colId ) = @_;

  my $dbh = C4::Context->dbh;

  my ( $sth, @results );
  $sth = $dbh->prepare("SELECT * FROM collections WHERE colId = ?");
  $sth->execute( $colId ) or return 0;
    
  my $row = $sth->fetchrow_hashref;
  
  return (
      $$row{'colId'},
      $$row{'colTitle'},
      $$row{'colDesc'},
      $$row{'colBranchcode'}
  );
    
}

=head2 AddItemToCollection

 ( $success, $errorcode, $errormessage ) = AddItemToCollection( $colId, $itemnumber );

Adds an item to a rotating collection.

 Input:
   $colId: Collection to add the item to.
   $itemnumber: Item to be added to the collection
 Output:
   $success: 1 if all database operations were successful, 0 otherwise
   $errorCode: Code for reason of failure, good for translating errors in templates
   $errorMessage: English description of error

=cut

sub AddItemToCollection {
  my ( $colId, $itemnumber ) = @_;

  ## Check for all neccessary parameters
  if ( ! $colId ) {
    return ( 0, 1, "No Collection Given" );
  } 
  if ( ! $itemnumber ) {
    return ( 0, 2, "No Itemnumber Given" );
  } 
  
  if ( isItemInThisCollection( $itemnumber, $colId ) ) {
    return ( 0, 2, "Item is already in the collection!" );
  } elsif ( isItemInAnyCollection( $itemnumber ) ) {
    return ( 0, 3, "Item is already in a different collection!" );
  }

  my $dbh = C4::Context->dbh;

  my $sth;
  $sth = $dbh->prepare("INSERT INTO collections_tracking ( ctId, colId, itemnumber ) 
                        VALUES ( NULL, ?, ? )");
  $sth->execute( $colId, $itemnumber ) or return ( 0, 3, $sth->errstr() );

  return 1;
  
}

=head2  RemoveItemFromCollection

 ( $success, $errorcode, $errormessage ) = RemoveItemFromCollection( $colId, $itemnumber );

Removes an item to a collection

 Input:
   $colId: Collection to add the item to.
   $itemnumber: Item to be removed from collection

 Output:
   $success: 1 if all database operations were successful, 0 otherwise
   $errorCode: Code for reason of failure, good for translating errors in templates
   $errorMessage: English description of error

=cut

sub RemoveItemFromCollection {
  my ( $colId, $itemnumber ) = @_;

  ## Check for all neccessary parameters
  if ( ! $itemnumber ) {
    return ( 0, 2, "No Itemnumber Given" );
  } 
  
  if ( ! isItemInThisCollection( $itemnumber, $colId ) ) {
    return ( 0, 2, "Item is not in the collection!" );
  } 

  my $dbh = C4::Context->dbh;

  my $sth;
  $sth = $dbh->prepare("DELETE FROM collections_tracking 
                        WHERE itemnumber = ?");
  $sth->execute( $itemnumber ) or return ( 0, 3, $sth->errstr() );

  return 1;
}

=head2 TransferCollection

 ( $success, $errorcode, $errormessage ) = TransferCollection( $colId, $colBranchcode );

Transfers a collection to another branch

 Input:
   $colId: id of the collection to be updated
   $colBranchcode: branch where collection is moving to

 Output:
   $success: 1 if all database operations were successful, 0 otherwise
   $errorCode: Code for reason of failure, good for translating errors in templates
   $errorMessage: English description of error

=cut

sub TransferCollection {
  my ( $colId, $colBranchcode ) = @_;

  ## Check for all neccessary parameters
  if ( ! $colId ) {
    return ( 0, 1, "No Id Given" );
  }
  if ( ! $colBranchcode ) {
    return ( 0, 2, "No Branchcode Given" );
  } 

  my $dbh = C4::Context->dbh;

  my $sth;
  $sth = $dbh->prepare("UPDATE collections
                        SET 
                        colBranchcode = ? 
                        WHERE colId = ?");
  $sth->execute( $colBranchcode, $colId ) or return ( 0, 4, $sth->errstr() );
  
  $sth = $dbh->prepare("SELECT barcode FROM items, collections_tracking 
                        WHERE items.itemnumber = collections_tracking.itemnumber
                        AND collections_tracking.colId = ?");
  $sth->execute( $colId ) or return ( 0, 4, $sth->errstr );
  my @results;
  while ( my $item = $sth->fetchrow_hashref ) {
    my ( $dotransfer, $messages, $iteminformation ) = transferbook( $colBranchcode, $item->{'barcode'}, my $ignore_reserves = 1);
  }

  return 1;
  
}

=head2 GetCollectionItemBranches

  my ( $holdingBranch, $collectionBranch ) = GetCollectionItemBranches( $itemnumber );

=cut

sub GetCollectionItemBranches {
  my ( $itemnumber ) = @_;

  if ( ! $itemnumber ) {
    return;
  }

  my $dbh = C4::Context->dbh;

  my ( $sth, @results );
  $sth = $dbh->prepare("SELECT holdingbranch, colBranchcode FROM items, collections, collections_tracking 
                        WHERE items.itemnumber = collections_tracking.itemnumber
                        AND collections.colId = collections_tracking.colId
                        AND items.itemnumber = ?");
  $sth->execute( $itemnumber );
    
  my $row = $sth->fetchrow_hashref;
  
  return (
      $$row{'holdingbranch'},
      $$row{'colBranchcode'},
  );  
}

=head2 isItemInThisCollection

  $inCollection = isItemInThisCollection( $itemnumber, $colId );

=cut

sub isItemInThisCollection {
  my ( $itemnumber, $colId ) = @_;
  
  my $dbh = C4::Context->dbh;
  
  my $sth = $dbh->prepare("SELECT COUNT(*) as inCollection FROM collections_tracking WHERE itemnumber = ? AND colId = ?");
  $sth->execute( $itemnumber, $colId ) or return( 0 );
      
  my $row = $sth->fetchrow_hashref;
        
  return $$row{'inCollection'};
}

=head2 isItemInAnyCollection

$inCollection = isItemInAnyCollection( $itemnumber );

=cut

sub isItemInAnyCollection {
  my ( $itemnumber ) = @_;
  
  my $dbh = C4::Context->dbh;
  
  my $sth = $dbh->prepare("SELECT itemnumber FROM collections_tracking WHERE itemnumber = ?");
  $sth->execute( $itemnumber ) or return( 0 );
      
  my $row = $sth->fetchrow_hashref;
        
  $itemnumber = $row->{itemnumber};
  if ( $itemnumber ) {
    return 1;
  } else {
    return 0;
  }
}

1;

__END__

=head1 AUTHOR

Kyle Hall <kylemhall@gmail.com>

=cut
