// Copyright (c) 2024, WSO2 LLC. (http://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/data.jsondata;
import ballerina/os;
import ballerina/test;

configurable boolean isLiveServer = os:getEnv("IS_LIVE_SERVER") == "true";
configurable string token = isLiveServer ? os:getEnv("OPENAI_TOKEN") : "test";
final string mockServiceUrl = "http://localhost:9090";
final Client openAIChat = check initClient();

function initClient() returns Client|error {
    if isLiveServer {
        return new ({auth: {token}});
    }
    return new ({auth: {token}}, mockServiceUrl);
}

@test:Config {
    groups: ["live_tests", "mock_tests"]
}
isolated function testChatCompletion() returns error? {
    CreateChatCompletionRequest request = {
        model: "gpt-4o-mini",
        messages: [
            {"role": "user", "content": "This is a test message"}
        ]
    };
    CreateChatCompletionResponse response = check openAIChat->/chat/completions.post(request);
    test:assertTrue(response.choices.length() > 0, msg = "Expected at least one completion choice");
    test:assertEquals(response.choices[0].finish_reason, "stop", msg = "Expected finish reason to be 'stop'");
    anydata content = response.choices[0].message?.content;
    test:assertTrue(content !is (), msg = "Expected content in the completion response");
}

@test:Config {
    groups: ["live_tests", "mock_tests"]
}
isolated function testChatCompletionWithSystemMessage() returns error? {
    CreateChatCompletionRequest request = {
        model: "gpt-4o-mini",
        messages: [
            {"role": "system", "content": "You are a helpful assistant."},
            {"role": "user", "content": "This is a test message"}
        ]
    };
    CreateChatCompletionResponse response = check openAIChat->/chat/completions.post(request);
    test:assertTrue(response.choices.length() > 0, msg = "Expected at least one completion choice");
    anydata content = response.choices[0].message?.content;
    test:assertTrue(content !is (), msg = "Expected content in the completion response");
}

@test:Config {
    groups: ["live_tests", "mock_tests"]
}
isolated function testChatCompletionWithToolCall() returns error? {
    CreateChatCompletionRequest request = {
        model: "gpt-4o-mini",
        messages: [
            {"role": "user", "content": "What is the weather in San Francisco?"}
        ],
        tools: [
            {
                'type: "function",
                'function: {
                    name: "get_weather",
                    description: "Get the current weather in a given location",
                    parameters: {}
                }
            }
        ],
        // Force the tool call, otherwise the live API is free to answer in prose
        // and the `finish_reason` assertion below becomes nondeterministic.
        tool_choice: {'type: "function", 'function: {name: "get_weather"}}
    };
    CreateChatCompletionResponse response = check openAIChat->/chat/completions.post(request);
    test:assertTrue(response.choices.length() > 0, msg = "Expected at least one completion choice");
    test:assertEquals(response.choices[0].finish_reason, "tool_calls", msg = "Expected finish reason to be 'tool_calls'");
    ChatCompletionMessageToolCalls? toolCalls = response.choices[0].message.tool_calls;
    test:assertTrue(toolCalls !is (), msg = "Expected tool calls in the response");
}

