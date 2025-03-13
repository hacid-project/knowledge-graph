PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
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
    ?superProperty a owl:ObjectProperty.
};

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
    ?superProperty a owl:DatatypeProperty.
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
    ?domain a owl:Class.
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
    ?range a owl:Class.
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
    ?superClass a owl:Class.
};

