require 'spec_helper'

describe ProjectTemplatesController do
  
  describe "CREATE" do

    context "When user allowed" do
      let(:valid_attributes) { FactoryGirl.build(:project_template, :company => @logged_user.company ).attributes.except("id", "type") }
      before :each do
        sign_in_admin
      end

      it "should create a project template" do
        expect{
          post :create, :project => valid_attributes
        }.to change { ProjectTemplate.count }.by(1)
      end

      it "should redirect to the 'index' action" do
        post :create, :project => valid_attributes
        response.should redirect_to project_templates_path
      end

    end # when user allowed

  end # DESTROY

  describe "DESTROY" do
    let(:project_template) { FactoryGirl.create(:project_template, :company => @logged_user.company ) }

    context "When user allowed" do
      before :each do
        sign_in_admin
        project_template
      end

      it "should remove a project template" do
        expect{
          delete :destroy, :id => project_template.id
        }.to change { ProjectTemplate.count }.by(-1)
      end

      it "should redirect to project template index page" do
        delete :destroy, :id => project_template.id
        response.should redirect_to project_templates_path
      end

    end # when user allowed

  end # DESTROY

end
