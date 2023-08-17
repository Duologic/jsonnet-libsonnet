local j = {
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
              m.toString(indent + '  ', break)
              for m in self.members
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
        std.join(
          '\n' + indent,
          [
            indent + '{',
            root.field.field(
              root.fieldname.expr(idexpr),
              expr,
            ).toString(indent),
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
                indent
                + (if break != ''
                   then '  '
                   else ''),
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
            expr.toString(indent, break),
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
    toString(indent=''):
      std.join('.', [
        expr.toString(indent),
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
    toString(indent='', break=''): indent + std.toString(string),
  },

  localbind: {},

  // TODO
  // local bind { , bind } ; expr
  // if expr then expr [ else expr ]
  // expr binaryop expr
  // unaryop expr
  // expr { objinside }
  // function ( [ params ] ) expr
  // assert ; expr
  // import string
  // importstr string
  // importbin string
  // error expr
  // expr in super

  member: {
    objlocal: {},
    'assert': {},
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
          expr.toString(
            indent
            + (if break != ''
               then '  '
               else ''),
            break,
          ),
        ]),
    },
    func(fieldname, expr, params=[], hidden=false): {
      toString(indent='', break=''):
        std.join('', [
          indent,
          fieldname.toString(),
          '(',
          std.join(
            ', ',
            [
              param.toString()
              for param in params
            ]
          ),
          ')',
          (if hidden
           then '::'
           else ':'),
          break,
          expr.toString(indent + '  ', break),
        ]),
    },
  },

  objlocal: {},

  compspec: {
    forspec: root.forspec,
    ifspec: root.ifspec,
  },

  forspec: {
    new(id, expr): {
      toString(indent):
        indent
        + std.join(' ', [
          'for',
          id.toString(),
          'in',
          expr.toString(),
        ]),
    },
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

  'assert': {},

  bind: {
    bind(id, expr): {
      toString(indent='', break=''):
        std.join(' ', [
          indent,
          'local',
          id.toString(),
          '=',
          expr.toString(),
        ]),
    },
    func(id, expr, params=[]): {
      toString(indent='', break=''):
        std.join('', [
          indent,
          id.toString(),
          '(',
          std.join(
            ', ',
            [
              param.toString()
              for param in params
            ]
          ),
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
};


local obj = j.object.members([
  j.member.field.field(
    j.fieldname.id('hello'),
    j.functioncall(
      j.fieldaccess(
        j['self'],
        j.id('heloF'),
      ),
      [
        j.arg.expr(
          j.array.items()
        ),
        j.arg.id(
          j.id('secondparam'),
          j.array.items([
            j.string('c'),
            j.string('d'),
          ]),
        ),
      ],
    ),
  ),
  j.member.field.field(
    j.fieldname.string('helo'),
    j.array.forloop(
      j.id('value'),
      j.forspec.new(
        j.id('value'),
        j.array.items([
          j.string('heloitem' + i)
          for i in std.range(0, 10)
        ]),
      )
    ),
  ),
  j.member.field.field(
    j.fieldname.string('hleo'),
    j.object.forloop(
      j.id('value'),
      j.id('value'),
      j.forspec.new(
        j.id('value'),
        j.array.items([
          j.string('a'),
          j.string('b'),
        ]),
      ),
      [
        j.ifspec(j['true']),
      ]
    ),
  ),
  local p = j.id('secondparam');
  j.member.field.func(
    j.fieldname.id('heloF'),
    p,
    [
      j.param.id('param1'),
      j.param.expr(
        p,
        j.array.items(),
      ),
    ],
    hidden=true,
  ),

  j.member.field.field(
    j.fieldname.id('b'),
    j.indexing(
      j.fieldaccess(j['self'], j.id('helo')),
      [
        j.number(1),
        j.number(6),
        j.number(2),
      ]
    )
  ),
]);

obj.toString(indent='', break='\n')
