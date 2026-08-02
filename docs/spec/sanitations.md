_Authors_: @ballerina-platform \
_Created_: 2024/08/05 \
_Updated_: 2026/08/02 \
_Edition_: Swan Lake

# Sanitation for OpenAPI specification

This document records the sanitation done on top of the official OpenAPI specification from OpenAI.
The OpenAPI specification is obtained from the [OpenAPI specification for the OpenAI API](https://app.stainless.com/api/spec/documented/openai/openapi.documented.yml).
These changes are done in order to improve the overall usability, and as workarounds for some known language limitations.

1. **Expressed nullability using OpenAPI 3.1 type arrays and enum `null` members**:

   - **Changed Schemas**: Multiple schemas throughout the specification (43 sites)
   - **Original**: `type: string` with `nullable: true` (OpenAPI 3.0 style)
   - **Updated**:
      - Non-enum schemas: `type: [string, 'null']`
      - Enum schemas: `null` added as an enum member (e.g. `enum: [auto, default, null]`)
   - **Reason**: This specification declares `openapi: 3.1.0`, and `nullable` is not a keyword in OpenAPI 3.1. The Ballerina OpenAPI tool ignores it, so every field marked this way was generated as non-nilable. The concrete failure was `ChatCompletionTokenLogprob.bytes`, a **required** field that the OpenAI API returns as `null`; it generated as `int[] bytes`, so any `logprobs: true` call could fail data binding. The remaining sites were on optional fields, where the `laxDataBinding` default of `true` silently discards the nulls — they fail only when a user sets `laxDataBinding: false`.
   - **Note on enums**: the type-array form alone is *not* sufficient for enum schemas. `type: [string, 'null']` combined with `enum:` generates a non-nilable union (`"a"|"b"`), silently dropping the null. Adding `null` as an enum member generates `"a"|"b"?` as intended. This was verified against the tool before applying.

2. **Removed `default: null` properties**:

   - **Changed Schemas**: Multiple schemas including request and response types
   - **Original**: `default: null`
   - **Updated**: Removed the `default` parameter
   - **Reason**: Temporary workaround until the Ballerina OpenAPI tool supports OpenAPI Specification version v3.1.x.

3. **Converted `const` to `enum`**:

   - **Changed Schemas**: Multiple schemas with constant values
   - **Original**: `const: "value"`
   - **Updated**: `enum: ["value"]`
   - **Reason**: The `const` keyword is not supported in OpenAPI 3.0.0. Using `enum` with a single value achieves the same effect.

4. **Converted `anyOf`/`oneOf` with null types**:

   - **Changed Schemas**: Multiple schemas using `anyOf`/`oneOf` with `{"type": "null"}`
   - **Original**: `anyOf: [{"type": "string"}, {"type": "null"}]`
   - **Updated**:
      - Where the union carried no other member: collapsed to the type-array form, `type: [string, 'null']`
      - Where a genuine union must be preserved (e.g. `ChatCompletionRequestAssistantMessage.content`, `StopConfiguration`): the nullability is expressed on one branch, `oneOf: [{type: [string, 'null']}, {type: array, ...}]`, which generates `string|string[]?`
   - **Reason**: The Ballerina OpenAPI tool does not recognise `{"type": "null"}` as a union member. A schema written as `anyOf: [{type: array}, {type: 'null'}]` generates `anydata`, discarding the type entirely — this is why the pre-sanitation types were `anydata bytes`, `ServiceTier anydata` and so on. The forms above were verified against the tool before applying.

5. **Removed `webhooks` section**:

   - **Reason**: The `webhooks` key is not supported in OpenAPI 3.0.0.

6. **Removed `jsonSchemaDialect`**:

   - **Reason**: The `jsonSchemaDialect` key is not supported in OpenAPI 3.0.0.

7. **Kept `top_logprobs`, `temperature` and `top_p` non-nilable to preserve their numeric constraints**:

   - **Changed Schemas**: `ModelResponseProperties`, `CreateModelResponseProperties`, `CreateChatCompletionRequest`
   - **Original**: `nullable: true` alongside `minimum`/`maximum`
   - **Updated**: `nullable` removed; `type: integer` / `type: number` retained with their `minimum`/`maximum`
   - **Reason**: Ballerina rejects a constraint annotation on a nilable type — `@constraint:Int` on `int?` is a compile error (`invalid '@constraint:Int' annotation on 'int?' type`). Both cannot be expressed, so the validation was kept over the nilability. These are optional **request** fields, so a caller omits them rather than sending `null`, and the constraints (`top_logprobs` 0–20, `temperature` 0–2, `top_p` 0–1) carry real value.

8. **Renamed schemas to Ballerina-friendly type names**:

   - **Changed Schemas**: Only the inline schemas whose generated Ballerina type name was not a valid UpperCamelCase identifier (anonymous inline records the tool already emitted without a name were left unchanged).
   - **Original**: Inline object schemas the tool named with underscores (`ChatCompletionMessageToolCall_function`, `CompletionUsage_completion_tokens_details`, ...), from a `title` containing spaces (`JSON schema`, `Custom tool properties`), or from an inline request body (`completions_completion_id_body`).
   - **Updated**:
      - Extracted the underscore-named inline objects into components with UpperCamelCase names (`ChatCompletionMessageToolCall_function` → `ChatCompletionMessageToolCallFunction`, `completions_completion_id_body` → `CompletionsCompletionIdBody`) and updated every `$ref`.
      - Replaced the space-bearing `title` values on the relevant inline schemas with UpperCamelCase (`JSON schema` → `JSONSchema`, `Custom tool properties` → `CustomToolProperties`).
      - Preserved the tool's structural de-duplication (e.g. the assistant message's `function_call` continues to share the `ChatCompletionResponseMessageFunctionCall` type).
   - **Reason**: Ballerina type names must be valid UpperCamelCase identifiers. Underscores, spaces, and lowercase starts force backslash-escaped or non-idiomatic type names, which hurts the connector's usability.

