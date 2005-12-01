use Test::More tests => 2;
use_ok( Catalyst::Test, 'BookShelf' );

ok( request('/')->is_success );
