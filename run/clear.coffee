
f = (x) ->
  if x <= 2 then 1 else f(x-1) + f(x-2)

console.log (f 13)