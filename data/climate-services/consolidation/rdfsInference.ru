PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX ccso: <https://w3id.org/hacid/onto/ccso/>
PREFIX data: <https://w3id.org/hacid/onto/data/>
PREFIX top: <https://w3id.org/hacid/onto/top-level/> 
PREFIX dimension: <https://w3id.org/hacid/data/cs/dimension/>
PREFIX time: <https://w3id.org/hacid/data/cs/metric-space/time/>

INSERT {
    GRAPH ?g {
        ?s ?superProperty ?o
    }
}
WHERE {
    GRAPH ?g {
        ?s ?property ?o
    }
    ?property rdfs:subPropertyOf+ ?superProperty.
    ?superProperty rdfs:label ?label.
  	FILTER NOT EXISTS {
      GRAPH ?g {
          ?s ?superProperty ?o
      }
    }
};

INSERT {
    GRAPH ?g {
        ?s a ?domain
    }
}
WHERE {
    GRAPH ?g {
        ?s ?property ?o
    }
    ?property rdfs:subPropertyOf*/rdfs:domain ?domain.
    ?domain rdfs:label ?label.
  	FILTER NOT EXISTS {
        GRAPH ?g {
            ?s a ?domain
        }
    }
};

INSERT {
    GRAPH ?g {
        ?o a ?range
    }
}
WHERE {
    GRAPH ?g {
        ?s ?property ?o
    }
    ?property rdfs:subPropertyOf*/rdfs:range ?range.
    ?range rdfs:label ?label.
  	FILTER NOT EXISTS {
        GRAPH ?g {
            ?o a ?range
        }
    }
};

INSERT {
    GRAPH ?g {
        ?o a ?range
    }
}
WHERE {
    GRAPH ?g {
        ?s ?property ?o
    }
    ?s rdf:type/rdfs:subClassOf+ [
        a owl:Restriction;
        owl:onProperty ?property;
        owl:allValuesFrom ?range
    ].
    ?range rdfs:label ?label.
  	FILTER NOT EXISTS {
        GRAPH ?g {
            ?o a ?range
        }
    }
};

INSERT {
    GRAPH ?g {
        ?s ?property ?s
    }
}
WHERE {
    GRAPH ?g {
        ?s a ?class
    }
    ?class rdfs:subClassOf+ [
        a owl:Restriction;
        owl:onProperty ?property;
        owl:hasSelf true
    ].
    ?class rdfs:label ?label.
  	FILTER NOT EXISTS {
        GRAPH ?g {
            ?s ?property ?s
        }
    }
};

INSERT {
    GRAPH ?g {
        ?s a ?superClass
    }
}
WHERE {
    GRAPH ?g {
        ?s a ?class
    }
    ?class rdfs:subClassOf+ ?superClass.
    ?superClass rdfs:label ?label.
  	FILTER NOT EXISTS {
        GRAPH ?g {
            ?s a ?superClass
        }
    }
};

