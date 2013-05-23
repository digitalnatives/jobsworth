require 'spec_helper'

describe ScoreRule do

  it { should belong_to :controlled_by }
  it { should validate_presence_of :name }
  it { should ensure_length_of(:name).is_at_most(30) }
  it { should validate_presence_of :exponent }
  it { should validate_presence_of :score }
  it { should validate_numericality_of :score }
  it { should validate_presence_of :score_type }
  it('should ensure inclusion of score_type in ScoreRuleTypes.all_score_types') do
    should ensure_inclusion_of(:score_type).in_array(ScoreRuleTypes.all_score_types)
  end

  describe '#calculate_score_for' do
    let(:task) { FactoryGirl.build :task }
    subject { sr.calculate_score_for(task) }

    context 'when score type is fixed' do
      let(:sr) { FactoryGirl.build :fixed_score_rule }

      it 'should return the score of score rule' do
        expect(subject).to eql sr.score
      end
    end

    context 'when score type is task age' do
      subject { FactoryGirl.build :task_age_score_rule }
      it { pending }
    end

    context 'when score type is last comment age' do
      subject { FactoryGirl.build :last_comment_age_score_rule }
      it { pending }
    end

    context 'when score type is overdue' do
      subject { FactoryGirl.build :overdue_score_rule }
      it { pending }
    end
  end

end


# == Schema Information
#
# Table name: score_rules
#
#  id                 :integer(4)      not null, primary key
#  name               :string(255)
#  score              :integer(4)
#  score_type         :integer(4)
#  exponent           :decimal(5, 2)   default(1.0)
#  controlled_by_id   :integer(4)
#  controlled_by_type :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#
# Indexes
#
#  index_score_rules_on_controlled_by_id  (controlled_by_id)
#  index_score_rules_on_score_type        (score_type)
#

