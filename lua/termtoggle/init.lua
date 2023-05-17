local TERM_TOGGLE_WIN_ID = nil
local TERM_TOGGLE_BUF_ID = nil
local TERM_TOGGLE_HEIGHT = 20
local TERM_IS_ON = nil
local TERM_BG=""

local function setup(t)
    if t ~= nil and t.bg ~= nil then
        TERM_BG = t.bg
    end
end

local function close_win()
    if TERM_TOGGLE_WIN_ID ~= nil then
        vim.api.nvim_win_close(TERM_TOGGLE_WIN_ID, true)
        TERM_TOGGLE_WIN_ID = nil
    end
end

local function check()
    local __current_win__ = vim.api.nvim_get_current_win()
    if __current_win__ == TERM_TOGGLE_WIN_ID then
        close_win()
        TERM_IS_ON = nil
    end
end

local function draw_term()
    local _width = vim.api.nvim_list_uis()[1].width
    local _height = vim.api.nvim_list_uis()[1].height
    TERM_TOGGLE_WIN_ID = vim.api.nvim_open_win(TERM_TOGGLE_BUF_ID, true, { relative="editor",
                 width= _width- 2, height= TERM_TOGGLE_HEIGHT ,
                 col= 2, row= _height - 2,
                 border="rounded"})
    vim.wo.number = false
    vim.wo.relativenumber = false
    if TERM_BG ~= "" then
        vim.api.nvim_win_set_hl_ns(TERM_TOGGLE_WIN_ID, vim.api.nvim_create_namespace("termtoggle"))
        vim.api.nvim_set_hl(vim.api.nvim_create_namespace("termtoggle"), "Normal", { bg = TERM_BG})
    end
end

local function term_toggle()
    if TERM_TOGGLE_BUF_ID == nil then
        TERM_TOGGLE_BUF_ID = vim.api.nvim_create_buf(false, true)
    end
    if TERM_TOGGLE_WIN_ID == nil then
        draw_term()
        if TERM_IS_ON == nil then
            vim.cmd("term zsh")
            vim.cmd("set nobuflisted")
            TERM_TOGGLE_BUF_ID = vim.api.nvim_get_current_buf()
            TERM_IS_ON = true
        end
    else
        close_win()
    end
end

local function on_resize()
    if TERM_TOGGLE_WIN_ID ~= nil then
        close_win()
        draw_term()
    end
end

local term_group = vim.api.nvim_create_augroup("github.com/aditya-K2/termtoggle.nvim", {clear = true})

vim.api.nvim_create_autocmd("VimResized", {
    group = term_group,
    pattern = "*",
    callback = on_resize
})

vim.api.nvim_create_autocmd("TermClose", {
    group = term_group,
    pattern = "*",
    callback = check
})

vim.api.nvim_create_autocmd("VimLeave", {
    group = term_group,
    pattern = "*",
    callback = function()
        TERM_TOGGLE_WIN_ID = nil
    end
})

vim.api.nvim_set_keymap('t', '<M-m>', '', {silent=true, noremap=true, callback=term_toggle})
vim.api.nvim_set_keymap("n", '<M-m>', '', {silent=true, noremap=true, callback=term_toggle})

return {
    setup = setup,
}
