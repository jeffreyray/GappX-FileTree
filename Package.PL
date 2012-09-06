use Module::Package;
my $pack = Module::Package->new(
    name => 'GappX::FileTree',
    version_from => 'lib/GappX/FileTree.pm',
    prereq_pm => {
        'Gapp' => '0.46',
        'MooseX::Types::Moose' => 0,
    },
    abstract_from => 'lib/GappX/FileTree.pm',
    author => 'Jeffrey Ray Hallock <jeffrey dot hallock at gmail dot com>',
    exclude => [ '*.komodoproject', '.komodotools', '.git' ],
);
$pack->package;


