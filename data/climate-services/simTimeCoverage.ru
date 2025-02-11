PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX ccso: <https://w3id.org/hacid/onto/ccso/>
PREFIX data: <https://w3id.org/hacid/onto/data/>
PREFIX top: <https://w3id.org/hacid/onto/top-level/> 
PREFIX dimension: <https://w3id.org/hacid/data/cs/dimension/>
PREFIX time: <https://w3id.org/hacid/data/cs/metric-space/time/>

INSERT {
    GRAPH ?simulationGraph {
        ?simulationOutput data:dependsOnVariable ?simulationTemporalGrid.
        ?simulationTemporalGrid
            data:basedOnDimensionalSpace dimension:time, time:gregorian;
            data:hasExactBoundingRegion ?simulationTemporalRegion.
        ?simulationTemporalRegion
            rdfs:label ?simulationTemporalRegionLabel ;
            rdfs:comment ?simulationTemporalRegionComment ;
            data:hasStartDateTime ?simulationStartTime;
            data:hasEndDateTime ?simulationEndTime.
    }
}
WHERE {
    {
        SELECT
            ?simulationGraph ?simulationOutput
            (MIN(?startTime) AS ?simulationStartTime)
            (MAX(?endTime)AS ?simulationEndTime) 
            (MAX(?temporalDSTypeId) AS ?finerTemporalDSTypeId)
            (MIN(?temporalGridStep) AS ?minTemporalGridStep)
            (MIN(?temporalGridPeriod) AS ?minTemporalGridPeriod)
        WHERE {
            GRAPH ?simulationGraph {
                ?simulation a ccso:Simulation;
                    ccso:hasOutput ?simulationOutput.
                ?simulationOutput top:hasPart/data:dependsOnVariable ?temporalDS.
                ?temporalDS
                    a ?temporalDSType;
                    data:basedOnDimensionalSpace dimension:time;
                    data:hasExactBoundingRegion [
                        data:hasStartDateTime ?startTime;
                        data:hasEndDateTime ?endTime
                    ].
                OPTIONAL {?temporalDS data:hasGridStep ?temporalGridStep}.
                OPTIONAL {?temporalDS data:hasPeriod ?temporalGridPeriod}.
                VALUES (?temporalDSType ?temporalDSTypeId) {
                    (data:RollingRegularGrid 'rolling')
                    (data:PeriodicRegularGrid 'periodic')
                    (data:ConstantDimensionalSpace 'constant')
                }.
            }
        }
        GROUP BY ?simulationGraph ?simulationOutput
    }
    BIND(CONCAT(STR(?simulationStartTime), " ", STR(?simulationEndTime)) AS ?simInterval)
    BIND("(.*) (.*)" AS ?re)
    BIND(
        IRI(REPLACE(?simInterval, ?re,
            "https://w3id.org/hacid/data/cs/temporalregion/$1-$2"
        )) AS ?simulationTemporalRegion
    ).
    BIND(
        STRLANG(REPLACE(?simInterval, ?re,
            "Time interval $1 - $2"
        ), "en") AS ?simulationTemporalRegionLabel
    ).
    BIND(
        STRLANG(REPLACE(?simInterval, ?re,
            "Time interval starting at date time $1 and ending at date time $2."
        ), "en") AS ?simulationTemporalRegionComment
    ).
    BIND(
        CONCAT(
            ?finerTemporalDSTypeId,
            COALESCE(CONCAT ('/', ?minTemporalGridStep), ''),
            COALESCE(CONCAT ('/', ?minTemporalGridPeriod), '')
        ) AS ?gridTypeId
    ).
    BIND(
        IRI(
            CONCAT(
                REPLACE(
                    ?simInterval, ?re,
                    "https://w3id.org/hacid/data/cs/temporalregion/$1-$2/"
                ),
                ?gridTypeId
            )
        ) AS ?simulationTemporalGrid
    ).
}
