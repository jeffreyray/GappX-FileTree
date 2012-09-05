package GappX::FileTree;


use Moose;
extends 'Gapp::TreeView';

use Gapp::TreeStore;
use Gapp::TreeViewColumn;

use File::Find;

has '+columns' => (
    default => sub {
        [
            Gapp::TreeViewColumn->new(
                title => 'Files',
                name => 'files',
            )
        ]
    },
    lazy => 1,
);

has '+model' => (
    default => sub {
        Gapp::TreeStore->new( columns => [
            qw(
                Glib::String
                Glib::String
                Gtk2::Gdk::Pixbuf
                Glib::Boolean
            )
        ])
    },
    lazy => 1,
);


has 'path' => (
    is => 'rw',
    isa => 'Str',
    default => '.',
);

sub refresh {
    my ( $self ) = @_;
    
    $self->model->gobject->clear;
    
    my $m = $self->model->gobject;
    
    my $base = $self->path;
    my $cwd = $base;
    
    my @path;
    
    my $iter = undef;
    
    find (
        sub {
            return if $File::Find::name =~ /\.git/;
            return if $_ eq '.';
            
            my $dir = $File::Find::dir;
            $dir =~ s/^$base//;
            
            my @dirs = split /\//, $dir;
            shift @dirs if @dirs && ! $dirs[0];
            
            print "FILE: $File::Find::name\n";
            print "BASE: $base\n";
            print "DIR: $dir\n";
            
            print "DIRS SPLIT: ";
            print join "/", @path;
            print "    VS.    ";
            print join "/", @dirs;
            print "\n\n";
            
            # if the current file is higher up in the heirarchy
            #while ( @path > @dirs ) {
            #    $iter = $m->iter_parent( $iter );
            #    unshift @path;
            #}
            #
            # if this is a directory
            if ( -d $File::Find::name ) {
                my $i = $m->append( $iter );
                $m->set( $i, 0 => $_ , 1 => $_, 3 => 1 );
                $iter = $i;
                push @path, $_;
            }
            # if this is a file
            else {
                my $i = $m->append( $iter );
                $m->set( $i, 0 => $_ , 1 => $_, 3 => 0 );
                $iter = $1;
            }
        },
        $self->path
    );

}







package Gapp::Layout::Default;
use Gapp::Layout;

build 'GappX::FileTree', sub {
    my ( $l, $w ) = @_;
    my $gtkw = $w->gobject;
    $gtkw->set_model( $w->model->isa('Gapp::Object') ? $w->model->gobject : $w->model ) if $w->model;
};

1;
