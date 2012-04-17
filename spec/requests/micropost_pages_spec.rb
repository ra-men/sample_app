require 'spec_helper'

describe "Micropost pages" do
  subject { page }

  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  describe "micropost creation" do
    before { visit root_path }

    describe "with invalid information" do
      
      it "should not create a micropost" do
        expect { click_button "Post" }.should_not change(Micropost, :count)
      end

      describe "error messages" do
        before { click_button "Post" }
        it { should have_content('error') }
      end
    end
    
    describe "with valid information" do
      
      before { fill_in 'micropost_content', with: "Lorem Ipsum Binjimon" }
      it "should create a micropost" do
        expect { click_button "Post" }.should change(Micropost, :count).by(1)
      end
    end

  end
  describe "micropost destruction" do
    before { FactoryGirl.create(:micropost, user: user) }

    describe "as correct user" do
      before { visit root_path }

      it "should delete a micropost" do
        expect { click_link "delete" }.should change(Micropost, :count).by(-1)
      end
    end
  end
  
  describe "micropost counting" do
    before { FactoryGirl.create(:micropost, user: user) }

    describe "having only one micropost" do
      before { visit root_path }
      
      it { should have_selector('span', text: '1 micropost' ) }
    end

    describe "having 2 microposts" do
      before do
        FactoryGirl.create(:micropost, user: user) 
        visit root_path
      end

      it { should have_selector('span', text: '2 microposts')}
    end
  end

  describe "micropost pagination" do
    before do 
      34.times { FactoryGirl.create(:micropost, user: user) } 
      visit root_path 
    end

    it { should have_link("Next") }
    it { should have_link("2") }
  end

  describe "micropost delete links" do
    let(:other_user) { FactoryGirl.create(:user) }
    before do
      FactoryGirl.create(:micropost, user: other_user)
      visit user_path(other_user)
    end
    
    describe "should not appear on other users' microposts" do
      it { should_not have_link('delete') }
    end
  end
end
