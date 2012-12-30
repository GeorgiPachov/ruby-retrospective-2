class Song

  attr_reader :name, :artist, :album
  def initialize(name, artist, album)
    @name = name
    @artist = artist
    @album = album
  end
end

class Collection
  include Enumerable

  attr_reader :song_list

  def initialize(array)
    @song_list = array
  end

  def names
    @song_list.map {|song| song.name}.uniq
  end

  def artists
    @song_list.map {|song| song.artist}.uniq
  end

  def albums
    @song_list.map {|song| song.album}.uniq
  end

  def Collection.parse_file(file)
    file_contents = File.read(file)
    parse(file_contents)
  end

  def Collection.parse(text)
    result =  text.each_line("\n\n").map{ |song_info| parse_song(song_info) }
    Collection.new result
  end

  def filter(criteria)
    filtered = @song_list.select {|song| criteria.accept? song }.uniq
    Collection.new filtered
  end

  def each
    @song_list.each {|song| yield song}
  end

  def adjoin(collection)
    Collection.new (@song_list | collection.song_list).uniq
  end

  private
  def Collection.parse_song(song_record_text)
    song_info_array = song_record_text.split("\n")
    Song.new song_info_array[0],song_info_array[1],song_info_array[2]
  end

end

class Criteria
  def initialize(lambda)
    @criteria = lambda
  end

  def accept? song
    @criteria.call song
  end

  def Criteria.name(song_name)
    Criteria.new lambda {|song| song.name == song_name}
  end

  def Criteria.artist(artist_name)
    Criteria.new lambda {|song| song.artist == artist_name}
  end

  def Criteria.album(album_name)
    Criteria.new lambda {|song| song.album == album_name}
  end

  def |(other_criteria)
    Criteria.new lambda {|song| accept? song or other_criteria.accept? song}
  end

  def &(other_criteria)
    Criteria.new lambda {|song| accept? song and other_criteria.accept? song}
  end

  def !@
    Criteria.new lambda {|song| !accept? song}
  end

end

