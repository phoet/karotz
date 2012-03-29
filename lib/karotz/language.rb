module Karotz
  class Language
    ENGLISH = :EN
    GERMAN  = :DE
    FRENCH  = :FR
    SPANISH = :ES

    def self.all
      @constants ||= constants.map { |const| const_get const }
    end
  end
end
