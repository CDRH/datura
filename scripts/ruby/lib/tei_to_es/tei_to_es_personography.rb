class TeiToEsPersonography < TeiToEs
  def assemble_subdoc_json doc
    json = {}
    doc_identifier = doc["id"]
    id = "#{@id}_#{doc_identifier}"
    json["identifier"] = id
    # json["identifier"] = "todo"

    json["category"] = "Life"
    json["subcategory"] = "Personography"
    json["data_type"] = "tei"
    json["project"] = project
    json["shortname"] = shortname

    json["title"] = doc.xpath("./persName[@type='display']").text
    json["title_sort"] = Common.normalize_name(json["title"])
    # more fields would be contributor, people, description, text, etc
    return json
  end
end
