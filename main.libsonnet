{
  local root = self,

  literal(literal): {
    type: 'literal',
    literal: literal,
    toString(indent='', break='')::
      indent + std.toString(literal),
  },

  'null': root.literal(null),
  'true': root.literal(true),
  'false': root.literal(false),
  'self': root.literal('self'),
  dollar: root.literal('$'),
  number(number): root.literal(number),

  string(string): {
    type: 'string',
    string: string,
    toString(indent='', break='')::
      indent + std.toString("'%s'" % string),
  },

  parenthesis(expr): {
    type: 'parenthesis',
    expr: expr,
    toString(indent='', break='')::
      indent + '(' + expr.toString(indent, break) + ')',
  },

  local findDuplicates(arr) =
    std.foldl(
      function(acc, i)
        acc + {
          items+: [i],
          duplicates+:
            if std.member(acc.items, i)
            then [i]
            else [],
        },
      arr,
      { items: [], duplicates: [] }
    ).duplicates,

  object: {
    members(members=[]): {
      type: 'object',
      members: members,

      local duplicates = findDuplicates(
        std.filterMap(
          function(m) 'fieldname' in m,
          function(m) m.fieldname[m.fieldname.type],
          members,
        )
      ),
      assert (
        std.length(duplicates) == 0
      ) : 'Object has duplicate fieldnames: %s' % std.manifestJson(duplicates),

      toString(indent='', break='')::
        std.join('', [
          indent,
          '{',
          break,
          std.join(
            ',' + break,
            [
              member.toString(indent + '  ', break)
              for member in members
            ]
          ),
          (if std.length(members) > 0
           then ','
           else ''),
          break,
          indent,
          '}',
        ]),
    },
    forloop(idexpr, expr, forspec, compspec=[]): {
      type: 'objforloop',
      idexpr: idexpr,
      expr: expr,
      forspec: forspec,
      compspec: compspec,
      toString(indent='', break='')::
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
      type: 'array',
      items: items,
      toString(indent='', break='')::
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
              for item in items
            ]
          ),
          break,
          indent,
          ']',
        ]),
    },
    forloop(expr, forspec, compspec=[]): {
      type: 'forloop',
      expr: expr,
      forspec: forspec,
      compspec: compspec,
      toString(indent='', break='')::
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

  fieldaccess(exprs, id): {
    type: 'fieldaccess',
    exprs: exprs,
    id: id,
    toString(indent='', break='')::
      std.join(
        '.',
        [
          expr.toString(indent, break)
          for expr in exprs
        ]
        + [
          id.toString(),
        ]
      ),
  },

  indexing(expr, exprs=[]): {
    type: 'indexing',
    expr: expr,
    exprs: exprs,

    assert std.length(exprs) > 0,
    assert std.length(exprs) < 4,

    toString(indent='', break='')::
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

  fieldaccess_super(id): {
    type: 'fieldaccess_super',
    id: id,
    toString(indent='', break='')::
      indent + 'super.' + id.toString(),
  },
  indexing_super(expr): {
    type: 'indexing_super',
    expr: expr,
    toString(indent='', break='')::
      indent + 'super[' + expr.toString() + ']',
  },

  functioncall(expr, args=[]): {
    type: 'functioncall',
    expr: expr,
    args: args,
    toString(indent='', break='')::
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

  id(id): {
    type: 'id',
    id: id,
    toString(indent='', break='')::
      (if break != ''
       then '    '
       else '') +
      indent
      + std.toString(id),
  },

  localbind(bind, expr, binds=[]): {
    type: 'localbind',
    bind: bind,
    expr: expr,
    binds: binds,
    toString(indent='', break='')::
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
    type: 'conditional',
    ifexpr: ifexpr,
    thenexpr: thenexpr,
    elseexpr: elseexpr,
    toString(indent='', break='')::
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

  binary(sign, exprs=[]): {
    type: 'binary',
    sign: sign,
    exprs: exprs,
    toString(indent='', break='')::
      indent
      + std.join(
        ' ' + sign + ' ',
        [
          expr.toString()
          + (if std.length(exprs) > 2
             then break + indent + ' '
             else '')
          for expr in exprs
        ]
      ),
  },

  unary(sign, expr): {
    type: 'unary',
    sign: sign,
    expr: expr,
    toString(indent='', break='')::
      sign
      + expr.toString(indent, break),
  },

  anonymousfunction(expr, params=[]): {
    type: 'anonymousfunction',
    expr: expr,
    params: params,
    toString(indent='', break='')::
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

  assertion_expr(assertion, expr): {
    type: 'assertion_expr',
    assertion: assertion,
    expr: expr,
    toString(indent='', break='')::
      std.join(';', [
        assertion.toString(indent, break),
        expr.toString(indent, break),
      ]),
  },

  _import(path, type): {
    type: type,
    path: path,
    toString(indent='', break='')::
      std.join('', [
        indent,
        type,
        ' ',
        root.path(path).toString(),
      ]),
  },
  importF(path): self._import(path, 'import'),
  importstrF(path): self._import(path, 'importstr'),
  importbinF(path): self._import(path, 'importbin'),

  err(expr): {
    type: 'err',
    expr: expr,
    toString(indent='', break='')::
      indent
      + 'error '
      + expr.toString(indent, break),
  },

  expr_in_super(expr): {
    type: 'expr_in_super',
    expr: expr,
    toString(indent='', break='')::
      expr.toString(indent, break)
      + ' in super',
  },

  member: {
    objlocal: root.objlocal,
    assertion: root.assertion,
    field: root.field,
  },

  field: {
    field(fieldname, expr, additive=false, hidden=false, nobreak=false): {
      type: 'field',
      fieldname: fieldname,
      expr: expr,
      additive: additive,
      hidden: hidden,

      toString(indent='', break='')::
        std.join('', [
          indent,
          fieldname.toString(),
          (if additive
           then '+'
           else ''),
          (if hidden
           then '::'
           else ':'),
          (if nobreak
           then ''
           else break),
          expr.toString(indent + '  ', break),
        ]),
    },
    func(fieldname, expr, params=[], hidden=false, nobreak=false): {
      type: 'function',
      fieldname: fieldname,
      expr: expr,
      params: params,
      hidden: hidden,

      toString(indent='', break='')::
        std.join('', [
          indent,
          fieldname.toString(),
          '(',
          root.params(params).toString(),
          ')',
          (if hidden
           then '::'
           else ':'),
          (if nobreak
           then ''
           else break),
          indent,
          expr.toString(indent + '  ', break),
        ]),
    },
  },

  objlocal(bind): {
    type: 'objlocal',
    bind: bind,
    toString(indent='', break='')::
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
    type: 'forspec',
    id: id,
    expr: expr,
    toString(indent)::
      indent
      + std.join(' ', [
        'for',
        id.toString(),
        'in',
        expr.toString(),
      ]),
  },

  ifspec(expr): {
    type: 'ifspec',
    expr: expr,
    toString(indent='')::
      indent + 'if ' + expr.toString(),
  },

  fieldname: {
    id: root.id,
    string: root.string,
    expr(expr): {
      type: 'fieldnameexpr',
      expr: expr,
      toString():: '[%s]' % expr.toString(),
    },
  },

  assertion(expr, return=null): {
    type: 'assertion',
    expr: expr,
    return: return,
    toString(indent='', break='')::
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
      type: 'bind',
      id: id,
      expr: expr,
      toString(indent='', break='')::
        std.join('', [
          id.toString(),
          '=',
          expr.toString(),
        ]),
    },
    func(id, expr, params=[]): {
      type: 'func',
      id: id,
      expr: expr,
      params: params,
      toString(indent='', break='')::
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
      type: 'argid',
      id: id,
      expr: expr,
      toString()::
        std.join('', [
          id.toString(),
          '=',
          expr.toString(''),
        ]),
    },
  },

  params(params): {
    type: 'params',
    params: params,
    toString()::
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
      type: 'paramexpr',
      id: id,
      expr: expr,
      toString()::
        std.join('', [
          id.toString(),
          '=',
          expr.toString(''),
        ]),
    },
  },
}
