require 'csv'
require 'linkeddata'
require 'nokogiri'
# require 'sparql'
require 'rdf'

##########################
######  Variables ########
##########################

csv_path = File.join(File.dirname(__FILE__), '../rdf/oscys.relationships.csv')
tei_path = File.join(File.dirname(__FILE__), '../tei/oscys.persons.xml')
output = File.join(File.dirname(__FILE__), '../rdf/oscys.relationships.ttl')

PREFIXES = {
  :oscys => 'http://cdrhsites.unl.edu/data/projects/oscys/rdf/oscys.objectproperties.owl#',
  :osrdf => 'http://cdrhsites.unl.edu/data/projects/oscys/rdf/oscys.relationships#',
  :rdf => 'http://www.w3.org/1999/02/22-rdf-syntax-ns#'
}

##########################
########  Helpers ########
##########################

def assemble_traits(xml)
  traits = {}
  traits['fullname'] = get_text(xml, "persName[type='display']")
  traits['birth'] = get_text(xml, 'birth')
  traits['death'] = get_text(xml, 'death')
  traits['sex'] = get_text(xml, 'sex')
  # can add more traits here from tei as necessary
  return traits
end

def error_msg(row)
  puts "\rMissing a subject for: #{row[1]} #{row[2]}\r" if row[0].nil?
  puts "\rMissing a predicate for: #{row[0]} #{row[2]}\r" if row[1].nil?
  puts "\rMissing an object for: #{row[0]} #{row[1]}\r" if row[2].nil?
end

def get_text(xml, css_path)
  node = xml.css(css_path)
  return node.nil? ? nil : node.text
end

def is_rdf_type?(pred)
  # "a" is shorthand in sparql queries for rdf:type
  return (pred == 'a' || pred == 'type')
end

def open_xml(path)
  file = File.open(path)
  tei = Nokogiri::XML(file)
  file.close
  return tei
end

def oscys_it(input)
  prefix = is_rdf_type?(input) ? PREFIXES[:rdf] : PREFIXES[:oscys]
  return RDF::URI.new("#{prefix}#{input}")
end

def osrdf_it(input, is_subject=false)
  regex = /per\.[0-9]{6}$/  # should match per.000001 etc
  input = input.nil? ? "" : input.strip  # cannot be nil, remove line breaks, etc
  # if it is a person then it is a URI, else return a literal
  if regex.match(input)
    return RDF::URI.new("#{PREFIXES[:osrdf]}#{input}")
  elsif is_subject
    return nil  # if the regex did not match and this is the subject, flag up as a bad thing
  else
    return input  # if it's not the subject then go ahead and just return the literal
  end
end


##########################
########  Script #########
##########################

repository = RDF::Repository.new

puts "Reading CSV file line by line"
CSV.foreach(csv_path, { :headers => true }) do |row|
  # TODO should we be checking that per.000000 rdf:type person before adding other stuff?
  error_msg(row)
  subj = osrdf_it(row[0], true)  # if the subject doesn't match the regex then reject
  pred = oscys_it(row[1])
  obj = osrdf_it(row[2])
  # the subject must be a valid person or else the triple won't work
  if subj
    repository << [subj, pred, obj]
    print "."
  else
    puts "\nIncorrect person id in CSV for #{row[0]} #{pred} #{obj} \n"
  end
end

tei = open_xml(tei_path)

puts "Reading through each TEI person entry"
people = tei.css('//person')
people.each do |person|
  id = person.attribute('id').value
  traits = assemble_traits(person)

  traits.each do |key, value|
    if !value.nil? && !value.empty?
      subj = osrdf_it(id, true)
      pred = oscys_it(key)
      obj = osrdf_it(value)  # should be literals but I'm running it through anyway
      if subj
        repository << [subj, pred, obj]
      else
        puts "\n Incorrect person id in TEI for #{id} #{pred} #{obj}\n"
      end
    end
  end
  print "+"
end

puts "\rWriting to file #{output}"
RDF::Writer.open(output, {:prefixes => PREFIXES , :format => :ttl}) do |writer|
  writer << repository
end


