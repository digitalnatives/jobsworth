require 'spec_helper'

describe TaskFilter do

  describe ".recent_for(user) scope" do
    let(:user)           { FactoryGirl.create :user }
    let!(:filters)       { FactoryGirl.create_list :task_filter, 4, user: user, recent_for_user_id: user.id }
    let!(:other_filters) { FactoryGirl.create_list :task_filter, 4, user: user }

    it "should return recent task filters for user" do
      expect(described_class.count).to eql 8
      expect(described_class.recent_for(user).all).to eql filters.reverse
    end
  end

  describe "#store_for(user)" do
    let(:company) { FactoryGirl.create :company }
    let(:user)    { FactoryGirl.create :user, company: company }
    let(:project) { FactoryGirl.create :project, company: company }
    let(:keyword) { Keyword.new(:word=>'keyword') }
    let(:qualifiers) {[
      TaskFilterQualifier.new(qualifiable: project),
      TaskFilterQualifier.new(qualifiable: Status.default_open(company)),
      TaskFilterQualifier.new(qualifiable: user)
    ]}
    subject { described_class.create user: user, company: user.company, qualifiers: qualifiers, keywords: [keyword] }

    it 'should create new task filter' do
      expect { subject.store_for(user) }.to change { described_class.count }.by(1)
    end

    it "should include all items(qualifiers or keywords) in filter's name" do
      subject.store_for(user)

      expect(described_class.recent_for(user).first.name.split(','))
      .to have(subject.qualifiers.size + subject.keywords.size ).items
    end

    context 'when the user have 10 recent filters' do
      let(:filters) { FactoryGirl.create_list :task_filter, 10, user: user, company: company }
      before { filters.each { |f| f.store_for(user) } }

      it 'should delete last recent filter' do
        expect { subject.store_for(user) }.to_not change { described_class.count }

        expect(described_class.recent_for(user).last.name)
          .to eql filters.second.name
      end
    end
  end
end





# == Schema Information
#
# Table name: task_filters
#
#  id                 :integer(4)      not null, primary key
#  name               :string(255)
#  company_id         :integer(4)
#  user_id            :integer(4)
#  shared             :boolean(1)
#  created_at         :datetime
#  updated_at         :datetime
#  system             :boolean(1)      default(FALSE)
#  unread_only        :boolean(1)      default(FALSE)
#  recent_for_user_id :integer(4)
#
# Indexes
#
#  fk_task_filters_company_id  (company_id)
#  fk_task_filters_user_id     (user_id)
#

