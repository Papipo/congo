require File.expand_path(File.dirname(__FILE__) + '/unit_spec_helper')

describe Congo::Scoper::InstanceMethods do
  before do
    @instance = Object.new
    @instance.metaclass.send(:include, Congo::Scoper::InstanceMethods)
    @instance.stubs(:content_types).returns(stub_everything)
  end
  
  describe "content_type_as_const" do
    it "should support ruby types" do
      @instance.content_type_as_const('String').should == String
    end
    
    it "should support Congo Email type" do
      @instance.content_type_as_const('Email').should == Congo::Types::Email
    end
  end
end