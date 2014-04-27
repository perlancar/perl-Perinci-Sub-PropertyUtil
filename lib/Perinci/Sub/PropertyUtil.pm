package Perinci::Sub::PropertyUtil;

use 5.010001;
use strict;
use warnings;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(
                       declare_property
               );

# VERSION

sub declare_property {
    my %args   = @_;
    my $name   = $args{name}   or die "Please specify property's name";
    my $schema = $args{schema} or die "Please specify property's schema";
    my $type   = $args{type};

    $name =~ m!\A((result)/)?\w+\z! or die "Invalid property name";

    # insert the property's schema into Sah::Schema::Rinci
    {
        # XXX currently we skip result/*
        last if $name =~ m!\Aresult/!;

        require Sah::Schema::Rinci;
        my $p = $Sah::Schema::Rinci::SCHEMAS{rinci_function}[1]{_prop}
            or die "BUG: Schema structure changed (1)";
        $p->{$name}
            and die "Property '$name' is already declared in schema";
        # XXX we haven't injected $schema
        $p->{$name} = {};
    }

    # install wrapper handler
    if ($args{wrapper} && $INC{"Perinci/Sub/Wrapper.pm"}) {
        no strict 'refs';
        my $n = $name; $n =~ s!/!__!g;
        *{"Perinci::Sub::Wrapper::handlemeta_$n"} =
            sub { $args{wrapper}{meta} };
        *{"Perinci::Sub::Wrapper::handle_$n"} =
            $args{wrapper}{handler};
    }

    # install Perinci::CmdLine help handler
    if ($args{cmdline_help} && $INC{"Perinci/CmdLine.pm"}) {
        no strict 'refs';
        my $n = $name; $n =~ s!/!__!g;
        *{"Perinci::CmdLine::help_hookmeta_$n"} =
            sub { $args{cmdline_help}{meta} };
        *{"Perinci::CmdLine::help_hook_$n"} =
            $args{cmdline_help}{handler};
    }

    # install Perinci::Sub::To::POD help hook
    if ($args{pod} && $INC{"Perinci/Sub/To/POD.pm"}) {
        no strict 'refs';
        my $n = $name; $n =~ s!/!__!g;
        *{"Perinci::Sub::To::POD::hookmeta_$n"} =
            sub { $args{pod}{meta} };
        *{"Perinci::Sub::To::POD::hook_$n"} =
            $args{pod}{handler};
    }
}

1;
# ABSTRACT: Utility routines for Perinci::Sub::Property::* modules

=head1 SYNOPSIS


=head1 FUNCTIONS

=head2 declare_property


=head1 SEE ALSO

L<Perinci>

Perinci::Sub::Property::* modules.

=cut
