# WikiData Jena Docker

WikiData import in Apache Jena tripletstore (TDB) to be queried with SparQL.

## Terminology

- Apache Jena : Java framework for building Semantic Web and Linked Data applications
- Apache Jena Fuseki : SparQL server
- Apache Jena TDB : A RDF storage and query DBMS

## Download WikiData

From [WikiData dumps](https://dumps.wikimedia.org/wikidatawiki/entities/), download the [`latest-all.ttl.gz`](https://dumps.wikimedia.org/wikidatawiki/entities/latest-all.ttl.gz) file (~104 Go)

## Download Jena tools

This will allow us to bulk insert WikiData later

```bash
wget https://dlcdn.apache.org/jena/binaries/apache-jena-4.3.2.zip
unzip -d jena-tools apache-jena-4.3.2.zip
rm apache-jena-4.3.2.zip
```

## Start Fuseki

Run the following commands :

```bash
mkdir fuseki-data
sudo chown 9008 fuseki-data # Internal fuseki user
sudo chown 9008 -R fuseki-configuration # Internal fuseki user

docker-compose up -d
```

Connect with user `admin` and the password set in your docker-compose configuration

## Import data

_This requires 670Go of disk space at the time of the writing._

**Place** the downloaded `latest-all.ttl.gz` file into the `wikidata/` directory

**Unzip** the downloaded file :

```bash
cd wikidata
gzip -d latest-all.ttl.gz
```

**Import** the data :

```bash
docker-compose exec fuseki

# Inside container
/jena-tools/apache-jena-4.3.2/bin/tdb2.xloader --phase data --loc data/ wikidata/latest-all.ttl
/jena-tools/apache-jena-4.3.2/bin/tdb2.xloader --phase index --loc data/
```

## Credits

- Using [fuseki-docker](https://github.com/SemanticComputing/fuseki-docker)
- [Importing](https://muncca.com/2019/02/14/wikidata-import-in-apache-jena/#top) WikiData into Jena
