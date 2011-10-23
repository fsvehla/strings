## Strings - A Ruby library for Apple Strings file manipulation

### Usage Example: Translation of a strings file

    table = Strings::Table.load_from_file('./Localizable.strings')

    table.update('History (Caption)' => 'Verlauf')
    table.write_to_file './Localizable-DE.strings'
