local j = import './main.libsonnet';
local xtd = import 'github.com/jsonnet-libs/xtd/main.libsonnet';

{
  local matchFieldname(astFieldname, fieldname) =
    local value = fieldnameValue(astFieldname);
    if value != null
    then value == fieldname
    else false,

  local fieldnameValue(astFieldname) =
    if std.member(['id', 'string'], astFieldname.type)
    then astFieldname[astFieldname.type]
    else null,

  local matchHidden(inc_hidden, field) = (inc_hidden || field.hidden == false),

  // std.type(x)
  type(ast):
    assert std.isObject(ast) : 'type error: expected object, got ' + std.type(ast);
    if 'type' in ast
    then ast.type
    else '<type not set>',


  // std.isObject(v)
  isObject(ast): self.type(ast) == 'object',

  // std.get(o, f, default=null, inc_hidden=true)
  // returns astField or default
  get(astObject, fieldname, default=null, inc_hidden=true):
    assert self.isObject(astObject) : 'type error: expected object, got ' + self.type(astObject);
    assert std.isString(fieldname) : 'type error: expected string, got ' + std.type(fieldname);
    local matches =
      std.filter(
        function(field)
          'fieldname' in field
          && matchFieldname(field.fieldname, fieldname)
          && matchHidden(inc_hidden, field),
        astObject.members
      );

    if std.length(matches) > 0
    then matches[0]  // duplicate fieldnames are not allowed so it is safe to assume the first item is a match
    else default,

  // std.objectFieldsEx(obj, hidden)
  // returns [astFieldname, ...]
  objectFieldsEx(astObject, hidden):
    assert self.isObject(astObject) : 'type error: expected object, got ' + self.type(astObject);
    std.filterMap(
      function(field) 'fieldname' in field && matchHidden(hidden, field),
      function(field) field.fieldname,
      astObject.members
    ),

  // std.objectFields(o)
  objectFields(astObject): self.objectFieldsEx(astObject, hidden=false),
  // std.objectFieldsAll(o)
  objectFieldsAll(astObject): self.objectFieldsEx(astObject, hidden=true),

  // std.objectHasEx(obj, fname, hidden)
  objectHasEx(astObject, fieldname, hidden):
    assert self.isObject(astObject) : 'type error: expected object, got ' + self.type(astObject);
    assert std.isString(fieldname) : 'type error: expected string, got ' + std.type(fieldname);
    local matches = std.filter(
      function(f) matchFieldname(f, fieldname),
      self.objectFieldsEx(astObject, hidden),
    );
    std.length(matches) > 0,

  //std.objectHas(o, f)
  objectHas(astObject, fieldname): self.objectHasEx(astObject, fieldname, hidden=false),
  //std.objectHasAll(o, f)
  objectHasAll(astObject, fieldname): self.objectHasEx(astObject, fieldname, hidden=true),

  deepMergeObjects(astObjects):
    self.deepMergeObjectFields(
      j.object.members([
        member
        for obj in astObjects
        for member in obj.members
      ])
    ),

  deepMergeObjectFields(astObject):
    local fields = std.foldl(
      function(acc, field)
        local fieldname = fieldnameValue(field.fieldname);
        if fieldname != null
           && self.objectHasAll(j.object.members(acc), fieldname)
        then
          std.map(
            function(item)
              if fieldnameValue(item.fieldname) == fieldname
              then
                j.field.field(
                  field.fieldname,
                  self.deepMergeObjectFields(
                    j.object.members(
                      item.expr.members
                      + field.expr.members
                    )
                  ),
                  additive=item.additive || field.additive,
                  hidden=item.hidden || field.hidden,
                )
              else item,
            acc,
          )
        else acc + [field],
      astObject.members,
      []
    );
    j.object.members(fields),

  setFieldsAtPath(to, members, additive=true, hidden=false):
    std.foldr(
      function(key, acc)
        if key == ''
        then acc
        else
          j.object.members([
            j.field.field(
              j.fieldname.string(key),
              acc,
              additive,
              hidden,
            ),
          ]),
      xtd.string.splitEscape(to, '.'),
      j.object.members(members),
    ),

  getFieldsFromPaths(ast, paths):
    local fields = [
      self.getFieldFromPath(ast, path)
      for path in paths
    ];
    std.filter(function(x) x != null, fields),

  getFieldFromPath(ast, path):
    std.foldl(
      function(acc, fieldname)
        if fieldname == ''  // fieldname can be empty if path='.'
        then acc
        else if self.type(acc) == 'field'  // when acc is a field, assume end?
        then acc
        else
          self.get(
            acc,
            fieldname,
            if std.startsWith(fieldname, '#')
            then null  // Don't error on docstring fields
            else error 'field %s on path %s not found' % [fieldname, path]
          ),
      xtd.string.splitEscape(path, '.'),
      ast,
    ),
}
