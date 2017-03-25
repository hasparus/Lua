require('past01')

function parseLisp(str)
  local matched = str:match('^%s*(%b())%s*$')
  if matched then
    matched = str:match('%(%s*(.*)%s*%)')
    return map(parseLisp, matched:tokenize(' \n'))
  else 
    matched = str:match('^%s*(%b"")%s*$')
    if matched then return str --[[:match('"%s*(.*)%s*%"')]] end --strip spaces and quotation marks
    matched = str:match('^%s*%d+%s*$')
    if matched then return tonumber(str) end
    return hash2string{symbol = '"' .. str .. '"'} 
    -- return {symbol = str}
    --psuję parsowanie, żeby to wypisać: 2do na potem, napisać sensowny tostring dla tablic, hashform jesli nie sa sekwencja, arrayform wpp
  end
end

print(parseLisp [[( if nil
( list 1 2 "foo")
(+ 1 2 var 4))
]])
