require File.expand_path(File.dirname(__FILE__) + '/unit_spec_helper')

describe 'Key' do
  
  it 'should be valid' do
    Congo::Metadata::Key.new(:name => 'title').should be_valid
  end
  
  it 'should not be valid without a name' do
    key = Congo::Metadata::Key.new(:name => '')
    key.should_not be_valid
    key.errors.on(:name).should_not be_nil
  end
  
  it 'should be valid without a name if a label is provided' do
    key = Congo::Metadata::Key.new(:name => '', :label => 'My title')
    key.should be_valid
    key.name.should == "my_title"
  end
  
  it 'should be valid without a type' do
    key = Congo::Metadata::Key.new(:name => 'title', :type => nil)
    key.should be_valid
    key.type.should == "String"
  end
  
  it 'should have a valid name' do
    key = Congo::Metadata::Key.new(:name => 'Title')
    key.should be_valid
    key.name.should == "title"
  end
  
  describe "when applied" do
    after do
      @key.apply(@base, @scope)
    end
    
    before do
      @base  = mock('Base class')
      @scope = mock('Scope')
      @const = Class.new(String)
      @scope.stubs(:content_type_as_const).with('Key').returns(@const)
      @key = Congo::Metadata::Key.new(:name => 'mykey', :type => 'Key')
    end
    
    it "should create the key in the base class" do
      @base.expects(:key).with(:mykey, @const)
    end
    
    describe "with validations" do
      before do
        @const.send(:include, Validatable)
        @const.send(:validates_format_of, :to_s, :with => /[0-9]+/)
        @scope.stubs(:content_type_as_const).with('Key').returns(@const)
        @base.stubs(:key).with(:mykey, @const)
      end
      
      it "should use include_errors_from in the base class" do
        @base.expects(:include_errors_from).with(:mykey)
      end
    end
  end
end
