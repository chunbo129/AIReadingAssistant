# 📖 KOReader AI 阅读助手

让 AI 成为你的贴身阅读伙伴！

这款插件能让你在 KOReader 中直接与 AI 助手对话，无论是解释概念、翻译句子，还是扩展知识，都能轻松搞定。

---

## ✨ 主要功能

*   **划词即问** 💬：选中文字，即可向 AI 提问，获取精准解释。
*   **快捷指令** 🚀：预设“单词解析”、“句子翻译”等常用功能，一键调用。
*   **自由对话** ✍️：除了预设指令，你还可以随时输入任何问题，与 AI 自由交流。
*   **保存笔记** 📝：觉得 AI 的回答很棒？一键将它保存为高亮笔记，方便日后回顾。
*   **高度定制** 🔧：你可以自由修改快捷指令的名称和功能，打造最适合你的 AI 助手。
*   **广泛兼容** 🌐：支持接入多种 AI 服务，如 OpenAI (ChatGPT)、Google (Gemini)、火山引擎 (豆包) 等。

---

## 🚀 如何使用

1.  在阅读时，**长按并选中**一段文字。
2.  在弹出的菜单中，点击你需要的 **AI 功能**（如“单词解析”）。
3.  稍等片刻，AI 的回答就会出现在一个新窗口中。
4.  你可以继续**追问**，或者将回答**保存为笔记**。

<img src="https://github.com/chunbo129/AIReadingAssistant/blob/main/Screenshot_org.koreader.launcher.jpg" alt="Screenshot_2025-07-22-14-11-49-904_org.koreader.launcher" style="zoom:50%;" />

---

## 🛠️ 安装与配置

只需三步，即可开启 AI 阅读之旅：

**第一步：下载插件**

*   访问本项目的 [Releases 页面](https://github.com/chunbo129/AIReadingAssistant/releases)。
*   下载最新的 `AIReadingAssistant.koplugin.zip` 压缩包。

**第二步：安装插件**

*   解压下载的 `zip` 文件，你会得到一个名为 `aireadingassistant.koplugin` 的文件夹。
*   将这个文件夹完整地复制到 KOReader 的 `plugins` 目录中。
    *   通常路径为 `koreader/plugins/`。
*   **重启 KOReader**，插件即可生效。

**第三步：配置 AI 服务**

插件需要一个“大脑”才能工作，这个“大脑”就是 AI 服务。你需要告诉插件如何连接到它。

1.  在 `aireadingassistant.koplugin` 文件夹中，找到 `configuration.lua.sample` 文件，并将它**重命名为 `configuration.lua`**。

2.  用任何文本编辑器打开 `configuration.lua` 文件。

3.  **填写三个关键信息**：
    *   `api_key`: 你的 AI 服务密钥。这就像是你的专属密码，需要从 AI 服务提供商的网站获取。
    *   `model`: 你想使用的 AI 模型。不同的模型有不同的能力和价格。
    *   `api_endpoint`: AI 服务的连接地址。

    **不知道怎么填？** 文件里已经为你准备了几个常用 AI 服务的**配置示例**，你可以直接复制粘贴，然后只替换你自己的 `api_key` 即可。

    ```lua
    -- 示例：使用火山引擎的豆包模型
    api_key = "在这里填入你从火山引擎获取的密钥",
    model = "Doubao-pro-32k",
    api_endpoint = "https://ark.cn-beijing.volces.com/api/v3/chat/completions",
    ```

4.  **保存并关闭** `configuration.lua` 文件。现在，你的 AI 助手已经准备就绪了！

---

## 🔧 自定义快捷指令

你可以在 `configuration.lua` 文件中，修改 `prompt1`, `menu_text1` 等字段，来定制你自己的快捷指令。

*   `menu_text1`: 显示在菜单中的名称（例如“帮我总结”）。
*   `prompt1`: 你希望 AI 执行的具体任务（例如“请用一句话总结以下内容”）。

---

## 常见问题

*   **问：我没有 API Key 怎么办？**
    *   答：你需要访问你想使用的 AI 服务官网（如 OpenAI, Google AI, 火山引擎方舟等），注册账户并创建一个 API Key。

*   **问：为什么点击功能后没有反应？**
    *   答：请检查你的网络连接是否正常，以及 `configuration.lua` 中的配置信息是否填写正确。

---

本项目根据 MIT 许可证发布。
