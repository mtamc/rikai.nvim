local M = {}

local bit = require('bit')
local band = bit.band
local rshift = bit.rshift

local word_dict = nil
local word_index = nil
local dif_reasons = {}
local dif_rules = {}
local initialized = false

local KANA_MAP = {
  ['ァ'] = 'ぁ', ['ア'] = 'あ', ['ィ'] = 'ぃ', ['イ'] = 'い', ['ゥ'] = 'ぅ', ['ウ'] = 'う',
  ['ェ'] = 'ぇ', ['エ'] = 'え', ['ォ'] = 'ぉ', ['オ'] = 'お',
  ['カ'] = 'か', ['ガ'] = 'が', ['キ'] = 'き', ['ギ'] = 'ぎ', ['ク'] = 'く', ['グ'] = 'ぐ',
  ['ケ'] = 'け', ['ゲ'] = 'げ', ['コ'] = 'こ', ['ゴ'] = 'ご',
  ['サ'] = 'さ', ['ザ'] = 'ざ', ['シ'] = 'し', ['ジ'] = 'じ', ['ス'] = 'す', ['ズ'] = 'ず',
  ['セ'] = 'せ', ['ゼ'] = 'ぜ', ['ソ'] = 'そ', ['ゾ'] = 'ぞ',
  ['タ'] = 'た', ['ダ'] = 'だ', ['チ'] = 'ち', ['ヂ'] = 'ぢ', ['ッ'] = 'っ', ['ツ'] = 'つ',
  ['ヅ'] = 'づ', ['テ'] = 'て', ['デ'] = 'で', ['ト'] = 'と', ['ド'] = 'ど',
  ['ナ'] = 'な', ['ニ'] = 'に', ['ヌ'] = 'ぬ', ['ネ'] = 'ね', ['ノ'] = 'の',
  ['ハ'] = 'は', ['バ'] = 'ば', ['パ'] = 'ぱ', ['ヒ'] = 'ひ', ['ビ'] = 'び', ['ピ'] = 'ぴ',
  ['フ'] = 'ふ', ['ブ'] = 'ぶ', ['プ'] = 'ぷ', ['ヘ'] = 'へ', ['ベ'] = 'べ', ['ペ'] = 'ぺ',
  ['ホ'] = 'ほ', ['ボ'] = 'ぼ', ['ポ'] = 'ぽ',
  ['マ'] = 'ま', ['ミ'] = 'み', ['ム'] = 'む', ['メ'] = 'め', ['モ'] = 'も',
  ['ャ'] = 'ゃ', ['ヤ'] = 'や', ['ュ'] = 'ゅ', ['ユ'] = 'ゆ', ['ョ'] = 'ょ', ['ヨ'] = 'よ',
  ['ラ'] = 'ら', ['リ'] = 'り', ['ル'] = 'る', ['レ'] = 'れ', ['ロ'] = 'ろ',
  ['ヮ'] = 'ゎ', ['ワ'] = 'わ', ['ヲ'] = 'を', ['ン'] = 'ん', ['ヴ'] = 'ゔ',
}

local function get_plugin_dir()
  local str = debug.getinfo(1, "S").source:sub(2)
  return str:match("(.*/)")
end

local function read_file(path)
  local file = io.open(path, "r")
  if not file then
    return nil, "Could not open file: " .. path
  end
  local content = file:read("*all")
  file:close()
  return content
end

local function utf8_char_len(byte)
  if byte >= 0xF0 then
    return 4
  elseif byte >= 0xE0 then
    return 3
  elseif byte >= 0xC0 then
    return 2
  else
    return 1
  end
end

-- Convert character position (JavaScript-style) to byte position (Lua-style)
-- The offsets in the index are character positions, not byte positions!
local function char_pos_to_byte_pos(text, char_pos)
  local byte_pos = 1
  local current_char = 0

  while byte_pos <= #text and current_char < char_pos do
    local byte = text:byte(byte_pos)
    local char_len = utf8_char_len(byte)
    byte_pos = byte_pos + char_len
    current_char = current_char + 1
  end

  return byte_pos
