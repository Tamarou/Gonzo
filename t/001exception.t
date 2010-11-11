use Test::More;
use Try::Tiny;

use_ok('Gonzo::Exception');


try {
    1 == 2 || Gonzo::Exception->throw('bad things');
}
catch {
    isa_ok($_, 'Gonzo::Exception');
    cmp_ok($_->message, 'eq', 'bad things', "Error message came through as expected.");
};

done_testing();
