require 'net/http'
require 'uri'

# Given filename, try to deduce its extension
def suffix(filename)
	return filename.split(".").drop(1).reverse.take_while{|x| x =~ /^[a-zA-Z2]{1,5}$/}.reverse.join(".")
end

# Given first 9 digits of ISBN, compute the check digit
def getISBN10(isbn)
	fail unless isbn.class == String and isbn.match(/^\d{9}$/)
	r = - isbn.split(//).each_with_index.map{|digit,idx| digit.to_i * (10-idx)}.inject(:+) % 11
	return (r==10)?'X':r.to_s
end

# Given first 12 digits of ISBN-13, compute the check digit
def getISBN13(isbn)
	fail unless isbn.class == String and isbn.match(/^\d{12}$/)
	r = - isbn.split(//).each_with_index.map{|digit,idx| digit.to_i * [1,3][idx%2]}.inject(:+) % 10
	return r.to_s
end

# Verify a ISBN is valid
def isbn10?(isbn)
	return isbn.class == String && isbn.upcase =~ /^\d{9}[\dX]$/ && isbn[9].upcase == getISBN10(isbn[0..8])
end

# Verify a ISBN-13 is valid
def isbn13?(isbn)
	return isbn.class == String && isbn.upcase =~ /^\d{13}$/ && isbn[12] == getISBN13(isbn[0..11])
end

# Obtain MARC XML of the given LCCN from the Library of Congress
def getMarcFromLccn(lccn)
    url = "http://lccn.loc.gov/#{lccn}/marcxml"
    Net::HTTP.get_response(URI.parse(url)).body + '<!-- ' + Time.now.to_s + ' -->'
end


