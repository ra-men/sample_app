require 'spec_helper'

describe "Authentication" do
  subject { page }
  describe "signin page" do
    before { visit signin_path } 
    
    it { should have_selector('h1', text: 'Sign in') }
    it { should have_selector('title', text: 'Sign in') }

  end
  describe "signin" do
    before { visit signin_path }
    
    describe "with invalid information" do
      before { click_button "Sign in" }

      it { should have_selector('div.flash.error', text: 'Invalid') }
      it { should have_selector('title', text: 'Sign in') }

      describe "after visiting another page" do
        before { click_link "Home" }
        it { should_not have_selector('div.flash.error') }
      end
    end

    describe "with valid information" do
      let(:user) { FactoryGirl.create(:user) }
      before { sign_in user }
      # before do
      #   fill_in "Email", with: user.email
      #   fill_in "Password", with: user.password
      #   click_button "Sign in"
      # end

      it { should have_selector('title', text: user.name) }
      it { should have_selector('li', text: 'Profile') }
      it { should have_selector('li', text: 'Settings') }
      it { should have_selector('li', text: 'Sign out') }
      it { should have_link('Profile', href: user_path(user)) }
      it { should_not have_link('Sign in', href: signin_path) }


      describe "followed by signout" do
        before { click_link "Sign out" }
        it { should have_link('Sign in') }
      end
    end
  end

  describe "with valid information" do
    let(:user) { FactoryGirl.create(:user) }
    before { sign_in user }
    
    it { should have_selector('title', text: user.name) }
    it { should have_selector('li', text: 'Profile') }
    it { should have_selector('li', text: 'Settings') }
    it { should have_link('Sign out', href: signout_path) }
    it { should_not have_link('Sign in', href: signin_path) }
  end

  describe "authorization" do
    describe "for non-signed in users" do
      let(:user) { FactoryGirl.create(:user) }

      describe "in the users controller" do

        describe "visiting the edit page" do
          before { visit edit_user_path(user) }
          it { should have_selector('title', text: 'Sign in') }
        end

        describe "submitting to the update action" do
          before { put user_path(user) }
          specify { response.should redirect_to(signin_path) }
        end

        describe "visiting the user index" do
          before { visit users_path }
          it { should have_selector('title', text: 'Sign in') }
        end

      end

      describe "when attempting to visit a protected page" do
        before do
          visit edit_user_path(user)
          fill_in "Email", with: user.email
          fill_in "Password", with: user.password
          click_button "Sign in"
        end

        describe "after signin in" do
          it "should render the desired protected page" do
            page.should have_selector('title', text: "Edit user")
          end

          describe "when signing in again" do
            before do
              visit signout_path
              visit signin_path
              fill_in "Email", with: user.email
              fill_in "Password", with: user.password
              click_button "Sign in"
            end

            it "should render the default (profile) page" do
              page.should have_selector('title', text: user.name)
            end
          end
        end
      end

    end

    describe "as wrong user" do
      let(:user) { FactoryGirl.create(:user) }
      let(:wrong_user) { FactoryGirl.create(:user, email: "wrong@blah.com") }
      before { sign_in user }

      describe "visiting Users#edit page" do
        before { visit edit_user_path(wrong_user) }
        it { should have_selector('title', text: 'Home') }
      end

      describe "submitting a PUT request to Users#update action" do
        before { put user_path(wrong_user) }
        specify { response.should redirect_to(root_path)  }
      end

    end

    describe "for non signed-in users" do
      let(:user) { FactoryGirl.create(:user) }

      describe "visiting any page" do
        before { visit root_path }
        it { should_not have_selector('li', text: 'Profile')}
      end

      describe "when attempting to visit a protected page" do
        before do
          visit edit_user_path(user)
          fill_in "Email", with: user.email
          fill_in "Password", with: user.password
          click_button "Sign in"
        end

        describe "after signing in" do
          it "should render the desired protected page" do
            page.should have_selector('title', text: 'Edit user')
          end
        end
      end

      describe "visiting user index" do
        before { visit users_path }
        it { should have_selector('title', text: 'Sign in') }
      end
      
      describe "in the Microposts controller" do

        describe "submitting to the create action" do
          before {  post microposts_path }
          specify { response.should  redirect_to(signin_path) }
        end

        describe "submitting to the destroy action" do
          before do
            micropost = FactoryGirl.create(:micropost)
            delete micropost_path(micropost)
          end
          specify { response.should redirect_to(signin_path) }
        end
      end
      
    end
  end
end
