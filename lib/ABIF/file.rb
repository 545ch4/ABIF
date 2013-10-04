require 'zlib'
require 'openssl'

module ABIF
	# This class holds the FSA/HID file format data. It's initialized given the filename or an IO object.
	# Options are:
	# [:normalize] All channels are normalized with respect to their 500-datapoint-tail assuming it means-up to 0.
	class File
		attr_reader :filetype, :fileversion, :data, :data_params

		def self.supported?(filename_or_io, options = {})
			ft = nil
			fv = 0
			begin
				io = filename_or_io.respond_to?(:seek) ? filename_or_io : ::File.open(filename_or_io, 'rb')
				(ft, fv) = io.read(6).unpack('A4S>')
			rescue Exception => e
				raise IOError.new "Error reding ABIF file: #{e}"
			ensure
				io.close unless io.nil? || !io.respond_to?(:close)
			end
			return ft == 'ABIF' && fv >= 100
		end

		def initialize(filename_or_io, options = {})
			@data = {}
			@data_params = {}
			@named_data = {}
			@some_counter = 1

			@decipher = OpenSSL::Cipher.new('DES-CBC')
			@decipher.key = "W\xB6\xBF\xBC\xFE\xBA1&" # [87, -74, -65, -68, -2, -70, 49, 38].pack('c*')
			@decipher.iv = "\x8E\x129\x9C\aroZ" # [-114, 18, 57, -100, 7, 114, 111, 90].pack('c*')

			io = nil
			begin
				io = filename_or_io.respond_to?(:seek) ? filename_or_io : ::File.open(filename_or_io, 'rb')
				(@filetype, @fileversion) = io.read(6).unpack('A4S>')
				raise IOError.new('Not an ABIF file') unless @filetype == 'ABIF' && @fileversion >= 100
				header_dir_entry = unpack_dir_entry(io)
				io.seek(header_dir_entry[:data_offset])
				header_dir_entry[:num_elements].times do
					dir_entry = unpack_dir_entry(io)
					old_pos = io.pos
					if dir_entry[:element_size] * dir_entry[:num_elements] > 4
						io.seek(dir_entry[:data_offset])
					else
						io.seek(-8, IO::SEEK_CUR)
					end

					@data_params["#{dir_entry[:name]}_#{dir_entry[:number]}"] = [dir_entry[:element_type], dir_entry[:element_size], dir_entry[:num_elements], dir_entry[:data_size]]
					@data["#{dir_entry[:name]}_#{dir_entry[:number]}"] = unpack_data(dir_entry[:element_type], dir_entry[:element_size], dir_entry[:num_elements], dir_entry[:data_size], io)
					io.seek(old_pos)
				end
			rescue Exception => e
				raise IOError.new "Error reding ABIF file: #{e}"
			ensure
				io.close unless io.nil? || !io.respond_to?(:close)
			end

			if options[:normalize] && options[:normalize] != 'none'
				data_length = @data['DATA_1'].size
				@data.keys.select{|key| key.include?('DATA_') && @data[key].size == data_length}.each do |key|
					mean = 0.0
					if options[:normalize] == 'head'
						mean = @data[key][500..(500+[499,data_length].min)].inject(0.0){|t, datapoint| t + datapoint} / [499,data_length].min.to_f
					elsif options[:normalize] == 'tail'
						mean = @data[key][-500..-1].inject(0.0){|t, datapoint| t + datapoint} / 500.0
					end
					@data[key] = @data[key].map{|i| i - mean}
				end
			end
		end

	private

		def some_counter
			@some_counter = @some_counter + 1
		end

		def unpack_dir_entry(io)
			dir_entry = {}
			dir_entry[:name], dir_entry[:number], dir_entry[:element_type], dir_entry[:element_size], dir_entry[:num_elements], dir_entry[:data_size], dir_entry[:data_offset], dir_entry[:data_handle] = io.read(28).unpack('A4L>S>S>L>L>L>L>')
			dir_entry
		end

		def unpack_data(type, size, num, data_size, io)
			# TODO Checksum
			#   Fields: CkSm, CkSm-1, CkSm-2, CLst
			#   split by ':' 
			#   Objects: java.util.Collections.synchronizedSortedSet/java.util.SortedSet/TreeSet/java.util.SortedSet
			# 	MD5 BASE64Encoder "ABIFAdmin", "IdeABu++inghedsmiteCLI4S3", "81tingpH!sh1es", "eleMENT5ConsOLI45Dated", "AloysiusANdauGUST1NE"
			data = io.read(data_size)
			case type
			when 0 # IllegalType -1-byte(s) wide
				"illegal type 'IllegalType'(#{type})"
			when 1 # Byte 1-byte(s) wide
				data.unpack('C' * num)
			when 2 # Char 1-byte(s) wide
				data.unpack('C' * num)
			when 3 # Word 2-byte(s) wide
				data.unpack('S>' * num)
			when 4 # Short 2-byte(s) wide
				data.unpack('s>' * num)
			when 5 # Long 4-byte(s) wide
				data.unpack('l>' * num)
			when 6 # Rational 8-byte(s) wide
				struct = {}
				struct[:numerator], struct[:denumerator] = data.unpack('l>l>' * num)
				struct
			when 7 # Float 4-byte(s) wide
				data.unpack('g' * num)
			when 8 # Double 8-byte(s) wide
				data.unpack('G' * num)
			when 9 # BCD 0-byte(s) wide
				"unsupported type 'BCD'(#{type})"
			when 10 # Date 4-byte(s) wide
				struct = {}
				struct[:year], struct[:month], struct[:day] = data.unpack('s>CC' * num)
				struct
			when 11 # Time 4-byte(s) wide
				struct = {}
				struct[:hour], struct[:minute], struct[:second], struct[:hsecond] = data.unpack('CCCC' * num)
				struct
			when 12 # Thumb 10-byte(s) wide
				struct = {}
				struct[:d], struct[:u], struct[:c], struct[:n] = data.unpack('l>l>CC' * num)
				struct
			when 13 # Boolean 1-byte(s) wide
				data.unpack('C' * num).map{|x| x == 0 ? false : true}
			when 14 # Point 4-byte(s) wide
				struct = {}
				struct[:v], struct[:h] = data.unpack('s>s>' * num)
				struct
			when 15 # Rect 8-byte(s) wide
				struct = {}
				struct[:top], struct[:left], struct[:bottom], struct[:right] = data.unpack('s>s>s>s>' * num)
				struct
			when 16 # VPoint 8-byte(s) wide
				struct = {}
				struct[:v], struct[:h] = data.unpack('l>l>' * num)
				struct
			when 17 # VRect 16-byte(s) wide
				struct = {}
				struct[:top], struct[:left], struct[:bottom], struct[:right] = data.unpack('l>l>l>l>' * num)
				struct
			when 18 # PString 1-byte(s) wide
				data[1..data[0].unpack("C").first]
			when 19 # CString 1-byte(s) wide
				data[0..-2]
			when 20 # Tag 8-byte(s) wide
				struct = {}
				struct[:name], struct[:number] = data.unpack('l>l>' * num)
				struct
			when 21 # DeltaLZWcompression 1-byte(s) wide
				# TODO: What is a "DeltaLZWcompression" compression? Implement it the right way.
				"unsupported compression 'DeltaLZWcompression'(#{type})"
			when 22 # LZWcompression 1-byte(s) wide
				unlzw(data.unpack('C' * size * num))
			when 23 # Directory 28-byte(s) wide
				unpack_dir_entry(data)
			when 24 # UserType 1-byte(s) wide
				"user type 'UserType'(#{type}) => #{num} elements of #{size}-byte wide struct: " << data.unpack('C' * size * num).join(', ')
			when 25 # CustomUserType 1-byte(s) wide
				"user type 'CustomUserType'(#{type}) => #{num} elements of #{size}-byte wide struct: " << data.unpack('C' * size * num).join(', ')
			when 26 # IString 1-byte(s) wide
				# TODO: What is an "IString"? Implement it the right way.
				data
			when 27 # compressedByte 1-byte(s) wide
				decrypt(data).unpack('C' * data_size)
			when 28 # compressedShort 1-byte(s) wide
				decrypt(data).unpack('C' * (data_size / 2))
			when 29 # compressedIString 1-byte(s) wide
				# TODO: What is an "IString"? Implement it the right way.
				decrypt(data)
			when 30 # compressedChar 1-byte(s) wide
				decrypt(data).unpack('C' * data_size)
			when 31 # compressedLong 1-byte(s) wide
				decrypt(data).unpack('l>' * (data_size / 4))
			when 32 # compressedDouble 1-byte(s) wide
				decrypt(data).unpack('G' * (data_size / 8))
			when 33 # compressedCString 1-byte(s) wide
				decrypt(data)[0..-2]
			when 34 # compressedPString 1-byte(s) wide
				decrypted = decrypt(data)
				decrypted[1..decrypted[0].unpack("C").first]
			when 35 # compressedFloat 1-byte(s) wide
				decrypt(data).unpack('g' * (data_size / 4))
			when 128 # deltaComp
				# TODO: What is a "deltaComp" compression? Implement it the right way.
				"unsupported compression 'deltaComp' data type '#{type}'"
			when 256 # LZWComp
				unlzw(data.unpack('C' * size * num))
			when 384 # deltaLZW
				# TODO: What is a "deltaLZW" compression? Implement it the right way.
				"unsupported compression 'deltaLZW'(#{type})"
			when 1024 # user
				"user type 'user'(#{type}) => #{num} elements of #{size}-byte wide struct: " << data.unpack('C' * size * num).join(', ')
			else
				"unsupported type '#{type}': " << data.unpack('C' * size * num).join(', ')
			end
		end

		def inflate(compressed)
			Zlib::Inflate.inflate compressed
		end

		def unlzw(compressed)
		    dict_size = 256
		    dictionary = Hash[ Array.new(dict_size) {|i| [i.chr, i.chr]} ]
		 
		    w = result = compressed.shift
		    for k in compressed
		        if dictionary.has_key?(k)
		            entry = dictionary[k]
		        elsif k == dict_size
		            entry = w + w[0,1]
		        else
		            raise 'Bad compressed k: %s' % k
		        end
		        result += entry
		 
		        dictionary[dict_size] = w + entry[0,1]
		        dict_size += 1
		 
		        w = entry
		    end
		    result
		end			

		def decrypt(encrypted)
			@decipher.reset
			@decipher.update(encrypted) + @decipher.final
		end
	end
end