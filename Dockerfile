FROM secoresearch/fuseki:4.3.2

USER 0

RUN apk add gzip
RUN apk add jq

RUN wget https://dlcdn.apache.org/jena/binaries/apache-jena-4.3.2.zip
RUN mkdir /jena-tools && unzip -d /jena-tools apache-jena-4.3.2.zip && rm apache-jena-4.3.2.zip

WORKDIR /jena-fuseki
EXPOSE 3030
USER 9008

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["java", "-cp", "*:/javalibs/*", "org.apache.jena.fuseki.cmd.FusekiCmd"]
