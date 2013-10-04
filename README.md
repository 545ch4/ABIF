# ABIF

Handle ABIF (Applied Biosystems Genetic Analysis Data File Format) FSA, AB1 and HID files.


## Installation

Add this line to your application's Gemfile:

    gem 'ABIF'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ABIF


## Usage

	$ file = ABIF::File.new(<.fsa|ab1|hid file or IO stream>)
	$ puts file.data.keys
	$ puts file.data['RunN_1']


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
