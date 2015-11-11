#!/usr/bin/env ruby

require 'optparse'
require 'yaml'
require './utils'

#
# Take a book, collect bibliographic data (MARCXML) and shelf it to the right place
#

#--
# HELPER FUNCTIONS
#++

# Parse commandline options
def parseOption()
	options = {:dryrun => false, :auto => false, :debug => false, :worldcat => true, :rename => false}
	OptionParser.new do |opts|
		opts.banner = "shelfer.rb [options]"
		opts.version = "0.1"

		opts.on("-fFILE", "File to shelf") { |f| options[:file] = f }
		opts.on("-n", "Dry-run") { |n| options[:dryrun] = true }
		opts.on("-a", "Auto") { |n| options[:auto] = true }
		opts.on("-d", "Debug") { |n| options[:debug] = true }
        opts.on("-r", "--rename-only", "Rename only, no shelfing") { |n| options[:rename] = true }
		opts.on("-w", "--noworldcat", "Do not use WorldCat") { |n| options[:worldcat] = false }
	end.parse!
	options[:input] = ARGV
	return options
end

# From non-option input extract search terms
# The returning hash contains some of these keys:
#   author, title, isbn, year, edition, fulltitle, lccn
def parseInput(args)
	# in case it is a full path, get only the filename part
	argstr = File.basename(args.join(" ").strip())
	# remove filename extensions
	while argstr.sub!(/\.[a-zA-Z2]{1,5}/,''); end
	# Case 1: LC control number
	if argstr.start_with?('lccn:') then
		return {'lccn' => argstr.sub!('lccn:','')}
	end
	# Case 2: worldcat query string
	tokens = argstr.split(/\b(author|isbn|keyword|title)=/).drop(1)
	if tokens.length > 1 then
		return Hash[*tokens]
	end
	# Case 3: ISBN10 or ISBN13
	for i in 0..(argstr.length - 13) do
		return {'isbn' => argstr[i..(i+12)]} if isbn13?(argstr[i..(i+12)])
	end
	for i in 0..(argstr.length - 10) do
		return {'isbn' => argstr[i..(i+9)]} if isbn10?(argstr[i..(i+9)])
	end
	# Case 4: Semicolon-separated pieces (probably filename without extension)
	tokens = argstr.split(";")
	ret = {}
	if tokens.length == 3 then # fulltitle;authors;year
		ret['fulltitle'] = tokens[0]
		ret['year'] = tokens[2].sub(/[^\d]/,'')
		if tokens[1] =~ /^([a-zA-Z]+-)?(.*)$/ then
			ret['author'] = $2 if $2.length > 0
		end
	elsif tokens.length > 1 then
		ret['fulltitle'] = tokens.shift
		author = tokens.drop_while{|x| x =~ /[^a-zA-Z\s]/}.first
		ret['author'] = author unless author.nil?
	else
		ret['fulltitle'] = argstr
	end
	ret['fulltitle'] = ret['fulltitle'].sub(/\(.*\)/,'').strip
	ret['fulltitle'].match(/\b(\d+)e$/) { |m|
		ret['edition'] = m[1]
		ret['fulltitle'].sub!(/\b\s*\d+e$/,'')
	}
	ret['title'] = ret['fulltitle'].sub(/\..*$/,'').strip()
	return ret
end

# main program of the shelfer
def main()
	options = parseOption

	# Parse command line options
	# Read in config file
	config = YAML::load_file(File.expand_path("~/.biblio/config.yaml"))

	puts config
	puts options
end

if __FILE__ == $0 then
	main
end

__END__

vim:set ts=4 sw=4 sts=4 et:
