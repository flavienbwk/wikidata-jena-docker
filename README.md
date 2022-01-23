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
/jena-tools/apache-jena-4.3.2/bin/tdb2.xloader --loc /fuseki-base/databases/wikidata /wikidata/latest-all.ttl
```

In a 16Gb RAM system, _xloader_ will load 10Gb chunks in RAM and then write data to the disk.

This operation can take a lot of time (start: 21h50, end: , took: days on quad-core server-grade AMD CPU). There are two parts :

- Data storage (~ 1 day)
- Data indexing

## SparQL querying

Now, you can go to the dashboard page of your server at port `:3030` and test the following query :

```sparql
PREFIX wd: <http://www.wikidata.org/entity/>
PREFIX wdt: <http://www.wikidata.org/prop/direct/>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

SELECT ?charLabel ?groupLabel
WHERE {
	?group 	wdt:P31 wd:Q14514600;  		# ist eine Gruppe fiktiver Figuren
          	wdt:P1080 wd:Q931597.  		# aus fiktivem Marvel Universum
 	?char 	wdt:P463 ?group. 			# Mitglied der Gruppe
 	?char 	rdfs:label ?charLabel.		# Label der Figur
 	?group 	rdfs:label ?groupLabel. 	# Label der Gruppe
 	FILTER (LANG(?charLabel) = 'de').
 	FILTER (LANG(?groupLabel) = 'de').
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
 	?char 	rdfs:label ?charLabel.		# Character label
 	?group 	rdfs:label ?groupLabel. 	# Label of the group
 	FILTER (LANG(?charLabel) = 'de').
 	FILTER (LANG(?groupLabel) = 'de').
}
LIMIT 1000
"
```

## Credits

- Using [fuseki-docker](https://github.com/SemanticComputing/fuseki-docker)
- [Importing](https://muncca.com/2019/02/14/wikidata-import-in-apache-jena/#top) WikiData into Jena
