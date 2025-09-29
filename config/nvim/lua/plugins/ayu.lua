return {
    'Shatur/neovim-ayu',
    config = function()
        local colors = require('ayu.colors')
        colors.generate()

        require('ayu').setup({
            mirage = false,
            terminal = true,
            overrides = {},
        })

        require('ayu').colorscheme()
    end,
}
