## Overview

[OpenAI](https://openai.com/), an AI research organization dedicated to developing beneficial AI for humanity, provides the [OpenAI API](https://platform.openai.com/docs/api-reference/introduction) for accessing its powerful AI models, enabling tasks such as natural language processing and image generation.

The `ballarinax/openai.chat` package offers functionality to connect and interact with [Chat Completion related endpoints of OpenAI API](https://platform.openai.com/docs/api-reference/chat) Enabling seamless interaction with the advanced GPT-4 models developed by OpenAI for diverse conversational and text generation tasks.

## Setup guide

To use the OpenAI Connector, you must have access to the OpenAI API through a [OpenAI Platform account](https://platform.openai.com) and a project under it. If you do not have a OpenAI Platform account, you can sign up for one [here](https://platform.openai.com/signup).

#### Create a OpenAI API Key

1. Open the [OpenAI Platform Dashboard](https://platform.openai.com).


2. Navigate to **Dashboard** -> **API keys**.
<img src=/docs/setup/resources/navigate-api-key-dashboard.png alt="Navigate to API key section" style="width: 70%;">

3. Click on the **Create new secret key** button.
<img src=/docs/setup/resources/api-key-dashboard.png alt="OpenAI Dashbaord | API keys" style="width: 70%;">

4. Fill the details and click on Create secret key.
<img src=/docs/setup/resources/create-new-secrete-key.png alt="Create New API key" style="width: 70%;">

5. Store the API key securely to use in your application.
<img src=/docs/setup/resources/saved-key.png alt="Generated New API key" style="width: 70%;">

## Quickstart

To use the `OpenAI Chat` connector in your Ballerina application, update the `.bal` file as follows:

### Step 1: Import the module

Import the `ballerinax/openai.chat` module.

```ballerina
import ballerinax/openai.chat;
```

### Step 2: Create a new connector instance

1. Create a `Config.toml` file and configure the API key (obtained in the above steps) as follows:

```bash
token = "<API key>"
```

2. Create and initialize a `chat:Client` connector with it.

```ballerina
chat:Client openAIChat = check new({
    auth: {
        token
    }
});
```

### Step 3: Invoke the connector operation

Now, you can utilize available connector operations.

#### Generate a response for given message

```ballerina

public function main() returns error? {

    // Create a chat completion request.
    CreateChatCompletionRequest request = {

        model: "gpt-4o-mini",
        messages: [{
            "role": "user",
            "content": "What is Ballerina programming language?"
            }]
            
    };

    // Call the API.
    CreateChatCompletionResponse response = check openAIChat->/chat/completions.post(request);
}
```

### Step 4: Run the Ballerina application

```bash
bal run
```


## Examples

The `OpenAI Chat` connector provides practical examples illustrating usage in various scenarios. Explore these [examples](https://github.com/module-ballerinax-openai.chat/tree/main/examples/), covering the following use cases:

[//]: # (TODO: Add examples)