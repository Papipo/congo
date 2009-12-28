require File.expand_path(File.dirname(__FILE__) + '/functional_spec_helper')

describe 'Key' do
  
  before(:each) do
    I18n.locale = :en
    
    Account.destroy_all
    Congo::ContentType.destroy_all
    
    @account = Account.create(:email => 'layne_stanley@acme.org')
  end
  
  it 'should add items' do
    create_content_type
    
    person = build_person
    person.valid?.should be_true
    person.name.should == 'Layne Stanley'
    person.bio.should == "That's great"
    person.email.should == 'layne_stanley@acme.org'
    person.save
    
    @account = Account.first # hard reload
    person = @account.developers.first
    person.email.should == 'layne_stanley@acme.org'
  end
  
  it 'should not add items with invalid data (incorrect e-mail)' do
    create_content_type
    
    person = build_person(:email => 'layne_stanley-acme.org')
    person.valid?.should be_false
    person.errors.on(:email).should_not be_nil
  end
  
  it 'should convert date into the locale' do
    create_content_type  
    person = build_person
    person.save
    
    @account = Account.first # hard reload
    person = @account.developers.first    
    person.birthday.strftime(I18n.t('congo.date.formats.default')).should == '06/28/1979'
    
    I18n.locale = :fr
    person.birthday.strftime(I18n.t('congo.date.formats.default')).should == '28/06/1979'

    person.birthday = '16/09/1982'
    person.save
    
    @account = Account.first # hard reload
    person = @account.developers.first
    person.birthday.strftime(I18n.t('congo.date.formats.default')).should == '16/09/1982'
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
        { :name => 'email', :type => 'Email' },
        { :name => 'birthday', :type => 'Date' }
      ] } 
    
    @account.content_types.build(default_options.merge(options))
  end
  
  def build_person(options = {})
    attributes = { 
      :name => 'Layne Stanley', 
      :bio => "That's great", 
      :email => 'layne_stanley@acme.org', 
      :birthday => '06/28/1979'
    }
    @account.developers.build attributes.merge(options)
  end
  
end