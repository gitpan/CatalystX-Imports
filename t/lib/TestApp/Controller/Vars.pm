package TestApp::Controller::Vars;
use warnings;
use strict;

use base 'Catalyst::Controller';

use CatalystX::Imports
    Context => ':all',
    Vars    => { Stash => [qw( $foo @bar %baz )] };

sub test_self:  Local { $_[1]->res->body( ref $self ) }
sub test_ctx:   Local { $_[1]->res->body( ref $ctx ) }
sub test_args:  Local { $_[1]->res->body( join ', ', @args ) }

sub test_stash: Local {
    $foo = 23;
    $ctx->forward('test_stash_val');
}

sub test_stash_val: Private {
    $ctx->res->body( $ctx->stash->{foo} );
}

sub test_array:  Local   { push @bar, 23 ; $ctx->forward('test_array2') }
sub test_array2: Private { push @bar, 42 ; $ctx->forward('test_array3') }
sub test_array3: Private { $ctx->res->body( join ', ', @{ $ctx->stash->{bar} } ) }

sub test_hash:  Local   { $baz{foo} = 23 ; $ctx->forward('test_hash2') }
sub test_hash2: Private { $ctx->res->body( $ctx->stash->{baz}{foo} ) }

sub test_args_chained: Chained PathPart('vars') CaptureArgs(2) {
    $ctx->res->body( join ', ', @args );
}
sub test_args_phases: Chained('test_args_chained') {
    $ctx->res->body( join '; ', $ctx->res->body, join ', ', @args );
    $ctx->forward('test_args_forward', [qw(x y z)]);
}
sub test_args_forward: Private {
    $ctx->res->body( join '; ', $ctx->res->body, join ', ', @args );
}

sub test_passed_args: Local {
    $ctx->forward('test_passed_args_rcvr', [@args])
}
sub test_passed_args_rcvr: Private {
    $ctx->res->body( join ', ', @args );
}

1;
