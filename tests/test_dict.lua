#!/usr/bin/env lua

package.path = package.path .. ';../lua/?.lua;../lua/?/init.lua'

local dict = require('rikai.dict')

local test_cases = {
  {
    input = 'モブ司祭だけど、この世界が乙女ゲームだと気づいたのでヒロインを育成します。',
    expected = {
      {word = 'モブ', reading = '', definitions = '(n) (1) mob; crowd of people; (n) (2) background character (in a manga, anime, etc.); mob (in a video game); non-player character; NPC'},
      {word = 'も', reading = '', definitions = "(prt) (1) too; also; in addition; as well; (not) either (in a negative sentence); (prt) (2) both A and B; A as well as B; neither A nor B (in a negative sentence); (prt) (3) even; as much as; as many as; as far as; as long as; no less than; no fewer than; (prt) (4) even if; even though; although; in spite of; (adv) (5) (col) further; more; again; another; the other; (P)"},
      {word = '裳', reading = 'も', definitions = '(n) (hist) traditional skirt'},
      {word = '喪', reading = 'も', definitions = '(n,adj-no) (1) mourning; (n) (2) (arch) calamity; misfortune; (P)'},
      {word = '藻', reading = 'も', definitions = '(n,adj-no) algae; waterweed; seaweed; duckweed; (P)'},
      {word = '面', reading = 'も', definitions = '(ok) (n) (1) face; (n) (2) surface'},
    }
  },
  {
    input = '司祭だけど、この世界が乙女ゲームだと気づいたのでヒロインを育成します。',
    expected = {
      {word = '司祭', reading = 'しさい', definitions = '(n,adj-no) priest; minister; pastor'},
      {word = '司', reading = 'し', definitions = '(n) (arch) (hist) office (government department beneath a bureau under the ritsuryo system)'},
      {word = '司', reading = 'つかさ', definitions = '(n) (1) office; official; (n) (2) chief; head; (n) (3) person (usually a woman) who officiates at religious ceremonies (on the Yaeyama Islands in Okinawa)'},
    }
  },
  {
    input = 'だけど、この世界が乙女ゲームだと気づいたのでヒロインを育成します。',
    expected = {
      {word = 'だけど', reading = '', definitions = '(conj) but; however; although; (P)'},
      {word = '岳', reading = 'だけ', definitions = '(n,n-suf) (1) (high) mountain; Mount; Mt.; (n) (2) mountain peak'},
      {word = '丈', reading = 'だけ', definitions = '(prt) (1) (uk) only; just; merely; simply; no more than; nothing but; alone; (prt) (2) (uk) as much as; to the extent of; enough to; (P)'},
      {word = '嶽', reading = 'だけ', definitions = '(oK) (n,n-suf) (1) (high) mountain; Mount; Mt.; (n) (2) mountain peak'},
      {word = '抱く', reading = 'だく', definitions = '(v5k,vt) (1) to hold in one\'s arms (e.g. a baby); to embrace; to hug; (v5k,vt) (2) to have sex with; to make love to; to sleep with; (v5k,vt) (3) to sit on (eggs); to brood; (P)'},
      {word = 'だ', reading = '', definitions = '(aux-v) (1) did; (have) done; (aux-v) (2) (please) do'},
      {word = 'だ', reading = '', definitions = '(aux-v,cop) be; is; (P)'},
    }
  },
  {
    input = 'けど、この世界が乙女ゲームだと気づいたのでヒロインを育成します。',
    expected = {
      {word = 'ＫＥＤＯ', reading = 'ケド', definitions = '(n) (org) Korean Peninsula Energy Development Organization; KEDO'},
      {word = 'けど', reading = '', definitions = '(conj,prt) but; however; although; (P)'},
      {word = 'け', reading = '', definitions = '(prt) remind me; I forget; was it?; was that what happened?'},
      {word = 'ケ', reading = '', definitions = "(sk) (prt) (1) indicates the subject of a sentence; (prt) (2) indicates possession; (conj,prt) (3) but; however; (and) yet; though; although; while; (prt) (4) and; (prt) (5) used after an introductory remark or explanation; (prt) (6) regardless of ...; whether ... (or not); no matter ...; (prt) (7) indicates a desire or hope; (prt) (8) softens a statement; (prt) (9) indicates doubt; (prt) (10) indicates scorn"},
      {word = '異', reading = 'け', definitions = '(adj-na) unusual; extraordinary'},
      {word = '仮', reading = 'け', definitions = '(n) (Buddh) lacking substance and existing in name only; something without substance'},
      {word = '家', reading = 'け', definitions = '(suf) house; family; (P)'},
    }
  },
  {
    input = 'ど、この世界が乙女ゲームだと気づいたのでヒロインを育成します',
    expected = {
      {word = 'ど', reading = '', definitions = '(n) cylindrical bamboo fishing basket'},
      {word = 'ど', reading = '', definitions = '(prt) (1) (arch) but; however; (prt) (2) (arch) even though; even if'},
      {word = 'ド', reading = '', definitions = '(n) (1) (music) doh (1st note of a major scale in movable-do solfege) (ita:); do; (n) (2) (music) C (note in the fixed-do system)'},
      {word = '途', reading = 'ど', definitions = '(ok) (n) way; route'},
      {word = '努', reading = 'ど', definitions = '(n) third principle of the Eight Principles of Yong; downward stroke'},
      {word = '度', reading = 'ど', definitions = '(n,n-suf) (1) degree (angle, temperature, scale, etc.); (ctr) (2) counter for occurrences; (n,n-suf) (3) strength (of glasses); glasses prescription; (n,n-suf) (4) alcohol content (percentage); alcohol by volume; (n) (5) extent; degree; limit; (n) (6) presence of mind; composure; (P)'},
      {word = '度', reading = 'ど', definitions = '(sK) (pref) (1) extreme; ultra; mega; totally; very much; precisely; exactly; (pref) (2) damn; stupid; cursed'},
    }
  },
  {
    input = 'この世界が乙女ゲームだと気づいたのでヒロインを育成します',
    expected = {
      {word = 'この世', reading = 'このよ', definitions = '(n) this world; this life; world of the living'},
      {word = '９', reading = 'この', definitions = '(num) nine; 9'},
      {word = '九', reading = 'この', definitions = '(num) nine; 9'},
      {word = '玖', reading = 'この', definitions = '(num) nine; 9'},
      {word = '此の', reading = 'この', definitions = '(rK) (adj-pn) (1) (uk) this; (adj-pn) (2) (uk) last (couple of years, etc.); these; past; this; (adj-pn) (3) (uk) you (as in \"you liar\")'},
      {word = '斯の', reading = 'この', definitions = '(rK) (adj-pn) (1) (uk) this; (adj-pn) (2) (uk) last (couple of years, etc.); these; past; this; (adj-pn) (3) (uk) you (as in \"you liar\")'},
      {word = 'こ', reading = '', definitions = '(suf) (1) (abbr) doing; in such a state; (suf) (2) doing together; doing to each other; contest; match; (suf) (3) (fam) familiarizing suffix (sometimes meaning \"small\")'},
    }
  },
  {
    input = 'の世界が乙女ゲームだと気づいたのでヒロインを育成します',
    expected = {
      {word = '乃', reading = 'の', definitions = '(sK) (prt) (1) indicates possessive; (prt) (2) nominalizes verbs and adjectives; (prt) (3) substitutes for \"ga\" in subordinate phrases; (prt) (4) indicates a confident conclusion; (prt) (5) (fem) indicates emotional emphasis; (prt) (6) indicates question'},
      {word = '之', reading = 'の', definitions = '(sK) (prt) (1) indicates possessive; (prt) (2) nominalizes verbs and adjectives; (prt) (3) substitutes for \"ga\" in subordinate phrases; (prt) (4) indicates a confident conclusion; (prt) (5) (fem) indicates emotional emphasis; (prt) (6) indicates question'},
      {word = '埜', reading = 'の', definitions = '(rK) (n) (1) field; plain; (n) (2) hidden interior part (of a structure or object); (n-pref) (3) wild (of an animal or plant)'},
      {word = '布', reading = 'の', definitions = '(n,n-suf,ctr) unit of measurement for cloth breadth (30-38 cm)'},
      {word = '幅', reading = 'の', definitions = '(n,n-suf,ctr) unit of measurement for cloth breadth (30-38 cm)'},
      {word = '箆', reading = 'の', definitions = '(n) shaft (of an arrow; made of bamboo)'},
      {word = '野', reading = 'の', definitions = '(n) (1) field; plain; (n) (2) hidden interior part (of a structure or object); (n-pref) (3) wild (of an animal or plant); (P)'},
    }
  },
  {
    input = '世界が乙女ゲームだと気づいたのでヒロインを育成します',
    expected = {
      {word = '世界', reading = 'せかい', definitions = '(n) (1) the world; society; the universe; (n) (2) sphere; circle; world; (adj-no) (3) world-renowned; world-famous; (n) (4) (Buddh) realm governed by one Buddha; space; (P)'},
      {word = '世', reading = 'せい', definitions = '(ctr) (1) counter for generations; (n-suf) (2) (geol) epoch'},
      {word = '世', reading = 'よ', definitions = '(n) (1) world; society; public; (n) (2) life; lifetime; (n) (3) age; era; period; epoch; generation; (n) (4) reign; rule; (n) (5) the times; (n) (6) (Buddh) world (of existence); (P)'},
    }
  },
  {
    input = '育成します',
    expected = {
      {word = '育成', reading = 'いくせい', definitions = '(n,vs,vt) rearing; training; nurture; cultivation; promotion; (P)'},
    }
  },
}

