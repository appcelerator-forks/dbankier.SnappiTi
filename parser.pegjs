start =
  objects

word =
  letters: [a-zA-Z]+
  {return letters.join("");}

extendedword=
  head:[a-zA-Z] tail:[a-zA-Z0-9_$]*
  {return head + tail.join("");}

integer "integer"
  = digits:[0-9]+ { return parseInt(digits.join(""), 10); }

id = 
  "#" word:extendedword 
  {return word;}

class =
  "." word:extendedword
  {return word}

plussed_object = 
  "+" object:parent_object
    {return object}
  / parent_object


object =
  word:word classes1:class* id:id classes2:class*
    {return [{object: word, id: id, classes:classes1.concat(classes2)}]}
  / word:word classes1:class+
    {return [{object: word, classes:classes1}]}
  / word:word
    {return [{object: word}]}
  / "(" parent_object:parent_object ")"
    {return parent_object}

multiplied_object = 
  object:object "*" i:integer
    { var ret = [];
      for (var a = 0; a < i; a++) {
        var current = {object: object[0].object};
        if (object[0].id) { 
          current.id = object[0].id;
        }
        if (object[0].classes) {
          current.classes = object[0].classes;
        }
        var id = current.id 
        if (id !== undefined && id.indexOf("$") > -1 ) {
          current.id = id.replace(/\$/, (a+1));
        }
        if (current.classes) {
          current.classes = current.classes.map(function(x) {return x.replace(/\$/, (a+1));});
        }
        ret.push(current) 
      };  
      return ret
    }
  / object 


added_object = 
  first:multiplied_object rest:plussed_object
    {return first.concat([].concat.apply([],rest))}
  / multiplied_object

parent_object = 
  parent:added_object ">" child:parent_object
    {return parent.map(function(p) { p.children=child; return p});}
  / added_object

objects =
  first:parent_object
    {return first}

  
