{
  local root = self,

  'null': { toString(indent='', break=''): indent + 'null' },
  'true': { toString(indent='', break=''): indent + 'true' },
  'false': { toString(indent='', break=''): indent + 'false' },
  'self': { toString(indent='', break=''): indent + 'self' },
  dollar: { toString(indent='', break=''): indent + '$' },
  string(string): { toString(indent='', break=''): indent + "'%s'" % string },
  number(number): { toString(indent='', break=''): indent + '%s' % std.manifestJson(number) },

  object: {
    members(members=[]): {
      members: members,
      toString(indent='', break=''):
        std.join('', [
          indent,
          '{',
          break,
          std.join(
            ',' + break,
            [
              member.toString(indent + '  ', break)
              for member in self.members
            ]
          ),
          (if std.length(self.members) > 0
           then ','
           else ''),
          break,
          indent,
          '}',
        ]),
    },
    forloop(idexpr, expr, forspec, compspec=[]): {
      toString(indent='', break=''):
        indent
        + std.join(
          break + indent,
          [
            '{',
            root.field.field(
              root.fieldname.expr(idexpr),
              expr,
            ).toString(indent, break),
            forspec.toString(indent),
          ]
          + [
            spec.toString(indent)
            for spec in compspec
          ]
          + ['}'],
        ),
    },
  },

  array: {
    items(items=[]): {
      items: items,
      toString(indent='', break=''):
        std.join('', [
          indent,
          '[',
          break,
          std.join(
            ',' + break, [
              item.toString(
                (if break != ''
                 then indent + '  '
                 else indent),
                break,
              )
              for item in self.items
            ]
          ),
          break,
          indent,
          ']',
        ]),
    },
    forloop(expr, forspec, compspec=[]): {
      toString(indent='', break=''):
        std.join(
          '\n' + indent,
          [
            indent + '[',
            expr.toString(indent),
            forspec.toString(indent),
          ]
          + [
            spec.toString(indent)
            for spec in compspec
          ]
          + [']'],
        ),
    },
  },

  fieldaccess(expr, id): {
    toString(indent='', break=''):
      std.join('.', [
        expr.toString(indent, break),
        id.toString(),
      ]),
  },

  indexing(expr, exprs=[]): {
    assert std.length(exprs) > 0,
    assert std.length(exprs) < 4,

    toString(indent='', break=''):
      std.join('', [
        expr.toString(indent),
        '[',
        std.join(':', [
          e.toString()
          for e in exprs
        ]),
        ']',
      ]),
  },

  'super': {
    id(id): { toString(indent='', break=''): indent + 'super.' + id.toString() },
    expr(expr): { toString(indent='', break=''): indent + 'super' + expr.toString() },
  },

  functioncall(expr, args=[]): {
    toString(indent='', break=''):
      indent
      + std.join('', [
        expr.toString(),
        '(',
        std.join(', ', [
          arg.toString()
          for arg in args
        ]),
        ')',
      ]),
  },

  id(string): {
    toString(indent='', break=''):
      (if break != ''
       then '    '
       else '') +
      indent
      + std.toString(string),
  },

  localbind(bind, expr, binds=[]): {
    toString(indent='', break=''):
      indent
      + std.join(
        '', [
          'local ',
          std.join(
            ',' + break, [
              b.toString(indent, break)
              for b in [bind] + binds
            ]
          ),
          ';',
          break,
          expr.toString(indent, break),
        ]
      ),
  },

  conditional(ifexpr, thenexpr, elseexpr=null): {
    toString(indent='', break=''):
      std.join(
        '',
        [
          indent,
          '(if ',
          ifexpr.toString(),
          '\n',
          indent,
          ' then ',
          thenexpr.toString(),
        ]
        + (if elseexpr != null
           then [
             '\n',
             indent,
             ' else ',
             elseexpr.toString(),
           ]
           else [])
        + [')']
      ),
  },

  binary(sign, expr1, expr2): {
    toString(indent='', break=''):
      std.join(' ', [
        expr1.toString(indent, break),
        sign,
        expr2.toString(indent, break),
      ]),
  },

  unary(sign, expr): {
    toString(indent='', break=''):
      std.join('', [
        sign,
        expr.toString(indent, break),
      ]),
  },

  anonymousfunction(expr, params=[]): {
    toString(indent='', break=''):
      std.join('', [
        indent,
        'function',
        '(',
        root.params(params).toString(),
        ')',
        break,
        expr.toString(indent + '  ', break),
      ]),
  },

  _assertion_expr(assertion, expr): {
    toString(indent='', break=''):
      std.join(';', [
        assertion.toString(indent, break),
        expr.toString(indent, break),
      ]),
  },

  importF(string): { toString(indent='', break=''): indent + 'import ' + string },
  importstrF(string): { toString(indent='', break=''): indent + 'importstr ' + string },
  importbinF(string): { toString(indent='', break=''): indent + 'importbin ' + string },

  err(expr): {
    toString(indent='', break=''):
      indent
      + 'error '
      + expr.toString(indent, break),
  },

  expr_in_super(expr): {
    toString(indent='', break=''):
      expr.toString(indent, break)
      + ' in super',
  },

  member: {
    objlocal: root.objlocal,
    assertion: root.assertion,
    field: root.field,
  },

  field: {
    field(fieldname, expr, additive=false, hidden=false): {
      toString(indent='', break=''):
        std.join('', [
          indent,
          fieldname.toString(),
          (if additive
           then '+'
           else ''),
          (if hidden
           then '::'
           else ':'),
          break,
          expr.toString(indent + '  ', break),
        ]),
    },
    func(fieldname, expr, params=[], hidden=false): {
      toString(indent='', break=''):
        std.join('', [
          indent,
          fieldname.toString(),
          '(',
          root.params(params).toString(),
          ')',
          (if hidden
           then '::'
           else ':'),
          break,
          indent,
          expr.toString(indent + '  ', break),
        ]),
    },
  },

  objlocal(bind): {
    toString(indent='', break=''):
      indent
      + std.join(' ', [
        'local',
        bind.toString(indent, break),
      ]),
  },

  compspec: {
    forspec: root.forspec,
    ifspec: root.ifspec,
  },

  forspec(id, expr): {
    toString(indent):
      indent
      + std.join(' ', [
        'for',
        id.toString(),
        'in',
        expr.toString(),
      ]),
  },

  ifspec(expr): {
    toString(indent=''): indent + 'if ' + expr.toString(),
  },

  fieldname: {
    id: root.id,
    string: root.string,
    expr(expr): {
      toString(): '[%s]' % expr.toString(),
    },
  },

  assertion(expr, return=null): {
    toString(indent='', break=''):
      std.join(
        ' ',
        [
          'assert',
          expr.toString(),
          ':',
        ]
        + (if return != null
           then [return.toString()]
           else [])
      ),
  },

  bind: {
    bind(id, expr): {
      toString(indent='', break=''):
        std.join('', [
          id.toString(),
          '=',
          expr.toString(),
        ]),
    },
    func(id, expr, params=[]): {
      toString(indent='', break=''):
        std.join('', [
          id.toString(),
          '(',
          root.params(params).toString(),
          ')',
          '=',
          break,
          expr.toString(indent + '  ', break),
        ]),
    },
  },

  arg: {
    expr(expr): expr,
    id(id, expr): {
      toString():
        std.join('', [
          id.toString(),
          '=',
          expr.toString(''),
        ]),
    },
  },

  params(params): {
    toString():
      std.join(
        ', ',
        [
          param.toString()
          for param in params
        ]
      ),
  },

  param: {
    id: root.id,
    expr(id, expr): {
      toString():
        std.join('', [
          id.toString(),
          '=',
          expr.toString(''),
        ]),
    },
  },
}