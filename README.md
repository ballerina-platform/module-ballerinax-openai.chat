# Ballerina OpenAI Chat connector

[![Build](https://github.com/ballerina-platform/module-ballerinax-openai.chat/actions/workflows/ci.yml/badge.svg)](https://github.com/ballerina-platform/module-ballerinax-openai.chat/actions/workflows/ci.yml)
[![GitHub Last Commit](https://img.shields.io/github/last-commit/ballerina-platform/module-ballerinax-openai.chat.svg)](https://github.com/ballerina-platform/module-ballerinax-openai.chat/commits/master)
[![GitHub Issues](https://img.shields.io/github/issues/ballerina-platform/ballerina-library/module/openai.chat.svg?label=Open%20Issues)](https://github.com/ballerina-platform/ballerina-library/labels/module%openai.chat)

## Overview

[OpenAI](https://openai.com/), an AI research organization focused on creating friendly AI for humanity, offers the [OpenAI API](https://platform.openai.com/docs/api-reference/introduction) to access its powerful AI models for tasks like natural language processing and image generation.

The `ballarinax/openai.chat` package offers functionality to connect and interact with [chat completion related endpoints of OpenAI REST API v1](https://platform.openai.com/docs/api-reference/chat) Enabling seamless interaction with the advanced GPT-4 models developed by OpenAI for diverse conversational and text generation tasks.

## Setup guide

To use the OpenAI Connector, you must have access to the OpenAI API through a [OpenAI Platform account](https://platform.openai.com) and a project under it. If you do not have a OpenAI Platform account, you can sign up for one [here](https://platform.openai.com/signup).

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

final chat:Client openAIChat = check new({
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
    chat:CreateChatCompletionRequest request = {
        model: "gpt-4o-mini",
        messages: [{
            "role": "user",
            "content": "What is Ballerina programming language?"
            }]
    };

    chat:CreateChatCompletionResponse response = check openAIChat->/chat/completions.post(request);
}
```

### Step 4: Run the Ballerina application

```bash
bal run
```

## Examples

The `OpenAI Chat` connector provides practical examples illustrating usage in various scenarios. Explore these [examples](https://github.com/module-ballerinax-openai.chat/tree/main/examples/), covering the following use cases:

1. [CLI assistant](https://github.com/ballerina-platform/module-ballerinax-openai.chat/tree/main/examples/cli-assistant) - Execute the user's task description by generating and running the appropriate command in the command line interface of their selected operating system.
2. [Image to markdown document converter](https://github.com/ballerina-platform/module-ballerinax-openai.chat/tree/main/examples/image-to-markdown-converter) - Generate detailed markdown documentation based on the image content.

## Build from the source

### Setting up the prerequisites

1. Download and install Java SE Development Kit (JDK) version 17. You can download it from either of the following sources:

    * [Oracle JDK](https://www.oracle.com/java/technologies/downloads/)
    * [OpenJDK](https://adoptium.net/)

   > **Note:** After installation, remember to set the `JAVA_HOME` environment variable to the directory where JDK was installed.

2. Download and install [Ballerina Swan Lake](https://ballerina.io/).

3. Download and install [Docker](https://www.docker.com/get-started).

   > **Note**: Ensure that the Docker daemon is running before executing any tests.

4. Export Github Personal access token with read package permissions as follows,

    ```bash
    export packageUser=<Username>
    export packagePAT=<Personal access token>
    ```

### Build options

Execute the commands below to build from the source.

1. To build the package:

   ```bash
   ./gradlew clean build
   ```

2. To run the tests:

   ```bash
   ./gradlew clean test
   ```

3. To build the without the tests:

   ```bash
   ./gradlew clean build -x test
   ```

4. To run tests against different environments:

   ```bash
   ./gradlew clean test -Pgroups=<Comma separated groups/test cases>
   ```

5. To debug the package with a remote debugger:

   ```bash
   ./gradlew clean build -Pdebug=<port>
   ```

6. To debug with the Ballerina language:

   ```bash
   ./gradlew clean build -PbalJavaDebug=<port>
   ```

7. Publish the generated artifacts to the local Ballerina Central repository:

    ```bash
    ./gradlew clean build -PpublishToLocalCentral=true
    ```

8. Publish the generated artifacts to the Ballerina Central repository:

   ```bash
   ./gradlew clean build -PpublishToCentral=true
   ```

## Contribute to Ballerina

As an open-source project, Ballerina welcomes contributions from the community.

For more information, go to the [contribution guidelines](https://github.com/ballerina-platform/ballerina-lang/blob/master/CONTRIBUTING.md).

## Code of conduct

All the contributors are encouraged to read the [Ballerina Code of Conduct](https://ballerina.io/code-of-conduct).

## Useful links

* For more information go to the [`openai.chat` package](https://central.ballerina.io/ballerinax/openai.chat/latest).
* For example demonstrations of the usage, go to [Ballerina By Examples](https://ballerina.io/learn/by-example/).
* Chat live with us via our [Discord server](https://discord.gg/ballerinalang).
* Post all technical questions on Stack Overflow with the [#ballerina](https://stackoverflow.com/questions/tagged/ballerina) tag.

### Using AI Badgr (OpenAI-Compatible Backend)

If you're already using the OpenAI API, you can also point your client at **AI Badgr**, which implements the same API surface (chat completions, streaming, JSON mode).

AI Badgr uses optimized open-source models to provide more affordable inference and also supports optional private/self-hosted modes for teams that need additional data control.

```bash
export OPENAI_API_KEY=YOUR_API_KEY
export OPENAI_BASE_URL=https://aibadgr.com/api/v1
```

**Python:**
```python
from openai import OpenAI
client = OpenAI(api_key="YOUR_API_KEY", base_url="https://aibadgr.com/api/v1")
response = client.chat.completions.create(model="gpt-3.5-turbo", messages=[{"role":"user","content":"Hello!"}], max_tokens=200)
print(response.choices[0].message.content)
```

**JavaScript:**
```javascript
import OpenAI from 'openai';
const client = new OpenAI({ apiKey: 'YOUR_API_KEY', baseURL: 'https://aibadgr.com/api/v1' });
const response = await client.chat.completions.create({ model: 'gpt-3.5-turbo', messages: [{ role: 'user', content: 'Hello!' }], max_tokens: 200 });
console.log(response.choices[0].message.content);
```


**cURL:**
```bash
curl https://aibadgr.com/api/v1/chat/completions \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"model":"gpt-3.5-turbo","messages":[{"role":"user","content":"Hello!"}],"max_tokens":200}'
```

**Notes:**
- Streaming: `"stream": true`
- JSON mode: `"response_format": {"type": "json_object"}`
- Because AI Badgr follows the OpenAI API spec, most existing OpenAI client code works by only changing the `base_url`.
