import json
import uuid
import sys

if len(sys.argv) != 4:
    print("Usage: python clone_realm.py input.json output.json NEW_REALM_NAME")
    sys.exit(1)

input_file = sys.argv[1]
output_file = sys.argv[2]
new_realm_name = sys.argv[3]

with open(input_file) as f:
    data = json.load(f)

old_realm_name = data.get("realm")
old_realm_id = data.get("id")
new_realm_id = str(uuid.uuid4())

id_map = {}
alias_map = {}
config_map = {}

PROTECTED_PROVIDER_IDS = [
    "ldap", "kerberos", "user-attribute-ldap-mapper", "msad-user-account-control-mapper",
    "kerberos-principal-attribute-mapper"
]

BUILTIN_FLOW_ALIASES = [
    "browser", "direct grant", "registration", "reset credentials", "clients",
    "docker auth", "first broker login"
]

BUILTIN_REQUIRED_ACTIONS = [
    "CONFIGURE_TOTP", "UPDATE_PASSWORD", "UPDATE_PROFILE", "VERIFY_EMAIL", "terms_and_conditions",
    "update_user_locale", "webauthn-register", "webauthn-register-passwordless"
]

TOP_LEVEL_FLOW_FIELDS = [
    "browserFlow", "registrationFlow", "directGrantFlow", "resetCredentialsFlow",
    "clientAuthenticationFlow", "dockerAuthenticationFlow", "firstBrokerLoginFlow"
]

def should_preserve_id(obj):
    if isinstance(obj, dict):
        if obj.get("providerId") in PROTECTED_PROVIDER_IDS:
            return True
    return False

def is_builtin_auth_flow(obj):
    return (
        isinstance(obj, dict)
        and obj.get("providerId") in ["basic-flow", "client-flow", "form-flow"]
        and obj.get("alias") in BUILTIN_FLOW_ALIASES
    )

def is_custom_auth_flow(obj):
    return (
        isinstance(obj, dict)
        and obj.get("providerId") in ["basic-flow", "client-flow", "form-flow"]
        and obj.get("alias") not in BUILTIN_FLOW_ALIASES
    )

def is_builtin_required_action(obj):
    return (
        isinstance(obj, dict)
        and obj.get("alias") in BUILTIN_REQUIRED_ACTIONS
    )

def is_custom_required_action(obj):
    return (
        isinstance(obj, dict)
        and obj.get("alias") not in BUILTIN_REQUIRED_ACTIONS
    )

def make_unique_alias(alias):
    return f"{alias}-{str(uuid.uuid4())[:8]}"

