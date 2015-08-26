/* Modernizr 2.8.3 (Custom Build) | MIT & BSD
 * Build: http://modernizr.com/download/#-flexbox-generatedcontent-audio-video-touch-teststyles-testprop-testallprops-prefixes-domprefixes
 */
;
window.Modernizr = function(a, b, c) {
  function z(a) {
    i.cssText = a
  }

  function A(a, b) {
    return z(m.join(a + ";") + (b || ""))
  }

  function B(a, b) {
    return typeof a === b
  }

  function C(a, b) {
    return !!~("" + a).indexOf(b)
  }

  function D(a, b) {
    for (var d in a) {
      var e = a[d];
      if (!C(e, "-") && i[e] !== c) return b == "pfx" ? e : !0
    }
    return !1
  }

  function E(a, b, d) {
    for (var e in a) {
      var f = b[a[e]];
      if (f !== c) return d === !1 ? a[e] : B(f, "function") ? f.bind(d || b) : f
    }
    return !1
  }

  function F(a, b, c) {
    var d = a.charAt(0).toUpperCase() + a.slice(1),
      e = (a + " " + o.join(d + " ") + d).split(" ");
    return B(b, "string") || B(b, "undefined") ? D(e, b) : (e = (a + " " + p.join(d + " ") + d).split(" "), E(e, b, c))
  }
  var d = "2.8.3",
    e = {}, f = b.documentElement,
    g = "modernizr",
    h = b.createElement(g),
    i = h.style,
    j, k = ":)",
    l = {}.toString,
    m = " -webkit- -moz- -o- -ms- ".split(" "),
    n = "Webkit Moz O ms",
    o = n.split(" "),
    p = n.toLowerCase().split(" "),
    q = {}, r = {}, s = {}, t = [],
    u = t.slice,
    v, w = function(a, c, d, e) {
      var h, i, j, k, l = b.createElement("div"),
        m = b.body,
        n = m || b.createElement("body");
      if (parseInt(d, 10))
        while (d--) j = b.createElement("div"), j.id = e ? e[d] : g + (d + 1), l.appendChild(j);
      return h = ["&#173;", '<style id="s', g, '">', a, "</style>"].join(""), l.id = g, (m ? l : n).innerHTML += h, n.appendChild(l), m || (n.style.background = "", n.style.overflow = "hidden", k = f.style.overflow, f.style.overflow = "hidden", f.appendChild(n)), i = c(l, a), m ? l.parentNode.removeChild(l) : (n.parentNode.removeChild(n), f.style.overflow = k), !! i
    }, x = {}.hasOwnProperty,
    y;
  !B(x, "undefined") && !B(x.call, "undefined") ? y = function(a, b) {
    return x.call(a, b)
  } : y = function(a, b) {
    return b in a && B(a.constructor.prototype[b], "undefined")
  }, Function.prototype.bind || (Function.prototype.bind = function(b) {
    var c = this;
    if (typeof c != "function") throw new TypeError;
    var d = u.call(arguments, 1),
      e = function() {
        if (this instanceof e) {
          var a = function() {};
          a.prototype = c.prototype;
          var f = new a,
            g = c.apply(f, d.concat(u.call(arguments)));
          return Object(g) === g ? g : f
        }
        return c.apply(b, d.concat(u.call(arguments)))
      };
    return e
  }), q.flexbox = function() {
    return F("flexWrap")
  }, q.touch = function() {
    var c;
    return "ontouchstart" in a || a.DocumentTouch && b instanceof DocumentTouch ? c = !0 : w(["@media (", m.join("touch-enabled),("), g, ")", "{#modernizr{top:9px;position:absolute}}"].join(""), function(a) {
      c = a.offsetTop === 9
    }), c
  }, q.generatedcontent = function() {
    var a;
    return w(["#", g, "{font:0/0 a}#", g, ':after{content:"', k, '";visibility:hidden;font:3px/1 a}'].join(""), function(b) {
      a = b.offsetHeight >= 3
    }), a
  }, q.video = function() {
    var a = b.createElement("video"),
      c = !1;
    try {
      if (c = !! a.canPlayType) c = new Boolean(c), c.ogg = a.canPlayType('video/ogg; codecs="theora"').replace(/^no$/, ""), c.h264 = a.canPlayType('video/mp4; codecs="avc1.42E01E"').replace(/^no$/, ""), c.webm = a.canPlayType('video/webm; codecs="vp8, vorbis"').replace(/^no$/, "")
    } catch (d) {}
    return c
  }, q.audio = function() {
    var a = b.createElement("audio"),
      c = !1;
    try {
      if (c = !! a.canPlayType) c = new Boolean(c), c.ogg = a.canPlayType('audio/ogg; codecs="vorbis"').replace(/^no$/, ""), c.mp3 = a.canPlayType("audio/mpeg;").replace(/^no$/, ""), c.wav = a.canPlayType('audio/wav; codecs="1"').replace(/^no$/, ""), c.m4a = (a.canPlayType("audio/x-m4a;") || a.canPlayType("audio/aac;")).replace(/^no$/, "")
    } catch (d) {}
    return c
  };
  for (var G in q) y(q, G) && (v = G.toLowerCase(), e[v] = q[G](), t.push((e[v] ? "" : "no-") + v));
  return e.addTest = function(a, b) {
    if (typeof a == "object")
      for (var d in a) y(a, d) && e.addTest(d, a[d]);
    else {
      a = a.toLowerCase();
      if (e[a] !== c) return e;
      b = typeof b == "function" ? b() : b, typeof enableClasses != "undefined" && enableClasses && (f.className += " " + (b ? "" : "no-") + a), e[a] = b
    }
    return e
  }, z(""), h = j = null, e._version = d, e._prefixes = m, e._domPrefixes = p, e._cssomPrefixes = o, e.testProp = function(a) {
    return D([a])
  }, e.testAllProps = F, e.testStyles = w, e
}(this, this.document);
