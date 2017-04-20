class TeiToEsPersonography < TeiToEs

  # this is just an example personography file set up
  # anything in the default tei_to_es_personography.rb
  # file can be overridden below, and furthermore anything
  # in the tei_to_es.rb file can be overridden, also
  
  def override_xpaths
    xpaths = {
      "titles" => {
        "main" => "persName[@type='display']",
        "alt" => "persName"
      },
      "text" => "note"
    }
    return xpaths
  end

end
