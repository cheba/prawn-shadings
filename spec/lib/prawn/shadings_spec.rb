# encoding: utf-8

require 'spec_helper'

describe "Shadingns" do
  before(:each) { create_pdf }

  describe 'linear gradients' do
    it "should create a /Pattern resource" do
      @pdf.fill_gradient [0, @pdf.bounds.height],
        [@pdf.bounds.width, @pdf.bounds.height], 'FF0000', '0000FF'

      grad = PDF::Inspector::Graphics::Pattern.analyze(@pdf.render)
      pattern = grad.patterns.values.first

      pattern.should_not be_nil
      pattern[:Shading][:ShadingType].should == 2
      pattern[:Shading][:Coords].should == [0, 0, @pdf.bounds.width, 0]
      pattern[:Shading][:Function][:C0].zip([1, 0, 0]).all?{ |x1, x2|
        (x1-x2).abs < 0.01
      }.should be_true
      pattern[:Shading][:Function][:C1].zip([0, 0, 1]).all?{ |x1, x2|
        (x1-x2).abs < 0.01
      }.should be_true
    end

    it "fill_gradient should set fill color to the pattern" do
      @pdf.fill_gradient [0, @pdf.bounds.height],
        [@pdf.bounds.width, @pdf.bounds.height], 'FF0000', '0000FF'

      str = @pdf.render
      str.should =~ %r{/Pattern\s+cs\s*/SP-?\d+\s+scn}
    end

    it "stroke_gradient should set stroke color to the pattern" do
      @pdf.stroke_gradient [0, @pdf.bounds.height],
        [@pdf.bounds.width, @pdf.bounds.height], 'FF0000', '0000FF'

      str = @pdf.render
      str.should =~ %r{/Pattern\s+CS\s*/SP-?\d+\s+SCN}
    end

    it "should be reused if used twice on page" do
      2.times do
        @pdf.fill_gradient [0, @pdf.bounds.height],
          [@pdf.bounds.width, @pdf.bounds.height], 'FF0000', '0000FF'
      end

      @pdf.page.resources[:Pattern].length.should == 1
    end

    it "should validate colors to be in the same color space" do
      lambda {
        @pdf.fill_gradient [0, @pdf.bounds.height],
          [@pdf.bounds.width, @pdf.bounds.height], 'FF0000', [1.0, 1.0, 1.0, 1.0]
      }.should raise_error(ArgumentError)
    end
  end

  describe 'radial gradients' do
    it "should create a /Pattern resource" do
      @pdf.fill_gradient [0, @pdf.bounds.height], 10,
        [@pdf.bounds.width, @pdf.bounds.height], 20, 'FF0000', '0000FF'

      grad = PDF::Inspector::Graphics::Pattern.analyze(@pdf.render)
      pattern = grad.patterns.values.first

      pattern.should_not be_nil
      pattern[:Shading][:ShadingType].should == 3
      pattern[:Shading][:Coords].should == [0, 0, 10, @pdf.bounds.width, 0, 20]
      pattern[:Shading][:Function][:C0].zip([1, 0, 0]).all?{ |x1, x2|
        (x1-x2).abs < 0.01
      }.should be_true
      pattern[:Shading][:Function][:C1].zip([0, 0, 1]).all?{ |x1, x2|
        (x1-x2).abs < 0.01
      }.should be_true
    end

    it "fill_gradient should set fill color to the pattern" do
      @pdf.fill_gradient [0, @pdf.bounds.height], 10,
        [@pdf.bounds.width, @pdf.bounds.height], 20, 'FF0000', '0000FF'

      str = @pdf.render
      str.should =~ %r{/Pattern\s+cs\s*/SP-?\d+\s+scn}
    end

    it "stroke_gradient should set stroke color to the pattern" do
      @pdf.stroke_gradient [0, @pdf.bounds.height], 10,
        [@pdf.bounds.width, @pdf.bounds.height], 20, 'FF0000', '0000FF'

      str = @pdf.render
      str.should =~ %r{/Pattern\s+CS\s*/SP-?\d+\s+SCN}
    end

    it "should be reused if used twice on page" do
      2.times do
        @pdf.stroke_gradient [0, @pdf.bounds.height], 10,
          [@pdf.bounds.width, @pdf.bounds.height], 20, 'FF0000', '0000FF'
      end

      @pdf.page.resources[:Pattern].length.should == 1
    end

    it "should validate colors to be in the same color space" do
      lambda {
        @pdf.stroke_gradient [0, @pdf.bounds.height], 10,
          [@pdf.bounds.width, @pdf.bounds.height], 20, 'FF0000', [1.0, 1.0, 1.0, 1.0]
      }.should raise_error(ArgumentError)
    end
  end

  describe 'Free-Form Gouraud-Shaded Triangle Mesh' do
    it "should create a /Pattern resource" do
      @pdf.fill_gradient :ffgstm do
        [
          [0, 0, 0, 'ff0000'],
          [0, 0, 100, '00ff00'],
          [0, 100, 0, '0000ff']
        ]
      end

      grad = PDF::Inspector::Graphics::Pattern.analyze(@pdf.render)
      pattern = grad.patterns.values.first

      pattern.should_not be_nil
      shading = pattern[:Shading].hash
      shading[:ShadingType].should == 4

      shading[:Decode].should == [0, 100, 0, 100, 0, 1, 0, 1, 0, 1]
      pattern[:Shading].data.length.should == 36
      pattern[:Shading].data.should == [0, 0, 0, 0xff, 0, 0,   0, 0, 0xffffffff, 0, 0xff, 0,   0, 0xffffffff, 0, 0, 0, 0xff].pack("CNNCCC" * 3)
    end

    it "fill_gradient should set fill color to the pattern" do
      @pdf.fill_gradient :ffgstm do
        [
          [0, 0, 0, 'ff0000'],
          [0, 0, 100, '00ff00'],
          [0, 100, 0, '0000ff']
        ]
      end

      str = @pdf.render
      str.should =~ %r{/Pattern\s+cs\s*/SP-?\d+\s+scn}
    end

    it "stroke_gradient should set stroke color to the pattern" do
      @pdf.stroke_gradient :ffgstm do
        [
          [0, 0, 0, 'ff0000'],
          [0, 0, 100, '00ff00'],
          [0, 100, 0, '0000ff']
        ]
      end

      str = @pdf.render
      str.should =~ %r{/Pattern\s+CS\s*/SP-?\d+\s+SCN}
    end

    it "should be reused if used twice on page" do
      2.times do
        @pdf.fill_gradient :ffgstm do
          [
            [0, 0, 0, 'ff0000'],
            [0, 0, 100, '00ff00'],
            [0, 100, 0, '0000ff']
          ]
        end
      end

      @pdf.page.resources[:Pattern].length.should == 1
    end

    it "should validate flag" do
      lambda {
        @pdf.fill_gradient :ffgstm do
          [
            [0, 0, 0, 'ff0000'],
            [2, 0, 100, '00ff00'],
            [100, 100, 0, '0000ff']
          ]
        end
      }.should raise_error(ArgumentError, /flag/i)
    end

    it "should validate vertices colorspace" do
      lambda {
        @pdf.fill_gradient :ffgstm do
          [
            [0, 0, 0, 'ff0000'],
            [0, 0, 100, [0, 1, 0, 1]],
            [0, 100, 0, '0000ff']
          ]
        end
      }.should raise_error(ArgumentError, /color space/i)
    end
  end

  describe 'Lattice-Form Gouraud-Shaded Triangle Mesh' do
    it "should create a /Pattern resource" do
      @pdf.fill_gradient :lfgstm do
        [
          [ [0, 100, '000000'], [100, 100, 'ff0000'] ],
          [ [0, 0,   'ff0000'], [100, 0,   '000000'] ]
        ]
      end

      grad = PDF::Inspector::Graphics::Pattern.analyze(@pdf.render)
      pattern = grad.patterns.values.first

      pattern.should_not be_nil
      shading = pattern[:Shading].hash
      shading[:ShadingType].should == 5

      shading[:Decode].should == [0, 100, 0, 100, 0, 1, 0, 1, 0, 1]
      pattern[:Shading].data.length.should == 44
      pattern[:Shading].data.should == [0, 0xffffffff, 0, 0, 0,   0xffffffff, 0xffffffff, 0xff, 0, 0,   0, 0, 0xff, 0, 0,   0xffffffff, 0, 0, 0, 0].pack("NNCCC" * 4)
    end

    it "fill_gradient should set fill color to the pattern" do
      @pdf.fill_gradient :lfgstm do
        [
          [ [0, 100, '000000'], [100, 100, 'ff0000'] ],
          [ [0, 0,   'ff0000'], [100, 0,   '000000'] ]
        ]
      end

      str = @pdf.render
      str.should =~ %r{/Pattern\s+cs\s*/SP-?\d+\s+scn}
    end

    it "stroke_gradient should set stroke color to the pattern" do
      @pdf.stroke_gradient :lfgstm do
        [
          [ [0, 100, '000000'], [100, 100, 'ff0000'] ],
          [ [0, 0,   'ff0000'], [100, 0,   '000000'] ]
        ]
      end

      str = @pdf.render
      str.should =~ %r{/Pattern\s+CS\s*/SP-?\d+\s+SCN}
    end

    it "should be reused if used twice on page" do
      2.times do
      @pdf.fill_gradient :lfgstm do
        [
          [ [0, 100, '000000'], [100, 100, 'ff0000'] ],
          [ [0, 0,   'ff0000'], [100, 0,   '000000'] ]
        ]

        end
      end

      @pdf.page.resources[:Pattern].length.should == 1
    end

    it "should validate number of rows" do
      lambda {
        @pdf.fill_gradient :lfgstm do
          [
            [ [0, 0, 'ff0000'], [100, 0, '000000'] ]
          ]
        end
      }.should raise_error(ArgumentError, /rows/i)
    end

    it "should validate number of vertices in all rows" do
      lambda {
        @pdf.fill_gradient :lfgstm do
          [
            [ [0, 100, '000000'] ],
            [ [0, 0,   'ff0000'], [100, 0,   '000000'] ]
          ]
        end
      }.should raise_error(ArgumentError, /at least 2 vertices per row/i)
    end

    it "should validate number of vertices in all rows" do
      lambda {
        @pdf.fill_gradient :lfgstm do
          [
            [ [0, 100, '000000'], [100, 100, 'ff0000'], [200, 100, '00ff00'] ],
            [ [0, 0,   'ff0000'], [100, 0,   '000000'] ]
          ]
        end
      }.should raise_error(ArgumentError, /rectangular matrix/i)
    end

    it "should validate vertices colorspace" do
      lambda {
      @pdf.fill_gradient :lfgstm do
        [
          [ [0, 100, '000000'], [100, 100, [1, 1, 1, 1]] ],
          [ [0, 0,   'ff0000'], [100, 0,   '000000'] ]
        ]

        end
      }.should raise_error(ArgumentError, /color space/i)
    end
  end

  describe 'Coons Patch Mesh' do
    it "should create a /Pattern resource" do
      @pdf.fill_gradient :cpm do
        [
          [
            0,
            0, 0,
              0, 0,
              0, 100,
            0, 100,
              0, 100,
              100, 100,
            100, 100,
              100, 100,
              100, 0,
            100, 0,
              100, 0,
              0, 0,
            'ffff00', 'ff0000', '00ff00', '0000ff'
          ]
        ]
      end

      grad = PDF::Inspector::Graphics::Pattern.analyze(@pdf.render)
      pattern = grad.patterns.values.first

      pattern.should_not be_nil
      shading = pattern[:Shading].hash
      shading[:ShadingType].should == 6

      shading[:Decode].should == [0, 100, 0, 100, 0, 1, 0, 1, 0, 1]
      pattern[:Shading].data.length.should == 109
      pattern[:Shading].data.should == [0,
                                        0, 0,
                                          0, 0,
                                          0, 0xffffffff,
                                        0, 0xffffffff,
                                          0, 0xffffffff,
                                          0xffffffff, 0xffffffff,
                                        0xffffffff, 0xffffffff,
                                          0xffffffff, 0xffffffff,
                                          0xffffffff, 0,
                                        0xffffffff, 0,
                                          0xffffffff, 0,
                                          0, 0,
                                        0xff, 0xff, 0,
                                        0xff, 0, 0,
                                        0, 0xff, 0,
                                        0, 0, 0xff].pack("CN24C12")
    end

    it "should create a /Pattern resource with reused vertices" do
      @pdf.fill_gradient :cpm do
        [
          [
            0,
            0, 0,
              0, 0,
              0, 100,
            0, 100,
              0, 100,
              100, 100,
            100, 100,
              100, 100,
              100, 0,
            100, 0,
              100, 0,
              0, 0,
            'ffff00', 'ff0000', '00ff00', '0000ff'
          ],
          [
            1,
              0, 100,
              100, 100,
            100, 100,
              100, 100,
              100, 0,
            100, 0,
              100, 0,
              0, 0,
            '00ff00', '0000ff'
          ],

        ]
      end

      grad = PDF::Inspector::Graphics::Pattern.analyze(@pdf.render)
      pattern = grad.patterns.values.first

      pattern.should_not be_nil
      shading = pattern[:Shading].hash
      shading[:ShadingType].should == 6

      shading[:Decode].should == [0, 100, 0, 100, 0, 1, 0, 1, 0, 1]
      pattern[:Shading].data.length.should == 180
      pattern[:Shading].data.should == [0,
                                        0, 0,
                                          0, 0,
                                          0, 0xffffffff,
                                        0, 0xffffffff,
                                          0, 0xffffffff,
                                          0xffffffff, 0xffffffff,
                                        0xffffffff, 0xffffffff,
                                          0xffffffff, 0xffffffff,
                                          0xffffffff, 0,
                                        0xffffffff, 0,
                                          0xffffffff, 0,
                                          0, 0,
                                        0xff, 0xff, 0,
                                        0xff, 0, 0,
                                        0, 0xff, 0,
                                        0, 0, 0xff,

                                        1,
                                          0, 0xffffffff,
                                          0xffffffff, 0xffffffff,
                                        0xffffffff, 0xffffffff,
                                          0xffffffff, 0xffffffff,
                                          0xffffffff, 0,
                                        0xffffffff, 0,
                                          0xffffffff, 0,
                                          0, 0,
                                        0, 0xff, 0,
                                        0, 0, 0xff
      ].pack("CN24C12CN16C6")
    end

    it "fill_gradient should set fill color to the pattern" do
      @pdf.fill_gradient :cpm do
        [
          [
            0,
            0, 0,
              0, 0,
              0, 100,
            0, 100,
              0, 100,
              100, 100,
            100, 100,
              100, 100,
              100, 0,
            100, 0,
              100, 0,
              0, 0,
            'ffff00', 'ff0000', '00ff00', '0000ff'
          ]
        ]
      end

      str = @pdf.render
      str.should =~ %r{/Pattern\s+cs\s*/SP-?\d+\s+scn}
    end

    it "stroke_gradient should set stroke color to the pattern" do
      @pdf.stroke_gradient :cpm do
        [
          [
            0,
            0, 0,
              0, 0,
              0, 100,
            0, 100,
              0, 100,
              100, 100,
            100, 100,
              100, 100,
              100, 0,
            100, 0,
              100, 0,
              0, 0,
            'ffff00', 'ff0000', '00ff00', '0000ff'
          ]
        ]

      end

      str = @pdf.render
      str.should =~ %r{/Pattern\s+CS\s*/SP-?\d+\s+SCN}
    end

    it "should be reused if used twice on page" do
      2.times do
        @pdf.fill_gradient :cpm do
          [
            [
              0,
              0, 0,
                0, 0,
                0, 100,
              0, 100,
                0, 100,
                100, 100,
              100, 100,
                100, 100,
                100, 0,
              100, 0,
                100, 0,
                0, 0,
              'ffff00', 'ff0000', '00ff00', '0000ff'
            ]
          ]
        end
      end

      @pdf.page.resources[:Pattern].length.should == 1
    end

    it "should validate flags" do
      lambda {
        @pdf.fill_gradient :cpm do
          [
            [
              20,
              0, 0,
                0, 0,
                0, 100,
              0, 100,
                0, 100,
                100, 100,
              100, 100,
                100, 100,
                100, 0,
              100, 0,
                100, 0,
                0, 0,
              'ffff00', 'ff0000', '00ff00', '0000ff'
            ]
          ]
        end
      }.should raise_error(ArgumentError, /flag/i)
    end

    it "should validate vertices colorspace" do
      lambda {
        @pdf.fill_gradient :cpm do
          [
            [
              0,
              0, 0,
                0, 0,
                0, 100,
              0, 100,
                0, 100,
                100, 100,
              100, 100,
                100, 100,
                100, 0,
              100, 0,
                100, 0,
                0, 0,
              'ffff00', 'ff0000', '00ff00', [1, 1, 1, 1]
            ]
          ]
        end
      }.should raise_error(ArgumentError, /color space/i)
    end
  end

  describe 'Tensor-Product Patch Mesh' do
    it "should create a /Pattern resource" do
      @pdf.fill_gradient :tppm do
        [
          [
            0,
            0, 0,
              0, 0,
              0, 100,
            0, 100,
              0, 100,
              100, 100,
            100, 100,
              100, 100,
              100, 0,
            100, 0,
              100, 0,
              0, 0,
            50, 50,
            50, 50,
            50, 50,
            50, 50,
            'ffff00', 'ff0000', '00ff00', '0000ff'
          ]
        ]
      end

      grad = PDF::Inspector::Graphics::Pattern.analyze(@pdf.render)
      pattern = grad.patterns.values.first

      pattern.should_not be_nil
      shading = pattern[:Shading].hash
      shading[:ShadingType].should == 7

      shading[:Decode].should == [0, 100, 0, 100, 0, 1, 0, 1, 0, 1]
      pattern[:Shading].data.length.should == 141
      pattern[:Shading].data.should == [0,
                                        0, 0,
                                          0, 0,
                                          0, 0xffffffff,
                                        0, 0xffffffff,
                                          0, 0xffffffff,
                                          0xffffffff, 0xffffffff,
                                        0xffffffff, 0xffffffff,
                                          0xffffffff, 0xffffffff,
                                          0xffffffff, 0,
                                        0xffffffff, 0,
                                          0xffffffff, 0,
                                          0, 0,
                                        0x80000000, 0x80000000,
                                        0x80000000, 0x80000000,
                                        0x80000000, 0x80000000,
                                        0x80000000, 0x80000000,
                                        0xff, 0xff, 0,
                                        0xff, 0, 0,
                                        0, 0xff, 0,
                                        0, 0, 0xff].pack("CN32C12")
    end

    it "should create a /Pattern resource with reused vertices" do
      @pdf.fill_gradient :tppm do
        [
          [
            0,
            0, 0,
              0, 0,
              0, 100,
            0, 100,
              0, 100,
              100, 100,
            100, 100,
              100, 100,
              100, 0,
            100, 0,
              100, 0,
              0, 0,
            50, 50,
            50, 50,
            50, 50,
            50, 50,
            'ffff00', 'ff0000', '00ff00', '0000ff'
          ],
          [
            1,
              0, 100,
              100, 100,
            100, 100,
              100, 100,
              100, 0,
            100, 0,
              100, 0,
              0, 0,
            50, 50,
            50, 50,
            50, 50,
            50, 50,
            '00ff00', '0000ff'
          ],

        ]
      end

      grad = PDF::Inspector::Graphics::Pattern.analyze(@pdf.render)
      pattern = grad.patterns.values.first

      pattern.should_not be_nil
      shading = pattern[:Shading].hash
      shading[:ShadingType].should == 7

      shading[:Decode].should == [0, 100, 0, 100, 0, 1, 0, 1, 0, 1]
      pattern[:Shading].data.length.should == 244
      pattern[:Shading].data.should == [0,
                                        0, 0,
                                          0, 0,
                                          0, 0xffffffff,
                                        0, 0xffffffff,
                                          0, 0xffffffff,
                                          0xffffffff, 0xffffffff,
                                        0xffffffff, 0xffffffff,
                                          0xffffffff, 0xffffffff,
                                          0xffffffff, 0,
                                        0xffffffff, 0,
                                          0xffffffff, 0,
                                          0, 0,
                                        0x80000000, 0x80000000,
                                        0x80000000, 0x80000000,
                                        0x80000000, 0x80000000,
                                        0x80000000, 0x80000000,
                                        0xff, 0xff, 0,
                                        0xff, 0, 0,
                                        0, 0xff, 0,
                                        0, 0, 0xff,

                                        1,
                                          0, 0xffffffff,
                                          0xffffffff, 0xffffffff,
                                        0xffffffff, 0xffffffff,
                                          0xffffffff, 0xffffffff,
                                          0xffffffff, 0,
                                        0xffffffff, 0,
                                          0xffffffff, 0,
                                          0, 0,
                                        0x80000000, 0x80000000,
                                        0x80000000, 0x80000000,
                                        0x80000000, 0x80000000,
                                        0x80000000, 0x80000000,
                                        0, 0xff, 0,
                                        0, 0, 0xff
      ].pack("CN32C12CN24C6")
    end

    it "fill_gradient should set fill color to the pattern" do
      @pdf.fill_gradient :tppm do
        [
          [
            0,
            0, 0,
              0, 0,
              0, 100,
            0, 100,
              0, 100,
              100, 100,
            100, 100,
              100, 100,
              100, 0,
            100, 0,
              100, 0,
              0, 0,
            50, 50,
            50, 50,
            50, 50,
            50, 50,
            'ffff00', 'ff0000', '00ff00', '0000ff'
          ]
        ]
      end

      str = @pdf.render
      str.should =~ %r{/Pattern\s+cs\s*/SP-?\d+\s+scn}
    end

    it "stroke_gradient should set stroke color to the pattern" do
      @pdf.stroke_gradient :tppm do
        [
          [
            0,
            0, 0,
              0, 0,
              0, 100,
            0, 100,
              0, 100,
              100, 100,
            100, 100,
              100, 100,
              100, 0,
            100, 0,
              100, 0,
              0, 0,
            50, 50,
            50, 50,
            50, 50,
            50, 50,
            'ffff00', 'ff0000', '00ff00', '0000ff'
          ]
        ]

      end

      str = @pdf.render
      str.should =~ %r{/Pattern\s+CS\s*/SP-?\d+\s+SCN}
    end

    it "should be reused if used twice on page" do
      2.times do
        @pdf.fill_gradient :tppm do
          [
            [
              0,
              0, 0,
                0, 0,
                0, 100,
              0, 100,
                0, 100,
                100, 100,
              100, 100,
                100, 100,
                100, 0,
              100, 0,
                100, 0,
                0, 0,
              50, 50,
              50, 50,
              50, 50,
              50, 50,
              'ffff00', 'ff0000', '00ff00', '0000ff'
            ]
          ]
        end
      end

      @pdf.page.resources[:Pattern].length.should == 1
    end

    it "should validate flags" do
      lambda {
        @pdf.fill_gradient :tppm do
          [
            [
              20,
              0, 0,
                0, 0,
                0, 100,
              0, 100,
                0, 100,
                100, 100,
              100, 100,
                100, 100,
                100, 0,
              100, 0,
                100, 0,
                0, 0,
              50, 50,
              50, 50,
              50, 50,
              50, 50,
              'ffff00', 'ff0000', '00ff00', '0000ff'
            ]
          ]
        end
      }.should raise_error(ArgumentError, /flag/i)
    end

    it "should validate vertices colorspace" do
      lambda {
        @pdf.fill_gradient :tppm do
          [
            [
              0,
              0, 0,
                0, 0,
                0, 100,
              0, 100,
                0, 100,
                100, 100,
              100, 100,
                100, 100,
                100, 0,
              100, 0,
                100, 0,
                0, 0,
              50, 50,
              50, 50,
              50, 50,
              50, 50,
              'ffff00', 'ff0000', '00ff00', [1, 1, 1, 1]
            ]
          ]
        end
      }.should raise_error(ArgumentError, /color space/i)
    end
  end
end
