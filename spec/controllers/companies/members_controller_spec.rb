require 'spec_helper'

describe Companies::MembersController, type: :controller do
  let(:admin)        { FactoryGirl.create(:admin) }
  let(:company)      { FactoryGirl.create(:company) }
  let(:user_member)  { FactoryGirl.create(:company_member, company: company) }

  let(:valid_params) do
    { company_id: company.permalink, company_member: {company_id: company.id} }
  end

  before(:each) do
    login_user(admin)
    request.env["HTTP_REFERER"] = root_url
  end

  context "#POST create" do
    it 'create new Company::Member' do
      expect do
        post :create, valid_params
      end.to change(Company::Member, :count).by(1)
    end
  end

  context "#DELETE destroy." do
    pending 'delete record' do  #не находится mebmer_request
      user_member
      expect do
        delete :destroy, company_id: user_member.company_id, id: user_member.id
      end.to change(Company::Member, :count).by(-1)
    end

    context 'email notifications' do
      before(:each) do
        allow(AdminMailer).to receive(:deleting_user) do
          mock = double
          allow(mock).to receive(:deliver!)
          mock
        end
      end

      pending 'notice admins about deleting user from company' do #не находится mebmer_request
        FactoryGirl.create(:company_admin, company: company)
        expect(AdminMailer).to receive(:deleting_user)
        delete :destroy, company_id: user_member.company_id, id: user_member.id
      end
    end
  end

end
