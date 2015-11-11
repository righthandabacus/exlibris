#!/usr/bin/env ruby
# Unit testing

require './shelfer'

if __FILE__ == $0
    fail unless suffix('foobar.tar.bz2') == 'tar.bz2'
    fail unless suffix('foobar.pdf') == 'pdf'
    fail unless suffix('foo.bar.tar.gz') == 'bar.tar.gz'

    fail unless getISBN13('978202108378') == '1'
    fail unless isbn13?('9782021083781')
    fail unless not isbn13?('9782021083780')

    fail unless getISBN10('962171123') == '1'
    fail unless isbn10?('9621711231')
    fail unless not isbn10?('9621711230')
    fail unless getISBN10('962270378') == 'X'
    fail unless isbn10?('962270378x')
    fail unless isbn10?('962270378X')

    fail unless parseInput(['lccn:12-34567']) == {'lccn' =>'12-34567'}
    fail unless parseInput(['lccn:1234567']) == {'lccn' => '1234567'}
    fail unless parseInput(['author=foo bar','title=foo','foo keyword=bar bar']) == {'author' => 'foo bar ', 'title' => 'foo foo ', 'keyword' => 'bar bar'}
    fail unless parseInput(['foo bar (blah blah) 3e;john doe;2015']) == {"fulltitle"=>"foo bar", "year"=>"2015", "author"=>"john doe", "edition"=>"3", "title"=>"foo bar"}
    fail unless parseInput(['foo bar (blah blah) 3e;;2015']) == {"fulltitle"=>"foo bar", "year"=>"2015", "edition"=>"3", "title"=>"foo bar"}
    fail unless parseInput(['foo bar (blah blah) 3e;2015']) == {"fulltitle"=>"foo bar", "edition"=>"3", "title"=>"foo bar"}
    fail unless parseInput(['foo bar (blah blah) 3e;2015;john doe;2015']) == {"fulltitle"=>"foo bar", "author"=>"john doe", "edition"=>"3", "title"=>"foo bar"}
    fail unless parseInput(['long long title']) == {"fulltitle"=>"long long title", "title"=>"long long title"}
    fail unless getMarcFromLccn('00-044044')
end

__END__

vim:set ts=4 sw=4 sts=4 et:
