[.[] | {key: .Index, value: [keys.[] | select(. != "Index")]}] | from_entries as $indices_to_sectors |

[
    $indices_to_sectors | to_entries | .[] |
    {
        "@id": @uri "climdex:\(.key)",
        isClassifiedBy: [.value.[] | (@uri "sector:\(.)")]
    }
] as $indices |

[
    $indices_to_sectors | values | flatten | unique | .[] |
    {
        "@id": @uri "sectors:\(.)",
        "@type": "top:Concept",
        label: .,
        isDefinedIn: "https://w3id.org/hacid/data/climdex/sectors"
    }
] as $sectors |

{
    "@context": {
        rdf: "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
        rdfs: "http://www.w3.org/2000/01/rdf-schema#",
        top: "https://w3id.org/hacid/onto/top-level/",
        climdex: "https://w3id.org/hacid/data/climdex/",
        sectors: "https://w3id.org/hacid/data/climdex/sectors/",
        label: "rdfs:label",
        comment: "rdfs:comment",
        acronym: "top:acronym",
        definition: "top:definition",
        isClassifiedBy: {
            "@reverse": {"@id": "top:classifies"}
        },
        isDefinedIn: {
            "@reverse": {"@id": "top:defines"}
        }
    },
    "@graph": [
        $indices.[],
        $sectors.[],
        {
            "@id": "https://w3id.org/hacid/data/climdex/sectors",
            "@type": "top:Description",
            label: "Sectors according to climdex.org",
            comment: "Economic sectors defined to classify climate indices according to climdex.org"
        }
    ]
}
