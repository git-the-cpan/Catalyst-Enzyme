package BookShelf;

use strict;
use warnings;

#
# Set flags and add plugins for the application
#
#         -Debug: activates the debug mode for very useful log messages
# Static::Simple: will serve static files from the applications root directory
#
use Catalyst qw/-Debug Static::Simple DefaultEnd FormValidator/;

our $VERSION = '0.01';

#
# Configure the application
#
__PACKAGE__->config( name => 'BookShelf' );

#
# Start the application
#
__PACKAGE__->setup;

=head1 NAME

BookShelf - Catalyst based application

=head1 SYNOPSIS

    script/bookshelf_server.pl

=head1 DESCRIPTION

Catalyst based application.

=head1 METHODS

=head2 default

=cut

#
# Output a friendly welcome message
#
sub default : Private {
    my ( $self, $c ) = @_;

    $c->res->redirect("/book");
}


=head1 AUTHOR

Catalyst developer

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
