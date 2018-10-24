class FileCsvHoldPlease

  def row_to_es(headers, row)
    doc = {}
    doc["text"] = ""
    doc["identifier"] = row["id"] if row["id"]
    doc["category"] = row["category"] if row["category"]
    doc["subcategory"] = row["sub_category"] if row["sub_category"]
    doc["data_type"] = "csv"
    doc["collection"] = @options["collection"]
    if row["title"]
      doc["title"] = row["title"]
      doc["text"] << " #{row["title"]}"
      doc["title_sort"] = CommonXml.normalize_name(row["title"])
    end
    doc["format"] = row["medium"]
    doc["places"] = [ row["location"] ]
    doc["date"] = row["date_normalized"] if row["date_normalized"]
    doc["date_display"] = row["date"] if row["date"]
    # TODO this is a proof of concept that would ideally also include things like creator
    doc
  end

  def row_to_solr(doc, headers, row)
    doc.add_child("<field name='id'>#{row['id']}</field>") if row['id']
    doc.add_child("<field name='title'>#{row['title']}</field>") if row['title']
    doc.add_child("<field name='category'>#{row['category']}</field>") if row['category']
    doc.add_child("<field name='sub_category'>#{row['sub_category']}</field>") if row['sub_category']
    doc.add_child("<field name='caption'>#{row['caption']}</field>") if row['caption']
    doc.add_child("<field name='location'>#{row['location']}</field>") if row['location']
    doc.add_child("<field name='pages'>#{row['pages']}</field>") if row['pages']
    doc.add_child("<field name='description'>#{row['description']}</field>") if row['description']
    doc.add_child("<field name='keywords'>#{row['keywords']}</field>") if row['keywords']
    doc.add_child("<field name='date'>#{row['date']}</field>") if row['date']
    doc.add_child("<field name='dateNormalized'>#{row['dateNormalized']}</field>") if row['dateNormalized']
    doc.add_child("<field name='medium'>#{row['medium']}</field>") if row['medium']
    doc.add_child("<field name='size'>#{row['size']}</field>") if row['size']
    doc.add_child("<field name='creator'>#{row['creator']}</field>") if row['creator']
    doc.add_child("<field name='collection'>#{row['collection']}</field>") if row['collection']
    return doc
  end
end
