class FileType

  # make the class variables read / writable
  class << self
    attr_accessor :script_es
    attr_accessor :script_html
    attr_accessor :script_solr
  end

  attr_reader :file_location

  def initialize location
    @file_location = location
  end

  def transform_es
    # TODO should there be any default transform behavior at all?
  end

  def transform_html
    # TODO also not sure about this one, because the XSL can't
    # operate on CSVs and DC / TEI are pretty different
  end

  def transform_solr
    # TODO same as above
  end
end
