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
        "@type": [(if (.parametric | not) then ["ccso:Index"] else [] end).[] , "ccso:ParametricIndex" ],
        acronym: .shortName,
        label: (.longName + " (" + .shortName + ")"),
        definition: .definition,
        comment: .description,
        hasUnitOfMeasure: (.units | if . then @uri "unit:\(.)" else [] end),
        generated: [if .generated then .generated else [] end | .[] | @uri "index:\(.)"],
        basedOnVariable: [.baseVars.[] | @uri "variable:\($base_vars_to_cmor[.])"],
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
        index: "https://w3id.org/hacid/data/climdex/index",
        sector: "https://w3id.org/hacid/data/climdex/sector/",
        variable: "https://w3id.org/hacid/data/dreq/mip-variable/",
        unit: "https://w3id.org/hacid/data/unitofmeasure/",
        label: "rdfs:label",
        comment: "rdfs:comment",
        acronym: "top:acronym",
        definition: "top:definition",
        hasUnitOfMeasure: {
            "@id": "top:hasUnitOfMeasure",
            "@type": "top:UnitOfMeasure"
        },
        permitsTemporalResolution: {
            "@id": "ccso:permitsTemporalResolution",
            "@type": "top:TimeDuration"
        },
        isClassifiedBy: {
            "@reverse": {"@id": "top:classifies"}
        },
        basedOnVariable: {
            "@id": "ccso:basedOnVariable",
            "@type": "ccso:Variable"
        },
        generated: "ccso:generated"
    },
    "@graph": [
        $indices.[]
    ]
}
