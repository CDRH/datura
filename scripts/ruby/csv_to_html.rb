require 'csv'
# require 'nokogiri'    # TODO if this gets more complicated then use nokogiri

def csv_to_html(file_path, options, output)
  data = read_csv(file_path)
  # puts data.headers()
  data.each do |row|
    if !row.header_row?
      id = row["id"]
      html = ""
      if row["description"]
        desc = row['description']
        html += "<p>Description:</p>\n<pre>#{desc}</pre>\n" 
      end
      if id && options["figures"]
        pages = row["pages"].to_i if row["pages"]
        if pages
          pages.times do |page|
            real_page = page+1
            page_ext = get_page_ext(real_page.to_s)
            img_large = "#{options["fig_location"]}large/#{id}.#{page_ext}.jpg"
            img_med = "#{options["fig_location"]}medium/#{id}.#{page_ext}.jpg"
            html += "<div class='thumbnail_listing_images'>"
            html += "<a rel='prettyPhoto[pp_gal]' href='#{img_large}'>"
            html += "<span class='thumbnail_div'>"
            html += "<img src='#{img_med}'/>"
            html += "</span></a></div>\n"
          end
        else
          html += "<img src='#{options["fig_location"]}large/#{id}.jpg'/>"
        end
      end
      write_file(html, id, output)    
    end
  end
end


# Ignore these if you are just changing the html

def get_page_ext(page)
  return page.rjust(3, "0")
end

def read_csv(file_path)
  data = CSV.read(file_path, {
    :encoding => "iso-8859-1",  # apparently this is necessary with excel docs
    :headers => true,           # there are headers in the csv file
    :return_headers => true     # should be accessible with csv object
    })
  return data
end

def write_file(html, id, path)
  output = "#{path}/#{id}.txt"
  File.open(output, "w") { |file| file.write(html) }
end