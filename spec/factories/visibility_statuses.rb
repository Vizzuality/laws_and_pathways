# global traits for visiblity status

FactoryBot.define do
  VisibilityStatus::VISIBILITY.each do |status|
    trait status do
      visibility_status { status }
    end
  end
end
