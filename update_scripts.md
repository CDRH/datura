## File Structure: 

(all in /data)

- projects
	- projectName
		- tei [I think every project will have this, but perhaps not in the future]
		- html [derivative of TEI/other formats. Not sure if that should be more explicit]
		- spreadsheets {optional}
			- csv [the original files, as exported from excel or google docs]
			- xml [converted from xsv to make these easier to work with]
			- json {optional} [May use this data format to process instead of XML in the future]
			- scripts [any scripts having to do with processing this specific data (since it's normally not standardized) into solr input format or HTML snippits]
		- vra_core {optional} [used if the project has vra core images. If we find vra core differs a lot between projects, it may need it's own scripts to get in a standard format]
		- dublin_core {optional} [similar to above]
		- config {files are git ignored} [any project specific config files. Should contain URL or test and production sites, and any other data used by the scripts. Currently kept as XML because it can be easily passed into XSL scripts, but these may be passed in as params anyway so it would not matter.]

- scripts [may want to rethink organization of this once the scripts are complete]
	- ruby
	- shell
	- xslt 

- solr [place to keep all the solr files. Not sure if this is useful, should keep whatever is useful for the scripts. How are these different from HTML derivatives?]
	- projectName
	
- tmp [probably won't need this once scripts are built]




## Notes on scripts

I've described these as 2 separate scripts but they could be one script if that makes more sense to build. 




## Posting Script

###  Post all files for project projectName

Iterates through all data types (tei, csv, + more to come) and posts all content to solr index, as well as creating output html.

	$ ./post.rb projectName post -e development

	posted item tei/projectName.001.xml to development index
	....
	....
	posted item tei/projectName.100.xml to development index
	posted item csv/memorabilia.xml to development index

	Posting complete. Errors found in the following files, complete output in logs.
	projectName.001.xml
	projectName.049.xml

Note: posting to development is the default, so -e development is optional
	
### Post every data type to the production environment of projectName

	$ post.rb projectName -e production
	
	[feedback similar to above]

### Post all tei files to the test index

	$ post.rb projectName -d tei
	
	[feedback similar to above]
	
### Post just the spreadsheet files to an index

	$ ./script.rb projectName post -e development -d csv
	
### Post all files of every file type which are new since last update

	$ post projectName -u
	
	Posting files added since 2015-02-01T14:00:02
	
	posted item tei/projectName.001.xml to development index
	....
	posted item tei/projectName.100.xml to development index
	
	Posting complete. Errors found in the following files, complete output in logs.
	projectName.001.xml
	projectName.049.xml
	
### Post all files of every file type which are after date listed

	$ post projectName -u -t 2015-01-01
	
	[feedback similar to above]

### Post all files that match regex to index

	$ post projectName -r "projectName.*.xml"
	
	The following files will be posted to index
	
	projectName.001.xml
	projectName.002.xml
	projectName.003.xml
	projectName.004.xml
	
	continue? y/n
	
	$ y
	
	[feedback similar to above]

Note: I could also see using a flag like -f (feedback) or something to indicate the user wants a list of files which will be posted. Might also want feedback with date based posting. 




## Manage files

### Clear test index

	$ ./manage.rb projectName clear

	Are you sure you want to clear all files from the projectName development index http://rosie.unl.edu:8080/solr/api_projectName_test? y/n

	$ y
	
	Index Cleared
	
### Removes from index all data type TEI

	$ manage.rb projectName delete -d tei
	
	Are you sure you want to clear all tei files from the projectName development index http://rosie.unl.edu:8080/solr/api_projectName_test? y/n

	$ y
	
	Files deleted from index
	
### Removes all index files posted since DATE

	$ manage.rb projectName delete -t 2015-01-01
	
	The following files will be deleted from index
	
	projectName.001.xml
	projectName.002.xml
	projectName.003.xml
	projectName.004.xml
	
	continue? y/n
	
	$ y
	
	Files deleted from index
	
As above, might want to make the interactive version optional

### Removes all index files that match regex

	$ manage.rb projectName delete -r "cody.news.*.xml"
	
	[feedback and user acceptance]
	
### Removes all index files that match filename. 

Not sure if this is necessary because it's covered by regex

	$ manage.rb projectName delete -f "cody.news.001.xml"
	



## Help

It might be easiest to maintain a help file at a url to make it easier to browse. A help request might go like this: 

	$ manage.rb help
	
	The options available for this script are: 
	
	projectName clear
	projectName delete
	
	More complete documentation available at https://github.com/CDRH/data/blob/master/README.md
	
Something like that. 


	
	

## Error Messages

Some example error messages: 

	Must provide project name which corresponds to a folder in "projects."  Current folders are: 
	projectName1
	projectName2
	projectName3

Attempt to post to projectName test index at http://rosie.unl.edu:8080/solr/api_projectName_test failed. Please check config and index settings. 
Error: "blah blah whatever the error from solr was verbatim"

Folder projectName/tei does not exist. Please check that your files are in the correct location.  Check https://github.com/CDRH/data/blob/master/README.md for more information on correct file structure.



## Workflow Projections

### Task: User wants to index a starting set of new files for a TEI only site. 

#### 0: Add files to github using the correct file structure

#### 1: User adds files to github repository

#### 2: User logs into server and updates git repo

#### 3: User runs script to index files to test site

	$ ./script.rb projectName post -e development

#### 4: User checks dev site, makes sure it looks OK, and then posts to live site: 

	$ ./script.rb projectName post -e production
	



## Flags

Note: no flag for project, since it is required 

* -e [environment] - development or production, but could be arbitrary, with  proper config file settings
* -d [data type] - csv, tei, dublin-core
* -r [regex]
* -t [time] a date time in normalized format
* -u [update]



## Optional stuff

* Option to just create output HTML?
* some kind of preview for output HTML would be really useful. Could run through cocoon somehow or some other way of dynamically viewing. 
* Ways to pass through options to XSLT, like turning pagebreaks or figures off and on.
* A way to customize output HTML on a per project basis
* A script to help with git commits/pulls? helpful, perhaps, for updating certain folders.
* a feature to remove files that match a grep search. For instance, delete all files from index edited by xxx. Not sure if this would be all that useful, especially if the reindex script is fast enough we could just rerun the index quickly.  