require 'open3'

def transform_to_solr(config, options, dir)
  # depending on the option sent in, pick a different script type
  script_hash = {
    "tei" => ""
  }

  source = "projects/test_data/tei/transmiss.per.hatchet.1898.xml"
  xslt = "scripts/xslt/cdrh_to_solr/solr_transform_tei.xsl"
  output = "testing.xml"
  saxon = "saxon -s:#{source} -xsl:#{xslt} -o:#{output}"

  # You may execute the below line instead of using Open3
  # but it does not have the same amount of stderr abilities
  # `saxon -s:#{source} -xsl:#{xslt} -o:#{output}`

  # execute the saxon command and make sure that you don't get a stderr!
  Open3.popen3(saxon) do |stdin, stdout, stderr|
    out = stdout.read
    err = stderr.read
    if err.length > 0
      puts "There was an error with the saxon transformation: "
      puts "#{err}"
      exit
    else
      puts "Saxon transformation successful" if options[:verbose]
    end
  end
  # TODO collect saxon errors
  # The above command is routed through a custom /usr/bin command
  # that doesn't have a whole lot of stdout and no stderr
  # so it's hard to tell if this thing even worked.
end