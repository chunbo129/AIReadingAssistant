# AI Reading Assistant KOReader Plugin
# KOReader AI 阅读助手插件

This plugin allows you to integrate various LLM services (OpenAI, Google Gemini, etc.) with KOReader.

本插件可让您将各种 LLM 服务（OpenAI、Google Gemini 、豆包、DeepSeek、千问等）与 KOReader 集成。

## Features
## 功能

- Three predefined system prompts for quick access
- Custom prompt input for flexible interactions
- Save AI responses directly as notes for highlighted text
- Configure custom system prompts for different contexts
- Support for multiple LLM providers (OpenAI, Google Gemini)
- Translate highlighted text to a specified language (if enabled in configuration)

- 三个预定义系统提示，方便快速访问
- 自定义提示输入，实现灵活交互
- 将 AI 回复直接保存为高亮文本的笔记
- 为不同情境配置自定义系统提示
- 支持多个 LLM 提供商（OpenAI、Google Gemini）
- 将高亮文本翻译成指定语言（如果在配置中启用）

## Installation
## 安装

1. Make sure you have KOReader installed on your device.
2. Clone/Download this repo, upzip it and rename the folder "AIReadingAssistant.koplugin".
3. Copy the `AIReadingAssistant.koplugin` folder to your KOReader plugins directory (`koreader/plugins/`).
4. Restart KOReader.
5. Configuration setup: use your favorite text editor to open the configuration.lua file and configure:
   - API endpoint (OpenAI or Gemini)
   - API key
   - Model name
   - Custom prompts (prompt1, prompt2, prompt3)

1. 确保您的设备上已安装 KOReader。
2. 克隆/下载此仓库，解压缩并将其重命名为“AIReadingAssistant.koplugin”。
3. 将 `AIReadingAssistant.koplugin` 文件夹复制到您的 KOReader 插件目录 (`koreader/plugins/`)。
4. 重新启动 KOReader。
5. 配置设置：使用您喜欢的文本编辑器打开 `configuration.lua` 文件并配置：
   - API 端点（OpenAI 或 Gemini）
   - API 密钥
   - 模型名称
   - 自定义提示（prompt1、prompt2、prompt3）

### Configuration Examples
### 配置示例

For OpenAI (ChatGPT):
```lua
api_endpoint = "https://api.openai.com/v1/chat/completions"
model = "gpt-3.5-turbo"
```

For Google (Gemini):
```lua
api_endpoint = "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent"
model = "gemini-pro"
```

For VolcEngine (火山引擎):
```lua
api_endpoint = "https://ark.cn-beijing.volces.com/api/v3/chat/completions"
model = "Doubao-pro-32k"
```

For DeepSeek:
```lua
api_endpoint = "https://api.deepseek.com/chat/completions"
model = "deepseek-chat"
```

For Alibaba Cloud (通义千问):
```lua
api_endpoint = "https://dashscope.aliyuncs.com/api/v1/services/aigc/text-generation/generation"
model = "qwen-turbo"
```
**Note:** Alibaba Cloud's Qwen API has a unique request and response format. The current version of this plugin may not support it without code modifications to `ai_query.lua`.
**注意：** 阿里云通义千问的 API 具有独特的请求和响应格式。当前版本的插件可能需要修改 `ai_query.lua` 文件才能支持。

## Usage
## 使用方法

1. Highlight text in a document.
2. Tap the "..." icon in the selection toolbar.
3. Choose from these options:
   - **Prompt 1**: Use your first predefined prompt (e.g., "translate to Spanish")
   - **Prompt 2**: Use your second predefined prompt (e.g., "translate to Chinese")
   - **Prompt 3**: Use your third predefined prompt (e.g., "explain in detail")
   - **Ask AI**: Open a dialog to enter your own custom prompt

1. 在文档中高亮显示文本。
2. 点击选择工具栏中的“...”图标。
3. 从以下选项中选择：
   - **提示 1**：使用您的第一个预定义提示（例如，“翻译成西班牙语”）
   - **提示 2**：使用您的第二个预定义提示（例如，“翻译成中文”）
   - **提示 3**：使用您的第三个预定义提示（例如，“详细解释”）
   - **询问 AI**：打开一个对话框，输入您自己的自定义提示

### Using Predefined Prompts (1, 2, 3)
### 使用预定义提示 (1, 2, 3)

- Simply tap the prompt button and the AI will process your highlighted text according to the predefined instruction in configuration.lua
- The response will appear in a viewer where you can:
  - Read the full conversation
  - Save the response as a note for the highlighted text
  - Ask follow-up questions

- 只需点击提示按钮，AI 将根据 `configuration.lua` 中的预定义指令处理您高亮显示的文本
- 回复将出现在一个查看器中，您可以在其中：
  - 阅读完整的对话
  - 将回复保存为高亮文本的笔记
  - 提出后续问题

### Using Custom Prompts (Ask AI)
### 使用自定义提示 (询问 AI)

1. Tap "Ask AI" in the menu
2. Type your custom prompt/question about the highlighted text
3. Tap "Ask" to get the response
4. The response will show in a viewer where you can:
   - Read the full conversation history
   - Save the response as a note for the highlighted text
   - Ask follow-up questions

1. 在菜单中点击“询问 AI”
2. 输入您关于高亮文本的自定义提示/问题
3. 点击“询问”以获取回复
4. 回复将显示在一个查看器中，您可以在其中：
   - 阅读完整的对话历史
   - 将回复保存为高亮文本的笔记
   - 提出后续问题

### Saving Responses as Notes
### 将回复保存为笔记

- When viewing an AI response, tap "Save as note" to save it as a note for the highlighted text
- The note will be automatically saved and the viewer will close
- You can view saved notes using KOReader's standard note viewing features

- 在查看 AI 回复时，点击“保存为笔记”以将其保存为高亮文本的笔记
- 笔记将自动保存，查看器将关闭
- 您可以使用 KOReader 的标准笔记查看功能查看已保存的笔记

### Tips
### 提示

- You can maintain a conversation thread with follow-up questions
- The AI considers the document's context (title and author) when responding
- Error messages will help you identify any configuration or connection issues
- Notes are saved directly to the document, making them easily accessible for future reference

- 您可以通过后续问题来维持一个对话线程
- AI 在回复时会考虑文档的上下文（标题和作者）
- 错误消息将帮助您识别任何配置或连接问题
- 笔记直接保存到文档中，方便将来参考

## License
## 许可证

This plugin is released under the MIT License. See the `LICENSE` file for more information.

本插件根据 MIT 许可证发布。有关更多信息，请参阅 `LICENSE` 文件。
