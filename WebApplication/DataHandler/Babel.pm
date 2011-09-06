package DataHandler::Babel;

# DataHandler::Babel - data handler to the Babel database



use strict;
#use warnings;

use base qw( DataHandler );

use DBMaster;
use DBI;
use Global_Config;


=pod

=head1 NAME

DataHandler::ACH - data handler to the Babel database

=head1 DESCRIPTION

This module returns the DBMaster object to the Babel database stored in the root
job directory of a ACH server. It requires the Global_Config.pm to specify the  
$rast_jobs directory.

Refer to WebApplication/DataHandler.pm for the full documentation.

=head1 METHODS

=over 4

=item * B<handle> ()

Returns the enclosed data handle. Returns undef if it fails to open the Jobs database

=cut

sub handle {
  
  unless (exists $_[0]->{_handle}) {
    
    my $user    = "";
    my $dbpass  = "";
    my $db      = "";
    my $dbhost  = "";
    my $backend = "";
    my $type    = "SQL"; # default is not PPO
    my $dbsock  = $Global_Config::dbsock || "";
    my $dbport  = $Global_Config::dbsock || "";
    
    if ($WebConfig::BABELDB) {
      $user    = $WebConfig::BABELUSER      || "ach"; 
      $dbpass  = $WebConfig::BABELDBPASS    || "";
      $db      = $WebConfig::BABELDB;
      $dbhost  = $WebConfig::BABELDBHOST;
      $backend = $WebConfig::BABELDBBACKEND || "MySQL"; # for PPO only
      $type    = $WebConfig::BABELDBPTYPE   if ($WebConfig::BABELDBTYPE);
      $dbsock  = $WebConfig::BABELDBSOCK    if ($WebConfig::BABELDBSOCK);
      $dbport  = $WebConfig::BABELDBPORT    if ($WebConfig::BABELDBPORT);
    }
    elsif ($Global_Config::babel_db) {
      $user    = $Global_Config::babel_dbuser    || "ach";
      $dbpass  = $Global_Config::babel_dbpass    || "";
      $db      = $Global_Config::babel_db;
      $dbhost  = $Global_Config::babel_dbhost;
      $backend = $Global_Config::babel_dbbackend || "MySQL"; # for PPO only
      $type    = $Global_Config::babel_dbtype    if ($Global_Config::babel_dbtype);
      $dbsock  = $Global_Config::babel_dbsock    if ($Global_Config::babel_dbsock);
      $dbport  = $Global_Config::babel_dbport    if ($Global_Config::babel_dbport);

    }
    else {
      	warn "Unable to read DataHandler::Babel database: can't find Global_Config.pm or Babel.pm\n";
	return undef;
    }

    if ($type eq "PPO") {
      eval {
	$_[0]->{_handle} = DBMaster->new( -database => $db,
					  -host     => $dbhost,
					  -user     => $user,
					  -backend  => $backend,
					);
      };
    }
    else {
      if ($dbhost) {
	$_[0]->{_handle} = DBI->connect("DBI:$type:dbname=$db;host=$dbhost", $user, $dbpass);
      }
      print STDERR $_[0]->{_handle} . "\n";
      unless ( $_[0]->{_handle} ) {
	print STDERR "Error , " , DBI->error , "\n";
      }
    }
    
    if ($@) {
      warn "Unable to read DataHandler::Babel : $@\n";
      $_[0]->{_handle} = undef;
    }
  }
  return $_[0]->{_handle};
}

1;
