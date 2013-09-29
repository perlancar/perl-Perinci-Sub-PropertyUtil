#!perl

use 5.010001;
use strict;
use warnings;

package Perinci::Sub::property::testprop1;
use Perinci::Sub::PropertyUtil qw(declare_property);

declare_property(
    name    => 'testprop1',
    type    => 'function',
    schema  => 'any*',
    wrapper => {
        meta => {
            v       => 2,
            prio    => 50,
            convert => 1,
            tags    => [qw/tag1 tag2/],
        },
        handler => sub {
            my ($self, %args) = @_;
            my $v    = $args{new} // $args{value} // 0;
            my $meta = $args{meta};
            return;
        },
    },
);

package main;

use Test::More 0.98;
use Test::Perinci::Sub::Wrapper qw(test_wrap);

{
    my $sub  = sub {};
    my $meta = {v=>1.1, testprop1=>1};
    test_wrap(
        name => 'forbid_tags',
        wrap_args => {sub => $sub, meta => $meta, forbid_tags=>['tag1']},
        wrap_status => 412,
    );
}

DONE_TESTING:
done_testing;
