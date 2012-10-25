#! /usr/bin/ruby

################################################################################
## rename_files_by_msg_id.rb
##
## Processes the input files to find the Message-Id: field in the headers
## and rename the files to a name based on that message ID.  E.g. if a file
## contains the Message-Id: line:
##
##		Message-Id: <yB3h9.31187$ip3.1779472@twister.southeast.rr.com>
##
## the file will be renamed to:
##
##		yB3h9.31187$ip3.1779472@twister.southeast.rr.com
##
## All occurances of the characters "<", ">" and "/" are removed.
##
## If the user wishes to append an extension, it can be supplied on the command
## line via the argument "--extension".  E.g.:
##
##		ruby rename_files_by_msg_id.rb --files=*.txt --extension=.dat
##
## Dependencies: trollop
################################################################################

require 'rubygems'
require 'trollop'

def set_options()
	opts = Trollop::options do
		opt :files, 'Files to process', :type => :string
		opt :extension, 'New extension for renamed files', :type => :string
	end
	return opts
end

opts = set_options()

Trollop::die :files, 'Please specify the input files' if nil == opts[:files] || 0 == opts[:files].length
extension = opts[:extension] || ''

input_files = Dir.glob(opts[:files])
input_files.each do |file|
	msg_id = ''
	File.open(file, 'r') do |infile| 
		while ((line = infile.gets) && 0 == msg_id.length && ! /^$/.match(line))
			msg_id = line[12..-1] if /^Message-[iI][dD]:/.match(line)
		end
	end
	if (0 == msg_id.length)
		puts "Unable to find message id for #{file}.  File not renamed."
	else
		# Eliminate occurances of the characters "%", "<", ">", "/" and "\n"
		msg_id.gsub!(/[%<>\/\n]/, '')
		File.rename(file, msg_id + extension)
	end
end