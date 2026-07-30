_Authors_: @ballerina-platform \
_Created_: 2024/08/05 \
_Updated_: 2026/07/31 \
_Edition_: Swan Lake

# Sanitation for OpenAPI specification

This document records the sanitation done on top of the official OpenAPI specification from OpenAI.
The OpenAPI specification is obtained from the [OpenAPI specification for the OpenAI API](https://app.stainless.com/api/spec/documented/openai/openapi.documented.yml).
These changes are done in order to improve the overall usability, and as workarounds for some known language limitations.

1. **Converted nullable type arrays to `nullable: true`**:

   - **Changed Schemas**: Multiple schemas throughout the specification
   - **Original**: `type: ["string", "null"]` (OpenAPI 3.1.x style)
   - **Updated**: `type: string` with `nullable: true`
   - **Reason**: Type arrays are not supported in OpenAPI 3.0.0. The `nullable: true` property is the 3.0.0 equivalent for expressing nullable types.

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
   - **Updated**: `type: string` with `nullable: true`
   - **Reason**: The `anyOf`/`oneOf` with `{"type": "null"}` pattern for expressing nullable types is not supported in OpenAPI 3.0.0. The `nullable: true` property is used instead.

5. **Removed `webhooks` section**:

   - **Reason**: The `webhooks` key is not supported in OpenAPI 3.0.0.

6. **Removed `jsonSchemaDialect`**:

   - **Reason**: The `jsonSchemaDialect` key is not supported in OpenAPI 3.0.0.

7. **Added `nullable: true` to `top_logprobs` in `CreateModelResponseProperties`**:

   - **Changed Schemas**: `CreateModelResponseProperties`
   - **Updated**:
      - `top_logprobs:`
         `// ... other fields omitted for brevity`
         `nullable: true`
   - **Reason**: The `top_logprobs` field is optional and can be absent or explicitly set to null. Marking it as `nullable: true` accurately reflects the field's data model, allowing it to represent either an integer value or the absence of a value.

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

## OpenAPI cli command

The following command was used to generate the Ballerina client from the OpenAPI specification. The command should be executed from the repository root directory.

```bash
bal openapi -i docs/spec/openapi.yaml --mode client --tags Chat --license docs/license.txt -o ballerina
```
