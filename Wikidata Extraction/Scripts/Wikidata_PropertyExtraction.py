import json
import requests
import time

# Function to extract the last part of the item value (e.g., "Q62736" from the URL)
def get_last_section_of_item(item_url):
    return item_url['value'].split("/")[-1]

# Function to perform a SPARQL query to retrieve triples
def run_sparql_query(item_id):
    # SPARQL query to retrieve specific triples
    query = f"""
    SELECT ?property ?propertyLabel ?value ?valueLabel WHERE {{
    OPTIONAL {{
      wd:{item_id} ?property ?value .
      VALUES ?property {{
        wdt:P31
        wdt:P279
        wdt:P361
        wdt:P527
        wdt:P1889
        wdt:P366
        wdt:P3094
        wdt:P927
        wdt:P1269
        wdt:P4843
        wdt:P3189
        wdt:P460
        wdt:P2789
        wdt:P2670
        wdt:P2286
      }}
       }}
      SERVICE wikibase:label {{ bd:serviceParam wikibase:language "[AUTO_LANGUAGE],en". }}
    }}
    """

    url = "https://query.wikidata.org/sparql"
    headers = {"Accept": "application/sparql-results+json"}

    # Send the query to the Wikidata SPARQL endpoint
    #response = requests.get(url, headers=headers, params={'query': query})
    #response.raise_for_status()
    #time.sleep(1)
    #return response.json()
    while True:  # Retry loop in case of rate limiting
        try:
            response = requests.get(url, headers=headers, params={'query': query})
            response.raise_for_status()
            break  # Exit loop if successful
        except requests.exceptions.HTTPError as e:
            if e.response.status_code == 429:
                print("Rate limit exceeded. Waiting 60 seconds before retrying...")
                time.sleep(60)  # Wait for 60 seconds before retrying
            else:
                raise  # Re-raise other exceptions

    time.sleep(1)  # Additional delay after successful request
    return response.json()

# Function to append results to the JSON structure
def append_results_to_json(data, sparql_results, item, item_label):
    for result in sparql_results["results"]["bindings"]:
        print(result)
        # Extracting required fields from the SPARQL query result
        property_url = result["property"]["value"]
        property_label = result.get("propertyLabel", {}).get("value", "")
        value_url = result["value"]["value"]
        value_label = result.get("valueLabel", {}).get("value", "")

        # Append the new structure to the existing JSON
        data.append({
            "item": item,
            "itemLabel": item_label,
            "property": property_url,
            "propertyLabel": property_label,
            "value": value_url,
            "valueLabel": value_label
        })

# Main function to handle the process
def main():
    # Load the JSON file
    with open('/Users/fiore/PycharmProjects/pythonProject1/Wikidata_AnatomicalStructure_ID.json', 'r') as file:
        data = json.load(file)["results"]["bindings"]

    # Initialize a list to hold all updated results
    updated_data = data.copy()

    # Create a set to track the distinct item IDs that have already been queried
    queried_items = set()

    # Loop over each item in the original JSON file
    for entry in data:
        item_url = entry["item"]
        item_label = entry["itemLabel"]

        # Get the last section of the item value (e.g., "Q62736")
        item_id = get_last_section_of_item(item_url)

        # Check if the item ID has already been queried
        if item_id not in queried_items:
            # Run SPARQL query to retrieve additional triples for this distinct item
            sparql_results = run_sparql_query(item_id)

            # Append the SPARQL results to the original JSON structure
            append_results_to_json(updated_data, sparql_results, item_url, item_label)

            # Add the item ID to the set of queried items
            queried_items.add(item_id)

    # Save the updated JSON back to the file
    with open('Wikidata_AnatomicalStructure_Data.json', 'w') as file:
        # noinspection PyTypeChecker
        json.dump(updated_data, file, indent=4)
    file.close()
    print("Data successfully updated and saved.")

if __name__ == "__main__":
    main()
