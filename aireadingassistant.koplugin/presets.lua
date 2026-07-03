local PRESETS = {
  {
    name = "DeepSeek (官方)",
    api_endpoint = "https://api.deepseek.com/chat/completions",
    models = { "deepseek-v4-flash" },
    default_model = "deepseek-v4-flash"
  },
  {
    name = "硅基流动 (SiliconFlow)",
    api_endpoint = "https://api.siliconflow.cn/v1/chat/completions",
    models = {
      "deepseek-ai/DeepSeek-V4-Flash",
      "Qwen/Qwen2.5-7B-Instruct",
      "THUDM/glm-4-9b-chat"
    },
    default_model = "deepseek-ai/DeepSeek-V4-Flash"
  },
  {
    name = "火山引擎 (火山方舟)",
    api_endpoint = "https://ark.cn-beijing.volces.com/api/v3/chat/completions",
    models = {
      "doubao-seed-2-0-mini-260215",
      "doubao-seed-2-0-lite"
    },
    default_model = "doubao-seed-2-0-mini-260215"
  },
  {
    name = "通义千问 (阿里 DashScope)",
    api_endpoint = "https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions",
    models = {
      "qwen-turbo",
      "qwen-coder-7b-instruct"
    },
    default_model = "qwen-turbo"
  },
  {
    name = "智谱 AI (GLM)",
    api_endpoint = "https://open.bigmodel.cn/api/paas/v4/chat/completions",
    models = { "glm-4-flash" },
    default_model = "glm-4-flash"
  },
  {
    name = "自定义",
    api_endpoint = "",
    models = {},
    default_model = "custom-model"
  }
}

return PRESETS