def replace_ids(obj):
    if isinstance(obj, dict):
        # Do not change IDs for protected providers (LDAP, Kerberos, etc.)
        if should_preserve_id(obj):
            if "realm" in obj and obj["realm"] == old_realm_name:
                obj["realm"] = new_realm_name
            for k, v in obj.items():
                obj[k] = replace_ids(v)
            return obj

        # Built-in authentication flows: do not change id/alias, but update realm name in strings
        if is_builtin_auth_flow(obj):
            if "realm" in obj and obj["realm"] == old_realm_name:
                obj["realm"] = new_realm_name
            for k, v in obj.items():
                if isinstance(v, str) and old_realm_name in v:
                    obj[k] = v.replace(old_realm_name, new_realm_name)
                else:
                    obj[k] = replace_ids(v)
            return obj

        # Custom authentication flows: change id and alias, update references
        if is_custom_auth_flow(obj):
            if "id" in obj:
                old_id = obj["id"]
                if old_id not in id_map:
                    id_map[old_id] = str(uuid.uuid4())
                obj["id"] = id_map[old_id]
            if "alias" in obj:
                old_alias = obj["alias"]
                if old_alias not in alias_map:
                    alias_map[old_alias] = make_unique_alias(old_alias)
                obj["alias"] = alias_map[old_alias]
            for k, v in obj.items():
                if isinstance(v, str) and old_realm_name in v:
                    obj[k] = v.replace(old_realm_name, new_realm_name)
                else:
                    obj[k] = replace_ids(v)
            return obj

        # Built-in required actions: do not change id/alias, but update realm name in strings
        if is_builtin_required_action(obj):
            for k, v in obj.items():
                if isinstance(v, str) and old_realm_name in v:
                    obj[k] = v.replace(old_realm_name, new_realm_name)
                else:
                    obj[k] = replace_ids(v)
            return obj

        # Custom required actions: change id and alias, update references
        if is_custom_required_action(obj):
            if "id" in obj:
                old_id = obj["id"]
                if old_id not in id_map:
                    id_map[old_id] = str(uuid.uuid4())
                obj["id"] = id_map[old_id]
            if "alias" in obj:
                old_alias = obj["alias"]
                if old_alias not in alias_map:
                    alias_map[old_alias] = make_unique_alias(old_alias)
                obj["alias"] = alias_map[old_alias]
            for k, v in obj.items():
                if isinstance(v, str) and old_realm_name in v:
                    obj[k] = v.replace(old_realm_name, new_realm_name)
                else:
                    obj[k] = replace_ids(v)
            return obj

        # Change IDs for custom roles, clients, etc. and update names if they contain the old realm name
        if "id" in obj:
            old_id = obj["id"]
            if old_id == old_realm_id:
                obj["id"] = new_realm_id
            else:
                if old_id not in id_map:
                    id_map[old_id] = str(uuid.uuid4())
                obj["id"] = id_map[old_id]
        if "containerId" in obj and obj["containerId"] == old_realm_id:
            obj["containerId"] = new_realm_id
        if "name" in obj and isinstance(obj["name"], str) and old_realm_name in obj["name"]:
            obj["name"] = obj["name"].replace(old_realm_name, new_realm_name)
        # Replace old realm name in all string fields
        for k, v in obj.items():
            if isinstance(v, str) and old_realm_name in v:
                obj[k] = v.replace(old_realm_name, new_realm_name)
            elif isinstance(v, dict) or isinstance(v, list):
                obj[k] = replace_ids(v)
            else:
                obj[k] = v
        # Update references to custom flow IDs and aliases, required actions, etc.
        for k, v in obj.items():
            if k in ["authenticationFlowBindingOverrides", "flowAlias", "defaultAction", "requiredActions", "authenticatorConfig"]:
                if isinstance(v, dict):
                    for flow_key, flow_val in v.items():
                        if flow_val in id_map:
                            v[flow_key] = id_map[flow_val]
                        if flow_val in alias_map:
                            v[flow_key] = alias_map[flow_val]
                        if flow_val in config_map:
                            v[flow_key] = config_map[flow_val]
                elif isinstance(v, list):
                    obj[k] = [id_map.get(x, alias_map.get(x, config_map.get(x, x))) for x in v]
                elif isinstance(v, str):
                    if v in id_map:
                        obj[k] = id_map[v]
                    elif v in alias_map:
                        obj[k] = alias_map[v]
                    elif v in config_map:
                        obj[k] = config_map[v]
        return obj
    elif isinstance(obj, list):
        return [replace_ids(i) for i in obj]
    else:
        if isinstance(obj, str) and old_realm_name in obj:
            return obj.replace(old_realm_name, new_realm_name)
        return obj

def update_flow_alias_and_config_references(obj):
    if isinstance(obj, dict):
        for k, v in obj.items():
            # Update flowAlias in executions and subflows
            if k == "flowAlias" and isinstance(v, str) and v in alias_map:
                obj[k] = alias_map[v]
            # Update authenticatorConfig in executions
            if k == "authenticatorConfig" and isinstance(v, str) and v in config_map:
                obj[k] = config_map[v]
            elif isinstance(v, dict) or isinstance(v, list):
                update_flow_alias_and_config_references(v)
    elif isinstance(obj, list):
        for item in obj:
            update_flow_alias_and_config_references(item)

# Set new realm id and name at top level
data["id"] = new_realm_id
data["realm"] = new_realm_name
if "displayName" in data:
    data["displayName"] = new_realm_name

# First, update authenticatorConfig IDs and build config_map
if "authenticatorConfig" in data and isinstance(data["authenticatorConfig"], list):
    for cfg in data["authenticatorConfig"]:
        if "id" in cfg:
            old_id = cfg["id"]
            new_id = str(uuid.uuid4())
            config_map[old_id] = new_id
            cfg["id"] = new_id
        if "name" in cfg and old_realm_name in cfg["name"]:
            cfg["name"] = cfg["name"].replace(old_realm_name, new_realm_name)

data = replace_ids(data)

# Update top-level flow references to new aliases if changed
for flow_field in TOP_LEVEL_FLOW_FIELDS:
    if flow_field in data:
        old_alias = data[flow_field]
        if old_alias in alias_map:
            data[flow_field] = alias_map[old_alias]

# Update all flowAlias and authenticatorConfig references in subflows/executions
if "authenticationFlows" in data:
    update_flow_alias_and_config_references(data["authenticationFlows"])

with open(output_file, "w") as f:
    json.dump(data, f, indent=2)

print(f"Cloned realm written to {output_file} with new realm name '{new_realm_name}' and new IDs.")