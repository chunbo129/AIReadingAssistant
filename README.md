# AskGPT KOReader 插件

本插件允许您在 KOReader 中集成多种大语言模型（LLM）服务，例如 OpenAI (ChatGPT), Google (Gemini), 火山引擎 (豆包) 等。

---

# AskGPT KOReader Plugin

This plugin allows you to integrate various Large Language Model (LLM) services with KOReader, such as OpenAI (ChatGPT), Google (Gemini), Volcengine (Doubao), etc.

## 功能 | Features

- **多服务商支持**: 支持 OpenAI、Google Gemini、火山引擎以及其他兼容 OpenAI API 的服务。
- **高度自定义**: 提供三个可完全自定义的快捷指令，并可自定义菜单名称。
- **灵活提问**: 支持在选中文字的基础上进行临时的自定义提问。
- **保存为笔记**: 可以将模型的返回结果直接保存为 KOReader 笔记。
- **连续对话**: 支持在当前会话中进行连续追问。

---

- **Multi-Provider Support**: Supports OpenAI, Google Gemini, Volcengine, and other OpenAI API-compatible services.
- **Highly Customizable**: Offers three fully customizable quick prompts with custom menu labels.
- **Flexible Interaction**: Allows for custom questions based on highlighted text.
- **Save as Note**: AI responses can be saved directly as KOReader notes.
- **Conversational Context**: Supports follow-up questions within the same session.

## 安装 | Installation

1.  下载本项目。
2.  将文件夹解压并重命名为 `askgpt.koplugin`。
3.  将 `askgpt.koplugin` 文件夹复制到 KOReader 的插件目录 (`koreader/plugins/`)。
4.  重启 KOReader。

---

1.  Download this project.
2.  Unzip and rename the folder to `askgpt.koplugin`.
3.  Copy the `askgpt.koplugin` folder to your KOReader plugins directory (`koreader/plugins/`).
4.  Restart KOReader.

## 配置 | Configuration

插件需要配置后才能使用。请按照以下步骤操作：

1.  在 `askgpt.koplugin` 文件夹中，将 `configuration.lua.sample` 文件复制并重命名为 `configuration.lua`。
2.  使用文本编辑器打开 `configuration.lua` 文件并填入您的配置。

---

The plugin requires configuration before use. Please follow these steps:

1.  Inside the `askgpt.koplugin` folder, copy and rename `configuration.lua.sample` to `configuration.lua`.
2.  Open `configuration.lua` with a text editor and fill in your configuration details.

### 配置文件详解 | Configuration Details

- `api_key`: **必需**。您的 API 密钥。
- `model`: **必需**。您想使用的模型名称。
- `api_endpoint`: **必需**。服务商提供的 API 地址。
- `prompt1`, `prompt2`, `prompt3`: **必需**。三个快捷指令的系统提示词 (System Prompt)。
- `menu_text1`, `menu_text2`, `menu_text3`: **必需**。三个快捷指令在菜单中显示的名称。

---

- `api_key`: **Required**. Your API key.
- `model`: **Required**. The name of the model you want to use.
- `api_endpoint`: **Required**. The API endpoint URL provided by the service.
- `prompt1`, `prompt2`, `prompt3`: **Required**. The system prompts for the three quick actions.
- `menu_text1`, `menu_text2`, `menu_text3`: **Required**. The names for the three quick actions that appear in the menu.

### 配置示例 | Configuration Examples

#### OpenAI

```lua
CONFIGURATION = {
  api_key = "sk-...", -- 你的 OpenAI API Key
  model = "gpt-4o-mini",
  api_endpoint = "https://api.openai.com/v1/chat/completions",
  
  prompt1 = "请将选中的英文翻译成流畅、优美的中文。",
  menu_text1 = "翻译",
  -- ... 其他 prompt 配置
}
```

#### Google Gemini

**注意**: Gemini 的 `api_endpoint` 地址以 `:generateContent` 结尾。

```lua
CONFIGURATION = {
  api_key = "AIza...", -- 你的 Gemini API Key
  model = "gemini-1.5-flash-latest", -- 此处的模型名称仅供参考，不会被发送
  api_endpoint = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent",
  
  prompt1 = "请用通俗易懂的语言解释选中的概念。",
  menu_text1 = "解释概念",
  -- ... 其他 prompt 配置
}
```

#### 火山引擎 (豆包) | Volcengine (Doubao)

火山引擎的 API 与 OpenAI 兼容。

```lua
CONFIGURATION = {
  api_key = "your_volcengine_api_key", -- 你的火山引擎 API Key
  model = "doubao-pro-4k",
  api_endpoint = "https://ark.cn-beijing.volces.com/api/v3/chat/completions",
  
  prompt1 = "你是一名资深学者，请解读选中的文本，输出限制在200字以内。",
  menu_text1 = "文本解读",
  -- ... 其他 prompt 配置
}
```

## 使用 | Usage

1.  在文档中长按选中一段文字。
2.  在弹出的菜单中，选择您在配置文件中设置的快捷指令 (例如 "翻译", "文本解读" 等)，或选择 **"Ask AI"** 进行自定义提问。
3.  模型返回的结果将显示在新的窗口中。您可以阅读、追问，或点击 **"Save as note"** 将其保存为笔记。

---

1.  Long-press to highlight text in a document.
2.  In the popup menu, select one of your configured quick prompts (e.g., "Translate," "Explain Concept") or choose **"Ask AI"** for a custom question.
3.  The response will appear in a new window. You can read it, ask follow-up questions, or tap **"Save as note"** to save it.

## 许可 | License

[MIT License](LICENSE)