## Index

* [bb.json.set_json](#bbjsonsetjson)

### bb.json.set_json

---
Prints the `input` json document with field `key` set to a json value `value`.
This is helpful for when you want to embed one json document within another.

#### Example

```bash
# Prints
# {
#  "a": "b",
#  "c": {
#    "d": "e"
#  }
# }
echo '{"a": "b"}' > doc.json
bb json.set_json ".c" '{"d": "e"}' doc.json
```

#### Arguments

* **$1** (string): `key` jq path for the key to set
* **$2** (string): `value` json string to set as the value for `key`
* **$3** (string): `input` json file to set key-value within

#### Exit codes

* **0**: if successful

