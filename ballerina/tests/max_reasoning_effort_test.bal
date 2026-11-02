// Copyright (c) 2026 WSO2 LLC (http://www.wso2.com).
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
// KIND, either express or implied. See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/test;

@test:Config {
    groups: ["mock_tests", "max_reasoning"]
}
isolated function testChatCompletionWithMaxReasoningEffort() returns error? {
    CreateChatCompletionRequest request = {
        model: "gpt-6-astra",
        messages: [{role: "user", content: "What is 2 + 2?"}],
        reasoning_effort: "max"
    };
    CreateChatCompletionResponse response = check openAIChat->/chat/completions.post(request);
    test:assertTrue(response.choices.length() > 0);

    map<json> body = check getLastRequestBody().ensureType();
    test:assertEquals(body["model"], "gpt-6-astra");
    test:assertEquals(body["reasoning_effort"], "max", "Maximum reasoning effort must reach the HTTP request");
}
