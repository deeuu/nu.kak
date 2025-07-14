# https://nu-lang.org/

# Detection
# ‾‾‾‾‾‾‾‾‾

hook global BufCreate .*\.nu %{
    set-option buffer filetype nu
}

# Initialization
# ‾‾‾‾‾‾‾‾‾‾‾‾‾‾

hook global WinSetOption filetype=nu %{
    require-module nu

    set-option window static_words %opt{nu_static_words}

    # trim trailingn whitespace when exiting insert
    hook window ModeChange pop:insert:.* -group nu-trim-indent nu-trim-indent
    # Apply indentation rules
    hook window InsertChar .* -group nu-indent nu-indent-on-char
    hook window InsertChar \n -group nu-indent nu-indent-on-new-line

    hook -once -always window WinSetOption filetype=.* %{ remove-hooks window nu-.+ }
}

hook -group nu-highlight global WinSetOption filetype=nu %{
    add-highlighter window/nu ref nu
    hook -once -always window WinSetOption filetype=.* %{ remove-highlighter window/nu }
}

provide-module nu %@

# Highlighters
# ‾‾‾‾‾‾‾‾‾‾‾‾

add-highlighter shared/nu regions
add-highlighter shared/nu/code default-region group

# Comments
add-highlighter shared/nu/comment region '#' '$' fill comment
add-highlighter shared/nu/code/ regex '#.*?$' 0:comment

