return {
    "williamboman/mason.nvim",
    opts = {
        ensure_installed = {
            "pyright",
            "rust-analyzer",
        },
    },
    config = function()
        require("mason").setup()
    end,
}
