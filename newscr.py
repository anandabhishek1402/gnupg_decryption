import json

def process_redirects(input_data):
    output = []
    for redirect in input_data["redirects"]:
        path_rule = f"path_rule {{\n  paths= ['{redirect['regex']}']\n  url_redirect {{\n    path_redirect= '{redirect['destination']}'\n  }}\n  strip_query=false\n}}"
        output.append(path_rule)
    return output

def main():
    # Read input JSON file
    with open("input.json", "r") as f:
        input_data = json.load(f)
    
    # Process redirects
    output = process_redirects(input_data)

    # Output formatted result
    for rule in output:
        print(rule)
        print()

if __name__ == "__main__":
    main()
