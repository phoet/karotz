module Karotz
  class Multimedia
    PLAY = :play
    PAUSE = :pause
    RESUME = :resume
    STOP = :stop
    PREVIOUS = :previous
    NEXT = :next
    RECORD = :record
    ALL_SONG = :allsong
    FOLDER = :folder
    ARTIST = :artist
    GENRE = :genre

    def self.all
      @constants ||= constants.map { |const| const_get const }
    end
  end
end
