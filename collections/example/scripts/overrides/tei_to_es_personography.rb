class TeiToEsPersonography < TeiToEs

  # if not needed in your collection, please remove this file
  # all the same overrides allowed in tei_to_es.rb are
  # valid in this file

  # if you need a personography, please know that the majority of your
  # xpaths will likely need to be overridden
  
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
