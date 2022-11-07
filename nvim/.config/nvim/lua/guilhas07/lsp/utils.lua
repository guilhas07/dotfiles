-- Ui Settings
local border = "rounded"

vim.diagnostic.config({
    float = { border = border },
})

-- lspconfig window
require("lspconfig.ui.windows").default_options.border = border

-- Configure handlers
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = border })

-- Setup Mason
require("mason").setup({ ui = { border = border } })

local servers = {
    sumneko_lua = {
        settings = {
            Lua = {
                diagnostics = {
                    globals = { "vim" },
                },
            },
        },
    },
    tsserver = {},
    clangd = {},
    jdtls = {},
    pylsp = {},
    html = {},
    cssls = {},
}

local ensure_installed = {}
for i, _ in pairs(servers) do
    table.insert(ensure_installed, i)
end

-- Insure LSPs are installed
require("mason-lspconfig").setup({
    ensure_installed = ensure_installed,
})

-- Setup autoformmating
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
local lsp_formatting = function(bufnr)
    vim.lsp.buf.format({
        filter = function(client)
            return client.name ~= "tsserver"
        end,
        bufnr = bufnr,
    })
end

local M = {}

-- LspAttach Function
function M.on_attach(client, bufnr)
    local bufopts = { noremap = true, silent = true, buffer = bufnr }
    vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
    vim.keymap.set("n", "<leader>[d", vim.diagnostic.goto_next, bufopts)
    vim.keymap.set("n", "<leader>]d", vim.diagnostic.goto_prev, bufopts)
    vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, bufopts)
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, bufopts)
    vim.keymap.set("n", "<leader>f", lsp_formatting, bufopts)

    -- auto formatting
    if client.supports_method("textDocument/formatting") then
        vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
        vim.api.nvim_create_autocmd("BufWritePre", {
            group = augroup,
            buffer = bufnr,
            callback = function()
                lsp_formatting(bufnr)
            end,
        })
    end
end

-- Servers config
M.servers = servers

return M