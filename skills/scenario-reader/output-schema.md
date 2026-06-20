# Scenario Reader — Output Schema

Produce this structured representation from the parsed blueprint:

```json
{
  "scenario_id": "string",
  "name": "string",
  "status": "active | inactive",
  "trigger": {
    "type": "webhook | schedule | instant | watch",
    "module": "string",
    "config": {}
  },
  "modules": [
    {
      "id": "string",
      "name": "string",
      "app": "string",
      "operation": "string",
      "position": 1,
      "has_error_handler": true,
      "can_fail": true,
      "data_in": ["field1", "field2"],
      "data_out": ["field1", "field2"],
      "hardcoded_values": []
    }
  ],
  "routes": [
    {
      "from": "module_id",
      "to": "module_id",
      "type": "normal | error | filter"
    }
  ],
  "filters": [
    {
      "position": "between module X and Y",
      "conditions": ["string"]
    }
  ],
  "issues_detected": [],
  "estimated_operations_per_run": 0,
  "has_error_handling": true,
  "has_notification": true,
  "touches_personal_data": false,
  "touches_payment_data": false,
  "touches_health_data": false
}
```
