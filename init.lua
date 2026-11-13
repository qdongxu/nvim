vim.g.mapleader = " "
vim.g.maplocalleader = " "

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)
require("lazy").setup("plugins")
vim.opt.termguicolors = true
vim.o.timeoutlen = 300 -- Waits only 300ms instead of 1000ms

-- Only explicit yanks (y/yy/yi…) go to the system clipboard; deletes/changes
-- never overwrite it (macOS pbcopy/pbpaste, no extra provider needed).
-- Paste FROM the system clipboard with "+p (or <C-r>+ in insert mode).
vim.api.nvim_create_autocmd("TextYankPost", {
    callback = function()
        if vim.v.event.operator ~= "y" then
            return
        end
        vim.fn.setreg("+", vim.v.event.regcontents, vim.v.event.regtype)
    end,
})

-- Auto-save every 5s, but never clobber external changes:
--   * a modified buffer is only written if the file on disk still matches
--     the mark (mtime+size) recorded at its last read/write;
--   * if the file changed on disk (agent/OpenCode rewrote it) the save is
--     skipped with a one-time warning -- :e! loads the new content;
--   * if the file vanished (external mv/rm) the save is skipped too, so a
--     stale buffer cannot resurrect deleted/renamed files;
--   * 'autoread' + checktime make UNMODIFIED buffers pick up external
--     rewrites silently, so :e! is only ever needed after local edits.
vim.opt.autoread = true
local function disk_mark(buf)
    local name = vim.api.nvim_buf_get_name(buf)
    if name == "" then
        return nil
    end
    local st = vim.loop.fs_stat(name)
    if not st then
        return { gone = true }
    end
    return { mtime = st.mtime.sec * 1000000000 + st.mtime.nsec, size = st.size }
end
-- Mark is refreshed ONLY on real reads (initial load / autoread / :e!) and
-- our own writes. Deliberately NOT on FileChangedShellPost: that event fires
-- for modified buffers when checktime notices an external change -- exactly
-- the conflict case -- and refreshing there would make the guard see the new
-- disk state as "known" and let the write through (into Vim's W12 prompt).
vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost" }, {
    callback = function(args)
        vim.b[args.buf].diskMark = disk_mark(args.buf)
    end,
})
vim.fn.timer_start(5000, function()
    vim.cmd("silent! checktime") -- passively reload unmodified buffers
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf)
            and vim.bo[buf].modified
            and vim.bo[buf].buftype == ""
            and vim.bo[buf].modifiable
            and vim.api.nvim_buf_get_name(buf) ~= ""
        then
            local mark = vim.b[buf].diskMark
            local cur = disk_mark(buf)
            if mark == nil then
                vim.b[buf].diskMark = cur -- first sight (brand-new buffer)
            elseif cur.gone and not mark.gone then
                if not vim.b[buf].autosaveWarned then
                    vim.b[buf].autosaveWarned = true
                    vim.notify(
                        "autosave skipped: " .. vim.api.nvim_buf_get_name(buf)
                        .. " disappeared from disk (renamed/deleted externally); close this buffer",
                        vim.log.levels.WARN)
                end
            elseif cur.mtime ~= mark.mtime or cur.size ~= mark.size then
                if not vim.b[buf].autosaveWarned then
                    vim.b[buf].autosaveWarned = true
                    vim.notify(
                        "autosave skipped: " .. vim.api.nvim_buf_get_name(buf)
                        .. " changed on disk after your edits; :e! to take the disk version"
                        .. " (local edits lost) or :wa! to force yours",
                        vim.log.levels.WARN)
                end
            else
                vim.api.nvim_buf_call(buf, function()
                    vim.cmd("silent! write")
                end)
            end
        end
    end
end, { ["repeat"] = -1 })

-- Publish the focused file + cursor line, keyed by this nvim instance's project
-- directory, so external tools (OpenCode agent) can resolve "this file" /
-- "line N" references even with several nvim instances running at once (one
-- per Ghostty window/tab, each opened in its own project):
--   ~/.local/state/nvim/current-files/<sanitized cwd>  contains path:line
-- The agent lists this dir and picks the entry matching the project being
-- discussed. Updated on buffer switch and whenever the cursor rests
-- (CursorHold, i.e. after 'updatetime' ms of idleness).
local current_files_dir = vim.fn.stdpath("state") .. "/current-files"
vim.fn.mkdir(current_files_dir, "p")
local function cwd_key()
    -- /Users/x/my-proj -> -Users-x-my-proj (slashes are not filename-safe)
    return vim.fn.substitute(vim.fn.getcwd(), "/", "-", "g")
end
vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold" }, {
    callback = function()
        if vim.bo.buftype ~= "" or vim.api.nvim_buf_get_name(0) == "" then
            return
        end
        vim.fn.writefile(
            { vim.api.nvim_buf_get_name(0) .. ":" .. vim.fn.line(".") },
            current_files_dir .. "/" .. cwd_key()
        )
    end,
})

-- Clean up this instance's current-file entry on exit, so the directory only
-- ever contains entries for still-running nvim instances. Guard: keep the
-- file if another nvim process still runs in this same project (same cwd),
-- because instances share one entry per project.
vim.api.nvim_create_autocmd("VimLeavePre", {
    callback = function()
        local key = cwd_key()
        local path = current_files_dir .. "/" .. key
        if vim.fn.filereadable(path) == 0 then
            return
        end
        for _, pidstr in ipairs(vim.fn.systemlist("pgrep -x nvim || true")) do
            local pid = tonumber(pidstr)
            if pid and pid ~= vim.fn.getpid() then
                local out = vim.fn.systemlist("lsof -a -p " .. pid .. " -d cwd -Fn 2>/dev/null")
                for _, line in ipairs(out) do
                    if line:sub(1, 1) == "n" then
                        local dir = vim.fn.substitute(line:sub(2), "/", "-", "g")
                        if dir == key then
                            return -- a live same-project nvim still owns this entry
                        end
                    end
                end
            end
        end
        vim.fn.delete(path)
    end,
})

-- Default settings: Expand tabs to 4 spaces
vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4

-- Go specific settings: Keep standard tabs
vim.api.nvim_create_autocmd("FileType", {
    pattern = "go",
    callback = function()
        vim.opt_local.expandtab = false
        vim.opt_local.tabstop = 4
        vim.opt_local.shiftwidth = 4
        vim.opt_local.softtabstop = 4
    end,
})

-- Quickfix window (gr references / grep results):
--   Enter jumps (default behavior, window stays open for repeated jumps);
--   q closes it from inside the window; <leader>q closes it from anywhere.
vim.keymap.set("n", "<leader>q", "<cmd>silent! cclose<cr>", { silent = true })
vim.api.nvim_create_autocmd("FileType", {
    pattern = "qf",
    callback = function(args)
        vim.keymap.set("n", "q", "<cmd>cclose<cr>", { buffer = args.buf, silent = true })
    end,
})




