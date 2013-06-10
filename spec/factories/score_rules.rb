FactoryGirl.define do
  factory :score_rule do
    name       'Score Rule'
    score      100
    score_type ScoreRuleTypes::FIXED

    factory(:fixed_score_rule)            { score_type ScoreRuleTypes::FIXED }
    factory(:task_age_score_rule)         { score_type ScoreRuleTypes::TASK_AGE }
    factory(:last_comment_age_score_rule) { score_type ScoreRuleTypes::LAST_COMMENT_AGE }
    factory(:overdue_score_rule)          { score_type ScoreRuleTypes::OVERDUE }
  end
end
