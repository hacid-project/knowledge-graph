# Headers to map input table to JSON
["shortName", "longName", "definition", "description", "units", "timeScales", "sectors"] as $headers |

# Incomplete trim function, just good enough for current usage
def trim:
    ltrimstr(" ") | ltrimstr("\t") |  ltrimstr("\n") |
    rtrimstr(" ") | rtrimstr("\t") |  rtrimstr("\n");

# JSON version of input table
[
    split("\n") | .[2:].[] | split("|") | .[1:-1] |
    to_entries | [.[] | {key: $headers[.key], value: .value | trim} ] | from_entries |
    .sectors |= ([(. + "") | split(", ").[] | split(",").[] ] | flatten) |
    .timeScales |= ((. + "") | split("/"))
] as $input_as_json |

# Specification of the three variants used for heatwave indices
[
    {
        shortName: "EHF",
        longName: "Excess Heat Factor (EHF)",
        definition: "the EHF is positive",
        baseVar: "TM"
    },
    {
        shortName: "Tx90",
        longName: "90th percentile of TX",
        definition: "TX > 90th percentile of TX",
        baseVar: "TX"
    },
    {
        shortName: "Tn90",
        longName: "90th percentile of TN",
        definition: "TN > 90th percentile of TN",
        baseVar: "TN"
    }
] as $heatwave_variants |
"(EHF/Tx90/Tn90)" as $heatwave_suffix |

# Specification of parameters used in parametric indices
{
    propertyId: "heatwaveMethod",
    shortName: "heatwave identification method",
    varLabel: "m"
} as $heatwaveMethodVar |
{
    propertyId: "minimumLength",
    shortName: "minimum length",
    varLabel: "d"
} as $minimumLengthVar |
{
    propertyId: "baseTemperature",
    shortName: "base temperature",
    varLabel: "n"
} as $baseTemperatureVar |
{
    propertyId: "minimumPrecipitation",
    shortName: "minimum precipitation",
    varLabel: "nn"
} as $minimumPrecipitationVar |

# Specification of parametric indices
{
    "WSDId": {
        parameters: [$minimumLengthVar],
        generated: []
    },
    "CSDId": {
        parameters: [$minimumLengthVar],
        generated: []
    },
    "TXdTNd": {
        parameters: [$minimumLengthVar],
        generated: []
    },
    "HDDheatn": {
        parameters: [$baseTemperatureVar],
        generated: []
    },
    "CDDcoldn": {
        parameters: [$baseTemperatureVar],
        generated: []
    }, 
    "GDDgrown": {
        parameters: [$baseTemperatureVar],
        generated: []
    },
    "RXdday": {
        parameters: [$minimumLengthVar],
        generated: ["Rx1day", "Rx5day"]
    },
    "TXbdTNbd": {
        parameters: [$minimumLengthVar],
        generated: []
    },
    "Rnnmm": {
        parameters: [$minimumPrecipitationVar],
        generated: ["R10mm", "R20mm"]
    }
} as $parametric_indices |

# Variable synonyms (used for lookup in textual fields)
{
    "RR": "PR"
} as $base_vars_synonyms |

# Derived variables (used for lookup in textual fields)
{
    "SPI": ["PR"],
    "SPEI": ["PR", "TM"],
    "ECF": ["TM"]
} as $base_vars_expansion |

# Conversion to CMOR tables standard names
{
    "TM": "tas",
    "TN": "tasmin",
    "TX": "tasmax",
    "PR": "pr"
} as $base_vars_to_cmor |

# Conversion to unit standard names
{
    "days": "day",
    "unitless": "1",
    "Number%20of%20individual%20heatwaves%20events": "event",
    "events": "event"
} as $units_to_cmor_units |

def convert_unit:
    if in($units_to_cmor_units) then $units_to_cmor_units[.] else . end;

# Conversion to temporalgrids standard names
{
    "Daily": ["day"],
    "Mon": ["mon"],
    "Ann": ["yr"],
    "Custom": ["3mon", "6mon", "yr"]
} as $timescales_to_temporalgrids |

def convert_timescales:
    [
        .[] |
        if in($timescales_to_temporalgrids)
            then $timescales_to_temporalgrids[.]
            else [.]
        end
    ] | flatten;

def convert_parameter:
    {
        "@id": @uri "parameter:\(.propertyId)",
        "label": .shortName,
        "acronym": .varLabel
    };

(
    [
        ($base_vars_synonyms | to_entries | .[] | (.value |= [.])),
        ($base_vars_expansion | to_entries | .[]),
        ($base_vars_to_cmor | keys | .[] | {key: ., value: [.]})
    ] |
    from_entries
) as $base_vars_dict |

