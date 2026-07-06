return {
    {
        'yetone/avante.nvim',
        -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
        build = vim.fn.has 'win32' ~= 0
                and 'powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false'
            or 'make',
        event = 'VeryLazy',
        version = false, -- Never set this value to "*"! Never!
        ---@module 'avante'
        ---@type avante.Config
        opts = {
            input = {
                provider = 'snacks',
                provider_opts = {
                    -- Additional snacks.input options
                    title = 'Avante Input',
                    icon = ' ',
                },
            },
            instructions_file = 'avante.md',
            provider = 'gemini-cli',
            acp_providers = {
                ['gemini-cli'] = {
                    command = 'gemini',
                    args = { '--experimental-acp', '--model', 'gemini-2.5-flash' },
                    env = {
                        NODE_NO_WARNINGS = '1',
                        HOME = os.getenv 'HOME',
                        GEMINI_API_KEY = os.getenv 'AVANTE_GEMINI_API_KEY'
                            or os.getenv 'GEMINI_API_KEY',
                    },
                },
            },
            -- TODO: try RAG https://github.com/yetone/avante.nvim/blob/main/README.md#rag-service
            -- TODO: compare and use it... does it work ok
            providers = {
                ollama = {
                    endpoint = 'http://127.0.0.1:11434', -- Native Ollama port (No "/v1" suffix)
                    model = 'qwen2.5-coder:7b', -- Change to your downloaded model
                    is_env_set = function()
                        return require('avante.providers.ollama').check_endpoint_alive()
                    end,
                    extra_request_body = {
                        options = {
                            num_ctx = 32768, -- Give the model enough room for code context
                            temperature = 0, -- Low temperature is ideal for coding
                        },
                    },
                },
                ['local-openai'] = {
                    __inherited_from = 'openai',
                    endpoint = 'http://127.0.0.1:1234/v1', -- Default LM Studio port (Needs "/v1" suffix)
                    model = 'qwen2.5-coder-7b-instruct',
                    api_key_name = '', -- Prevents Avante from prompting for a key on startup
                    extra_request_body = {
                        temperature = 0.2,
                        max_completion_tokens = 4096,
                    },
                },
                gemini = {
                    endpoint = 'https://generativelanguage.googleapis.com/v1beta/models',
                    model = 'gemini-2.5-flash',
                    timeout = 30000, -- Timeout in milliseconds
                    extra_request_body = {
                        temperature = 0.2,
                        max_tokens = 8192,
                    },
                },
                claude = {
                    endpoint = 'https://api.anthropic.com',
                    model = 'claude-sonnet-4-20250514',
                    timeout = 30000, -- Timeout in milliseconds
                    extra_request_body = {
                        temperature = 0.75,
                        max_tokens = 20480,
                    },
                },
                moonshot = {
                    endpoint = 'https://api.moonshot.ai/v1',
                    model = 'kimi-k2-0711-preview',
                    timeout = 30000, -- Timeout in milliseconds
                    extra_request_body = {
                        temperature = 0.75,
                        max_tokens = 32768,
                    },
                },
            },
        },
        dependencies = {
            'nvim-lua/plenary.nvim',
            'MunifTanjim/nui.nvim',
            --- The below dependencies are optional,
            'hrsh7th/nvim-cmp', -- autocompletion for avante commands and mentions
            'folke/snacks.nvim', -- for input provider snacks
            'nvim-tree/nvim-web-devicons', -- or echasnovski/mini.icons
            -- "nvim-mini/mini.pick",           -- for file_selector provider mini.pick
            -- "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
            -- "ibhagwan/fzf-lua",              -- for file_selector provider fzf
            -- "stevearc/dressing.nvim",        -- for input provider dressing
            -- "zbirenbaum/copilot.lua",        -- for providers='copilot'
            {
                -- support for image pasting
                'HakonHarnes/img-clip.nvim',
                event = 'VeryLazy',
                opts = {
                    -- recommended settings
                    default = {
                        embed_image_as_base64 = false,
                        prompt_for_file_name = false,
                        drag_and_drop = {
                            insert_mode = true,
                        },
                        -- required for Windows users
                        use_absolute_path = true,
                    },
                },
            },
            {
                -- Make sure to set this up properly if you have lazy=true
                'MeanderingProgrammer/render-markdown.nvim',
                opts = {
                    file_types = { 'Avante' },
                },
                ft = { 'Avante' },
            },
        },
    },
}
