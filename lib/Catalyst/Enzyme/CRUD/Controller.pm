package Catalyst::Enzyme::CRUD::Controller;
use base 'Catalyst::Base';

our $VERSION = 0.01;



use strict;
use Data::Dumper;
use Carp;



=head1 NAME

Catalyst::Controller::CRUD::Base - CRUD Controller Base Class

=head1 SYNOPSIS

See L<Catalyst::Enzyme>


=head1 PROPERTIES


=head2 model_class

The model class, set by you by calling set_model_class in the private
C<begin> action in each Controller class.

=cut
__PACKAGE__->mk_accessors('model_class');




=head1 METHODS

=head2 new()

Create new Controller.

=cut
sub new {
    my $self = shift->NEXT::new(@_);
    
    return($self);
}





=head1 METHODS - ACTIONS

These are the default CRUD actions.

You should read the source so you know what the actions do, and how
you can adjust or block them in your own code.

They also deal with form validation, messages, and errors in a certain
way that you could use (or not, you may have a better way) in your own
actions.


=head2 begin

Set up the default model and class for this Controller

This is one of the few methods that you probably always want to
define.

=cut



=head2 default

Forward to list.

=cut
sub default : Private {
    my ( $self, $c ) = @_;
    $c->forward('list');
}



=head2 list

Display list template

=cut

sub list : Local {
    my ( $self, $c ) = @_;
    my $model = $self->model_with_pager($c, $self->crud_config->{rows_per_page}, $c->req->param("page"));    
    $c->stash->{items} = [ $model->retrieve_all() ];
    $c->stash->{template} = 'list.tt';
}



=head2 view

Select a row and display view template.

=cut
sub view : Local {
    my ( $self, $c, $id ) = @_;
    $c->stash->{item} = $self->model_class->retrieve($id);
    $c->stash->{template} = 'view.tt';
}



=head2 add

Display add template

=cut
sub add : Local {
    my ( $self, $c ) = @_;
    $c->stash->{template} = 'add.tt';
}



=head2 do_add

Add a new row and redirect to list.

=cut
sub do_add : Local {
    my ($self, $c) = @_;

    $c->form( %{ $self->crud_config->{data_form_validator} || $self->default_dfv($c)});
    $c->form->success or return( $c->forward('add') );

    $self->run_safe($c,
        sub  { $self->model_class->create_from_form( $c->form ) },
        "add", "Could not create record",
    ) or return;

    $c->stash->{message} = "Record created OK";
    return( $c->res->redirect($c->uri_for('list')) );
}



=head2 edit

Display edit template.

=cut
sub edit : Local {
    my ( $self, $c, $id ) = @_;
    $c->stash->{item} = $self->model_class->retrieve($id);
    $c->stash->{template} = 'edit.tt';
}



=head2 do_edit

Edit a row and redirect to edit.

=cut
sub do_edit : Local {
    my ( $self, $c, $id ) = @_;
    
    $c->form( %{ $self->crud_config->{data_form_validator} || $self->default_dfv($c)});
    $c->form->success or return( $c->forward('edit') );

    $self->run_safe($c,
        sub  { $self->model_class->retrieve($id)->update_from_form( $c->form ) },
        "edit", "Could not update record",
    ) or return;


    $c->stash->{message} = "Record updated OK";
    return( $c->res->redirect($c->uri_for('edit', $id)) );
}



=head2 destroy

Destroy row and forward to list.

=cut
sub destroy : Local {
    my ( $self, $c, $id ) = @_;

    $self->run_safe($c,
        sub  { $self->model_class->retrieve($id)->delete },
        "list", "Could not delete record",
    ) or return;


    $c->stash->{message} = "Record deleted OK";
    return( $c->res->redirect($c->uri_for('list')) );
}



=head1 METHODS


=head2 default_dfv

Return hash ref with a default L<Data::FormValidator> config.

