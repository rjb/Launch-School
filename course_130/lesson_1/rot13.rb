PIONEERS = [
  'Nqn Ybirynpr',
  'Tenpr Ubccre',
  'Nqryr Tbyqfgvar',
  'Nyna Ghevat',
  'Puneyrf Onoontr',
  'Noqhyynu Zhunzznq ova Zhfn ny-Xujnevmzv',
  'Wbua Ngnanfbss',
  'Ybvf Unyog',
  'Pynhqr Funaaba',
  'Fgrir Wbof',
  'Ovyy Tngrf',
  'Gvz Orearef-Yrr',
  'Fgrir Jbmavnx',
  'Xbaenq Mhfr',
  'Wbua Ngnanfbss',
  'Fve Nagbal Ubner',
  'Zneiva Zvafxl',
  'Lhxvuveb Zngfhzbgb',
  'Unllvz Fybavzfxv',
  'Tregehqr Oynapu'
].freeze

def rot13(string)
  string.split('').map { |char| decipher(char) }.join
end

def decipher(char)
  first = [*'A'..'M', *'a'..'m']
  last = [*'N'..'Z', *'n'..'z']
  if first.include?(char)
    last[first.index(char)]
  elsif last.include?(char)
    first[last.index(char)]
  else
    char
  end
end

def decipher2(char)
  case char
  when 'A'..'M', 'a'..'m'
    (char.ord + 13).chr
  when 'N'..'Z', 'n'..'z'
    (char.ord - 13).chr
  else
    char
  end
end

def decipher3(char)
  alpha_up = ('A'..'Z').to_a
  alpha_down = ('a'..'z').to_a
  if alpha_up.include?(char)
    alpha_up[alpha_up.index(char) - 13]
  elsif alpha_down.include?(char)
    alpha_down[alpha_down.index(char) - 13]
  else
    char
  end
end

PIONEERS.each { |pioneer| puts rot13(pioneer) }
