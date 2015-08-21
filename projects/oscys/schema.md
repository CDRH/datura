# OSCYS Schema description

I have not compared these fields to every project to make sure they fit, but here is my preliminary list of general CDRH SOLR fields. All are single valued unless indicated:

## Resource Identification:

### id
* **id**
   * oscys.case.XXXX.XXX - Case Documents.  ID pulled from filename
        * **recordType_s:document**
   * oscys.mb*, oscys.report*, Supplementary case documents.  ID pulled from filename. 
        * **recordType_s:document**
   * oscys.caseid.XXXX - Case ID record. Describes a case. ID pulled from filename. 
        * **recordType_s:caseid**
   * per.XXXXX - Person record, describes a person. All come from 1 file: oscys.persons.xml  ID pulled from xml:id of person element. 
        * **recordType_s:person**
   
* **slug** (I have been using this in some contexts to indicate where the files are found, i.e. cody/xml/tei/. Should include the shorthand version of the project, i.e. "cody" at the least)
* **project** (the full CDRH name of the resource, e.g. "The William F. Cody Archive")
* **uri** (full URI of resource)
* **uriXML** (full URL to XML of data, when available)
* **uriHTML** (full URL to HTML snippit of data)
* **dataType** (the format the data was originally stored in at CDRH. current options: tei, dublin_core, vra_core, csv)

### Dublin Core Metadata Elements. 

I've included a couple of extra elements here as they make sense to support the DC elements. DC Elements described here: http://dublincore.org/documents/dcmi-terms/

