# Web Scraping

These instructions demonstrate how to add the data and rails components of web scraping functionality for an existing application. The scripts will scrape web pages specified by section, ingest them, and create results that link to the pages. Note that the scripts will not work unless the app exists. If you are adding web scraping functionality for a new app, you will need to set scrape_website to "false" (and possibly temporarily remove the data_manager.rb file) before indexing the site for the first time. 

## In DATA repo
- go to `/config/public.yml`
    - add the following under `default`:
    ```
    #scrape_endpoint is tacked onto the end of site_url
    scrape_endpoint: content_pages
    scrape_website: true
    ```    
    - add the following under `production`:
    ```
    scrape_website: false
    ```
- \[OPTIONAL: localhost] go to `/config/private.yml`:    
    - add the following under `development`:
    ```
    scrape_website: true
    ```    
- create a new `data_manager.rb` file to put in `/scripts/overrides`
    - for an example see [data_manager.rb](https://github.com/CDRH/sample_files/blob/95c308a4035ceb1aec4bb260c12ad3ffdc64c7f9/data_manager.rb)
- create a new `webs_to_es.rb` file to put in `/scripts/overrides`
    - for an example see [webs_to_es.rb](https://github.com/CDRH/sample_files/blob/95c308a4035ceb1aec4bb260c12ad3ffdc64c7f9/webs_to_es.rb)
- create a new directory titled `webs` in `/source`
        
## In RAILS repo
- go to `/config/routes.rb`:
    - add the following lines just before the end: 
    ```
    #for web scraping
    get "content_pages", to: "general#content_pages", as: "content_pages"  
    ```    
- go to `/app/controllers/general_override.rb`:
    - add a `content_pages` method:
    ```
    # returns a list of all the rails views with content that should be searchable
    def content_pages
        all_routes = Rails.application.routes.routes.map do |route|
            route.path.spec.to_s
        end
        filtered = all_routes.select { |r| r[/about|correspondence/] }
        # get the current base URL + sub URI if it exists
        base_url = request.base_url
        if config.relative_url_root
            base_url = File.join(base_url, config.relative_url_root)
        end

        urls = filtered.map do |path|

            next if path.include?("objects_pt")

            path.gsub!("(.:format)", "").gsub!("(/:locale)", "")
            [
                File.join(base_url, path)
            ]
        end
        render json: urls.compact
    end
    ```    
- go to `/app/helpers/items_helper.rb`
    - add an exception or override for the site sections, for example: 
    ```
    if category == "site section"
      path = send("#{item_id}_path")
    ```      

## NOTES
- the particular sections you want scraped are designated by regular expression in `general_override.rb`:
	- `filtered = all_routes.select { |r| r[/about/] }` #scrapes pages with "about"
 in the path
	- `filtered = all_routes.select { |r| r[/about|corresponence/] }` #scrapes pages with "about" and "correspondence" in the path
	- `filtered = all_routes.select { |r| r[/explore|learn|research(?!\/maps)/] }` #scrapes pages with "explore" or "learn" or "research" in the path, with the exception of "research" pages that also have "maps" in the path
	- if you scrape a page with indexed results, all indexed results are included in text (but the results themselves are not created as separate web-scraped html pages)
- the title of the page is currently grabbed from the first `<h1>` in the HTML
- the rails site will need to be created before it is scraped
- to index data without scraping, you should adjust config files in data repo to `scrape_website: false` (but this will still index the files already scraped and in webs, if they exist)
- you will get an error if you try to post HTML (this is okay, you don't need HTML transformation for these)

## FILES changed or created

### DATA
- /config/public.yml
- /config/private.yml [OPTIONAL: localhost]
- /scripts/overrides/data_manager.rb
- /scripts/overrides/webs_to_es.rb
- /source/webs/

### RAILS
- /config/routes.rb
- /app/controllers/general_override.rb
- /app/helpers/items_helper.rb