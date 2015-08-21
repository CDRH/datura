require 'linkeddata'

owl_file = File.join(File.dirname(__FILE__), '../rdf/oscys.objectproperties.owl')
output_file = File.join(File.dirname(__FILE__), '../rdf.oscys.objectproperties.ttl')


repository = RDF::Repository.load(owl_file)

PREFIXES = { 
  :osrdf => "http://cdrhsites.unl.edu/data/projects/oscys/rdf/oscys.relationships#", 
  :oscys => "http://cdrhsites.unl.edu/data/projects/oscys/rdf/oscys.objectproperties.owl#", 
  :rdfs => "http://www.w3.org/2000/01/rdf-schema#",
  :owl => "http://www.w3.org/2002/07/owl#"
}

RDF::Writer.open(output_file, {:prefixes => PREFIXES, :format => :ttl }) { |writer|
  writer << repository
}