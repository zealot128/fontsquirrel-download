# Fontsquirrel::Download

Download and extract font-kits from [fontsquirrel](http://www.fontsquirrel.com/fontface) easily with a rake tasks.

## Installation

Add this line to your application's Gemfile:

    gem 'fontsquirrel-download', group: "development"

And then execute:

    $ bundle

Add to your application.css/application.css.scss:

```css
//= require fonts
```

Because the download will append the necessary changes to ``app/assets/stylesheets/_fonts.scss``.

## Usage



Use Rake task, specify the Font name as written in the URL from font-squirrel, e.g. the well-known LaTeX-Font:

```bash
rake font:download NAME=TeX-Gyre-Bonum
```

This will download the fonts to ``app/assets/fonts`` and append the style rules to ``app/assets/stylesheets/_fonts.scss``.

After that, you can use that style definition in your css rules, like:

```css
body {
  font-family: "TeXGyreBonumRegular", serif;
}
```

The names always vary a little, just look them up in the \_fonts.scss


## Webfont-Kits

You can also create font-kits with Fontsquirrel's great Webfont-generator and extract+apply that zipfile and merge a meaningful scss-file with correct font weight and style:

```
rake font:install FILE=/tmp/webfontkit-123.zip
```


## Limitations

* Until know, it will download the normal subset of the font.
  Some fonts have no special chars (like German Umlauts) at all, some have them in a subset. Maybe specifying the subset comes in handy.