@test:Config {
    groups: ["live_tests", "mock_tests"]
}
isolated function testChatCompletionResponseFields() returns error? {
    CreateChatCompletionRequest request = {
        model: "gpt-4o-mini",
        messages: [
            {"role": "user", "content": "This is a test message"}
        ]
    };
    CreateChatCompletionResponse response = check openAIChat->/chat/completions.post(request);
    test:assertTrue(response.id.length() > 0, msg = "Expected a non-empty response ID");
    test:assertTrue(response.created > 0, msg = "Expected a valid created timestamp");
    test:assertTrue(response.model.length() > 0, msg = "Expected a non-empty model name");
    test:assertEquals(response.'object, "chat.completion", msg = "Expected object type to be 'chat.completion'");
    test:assertTrue(response.usage !is (), msg = "Expected usage information in response");
}

@test:Config {
    groups: ["live_tests", "mock_tests"]
}
isolated function testChatCompletionWithReasoningModel() returns error? {
    CreateChatCompletionRequest request = {
        model: "gpt-5-mini",
        messages: [
            {"role": "user", "content": "This is a test message"}
        ],
        // Reasoning models reject `max_tokens`; `max_completion_tokens` covers
        // both the reasoning tokens and the visible completion tokens.
        max_completion_tokens: 2048,
        reasoning_effort: "low",
        verbosity: "low"
    };
    CreateChatCompletionResponse response = check openAIChat->/chat/completions.post(request);
    test:assertTrue(response.choices.length() > 0, msg = "Expected at least one completion choice");
    test:assertTrue(response.model.startsWith("gpt-5"), msg = "Expected the response to come from a GPT-5 model");
    string? content = response.choices[0].message?.content;
    test:assertTrue(content !is (), msg = "Expected content in the completion response");

    CompletionUsage? usage = response.usage;
    test:assertTrue(usage !is (), msg = "Expected usage information in response");
    if usage is CompletionUsage {
        CompletionUsageCompletionTokensDetails? details = usage.completion_tokens_details;
        test:assertTrue(details !is (), msg = "Expected completion token details for a reasoning model");
    }
}

@test:Config {
    groups: ["live_tests", "mock_tests"]
}
isolated function testChatCompletionWithDeveloperMessage() returns error? {
    CreateChatCompletionRequest request = {
        model: "gpt-5-mini",
        messages: [
            // `developer` replaces `system` for o-series and GPT-5 models.
            {"role": "developer", "content": "You are a helpful assistant."},
            {"role": "user", "content": "This is a test message"}
        ],
        max_completion_tokens: 2048,
        reasoning_effort: "low"
    };
    CreateChatCompletionResponse response = check openAIChat->/chat/completions.post(request);
    test:assertTrue(response.choices.length() > 0, msg = "Expected at least one completion choice");
    string? content = response.choices[0].message?.content;
    test:assertTrue(content !is (), msg = "Expected content in the completion response");
}

@test:Config {
    groups: ["live_tests", "mock_tests"]
}
isolated function testChatCompletionWithCustomToolCall() returns error? {
    CreateChatCompletionRequest request = {
        model: "gpt-5-mini",
        messages: [
            {"role": "user", "content": "Print the numbers from 1 to 5."}
        ],
        tools: [
            {
                'type: "custom",
                custom: {
                    name: "code_exec",
                    description: "Execute arbitrary Python code"
                }
            }
        ],
        tool_choice: {'type: "custom", custom: {name: "code_exec"}}
    };
    CreateChatCompletionResponse response = check openAIChat->/chat/completions.post(request);
    test:assertTrue(response.choices.length() > 0, msg = "Expected at least one completion choice");

    ChatCompletionMessageToolCalls? toolCalls = response.choices[0].message.tool_calls;
    test:assertTrue(toolCalls !is (), msg = "Expected tool calls in the response");
    if toolCalls is ChatCompletionMessageToolCalls {
        test:assertTrue(toolCalls.length() > 0, msg = "Expected at least one tool call");
        // A tool call is now a union: narrow before accessing `custom`/`'function`.
        ChatCompletionMessageToolCall|ChatCompletionMessageCustomToolCall toolCall = toolCalls[0];
        test:assertTrue(toolCall is ChatCompletionMessageCustomToolCall,
                msg = "Expected a custom tool call when `tool_choice` forces a custom tool");
        if toolCall is ChatCompletionMessageCustomToolCall {
            test:assertEquals(toolCall.custom.name, "code_exec", msg = "Expected the forced custom tool to be called");
        }
    }
}

// Guards the sanitation that removed `default:` from the request-body sampling
// parameters. A parameter the caller never set must not appear in the serialised
// body: the reasoning models (o-series, gpt-5 family) reject the *presence* of
// these keys, so a defaulted-but-always-present field made those models
// uncallable. `jsondata:toJson` is the exact serialiser used by `client.bal`.
@test:Config {
    groups: ["mock_tests"]
}
isolated function testUnsetRequestParametersAreNotSerialized() returns error? {
    CreateChatCompletionRequest request = {
        model: "o3-mini",
        messages: [{"role": "user", "content": "This is a test message"}]
    };

    map<json> body = check jsondata:toJson(request).ensureType();
    foreach string paramName in ["temperature", "top_p", "frequency_penalty", "presence_penalty", "n", "logprobs", "store", "stream"] {
        test:assertFalse(body.hasKey(paramName),
                msg = string `Expected '${paramName}' to be omitted when the caller does not set it`);
    }

    // An explicitly set parameter must still be serialised.
    request.temperature = 0.2;
    map<json> bodyWithTemperature = check jsondata:toJson(request).ensureType();
    test:assertEquals(bodyWithTemperature["temperature"], 0.2d,
            msg = "Expected an explicitly set temperature to be sent");
}
