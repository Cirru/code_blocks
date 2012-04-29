// Generated by CoffeeScript 1.3.1
var add_inputs, available_chars, blank, cancel, control, curse, down, draw, enter, esc, input, keymap, left, ll, render_curse, right, space, store, tag, up,
  __slice = [].slice,
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

tag = function(id) {
  return document.getElementById(id);
};

ll = function() {
  var item, time, v, _i, _len, _results;
  v = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
  _results = [];
  for (_i = 0, _len = v.length; _i < _len; _i++) {
    item = v[_i];
    time = new Date().getTime();
    _results.push(console.log(time, item));
  }
  return _results;
};

keymap = '';

available_chars = 'abcdefghijjklmnopqrstuvwxyz';

available_chars += 'ABCDEFGHIJJKLMNOPQRSTUVWXYZ';

available_chars += '1234567890!@#$%^&*()';

available_chars += '~`_-+-[]{}\\|:;"\',.<>/?';

add_inputs = available_chars.split('');

curse = '\t';

render_curse = '<nav>&nbsp;</nav>';

draw = function(arr) {
  var item, str, _i, _len;
  str = '';
  for (_i = 0, _len = arr.length; _i < _len; _i++) {
    item = arr[_i];
    if (Array.isArray(item)) {
      str += draw(item);
    } else if (item === curse) {
      str += render_curse;
    } else {
      item = item.replace(curse, render_curse).replace(/\s/g, '&nbsp;');
      str += "<code>" + item + "</code>";
    }
  }
  return "<div>" + str + "</div>";
};

window.onload = function() {
  var box, refresh;
  box = tag('box');
  window.focus();
  (refresh = function() {
    box.innerHTML = draw(store);
    return console.log('Refreshing :::: ', store);
  })();
  document.onkeypress = function(e) {
    var char;
    char = String.fromCharCode(e.keyCode);
    if (__indexOf.call(add_inputs, char) >= 0) {
      console.log("(" + char + ") in inputs");
      input(char);
      refresh();
    }
    return false;
  };
  return document.onkeydown = function(e) {
    var code;
    code = e.keyCode;
    if (control['' + code] != null) {
      control['' + code]();
      refresh();
      return false;
    }
  };
};

store = ['45345', '345345', ['44', '5', 'sdfsdfsdf\t', ['444']]];

input = function(char) {
  var recurse;
  recurse = function(arr) {
    var c, coll, copy, item, _i, _j, _len, _len1;
    copy = [];
    for (_i = 0, _len = arr.length; _i < _len; _i++) {
      item = arr[_i];
      if (Array.isArray(item)) {
        copy.push(recurse(item));
      } else if (item === curse) {
        copy.push("" + char + curse);
      } else {
        coll = '';
        for (_j = 0, _len1 = item.length; _j < _len1; _j++) {
          c = item[_j];
          if (c === curse) {
            coll += char;
          }
          coll += c;
        }
        copy.push(coll);
      }
    }
    return copy;
  };
  return store = recurse(store);
};

cancel = function() {
  var recurse;
  console.log('called to cancel');
  if (store[0] === curse) {
    return 'nothing to do';
  }
  recurse = function(arr) {
    var c, coll, copy, curse_place, item, _i, _j, _len, _len1;
    if (__indexOf.call(arr, curse) >= 0) {
      if (arr[0] === curse) {
        return curse;
      }
      curse_place = arr.indexOf(curse);
      arr = arr.slice(0, curse_place - 1).concat(arr.slice(curse_place));
      return arr;
    }
    copy = [];
    for (_i = 0, _len = arr.length; _i < _len; _i++) {
      item = arr[_i];
      if (Array.isArray(item)) {
        copy.push(recurse(item));
      } else {
        if (item[0] === curse) {
          return curse;
        }
        coll = '';
        for (_j = 0, _len1 = item.length; _j < _len1; _j++) {
          c = item[_j];
          if (c === curse) {
            coll = coll.slice(0, -1);
          }
          coll += c;
        }
        copy.push(coll);
      }
    }
    return copy;
  };
  return store = recurse(store);
};

space = function() {
  var recurse;
  recurse = function(arr) {
    var copy, curse_place, item, _i, _len;
    copy = [];
    for (_i = 0, _len = arr.length; _i < _len; _i++) {
      item = arr[_i];
      if (Array.isArray(item)) {
        copy.push(recurse(item));
      } else {
        curse_place = item.indexOf(curse);
        if (curse_place === -1) {
          copy.push(item);
        } else {
          copy.push(item.slice(0, curse_place).concat(item.slice(curse_place + 1)));
          copy.push(curse);
        }
      }
    }
    return copy;
  };
  return store = recurse(store);
};

enter = function() {
  var recurse;
  recurse = function(arr) {
    var copy, curse_place, item, _i, _len;
    if (__indexOf.call(arr, curse) >= 0) {
      return arr.map(function(x) {
        if (x === curse) {
          return [x];
        } else {
          return x;
        }
      });
    }
    copy = [];
    for (_i = 0, _len = arr.length; _i < _len; _i++) {
      item = arr[_i];
      if (Array.isArray(item)) {
        copy.push(recurse(item));
      } else {
        curse_place = item.indexOf(curse);
        if (curse_place === -1) {
          copy.push(item);
        } else {
          copy.push(item.slice(0, curse_place).concat(item.slice(curse_place + 1)));
          copy.push([curse]);
        }
      }
    }
    return copy;
  };
  return store = recurse(store);
};

blank = function() {
  return input(' ');
};

esc = function() {
  return '';
};

left = function() {
  return '';
};

right = function() {
  return '';
};

up = function() {
  return '';
};

down = function() {
  return '';
};

control = {
  '8': cancel,
  '13': enter,
  '32': space,
  '9': blank,
  '27': esc,
  '37': left,
  '39': right,
  '38': up,
  '40': down
};
