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
        ?simulationQuantization
            a ?finestTemporalQuantizationType;
            data:hasResolutionValue ?minResolution;
            data:hasPeriodValue ?minGridPeriod.
    }
}
WHERE {
    {
        SELECT
            ?simulationGraph ?simulationOutput
            (MIN(?startTime) AS ?simulationStartTime)
            (MAX(?endTime)AS ?simulationEndTime) 
            (MAX(?quantizationTypeId) AS ?mostFineGrainedQuantizationTypeId)
            (MIN(?resolution) AS ?minResolution)
            (MIN(?gridPeriod) AS ?minGridPeriod)
        WHERE {
            GRAPH ?simulationGraph {
                ?simulation a ccso:Simulation;
                    ccso:hasOutput ?simulationOutput.
                ?simulationOutput top:hasPart/data:dependsOnVariable ?temporalDS.
                ?temporalDS
                    data:basedOnDimensionalSpace+ dimension:time;
                    data:hasExactBoundingRegion [
                        data:hasStartDateTime ?startTime;
                        data:hasEndDateTime ?endTime
                    ];
                    data:hasDiscretization ?quantization.
        		?quantization a ?quantizationType.
                OPTIONAL {?quantization data:hasResolutionValue ?resolution}.
                OPTIONAL {?quantization data:hasPeriodValue ?gridPeriod}.
                VALUES (?quantizationType ?quantizationTypeId) {
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
            ?mostFineGrainedQuantizationTypeId,
            COALESCE(CONCAT ('/', STR(?minResolution)), ''),
            COALESCE(CONCAT ('/', STR(?minGridPeriod)), '')
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
    BIND(
        IRI(
            CONCAT(
                "https://w3id.org/hacid/data/cs/temporalgrid/",
                ?gridTypeId
            )
        ) AS ?simulationQuantization
    ).
    VALUES (?finestTemporalQuantizationType ?mostFineGrainedQuantizationTypeId) {
        (data:RollingRegularGrid 'rolling')
        (data:PeriodicRegularGrid 'periodic')
        (data:ConstantDimensionalSpace 'constant')
    }.
}
