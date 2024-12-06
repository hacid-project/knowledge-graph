import requests
import json
import time


# SPARQL query to be sent to Wikidata Query Service
def run_wikidata_query():
    query = """
    SELECT ?item ?itemLabel ?idProperty ?idPropertyLabel ?idValue ?idValueLabel WHERE {
      ?item wdt:P31/wdt:P279* wd:Q12136.  
      
      ?item ?idProperty ?idValue .
      VALUES ?idProperty { 
        wdt:P5806   # SNOMED CT ID
        wdt:P493    # ICD-9-CM
        wdt:P494    # ICD-10
        wdt:P2892   # UMLS CUI
      }
      SERVICE wikibase:label { bd:serviceParam wikibase:language "[AUTO_LANGUAGE],en". }
    }  
    """

    url = "https://query.wikidata.org/sparql"
    headers = {
        "Accept": "application/sparql-results+json"
    }

    # Send the query to the Wikidata Query Service
    response = requests.get(url, headers=headers, params={'query': query})
    print(response)
    time.sleep(5)


    # Check if the request was successful
    if response.status_code == 200:
        print(response.json())
        return response.json()  # Return the response as JSON
    else:
        raise Exception(f"Query failed with status code {response.status_code}: {response.text}")


# Function to save the SPARQL results to a JSON file
def save_results_to_file(data, filename):
    with open(filename, 'w') as file:
        # noinspection PyTypeChecker
        json.dump(data, file, indent=4)
    file.close()
    print(f"Data successfully saved to {filename}")


# Main function
def main():
    try:
        # Run the query to get the results from Wikidata Query Service
        sparql_results = run_wikidata_query()

        # Define the file to save the results
        output_file = 'Wikidata_Disease_ID2.json'

        # Save the results in JSON format
        save_results_to_file(sparql_results, output_file)

    except Exception as e:
        print(f"An error occurred: {e}")


# Entry point for the script
if __name__ == "__main__":
    main()
