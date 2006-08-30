#!perl

use strict;
use warnings;

use Test::More tests => 32;
use Test::Exception;
use Cwd;
my $cwd = getcwd();

use_ok('WWW::Mechanize::XML');
my $mech;

foreach my $option (qw(
    quiet
    stack_depth
    )) {
    foreach (0..1) {
        $mech = WWW::Mechanize::XML->new( $option => $_ );
        is($mech->$option, $_, "Mechanize option set: $option => $_");
    }
}

foreach my $option (qw(
    validation
    recover
    expand_entities
    keep_blanks
    pedantic_parser
    line_numbers
    load_ext_dtd
    complete_attributes
    expand_xinclude
    clean_namespaces
    )) {
    foreach (0..1) {
        $mech = WWW::Mechanize::XML->new( parser_options => { $option => $_ } );
        is($mech->{xml_parser}->$option, $_, "Mechanize parser option set: $option => $_");
    }
}

foreach my $option (qw(
    foo
    bar
    )) {
    throws_ok {
        $mech = WWW::Mechanize::XML->new( parser_options => { $option => 1 } );
    } qr/Invalid parser option/, "Invalid parser option: $option";
}

$mech = WWW::Mechanize::XML->new();
my $dom;

ok($mech->get("file://$cwd/t/files/valid.xml"), 'got valid xml file');
lives_ok {
    $dom = $mech->xml();
} 'got xml dom from valid xml';
isa_ok($dom, 'XML::LibXML::Document');

ok($mech->get("file://$cwd/t/files/invalid.xml"), 'got invalid xml file');
throws_ok {
    $dom = $mech->xml();
} qr/Opening\sand\sending\stag\smismatch/, 'xml is invalid';
