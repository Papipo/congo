require File.expand_path(File.dirname(__FILE__) + '/functional_spec_helper')

describe 'Grip' do
  
  before(:each) do
    Account.destroy_all
    Congo::ContentType.destroy_all
    
    @account = Account.create(:email => 'layne_stanley@acme.org')        
  end
  
  it 'should attach a file to a content' do
    create_content_type
    developer = @account.developers.create({
      :name => 'Layne Stanley', 
      :description => 'foo bar', 
      :picture => open_file('avatar.jpeg')
    })
    developer.should be_valid
    developer.picture_name.should == 'avatar.jpeg'
    developer.picture_content_type.should == 'image/jpeg'
    developer.picture_path.should == "fs/developer/#{developer._id}"
  end
  
  def create_content_type(options = {})
    type = build_content_type
    type.save!
    type
  end
  
  def build_content_type(options = {})
    default_options = {
      :name => 'Developer',
      :embedded => false,
      :metadata_keys => [
        { :name => 'name', :type => 'String' },
        { :name => 'bio', :type => 'Text' },
        { :name => 'picture', :type => 'File' }
      ] } 
    
    @account.content_types.build(default_options.merge(options))
  end
  
  def open_file(name)
    File.open(File.join(File.dirname(__FILE__), '..', 'assets', name))
  end
end