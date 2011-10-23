$LOAD_PATH.unshift(File.dirname(File.expand_path(__FILE__, '../lib')))

require 'strings'

table = Strings::Table.load_from_file('./Localizable.strings')

table.update('History (Caption)' => 'Verlauf')
table.write_to_file './Localizable-DE.strings'
