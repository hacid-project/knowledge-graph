PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX ccso: <https://w3id.org/hacid/onto/ccso/>
PREFIX data: <https://w3id.org/hacid/onto/data/>
PREFIX top: <https://w3id.org/hacid/onto/top-level/> 
PREFIX dimension: <https://w3id.org/hacid/data/cs/dimension/>
PREFIX time: <https://w3id.org/hacid/data/cs/metric-space/time/>

INSERT {
    GRAPH ?g {
        ?depVar data:isSpecializedAccordingTo ?specialization.
        ?specialization
            a data:VariableSpecialization;
            data:isSpecializationOn ?indepVarGeneralized;
            data:isSelectedRegion ?boundingRegion
    }
}
WHERE {
    GRAPH ?g {
        ?depVar data:dependsOnVariable ?indepVar.
    }
    ?indepVar data:hasValuesOn/data:hasBoundingRegion ?boundingRegion.
    ?indepVar data:holdsSpecializationOfVariable+ ?indepVarGeneralized.
    FILTER NOT EXISTS {
        ?indepVarGeneralized data:hasValuesOn/data:hasBoundingRegion ?boundingRegion.
    }
    FILTER NOT EXISTS {
        GRAPH ?g {
            ?depVar data:isSpecializedAccordingTo/data:isSpecializationOn ?indepVarGeneralized
        }
    }
    BIND(CONCAT(STR(?indepVarGeneralized),'/specialization/', ENCODE_FOR_URI(STR(?boundingRegion))) AS ?specialization)
};

INSERT {
    GRAPH ?g {
        ?childVar data:isSpecializedAccordingTo ?parentVarSpecialization
    }
}
WHERE {
    GRAPH ?g {
        ?parentVar top:hasPart ?childVar.
    }
    ?parentVar data:isSpecializedAccordingTo ?parentVarSpecialization
    FILTER NOT EXISTS {
        GRAPH ?g {
            ?childVar data:isSpecializedAccordingTo ?parentVarSpecialization
        }
    }
};