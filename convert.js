// Generated by CoffeeScript 1.3.1
var add_inputs, available_chars, blank, cancel, control, curse, down, draw, enter, esc, input, keymap, left, render_curse, right, space, store, tab, tag, up,
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

tag = function(id) {
  return document.getElementById(id);
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
    if (typeof item === 'object') {
      str += draw(item);
    } else {
      item = item.replace(curse, render_curse);
      str += "<span>" + item + "</span>";
    }
  }
  return "<div>" + str + "</div>";
};

control = {
  '8': cancel,
  '13': enter,
  '32': space,
  '9': tab,
  '27': esc,
  '37': left,
  '39': right,
  '38': up,
  '40': down
};

window.onload = function() {
  var box, nothing, refresh;
  box = tag('box');
  nothing = tag('nothing');
  nothing.focus();
  (refresh = function() {
    return box.innerHTML = draw(store);
  })();
  nothing.onkeypress = function(e) {
    var char;
    char = String.fromCharCode(e.keyCode);
    if (__indexOf.call(add_inputs, char) >= 0) {
      console.log("(" + char + ") in inputs");
      input(char);
      refresh();
    }
    return false;
  };
  return nothing.onkeydown = function(e) {
    var code;
    code = e.keyCode;
    if (control[String(code)] != null) {
      return control(String(code))();
    }
  };
};

store = ['45345', '345345', ['444\t']];

input = function(char) {
  var reverse;
  reverse = function(arr) {
    var c, coll, copy, item, _i, _j, _len, _len1;
    copy = [];
    for (_i = 0, _len = arr.length; _i < _len; _i++) {
      item = arr[_i];
      if (typeof item === 'object') {
        copy.push(reverse(item));
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
  return store = reverse(store);
};

cancel = function() {
  return '';
};

enter = function() {
  return '';
};

space = function() {
  return '';
};

blank = function() {
  return '';
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

tab = function() {
  return '';
};
