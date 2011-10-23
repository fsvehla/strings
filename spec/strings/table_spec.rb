require 'spec_helper'
require 'tempfile'

module StripHereDoc
  def strip_heredoc
    indent = scan(/^[ \t]*(?=\S)/).min.size || 0
    gsub(/^[ \t]{#{indent}}/, '')
  end
end

String.send(:include, StripHereDoc)

describe Strings::Table do
  let(:source) do
    source = (<<-EOS)
      /* No comment left by engineer */
      "Hello" = "World";

      /* The number one */
      "One"   = "Ichi";
      "Two"   = "Ni";
      "Three" = "San";
    EOS

    source.strip_heredoc
  end

  let(:table) do
    Strings::Table.new(source)
  end

  describe 'Access' do
    describe 'fetch' do
      it 'returns the string value for the specified key' do
        table['Hello'].should        eq 'World'
        table['Gibbetnettet'].should eq nil
      end
    end

    describe 'keys' do
      it 'returns a Set of keys' do
        table.keys.should == Set.new(['Hello', 'One', 'Two', 'Three'])
      end
    end

    describe 'to_hash' do
      it 'to_hash returns a hash of values and keys' do
        table.to_hash.should eql('Hello' => 'World', 'One' => 'Ichi', 'Two' => 'Ni', 'Three' => 'San')
      end
    end

    describe 'set' do
      it 'returns the new value' do
        table.set('Hello', 'Woof').should eq 'Woof'
      end

      it 'fetches what was set' do
        table['Hello'] = 'Woof'
        table['Hello'].should eq 'Woof'
      end

      it 'raises when trying to set to nil' do
        -> {
          table['Hello'] = nil
        }.should raise_error(RuntimeError, /nil/)
      end

      it 'raises when trying to update an unknown key' do
        -> {
          table.set('Nada', 'Nil')
        }.should raise_error(RuntimeError)
      end
    end

    describe 'update' do
      it 'updates all the keys' do
        table.update('Hello' => 'Lady', 'One' => 'Eins', 'Two' => 'Zwei')

        table['Hello'].should eq 'Lady'
        table['One'].should   eq 'Eins'
        table['Two'].should   eq 'Zwei'
      end

      it 'raises when trying to update an non-existing key' do
        -> {
          table.update('Hezzo' => 'Zupital')
        }
      end

      it 'doesnt update any key if any of them doesnt exist'
    end

    describe 'update_all' do
      it 'updates, if all existing keys are specified in the options' do
        table.expects(:update).once
        table.update_all('Hello' => 'Lady', 'One' => 'Eins', 'Two' => 'Zwei', 'Three' => 'Drei')
      end

      it 'raises, when not all existing keys are specified in the options' do
        -> {
          table.update_all('Hello' => 'Lady', 'One' => 'Eins')
        }.should raise_error(RuntimeError, /missing.+Two/)
      end
    end
  end

  describe 'Output' do
    it 'dumps the table exactly at is was read when unchanged' do
      table.dump.should eql source
    end

    it 'outputs the new values' do
      table.update('One' => 'Eins', 'Two' => 'Zwei', 'Three' => 'Drei')

      table.dump.should eql (<<-EOS).strip_heredoc
        /* No comment left by engineer */
        "Hello" = "World";

        /* The number one */
        "One"   = "Eins";
        "Two"   = "Zwei";
        "Three" = "Drei";
      EOS
    end
  end

  describe 'Loading from a file' do
    it 'reads string files, even though they have a BOM' do
      table = Strings::Table.load_from_file(data_path('History.strings'))

      table['History (Caption)'].should == 'History'
    end

    it 'writes the string file' do
      path = Tempfile.new('strings-table-output').path

      table = Strings::Table.load_from_file(data_path('History.strings'))
      table.write_to_file(path)

      File.binread(path).should == File.binread(data_path('History.strings'))
    end
  end
end