[
    $input_as_json.[] |

    # Set .parametric as false by default
    (.parametric = false) |

    # Heuristic to find baseVars as labels in string fields
    (
        .baseVars = (
            [
                . as $index | $base_vars_dict | keys | .[] |
                select(
                    . as $param |
                    ($index.definition | contains($param)) or
                        ($index.longName | contains($param)) or
                        ($index.description | contains($param))
                ) |
                $base_vars_dict[.]
            ] | flatten | unique
        )
    ) |

    # Fix baseVars for SPI (the previous heuristic would add also temperature)
    if (.shortName == "SPI")
        then (.baseVars = ["PR"])
    end |

    # Handle heatwave indexes that have multiple variants (methods), as parametric indices generating the corresponding variants
    if (.shortName | endswith($heatwave_suffix))
        then (
            (.shortName | .[0:rindex($heatwave_suffix)]) as $shortName_prefix |
            (.longName | .[0:index("either")] | (. + "the ")) as $longName_prefix |
            (.definition | if contains("either") then .[0:(index("either") - 4)] else null end) as $definition_prefix |
            (.definition | if contains(". ") then .[(rindex(". ") - 4):] else null end) as $definition_suffix |
            (
                (
                    (.parametric = true) |
                    (.parameters = [$heatwaveMethodVar]) |
                    (.generated = [$heatwave_variants.[] | ($shortName_prefix + "_" + .shortName)]) |
                    (.baseVars = [$heatwave_variants.[] | .baseVar]) |
                    (.units |= if (. == "°C (°C^2 for  EHF)") then empty end)
                ),
                (
                    . as $heatwave_multiindex |
                    $heatwave_variants.[] | . as $variant |
                    $heatwave_multiindex |
                    (.heatwaveMethod = $variant.shortName) |
                    (.shortName = $shortName_prefix + "_" + $variant.shortName) |
                    (.longName = $longName_prefix + $variant.longName) |
                    (.definition |= if contains("either") then ($definition_prefix + $variant.definition + $definition_suffix) end) |
                    (.baseVars = [$variant.baseVar]) |
                    (.units |=
                        if ($heatwave_multiindex.units == "°C (°C^2 for  EHF)")
                            then (if ($variant.shortName == "EHF") then "°C^2" else "°C" end)
                        end
                    )
                )
            )
        )
    end |

    # Set information about parametric indexes (a part from heatwave indexes considered above)
    if (.shortName | in($parametric_indices))
        then (
            (.parametric = true) |
            (.parameters = $parametric_indices[.shortName].parameters) |
            (.generated = $parametric_indices[.shortName].generated)
        )
    end

] as $input_as_json_extended |

[
    $input_as_json_extended.[] |
    {
        "@id": @uri "index:\(.shortName)",
#        "@type": [(if (.parametric | not) then ["ccso:Index"] else [] end).[] , "ccso:ParametricIndex" ],
        "@type": ["data:Variable", "data:DependentVariable"],
        acronym: .shortName,
        label: (.longName + " (" + .shortName + ")"),
        definition: .definition,
        comment: .description,
        hasUnitOfMeasure: (.units | if . then @uri "unit:\(convert_unit)" else [] end),
        hasValuesOn: (.units | if . then @uri "unit:\(convert_unit)" else [] end),
        generated: [if .generated then .generated else [] end | .[] | {"@id": @uri "index:\(.)"}],
        basedOnVariable: [.baseVars.[] | @uri "variable:\($base_vars_to_cmor[.])"],
        dependsOnVariable: ["dimension:geodetic", "dimension:time", if .parameters then (.parameters | .[] | convert_parameter) else empty end],
        definesAggregation: {
            "@id": @uri "aggregation:\(.shortName)",
            aggregatesVariable: "dimension:time",
            suggestedAggregationGrid: [ .timeScales | convert_timescales | .[] | @uri "temporalgrid:\(.)" ]
        },
#        isClassifiedBy: [.sectors | ("sector:" + .)],
        rest: .
    }
] as $indices |

{
    "@context": {
        rdf: "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
        rdfs: "http://www.w3.org/2000/01/rdf-schema#",
        top: "https://w3id.org/hacid/onto/top-level/",
        ccso: "https://w3id.org/hacid/onto/ccso/",
        data: "https://w3id.org/hacid/onto/data/",
        index: "https://w3id.org/hacid/data/cs/climdex/index",
        sector: "https://w3id.org/hacid/data/cs/climdex/sector/",
        parameter: "https://w3id.org/hacid/data/cs/climdex/parameter/",
        variable: "https://w3id.org/hacid/data/cs/variable/mip/",
        unit: "https://w3id.org/hacid/data/cs/unitofmeasure/",
        dimension: "https://w3id.org/hacid/data/cs/dimension/",
        aggregation: "https://w3id.org/hacid/data/cs/climdex/index-time-aggregation/",
        temporalgrid: "https://w3id.org/hacid/data/cs/temporalgrid/",
        label: "rdfs:label",
        comment: "rdfs:comment",
        acronym: "top:acronym",
        definition: "top:definition",
        hasUnitOfMeasure: {
            "@id": "top:hasUnitOfMeasure",
            "@type": "top:UnitOfMeasure"
        },
        hasValuesOn: {
            "@id": "data:hasValuesOn",
            "@type": "data:DimensionalSpace"
        },
        dependsOnVariable: {
            "@id": "data:dependsOnVariable",
            "@type": "data:Variable"
        },
        definesAggregation: {
            "@id": "data:definesAggregation",
            "@type": "data:Aggregation"
        },
        aggregatesVariable: {
            "@id": "data:aggregatesVariable"
        },
        suggestedAggregationGrid: {
            "@id": "data:suggestedAggregationGrid",
            "@type": "data:Grid"
        },
        permitsTemporalResolution: {
            "@id": "ccso:permitsTemporalResolution",
            "@type": "top:TimeDuration"
        },
        basedOnVariable: {
            "@id": "data:derivedFromVariable",
            "@type": "data:Variable"
        },
        generated: {
            "@reverse": "data:holdsSpecializationOfVariable"
        }
    },
    "@graph": [
        $indices.[]
    ]
}
