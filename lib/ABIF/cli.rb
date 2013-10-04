require 'thor'
require 'tempfile'
require 'open3'
require 'abif'

module ABIF
	class CLI < Thor
		class_option :verbose, :type => :boolean
		class_option :version, :type => :boolean

		desc "test FILE", "Test validity of FILE"
		def test(filename)
			print_version if options[:version]
			puts ABIF::File.supported? filename, options.select{|option| [].include? option}
		end

		option :format, :type => :string, :default => 'dat'
		option :normalize, :type => :string, :default => 'none'
		desc "parse FILE", "parse FILE "
		def parse(filename)
			print_version if options[:version]

			f = ABIF::File.new filename, options.select{|option| [:normalize].include? option}
			refrence_datapoints = f.data['DATA_1'].size
			channels = f.data.keys.select{|channel| channel.include?('DATA_') && f.data[channel].size == refrence_datapoints}
			case options[:format]
			when 'csv'
				puts "index," << channels.join(",")
				refrence_datapoints.times do |i|
				puts "#{i}," << channels.map{|channel| f.data[channel][i]}.join(",")
				end
			when 'raw'
				f.data.each do |key, d|
					puts "#{key} (#{f.data_params[key].join(',')}): #{d.inspect}"
				end
			else
				puts "index\t" << channels.join("\t")
				refrence_datapoints.times do |i|
				puts "#{i}\t" << channels.map{|channel| f.data[channel][i]}.join("\t")
				end
			end
			exit 0
		end

		option :format, :type => :string, :default => 'png'
		option :size, :type => :string, :default => '5000,6000'
		option :normalize, :type => :string, :default => 'none'
		desc "plot FILE OUTFILE", "plot FILE into OUTFILE"
		def plot(filename, outfilename)
			print_version if options[:version]

			#colors = ['blue', 'green', 'black', 'red', 'orange', 'purple']

			f = ABIF::File.new filename, options.select{|option| [:normalize].include? option}
			tmpfile = Tempfile.new('abifcli.dat')

			refrence_datapoints = f.data['DATA_1'].size
			channels = f.data.keys.select{|channel| channel.include?('DATA_') && f.data[channel].size == refrence_datapoints}
			tmpfile.puts "index\t" << channels.join("\t")
			refrence_datapoints.times do |i|
				tmpfile.puts "#{i}\t" << channels.map{|channel| f.data[channel][i]}.join("\t")
			end
			tmpfile.close

			IO.popen(%w{gnuplot}, 'r+') do |gnuplot|
				gnuplot.puts "set terminal #{options[:format].inspect} size #{options[:size]}"
				gnuplot.puts "set output #{outfilename.inspect}"
				gnuplot.puts "set multiplot layout #{channels.size}, 1 title #{filename.inspect}"
				channels.each_with_index.map do |channel, i|
					gnuplot.puts "set title #{channel.inspect}"
					gnuplot.puts "unset key"
					gnuplot.puts "plot #{tmpfile.path.inspect} using 1:#{i + 2} with lines lt 1 lc rgb 'grey' lw 1"
				end
				gnuplot.puts "unset multiplot"
				gnuplot.puts "exit"
				gnuplot.close_write
			end

			tmpfile.unlink

			exit 0
		end
	
	private
	
		def print_version
			puts "abifcli version #{ABIF::VERSION}"
			exit 0
		end
	end
end
