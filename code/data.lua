-- Build-time code generator for ROM disk file table
-- These functions generate Z80 assembly code during the build process.

-- Generate file table entries with offset, bank, and size for each ROM file
-- Called from data.asm to create the Files: lookup table
function generate_file_table()
    for i = 0, ROM.file_count - 1 do
        local f = ROM.files[i]
        _pc(string.format("\tdw $%04X", f.offset))
        _pc(string.format("\tdb %d", f.bank))
        _pc(string.format("\tdw %d", f.size))
    end
end

-- Generate incbin statements for all files with proper banking
-- Outputs MMU commands and org directives to embed files in correct banks
function generate_file_incbins()
    local current_mapped_bank = 20
    local current_offset = 0

    -- Map initial bank
    _pc(string.format("\tMMU\t7 n, %d", current_mapped_bank))
    _pc("\torg\t$E000")

    for i = 0, ROM.file_count - 1 do
        local f = ROM.files[i]

        -- Check if we need to switch banks
        if f.bank ~= current_mapped_bank then
            current_mapped_bank = f.bank
            _pc(string.format("\tMMU\t7 n, %d", current_mapped_bank))
            _pc(string.format("\torg\t$%04X", 0xE000 + f.offset))
        elseif f.offset ~= current_offset then
            _pc(string.format("\torg\t$%04X", 0xE000 + f.offset))
        end

        -- Generate the incbin statement with the actual filename
        _pc(string.format("\tincbin \"../%s\"", f.filename))

        -- Update current offset
        current_offset = (f.offset + f.size) % 8192
    end
end