package BookShelf::Controller::Book;
use base 'Catalyst::Enzyme::CRUD::Controller';

use strict;
use warnings;



=head1 NAME

BookShelf::Controller::Book - Catalyst Enzyme CRUD Controller



=head1 SYNOPSIS

See L<BookShelf>



=head1 DESCRIPTION

Catalyst Enzyme Controller with CRUD support.



=head1 METHODS

=head2 begin

Set up the default model and class for this Controller

=cut
sub begin : Private {
    my ($self, $c) = @_;
    $self->set_model_class($c, "BookShelf::Model::BookShelfDB::Book");
}



=head1 SEE ALSO

L<BookShelf>, L<Catalyst::Enzyme::CRUD::Controller>,
L<Catalyst::Enzyme>



=head1 AUTHOR

A clever guy



=head1 LICENSE

This library is free software . You can redistribute it and/or modify
it under the same terms as perl itself.

=cut

1;
