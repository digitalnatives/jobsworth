require 'spec_helper'

describe ProjectTemplatesController do
  let(:project_template) { FactoryGirl.create(:project_template, :company => @logged_user.company ) }

  describe "DESTROY" do

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
