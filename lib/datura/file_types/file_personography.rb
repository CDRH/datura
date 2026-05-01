require_relative "../helpers.rb"
require_relative "../file_type.rb"
require_relative "../solr_poster.rb"
require_relative "file_tei.rb"
require "rest-client"
require "json"

# FilePersonography handles TEI personography files — XML files containing
# a <listPerson> element with individual <person> children, each identified
# by a unique xml:id attribute.
#
# Unlike standard TEI processing (one ES document per file), this class
# produces one ES JSON document per <person> element, with each output file
# named by the person's xml:id value (e.g., hickok.j.json).
#
# HTML output uses the standard tei_to_html XSLT, which via
# personography_encyclopedia.xsl writes:
#   - one combined HTML file with all persons as divs (served at /item/{filename})
#   - individual HTML files per person via xsl:result-document (served at /item/{xml:id})
#
# Solr output uses the standard tei_to_solr XSLT, which via
# tei_to_solr/lib/personography.xsl produces per-person Solr docs.
#
# Source files should be placed in source/personography/ within the collection.
class FilePersonography < FileTei

  # Maps each <person> element to TeiToEsPersonography for ES transformation.
  # The parent /TEI document is intentionally excluded — one ES doc is produced
  # per person, not one for the entire file.
  def subdoc_xpaths
    { "//listPerson/person" => TeiToEsPersonography }
  end

  # Overrides FileType#transform_es to write one JSON file per person
  # (named by the person's xml:id) instead of a single file for the whole document.
  # Returns an array of JSON hashes so that post_es can iterate and POST them
  # to Elasticsearch without modification.
  def transform_es
    es_req = []
    begin
      file_xml = parse_markup_lang_file

      # Verify at least one person element exists before continuing
      results = file_xml.xpath(*subdoc_xpaths.keys)
      if results.length == 0
        raise "No persons found in #{self.filename}; verify //listPerson/person matches the XML structure"
      end

      file_xml.xpath("//listPerson/person").each do |person_node|
        transformer = TeiToEsPersonography.new(person_node, @options, file_xml, self.filename(false))
        person_json = transformer.json
        es_req << person_json

        # Write one JSON file per person using the person's identifier as the filename.
        # Produces e.g. output/es/hickok.j.json rather than output/es/wfc.person.json.
        if @options["output"]
          person_id = person_json["identifier"]
          if person_id.nil? || person_id.empty?
            puts "WARNING: person in #{self.filename} has no identifier; skipping ES file output"
            next
          end
          filepath = File.join(@out_es, "#{person_id}.json")
          File.open(filepath, "w") { |f| f.write(JSON.pretty_generate(person_json)) }
        end
      end

      return es_req
    rescue => e
      puts "Error transforming #{self.filename}: #{e}"
      puts e.backtrace
      raise e
    end
  end

  def transform_iiif
    raise "Personography to IIIF is not implemented"
  end

end