9. **Made `content` and `refusal` nilable in the `logprobs` object of `CreateChatCompletionResponse` choices**:

   - **Changed Schemas**: `CreateChatCompletionResponse` (inline `choices` item schema, `logprobs` object)
   - **Original**: The inner `content` and `refusal` array fields used `nullable: true`, and the `logprobs` object itself also had `nullable: true`
   - **Updated**: Converted `content` and `refusal` to the OpenAPI 3.1 type-array style (`type: [array, 'null']`) and removed `nullable: true` from the `logprobs` object itself
   - **Reason**: The OpenAI API returns `null` for `content` and `refusal` inside a non-null `logprobs` object. Since this specification is OpenAPI 3.1, the Ballerina OpenAPI tool ignores the 3.0-only `nullable: true` keyword, so the type-array style is required to generate nilable fields (`ChatCompletionTokenLogprob[]?`). The `logprobs` object itself is kept non-nilable and optional (`logprobs?`) for usability.

10. **Known limits of the nullability conversion in sanitation #1**:

   Two `nullable: true` markers remain in the specification, and a few conversions have no effect on the generated code. Both are tool limitations rather than oversights:

   - **`CreateChatCompletionStreamResponse.usage`** (a `$ref` with a sibling `nullable`) and **`CreateModelResponseProperties.prediction`** (a single-branch `oneOf` over a `$ref`) are left as `nullable: true`. The only way to express these is `oneOf: [{$ref: ...}, {type: 'null'}]`, which the tool generates as `anydata` — losing `CompletionUsage` and `PredictionContent` entirely. Keeping the ignored marker is preferable to degrading the type.
   - **Inline `object` schemas that declare `properties`** (`web_search_options.user_location`, the request `audio` object, the streaming `logprobs` object) were converted to `type: [object, 'null']` for spec correctness, but the tool does not propagate the null into an inline record type, so the generated fields stay non-nilable. All are optional, and all but the streaming one are request-side. The same schema referenced through a `$ref` *does* generate correctly, which is why the `ChatCompletionStreamOptions` and audio component schemas convert as expected.

## OpenAPI cli command

The following command was used to generate the Ballerina client from the OpenAPI specification. The command should be executed from the repository root directory.

```bash
bal openapi -i docs/spec/openapi.yaml --mode client --tags Chat --license docs/license.txt -o ballerina
```
