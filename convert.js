// Generated by CoffeeScript 1.3.1
var add_inputs, available_chars, blank, cancel, cancel_recursion, choose_version, control, copy_recursion, ctrl_copy, ctrl_cut, ctrl_paste, current, current_version, cursor, cut_recursion, down, down_recursion, draw, editor_mode, end, enter, enter_recursion, esc, go_ahead, go_back, history, history_generator, history_reset, home, home_recursion, input, input_recursion, keymap, left, left_recursion, left_step, left_step_recursion, ll, new_footer, output, pair_num, paste_recursion, pgdown, pgup, pgup_recursion, remove, remove_recursion, render_cursor, reverse, reverse_action, right, right_step, run_code, save_version, snippet, source, space, space_recursion, stemp, store, tag, up, version_cursor, version_map, view_recursion, view_version,
  __slice = [].slice,
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

tag = function(id) {
  return document.getElementById(id);
};

new_footer = function() {
  return document.createElement('footer');
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

available_chars += '~`_-+=-[]{}\\|:;"\',.<>/?';

add_inputs = available_chars.split('');

cursor = '\t';

render_cursor = '<nav>&nbsp;</nav>';

draw = function(arr) {
  var inline_block, item, now_level, str, _i, _len;
  str = '';
  now_level = '';
  for (_i = 0, _len = arr.length; _i < _len; _i++) {
    item = arr[_i];
    if (Array.isArray(item)) {
      str += draw(item);
    } else if (item === cursor) {
      str += render_cursor;
      now_level = ' id="now_level"';
    } else {
      if ((item.indexOf(cursor)) >= 0) {
        now_level = ' id="now_level"';
      }
      item = item.replace(cursor, render_cursor).replace(/\s/g, '<span class="appear">&nbsp;</span>');
      str += "<code>" + item + "</code>";
    }
  }
  inline_block = '';
  if (arr.toString().length < 15) {
    inline_block = ' class="inline_block"';
  }
  return "<div" + inline_block + now_level + ">" + str + "</div>";
};

editor_mode = true;

store = ['\t'];

history = [store];

current = 0;

history_generator = function() {
  history = history.slice(0, current + 1 || 9e9);
  history.push(store);
  return current += 1;
};

window.onload = function() {
  var box, refresh;
  box = tag('box');
  window.focus();
  (refresh = function() {
    return box.innerHTML = draw(store);
  })();
  document.onkeypress = function(e) {
    var char;
    if (!editor_mode) {
      return 'locked';
    }
    char = String.fromCharCode(e.keyCode);
    if (!(e.ctrlKey || e.altKey)) {
      if (__indexOf.call(add_inputs, char) >= 0) {
        input(char);
        refresh();
        history_generator();
      }
      return false;
    }
  };
  return document.onkeydown = function(e) {
    var code, send_back;
    code = e.keyCode;
    console.log(code);
    if (!editor_mode) {
      if (code !== 27) {
        return 'locked';
      }
    }
    if (!(e.ctrlKey || e.altKey)) {
      if (control['' + code] != null) {
        send_back = control['' + code]();
        if (send_back !== 'stay') {
          refresh();
          history_generator();
        }
        return false;
      }
    }
    if (e.ctrlKey && (!e.altKey)) {
      if (control['c_' + code] != null) {
        send_back = control['c_' + code]();
        if (send_back !== 'stay') {
          refresh();
          history_generator();
        }
        return false;
      }
    }
  };
};

input_recursion = function(arr, char) {
  var c, coll, copy, item, _i, _j, _len, _len1;
  copy = [];
  for (_i = 0, _len = arr.length; _i < _len; _i++) {
    item = arr[_i];
    if (Array.isArray(item)) {
      copy.push(input_recursion(item, char));
    } else if (item === cursor) {
      copy.push("" + char + cursor);
    } else {
      coll = '';
      for (_j = 0, _len1 = item.length; _j < _len1; _j++) {
        c = item[_j];
        if (c === cursor) {
          coll += char;
        }
        coll += c;
      }
      copy.push(coll);
    }
  }
  return copy;
};

input = function(char) {
  return store = input_recursion(store, char);
};

cancel_recursion = function(arr) {
  var copy, item, point, _i, _len;
  point = arr.indexOf(cursor);
  if (point !== -1) {
    if (point === 0) {
      return arr;
    }
    arr = arr.slice(0, point - 1).concat(arr.slice(point));
    return arr;
  }
  copy = [];
  for (_i = 0, _len = arr.length; _i < _len; _i++) {
    item = arr[_i];
    if (Array.isArray(item)) {
      copy.push(cancel_recursion(item));
    } else {
      point = item.indexOf(cursor);
      if (point === -1) {
        copy.push(item);
      } else if (point === 0) {
        copy.push(cursor);
      } else {
        copy.push("" + item.slice(0, point - 1) + item.slice(point));
      }
    }
  }
  return copy;
};

cancel = function() {
  if (store[0] === cursor) {
    return 'skip';
  }
  return store = cancel_recursion(store);
};

space_recursion = function(arr) {
  var copy, item, _i, _len;
  copy = [];
  for (_i = 0, _len = arr.length; _i < _len; _i++) {
    item = arr[_i];
    if (Array.isArray(item)) {
      copy.push(space_recursion(item));
    } else {
      if ((item.indexOf(cursor)) === -1) {
        copy.push(item);
      } else {
        copy.push(item.replace(cursor, ''), cursor);
      }
    }
  }
  return copy;
};

space = function() {
  return store = space_recursion(store);
};

enter_recursion = function(arr) {
  var copy, item, point, _i, _len;
  if (__indexOf.call(arr, cursor) >= 0) {
    return arr.map(function(x) {
      if (x === cursor) {
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
      copy.push(enter_recursion(item));
    } else {
      point = item.indexOf(cursor);
      if (point === -1) {
        copy.push(item);
      } else {
        copy.push(item.replace(cursor, ''), [cursor]);
      }
    }
  }
  return copy;
};

enter = function() {
  return store = enter_recursion(store);
};

blank = function() {
  return input(' ');
};

pgup_recursion = function(arr) {
  var copy, item, last_item, _i, _len;
  copy = [];
  for (_i = 0, _len = arr.length; _i < _len; _i++) {
    item = arr[_i];
    if (Array.isArray(item)) {
      if (item[0] === cursor) {
        copy.push(cursor);
        if (item.length > 1) {
          copy.push(item.slice(1));
        }
      } else {
        copy.push(pgup_recursion(item));
      }
    } else if (item === cursor) {
      last_item = copy.pop();
      if (Array.isArray(last_item)) {
        last_item.push(cursor);
        copy.push(last_item);
      } else {
        copy.push(cursor, last_item);
      }
    } else {
      if (item.indexOf(cursor) < 0) {
        copy.push(item);
      } else {
        copy.push(cursor, item.replace(cursor, ''));
      }
    }
  }
  return copy;
};

pgup = function() {
  if (store[0] === cursor) {
    return 'skip';
  }
  return store = pgup_recursion(store);
};

pgdown = function() {
  store = reverse(store);
  pgup();
  return store = reverse(store);
};

home_recursion = function(arr) {
  var copy, find_cursor, item, _i, _len;
  if (__indexOf.call(arr, cursor) >= 0 && (arr[0] !== cursor)) {
    return [cursor].concat(arr.filter(function(x) {
      return x !== cursor;
    }));
  }
  copy = [];
  for (_i = 0, _len = arr.length; _i < _len; _i++) {
    item = arr[_i];
    if (item[0] === cursor) {
      copy.push(cursor);
      if (item.length > 1) {
        copy.push(item.slice(1));
      }
    } else {
      if (Array.isArray(item)) {
        copy.push(home_recursion(item));
      } else {
        find_cursor = item.match(new RegExp(cursor));
        if (find_cursor != null) {
          copy.push("" + cursor + (item.replace(cursor, '')));
        } else {
          copy.push(item);
        }
      }
    }
  }
  return copy;
};

home = function() {
  if ((store[0] != null) && store[0] === cursor) {
    return 'nothing to do';
  }
  return store = home_recursion(store);
};

reverse = function(arr) {
  return arr.reverse().map(function(item) {
    if (Array.isArray(item)) {
      return reverse(item);
    } else {
      return item.split('').reverse().join('');
    }
  });
};

reverse_action = function(action) {
  store = reverse(store);
  action();
  return store = reverse(store);
};

end = function() {
  return reverse_action(home);
};

remove_recursion = function(arr) {
  return arr.map(function(x) {
    if (Array.isArray(x)) {
      if (__indexOf.call(x, cursor) >= 0) {
        return cursor;
      } else {
        return remove_recursion(x);
      }
    } else {
      if ((x.indexOf(cursor)) === -1) {
        return x;
      } else {
        return cursor;
      }
    }
  });
};

remove = function() {
  if (__indexOf.call(store, cursor) >= 0) {
    store = [cursor];
    return 'done';
  }
  return store = remove_recursion(store);
};

left_recursion = function(arr) {
  var copy, item, last_item, part_a, part_b, point, _i, _len;
  copy = [];
  for (_i = 0, _len = arr.length; _i < _len; _i++) {
    item = arr[_i];
    if (Array.isArray(item)) {
      if (item[0] === cursor) {
        copy.push(cursor);
        if (item.length > 1) {
          copy.push(item.slice(1));
        }
      } else {
        copy.push(left_recursion(item));
      }
    } else if (item === cursor) {
      last_item = copy.pop();
      if (Array.isArray(last_item)) {
        last_item.push(cursor);
        copy.push(last_item);
      } else {
        copy.push("" + last_item + cursor);
      }
    } else {
      if (item[0] === cursor) {
        copy.push(cursor);
        if (item.length > 1) {
          copy.push(item.slice(1));
        }
      } else {
        point = item.indexOf(cursor);
        if (point < 0) {
          copy.push(item);
        } else {
          part_a = "" + item.slice(0, point - 1) + cursor;
          part_b = "" + item[point - 1] + item.slice(point + 1);
          copy.push("" + part_a + part_b);
        }
      }
    }
  }
  return copy;
};

left = function() {
  if (store[0] === cursor) {
    return 'skip';
  }
  return store = left_recursion(store);
};

right = function() {
  return reverse_action(left);
};

down_recursion = function(arr) {
  var copy, has_cursor, item, obj, _i, _len;
  copy = [];
  has_cursor = false;
  for (_i = 0, _len = arr.length; _i < _len; _i++) {
    item = arr[_i];
    if (item === cursor || item === [cursor]) {
      has_cursor = true;
    } else if (typeof item === 'string') {
      if (item.match(new RegExp(cursor)) != null) {
        copy.push(item.replace(cursor, ''));
        has_cursor = true;
      } else {
        copy.push(item);
      }
    } else {
      if (has_cursor) {
        item.unshift(cursor);
        copy.push(item);
        has_cursor = false;
      } else {
        obj = down_recursion(item);
        copy.push(obj.value);
        if (obj.has_cursor) {
          copy.push(cursor);
        }
      }
    }
  }
  return obj = {
    value: copy,
    has_cursor: has_cursor
  };
};

down = function() {
  var copy_tail, item, _i, _len;
  copy_tail = store.concat().reverse();
  for (_i = 0, _len = copy_tail.length; _i < _len; _i++) {
    item = copy_tail[_i];
    if (Array.isArray(item)) {
      break;
    }
    if (item === cursor || item === [cursor]) {
      return 'skip';
    }
    if ((item.indexOf(cursor)) !== -1) {
      return 'skip';
    }
  }
  return store = (down_recursion(store)).value;
};

up = function() {
  return reverse_action(down);
};

left_step_recursion = function(arr) {
  var copy, item, last_item, _i, _len;
  if (arr[0] === cursor) {
    return arr;
  }
  copy = [];
  for (_i = 0, _len = arr.length; _i < _len; _i++) {
    item = arr[_i];
    if (Array.isArray(item)) {
      copy.push(left_step_recursion(item));
    } else if (item === cursor) {
      last_item = copy.pop();
      copy.push(cursor, last_item);
    } else {
      if ((item.indexOf(cursor)) === -1) {
        copy.push(item);
      } else {
        copy.push(cursor, item.replace(cursor, ''));
      }
    }
  }
  return copy;
};

left_step = function() {
  return store = left_step_recursion(store);
};

right_step = function() {
  return reverse_action(left_step);
};

snippet = null;

copy_recursion = function(arr) {
  var item, _i, _len, _results;
  _results = [];
  for (_i = 0, _len = arr.length; _i < _len; _i++) {
    item = arr[_i];
    if (Array.isArray(item)) {
      if (__indexOf.call(item, cursor) >= 0) {
        _results.push(snippet = item.filter(function(x) {
          return x !== cursor;
        }));
      } else {
        _results.push(copy_recursion(item));
      }
    } else if (item.indexOf(cursor) >= 0) {
      _results.push(snippet = item.replace(cursor, ''));
    } else {
      _results.push(void 0);
    }
  }
  return _results;
};

ctrl_copy = function() {
  return copy_recursion(store);
};

cut_recursion = function(arr) {
  console.log(arr);
  return arr.map(function(item) {
    if (Array.isArray(item)) {
      if (__indexOf.call(item, cursor) >= 0) {
        snippet = item.filter(function(x) {
          return x !== cursor;
        });
        return cursor;
      } else {
        return cut_recursion(item);
      }
    } else {
      if ((item.indexOf(cursor)) < 0) {
        return item;
      } else {
        snippet = item.replace(cursor, '');
        return cursor;
      }
    }
  });
};

ctrl_cut = function() {
  if (__indexOf.call(store, cursor) >= 0) {
    return skip;
  }
  return store = cut_recursion(store);
};

paste_recursion = function(arr) {
  var copy, item, _i, _len;
  copy = [];
  for (_i = 0, _len = arr.length; _i < _len; _i++) {
    item = arr[_i];
    if (Array.isArray(item)) {
      copy.push(paste_recursion(item));
    } else if (item === cursor) {
      copy.push(snippet, cursor);
    } else if ((item.indexOf(cursor)) < 0) {
      copy.push(item);
    } else {
      copy.push(snippet, item);
    }
  }
  return copy;
};

ctrl_paste = function() {
  if (snippet != null) {
    return store = paste_recursion(store);
  }
};

version_map = {
  store: store,
  stemp: '000000 00:00',
  child: [cursor],
  commit: '/'
};

version_cursor = version_map;

pair_num = function(num) {
  if (num < 10) {
    return '0' + (String(num));
  } else {
    return String(num);
  }
};

stemp = function() {
  var date, date_obj, hour, minute, month, year;
  date_obj = new Date();
  year = (String(date_obj.getFullYear())).slice(2, 4);
  month = pair_num(date_obj.getMonth() + 1);
  date = pair_num(date_obj.getDate());
  hour = pair_num(date_obj.getHours());
  minute = pair_num(date_obj.getMinutes());
  return "" + year + month + date + " " + hour + ":" + minute;
};

history_reset = function() {
  history = [store];
  return current = 0;
};

save_version = function() {
  var last_item;
  version_cursor.child.pop();
  version_cursor.child.push({
    store: store,
    stemp: stemp(),
    child: [],
    commit: prompt('add phrase to commit') || 'Save'
  });
  last_item = version_cursor.child;
  version_cursor = version_cursor.child[last_item.length - 1];
  version_cursor.child.push(cursor);
  history_reset();
  return 'stay';
};

choose_version = function(new_version_cursor) {
  version_cursor.child.pop();
  version_cursor = new_version_cursor;
  store = version_cursor.store;
  version_cursor.child.push(cursor);
  history_reset();
  return view_version();
};

current_version = document.createElement('header');

current_version.innerHTML = 'current';

view_recursion = function(obj) {
  var footer;
  if (obj === cursor) {
    return current_version;
  }
  if (obj.commit != null) {
    footer = new_footer();
    footer.onclick = function(e) {
      choose_version(obj);
      e.stopPropagation();
      return false;
    };
    footer.innerHTML += "" + obj.commit + "<br>";
    footer.innerHTML += "<span>" + obj.stemp + "</span><br>";
    obj.child.forEach(function(item) {
      var result;
      result = view_recursion(item);
      return footer.appendChild(result);
    });
  }
  return footer;
};

view_version = function() {
  tag('box').innerHTML = '';
  tag('box').appendChild(view_recursion(version_map));
  return 'stay';
};

esc = function() {
  if (editor_mode) {
    view_version();
    editor_mode = false;
  } else {
    (tag('box')).innerHTML = draw(store);
    editor_mode = true;
  }
  return 'stay';
};

go_ahead = function() {
  if (history[current + 1] != null) {
    store = history[current + 1];
    current += 1;
    (tag('box')).innerHTML = draw(store);
  }
  return 'stay';
};

go_back = function() {
  console.log('current: ', current);
  if (history[current - 1] != null) {
    store = history[current - 1];
    current -= 1;
    (tag('box')).innerHTML = draw(store);
  }
  return 'stay';
};

source = function(arr) {
  var copy, item, _i, _len;
  copy = [];
  for (_i = 0, _len = arr.length; _i < _len; _i++) {
    item = arr[_i];
    if (item === cursor || item === [cursor]) {
      continue;
    } else if (Array.isArray(item)) {
      copy.push(source(item));
    } else if ((item.indexOf(cursor)) === -1) {
      copy.push(item);
    } else {
      copy.push(item.replace(cursor, ''));
    }
  }
  return copy;
};

output = [];

run_code = function() {
  var item, _i, _len, _ref;
  output = [];
  console.log(source(store));
  _ref = source(store);
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    item = _ref[_i];
    run(item);
  }
  output = output.map(function(item) {
    return item.replace(/\s/g, '&nbsp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
  }).join('<br>');
  console.log('output', output);
  (tag('box')).innerHTML = "<div id='result'>" + output + "</div>";
  editor_mode = false;
  return 'stay';
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
  '40': down,
  '36': home,
  '35': end,
  '46': remove,
  '33': pgup,
  '34': pgdown,
  'c_37': left_step,
  'c_39': right_step,
  'c_67': ctrl_copy,
  'c_88': ctrl_cut,
  'c_80': ctrl_paste,
  'c_83': save_version,
  'c_90': go_back,
  'c_89': go_ahead,
  'c_69': run_code
};
