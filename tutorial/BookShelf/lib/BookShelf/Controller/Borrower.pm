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

=head2 begin

Set up the default model and class for this Controller

=cut
sub begin : Private {
    my ($self, $c) = @_;
    $self->set_model_class($c, "BookShelf::Model::BookShelfDB::Borrower");
}


=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
