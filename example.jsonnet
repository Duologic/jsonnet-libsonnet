local j = import './main.libsonnet';

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
    j.localbind(
      j.bind.bind(
        j.id('arr'),
        j.array.items([
          j.string('heloitem' + i)
          for i in std.range(0, 10)
        ]),
      ),
      j.array.forloop(
        j.id('value'),
        j.forspec(
          j.id('value'),
          j.id('arr'),
        )
      )
    ),
  ),
  j.member.field.field(
    j.fieldname.string('hleo'),
    j.object.forloop(
      j.id('value'),
      j.id('value'),
      j.forspec(
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
    j.anonymousfunction(
      j.conditional(
        j.id('abool'),
        j.array.items(),
        j.indexing(
          j.fieldaccess(j['self'], j.id('helo')),
          [
            j.number(1),
            j.number(6),
            j.number(2),
          ]
        )
      ),
      [j.id('abool')],
    ),
    hidden=true,
  ),

  j.member.field.field(
    j.fieldname.id('c'),
    j.functioncall(
      j.fieldaccess(
        j['self'],
        j.id('b'),
      ),
      [
        j['false'],
      ],
    ),
  ),
]);

obj.toString(indent='', break='\n')
