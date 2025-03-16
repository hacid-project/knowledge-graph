[.[] | {key: .Index, value: [keys.[] | select(. != "Index")]}] | from_entries as $indices_to_sectors |

[
    $indices_to_sectors | to_entries | .[] |
    {
        "@id": @uri "index:\(.key)",
        isClassifiedBy: [.value.[] | {"@id": @uri "sector:\(.)"} ]
    }
] as $indices |

[
    $indices_to_sectors | values | flatten | unique | .[] |
    {
        "@id": @uri "sectors:\(.)",
        "@type": "top:Concept",
        label: .,
        isDefinedIn: {"@id": "https://w3id.org/hacid/data/cs/climdex/sectors"}
    }
] as $sectors |

{
    "@context": {
        rdf: "http://www.w3.org/1999/02/22-rdf-syntax-ns#",
        rdfs: "http://www.w3.org/2000/01/rdf-schema#",
        top: "https://w3id.org/hacid/onto/top-level/",
        index: "https://w3id.org/hacid/data/cs/climdex/index",
        sectors: "https://w3id.org/hacid/data/cs/climdex/sectors/",
        label: "rdfs:label",
        comment: "rdfs:comment",
        acronym: "top:acronym",
        definition: "top:definition",
        isClassifiedBy: {
            "@reverse": "top:classifies"
        },
        isDefinedIn: {
            "@reverse": "top:defines"
        }
    },
    "@graph": [
        $indices.[],
        $sectors.[],
        {
            "@id": "https://w3id.org/hacid/data/cs/climdex/sectors",
            "@type": "top:Description",
            label: "Sectors according to climdex.org",
            comment: "Economic sectors defined to classify climate indices according to climdex.org"
        }
    ]
}
