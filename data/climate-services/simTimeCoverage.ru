PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX ccso: <https://w3id.org/hacid/onto/ccso/>
PREFIX top: <https://w3id.org/hacid/onto/top-level/> 

INSERT {
    GRAPH ?simulationGraph {
    	?simulation ccso:hasTemporalCoverage ?simulationTemporalCoverage.
        ?simulationTemporalCoverage
            rdfs:label ?simulationTemporalCoverageLabel ;
            rdfs:comment ?simulationTemporalCoverageComment ;
    		top:startTime ?simulationStartTime ;
            top:endTime ?simulationEndTime .
    }
}
WHERE {
    {
        SELECT
            ?simulationGraph ?simulation
            (MIN(?startTime) AS ?simulationStartTime)
            (MAX(?endTime)AS ?simulationEndTime) 
        WHERE {
            GRAPH ?simulationGraph {
                ?simulation a ccso:Simulation;
                    ccso:generatesProjection/ccso:hasTemporalCoverage [
                        top:startTime ?startTime ;
                        top:endTime ?endTime
                    ]
            }
        }
        GROUP BY ?simulationGraph ?simulation
    }
    BIND(CONCAT(STR(?simulationStartTime), " ", STR(?simulationEndTime)) AS ?simInterval)
    BIND("(.*) (.*)" AS ?re)
    BIND(
        IRI(REPLACE(?simInterval, ?re,
            "https://w3id.org/hacid/data/timeinterval/$1-$2"
        )) AS ?simulationTemporalCoverage
    ).
    BIND(
        STRLANG(REPLACE(?simInterval, ?re,
            "Time interval $1 - $2"
        ), "en") AS ?simulationTemporalCoverageLabel
    ).
    BIND(
        STRLANG(REPLACE(?simInterval, ?re,
            "Time interval starting at date time $1 and ending at date time $2."
        ), "en") AS ?simulationTemporalCoverageComment
    ).
}
