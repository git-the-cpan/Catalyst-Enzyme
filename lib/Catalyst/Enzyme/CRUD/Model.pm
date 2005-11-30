package Catalyst::Enzyme::CRUD::Model;
use strict;
use base 'Catalyst::Model';



our $VERSION = 0.01;



=head1 NAME

Catalyst::Model::Enzyme::CRUD - CRUD Model Component


=head1 SYNOPSIS



=head1 DESCRIPTION

CRUD Model Component.



=head1 MODEL CONFIGURATION

This is how to configure your model classes' meta data.


=head2 __PACKAGE__->config( crud => {} )

Some things are configured

=over 4

=item moniker

Human readable name for this model.

E.g. "Shop Location".

Default: MyApp::Model::CDBI::ShopLocation becomes "Shop Location".



=item column_monikers

Column monikers. Hash ref with (key: column name: value:
moniker).

Default: based on the column name. Override specific column names like this:

    column_monikers => { __PACKAGE__->default_column_monikers, url => "URL" },


=item data_form_validator

Validation rules for the data fields.

Default: no validation

Note that you need to provide the entire config hashref for
L<Data::FormValidator>.


=item rows_per_page

Number of rows per page when using a pager (which will happen unless
paging is disabled by setting this value is 0).

Default: 20

=back



=head2 Class::DBI configuration

=over 4

=item Stringified column


Let's say your Model class Book has a Foreign Key (FK) genre_id to the
Genre Model class.

In the list of Books, the Genre will just be displayed with this
identifier, whereas you really would like it to display the Genre name.

In the Genre model class, define the column group Stringify, like this:

  __PACKAGE__->columns(Stringify => qw/ name /);

This magic is performed by L<Class::DBI> and L<Class::DBI::AsForm>'s
to_field method.



=item Fields to display

  __PACKAGE__->columns(crud_view_columns => qw/ COLUMNS /);

Default: all columns.


=item Fields to display in lists

  __PACKAGE__->columns(crud_list_columns => qw/ COLUMNS /);

Default: all columns.

=back


=head2 Example

    use Data::FormValidator::Constraints qw(:regexp_common);

    __PACKAGE__->columns(Stringify => qw/ url /);

    __PACKAGE__->config(

        crud => {
            moniker => "URL",
            rows_per_page => 20,
            data_form_validator => {
                optional => [ __PACKAGE__->columns ],
                required => [ "url" ],
                constraint_methods => {
                    url => FV_URI(),
                },
                msgs => {
                    format => '%s',
                    constraints => {
                        FV_URI => "Not a URL",
                    },
                },
            },
        },
    );




=head1 CLASS METHODS


=head2 default_column_monikers()

Return hash ref with the default column monikers (display names) for
all columns.

You can use this to setup a Model's crud config like this:

    __PACKAGE__->config(
        crud => {
            column_monikers => { __PACKAGE__->default_column_monikers, url_id => "URL" };
        },
    );

=cut
sub default_column_monikers {
    my $pkg = shift;
    return( map { $_ => $pkg->default_column_moniker($_) } $pkg->columns );
}





=head2 default_column_moniker($column)

Return default name for $column.

Remove _id$ and ^id_.

Exemple: author_name_id --> Author Name

=cut
sub default_column_moniker {
    my $pkg = shift;
    my ($column) = @_;

    my $name = ucfirst(lc($column));
    $name =~ s/^id_//i;
    $name =~ s/_id$//i;

    $name =~ s/(.)_+(.)/ "$1 " . uc($2) /e;

    return($name);
}





=head1 AUTHOR

Johan Lindstrom <johanl �T cpan.org>



=head1 LICENSE

This library is free software . You can redistribute it and/or modify
it under the same terms as perl itself.

=cut

1;
