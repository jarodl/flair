Flair
=====

Flair is a little "language" that "compiles" into CSS.

Compile a flair script: (an example is provided in `/bin`)

    flair /example/code.flair
    => creates code.css

### Examples that work: (for right now) ###

CSS class selectors:

    class Wrapper:
        background = "rgb(255, 255, 255)"
        padding = 1

compiles to:

    .wrapper {
        background: rgb(255, 255, 255);
        padding: 1em;
    }

CSS id selectors:

    id Navigation:
        background = "rgb(40, 40, 40)"
        float = "left"

compiles to:

    #navigation {
       background: rgb(40, 40, 40);
       float: left;
    }


More About Flair:
============

Flair was inspired by
[Coffee-Script](http://github.com/jashkenas/coffee-script) and the book
["Create Your Own Freaking Awesome Programming
Language"](http://createyourproglang.com). It is
meant for developers who do not enjoy writing CSS. Flair translates into normal CSS.

## Ideas: ##
* allow classes and identifiers to 'inherit' from each other
* access class and indentifier attributes from other classes/identifiers
* should be able to set attributes on condition (active, hover, etc)
* python like import of other files
* mixins for repetitive css blocks
* some way to template common styles

### A simple example showing inheritance and attribute accessors: ###

    import 'fonts'
    import 'reset'

    # variables for storing a color or path to file
    @body_bg = "rgb(120, 125, 10)"
    @link_img = "/images/link_bg.png"

    class Header:
        background = "rgb(255, 255, 255)"
        margins = { right => 0.5, bottom => 0.5 }
        padding = 1

        if parent == div:
            # do something
        elsif parent == ul:
            # do something specific to ul

    class Footer < Header:
        min-height = 15
        border = "1px solid blue"

    class Button:
        color = "blue"

        if hover:
            color = "red"
        elsif active:
            color = "green"

    id Featured:
        background = Header.background
        border = Footer.border


### would compile to: ###

    .header, .footer {
      background: rgb(255, 255, 255);
      margin-right: 0.5em;
      margin-bottom: 0.5em;
      padding: 1em;
    }

    .footer {
      min-height: 15em;
      border: 1px solid blue;
    }

    .button {
      color: blue;
    }

    .button:hover {
      color: red;
    }

    #featured {
      background: rgb(255, 255, 255);
      border: 1px solid blue;
    }


### Don't like whitespace? ###

I have gone back and forth between using whitespace or begin..end blocks
like Ruby. I think I will stick with whitespace for now unless I find a
good reason to do otherwise. The only reason I can think of is to also
change the syntax of assignment from using `=` to using `:` like
coffee-script and CSS.

    class Header
      background: "rgb(240, 240, 240)"
      height: 20
    end

    id Footer < Header
      color: red
    end
