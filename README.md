# WikiData Jena Docker

WikiData import in Apache Jena tripletstore (TDB) to be queried with SparQL.

## Terminology

- Apache Jena : Java framework for building Semantic Web and Linked Data applications
- Apache Jena Fuseki : SparQL server
- Apache Jena TDB : A RDF storage and query DBMS

## Download WikiData

From [WikiData dumps](https://dumps.wikimedia.org/wikidatawiki/entities/), download the [`latest-all.ttl.gz`](https://dumps.wikimedia.org/wikidatawiki/entities/latest-all.ttl.gz) file (~104 Go)

## Start Fuseki

Run the following commands :

```bash
mkdir fuseki-data
sudo chown 9008 fuseki-data # Internal fuseki user
sudo chown 9008 -R fuseki-configuration # Internal fuseki user

docker-compose up -d
```

## Resources considerations

:warning: Importing Wikidata takes a **lot of time** to index the 16.805 billion triples on a 24-threads bi-Xeon E5 CPU and 189Gb of RAM (128Gb of RAM is sufficient, consumption is below 100Gb). We recommend using a [cloud provider](https://www.scaleway.com/en/elastic-metal/).

There are two parts :

- Data storage (took: 2d16h17m)
- Data indexing (SPO took: 32h50m, POS: 77h19m, OPS: 32h01m)

> Number of triples at the time of the writing is (a bit more than) `16 805 375 870`

## Import data

_This requires 701Go of disk space at the time of the writing._

**Place** the downloaded `latest-all.ttl.gz` file into the `wikidata/` directory

**Unzip** the downloaded file :

```bash
cd wikidata
gzip -d latest-all.ttl.gz
```

**Import** the data :

```bash
docker-compose exec fuseki bash

# Inside container
cd /jena-tools/apache-jena-4.3.2/bin
/jena-tools/apache-jena-4.3.2/bin/tdb2.xloader --loc /fuseki-base/databases/wikidata /wikidata/latest-all.ttl # this takes a LOT of time
```

## SparQL querying

Now, you can go to the dashboard page of your server at port `:3030` and test the following query :

```sparql
PREFIX wd: <http://www.wikidata.org/entity/>
PREFIX wdt: <http://www.wikidata.org/prop/direct/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?charLabel ?groupLabel
WHERE {
	?group 	wdt:P31 wd:Q14514600;  		# is a group of fictional characters
          	wdt:P1080 wd:Q931597.  		# from fictional Marvel universe
 	?char 	wdt:P463 ?group. 			# Member of the group
 	?char 	rdfs:label ?charLabel.		# Label of the character
 	?group 	rdfs:label ?groupLabel. 	# Label of the group
 	FILTER (LANG(?charLabel) = 'fr').	# Get labels on french language
 	FILTER (LANG(?groupLabel) = 'fr').	# Get labels on french language
}
LIMIT 1000
```

Connect with user `admin` and the password set in your docker-compose configuration

Or query manually inside the container :

```sparql
/jena-tools/apache-jena-4.3.2/bin/tdb2.tdbquery --loc /fuseki-base/databases/wikidata "

PREFIX wd: <http://www.wikidata.org/entity/>
PREFIX wdt: <http://www.wikidata.org/prop/direct/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?charLabel ?groupLabel
WHERE {
	?group 	wdt:P31 wd:Q14514600;  		# is a group of fictional characters
          	wdt:P1080 wd:Q931597.  		# from fictional Marvel universe
 	?char 	wdt:P463 ?group. 			# Member of the group
 	?char 	rdfs:label ?charLabel.		# Label of the character
 	?group 	rdfs:label ?groupLabel. 	# Label of the group
 	FILTER (LANG(?charLabel) = 'fr').	# Get labels on french language
 	FILTER (LANG(?groupLabel) = 'fr').	# Get labels on french language
}
LIMIT 1000
"
```

## Credits

- Using [fuseki-docker](https://github.com/SemanticComputing/fuseki-docker)
- [Importing WikiData into Jena](https://muncca.com/2019/02/14/wikidata-import-in-apache-jena/#top)
