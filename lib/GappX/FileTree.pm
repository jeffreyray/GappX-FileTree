package GappX::FileTree;

our $VERSION = 0.01;

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
                renderer => undef,
                customize => sub {
                    my ( $self ) = @_;
                    
                    my $pixrender = Gtk2::CellRendererPixbuf->new();
                    $self->gobject->pack_start( $pixrender, 0);
                    $self->gobject->set_attributes( $pixrender, 'stock-id', 2 );
                    
                    my $textrender = Gtk2::CellRendererText->new();
                    $self->gobject->pack_start( $textrender, 1 );
                    $self->gobject->set_attributes( $textrender, 'markup', 1 );
                    
                },
            )
        ]
    },
    lazy => 1,
);

has '+model' => (
    default => sub {
        Gapp::TreeStore->new(
            columns => [qw( Glib::String Glib::String Glib::String Glib::Boolean )],
            customize => sub {
                $_[0]->gobject->set_sort_func( 0, sub {
                    my ( $model, $itera, $iterb, $self ) = @_;
                    
                    my $dira = $model->get( $itera, 3 );
                    my $dirb = $model->get( $iterb, 3 );
                    my $texta = $model->get( $itera, 1 );
                    my $textb = $model->get( $iterb, 1 );
                    
                    no warnings;
                    $dirb <=> $dira || lc $texta cmp lc $textb;
                } );
                
                $_[0]->gobject->set_sort_column_id( 0, 'ascending' );
            },
        )
    },
    lazy => 1,
);


has 'path' => (
    is => 'rw',
    isa => 'Str',
    default => '.',
);

sub update {
    my ( $self ) = @_;
    
    $self->model->gobject->clear;
    
    my $m = $self->model->gobject;
    
    my $base = $self->path;
    
    my @path;
    
    my $iter = undef;
    
    find (
        sub {
            return if $File::Find::name =~ /\.git/;
            return if $_ eq '.';
            
            my $dir = $File::Find::dir;
            
            $dir =~ s/^\.//;
            
            my @dirs = split /\//, $dir;
            shift @dirs if @dirs && ! $dirs[0];
            
            # if this is a directory
            if ( -d $_ ) {
                
                if ( @path && ( ! @dirs || $path[-1] ne $dirs[-1] ) ) {
                    $iter = $m->iter_parent( $iter ) if $iter ;
                    pop @path;
                }
                
                my $i = $m->append( $iter );
                $m->set( $i, 0 => $_ , 1 => $_, 2 => 'gtk-directory', 3 => 1 );
                $iter = $i;
                push @path, $_;
            }
            # if this is a file
            else {
                my $i = $m->append( $iter );
                $m->set( $i, 0 => $_ , 1 => $_, 2 => 'gtk-new', 3 => 0 );
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


__END__

=pod

=head1 NAME

GappX::FileTree - FileTree widget for Gapp

=head1 SYNOPSIS


    use GappX::FileTree;

    $w = GappX::FileTree->new( path => 'path/to/view/ );

    $w->refresh;

    Gapp->main;

=head1 DESCRIPTION

GappX::FileTree is a TreeView widget for displaying the structure of a file
system. Directories expand and collapse and each item is displayed with an
icon.
  
=head1 OBJECT HIERARCHY

=over 4

=item L<Gapp::Object>

=item +-- L<Gapp::Widget>

=item ....+-- L<Gapp::TreeView>

=item ........+-- L<Gapp::FileTree>

=back

=head1 PROVIDED ATTRIBUTES

=ober 4

=item B<path>

=over 4

=item is rw

=item isa Str

=item default .

=back

The directory path to display in the widget.

=back

=head PROVIDED METHODS

=over 4

=item B<update>

Refresh the contents of the display. Call this after setting the C<path> attribute
or after changes have been made to the file system.

=head1 AUTHORS

Jeffrey Ray Hallock E<lt>jeffrey.hallock at gmail dot comE<gt>

=head1 COPYRIGHT & LICENSE

    Copyright (c) 2011-2012 Jeffrey Ray Hallock.

    This program is free software; you can redistribute it and/or
    modify it under the same terms as Perl itself.

=cut


