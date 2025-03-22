PREFIX rdf:     <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs:     <http://www.w3.org/2000/01/rdf-schema#>
PREFIX owl:	    <http://www.w3.org/2002/07/owl>
PREFIX irao:    <http://ontology.ethereal.cz/irao>
PREFIX vann:    <http://purl.org/vocab/vann>
PREFIX odp:     <https://w3id.org/odp/onto/>
PREFIX status:  <https://w3id.org/odp/data/status/>

INSERT {
    GRAPH ?ontology {
        ?term rdfs:isDefinedBy ?ontology
    }
}
WHERE {
    ?ontology a owl:Ontology;
        odp:hasStatus status:draft;
        vann:preferredNamespaceUri ?ns.
    GRAPH ?ontology {
        ?term a ?termClass.
    }
    FILTER(STRSTARTS(STR(?term), ?ns))
    FILTER NOT EXISTS {
        GRAPH ?ontology {
            ?term rdfs:isDefinedBy ?ontology
        }
    }
};

DELETE {
    GRAPH ?ontology {
        ?term rdfs:isDefinedBy ?anotherOntology
    }
}
WHERE {
    ?ontology a owl:Ontology;
        odp:hasStatus status:draft;
        vann:preferredNamespaceUri ?ns.
    GRAPH ?ontology {
        ?term a ?termClass;
            rdfs:isDefinedBy ?anotherOntology.
    }
    FILTER(STRSTARTS(STR(?term), ?ns))
    FILTER(?anotherOntology != ?ontology)
};

