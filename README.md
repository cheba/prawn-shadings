
Prawn Shadings
==============

[![Build Status](https://travis-ci.org/cheba/prawn-shadings.png)](https://travis-ci.org/cheba/prawn-shadings)

This is a Prawn extension that implements advanced PDF shadings.

Specifically, it a bit refactors already implemented linear and radial gradients
and adds a few more advanced ones.

Currently implemented shadings:

* Axial Shadings (or linear gradients) (PDF Type 2 Shading)
* Radial Shading (PDF Type 3 Shading)
* Free-Form Gouraud-Shaded Triangle Meshes (PDF Type 4 Shading)
* Lattice-Form Gouraud-Shaded Triangle Meshes (PDF Type 5 Shading)
* Coons Patch Meshes (PDF Type 6 Shading)
* Tensor-Product Patch Meshes (PDF Type 7 Shading)

API is simple but you need to know what data to supply. Please get familiar with
Section 4.6.3 of PDF Reference.


A Word of Warning
-----------------

Please note that this gem gives you ability use all these shadings in your
generated PDF but gives no guarantee that PDF will be rendered correctly.

Just a few examples:

* OS X Preview has problems with flags other than 0 in Type 4, 6 and 7 type
  shadings.
* OS X Previews renders Type 7 shadings exactly the same as Type 6 shadings
  ignoring all 4 extra control points.
* PDF.js can not render pretty much any of these.

Installation
------------

    gem install prawn-shadings


Usage
-----

    require 'prawn/shadings'


Testing
-------

To run the tests:

    $ rake


Contributing
------------

1. Fork it.
2. Create a branch (`git checkout -b my_shading`)
3. Commit your changes (`git commit -am "Added Shading"`)
4. Push to the branch (`git push origin my_shading`)
5. Open a [Pull Request][1]

[1]: http://github.com/cheba/prawn-shadings/pulls