local function contains_result(actual_results, expected_entry)
  for _, actual in ipairs(actual_results) do
    if actual.word == expected_entry.word and
       actual.reading == expected_entry.reading and
       actual.definitions == expected_entry.definitions then
      return true
    end
  end
  return false
end

print("Initializing dictionary...")
local ok, err = dict.init("../data/")
if not ok then
  print("ERROR: Failed to initialize dictionary: " .. (err or "unknown"))
  os.exit(1)
end
print("Initialized!\n")

local total_tests = 0
local passed_tests = 0

for i, test in ipairs(test_cases) do
  total_tests = total_tests + 1
  print(string.format("Test %d: %s...", i, test.input:sub(1, 30)))

  local results = dict.lookup(test.input)

  if not results then
    print("  ERROR: No results returned")
  else
    print(string.format("  Expected at least %d results, got %d", #test.expected, #results))

    if #results > 0 then
      print("  Actual results:")
      for _, r in ipairs(results) do
        print(string.format("    - %s [%s]", r.word, r.reading))
      end
    end

    local matches = 0
    local missing = 0

    for _, expected in ipairs(test.expected) do
      if contains_result(results, expected) then
        print(string.format("  [OK] %s [%s]", expected.word, expected.reading))
        matches = matches + 1
      else
        print(string.format("  [MISSING] %s [%s]", expected.word, expected.reading))
        missing = missing + 1
      end
    end

    local extra = #results - #test.expected
    if extra > 0 then
      print(string.format("  (plus %d additional results)", extra))
    end

    if missing == 0 then
      print(string.format("  ✓ All %d expected results found", matches))
      passed_tests = passed_tests + 1
    else
      print(string.format("  ✗ %d missing results", missing))
    end
  end
  print()
end

print(string.format("Results: %d/%d tests passed", passed_tests, total_tests))

if passed_tests == total_tests then
  print("✓ All tests passed!")
  os.exit(0)
else
  print("✗ Some tests failed")
  os.exit(1)
end
