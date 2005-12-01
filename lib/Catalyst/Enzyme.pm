package Catalyst::Enzyme;
use base 'Catalyst::Base';



our $VERSION = 0.06;



use strict;
use Data::Dumper;
use Carp;



=head1 NAME

Catalyst::Enzyme - CRUD framework for Catalyst



=head1 SYNOPSIS

    #Create app
    catalyst BookShelf
    cd BookShelf

    #Create View
    script\bookshelf_create.pl view TT Enzyme::TT

    #Create database
    ... left as an exercise for the reader (actually, see the tutorial) ...

    #Create Models for all tables
    script\bookshelf_create.pl model BookShelfDB Enzyme::CDBI dbi:SQLite:dbname=db/bookshelf.db

    #Create Controller
    script\bookshelf_create.pl controller Book Enzyme::CRUD BookShelfDB::Book


Browse to http://localhost:3000/book and see what it looks like
without any configuration.

See the L</TUTORIAL> below for a detailed example of the BookDB.



=head1 DESCRIPTION

Catalyst::Enzyme is a layer on top of the Catalyst framework providing
CRUD functionality for L<Class::DBI> models.

Enzyme uses convention and configuration to provide e.g. extensible
CRUD out-of-the-box, and a common way of dealing with error handling
etc.

It's not completely unlike L<Maypole> in this regard. However, at this
point Enzyme isn't as feature-rich as Maypole.

Enzyme is one way of bringing many Catalyst modules and concepts
together into a unified whole. There are other ways to do this
(obviously. This is, like... uh, Perl).


=head2 Documentation

First, look at these docs, and do the L</TUTORIAL>.

Then look at L</Further Documentation>.



=head1 WORKING WITH ENZYME


=head2 Introduction

Enzyme came about when I created Scaffolding CRUD code for some
tables. There was much duplication, both in Controllers and in
templates.

So I refactored.

The templates duplication resulted in
L<Catalyst::View::TT::ControllerLocal>, which allows you to override
templates or template fragments by placing them in a directory
specific to the Controller.

The Controller code duplication resulted in the class
L<Catalyst::Enzyme::CRUD::Controller>. This has since grown
significantly and now includes more robust CRUD behaviour, uniform
presentation of status and messages to the user.


=head2 Assumptions

Your application uses L<Class::DBI> based model classes.

You want CRUD functionality, either as part of your application
(perhaps as a mangagement interface for internal use), or just to get
started with something.

You are willing to read and understand the source (both code and
templates) in order to modify them. While Enzyme can get you started
faster and with less code, you need to make this your own
framework. Change it, adapt it to your needs.


=head2 Overview

At the bottom is a database table.

On top of the table there is a Catalyst L<Class::DBI> Model class
(which also inherits from L<Catalyst::Enzyme::CRUD::Model>). The Model
class provides some meta data so Enzyme can display the Model objects
properly.

