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

  def within_ascor_pillar(header_text)
    within(
      :xpath,
      "(.//div[#{contains_class('country-assessment__pillar')}]//h2[contains(., '#{header_text}')]/../../..)[1]"
    ) do
      yield if block_given?
    end
  end

  def with_older_mq_scores
    within '.mq-beta-scores' do
      click_on 'V4.0'
    end
    yield
    within '.mq-beta-scores' do
      click_on 'Current V5.0'
    end
  end

  def for_mobile_screen
    current_window.resize_to(375, 812)
    yield
    current_window.resize_to(1400, 800)
  end
end
