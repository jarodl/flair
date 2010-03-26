flair
=====

Flair is a little "language" that "compiles" into CSS.

Compile a flair script:

    flair /path/to/script.flair
    => creates script.css

###Examples:###

CSS class selectors:

    class Wrapper:
        background = rgb(255, 255, 255)
        margins = { right => 0.5, bottom => 0.5 }
        padding = 1

compiles to:

    .wrapper {
        background: rgb(255, 255, 255);
        margin-right: 0.5em;
        margin-bottom: 0.5em;
        padding: 1em;
    }

CSS id selectors:

    id Navigation:
        background = rgb(40, 40, 40)
        float = left

compiles to:

    #navigation {
       background: rgb(40, 40, 40);
       float: left;
    }