end

local function utf8_remove_last_char(text)
  if #text == 0 then return "" end

  -- Find start of last character by scanning backwards
  local i = #text
  while i > 0 do
    local byte = text:byte(i)
    -- If this is a starting byte (not a continuation byte 0x80-0xBF)
    if byte < 0x80 or byte >= 0xC0 then
      return text:sub(1, i - 1)
    end
    i = i - 1
  end
  return ""
end

local function normalize_input(text)
  local result = ""
  local i = 1
  while i <= #text do
    local byte = text:byte(i)
    local char_len = utf8_char_len(byte)

    -- Extract the full character
    local char = text:sub(i, i + char_len - 1)

    -- Try to normalize it
    local normalized = KANA_MAP[char]
    if normalized then
      result = result .. normalized
    else
      result = result .. char
    end

    i = i + char_len
  end
  return result
end

-- Simple linear search in index (for now - can optimize later)
local function find_in_index(data, search_text)
  if data:sub(1, #search_text) == search_text then
    local line_end = data:find('\n', 1, true) or #data
    return data:sub(1, line_end - 1)
  end

  local search_with_nl = "\n" .. search_text
  local pos = data:find(search_with_nl, 1, true)

  if not pos then
    return nil
  end

  local line_start = pos + 1

  local line_end = data:find('\n', line_start + 1, true)
  if not line_end then
    line_end = #data
  end

  return data:sub(line_start, line_end - 1)
end

local function parse_entry(line)
  -- Format: word [reading] /definition1/definition2/  -- OR: word /definition1/definition2/ (no reading)

  -- Try with reading first
  local word, reading, defs = line:match("^([^%s]+)%s+%[([^%]]*)%]%s*/(.+)/$")

  if not word then
    -- Try without reading
    word, defs = line:match("^([^%s]+)%s*/(.+)/$")
    reading = ""
  end

  if not word or not defs then
    return nil
  end

  local definitions = defs:gsub("/", "; ")

  return {
    word = word,
    reading = reading,
    definitions = definitions
  }
end

local function load_deinflect_data(path)
  local content, err = read_file(path)
  if not content then
    return false, err
  end

  local lines = {}
  for line in content:gmatch("[^\r\n]+") do
    table.insert(lines, line)
  end

  dif_reasons = {}
  dif_rules = {}

  local current_length = -1
  local current_group = nil

  for i = 2, #lines do
    local parts = {}
    for part in lines[i]:gmatch("[^\t]+") do
      table.insert(parts, part)
    end

    if #parts == 1 then
      -- This is a reason
      table.insert(dif_reasons, parts[1])
    elseif #parts == 4 then
      -- This is a rule: from, to, type_mask, reason_index
      local rule = {
        from = parts[1],
        to = parts[2],
        type_mask = tonumber(parts[3]),
        reason_index = tonumber(parts[4])
      }

      local from_len = #rule.from
      if from_len ~= current_length then
        current_length = from_len
        current_group = {
          from_length = current_length,
          rules = {}
        }
        table.insert(dif_rules, current_group)
      end

      table.insert(current_group.rules, rule)
    end
  end

  return true
end

local function deinflect(word)
  local results = {{word = word, type = 0xff, reason = ""}}
  local have = {[word] = 1}

  local i = 1
  while i <= #results do
    local curr = results[i]
    local curr_word = curr.word
    local word_len = #curr_word
    local curr_type = curr.type

    for _, group in ipairs(dif_rules) do
      if group.from_length <= word_len then
        local word_end = curr_word:sub(-group.from_length)

        for _, rule in ipairs(group.rules) do
          if band(curr_type, rule.type_mask) ~= 0 and word_end == rule.from then
            local new_word = curr_word:sub(1, word_len - #rule.from) .. rule.to

            if #new_word > 0 and not have[new_word] then
              local new_reason = dif_reasons[rule.reason_index + 1] or ""
              if curr.reason ~= "" then
                new_reason = new_reason .. " < " .. curr.reason
              end

              table.insert(results, {
                word = new_word,
                type = rshift(rule.type_mask, 8),
                reason = new_reason
              })
              have[new_word] = #results
            end
          end
        end
      end
    end

    i = i + 1
  end

  return results
end

function M.init(data_dir)
  if initialized then
    return true
  end

  if not data_dir then
    local plugin_dir = get_plugin_dir()
    data_dir = plugin_dir .. "../../data/"
  end

  local dict_path = data_dir .. "dict.dat"
  local idx_path = data_dir .. "dict.idx"
  local deinflect_path = data_dir .. "deinflect.dat"

  local content, err

  content, err = read_file(dict_path)
  if not content then
    return false, "Failed to load dict.dat: " .. (err or "unknown error")
  end
  word_dict = content

  content, err = read_file(idx_path)
  if not content then
    return false, "Failed to load dict.idx: " .. (err or "unknown error")
  end
  word_index = content

  local ok
  ok, err = load_deinflect_data(deinflect_path)
  if not ok then
    return false, "Failed to load deinflect.dat: " .. (err or "unknown error")
  end

  initialized = true
  return true
end

function M.lookup(input, max_entries)
  if not initialized then
    return nil, "Dictionary not initialized. Call init() first."
  end

  max_entries = max_entries or 7

  local normalized = normalize_input(input)
  local results = {}
  local have = {}
  local count = 0

  local word = normalized
  while #word > 0 and count < max_entries do
    local deinflections = deinflect(word)

    for deinf_idx, deinf in ipairs(deinflections) do
      if count >= max_entries then
        break
      end

      local index_line = find_in_index(word_index, deinf.word .. ",")

      if index_line then
        -- Parse offsets from index line (format: "word,offset1,offset2,...")
        -- Split by comma and skip the word (first element)
        local parts = {}
        for part in (index_line .. ','):gmatch("([^,]*),") do
          table.insert(parts, part)
        end

        -- parts[1] is the word, parts[2]+ are offsets
        for i = 2, #parts do
          if count >= max_entries then
            break
          end

          local ofs = tonumber(parts[i])
          if not have[ofs] then
            local byte_pos = char_pos_to_byte_pos(word_dict, ofs)

            local entry_end = word_dict:find('\n', byte_pos, true) or #word_dict
            local entry_line = word_dict:sub(byte_pos, entry_end - 1)

            local ok = true
            if deinf_idx > 1 then
              local parts_check = {}
              for part in entry_line:gmatch("[^,()]+") do
                table.insert(parts_check, part)
              end

              local y = deinf.type
              local found = false
              local z = math.min(#parts_check, 10)

              for j = z, 1, -1 do
                local w = parts_check[j]:match("^%s*(.-)%s*$") -- trim
                if band(y, 1) ~= 0 and w == 'v1' then
                  found = true
                  break
                end
                if band(y, 4) ~= 0 and w == 'adj-i' then
                  found = true
                  break
                end
                if band(y, 2) ~= 0 and w:sub(1, 2) == 'v5' then
                  found = true
                  break
                end
                if band(y, 16) ~= 0 and w:sub(1, 3) == 'vs-' then
                  found = true
                  break
                end
                if band(y, 8) ~= 0 and w == 'vk' then
                  found = true
                  break
                end
                if band(y, 32) ~= 0 and w == 'cop' then
                  found = true
                  break
                end
              end
              ok = found
            end

            if ok then
              local parsed = parse_entry(entry_line)
              if parsed then
                table.insert(results, parsed)
                have[ofs] = true
                count = count + 1
              end
            end
          end
        end
      end
    end

    word = utf8_remove_last_char(word)
  end

  return results
end

return M
