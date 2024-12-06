import json
import csv

def map_to_snomed(json_file_path, umls_mapping_path, icd9_mapping_path, icd10_mapping_path, output_file_path):
    # Load JSON data from the input file
    with open(json_file_path, 'r') as file:
        data = json.load(file)

    # Load UMLS-to-SNOMED mapping file
    with open(umls_mapping_path, 'r') as umls_file:
        umls_to_snomed_mapping = json.load(umls_file)

    # Load ICD-9-to-SNOMED mapping file
    icd9_to_snomed_mapping = {}
    with open(icd9_mapping_path, 'r') as icd9_file:
        reader = csv.DictReader(icd9_file, delimiter='\t')
        for row in reader:
            if row["IS_CURRENT_ICD"] == "1":  # Only map active ICD-9 codes
                icd9_to_snomed_mapping[row["ICD_CODE"]] = row["SNOMED_CID"]

    # Load ICD-10-to-SNOMED mapping file
    icd10_to_snomed_mapping = {}
    with open(icd10_mapping_path, 'r') as icd10_file:
        reader = csv.DictReader(icd10_file, delimiter='\t')
        for row in reader:
            if row["active"] == "1":  # Only map active ICD-10 codes
                icd10_to_snomed_mapping[row["mapTarget"]] = row["referencedComponentId"]

    # Process the input JSON data
    combined_results = {}
    bindings = data.get("results", {}).get("bindings", [])
    for record in bindings:
        item_value = record.get("item", {}).get("value")
        id_property = record.get("idProperty", {}).get("value")
        id_value = record.get("idValue", {}).get("value")  # UMLS, ICD-9, or ICD-10 ID

        # Initialize the result for the current item
        if item_value not in combined_results:
            combined_results[item_value] = {
                "Original_IDs": [],
                "Mapped_SNOMED_IDs": []
            }

        # Add the original ID
        combined_results[item_value]["Original_IDs"].append({
            "Type": id_property,
            "Value": id_value
        })

        # Map UMLS to SNOMED
        if id_property == "http://www.wikidata.org/prop/direct/P2892":  # UMLS
            if id_value in umls_to_snomed_mapping:
                combined_results[item_value]["Mapped_SNOMED_IDs"].append({
                    "Type": "UMLS-to-SNOMED",
                    "Source_ID": id_value,
                    "SNOMED_IDs": umls_to_snomed_mapping[id_value]
                })

        # Map ICD-9 to SNOMED
        elif id_property == "http://www.wikidata.org/prop/direct/P493":  # ICD-9
            if id_value in icd9_to_snomed_mapping:
                combined_results[item_value]["Mapped_SNOMED_IDs"].append({
                    "Type": "ICD9-to-SNOMED",
                    "Source_ID": id_value,
                    "SNOMED_ID": icd9_to_snomed_mapping[id_value]
                })

        # Map ICD-10 to SNOMED
        elif id_property == "http://www.wikidata.org/prop/direct/P494":  # ICD-10
            if id_value in icd10_to_snomed_mapping:
                combined_results[item_value]["Mapped_SNOMED_IDs"].append({
                    "Type": "ICD10-to-SNOMED",
                    "Source_ID": id_value,
                    "SNOMED_ID": icd10_to_snomed_mapping[id_value]
                })

    # Save the combined results to the output file
    with open(output_file_path, 'w') as output_file:
        json.dump(combined_results, output_file, indent=4)

    # Print summary
    total_items = len(combined_results)
    total_mappings = sum(len(item["Mapped_SNOMED_IDs"]) for item in combined_results.values())
    print(f"Mapping completed. Combined results saved to {output_file_path}")
    print(f"Total items processed: {total_items}")
    print(f"Total mappings completed: {total_mappings}")

    return combined_results

json_file_path = '/path/to/Disease_ID.json'         # Path to input JSON file
umls_mapping_path = '/path/to/snomed_to_umls.json'  # Path to UMLS-to-SNOMED mapping file
icd9_mapping_path = '/path/to/icd9_to_snomed.txt'   # Path to ICD-9-to-SNOMED mapping file
icd10_mapping_path = '/path/to/icd10_to_snomed.txt' # Path to ICD-10-to-SNOMED mapping file
output_file_path = '/path/to/output.json'           # Path to output file

combined_results = map_to_snomed(
    json_file_path, umls_mapping_path, icd9_mapping_path, icd10_mapping_path, output_file_path
)
