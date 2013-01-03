# tmux_wrapper
A wrapper to create tmux sessions, written in [Bash] [1].

## Useage
    Useage: ./tmux.sh {local|server}

## Config
There are two type of configurations, the syntax listed below. You can find the samples in config directory.

### Local
    SESSION='session_name'
    WINDOWS="
    cmd1/window1_name
    'cmd2 -option'/window2_name
    'cmd3'/window3_name"
    COLOR='color'

### Server
    SESSION='session_name'
    WINDOWS='
    user@host/window1_name
    host/window2_name'
    COLOR='color'

### Color
Supported colors listed below.
  * red
  * green
  * blue
  * cyan
  * yellow
  * purple
  * gary

## Author
Timothy.Lee a.k.a MarlboroMoo.

## License
Released under the [MIT License] [2].

  [1]: http://goo.gl/pkmI                   "Bourne-Again SHell"
  [2]: http://opensource.org/licenses/MIT   "MIT License"


