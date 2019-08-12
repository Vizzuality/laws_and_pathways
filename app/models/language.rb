class Language
  def self.common
    ::LanguageList::COMMON_LANGUAGES.sort_by(&:name)
  end

  def self.find(language_code)
    ::LanguageList::LanguageInfo.find(language_code)
  end
end
