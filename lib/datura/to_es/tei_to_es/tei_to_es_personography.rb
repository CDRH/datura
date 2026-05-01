# TeiToEsPersonography transforms a single <person> element from a TEI
# personography file into an Elasticsearch JSON document.
#
# Each <person> element becomes one ES document, identified by the person's
# xml:id attribute value (e.g., "hickok.j"). The parent TEI document is passed
# as @parent_xml so that header-level fields (creator, contributor, etc.) can
# still be extracted from the full file.

class TeiToEsPersonography < TeiToEs

  # Merges person-level xpaths on top of the standard TeiToEs xpaths, then
  # merges override_xpaths on top so collection teams can still customize using
  # the familiar hook pattern (e.g., in scripts/overrides/tei_to_es_personography.rb).
  # Paths here are relative to the <person> element (@xml), not the document root.
  # Header-level fields (creator, contributor, rights, etc.) are unchanged and
  # are queried against @parent_xml in the field methods below.
  def xpaths_list
    super.merge({
      "titles" => {
        "main" => "persName[@type='display']",
        "alt"  => "persName"
      },
      "text"       => "note",
      "birth_year" => "birth/@when",
      "death_year" => "death/@when"
    }).merge(override_xpaths)
  end

  # No-op by default; override in a collection script to add or replace xpaths.
  def override_xpaths
    {}
  end

  # Returns the person's xml:id value as the document identifier.
  # After namespace removal by Nokogiri, xml:id is accessible as the "id" attribute.
  def get_id
    @xml["id"]
  end

  def category
    "Life"
  end

  # Hardcoded subcategory for all personography entries.
  def subcategory
    "Personography"
  end

  def creator
    []
  end

  def creators
    nil
  end

  def person
    [{
      "role" => nil,
      "name" => get_text(@xpaths["titles"]["main"]),
      "id" => @id
    }]
  end

  # Uses birth/@when as the person's primary date (standardized to start of year).
  def date
    year = get_text(@xpaths["birth_year"])
    Datura::Helpers.date_standardize(year, true) if year
  end

  # Same as date — birth year as the not-before bound.
  def date_not_before
    year = get_text(@xpaths["birth_year"])
    Datura::Helpers.date_standardize(year, true) if year
  end

  # Uses death/@when as the not-after date (standardized to end of year).
  def date_not_after
    year = get_text(@xpaths["death_year"])
    Datura::Helpers.date_standardize(year, false) if year
  end

  # Raw birth year string for display (e.g., "1850").
  def date_display
    get_text(@xpaths["birth_year"])
  end

  # Points to the source personography XML file (the whole file, not per-person),
  # since all persons share one source document.
  def uri_data
    File.join(
      @options["data_base"],
      "data",
      @options["collection"],
      "source/personography",
      "#{@filename}.xml"
    )
  end

end
