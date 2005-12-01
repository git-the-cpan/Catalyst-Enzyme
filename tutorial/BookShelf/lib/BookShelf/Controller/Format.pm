package BookShelf::Controller::Format;
use base 'Catalyst::Enzyme::CRUD::Controller';

use strict;
use warnings;
use base 'Catalyst::Controller';

=head1 NAME

BookShelf::Controller::Format - Catalyst Controller

=head1 SYNOPSIS

See L<BookShelf>

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head2 model_class

Define the  model class for this Controller

=cut
sub model_class {
    return("BookShelf::Model::BookShelfDB::Format");
}
        


=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
