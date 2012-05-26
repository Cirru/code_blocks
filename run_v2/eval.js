// Generated by CoffeeScript 1.3.3
var echo, err, read, run, runit, scope_new, scope_zero;

echo = function(item) {
  return output.push(String(item));
};

err = function(str) {
  throw new Error(str);
};

scope_zero = {
  here: {},
  seek: function(key) {
    if (this.here[key] != null) {
      return this.here;
    } else {
      return void 0;
    }
  }
};

scope_new = function(parent) {
  var obj;
  return obj = {
    here: {},
    parent: parent,
    seek: function(key) {
      if (this.here[key] != null) {
        return this.here;
      } else {
        return this.parent.seek(key);
      }
    }
  };
};

runit = function(scope, arr) {
  var here;
  here = scope.seek(arr[0]);
  if (here == null) {
    console.log(arr);
    return err('no function found');
  } else {
    return here[arr[0]](scope, arr.slice(1));
  }
};

read = function(scope, x) {
  var here;
  if (Array.isArray(x)) {
    return runit(scope, x);
  } else {
    here = (scope.seek(x)) || scope.here;
    return here[x];
  }
};

scope_zero.here = {
  set: function(scope, v) {
    var here;
    here = (scope.seek(v[0])) || scope.here;
    if (v.length === 2) {
      return here[v[0]] = read(scope, v[1]);
    } else {
      return here[v[0]] = v.slice(1).map(function(x) {
        return read(scope, x);
      });
    }
  },
  echo: function(scope, v) {
    v = v.map(function(x) {
      return read(scope, x);
    });
    echo.apply(console, v);
    return v;
  },
  '+': function(scope, v) {
    return v.map(function(x) {
      return read(scope, x);
    }).reduce(function(x, y) {
      return (Number(x)) + (Number(y));
    });
  },
  '-': function(scope, v) {
    return v.map(function(x) {
      return read(scope, x);
    }).reduce(function(x, y) {
      return x - y;
    });
  },
  number: function(scope, v) {
    v = v.map(function(x) {
      return Number(x);
    });
    if (v.length === 1) {
      return v[0];
    } else {
      return v;
    }
  },
  string: function(scope, v) {
    return v.join(' ');
  },
  def: function(scope, v) {
    var here;
    here = (scope.seek(v[0])) || scope.here;
    return here[v[0]] = function(scope_in, arr) {
      var exp, index, item, scope_sub, _i, _j, _len, _len1, _ref, _ref1, _results;
      scope_sub = scope_new(scope);
      _ref = v[1];
      for (index = _i = 0, _len = _ref.length; _i < _len; index = ++_i) {
        item = _ref[index];
        scope_sub.here[item] = read(scope_in, arr[index]);
      }
      _ref1 = v.slice(2);
      _results = [];
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        exp = _ref1[_j];
        _results.push(runit(scope_sub, exp));
      }
      return _results;
    };
  },
  "if": function(scope, v) {
    if (runit(scope, v[0])) {
      return runit(scope, v[1]);
    } else {
      return runit(scope, v[2]);
    }
  },
  '>': function(scope, v) {
    var base, item, _i, _len;
    v = v.map(function(x) {
      return read(scope, x);
    });
    base = v.shift();
    for (_i = 0, _len = v.length; _i < _len; _i++) {
      item = v[_i];
      if (base <= item) {
        return false;
      }
      base = item;
    }
    return true;
  }
};

run = function(arr) {
  return runit(scope_zero, arr);
};
