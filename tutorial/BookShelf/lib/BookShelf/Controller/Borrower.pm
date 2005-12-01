package BookShelf::Controller::Borrower;
use base 'Catalyst::Enzyme::CRUD::Controller';

use strict;
use warnings;

=head1 NAME

BookShelf::Controller::Borrower - Catalyst Controller

=head1 SYNOPSIS

See L<BookShelf>

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head2 model_class

Define the  model class for this Controller

=cut
sub model_class {
    return("BookShelf::Model::BookShelfDB::Borrower");
}

        

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
