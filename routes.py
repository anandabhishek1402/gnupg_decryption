def load_json(filename):
    with open(filename, 'r') as file:
        return json.load(file)

def generate_yaml_template(redirects):
    yaml_template = """
apiVersion: gateway.networking.k8s.io/v1beta1
kind: HTTPRoute
metadata:
  name: store
spec:
  parentRefs:
    - kind: Gateway
      name: external-http
  hostnames:
    - store.example.com
  rules:
"""
    for redirect in redirects:
        name = redirect['regex'].lower()
        yaml_template += f"""\
---
apiVersion: gateway.networking.k8s.io/v1beta1
kind: HTTPRoute
metadata:
  name: {name}
spec:
  parentRefs:
    - kind: Gateway
      name: external-http
  hostnames:
    - store.example.com
  rules:
    - matches:
      - path:
          type: PathPrefix
          value: /{redirect['regex']}
      filters:
        - type: RequestRedirect
          requestRedirect:
            path:
              type: ReplaceFullPath
              replaceFullPath: /{redirect['destination']}
            statusCode: 302
"""
    return yaml_template

def generate_combined_yaml_file(data):
    redirects = data['redirects']
    num_redirects = len(redirects)
    num_templates = num_redirects // 16 + (1 if num_redirects % 16 != 0 else 0)

    combined_yaml = ""
    for template_index in range(num_templates):
        combined_yaml += "apiVersion: gateway.networking.k8s.io/v1beta1\n"
        combined_yaml += "kind: HTTPRoute\n"
        combined_yaml += "metadata:\n"
        combined_yaml += "  name: store\n"
        combined_yaml += "spec:\n"
        combined_yaml += "  parentRefs:\n"
        combined_yaml += "    - kind: Gateway\n"
        combined_yaml += "      name: external-http\n"
        combined_yaml += "  hostnames:\n"
        combined_yaml += "    - store.example.com\n"
        combined_yaml += "  rules:\n"

        start_index = template_index * 16
        end_index = min((template_index + 1) * 16, num_redirects)
        redirects_chunk = redirects[start_index:end_index]

        for redirect in redirects_chunk:
            name = redirect['regex'].lower()
            combined_yaml += f"""\
    - matches:
      - path:
          type: PathPrefix
          value: /{redirect['regex']}
      filters:
        - type: RequestRedirect
          requestRedirect:
            path:
              type: ReplaceFullPath
              replaceFullPath: /{redirect['destination']}
            statusCode: 302
"""
        if template_index < num_templates - 1:
            combined_yaml += "---\n"

    with open("combined_output.yaml", "w") as file:
        file.write(combined_yaml)

import json

# Load JSON data
json_data = load_json("data.json")

# Generate combined YAML file
generate_combined_yaml_file(json_data)
