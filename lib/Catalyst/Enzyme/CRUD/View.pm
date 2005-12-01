package Catalyst::Enzyme::CRUD::View;

our $VERSION = '0.01';



use strict;
use Data::Dumper;
use HTML::Element;



=head1 NAME

Catalyst::View::Enzyme::CRUD::View - Catalyst View helper methods
for CRUD templates

=head1 SYNOPSIS



=head1 DESCRIPTION

This is a mix-in for any (TT) View using the Enzyme CRUD.

=cut





=head2 METHODS


=head2 element_req($c, $action_name, $column, [$type = "text"])

Return new HTML::Element for $column.

If the current action is $action_name, fill in data from the request.

If there is no $column field in the model class, return a HTML <INPUT
type="$type"> field with that name.

=cut
sub element_req {
    my ($self, $c, $action_name, $column, $type) = @_;
    $type ||= "text";

    my $element = eval { $c->stash->{crud}->{model_class}->to_field($column) } ||
            HTML::Element->new("input", name => $column, type => $type);

    if($c->action->name eq $action_name) {
        my $value = $c->req->param($column);
        if($element->tag eq  "textarea") {
            $element = $element->push_content($value);
        } elsif($element->tag eq "select") {
            for my $option ($element->content_list) {
                $option->attr("selected", "1"), last if($option->attr("value") eq $value);
            }
        } else {
            $element->attr("value", $value);
        }
    }
    
    return($element);
}





=head2 $c->this_request_except(%new_params)

Return uri which is identical to the current request, except
overwritten with the new parameters in %new_params.

=cut
use URI;
use URI::QueryParam;
sub Catalyst::this_request_except {
    my ( $c, %new_params ) = @_;

    my $uri = $c->req->uri->clone;
    while(my ($key, $val) = each(%new_params)) {
        $uri->query_param($key, $val);
    }

    return($uri);
}



=head1 AUTHOR

Johan Lindstrom <johanl ÄT cpan.org>

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
