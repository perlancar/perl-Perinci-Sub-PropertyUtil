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

    my $bs; # base schema (Rinci::metadata)
    my $ts; # per-type schema (Rinci::metadata::TYPE)
    my $bpp;
    my $tpp;

    # insert the property's schema into Rinci::Schema's data
    {
        # XXX currently we skip result/*
        last if $name =~ m!\Aresult/!;

        require Rinci::Schema;
        $bs = $Rinci::Schema::base;
        $bpp = $bs->[1]{"keys"}
            or die "BUG: Schema structure changed (1)";
        $bpp->{$name}
            and die "Property '$name' is already declared in base schema";
        if ($type) {
            if ($type eq 'function') {
                $ts = $Rinci::Schema::function;
            } elsif ($type eq 'variable') {
                $ts = $Rinci::Schema::variable;
            } elsif ($type eq 'package') {
                $ts = $Rinci::Schema::package;
            } else {
                die "Unknown/unsupported property type: $type";
            }
            $tpp = $ts->[1]{"[merge+]keys"}
                or die "BUG: Schema structure changed (2)";
            $tpp->{$name}
                and die "Property '$name' is already declared in $type schema";
        }
        ($bpp // $tpp)->{$name} = $schema;
    }

    # install wrapper
    if ($args{wrapper} && $INC{"Perinci/Sub/Wrapper.pm"}) {
        no strict 'refs';
        my $n = $name; $n =~ s!/!__!g;
        *{"Perinci::Sub::Wrapper::handlemeta_$n"} =
            sub { $args{wrapper}{meta} };
        *{"Perinci::Sub::Wrapper::handle_$n"} =
            $args{wrapper}{handler};
    }

    # install cmdline help hook
    if ($args{cmdline_help} && $INC{"Perinci/CmdLine.pm"}) {
        no strict 'refs';
        my $n = $name; $n =~ s!/!__!g;
        *{"Perinci::CmdLine::help_hookmeta_$n"} =
            sub { $args{cmdline_help}{meta} };
        *{"Perinci::CmdLine::help_hook_$n"} =
            $args{cmdline_help}{handler};
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
