package WWW::Mechanize::XML;

use vars qw( $VERSION );
$VERSION = '0.01';

use strict;
use warnings;

use base qw( WWW::Mechanize );

use XML::LibXML;
use File::Temp qw( tempfile );

=head1 NAME

WWW::Mechanize::XML - adds an XML DOM accessor to L<WWW::Mechanize>.

=head1 VERSION

This document describes WWW::Mechanize::XML version 0.01

=head1 SYNOPSIS

    use WWW::Mechanize::XML;
    use Test::More;
    my $mech = WWW::Mechanize::XML->new();
    
    ok($mech->get('http://flickr.com/service/?method=getPhotos'), 'got photo list');
    lives_ok {
        $dom = $mech->xml();
    } 'got xml dom object';
    $root = $dom->domumentElement();
    my @photos = $root->findnodes('/rsp/photos/photo');
    is(scalar @photos, 23, 'got 23 photos');

=head1 DESCRIPTION

This is a subclass of L<WWW::Mechanize> that provides an XML DOM accessor which
parses the contents of the response and returns it as a 
L<XML::LibXML::Document>. The motivation for developing this module was to 
facilitate testing of XML APIs and XHTML web pages.

=head1 METHODS 

=head2 new( %mech_options, parser_options => {} )

Creates a new C<WWW::Mechanize::XML> object with the specified mechanize and
parser options. Parser options will be passed directly to the 
L<XML::LibXML::Parser>. If no paresr options are passed in, defaults are used. 
Please see the documentation for L<XML::LibXML::Parser> for option descriptions 
and default values. Valid parser options accepted are:

=over
=item validation
=item recover
=item recover_silently
=item expand_entities
=item keep_blanks
=item pedantic_parser
=item line_numbers
=item load_ext_dtd
=item complete_attributes
=item expand_xinclude
=item clean_namespaces
=back

=cut

my @valid_parser_options = qw(
    validation
    recover
    recover_silently
    expand_entities
    keep_blanks
    pedantic_parser
    line_numbers
    load_ext_dtd
    complete_attributes
    expand_xinclude
    clean_namespaces
);

sub new {
  my ( $class, %args ) = @_;
  
  my $parser_options = delete $args{parser_options} || {};
  # use catalog to speed up parsing if DTD is loaded 
  my ( $catalog_fh, $catalog_file ) = tempfile();
  my $parser = XML::LibXML->new();
  $parser->load_catalog( $catalog_file );
  
  # set each parser option is valid
  foreach my $option (keys %$parser_options) {
      if (grep { $_ =~ $option } @valid_parser_options) {
          $parser->$option( $parser_options->{$option} );
      } else {
          die "Invalid parser option: $option";
      }
  }
  
  my $self = bless WWW::Mechanize->SUPER::new( %args ), $class;
  $self->{xml_parser} = $parser;
  return $self;
}

=head2 xml()

Returns a L<XML::LibXML::Document> object created from the response content by
calling the L<XML::LibXML::Parser> parse_string() method. Any parsing errors 
will propogate up.

=cut

sub xml {
  my $self = shift;
  
  my $dom = $self->{xml_parser}->parse_string( $self->content() );
  $dom->indexElements(); # speed up XPath queries for static documents
  return $dom;
}

=head1 DEPENDENCIES

L<WWW::Mechanize>
L<XML::LibXML>
L<File::Temp>

=head1 BUGS

Please report any bugs you find via the CPAN RT system.
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Froody>

=head1 AUTHOR

Copyright Fotango 2006.  All rights reserved.

This module is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

This module has been worked on by the following people:

    Barry White <bwhite@fotango.com>

You can reach the current maintainers by emailing us at C<cpan@fotango.com>,
but if you're reporting bugs I<please> use the RT system mentioned above so
we can track the issues you report.

=cut

1;

__END__