# Strings
add-highlighter shared/nu/double_string region '"' '(?<!\\)(\\\\)*"' fill string
add-highlighter shared/nu/single_string region "'" "(?<!\\)(\\\\)*'" fill string
add-highlighter shared/nu/raw_string  region -match-capture %{(?<!')r(#*)'} %{'(#*)} fill string
add-highlighter shared/nu/backtick_string region "`" "`" fill string

add-highlighter shared/nu/$_double_string  region '\$"' '(?<!\\)(\\\\)*"'  regions
add-highlighter shared/nu/$_double_string/ default-region fill string
add-highlighter shared/nu/$_double_string/ region '\(' '\)' ref nu

add-highlighter shared/nu/$_single_string  region "\$'" "(?<!\\)(\\\\)*'" regions
add-highlighter shared/nu/$_single_string/ default-region fill string
add-highlighter shared/nu/$_single_string/ region '\(' '\)' ref nu

# function delcaration
# treat as string for consistency with string function declaration, i.e. def "cmd subcmd" []
add-highlighter shared/nu/code/function_declaration regex (?:def\h+)(\w+)\h+\[ 1:string

# Variables
add-highlighter shared/nu/code/ regex '\$[\w\-]+' 0:variable

# Flag parameters
add-highlighter shared/nu/code/ regex '--[\w\-]+' 0:module
add-highlighter shared/nu/code/ regex '-[a-zA-Z]' 0:module

# Command blocks or closures
add-highlighter shared/nu/code/ regex '\{' 0:delimiter
add-highlighter shared/nu/code/ regex '\}' 0:delimiter

# Brackets and parentheses
add-highlighter shared/nu/code/ regex '[\[\]\(\)]' 0:delimiter

add-highlighter shared/nu/code/question_mark regex \? 0:meta

add-highlighter shared/nu/code/modules regex 'use\s+([\w+/?]+)' 0:meta

# units
add-highlighter shared/nu/code/ regex '\b([0-9_]\.?)(ns|us|ms|sec|min|hr|day|wk)\b' 2:meta
add-highlighter shared/nu/code/ regex '\b([0-9_]\.?)((k|K|m|M|g|G|t|T|p|P|e|E)?(b|B))\b' 2:meta

# Numbers
add-highlighter shared/nu/code/ regex '\b[-+]?[_0-9]+(\.[_0-9]+)?' 0:value
add-highlighter shared/nu/code/ regex '\b[-+]?\.[_0-9]+' 0:value

add-highlighter shared/nu/code/ regex '\b(0x[0-9a-fA-F_]+)' 0:value
add-highlighter shared/nu/code/ regex '\b(0x\[[0-9a-fA-F\s]+\])' 0:value

add-highlighter shared/nu/code/ regex '\b(0o[_0-7]+)' 0:value
add-highlighter shared/nu/code/ regex '\b(0o\[[0-7\s]+\])' 0:value

add-highlighter shared/nu/code/ regex '\b(0b[_01]+)' 0:value
add-highlighter shared/nu/code/ regex '\b(0b\[[01\s]+\])' 0:value

# Operators
add-highlighter shared/nu/code/operators regex \s+((!=)|(<=?)|(>=?)|(=[~=]?)|(!~)|(\+[\+=]?)|(-=?)|(\*[\*=]?)|(/[=/]?)|(\+\+=))\s+ 0:operator

evaluate-commands %sh{
    # Grammar
    keywords="while|where|use|try|source-env|source|return|plugin use|overlay use|overlay new|overlay hide|overlay|mut|module|match|loop|let|if|hide|for|extern|export-env|export use|export module|export extern|export def|export const|export alias|export|def|continue|const|break|alias"
    operators="xor|starts-with|or|not-in|not-has|not|mod|in|has|ends-with|bit-xor|bit-shr|bit-shl|bit-or|bit-and|and"
    commands="zip|wrap|with-env|window|whoami|which|watch|view span|view source|view ir|view files|view blocks|view|version check|version|values|url split-query|url parse|url join|url encode|url decode|url build-query|url|upsert|update cells|update|uniq-by|uniq|uname|ulimit|tutor|transpose|touch|to yml|to yaml|to xml|to tsv|to toml|to text|to nuon|to msgpackz|to msgpack|to md|to json|to html|to csv|to|timeit|term size|term query|term|tee|take while|take until|take|table|sys users|sys temp|sys net|sys mem|sys host|sys disks|sys cpu|sys|str upcase|str trim|str title-case|str substring|str stats|str starts-with|str snake-case|str screaming-snake-case|str reverse|str replace|str pascal-case|str length|str kebab-case|str join|str index-of|str expand|str ends-with|str downcase|str distance|str contains|str capitalize|str camel-case|str|stor update|stor reset|stor open|stor insert|stor import|stor export|stor delete|stor create|stor|start|split words|split row|split list|split column|split chars|split cell-path|split|sort-by|sort|slice|sleep|skip while|skip until|skip|shuffle|seq date|seq char|seq|select|scope variables|scope modules|scope externs|scope engine-stats|scope commands|scope aliases|scope|schema|save|run-external|rotate|roll up|roll right|roll left|roll down|roll|rm|reverse|rename|reject|reduce|random uuid|random int|random float|random dice|random chars|random bool|random binary|random|query db|ps|print|prepend|port|plugin stop|plugin rm|plugin list|plugin add|plugin|path type|path split|path self|path relative-to|path parse|path join|path expand|path exists|path dirname|path basename|path|parse|par-each|panic|overlay list|open|nu-highlight|nu-check|mv|move|mktemp|mkdir|metadata set|metadata access|metadata|merge deep|merge|math variance|math tanh|math tan|math sum|math stddev|math sqrt|math sinh|math sin|math round|math product|math mode|math min|math median|math max|math log|math ln|math floor|math exp|math cosh|math cos|math ceil|math avg|math arctanh|math arctan|math arcsinh|math arcsin|math arccosh|math arccos|math abs|math|ls|load-env|lines|let-env|length|last|kill|keybindings listen|keybindings list|keybindings default|keybindings|join|job unfreeze|job spawn|job list|job kill|job|items|is-terminal|is-not-empty|is-empty|is-admin|into value|into string|into sqlite|into record|into int|into glob|into float|into filesize|into duration|into datetime|into cell-path|into bool|into binary|into|interleave|inspect|insert|input listen|input list|input|ignore|http put|http post|http patch|http options|http head|http get|http delete|http|history session|history import|history|histogram|hide-env|help pipe-and-redirect|help operators|help modules|help externs|help escapes|help commands|help aliases|help|headers|hash sha256|hash md5|hash|group-by|grid|glob|get|generate|from yml|from yaml|from xml|from xlsx|from url|from tsv|from toml|from ssv|from ods|from nuon|from msgpackz|from msgpack|from json|from csv|from|format pattern|format number|format filesize|format duration|format date|format bits|format|flatten|first|find|filter|fill|explore|explain|exit|exec|every|error make|enumerate|encode hex|encode base64|encode base32hex|encode base32|encode|echo|each while|each|du|drop nth|drop column|drop|do|detect columns|describe|default|decode hex|decode base64|decode base32hex|decode base32|decode|debug profile|debug info|debug|date to-timezone|date now|date list-timezone|date humanize|date format|date|cp|config use-colors|config reset|config nu|config flatten|config env|config|complete|compact|commandline set-cursor|commandline get-cursor|commandline edit|commandline|columns|collect|clear|chunks|chunk-by|char|cd|cal|bytes starts-with|bytes split|bytes reverse|bytes replace|bytes remove|bytes length|bytes index-of|bytes ends-with|bytes collect|bytes build|bytes at|bytes add|bytes|bits xor|bits shr|bits shl|bits ror|bits rol|bits or|bits not|bits and|bits|attr search-terms|attr example|attr category|ast|append|any|ansi strip|ansi link|ansi gradient|ansi|all"

    types="string int float bool table duration date list block closure nothing range binary record null filesize any"

    values="false true"

    join() { sep=$2; set -- $1; IFS="$sep"; echo "$*"; }

    static_words="$(join "${keywords} ${operators} ${commands} ${types} ${values}" ' ')"

    # Add the language's grammar to the static completion list
    printf %s\\n "declare-option str-list nu_static_words ${static_words}"

    types="$(join "${types}" '|')"
    values="$(join "${values}" '|')"
    keywords_re="\b((while)|(where)|(use)|(try)|(source-env)|(source)|(return)|(plugin\s+use)|(overlay\s+use)|(overlay\s+new)|(overlay\s+hide)|(overlay)|(mut)|(module)|(match)|(loop)|(let)|(if)|(hide)|(for)|(extern)|(export-env)|(export\s+use)|(export\s+module)|(export\s+extern)|(export\s+def)|(export\s+const)|(export\s+alias)|(export)|(def)|(continue)|(const)|(break)|(alias))\b"
    operators_re="\b((xor)|(starts-with)|(or)|(not-in)|(not-has)|(not)|(mod)|(in)|(has)|(ends-with)|(bit-xor)|(bit-shr)|(bit-shl)|(bit-or)|(bit-and)|(and))\b"
    commands_re="\b((zip)|(wrap)|(with-env)|(window)|(whoami)|(which)|(watch)|(view\s+span)|(view\s+source)|(view\s+ir)|(view\s+files)|(view\s+blocks)|(view)|(version\s+check)|(version)|(values)|(url\s+split-query)|(url\s+parse)|(url\s+join)|(url\s+encode)|(url\s+decode)|(url\s+build-query)|(url)|(upsert)|(update\s+cells)|(update)|(uniq-by)|(uniq)|(uname)|(ulimit)|(tutor)|(transpose)|(touch)|(to\s+yml)|(to\s+yaml)|(to\s+xml)|(to\s+tsv)|(to\s+toml)|(to\s+text)|(to\s+nuon)|(to\s+msgpackz)|(to\s+msgpack)|(to\s+md)|(to\s+json)|(to\s+html)|(to\s+csv)|(to)|(timeit)|(term\s+size)|(term\s+query)|(term)|(tee)|(take\s+while)|(take\s+until)|(take)|(table)|(sys\s+users)|(sys\s+temp)|(sys\s+net)|(sys\s+mem)|(sys\s+host)|(sys\s+disks)|(sys\s+cpu)|(sys)|(str\s+upcase)|(str\s+trim)|(str\s+title-case)|(str\s+substring)|(str\s+stats)|(str\s+starts-with)|(str\s+snake-case)|(str\s+screaming-snake-case)|(str\s+reverse)|(str\s+replace)|(str\s+pascal-case)|(str\s+length)|(str\s+kebab-case)|(str\s+join)|(str\s+index-of)|(str\s+expand)|(str\s+ends-with)|(str\s+downcase)|(str\s+distance)|(str\s+contains)|(str\s+capitalize)|(str\s+camel-case)|(str)|(stor\s+update)|(stor\s+reset)|(stor\s+open)|(stor\s+insert)|(stor\s+import)|(stor\s+export)|(stor\s+delete)|(stor\s+create)|(stor)|(start)|(split\s+words)|(split\s+row)|(split\s+list)|(split\s+column)|(split\s+chars)|(split\s+cell-path)|(split)|(sort-by)|(sort)|(slice)|(sleep)|(skip\s+while)|(skip\s+until)|(skip)|(shuffle)|(seq\s+date)|(seq\s+char)|(seq)|(select)|(scope\s+variables)|(scope\s+modules)|(scope\s+externs)|(scope\s+engine-stats)|(scope\s+commands)|(scope\s+aliases)|(scope)|(schema)|(save)|(run-external)|(rotate)|(roll\s+up)|(roll\s+right)|(roll\s+left)|(roll\s+down)|(roll)|(rm)|(reverse)|(rename)|(reject)|(reduce)|(random\s+uuid)|(random\s+int)|(random\s+float)|(random\s+dice)|(random\s+chars)|(random\s+bool)|(random\s+binary)|(random)|(query\s+db)|(ps)|(print)|(prepend)|(port)|(plugin\s+stop)|(plugin\s+rm)|(plugin\s+list)|(plugin\s+add)|(plugin)|(path\s+type)|(path\s+split)|(path\s+self)|(path\s+relative-to)|(path\s+parse)|(path\s+join)|(path\s+expand)|(path\s+exists)|(path\s+dirname)|(path\s+basename)|(path)|(parse)|(par-each)|(panic)|(overlay\s+list)|(open)|(nu-highlight)|(nu-check)|(mv)|(move)|(mktemp)|(mkdir)|(metadata\s+set)|(metadata\s+access)|(metadata)|(merge\s+deep)|(merge)|(math\s+variance)|(math\s+tanh)|(math\s+tan)|(math\s+sum)|(math\s+stddev)|(math\s+sqrt)|(math\s+sinh)|(math\s+sin)|(math\s+round)|(math\s+product)|(math\s+mode)|(math\s+min)|(math\s+median)|(math\s+max)|(math\s+log)|(math\s+ln)|(math\s+floor)|(math\s+exp)|(math\s+cosh)|(math\s+cos)|(math\s+ceil)|(math\s+avg)|(math\s+arctanh)|(math\s+arctan)|(math\s+arcsinh)|(math\s+arcsin)|(math\s+arccosh)|(math\s+arccos)|(math\s+abs)|(math)|(ls)|(load-env)|(lines)|(let-env)|(length)|(last)|(kill)|(keybindings\s+listen)|(keybindings\s+list)|(keybindings\s+default)|(keybindings)|(join)|(job\s+unfreeze)|(job\s+spawn)|(job\s+list)|(job\s+kill)|(job)|(items)|(is-terminal)|(is-not-empty)|(is-empty)|(is-admin)|(into\s+value)|(into\s+string)|(into\s+sqlite)|(into\s+record)|(into\s+int)|(into\s+glob)|(into\s+float)|(into\s+filesize)|(into\s+duration)|(into\s+datetime)|(into\s+cell-path)|(into\s+bool)|(into\s+binary)|(into)|(interleave)|(inspect)|(insert)|(input\s+listen)|(input\s+list)|(input)|(ignore)|(http\s+put)|(http\s+post)|(http\s+patch)|(http\s+options)|(http\s+head)|(http\s+get)|(http\s+delete)|(http)|(history\s+session)|(history\s+import)|(history)|(histogram)|(hide-env)|(help\s+pipe-and-redirect)|(help\s+operators)|(help\s+modules)|(help\s+externs)|(help\s+escapes)|(help\s+commands)|(help\s+aliases)|(help)|(headers)|(hash\s+sha256)|(hash\s+md5)|(hash)|(group-by)|(grid)|(glob)|(get)|(generate)|(from\s+yml)|(from\s+yaml)|(from\s+xml)|(from\s+xlsx)|(from\s+url)|(from\s+tsv)|(from\s+toml)|(from\s+ssv)|(from\s+ods)|(from\s+nuon)|(from\s+msgpackz)|(from\s+msgpack)|(from\s+json)|(from\s+csv)|(from)|(format\s+pattern)|(format\s+number)|(format\s+filesize)|(format\s+duration)|(format\s+date)|(format\s+bits)|(format)|(flatten)|(first)|(find)|(filter)|(fill)|(explore)|(explain)|(exit)|(exec)|(every)|(error\s+make)|(enumerate)|(encode\s+hex)|(encode\s+base64)|(encode\s+base32hex)|(encode\s+base32)|(encode)|(echo)|(each\s+while)|(each)|(du)|(drop\s+nth)|(drop\s+column)|(drop)|(do)|(detect\s+columns)|(describe)|(default)|(decode\s+hex)|(decode\s+base64)|(decode\s+base32hex)|(decode\s+base32)|(decode)|(debug\s+profile)|(debug\s+info)|(debug)|(date\s+to-timezone)|(date\s+now)|(date\s+list-timezone)|(date\s+humanize)|(date\s+format)|(date)|(cp)|(config\s+use-colors)|(config\s+reset)|(config\s+nu)|(config\s+flatten)|(config\s+env)|(config)|(complete)|(compact)|(commandline\s+set-cursor)|(commandline\s+get-cursor)|(commandline\s+edit)|(commandline)|(columns)|(collect)|(clear)|(chunks)|(chunk-by)|(char)|(cd)|(cal)|(bytes\s+starts-with)|(bytes\s+split)|(bytes\s+reverse)|(bytes\s+replace)|(bytes\s+remove)|(bytes\s+length)|(bytes\s+index-of)|(bytes\s+ends-with)|(bytes\s+collect)|(bytes\s+build)|(bytes\s+at)|(bytes\s+add)|(bytes)|(bits\s+xor)|(bits\s+shr)|(bits\s+shl)|(bits\s+ror)|(bits\s+rol)|(bits\s+or)|(bits\s+not)|(bits\s+and)|(bits)|(attr\s+search-terms)|(attr\s+example)|(attr\s+category)|(ast)|(append)|(any)|(ansi\s+strip)|(ansi\s+link)|(ansi\s+gradient)|(ansi)|(all))\b"

    # Highlight keywords
    printf %s "
        add-highlighter shared/nu/code/ regex ${keywords_re} 0:keyword
        add-highlighter shared/nu/code/ regex ${commands_re} 0:builtin
        add-highlighter shared/nu/code/ regex ${operators_re} 0:operator
        add-highlighter shared/nu/code/ regex \b(${types})\b 0:type
        add-highlighter shared/nu/code/ regex \b(${values})\b 0:value
    "
}

# Commands

define-command -hidden nu-trim-indent %{
    # remove trailing white spaces
    try %{ execute-keys -draft -itersel x s \h+$ <ret> d }
}

define-command -hidden nu-insert-on-new-line %{
    evaluate-commands -draft -itersel %{
        # copy '#' comment prefix and following white spaces
        try %{ exec -draft k x s ^\h*#\h* <ret> y jgh P }
    }
}

define-command -hidden nu-indent-on-char %<
    evaluate-commands -draft -itersel %<
        # align closer token to its opener when alone on a line
        try %< execute-keys -draft <a-h> <a-k> ^\h+[\]})]$ <ret> m <a-S> 1<a-&> >
    >
>

define-command -hidden nu-indent-on-new-line %<
    evaluate-commands -draft -itersel %<
        # preserve previous line indent
        try %{ exec -draft <semicolon> K <a-&> }

        # cleanup trailing whitespaces from previous line
        try %{ execute-keys -draft k : nu-trim-indent <ret> }
        # indent after lines ending with opener token
        try %< execute-keys -draft k x <a-k> [[{(]\h*$ <ret> j <a-gt> >
        # deindent closer token(s) when after cursor
        try %< execute-keys -draft x <a-k> ^\h*[}\])] <ret> gh / [}\])] <ret> m <a-S> 1<a-&> >
    >
>

@
