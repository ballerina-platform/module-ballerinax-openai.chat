## Overview

The `openai.chat` module is a direct, fully-typed REST connector for OpenAI's [Chat Completions API](https://platform.openai.com/docs/api-reference/chat) (`POST /chat/completions`). Use it as a standalone client to send chat prompts to GPT models (GPT-4o, GPT-4, GPT-3.5) and receive completions with full control over request parameters such as tools, temperature, and structured response formats — independent of the `ballerina/ai` agent framework.


### Key Features

- Generate chat completions using GPT models
- Support for multi-turn conversations with message history
- Function calling and tool use capabilities
- Configurable model parameters and response formats

## Setup guide

To use the OpenAI Connector, you must have access to the OpenAI API through an [OpenAI Platform account](https://platform.openai.com) and a project under it. If you do not have a OpenAI Platform account, you can sign up for one [here](https://platform.openai.com/signup).

#### Create a OpenAI API Key

1. Open the [OpenAI Platform Dashboard](https://platform.openai.com).

2. Navigate to Dashboard -> API keys.
<img src=https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-openai.chat/main/docs/setup/resources/navigate-api-key-dashboard.png alt="OpenAI Platform" style="width: 70%;">

3. Click on the "Create new secret key" button.
<img src=https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-openai.chat/main/docs/setup/resources/api-key-dashboard.png alt="OpenAI Platform" style="width: 70%;">

4. Fill the details and click on Create secret key.
<img src=https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-openai.chat/main/docs/setup/resources/create-new-secret-key.png alt="OpenAI Platform" style="width: 70%;">

5. Store the API key securely to use in your application.
<img src=https://raw.githubusercontent.com/ballerina-platform/module-ballerinax-openai.chat/main/docs/setup/resources/saved-key.png alt="OpenAI Platform" style="width: 70%;">

## Quickstart

To use the `OpenAI Chat` connector in your Ballerina application, update the `.bal` file as follows:

### Step 1: Import the module

Import the `ballerinax/openai.chat` module.

```ballerina
import ballerinax/openai.chat;
```

### Step 2: Create a new connector instance

Create a `chat:Client` with the obtained API Key and initialize the connector.

```ballerina
configurable string token = ?;

final chat:Client openAIChat = check new ({
    auth: {
        token
    }
});
```

### Step 3: Invoke the connector operation

Now, you can utilize the available connector operation.

#### Create a chat completion

```ballerina
public function main() returns error? {
    chat:CreateChatCompletionRequest request = {
        model: "gpt-4o-mini",
        messages: [
            {
                "role": "user",
                "content": "What is Ballerina programming language?"
            }
        ]
    };

    chat:CreateChatCompletionResponse response =
        check openAIChat->/chat/completions.post(request);
}
```

#### Create a chat completion with a GPT-5 or other reasoning model

GPT-5 and the o-series models do not accept the deprecated `max_tokens` field. Use `max_completion_tokens` instead, which bounds the reasoning tokens and the visible completion tokens together. These models additionally accept `reasoning_effort` and `verbosity`, and they take instructions through a `developer` message rather than a `system` message.

```ballerina
public function main() returns error? {
    chat:CreateChatCompletionRequest request = {
        model: "gpt-5-mini",
        messages: [
            {
                "role": "developer",
                "content": "You are a helpful assistant."
            },
            {
                "role": "user",
                "content": "What is Ballerina programming language?"
            }
        ],
        max_completion_tokens: 2048,
        reasoning_effort: "low",
        verbosity: "low"
    };

    chat:CreateChatCompletionResponse response =
        check openAIChat->/chat/completions.post(request);
}
```

> **Note:** Reasoning tokens are billed as completion tokens and are reported separately in `response.usage.completion_tokens_details.reasoning_tokens`. Setting `max_completion_tokens` too low can exhaust the budget on reasoning alone, returning an empty message with `finish_reason` set to `"length"`.

### Step 4: Run the Ballerina application

```bash
bal run
```

## Examples

The `OpenAI Chat` connector provides practical examples illustrating usage in various scenarios. Explore these [examples](https://github.com/module-ballerinax-openai.chat/tree/main/examples/), covering the following use cases:

1. [CLI assistant](https://github.com/ballerina-platform/module-ballerinax-openai.chat/tree/main/examples/cli-assistant) - Execute the user's task description by generating and running the appropriate command in the command line interface of their selected operating system.
2. [Image to markdown document converter](https://github.com/ballerina-platform/module-ballerinax-openai.chat/tree/main/examples/image-to-markdown-converter) - Generate detailed markdown documentation based on the image content.
