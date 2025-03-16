import "cmip5-model-synonyms" as $model_synonyms_source;

(
    ["AER", "AS-RCEC", "AWI", "BCC", "BOM", "CAMS", "CAS", "CCCR-IITM", "CCCma",
    "CMCC", #(already included in model name)
    "CNRM-CERFACS", 
    "CSIRO", #(already included in model name)
    "CSIRO-ARCCSS", "CSIRO-BOM", "CNRM-CERFACS", "CSIRO-COSIMA", "CSIRO-QCCCE",  "QCCCE",
    "DKRZ", "DWD", "E3SM-Project", "EC-EARTH", "EC-Earth-Consortium", "ECMWF",
    "FIO", "FIO-QLNM", "GCESS", "HAMMOZ-Consortium", "ICHEC", "INM",
    "IPSL", #(already included in model name)
    "KIOST", "LASG-IAP", "LLNL",
    "MESSy-Consortium",
    "MIROC", #(already included in model name)
    "MOHC", "MPI-M",
    "MRI", #(already included in model name)
    "NASA-GISS", "NASA-GMAO", "NASA-GSFC",
    "NCAR", "NCC", "NCEP", "NERC", "NIMS-KMA", "NIWA", "NMR-KMA", "NOAA-GFDL", "NTU", "NUIST",
    "PCMDI", "PNNL-WACCEM", "RSMAS", "RTE-RRTMGP-Consortium", "RUBISCO", "SNU", "THU", "UA",
    "UCI", "UCSB", "UHH"]
    | sort_by(length) | reverse
) as $institutions |

#{
#    "CSIRO-Mk3-6-0": "CSIRO-Mk3.6.0",
#    "CSIRO-Mk3": "CSIRO-Mk3.6.0",
#    "MIROC-MIROC5": "MIROC5"
#}
$model_synonyms_source::model_synonyms_source[0]
as $model_synonyms |

(
    [
        (
            "cf_standard_name", "dataset_id_template_",
            "directory_format_template_", "domain", "driving_model", "ensemble",
            "experiment", "geo", "geo_units", "institute", "product", "project",
            "rcm_name", "rcm_version", "time_frequency", "variable",
            "variable_long_name", "variable_units"
        )
        | { key: ., value: true }
    ] | from_entries
)    as $false_arrays |

def get_institution_id:
    . as $composite_model_id |
    [$institutions | .[] | select(. as $institution_id | $composite_model_id | startswith($institution_id))] |
    (if length > 0 then .[0] else "" end);

def get_model_id:
#    (
#        . as $composite_model_id |
#        get_institution_id |
#        if length > 0
#            then . as $institution_id | $composite_model_id | ltrimstr($institution_id + "-")
#            else $composite_model_id
#        end
#    ) |
    if in($model_synonyms)
        then $model_synonyms[.]
        else .
    end;

def replace(pos; new_value):
    split(".") |
    [.[0:pos].[], new_value, .[pos+1:].[]] |
    join(".");

.response.docs = [
    .response.docs.[] |
#    with_entries(
#        if (.key | in($false_arrays))
#            then (.value = .value[0])
#            else .
#        end
#    ) |
    [.driving_model.[] | get_model_id] as $fixed_driving_models |
    .driving_model_institution = [.driving_model.[] | get_institution_id] |
    .driving_model = $fixed_driving_models |
    .id = (.id | replace(4; $fixed_driving_models | join(";")))
]


