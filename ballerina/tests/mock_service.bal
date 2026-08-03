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

import ballerina/http;
import ballerina/log;

listener http:Listener httpListener = new (9090);

http:Service mockService = service object {
    resource function post chat/completions(@http:Payload CreateChatCompletionRequest payload) returns CreateChatCompletionResponse|http:BadRequest {

        // Validate the request payload
        if payload.messages.length() == 0 || payload.model.toString() is "" {
            return http:BAD_REQUEST;
        }

        // Check if the request forces a custom tool
        if payload.tools != () && payload.tool_choice is ChatCompletionNamedToolChoiceCustom {
            CreateChatCompletionResponse customToolResponse = {
                id: "chatcmpl-custom-tool-00000",
                choices: [
                    {
                        finish_reason: "tool_calls",
                        index: 0,
                        message: {
                            "content": null,
                            "role": "assistant",
                            "refusal": null,
                            "tool_calls": [
                                {
                                    "id": "call_custom_00000",
                                    "type": "custom",
                                    "custom": {
                                        "name": "code_exec",
                                        "input": "for i in range(1, 6):\n    print(i)"
                                    }
                                }
                            ]
                        },
                        logprobs: null
                    }
                ],
                created: 1723091495,
                model: "gpt-5-mini-2025-08-07",
                "object": "chat.completion",
                "usage": {
                    "completion_tokens": 32,
                    "prompt_tokens": 45,
                    "total_tokens": 77,
                    "completion_tokens_details": {"reasoning_tokens": 8}
                }
            };
            return customToolResponse;
        }

        // Check if the request includes tools
        if payload.tools != () {
            // Return a mock tool call response
            CreateChatCompletionResponse toolResponse = {
                id: "chatcmpl-tool-00000",
                choices: [
                    {
                        finish_reason: "tool_calls",
                        index: 0,
                        message: {
                            "content": null,
                            "role": "assistant",
                            "refusal": null,
                            "tool_calls": [
                                {
                                    "id": "call_00000",
                                    "type": "function",
                                    "function": {
                                        "name": "get_weather",
                                        "arguments": "{\"location\":\"San Francisco\"}"
                                    }
                                }
                            ]
                        },
                        logprobs: null
                    }
                ],
                created: 1723091495,
                model: "gpt-4o-mini-2024-07-18",
                "object": "chat.completion",
                "usage": {"completion_tokens": 20, "prompt_tokens": 50, "total_tokens": 70}
            };
            return toolResponse;
        }

        // Mock response for reasoning models, which report reasoning tokens
        // and echo a `gpt-5` model name.
        string model = payload.model;
        if model.startsWith("gpt-5") {
            CreateChatCompletionResponse reasoningResponse = {
                id: "chatcmpl-reasoning-00000",
                choices: [
                    {
                        finish_reason: "stop",
                        index: 0,
                        message: {"content": "Test message received! How can I assist you today?", "role": "assistant", "refusal": null},
                        logprobs: null
                    }
                ],
                created: 1723091495,
                model: "gpt-5-mini-2025-08-07",
                "object": "chat.completion",
                "usage": {
                    "completion_tokens": 29,
                    "prompt_tokens": 13,
                    "total_tokens": 42,
                    "completion_tokens_details": {"reasoning_tokens": 18}
                }
            };
            return reasoningResponse;
        }

        // Mock response for regular chat completion
        CreateChatCompletionResponse response = {
            id: "chatcmpl-00000",
            choices: [
                {
                    finish_reason: "stop",
                    index: 0,
                    message: {"content": "Test message received! How can I assist you today?", "role": "assistant", "refusal": null},
                    logprobs: null
                }
            ],
            created: 1723091495,
            model: "gpt-4o-mini-2024-07-18",
            "object": "chat.completion",
            "usage": {"completion_tokens": 11, "prompt_tokens": 13, "total_tokens": 24}
        };
        return response;
    }
};

function init() returns error? {
    if isLiveServer {
        log:printInfo("Skiping mock server initialization as the tests are running on live server");
        return;
    }

    log:printInfo("Initiating mock server...");
    check httpListener.attach(mockService, "/");
    check httpListener.'start();
}
