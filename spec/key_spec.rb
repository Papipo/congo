require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'Key' do
  
  it 'should be valid' do
    Congo::Key.new(:name => 'title').should be_valid
  end
  
  it 'should not be valid without a name' do
    key = Congo::Key.new(:name => '')
    key.should_not be_valid
    key.errors.on(:name).should_not be_nil
  end
  
  it 'should be valid without a name if a label is provided' do
    key = Congo::Key.new(:name => '', :label => 'My title')
    key.should be_valid
    key.name.should == "my_title"
  end
  
  it 'should be valid without a type' do
    key = Congo::Key.new(:name => 'title', :type => nil)
    key.should be_valid
    key.type.should == "String"
  end
  
  it 'should have a valid name' do
    key = Congo::Key.new(:name => 'Title')
    key.should be_valid
    key.name.should == "title"
  end
  
  it 'should keep the previous name and tell if the name changed or not' do
    key = Congo::Key.new(:name => 'Title')
    key.name = 'foo'
    key.name.should == 'foo'
    key.name_changed?.should be_true
    key.name = 'foo'
    key.name_changed?.should be_false
    key.attributes = { :name => 'bar' }
    key.name_changed?.should be_true
    key.attributes = { :name => 'bar' }
    key.name_changed?.should be_false
  end
  
end
