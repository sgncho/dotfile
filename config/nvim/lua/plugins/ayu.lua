return {
    'Shatur/neovim-ayu',
    config = function()
        local colors = require('ayu.colors')
        colors.generate()

        require('ayu').setup({
            mirage = false,
            terminal = true,
            overrides = {
                Normal = { bg = '#FCFCFC' },
                NormalNC = { bg = '#FCFCFC' },
                NormalFloat = { bg = '#FCFCFC' },
                SignColumn = { bg = '#FCFCFC' },
            },
        })

        require('ayu').colorscheme()
    end,
}