For each Model class there is a CRUD Controller class (based on
L<Catalyst::Enzyme::CRUD::Controller> providing actions for L<create>,
L<edit>, etc.

There is a set of default TT templates to display the Model
objects. You can override templates per Controller.


=head2 Providing Meta Data

Refactoring meant moving details out of templates and into general
components. Sometimes this involved moving metadata out of the
application.

This information must be provided somehow, and the best we can do (if
it can't be figured out automatically) is to put it in one place. This
is done in the Model class' config->{crud} hash ref.

(Granted, some configurations are View related and really should be in
the View (i.e.the template?), but I don't see a way to do that right
now.)

See L<Catalyst::Enzyme::CRUD::Model> for details on what parameters
you should set for each Model class.


=head2 Adapting Controllers

Add new actions for new behaviour: Look at the existing ones.

Change existing actions: Copy-paste from the base class, then
refactor.

Disable actions.


=head2 Disabling default actions



=head2 Adapting Templates

Enzyme uses L<Catalyst::View::TT::ControlleraLocal>, so templates are
overridden per Controller directory.

Change layout from the off-the-shelf look: Edit templates in ./base/

Change layout per class: Copy template in ./base/ and put it in
./YOURCLASS/. Edit and refactor as needed.



=head2 Messages

$c->stash->{message}

css: .message

Template: header.tt


=head2 Form validation

L<Data::FormValidator>


=head2 Form validation errors

css: .error_text


=head2 Errors in the Controller

$c->stash->{message}, $c->stash->{error}

css: .error_text

Template: header.tt


=head2 Forward vs redirect

Enzyme will redirect (as opposed to forward) after any data modifying
action (the do_* actions).

The reason for this is that there shouldn't be any destructive url
lingering in the Location field in the browser (what happens when the
user reloads the /book/destroy/34 URL? It fails if course).


=head2 Internationalization

Not supported at the moment. There are a few texts coming from the
Controllers, but almost all text is in the templates.


=head2 Further Documentation

Read up on the config for your Model classes:
L<Catalyst::Enzyme::CRUD::Model>

Look through the templates in ./root/base and make sure you have a
basic understanding of what they do.

Read the source of L<Catalyst::Enzyme::CRUD::Controller> to understand
how you can use, adapt, and extend it. Or ignore it. You may have much
better ways of doing things, or totally different needs for your
application.



=head1 TUTORIAL

Let's take the Catalyst example BookDB application and see what it
looks like with only a CRUD layer on top of the database.

Note: this was done using Windows, so make sure you adapt the / vs \
to your filesystem conventions.

Browse to http://localhost:3000/ at regular intervals during the setup
to see the current state of the application.

If you're gonna do this yourself, the simplest thing is probably to do
it from the t/tutorial directory. That way the database create script
will be in place.

Rename the existing C<BookShelf> application directory to something
else, open up a shell in C<tutorial> and go ahead...



=head2 Create Catalyst application BookShelf

    catalyst BookShelf
    ... created files ...
    cd BookShelf

Run test

    prove -Ilib t

Start server

    script\bookshelf_server.pl

Browsing to http://localhost:3000/ gets us the welcome screen.



=head2 Edit lib/BookShelf.pm

Add DefaultEnd and FormValidator

    use Catalyst qw/-Debug Static::Simple DefaultEnd FormValidator/;

Remove the welcome message from the default action

    # Hello World
    $c->response->body( $c->welcome_message );

and replace it with

    $c->res->redirect("/book");

This url doesn't exist yet, but we'll create it soon (so don't try to
restart the server just yet).

Note that the test t/01app.t will fail from now on since a redirect
isn't is_success. Figure out what

    prove -Ilib -v t\01app.t

Since that test doesn't reflect what the application does anymore, you
should probably change it to this:

    use Test::More tests => 1;
    use_ok( Catalyst::Test, 'BookShelf' );

And the test pass again. That's nice.

    prove -Ilib t


=head2 Create TT View

    script\bookshelf_create.pl view TT Enzyme::TT
    ... created files ...

This creates a special Enzyme TT View, standard templates in
./root/base/, as well as a css file in ./root/static/css/ .

The Enzyme TT View allows for overloading template fragments based on
the Controller (e.g. BookShelf::Controller::Book). It also provides a few
utility methods for the templates.

You'll probably want to modify the templates and the style sheet later
on to alter the global look of the application.

You'll probably want to copy some standard templates from
C<./root/base/> to e.g. <./root/book/) and modify them in order to
alter the web pages for only that part of the application.



=head2 Create the database

The bookdb.sql file is available in the C<t/tutorial/database>
directory. It's probably a good idea to take a look at it to get an
idea of what it provides. The foreign key relationships are especially
interesting.

Note: Make sure you have L<DBI::Shell> installed before running C<dbish>.

    mkdir db
    dbish dbi:SQLite:dbname=db/bookshelf.db < ..\database\bookdb.sql


=head2 Create the CDBI Model

    script\bookshelf_create.pl model BookShelfDB Enzyme::CDBI dbi:SQLite:dbname=db/bookshelf.db
    ... created files ...

This creates the main CDBI class BookShelfDB, and table classes for
each table in the database.

While they work as it is, Enzyme could use some extra meta data about
the Model classes.



=head2 Configure the Book Model class

lib\BookShelf\Model\BookShelfDB\Book.pm

Add Add Class::DBI configuration:

    __PACKAGE__->columns(Stringify => "title");

Add crud configuration:

    __PACKAGE__->config(

        crud => {
            moniker => "Book",
            column_monikers => { __PACKAGE__->default_column_monikers, isbn => "ISBN" },
            rows_per_page => 10,
            data_form_validator => {
                optional => [ __PACKAGE__->columns ],
                required => [ qw/ title format genre /],
                constraint_methods => {
                    isbn => { name => "fv_isbn", constraint => qr/^[\d-]+$/ },
                },
                missing_optional_valid => 1,
                msgs => {
                    format => '%s',
                    constraints => {
                        fv_isbn => "Not an ISBN number",
                    },
                },
            },
        },
    );


A few things to note:

            moniker => "Book",

The C<Moniker> is optional and would have defaulted to Book
anyway. But that's how to do it.

            column_monikers => { __PACKAGE__->default_column_monikers, isbn => "ISBN" },

The column_monikers is optional, and except for the ISBN, this was
also unnecessary. But since we had to override it, we had to start
with the deafult column monikers.

            rows_per_page => 10,

The rows_per_page controls paging when listing the Books. The deafult
is 20 rows, but Books take a little more vertical space, so we'll go
with 10. Actually, if you'd like to see the paging feature right away,
set it to 3. Or you could just add a few books...

(Yes, this should really be a View configuration somehow.)

            data_form_validator => {
                optional => [ __PACKAGE__->columns ],
                required => [ qw/ title format genre /],
                constraint_methods => {
                    isbn => { name => "fv_isbn", constraint => qr/^[\d-]+$/ },
                },
                missing_optional_valid => 1,
                msgs => {
                    format => '%s',
                    constraints => {
                        fv_isbn => "Not an ISBN number",
                    },
                },
            },

This chunk is passed to L<Data::FormValidator>, so you should
familiarize yourself with that module at some point. The default form
validator config makes all columns optional.

                missing_optional_valid => 1,

This should always be in your dfv config, otherwise updates with empty
values will not work.

Read more about the configuration values in
L<Catalyst::Enzyme::CRUD::Model>.



=head2 Create Book CRUD Controller

There are other model classes, but let's just finish the table C<book>
by adding a CRUD controller.

    script\bookshelf_create.pl controller Book Enzyme::CRUD BookShelfDB::Book
    ... created files ...


The most important thing to note in the created
BookShelf\Controller\Book.pm is the sub where the Model file is
specified:

    sub model_class {
        return("BookShelf::Model::BookShelfDB::Book");
    }



=head2 Test the book CRUD

Now we finally have all the required components in place to take a
look at the Book table. But why not run the tests again.

    prove -Ilib t

All test should pass (and they don't really do much anyway. At least
the Controller tests make a request to the default action).

Run the server:

    script\bookshelf_server.pl

When you surf around at L<http://localhost:3000/book> and check out
all the books you may notice that Borrower is a number, and so is
Genre. That's because we haven't configured the other Models with a
Stringify column yet.

When you add new Books, note how the C<title> is mandatory. See what
happens if you omit it.

Also note how the ISBN number is optional, but if there is anything
entered, it must abide by the constraint. (I have no idea whether
that's actually a proper constraint for ISBN numbers).

If you set the rows_per_page to 3, you should see the paging in
action. If not, add a few books.



=head2 Add links between the tables

Edit the root/base/header.tt and add this inside the content div so we
can jump between the tables:

    <a href="/book">Book</a> |
    <a href="/borrower">Borrower</a> |
    <a href="/genre">Genre</a> |
    <a href="/format">Format</a>
    <br />


=head2 Configure Models for the other tables

=over 4

=item lib\BookShelf\Model\BookShelfDB\Borrower.pm

    use Data::FormValidator::Constraints qw(:regexp_common);
    __PACKAGE__->columns(Stringify=> qw/name/);
    __PACKAGE__->config(
        crud => {
            data_form_validator => {
                optional => [ __PACKAGE__->columns ],
                required => [ "name" ],
                constraint_methods => {
                    url => FV_URI(),
                    email => Data::FormValidator::Constraints::email(),
                },
                missing_optional_valid => 1,
                msgs => {
                    format => '%s',
                    constraints => {
                        FV_URI => "Not a URL",
                        email => "Not an email",
                    },
                },
            },
        },
    );


A few notes:

The normal way to import the default FormValidator::Constraints would be

    use Data::FormValidator::Constraints qw(:regexp_common :closures);

and the C<:closures> group imports subs like C<email> and C<phone>
into this namespace. But... since this is our model class, there is
already field accessors by that names in our symbol table, and that
will clash. Hence the use of
C<Data::FormValidator::Constraints::email> in the config.

    __PACKAGE__->columns(Stringify=> qw/name/);

Thanks to the Stringify, the Borrower now displays as the name, not
the PK in the Book listing.


=item lib\BookShelf\Model\BookShelfDB\Genre.pm

    __PACKAGE__->columns(Stringify=>qw/name/);


=item lib\BookShelf\Model\BookShelfDB\Format.pm

    __PACKAGE__->columns(Stringify=>qw/name/);

=back



=head2 Create Controllers for the rest of the tables

    script\bookshelf_create.pl controller Borrower Enzyme::CRUD BookShelfDB::Borrower
    script\bookshelf_create.pl controller Genre Enzyme::CRUD BookShelfDB::Genre
    script\bookshelf_create.pl controller Format Enzyme::CRUD BookShelfDB::Format


Now restart the server and see how much prettier the Books listing is.


=head2 And we're done

That's all folks!

Now read the rest of the documentation to learn how to modify the
application further and perhaps start building on top of it.

L</Further Documentation>


=head1 SEE ALSO



=head1 TODO

Tests, lots of tests!

Yes, there's a todo-list.



=head1 AUTHOR

Johan Lindstrom <johanl ÄT cpan.org>


=head1 LICENSE

This library is free software . You can redistribute it and/or modify
it under the same terms as perl itself.

=cut

1;
