// =================================================================================================
//
//	Starling Framework
//	Copyright Gamua GmbH. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================

package starling.filters;

import starling.rendering.Painter;
import starling.textures.Texture;

/** The GlowFilter class lets you apply a glow effect to display objects.
 *  It is similar to the drop shadow filter with the distance and angle properties set to 0.
 *
 *  <p>This filter can also be used to create outlines around objects. The trick is to
 *  assign an alpha value that's (much) greater than <code>1.0</code>, and full resolution.
 *  For example, the following code will yield a nice black outline:</p>
 *
 *  <listing>object.filter = new GlowFilter(0x0, 30, 1, 1.0);</listing>
 */
class GlowFilter extends FragmentFilter
{
    private var _blurFilter:BlurFilter;
    private var _compositeFilter:CompositeFilter;

    #if commonjs
    private static function __init__ () {
        
        untyped Object.defineProperties (GlowFilter.prototype, {
            "color": { get: untyped __js__ ("function () { return this.get_color (); }"), set: untyped __js__ ("function (v) { return this.set_color (v); }") },
            "alpha": { get: untyped __js__ ("function () { return this.get_alpha (); }"), set: untyped __js__ ("function (v) { return this.set_alpha (v); }") },
            "blur": { get: untyped __js__ ("function () { return this.get_blur (); }"), set: untyped __js__ ("function (v) { return this.set_blur (v); }") },
        });
        
    }
    #end

    /** Initializes a new GlowFilter instance with the specified parameters.
     *
     * @param color      the color of the glow
     * @param alpha      the alpha value of the glow. Values between 0 and 1 modify the
     *                   opacity; values > 1 will make it stronger, i.e. produce a harder edge.
     * @param blur       the amount of blur used to create the glow. Note that high
     *                   values will cause the number of render passes to grow.
     * @param resolution the resolution of the filter texture. '1' means full resolution,
     *                   '0.5' half resolution, etc.
     */
    public function new(color:UInt=0xffff00, alpha:Float=1.0, blur:Float=1.0,
                        resolution:Float=0.5)
    {
        super();
        
        _blurFilter = new BlurFilter(blur, blur, resolution);
        _compositeFilter = new CompositeFilter();
        _compositeFilter.setColorAt(0, color, true);
        _compositeFilter.setAlphaAt(0, alpha);

        updatePadding();
    }

    /** @inheritDoc */
    override public function dispose():Void
    {
        _blurFilter.dispose();
        _compositeFilter.dispose();

        super.dispose();
    }

    /** @private */
    override public function process(painter:Painter, helper:IFilterHelper,
                                     input0:Texture = null, input1:Texture = null,
                                     input2:Texture = null, input3:Texture = null):Texture
    {
        var glow:Texture = _blurFilter.process(painter, helper, input0);
        var result:Texture = _compositeFilter.process(painter, helper, glow, input0);
        helper.putTexture(glow);
        return result;
    }

    /** @private */
    override private function get_numPasses():Int
    {
        return _blurFilter.numPasses + _compositeFilter.numPasses;
    }

    private function updatePadding():Void
    {
        padding.copyFrom(_blurFilter.padding);
    }

    /** The color of the glow. @default 0xffff00 */
    public var color(get, set):UInt;
    private function get_color():UInt { return _compositeFilter.getColorAt(0); }
    private function set_color(value:UInt):UInt
    {
        if (color != value)
        {
            _compositeFilter.setColorAt(0, value, true);
            setRequiresRedraw();
        }
        return value;
    }

    /** The alpha value of the glow. Values between 0 and 1 modify the opacity;
     *  values > 1 will make it stronger, i.e. produce a harder edge. @default 1.0 */
    public var alpha(get, set):Float;
    private function get_alpha():Float { return _compositeFilter.getAlphaAt(0); }
    private function set_alpha(value:Float):Float
    {
        if (alpha != value)
        {
            _compositeFilter.setAlphaAt(0, value);
            setRequiresRedraw();
        }
        return value;
    }

    /** The amount of blur with which the glow is created.
     *  The number of required passes will be <code>Math.ceil(value) × 2</code>.
     *  @default 1.0 */
    public var blur(get, set):Float;
    private function get_blur():Float { return _blurFilter.blurX; }
    private function set_blur(value:Float):Float
    {
        if (blur != value)
        {
            _blurFilter.blurX = _blurFilter.blurY = value;
            setRequiresRedraw();
            updatePadding();
        }
        return value;
    }

    /** @private */
    override private function get_resolution():Float { return _blurFilter.resolution; }
    override private function set_resolution(value:Float):Float
    {
        if (resolution != value)
        {
            _blurFilter.resolution = value;
            setRequiresRedraw();
            updatePadding();
        }
        return value;
    }
}