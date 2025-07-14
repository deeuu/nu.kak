def to_regex [data: list<string> ] {
    let re = ($data | sort -r | each {|s| $s | str replace ' ' '\s+' --all | $"\(($in)\)" } | flatten | str join '|' )
    return $"\\b\(($re)\)\\b"
}

def to_string [data: list<string> ] {
    $data | sort -r | str join '|'
}

def main [] {
    let cmds = (help commands | where command_type == built-in | get name)
    let kws = (help commands | where command_type == keyword | get name)
    let ops = (help operators | get operator | parse -r '(\w+(-\w+)?)') | get capture0
  
    let properties = {
        "NU_COMMANDS": (to_string $cmds),
        "NU_COMMANDS_RE": (to_regex $cmds),
        "NU_KEYWORDS": (to_string $kws),
        "NU_KEYWORDS_RE": (to_regex $kws),
        "NU_OPERATORS": (to_string $ops),
        "NU_OPERATORS_RE": (to_regex $ops),
    } | transpose key data

    mut output = open --raw nushell.template.kak

    for $p in $properties {
        $output = $output | str replace -r $"{{\(\\s+\)?($p.key)\(\\s+\)?}}"  $p.data
    }

    mkdir rc

    $output | save -f rc/nu.kak

}