=cut
sub default_dfv {
    my ($self, $c) = @_;
    return({
        optional => [ $self->model_class->columns ],
        msgs => { format => '%s' },
    });
}



=head2 run_safe($c, $sub, $fail_action, $fail_message, @rest)

Run the $sub->(@rest) ref inside an eval cage, and return 1.

Or, if $sub dies, set stash->{message} to $fail_message,
stash->{error} to $@, log the error, shed a tear, and return 0.

=cut
sub run_safe {
    my ($self, $c, $sub, $fail_action, $fail_message, @rest) = @_;

    eval { $sub->() };
    $@ or return(1);

    my $message = $c->stash->{message} = $fail_message;
    $c->stash->{error} = $@;
    $c->log->error("$message: $@");
    $c->forward($fail_action);
    
    return(0);
}



=head2 set_model_class($c, $model_class_name)

Set the Model class for the Controller.

Set $self->model_class, and point $self->crud_config to the Model's
config->{crud}. Set crud_config keys:

 model_class
 model
 moniker (default)
 rows_per_page (default 20)
 column_monikers (default)

Return 1.

=cut
sub set_model_class {
    my ($self, $c, $model_class_name) = @_;

    $self->model_class($model_class_name);
    my $crud_config = $self->crud_config;
    $crud_config->{model_class} = $model_class_name;
    
    $crud_config->{moniker} ||= $self->class_to_moniker($model_class_name);
    defined($crud_config->{rows_per_page}) or $crud_config->{rows_per_page} = 20;  #default
    $crud_config->{column_monikers} ||= { $model_class_name->default_column_monikers() };

    my $crud_model = $c->comp($model_class_name);
    ref($crud_model) or die("Object for model class ($model_class_name) not found\n");
    $crud_config->{model} = $crud_model;

    $c->stash->{crud} = $crud_config;
    
    return(1);
}



=head2 crud_config()

Return hash ref with config values form the Model class'
config->{crud} (so model_class needs to be set).

=cut
sub crud_config {
    my ($self) = @_;

    my $model_class = $self->model_class or confess("No model_class defined in (" . ref($self) . '). Make sure you call "$self->set_model_class($c, "YOUR_MODEL_CLASS");" in the "begin" action' . "\n");

    $self->model_class->config->{crud} ||= {};  #Default to empty crud config
    my $crud_config = $self->model_class->config->{crud};
    
    return($crud_config);
}



=head2 class_to_moniker($class_name)

Return default moniker of $class_name.

Default is to take the last past of the $class_name, and split it on
lower/uppercase boundaries.

If one can't be figured out, return the $class_name.

=cut
sub class_to_moniker {
    my ($self) = shift;
    my ($class_name) = @_;

    $class_name =~ /::(\w+)$/ or return($class_name);
    my $moniker = $1;
    $moniker =~ s/([a-z])([A-Z])/$1 $2/g;
    
    return($moniker);
}





=head2 model_with_pager($c, $rows_per_page, $page)

Return either the current model class, or (if $rows_per_page > 0) a
pager for the current model class. $page indicates which page to
display in the pager (default to the first page).

Assign the pager to $c->stash->{pager}.

The Model class (or it's base class) must C<use L<Class::DBI::Pager>>.

=cut
sub model_with_pager {
    my ($self, $c, $rows_per_page, $page) = @_;
    
    my $model = $self->model_class;
    $rows_per_page or return($model);
    
    $model->can("pager") or die("Class '$model' does not have a 'pager' property and still the ($model->config->{crud}->{rows_per_page} > 0. You need to add a 'use Class::DBI::Pager;' to ($model) or it's Model base class to enable paging or set the 'rows_per_page' to 0 to disable paging\n");
    $model = $model->pager($rows_per_page, $page);
    $c->stash->{pager} = $model;

    return($model);
}





=head1 AUTHOR

Johan Lindstrom <johanl ÄT cpan.org>


=head1 LICENSE

This library is free software . You can redistribute it and/or modify
it under the same terms as perl itself.

=cut

1;