* **title**
* **titleSort** (a,an,the removed/moved to the end)
* **creator** (a singular field for the creator, used for sorting. If there are multiple creators, they will be alphabetized  i.e. "Boggs, Jeremy; Earhart, Amy; Graham, Wayne"
* **creators** (multivalued field containing the names from above - <field>Boggs, Jeremy</field>, <field>Earhart, Amy</field>, <field>Graham, Wayne</field>)
* **subject** (generally won't be used because it's covered by topics below, but may use this for controlled vocab subject)
* **subjects** (multivalued version of above)
* **description** (a short description of the resource, often what will be shown in search results/aggregation pages)
* **publisher** (generally for books. The CDRH is the known publisher of the electronic versions, and we may want to find a way to distinguish that from the original publisher)
* **contributor** (all contributors collapsed into one field like creator above. Pulled from TEI resp statements and the like)
* **contributors** (multivalued)
* **date** (date using the solr date value)
* **dateDisplay** (however we want the date to display, either pulled from the TEI or normalized from the @when)
* **type** (From Dublin core, usually will be Image, Text, Sound or something like this. Often a duplicate of "subCategory" field)
* **format** (The file format, physical medium, or dimensions of the resource.)
* **medium** (added because a few projects seem to use it)
* **extent** (size or time span)
* **language**
* **relation** (A related resource that is substantially the same as the described resource, but in another format.)
* **coverage** (The spatial or temporal topic of the resource, the spatial applicability of the resource, or the jurisdiction under which the resource is relevant.) (Included for completeness, but probably covered in most cases by other fields)
* **source** (A related resource from which the described resource is derived) - in many cases, this may be the newspaper, publication, or book the resource is from.
* **rightsHolder** (A person or organization owning or managing rights over the resource.) - often this is where the CDRH got the object
* **rights** (any information about the rights)
* **rightsURI** (URI for above, will usually be linked to the "rights holder" for display purposes)

### Other elements: 

* **principalInvestigator** (in TEI header)
* **principalInvestigators** (multivalued)
* **place** (solr lat/long type) (for now, I am assuming each document has only one place. we may need to reevaluate in the future)
* **placeName** (name for the place above, or may be used without the lat/long)
* **recipient** (a singular field for the recipient(s), used for sorting. If there are multiple recipients, they will be alphabetized  i.e. "Boggs, Jeremy; Earhart, Amy; Graham, Wayne"
* **recipients** (multivalued field containing the names from above - <field>Boggs, Jeremy</field>, <field>Earhart, Amy</field>, <field>Graham, Wayne</field>)

### CDRH specific categorization (all pulled directly from the profileDesc)

* **category** - a way to categorize files. for OSCYS, the basic distinctions of document, caseid, and person are handled with recordType_s
* **subCategory**
* **topics** (multivalued)
* **keywords** (multivalued)
* **people** (multivalued)
* **places** (multivalued)
* **works** (multivalued)

### OSCYS general

Many fields have JSON in them so that the programmer can, for instance, build a link by grabbing the name of a person and the id in order to link it to the solr search for that person. The JSON Field will end in "Data_ss". The fields are:

* id: the id of the file/person/whatever. Usually this will be used to construct a link. the ID may be a source of the information.
* label: The name/title of the item. 
* date: sometimes there will be multiple bits of information distinguished by a date. The format should be whatever is to be displayed, this is not sortable. 
* sourcefile: this is just for troubleshooting, will probably be removed later

Fields with a name and ID attached will contain three versions:

* noun_ss - the label for the item, which will be the title/name. 
* nounID_ss - the id of the item, so we can do a solr search 
* nounData - the JSON field with any and all info to grab. 

### OSCYS General Fields
* **recordType_s** Usually we would handle this with category and subCategory, but OSCYS is using it for document type. See ID at the top for description. Choices are:
    * document
    * caseid
    * person
* **People** (additional to "people" field for OSCYS related purposes)
    * **people_ss**
    * **peopleID_ss** The id of a person appearing in the file. for person files this should be repeated from ID
    * **peopleData_ss** The ID and name of any people appearing in the file (Format: ID/Title)
* **Plaintiff**
    * **plaintiff_ss**
    * **plaintiffID_ss**
    * **plaintiffData_ss**
* **Defendant**
    * **defendant_ss**
    * **defendantID_ss**
    * **defendantData_ss**
* **Attorney for the Plaintiff**
    * **attorneyP_ss**
    * **attorneyPID_ss**
    * **attorneyPData_ss**
* **Attorney for the Defendant**
    * **attorneyD_ss**
    * **attorneyDID_ss**
    * **attorneyDData_ss**
* **All Attorneys**
    * **attorney_ss**
    * **attorneyID_ss**
    * **attorneyData_ss**
* **term_ss**
* **jurisdiction_ss** pulled form orgName for now
* **titleLetter_a** - first letter of title for sorting purposes


### OSCYS Person Fields

Not all these fields will need the "data" field but I am including them all right now. This section will be reworked as we make more sense of the personography. 

* **personAltName_ss**
* **personAffiliation_ss**
    * **personAffiliationData_ss**
* **personAge_ss**
    * **personAgeData_ss**
* **personBibl_ss**
    * **personBiblData_ss**
* **personBirth_ss**
    * **personBirthData_ss**
* **personDeath_ss**
    * **personDeathData_ss**
* **personEvent_ss**
    * **personEventData_ss**
* **personIdnoVIAF_ss**
* **personNationality_ss**
    * **personNationalityData_ss**
* **personNote_ss**
    * **personNoteData_ss**
* **personOccupation_ss**
    * **personOccupationData_ss**
* **personName_ss**
    * **personNameData_ss**
* **personResidence_ss**
    * **personResidenceData_ss**
* **personSex_ss**
* **personSocecStatus_ss**
    * **personSocecStatusData_ss**
* **personColor_ss**
    * **personColorData_ss**

### OSCYS CaseID Fields

* **relatedCaseID_ss** - related cases ID
* **relatedCaseData_ss** - JSON of ID + Label
* **caseDocumentID_ss** - inserting in all the documents into caseID filesm so we don't have to run a seperate solr query. I may be going overboard here. 
* **caseDocumentData_ss**
* **caseRelatedDocumentID_ss** - for related documents so we can pull them seperately - everything that is not category=Case Papers 
* **caseRelatedDocumentData_ss**
* **caseidHasNarrative_s**
* **outcome_ss** - the terms for outcome, i.e. "Verdict for Defendant" - useful for faceting on outcome. 
* **outcomeData_ss** - includes label, date (from document) and id of source

### OSCYS Documents Fields

* **documentCaseID_ss**  The id of any cases associate with this document
* **documentCaseData_ss**  - JSON of ID + Label

### Generic Text field: (much of the above is copied into this for text searching)

