Elm.Native.Lazy = {};
Elm.Native.Lazy.make = function(elm)
{
  elm.Native = elm.Native || {};
  elm.Native.Lazy = elm.Native.Lazy || {};
  if (elm.Native.Lazy.values)
  {
    return elm.Native.Lazy.values;
  }

  // LAZINESS

  function lazyRef(fn, a, addr)
  {
    function thunk()
    {
      return A2(fn, a, addr);
    }
    return new Thunk(fn, [a], thunk);
  }

  function lazyRef2(fn, a, b, addr)
  {
    function thunk()
    {
      return A3(fn, a, b, addr);
    }
    return new Thunk(fn, [a,b], thunk);
  }

  function lazyRef3(fn, a, b, c, addr)
  {
    function thunk()
    {
      return A4(fn, a, b, c, addr);
    }
    return new Thunk(fn, [a,b,c], thunk);
  }

  function Thunk(fn, args, thunk)
  {
    /* public (used by VirtualDom.js) */
    this.vnode = null;
    this.key = undefined;

    /* private */
    this.fn = fn;
    this.args = args;
    this.thunk = thunk;
  }

  Thunk.prototype.type = "Thunk";
  Thunk.prototype.render = renderThunk;

  function shouldUpdate(current, previous)
  {
    if (current.fn !== previous.fn)
    {
      return true;
    }

    // if it's the same function, we know the number of args must match
    var cargs = current.args;
    var pargs = previous.args;

    for (var i = cargs.length; i--; )
    {
      if (cargs[i] !== pargs[i])
      {
        return true;
      }
    }

    return false;
  }

  function renderThunk(previous)
  {
    if (previous == null || shouldUpdate(this, previous))
    {
      return this.thunk();
    }
    else
    {
      return previous.vnode;
    }
  }

  return elm.Native.Lazy.values = Elm.Native.Lazy.values = {
    lazy: F3(lazyRef),
    lazy2: F4(lazyRef2),
    lazy3: F5(lazyRef3),
  };
};
