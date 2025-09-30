-- Build-time file system generator for ZX Spectrum Next ROM disk
-- This Lua code runs during assembly to automatically allocate files
-- to memory banks and generate the necessary Z80 assembly code.
--
-- The ZX Spectrum Next has 128 banks of 8KB each. Files are stored
-- starting at bank 20, avoiding Layer 2 display banks (32-37).

local ROM = {}
ROM.files = {}
ROM.file_count = 0
ROM.current_offset = 0
ROM.current_bank = 20

-- Add a file to the ROM disk filesystem
-- Automatically calculates bank allocation and avoids Layer 2 banks
function ROM:add_file(label, filename)
    local file = io.open(filename, "rb")

    if not file then
        error(string.format("File not found: %s", filename))
    end

    local size = file:seek("end")
    file:close()

    -- Check if this file would spill into Layer 2 banks (32-37)
    local end_offset = self.current_offset + size
    local banks_needed = 0
    while end_offset > 8192 do
        end_offset = end_offset - 8192
        banks_needed = banks_needed + 1
    end

    -- If current bank + banks needed would enter Layer 2 range, skip ahead
    if self.current_bank < 32 and (self.current_bank + banks_needed) >= 32 then
        print(string.format("[INFO] File would spill into Layer 2 banks, moving to bank 38"))
        self.current_bank = 38
        self.current_offset = 0
    end

    print(string.format("[FILE] %s: %s (size=%d, bank=%d, offset=0x%04X)",
        label, filename, size, self.current_bank, self.current_offset))
    
    self.files[self.file_count] = {
        label = label,
        filename = filename,
        bank = self.current_bank,
        offset = self.current_offset,
        size = size
    }
    
    self.current_offset = self.current_offset + size
    while self.current_offset >= 8192 do
        self.current_offset = self.current_offset - 8192
        self.current_bank = self.current_bank + 1
        -- Skip Layer 2 display banks (32-37)
        if self.current_bank == 32 then
            self.current_bank = 38
            print("[INFO] Skipping Layer 2 banks 32-37, continuing at bank 38")
        end
    end
    
    self.file_count = self.file_count + 1
end

if not ROM then
    error("Failed to load filesys.lua")
end
print("[LUA] Loaded filesys.lua successfully")

return ROM