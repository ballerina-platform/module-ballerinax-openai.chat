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
        // Mock response
        CreateChatCompletionResponse response = {
            id: "chatcmpl-00000",
            choices: [
                {
                    finishReason: "stop",
                    index: 0,
                    message: {
                        content: "Test message received! How can I assist you today?",
                        role: "assistant",
                        refusal: ()
                    },
                    logprobs: ()
                }
            ],
            created: 1723091495,
            model: "gpt-4o-mini-2024-07-18",
            systemFingerprint: "fp_48196bc67a",
            'object: "chat.completion",
            usage: {
                completionTokens: 11,
                promptTokens: 13,
                totalTokens: 24
            }
        };
        return response;
    }
};

function init() returns error? {
    if isLiveServer {
        log:printInfo("Skipping mock server initialization as the tests are running on live server");
        return;
    }

    log:printInfo("Initiating mock server...");
    check httpListener.attach(mockService, "/");
    check httpListener.'start();
}
