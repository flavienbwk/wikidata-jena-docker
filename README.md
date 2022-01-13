# wikidata-jena-docker

Wikidata import in Apache Jena tripletstore (TDB) to be queried with SparQL.

- Using [fuseki-docker](https://github.com/SemanticComputing/fuseki-docker)

## Start

```bash
mkdir fuseki-data
sudo chown 9008 fuseki-data # Internal fuseki user
sudo chown 9008 -R fuseki-configuration # Internal fuseki user

docker-compose up -d
```

Connect with user `admin` and the password set in your docker-compose configuration
