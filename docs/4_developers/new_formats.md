# Adding new formats to datura

## Configuring datura

In `lib/datura/data_manager.rb`, `self.format_to_class` contains a hash with the format as key and a file with format-specific methods as value. Add your desired format to this hash, with the corresponding file FileFornat.
```
 def self.format_to_class
    {
      "csv" => FileCsv,
      "ead" => FileEad,
      "html" => FileHtml,
      "tei" => FileTei,
      "vra" => FileVra,
    }
end
```
Modify `lib/datura/parser_options/post.rb` to accept parameters for the new format:
```
options["format"] = nil
      opts.on( '-f', '--format [input]', 'Restrict to one format (csv, ead, html, tei, vra, webs)') do |input|
        if %w[csv ead html tei vra webs].include?(input)
          options["format"] = input
        else
          puts "Format #{input} is not recognized.".red
          puts "Allowed formats are csv, ead, html, tei, vra, and webs (web-scraped html)"
          exit
        end
      end
```
In the `config/public.yml` file you need to add a link to the xsl scripts for the specific format (you do not necessarily need to create a working script until you need to transform files), and also create a file and add it to the scripts folder:
```
  html_html_xsl: scripts/.xslt-datura/html_to_html/html_to_html.xsl
  tei_html_xsl: scripts/.xslt-datura/tei_to_html/tei_to_html.xsl
  vra_html_xsl: scripts/.xslt-datura/vra_to_html/vra_to_html.xsl
  ead_html_xsl: scripts/.xslt-datura/ead_to_html/ead_to_html.xsl
```

## Datura overrides and new files
You will need to create a `file_format.rb` (i.e. `file_ead.rb`) file in `lib/datura/file_types`. Copy from a similar file type (file_tei.rb is a good model for XML-based formats) and make any necessary changes for the file format. Make sure to change the class name to reflect the new file format. In particular, in the case of an XML-based format, the `subdoc_xpaths` should be modified to get the correct XPath for the files you want to transform:
```
def subdoc_xpaths
    # match subdocs against classes
    return {
      "/ead" => EadToEs,
    }
  end
```

In the `/lib/datura/to_es` folder you also need to make a format_to_es.rb file, i.e. `ead_to_es.rb` and also a folder with fields.rb, request.rb, and (for XML-based formats) xpaths.rb overrides
Be sure to require all the necessary files at the top (and create them in the proper folder).
```
require_relative "xml_to_es.rb"
require_relative "ead_to_es/fields.rb"
require_relative "ead_to_es/request.rb"
require_relative "ead_to_es/xpaths.rb"



class EadToEs < XmlToEs
end
```
The new files you have added must to be required in `lib/datura/requirer.rb`. This should happen automatically, but if not add the following to make sure they get picked up:
```
require_relative "to_es/ead_to_es.rb"
```
All code in these files should be within the same class. If the format is based on XML, it should inherit from XmlToEs.
```
class EadToEs < XmlToEs
end
```

## Xpaths
Add all the xpaths for your desired fields in xpaths.rb, in the hash inside the xpaths.rb file. it may be helpful to use an existing template like `tei_to_es/xpaths.rb`. There is no need to add all of them, you can comment out the fields you do not need.

## Overrides with specific fields
All fields must be defined within fields.rb. Even if you do not intend to index them, Datura requires that you at least have an empty method defining each field. (An empty field will be nil and not be displayed in Orchid).
```
def category
end
```
Make appropriate changes to your fields as desired.

## Dealing with subsections of XML files
If you want to index subsections, the best way to do this is to define an xpaths selector for the desired sections in the `subdoc_xpaths` method as described above.
```
def subdoc_xpaths
    # match subdocs against classes
    return {
      "/ead" => EadToEs,
      "//*[@level='item']" => EadToEsItems,
    }
  end
```
Then add all the necessary overrides in the `to_es` folder like above. Depending on what you need to override, you may combine them into one file, or  have separate files. In any case, they should inherit from the main file, i.e. `class TeiToEsPersonography < TeiToEs`. 
