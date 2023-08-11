module CapybaraHelpers
  def contains_class(class_name)
    "contains(concat(' ', normalize-space(@class), ' '), ' #{class_name} ')"
  end

  def expect_property(property, text)
    within(
      :xpath,
      "(.//div[#{contains_class('property__name')} and contains(., '#{property}')]/..)[1]"
    ) do
      expect(page).to have_text(text)
    end
  end

  def within_banking_area(header_text)
    within(
      :xpath,
      "(.//div[#{contains_class('bank-assessment__area-header')}]//h2[contains(., '#{header_text}')]/../../..)[1]"
    ) do
      yield if block_given?
    end
  end

  def with_mq_beta_scores
    within '.mq-beta-scores' do
      click_on 'BETA'
    end
    yield
    within '.mq-beta-scores' do
      click_on 'Current'
    end
  end
end
