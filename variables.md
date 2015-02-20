## Paths

* repo_directory: the full path of the files for the repo you're in. Used by xsl that outputs HTML
* fig_location: the location of the figures for the project
	* (Should we differentiate between test/production?)
* keyword_link: DELETE was used in tei-html, won't be used if we get rid of metadata box
* site_location: base URL of the rails/sinatra/cocoon site

## XSL Options
* metadata_box: DELETE pull this data from solr instead
* figures: true/false to turn figures on or off
* fw: true/false to turn form works on and off
* pb: true/false to turn page breaks on and off
* project: full project name
* ? slug: planning on pulling this from the containing folder, should it be a variable?
