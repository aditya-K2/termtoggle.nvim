TERM_TOGGLE_WIN_ID = nil
TERM_TOGGLE_BUF_ID = nil
TERM_TOGGLE_HEIGHT = 20
TERM_IS_ON = nil
vim.cmd [[
    augroup CPH
        autocmd!
        autocmd VimResized * :lua require("termtoggle").OnResize()
        autocmd TermClose * :lua require("termtoggle").Check()
        autocmd VimLeave * :lua TERM_TOGGLE_WIN_ID = nil
    augroup END
    tnoremap <M-m> <C-\><C-n>:lua require("termtoggle").TermToggle()<CR>
]]

local function CloseWin()
    if TERM_TOGGLE_WIN_ID ~= nil then
        vim.api.nvim_win_close(TERM_TOGGLE_WIN_ID, true)
        TERM_TOGGLE_WIN_ID = nil
    end
end

local function Check()
    CloseWin()
    TERM_IS_ON = nil
end

local function DrawTerm()
    local _width = vim.api.nvim_list_uis()[1].width
    local _height = vim.api.nvim_list_uis()[1].height
    TERM_TOGGLE_WIN_ID = vim.api.nvim_open_win(TERM_TOGGLE_BUF_ID, true, { relative="editor",
                 width= _width- 2, height= TERM_TOGGLE_HEIGHT ,
                 col= 2, row= _height - 2,
                 border="rounded"})
    vim.wo.number = false
    vim.wo.relativenumber = false
end

local function TermToggle()
    if TERM_TOGGLE_BUF_ID == nil then
        TERM_TOGGLE_BUF_ID = vim.api.nvim_create_buf(false, true)
    end
    if TERM_TOGGLE_WIN_ID == nil then
        DrawTerm()
        if TERM_IS_ON == nil then
            vim.cmd("term zsh")
            TERM_TOGGLE_BUF_ID = vim.api.nvim_get_current_buf()
            TERM_IS_ON = true
        end
    else
        CloseWin()
    end
end

local function OnResize()
    if TERM_TOGGLE_WIN_ID ~= nil then
        CloseWin()
        DrawTerm()
    end
end

return {
    TermToggle = TermToggle,
    OnResize = OnResize,
    CloseWin = CloseWin,
    Check = Check,
}
