package Module::LoadVersion;

use strict;
use warnings;

use Digest::MD5 qw(md5_hex);
use Module::Info;
use Carp qw(confess carp);

our $VERSION = '0.1';

our %loaded_modules;

# ABSTRACT: Load specific module version from your @INC

sub import {
    shift;
    _check_args(@_);
    _load_modules(@_);
}

sub _load_modules {
    my %modules = @_;

    while ( my ( $module, $version ) = each %modules ) {

        confess "module version not defined for $module"
            unless $version;

        next if module_name($module => $version);

        my @modules = Module::Info->all_installed($module);
        my ($module_file) = grep { $_->version eq $version } @modules;
        my $module_md5 = 'mod_'.md5_hex($module.$version); 
 
        my $file_content = do {
            local $/;
            my $file = $module_file->file;
            open my $fh, '<', $file or die "cannot open file $file : $!";
            <$fh>;
        };

        $file_content =~ s/package $module/package $module_md5/;
        eval "$file_content" or do {
            confess "failed to load module $module : $@";
        };

        $loaded_modules{ $module.$version } = $module_md5;
    }
}

sub _check_args {
    if ( @_ % 2 ) {
        confess "Incorrect use, got @_";
    }
}

sub load_module {
    shift if @_ % 2;
    my ( $module, $version ) = @_;

    _load_modules($module => $version);
    return module_name($module => $version );
}

sub module_name {
    shift if @_ % 2;
    return $loaded_modules{$_[0].$_[1]}; 
}

=head1 NAME

Module::LoadVersion

=head1 DESCRIPTION

Load a specific module version from your @INC

=head1 WARNING

It's probably not a wise idea to use this code in production ;)

=head1 SYNOPSIS

use Module::LoadVersion Foo => 0.1, Bar => 2.0, Foo::Bar => 0.3;

my $foo_class = Module::LoadVersion->module_name('Foo');

my object = $foo->new;

# or

use Module::LoadVersion;

my $foo = Module::LoadVersion->load_module(Foo => 0.1);

my $foot2 = Module::LoadVersion->load_module(Foo => 0.2);

$foo->foo; # bar

$foo->foo; # baz

=cut

1;
